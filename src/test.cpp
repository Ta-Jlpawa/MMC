#include <iostream>


#include <windows.h>
#include <shobjidl.h>

#pragma comment(lib, "Ole32.lib")

int main()
{
    CoInitialize(NULL);

    IFileOpenDialog* dialog = nullptr;

    HRESULT hr = CoCreateInstance(
        CLSID_FileOpenDialog,
        NULL,
        CLSCTX_INPROC_SERVER,
        IID_PPV_ARGS(&dialog)
    );

    if (SUCCEEDED(hr))
    {
        if (SUCCEEDED(dialog->Show(NULL)))
        {
            IShellItem* item;

            if (SUCCEEDED(dialog->GetResult(&item)))
            {
                PWSTR path = nullptr;

                item->GetDisplayName(
                    SIGDN_FILESYSPATH,
                    &path
                );

                std::wcout << "111" << path << std::endl;
                CoTaskMemFree(path);
                item->Release();
            }
        }

        dialog->Release();
    }

    CoUninitialize();

    return 0;
}