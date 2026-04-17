// viewer.cpp - Named pipe server that receives and displays logs from hook.dll
#include <Windows.h>
#include <iostream>
#include <string>
#include <ctime>

std::string Timestamp() {
    SYSTEMTIME st;
    GetLocalTime(&st);
    char buf[32];
    snprintf(buf, sizeof(buf), "%02d:%02d:%02d.%03d",
        st.wHour, st.wMinute, st.wSecond, st.wMilliseconds);
    return buf;
}

int main() {
    SetConsoleTitleA("DLL Tracer - Log Viewer");

    std::cout << "================================================\n";
    std::cout << "  DLL Tracer - Log Viewer\n";
    std::cout << "  Pipe: \\\\.\\pipe\\dlltracer\n";
    std::cout << "================================================\n";
    std::cout << "[*] Creating pipe server, waiting for hook.dll...\n\n";

    HANDLE pipe = CreateNamedPipeA(
        "\\\\.\\pipe\\dlltracer",
        PIPE_ACCESS_INBOUND,
        PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT,
        1,      // max instances
        4096,   // out buffer
        4096,   // in buffer
        0,      // default timeout
        nullptr
    );

    if (pipe == INVALID_HANDLE_VALUE) {
        std::cerr << "[ERR] CreateNamedPipe failed (error " << GetLastError() << ")\n";
        std::cerr << "      Is another viewer.exe already running?\n";
        system("pause");
        return 1;
    }

    // Block until hook.dll connects
    if (!ConnectNamedPipe(pipe, nullptr)) {
        DWORD err = GetLastError();
        if (err != ERROR_PIPE_CONNECTED) {
            std::cerr << "[ERR] ConnectNamedPipe failed (error " << err << ")\n";
            CloseHandle(pipe);
            system("pause");
            return 1;
        }
    }

    std::cout << "[" << Timestamp() << "] hook.dll connected — streaming logs:\n";
    std::cout << "------------------------------------------------\n";

    // Also mirror output to a log file
    FILE* logFile = fopen("dlltracer_session.log", "w");
    if (logFile) fprintf(logFile, "DLL Tracer session started at %s\n\n", Timestamp().c_str());

    char buf[4096];
    DWORD bytesRead;
    std::string partial; // handle partial line reads across buffer boundaries

    while (ReadFile(pipe, buf, sizeof(buf) - 1, &bytesRead, nullptr)) {
        buf[bytesRead] = '\0';
        partial += buf;

        // Print and log complete lines
        size_t pos;
        while ((pos = partial.find('\n')) != std::string::npos) {
            std::string line = partial.substr(0, pos);
            partial = partial.substr(pos + 1);

            std::string out = "[" + Timestamp() + "] " + line;
            std::cout << out << "\n";
            if (logFile) fprintf(logFile, "%s\n", out.c_str());
        }
    }

    std::cout << "\n[" << Timestamp() << "] Pipe closed — hook.dll disconnected or process exited.\n";
    if (logFile) { fprintf(logFile, "\nSession ended.\n"); fclose(logFile); }
    CloseHandle(pipe);

    std::cout << "\nLog saved to dlltracer_session.log\n";
    system("pause");
    return 0;
}
