// synapse_dll_bridge.cpp
// Compile with: cl /LD synapse_dll_bridge.cpp /Fe:SynapseXBridge.dll

#include <windows.h>
#include <iostream>
#include <thread>
#include <string>
#include <sstream>

// JSON parsing - in production use a library like nlohmann/json
// This is a simplified example
struct Command {
    std::string type;
    std::string data;
};

class NamedPipeServer {
private:
    HANDLE hPipe;
    std::thread serverThread;
    bool running;
    
    const char* PIPE_NAME = "\\\\.\\pipe\\SynapseXPipe";
    const int BUFFER_SIZE = 4096;

public:
    NamedPipeServer() : hPipe(INVALID_HANDLE_VALUE), running(false) {}
    
    ~NamedPipeServer() {
        Stop();
    }
    
    bool Start() {
        // Create the named pipe
        hPipe = CreateNamedPipeA(
            PIPE_NAME,
            PIPE_ACCESS_DUPLEX,       // Read/write access
            PIPE_TYPE_MESSAGE |       // Message-type pipe
            PIPE_READMODE_MESSAGE |   // Message-read mode
            PIPE_WAIT,                // Blocking mode
            PIPE_UNLIMITED_INSTANCES,
            BUFFER_SIZE,
            BUFFER_SIZE,
            0,
            NULL
        );
        
        if (hPipe == INVALID_HANDLE_VALUE) {
            std::cerr << "[DLL] Failed to create pipe. Error: " << GetLastError() << std::endl;
            return false;
        }
        
        std::cout << "[DLL] Named pipe server created successfully" << std::endl;
        
        running = true;
        serverThread = std::thread(&NamedPipeServer::ServerLoop, this);
        
        return true;
    }
    
    void Stop() {
        running = false;
        
        if (hPipe != INVALID_HANDLE_VALUE) {
            DisconnectNamedPipe(hPipe);
            CloseHandle(hPipe);
            hPipe = INVALID_HANDLE_VALUE;
        }
        
        if (serverThread.joinable()) {
            serverThread.join();
        }
    }
    
private:
    void ServerLoop() {
        std::cout << "[DLL] Waiting for client connection..." << std::endl;
        
        // Wait for the client to connect
        BOOL connected = ConnectNamedPipe(hPipe, NULL) ? 
                        TRUE : (GetLastError() == ERROR_PIPE_CONNECTED);
        
        if (!connected) {
            std::cerr << "[DLL] Failed to connect to client" << std::endl;
            return;
        }
        
        std::cout << "[DLL] Client connected!" << std::endl;
        
        // Main message loop
        while (running) {
            char buffer[BUFFER_SIZE];
            DWORD bytesRead;
            
            // Read message from client
            BOOL success = ReadFile(
                hPipe,
                buffer,
                BUFFER_SIZE,
                &bytesRead,
                NULL
            );
            
            if (!success || bytesRead == 0) {
                if (GetLastError() == ERROR_BROKEN_PIPE) {
                    std::cout << "[DLL] Client disconnected" << std::endl;
                } else {
                    std::cerr << "[DLL] ReadFile failed. Error: " << GetLastError() << std::endl;
                }
                break;
            }
            
            // Null-terminate the message
            buffer[bytesRead] = '\0';
            std::string message(buffer);
            
            // Process the command
            ProcessCommand(message);
        }
        
        DisconnectNamedPipe(hPipe);
    }
    
    void ProcessCommand(const std::string& jsonMessage) {
        std::cout << "[DLL] Received: " << jsonMessage << std::endl;
        
        // Parse command (simplified - use proper JSON parser in production)
        Command cmd = ParseCommand(jsonMessage);
        
        std::string response;
        
        if (cmd.type == "execute") {
            // Execute Lua script
            response = ExecuteScript(cmd.data);
        }
        else if (cmd.type == "attach") {
            // Attach to Roblox process
            response = AttachToRoblox();
        }
        else if (cmd.type == "detach") {
            // Detach from Roblox
            response = DetachFromRoblox();
        }
        else {
            response = CreateResponse("error", "Unknown command type");
        }
        
        // Send response back to client
        SendResponse(response);
    }
    
    Command ParseCommand(const std::string& json) {
        Command cmd;
        
        // Simple parsing (replace with proper JSON parser)
        size_t typePos = json.find("\"type\":");
        if (typePos != std::string::npos) {
            size_t startQuote = json.find("\"", typePos + 7);
            size_t endQuote = json.find("\"", startQuote + 1);
            cmd.type = json.substr(startQuote + 1, endQuote - startQuote - 1);
        }
        
        size_t dataPos = json.find("\"data\":");
        if (dataPos != std::string::npos) {
            size_t startQuote = json.find("\"", dataPos + 7);
            size_t endQuote = json.find("\"", startQuote + 1);
            if (startQuote != std::string::npos && endQuote != std::string::npos) {
                cmd.data = json.substr(startQuote + 1, endQuote - startQuote - 1);
            }
        }
        
        return cmd;
    }
    
    std::string ExecuteScript(const std::string& script) {
        std::cout << "[DLL] Executing Lua script..." << std::endl;
        std::cout << "Script content: " << script << std::endl;
        
        // TODO: Actual Lua execution logic here
        // This would involve:
        // 1. Getting Roblox Lua state
        // 2. Compiling the script
        // 3. Executing in the game context
        
        // For now, simulate success
        return CreateResponse("execute", "Script executed successfully", true);
    }
    
    std::string AttachToRoblox() {
        std::cout << "[DLL] Attaching to Roblox process..." << std::endl;
        
        // TODO: Actual attachment logic
        // This would involve:
        // 1. Finding Roblox process
        // 2. Injecting DLL if needed
        // 3. Setting up hooks
        
        // Simulate attachment
        return CreateResponse("attach", "Attached to Roblox successfully", true);
    }
    
    std::string DetachFromRoblox() {
        std::cout << "[DLL] Detaching from Roblox..." << std::endl;
        
        // TODO: Cleanup logic
        
        return CreateResponse("detach", "Detached successfully", true);
    }
    
    std::string CreateResponse(const std::string& type, const std::string& message, bool success = true) {
        std::stringstream ss;
        ss << "{"
           << "\"type\":\"" << type << "\","
           << "\"success\":" << (success ? "true" : "false") << ","
           << "\"message\":\"" << message << "\""
           << "}";
        return ss.str();
    }
    
    void SendResponse(const std::string& response) {
        DWORD bytesWritten;
        
        std::string responseWithNewline = response + "\n";
        
        BOOL success = WriteFile(
            hPipe,
            responseWithNewline.c_str(),
            responseWithNewline.length(),
            &bytesWritten,
            NULL
        );
        
        if (!success) {
            std::cerr << "[DLL] Failed to send response. Error: " << GetLastError() << std::endl;
        } else {
            std::cout << "[DLL] Sent response: " << response << std::endl;
        }
    }
};

// Global server instance
NamedPipeServer* g_pipeServer = nullptr;

// DLL Entry Point
BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved) {
    switch (ul_reason_for_call) {
        case DLL_PROCESS_ATTACH:
            // Allocate console for debugging
            AllocConsole();
            FILE* fDummy;
            freopen_s(&fDummy, "CONOUT$", "w", stdout);
            freopen_s(&fDummy, "CONOUT$", "w", stderr);
            
            std::cout << "[DLL] Synapse X Bridge DLL loaded" << std::endl;
            
            // Start the pipe server
            g_pipeServer = new NamedPipeServer();
            if (!g_pipeServer->Start()) {
                std::cerr << "[DLL] Failed to start pipe server" << std::endl;
                delete g_pipeServer;
                g_pipeServer = nullptr;
            }
            break;
            
        case DLL_PROCESS_DETACH:
            if (g_pipeServer) {
                g_pipeServer->Stop();
                delete g_pipeServer;
                g_pipeServer = nullptr;
            }
            std::cout << "[DLL] Synapse X Bridge DLL unloaded" << std::endl;
            FreeConsole();
            break;
    }
    return TRUE;
}

// Exported functions (if needed)
extern "C" {
    __declspec(dllexport) void StartPipeServer() {
        if (g_pipeServer && !g_pipeServer->Start()) {
            std::cerr << "[DLL] Failed to start pipe server" << std::endl;
        }
    }
    
    __declspec(dllexport) void StopPipeServer() {
        if (g_pipeServer) {
            g_pipeServer->Stop();
        }
    }
}
