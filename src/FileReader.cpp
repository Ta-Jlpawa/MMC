
#include <iostream>
#include <vector>
#include <string>
#include <windows.h>
#include <shobjidl.h>
#include <wrl/client.h> // 使用ComPtr管理COM对象生命周期

#pragma comment(lib, "Ole32.lib")

using Microsoft::WRL::ComPtr;

// 辅助函数：将 UTF-8 字符串转换为宽字符串 (UTF-16)
std::wstring UTF8ToWide(const std::string& str) {
    if (str.empty()) return std::wstring();
    int size = MultiByteToWideChar(CP_UTF8, 0, &str[0], (int)str.size(), NULL, 0);
    std::wstring result(size, 0);
    MultiByteToWideChar(CP_UTF8, 0, &str[0], (int)str.size(), &result[0], size);
    return result;
}

// 辅助函数：将宽字符串 (UTF-16) 转换为 UTF-8 字符串
std::string WideToUTF8(const std::wstring& wstr) {
    if (wstr.empty()) return std::string();
    int size = WideCharToMultiByte(CP_UTF8, 0, &wstr[0], (int)wstr.size(), NULL, 0, NULL, NULL);
    std::string result(size, 0);
    WideCharToMultiByte(CP_UTF8, 0, &wstr[0], (int)wstr.size(), &result[0], size, NULL, NULL);
    return result;
}

// 打印使用说明
void PrintUsage(const char* progName) {
    std::cout << "用法: " << progName << " <模式> [文件后缀1] [文件后缀2] ...\n";
    std::cout << "运行模式:\n";
    std::cout << "  1 : 单选文件 (可接后缀名, 例如: txt png)\n";
    std::cout << "  2 : 多选文件 (可接后缀名, 例如: txt png)\n";
    std::cout << "  3 : 单选文件夹\n";
    std::cout << "  4 : 多选文件夹\n";
}

int main(int argc, char* argv[]) {
    // 设置控制台输出为UTF-8，防止中文路径乱码
    SetConsoleOutputCP(CP_UTF8);
    int mode = 0;

    if (argc < 2) {
        // PrintUsage(argv[0]);
        mode = 1;
        // return 1;
    }
    else {
        mode = std::stoi(argv[1]);
    }

    if (mode < 1 || mode > 4) {
        std::cerr << "错误: 无效的运行模式。\n";
        PrintUsage(argv[0]);
        return 1;
    }

    // 解析文件后缀
    std::vector<std::string> extensions;
    for (int i = 2; i < argc; ++i) {
        std::string ext = argv[i];
        if (ext[0] != '.') {
            ext = "." + ext; // 自动补充点号
        }
        extensions.push_back(ext);
    }

    // 初始化COM库
    HRESULT hr = CoInitializeEx(NULL, COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE);
    if (FAILED(hr)) {
        std::cerr << "COM 初始化失败。\n";
        return 1;
    }

    {
        // 创建文件对话框实例
        ComPtr<IFileOpenDialog> pDialog;
        hr = CoCreateInstance(CLSID_FileOpenDialog, NULL, CLSCTX_ALL, IID_PPV_ARGS(&pDialog));
        if (FAILED(hr)) {
            CoUninitialize();
            std::cerr << "创建 IFileOpenDialog 失败。\n";
            return 1;
        }

        // 设置对话框选项
        DWORD dwOptions;
        pDialog->GetOptions(&dwOptions);
        dwOptions |= FOS_FORCEFILESYSTEM; // 仅限文件系统项

        if (mode == 2 || mode == 4) {
            dwOptions |= FOS_ALLOWMULTISELECT; // 允许多选
        }
        if (mode == 3 || mode == 4) {
            dwOptions |= FOS_PICKFOLDERS; // 选择文件夹
        }

        pDialog->SetOptions(dwOptions);

        // 如果是文件选择模式，并且提供了后缀，则应用过滤器
        std::wstring filterSpecStr = L"";
        std::wstring filterNameStr = L"Supported Files (";
        if ((mode == 1 || mode == 2) && !extensions.empty()) {
            for (size_t i = 0; i < extensions.size(); ++i) {
                std::wstring wExt = UTF8ToWide(extensions[i]);
                filterSpecStr += L"*" + wExt;
                filterNameStr += L"*" + wExt;
                if (i < extensions.size() - 1) {
                    filterSpecStr += L";";
                    filterNameStr += L", ";
                }
            }
            filterNameStr += L")";

            COMDLG_FILTERSPEC fileTypes[] = {
                { filterNameStr.c_str(), filterSpecStr.c_str() },
                { L"All Files (*.*)", L"*.*" }
            };
            pDialog->SetFileTypes(2, fileTypes);
            pDialog->SetFileTypeIndex(1);
        }

        // 显示对话框
        hr = pDialog->Show(NULL);

        if (SUCCEEDED(hr)) {
            ComPtr<IShellItemArray> pItemArray;
            hr = pDialog->GetResults(&pItemArray); // 使用 GetResults 统一处理单选和多选

            if (SUCCEEDED(hr)) {
                DWORD count = 0;
                pItemArray->GetCount(&count);

                for (DWORD i = 0; i < count; ++i) {
                    ComPtr<IShellItem> pItem;
                    if (SUCCEEDED(pItemArray->GetItemAt(i, &pItem))) {
                        PWSTR pszFilePath = NULL;
                        if (SUCCEEDED(pItem->GetDisplayName(SIGDN_FILESYSPATH, &pszFilePath))) {
                            // 将 UTF-16 转换为 UTF-8 输出
                            std::cout << WideToUTF8(pszFilePath) << std::endl;
                            CoTaskMemFree(pszFilePath); // 释放内存
                        }
                    }
                }
            }
        }
        else if (hr == HRESULT_FROM_WIN32(ERROR_CANCELLED)) {
            // 用户取消了对话框，什么也不输出
        }
        else {
            std::cerr << "显示对话框失败，错误码: " << std::hex << hr << "\n";
        }
    }

    CoUninitialize();
    return 0;
}