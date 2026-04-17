// injector.cpp - Injects hook.dll into the target process via LoadLibraryA remote thread
#include <Windows.h>
#include <TlHelp32.h>
#include <iostream>
#include <string>

DWORD FindPID(const char* exeName) {
    HANDLE snap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (snap == INVALID_HANDLE_VALUE) return 0;
    PROCESSENTRY32 pe;
    pe.dwSize = sizeof(pe);
    if (Process32First(snap, &pe)) {
        do {
            if (_stricmp(pe.szExeFile, exeName) == 0) {
                CloseHandle(snap);
                return pe.th32ProcessID;
            }
        } while (Process32Next(snap, &pe));
    }
    CloseHandle(snap);
    return 0;
}

int main(int argc, char** argv) {
    if (argc < 3) {
        std::cout << "Usage: injector.exe <target.exe> <hook.dll>\n";
        std::cout << "Example: injector.exe game.exe hook.dll\n";
        return 1;
    }

    const char* targetExe = argv[1];
    const char* dllName   = argv[2];

    // Resolve full path of the DLL
    char fullDllPath[MAX_PATH];
    if (!GetFullPathNameA(dllName, MAX_PATH, fullDllPath, nullptr)) {
        std::cerr << "[ERR] Could not resolve DLL path: " << dllName << "\n";
        return 1;
    }

    // Check the DLL actually exists before trying to inject
    if (GetFileAttributesA(fullDllPath) == INVALID_FILE_ATTRIBUTES) {
        std::cerr << "[ERR] DLL not found: " << fullDllPath << "\n";
        return 1;
    }

    DWORD pid = FindPID(targetExe);
    if (!pid) {
        std::cerr << "[ERR] Process not found: " << targetExe << "\n";
        return 1;
    }
    std::cout << "[*] Found " << targetExe << " -> PID " << pid << "\n";

    HANDLE hProc = OpenProcess(PROCESS_ALL_ACCESS, FALSE, pid);
    if (!hProc) {
        std::cerr << "[ERR] OpenProcess failed (error " << GetLastError() << ")\n";
        std::cerr << "      Try running injector.exe as Administrator.\n";
        return 1;
    }

    // Allocate space for the DLL path string in the remote process
    SIZE_T pathLen = strlen(fullDllPath) + 1;
    LPVOID remote = VirtualAllocEx(hProc, nullptr, pathLen, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
    if (!remote) {
        std::cerr << "[ERR] VirtualAllocEx failed\n";
        CloseHandle(hProc);
        return 1;
    }

    // Write DLL path into the remote process
    if (!WriteProcessMemory(hProc, remote, fullDllPath, pathLen, nullptr)) {
        std::cerr << "[ERR] WriteProcessMemory failed\n";
        VirtualFreeEx(hProc, remote, 0, MEM_RELEASE);
        CloseHandle(hProc);
        return 1;
    }

    // Spawn a remote thread at LoadLibraryA with our DLL path as the argument
    LPVOID loadLib = (LPVOID)GetProcAddress(GetModuleHandleA("kernel32.dll"), "LoadLibraryA");
    HANDLE hThread = CreateRemoteThread(hProc, nullptr, 0,
        (LPTHREAD_START_ROUTINE)loadLib, remote, 0, nullptr);

    if (!hThread) {
        std::cerr << "[ERR] CreateRemoteThread failed (error " << GetLastError() << ")\n";
        VirtualFreeEx(hProc, remote, 0, MEM_RELEASE);
        CloseHandle(hProc);
        return 1;
    }

    std::cout << "[*] Remote thread created, waiting for LoadLibrary...\n";
    WaitForSingleObject(hThread, 5000);

    DWORD exitCode = 0;
    GetExitCodeThread(hThread, &exitCode);
    if (exitCode == 0) {
        std::cerr << "[ERR] LoadLibraryA returned NULL — DLL failed to load.\n";
        std::cerr << "      Check that hook.dll and MinHook.dll are accessible from the target process.\n";
    } else {
        std::cout << "[OK] hook.dll injected successfully (module base: 0x"
                  << std::hex << exitCode << std::dec << ")\n";
    }

    CloseHandle(hThread);
    VirtualFreeEx(hProc, remote, 0, MEM_RELEASE);
    CloseHandle(hProc);
    return 0;
}
