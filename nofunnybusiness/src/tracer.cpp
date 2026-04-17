// tracer.cpp
// DLL Tracer GUI — Dear ImGui + DirectX11
// Panels: Process picker | Export table + hook toggles | Live call log

#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include <Windows.h>
#include <TlHelp32.h>
#include <Psapi.h>
#include <d3d11.h>
#include <dxgi.h>
#include <imgui.h>
#include <imgui_impl_win32.h>
#include <imgui_impl_dx11.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
#include <deque>
#include <thread>
#include <mutex>
#include <atomic>
#include "shared.h"

#pragma comment(lib, "d3d11.lib")
#pragma comment(lib, "dxgi.lib")
#pragma comment(lib, "psapi.lib")

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------
struct ProcessEntry {
    DWORD       pid;
    std::string name;
};

struct ExportEntry {
    std::string name;
    uint64_t    rva;
    uint32_t    ordinal;
    bool        hooked = true;
    uint64_t    call_count = 0;
};

struct LogEntry {
    uint64_t    timestamp_us;
    std::string func_name;
    uint64_t    rcx, rdx, r8, r9, rax, ret_addr;
};

static std::vector<ProcessEntry> g_processes;
static std::vector<ExportEntry>  g_exports;
static std::deque<LogEntry>      g_log;
static std::mutex                g_log_mutex;
static std::mutex                g_export_mutex;

static DWORD  g_target_pid    = 0;
static char   g_target_dll[256] = "";
static char   g_dll_filter[128] = "";
static char   g_log_filter[128] = "";
static bool   g_injected       = false;
static bool   g_connected      = false;
static bool   g_auto_scroll    = true;
static int    g_max_log        = 5000;

static HANDLE g_pipe_in  = INVALID_HANDLE_VALUE; // hook -> tracer
static HANDLE g_pipe_cmd = INVALID_HANDLE_VALUE; // tracer -> hook

// DX11
static ID3D11Device*           g_pd3dDevice           = nullptr;
static ID3D11DeviceContext*     g_pd3dDeviceContext    = nullptr;
static IDXGISwapChain*          g_pSwapChain           = nullptr;
static ID3D11RenderTargetView*  g_pRenderTargetView    = nullptr;
static HWND                     g_hwnd                 = nullptr;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
static std::string HexStr(uint64_t v) {
    char buf[32]; snprintf(buf, sizeof(buf), "0x%llX", (unsigned long long)v);
    return buf;
}

static void RefreshProcessList() {
    g_processes.clear();
    HANDLE snap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    PROCESSENTRY32 pe{ sizeof(pe) };
    if (Process32First(snap, &pe)) {
        do {
            g_processes.push_back({ pe.th32ProcessID, pe.szExeFile });
        } while (Process32Next(snap, &pe));
    }
    CloseHandle(snap);
}

// Get loaded DLL names for a given PID
static std::vector<std::string> GetDLLsForPID(DWORD pid) {
    std::vector<std::string> dlls;
    HANDLE hProc = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, pid);
    if (!hProc) return dlls;
    HMODULE mods[512]; DWORD needed;
    if (EnumProcessModules(hProc, mods, sizeof(mods), &needed)) {
        DWORD count = needed / sizeof(HMODULE);
        for (DWORD i = 0; i < count; i++) {
            char name[MAX_PATH];
            if (GetModuleBaseNameA(hProc, mods[i], name, MAX_PATH))
                dlls.push_back(name);
        }
    }
    CloseHandle(hProc);
    return dlls;
}

// Write target DLL name to file so hook.dll can read it at inject time
static void WriteTargetFile(const char* dllName) {
    FILE* f = fopen("dlltracer_target.txt", "w");
    if (f) { fprintf(f, "%s", dllName); fclose(f); }
}

// Inject hook.dll into target process
static bool Inject(DWORD pid, const char* hookDllPath) {
    HANDLE hProc = OpenProcess(PROCESS_ALL_ACCESS, FALSE, pid);
    if (!hProc) return false;
    char full[MAX_PATH];
    GetFullPathNameA(hookDllPath, MAX_PATH, full, nullptr);
    SIZE_T len = strlen(full) + 1;
    LPVOID remote = VirtualAllocEx(hProc, nullptr, len, MEM_COMMIT, PAGE_READWRITE);
    if (!remote) { CloseHandle(hProc); return false; }
    WriteProcessMemory(hProc, remote, full, len, nullptr);
    HANDLE ht = CreateRemoteThread(hProc, nullptr, 0,
        (LPTHREAD_START_ROUTINE)GetProcAddress(GetModuleHandleA("kernel32.dll"), "LoadLibraryA"),
        remote, 0, nullptr);
    if (!ht) { VirtualFreeEx(hProc, remote, 0, MEM_RELEASE); CloseHandle(hProc); return false; }
    WaitForSingleObject(ht, 5000);
    CloseHandle(ht);
    VirtualFreeEx(hProc, remote, 0, MEM_RELEASE);
    CloseHandle(hProc);
    return true;
}

// ---------------------------------------------------------------------------
// Pipe I/O threads
// ---------------------------------------------------------------------------
static void PipeReadThread() {
    // Create the server end — hook.dll connects to this
    g_pipe_in = CreateNamedPipeA(
        TRACER_PIPE_NAME,
        PIPE_ACCESS_INBOUND,
        PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT,
        1, 1 << 16, 1 << 16, 0, nullptr);

    ConnectNamedPipe(g_pipe_in, nullptr);
    g_connected = true;

    uint8_t type;
    DWORD   read;

    while (ReadFile(g_pipe_in, &type, 1, &read, nullptr) && read == 1) {
        if (type == 0x01) {
            // Export table
            ExportInfo info;
            DWORD total = 0;
            uint8_t* dst = (uint8_t*)&info;
            while (total < sizeof(info)) {
                if (!ReadFile(g_pipe_in, dst + total, sizeof(info) - total, &read, nullptr)) break;
                total += read;
            }
            std::lock_guard<std::mutex> lk(g_export_mutex);
            g_exports.clear();
            for (uint32_t i = 0; i < info.count && i < TRACER_MAX_EXPORTS; i++) {
                ExportEntry e;
                e.name    = info.exports[i].name;
                e.rva     = info.exports[i].rva;
                e.ordinal = info.exports[i].ordinal;
                e.hooked  = true;
                g_exports.push_back(e);
            }
        } else if (type == 0x02) {
            // CallRecord (hook.dll prefixes each with 0x02)
            CallRecord rec;
            DWORD total = 0;
            uint8_t* dst = (uint8_t*)&rec;
            while (total < sizeof(rec)) {
                if (!ReadFile(g_pipe_in, dst + total, sizeof(rec) - total, &read, nullptr)) break;
                total += read;
            }
            LogEntry le;
            le.timestamp_us = rec.timestamp_us;
            le.func_name    = rec.name;
            le.rcx = rec.rcx; le.rdx = rec.rdx;
            le.r8  = rec.r8;  le.r9  = rec.r9;
            le.rax = rec.rax; le.ret_addr = rec.ret_addr;

            std::lock_guard<std::mutex> lk(g_log_mutex);
            g_log.push_back(le);
            if ((int)g_log.size() > g_max_log) g_log.pop_front();

            // update call count
            {
                std::lock_guard<std::mutex> lk2(g_export_mutex);
                if (rec.export_index < g_exports.size())
                    g_exports[rec.export_index].call_count++;
            }
        }
    }
    g_connected = false;
}

static void SendCmd(HookCmd cmd, uint32_t idx = 0) {
    if (g_pipe_cmd == INVALID_HANDLE_VALUE) {
        g_pipe_cmd = CreateFileA("\\\\.\\pipe\\dlltracer_cmd",
            GENERIC_WRITE, 0, nullptr, OPEN_EXISTING, 0, nullptr);
    }
    if (g_pipe_cmd == INVALID_HANDLE_VALUE) return;
    HookCommand hc{ cmd, idx };
    DWORD w;
    WriteFile(g_pipe_cmd, &hc, sizeof(hc), &w, nullptr);
}

// ---------------------------------------------------------------------------
// GUI
// ---------------------------------------------------------------------------
static void DrawGUI() {
    ImGuiIO& io = ImGui::GetIO();
    ImGui::SetNextWindowPos({0,0});
    ImGui::SetNextWindowSize(io.DisplaySize);
    ImGui::Begin("DLL Tracer", nullptr,
        ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize |
        ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoBringToFrontOnFocus |
        ImGuiWindowFlags_MenuBar);

    // ---- Menu bar ----
    if (ImGui::BeginMenuBar()) {
        if (ImGui::BeginMenu("File")) {
            if (ImGui::MenuItem("Clear log")) {
                std::lock_guard<std::mutex> lk(g_log_mutex);
                g_log.clear();
            }
            if (ImGui::MenuItem("Save log...")) {
                std::lock_guard<std::mutex> lk(g_log_mutex);
                FILE* f = fopen("dlltracer_log.txt", "w");
                if (f) {
                    for (auto& e : g_log)
                        fprintf(f, "[%llu us] %s  rcx=%llX rdx=%llX r8=%llX r9=%llX rax=%llX ret=%llX\n",
                            e.timestamp_us, e.func_name.c_str(),
                            e.rcx, e.rdx, e.r8, e.r9, e.rax, e.ret_addr);
                    fclose(f);
                }
            }
            ImGui::EndMenu();
        }
        if (ImGui::BeginMenu("Hooks")) {
            if (ImGui::MenuItem("Enable all"))  SendCmd(HookCmd::EnableAll);
            if (ImGui::MenuItem("Disable all")) SendCmd(HookCmd::DisableAll);
            ImGui::EndMenu();
        }
        ImGui::EndMenuBar();
    }

    // ---- Layout: three columns ----
    float col1 = 240.f, col3 = io.DisplaySize.x * 0.45f;
    float col2 = io.DisplaySize.x - col1 - col3 - 16.f;

    // ===== Column 1: Process + DLL picker =====
    ImGui::BeginChild("##proc", {col1, 0}, true);
    ImGui::TextDisabled("Process");
    ImGui::Separator();

    if (ImGui::Button("Refresh", {-1, 0})) RefreshProcessList();
    ImGui::Spacing();

    static int sel_proc = -1;
    for (int i = 0; i < (int)g_processes.size(); i++) {
        char label[128];
        snprintf(label, sizeof(label), "[%5lu] %s",
            g_processes[i].pid, g_processes[i].name.c_str());
        if (ImGui::Selectable(label, sel_proc == i)) {
            sel_proc = i;
            g_target_pid = g_processes[i].pid;
        }
    }

    ImGui::Spacing(); ImGui::Separator(); ImGui::Spacing();
    ImGui::TextDisabled("DLLs in process");

    static std::vector<std::string> s_dlls;
    static int sel_dll = -1;
    if (g_target_pid && ImGui::Button("Load DLL list", {-1,0}))
        s_dlls = GetDLLsForPID(g_target_pid);

    ImGui::InputText("Filter##dll", g_dll_filter, sizeof(g_dll_filter));
    for (int i = 0; i < (int)s_dlls.size(); i++) {
        if (g_dll_filter[0] && s_dlls[i].find(g_dll_filter) == std::string::npos) continue;
        if (ImGui::Selectable(s_dlls[i].c_str(), sel_dll == i)) {
            sel_dll = i;
            strncpy_s(g_target_dll, s_dlls[i].c_str(), _TRUNCATE);
        }
    }

    ImGui::Spacing(); ImGui::Separator(); ImGui::Spacing();
    ImGui::Text("Target: %s", g_target_dll[0] ? g_target_dll : "(none)");
    ImGui::Spacing();

    bool can_inject = g_target_pid && g_target_dll[0] && !g_injected;
    if (!can_inject) ImGui::BeginDisabled();
    if (ImGui::Button("Inject + Hook", {-1, 0})) {
        WriteTargetFile(g_target_dll);
        // Start pipe server before injecting
        std::thread(PipeReadThread).detach();
        Sleep(200);
        if (Inject(g_target_pid, "hook.dll")) {
            g_injected = true;
        }
    }
    if (!can_inject) ImGui::EndDisabled();

    if (g_injected) {
        ImGui::Spacing();
        ImGui::TextColored(g_connected ? ImVec4(0.2f,1,0.2f,1) : ImVec4(1,0.6f,0,1),
            g_connected ? "Connected" : "Waiting...");
    }
    ImGui::EndChild();

    ImGui::SameLine();

    // ===== Column 2: Export table =====
    ImGui::BeginChild("##exports", {col2, 0}, true);
    ImGui::TextDisabled("Exports");
    ImGui::Separator();

    {
        std::lock_guard<std::mutex> lk(g_export_mutex);
        ImGui::Text("%zu exports", g_exports.size());
        ImGui::SameLine();
        if (ImGui::SmallButton("All on"))  { for (auto& e : g_exports) e.hooked=true;  SendCmd(HookCmd::EnableAll); }
        ImGui::SameLine();
        if (ImGui::SmallButton("All off")) { for (auto& e : g_exports) e.hooked=false; SendCmd(HookCmd::DisableAll); }

        ImGui::Separator();
        ImGui::BeginChild("##explist", {0, 0}, false,
            ImGuiWindowFlags_HorizontalScrollbar);

        ImGui::Columns(3, "expcols", true);
        ImGui::SetColumnWidth(0, 30);
        ImGui::SetColumnWidth(1, col2 - 130);
        ImGui::TextDisabled("On"); ImGui::NextColumn();
        ImGui::TextDisabled("Name"); ImGui::NextColumn();
        ImGui::TextDisabled("Calls"); ImGui::NextColumn();
        ImGui::Separator();

        for (int i = 0; i < (int)g_exports.size(); i++) {
            auto& e = g_exports[i];
            char id[16]; snprintf(id, sizeof(id), "##h%d", i);
            bool h = e.hooked;
            if (ImGui::Checkbox(id, &h)) {
                e.hooked = h;
                SendCmd(h ? HookCmd::EnableOne : HookCmd::DisableOne, i);
            }
            ImGui::NextColumn();
            ImGui::TextUnformatted(e.name.c_str());
            ImGui::NextColumn();
            if (e.call_count > 0)
                ImGui::TextColored({0.4f,1,0.4f,1}, "%llu", e.call_count);
            else
                ImGui::TextDisabled("0");
            ImGui::NextColumn();
        }
        ImGui::Columns(1);
        ImGui::EndChild();
    }
    ImGui::EndChild();

    ImGui::SameLine();

    // ===== Column 3: Live log =====
    ImGui::BeginChild("##log", {col3, 0}, true);
    ImGui::TextDisabled("Call log");
    ImGui::SameLine();
    ImGui::SetNextItemWidth(160);
    ImGui::InputText("Filter##log", g_log_filter, sizeof(g_log_filter));
    ImGui::SameLine();
    ImGui::Checkbox("Auto-scroll", &g_auto_scroll);
    ImGui::SameLine();
    if (ImGui::SmallButton("Clear")) {
        std::lock_guard<std::mutex> lk(g_log_mutex);
        g_log.clear();
    }
    ImGui::Separator();

    ImGui::BeginChild("##logscroll", {0, 0}, false,
        ImGuiWindowFlags_HorizontalScrollbar);

    {
        std::lock_guard<std::mutex> lk(g_log_mutex);
        ImGuiListClipper clipper;
        // pre-filter
        std::vector<const LogEntry*> visible;
        visible.reserve(g_log.size());
        for (auto& e : g_log) {
            if (g_log_filter[0] && e.func_name.find(g_log_filter) == std::string::npos) continue;
            visible.push_back(&e);
        }
        clipper.Begin((int)visible.size());
        while (clipper.Step()) {
            for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                auto& e = *visible[i];
                double ts = e.timestamp_us / 1000.0;
                ImGui::TextColored({0.5f,0.8f,1.f,1.f}, "[%.3f ms]", ts);
                ImGui::SameLine();
                ImGui::TextColored({1.f,0.85f,0.4f,1.f}, "%s", e.func_name.c_str());
                ImGui::SameLine();
                ImGui::TextDisabled("rcx=%llX rdx=%llX r8=%llX r9=%llX",
                    e.rcx, e.rdx, e.r8, e.r9);
                if (e.rax) {
                    ImGui::SameLine();
                    ImGui::TextColored({0.5f,1.f,0.5f,1.f}, "-> %llX", e.rax);
                }
            }
        }
    }

    if (g_auto_scroll && ImGui::GetScrollY() >= ImGui::GetScrollMaxY() - 20.f)
        ImGui::SetScrollHereY(1.0f);

    ImGui::EndChild();
    ImGui::EndChild();

    ImGui::End();
}

// ---------------------------------------------------------------------------
// DX11 boilerplate
// ---------------------------------------------------------------------------
static bool CreateDeviceD3D(HWND hWnd) {
    DXGI_SWAP_CHAIN_DESC sd = {};
    sd.BufferCount = 2;
    sd.BufferDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM;
    sd.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
    sd.OutputWindow = hWnd;
    sd.SampleDesc.Count = 1;
    sd.Windowed = TRUE;
    sd.SwapEffect = DXGI_SWAP_EFFECT_DISCARD;
    D3D_FEATURE_LEVEL fl;
    HRESULT hr = D3D11CreateDeviceAndSwapChain(nullptr, D3D_DRIVER_TYPE_HARDWARE,
        nullptr, 0, nullptr, 0, D3D11_SDK_VERSION, &sd,
        &g_pSwapChain, &g_pd3dDevice, &fl, &g_pd3dDeviceContext);
    if (FAILED(hr)) return false;
    ID3D11Texture2D* bb = nullptr;
    g_pSwapChain->GetBuffer(0, IID_PPV_ARGS(&bb));
    g_pd3dDevice->CreateRenderTargetView(bb, nullptr, &g_pRenderTargetView);
    bb->Release();
    return true;
}

static void CleanupDeviceD3D() {
    if (g_pRenderTargetView) { g_pRenderTargetView->Release(); g_pRenderTargetView=nullptr; }
    if (g_pSwapChain)        { g_pSwapChain->Release();        g_pSwapChain=nullptr; }
    if (g_pd3dDeviceContext) { g_pd3dDeviceContext->Release();  g_pd3dDeviceContext=nullptr; }
    if (g_pd3dDevice)        { g_pd3dDevice->Release();         g_pd3dDevice=nullptr; }
}

extern IMGUI_IMPL_API LRESULT ImGui_ImplWin32_WndProcHandler(HWND,UINT,WPARAM,LPARAM);
static LRESULT WINAPI WndProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam) {
    if (ImGui_ImplWin32_WndProcHandler(hWnd,msg,wParam,lParam)) return true;
    if (msg == WM_SIZE && g_pd3dDevice && wParam != SIZE_MINIMIZED) {
        if (g_pRenderTargetView) { g_pRenderTargetView->Release(); g_pRenderTargetView=nullptr; }
        g_pSwapChain->ResizeBuffers(0,LOWORD(lParam),HIWORD(lParam),DXGI_FORMAT_UNKNOWN,0);
        ID3D11Texture2D* bb=nullptr;
        g_pSwapChain->GetBuffer(0,IID_PPV_ARGS(&bb));
        g_pd3dDevice->CreateRenderTargetView(bb,nullptr,&g_pRenderTargetView);
        bb->Release();
    }
    if (msg == WM_DESTROY) { PostQuitMessage(0); return 0; }
    return DefWindowProcW(hWnd, msg, wParam, lParam);
}

// ---------------------------------------------------------------------------
// WinMain
// ---------------------------------------------------------------------------
int WINAPI WinMain(HINSTANCE hInst, HINSTANCE, LPSTR, int) {
    WNDCLASSEXW wc = { sizeof(wc), CS_CLASSDC, WndProc, 0,0, hInst,
        nullptr,nullptr,nullptr,nullptr, L"DLLTracer", nullptr };
    RegisterClassExW(&wc);
    g_hwnd = CreateWindowW(L"DLLTracer", L"DLL Tracer",
        WS_OVERLAPPEDWINDOW, 100,100, 1400,800, nullptr,nullptr, hInst, nullptr);

    if (!CreateDeviceD3D(g_hwnd)) { CleanupDeviceD3D(); return 1; }

    ShowWindow(g_hwnd, SW_SHOWDEFAULT);
    UpdateWindow(g_hwnd);

    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO();
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;
    ImGui::StyleColorsDark();

    // Tweak style for a clean dark RE-tool look
    ImGuiStyle& st = ImGui::GetStyle();
    st.WindowRounding = 4.f;
    st.FrameRounding  = 3.f;
    st.ScrollbarRounding = 3.f;
    st.Colors[ImGuiCol_WindowBg]      = {0.10f,0.10f,0.12f,1.f};
    st.Colors[ImGuiCol_ChildBg]       = {0.08f,0.08f,0.10f,1.f};
    st.Colors[ImGuiCol_FrameBg]       = {0.16f,0.16f,0.20f,1.f};
    st.Colors[ImGuiCol_Header]        = {0.20f,0.20f,0.28f,1.f};
    st.Colors[ImGuiCol_HeaderHovered] = {0.28f,0.28f,0.38f,1.f};
    st.Colors[ImGuiCol_Button]        = {0.22f,0.22f,0.30f,1.f};
    st.Colors[ImGuiCol_ButtonHovered] = {0.30f,0.30f,0.42f,1.f};
    st.Colors[ImGuiCol_TitleBgActive] = {0.14f,0.14f,0.20f,1.f};
    st.Colors[ImGuiCol_CheckMark]     = {0.40f,1.0f,0.40f,1.f};

    ImGui_ImplWin32_Init(g_hwnd);
    ImGui_ImplDX11_Init(g_pd3dDevice, g_pd3dDeviceContext);

    RefreshProcessList();

    MSG msg = {};
    while (msg.message != WM_QUIT) {
        if (PeekMessage(&msg,nullptr,0,0,PM_REMOVE)) {
            TranslateMessage(&msg); DispatchMessage(&msg); continue;
        }
        ImGui_ImplDX11_NewFrame();
        ImGui_ImplWin32_NewFrame();
        ImGui::NewFrame();

        DrawGUI();

        ImGui::Render();
        const float cc[4] = {0.07f,0.07f,0.09f,1.f};
        g_pd3dDeviceContext->OMSetRenderTargets(1,&g_pRenderTargetView,nullptr);
        g_pd3dDeviceContext->ClearRenderTargetView(g_pRenderTargetView,cc);
        ImGui_ImplDX11_RenderDrawData(ImGui::GetDrawData());
        g_pSwapChain->Present(1,0);
    }

    ImGui_ImplDX11_Shutdown();
    ImGui_ImplWin32_Shutdown();
    ImGui::DestroyContext();
    CleanupDeviceD3D();
    DestroyWindow(g_hwnd);
    UnregisterClassW(wc.lpszClassName, hInst);
    return 0;
}
