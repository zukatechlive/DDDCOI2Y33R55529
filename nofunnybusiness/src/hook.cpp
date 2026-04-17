// hook.cpp
// Injected into the target process. Enumerates all exports of a specified DLL,
// installs generic naked trampolines on each one, and streams CallRecords to
// tracer.exe over a named pipe. Also listens for enable/disable commands.

#include <Windows.h>
#include <MinHook.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <thread>
#include <vector>
#include <atomic>
#include <mutex>
#include "shared.h"

// ---------------------------------------------------------------------------
// Globals
// ---------------------------------------------------------------------------
static HANDLE          g_pipe_out   = INVALID_HANDLE_VALUE; // hook -> tracer
static HANDLE          g_pipe_cmd   = INVALID_HANDLE_VALUE; // tracer -> hook
static LARGE_INTEGER   g_freq       = {};
static LARGE_INTEGER   g_start      = {};
static std::mutex      g_pipe_mutex;

struct HookEntry {
    char     name[128];
    uint32_t index;
    void*    original;   // trampoline ptr from MinHook
    void*    target;     // address in target DLL
    std::atomic<bool> enabled{ true };
};

static std::vector<HookEntry> g_hooks;

// ---------------------------------------------------------------------------
// Timing
// ---------------------------------------------------------------------------
static uint64_t NowUs() {
    LARGE_INTEGER now;
    QueryPerformanceCounter(&now);
    return (uint64_t)(((now.QuadPart - g_start.QuadPart) * 1000000ULL) / g_freq.QuadPart);
}

// ---------------------------------------------------------------------------
// Pipe write helper
// ---------------------------------------------------------------------------
static void PipeWrite(const void* data, DWORD size) {
    std::lock_guard<std::mutex> lk(g_pipe_mutex);
    if (g_pipe_out == INVALID_HANDLE_VALUE) return;
    DWORD written;
    WriteFile(g_pipe_out, data, size, &written, nullptr);
}

// ---------------------------------------------------------------------------
// Generic hook dispatcher
// Called from each naked trampoline stub with the hook index + saved regs.
// Returns the original function pointer so the stub can tail-call through.
// ---------------------------------------------------------------------------
void* __cdecl HookDispatch(uint32_t idx,
                            uint64_t rcx, uint64_t rdx,
                            uint64_t r8,  uint64_t r9,
                            uint64_t ret_addr)
{
    if (idx >= g_hooks.size()) return nullptr;
    HookEntry& e = g_hooks[idx];

    if (e.enabled.load(std::memory_order_relaxed)) {
        CallRecord rec = {};
        rec.timestamp_us = NowUs();
        rec.export_index = idx;
        rec.rcx      = rcx;
        rec.rdx      = rdx;
        rec.r8       = r8;
        rec.r9       = r9;
        rec.ret_addr = ret_addr;
        strncpy_s(rec.name, e.name, _TRUNCATE);
        // rax filled after call — we only log pre-call here for simplicity.
        // A full pre/post split would need per-thread stacks; overkill for tracing.
        PipeWrite(&rec, sizeof(rec));
    }

    return e.original; // trampoline calls this via rax
}

// ---------------------------------------------------------------------------
// Per-export naked stub (x64 MASM-style via __asm not available in x64 MSVC).
// We allocate executable memory and write the stub bytes manually.
//
// Stub layout (each stub is 64 bytes, index embedded as imm32):
//
//   push    rax / push rcx / push rdx / push r8 / push r9 / push r10 / push r11
//   mov     ecx, <index>          ; arg1 = index
//   mov     rdx, [rsp+8*2]        ; arg2 = original rcx (saved above rax)
//   mov     r8,  [rsp+8*3]        ; arg3 = original rdx
//   mov     r9,  [rsp+8*4]        ; arg4 = original r8
//   sub     rsp, 40               ; shadow space + align
//   call    HookDispatch
//   add     rsp, 40
//   ; rax now = original function pointer
//   pop r11/r10/r9/r8/rdx/rcx
//   ; restore rax? — we don't; HookDispatch returns the fn ptr in rax
//   add rsp, 8                    ; discard saved rax slot
//   jmp rax                       ; tail-call original
// ---------------------------------------------------------------------------

// We store one VirtualAlloc slab and carve 64-byte slots from it
static uint8_t* g_stub_mem  = nullptr;
static size_t   g_stub_count = 0;

static void* MakeStub(uint32_t idx) {
    // Each stub is 80 bytes — generous for alignment
    uint8_t* s = g_stub_mem + idx * 80;

    // save volatile regs we'll clobber
    // push rax
    s[0]=0x50;
    // push rcx
    s[1]=0x51;
    // push rdx
    s[2]=0x52;
    // push r8   (41 50)
    s[3]=0x41; s[4]=0x50;
    // push r9   (41 51)
    s[5]=0x41; s[6]=0x51;
    // push r10  (41 52)
    s[7]=0x41; s[8]=0x52;
    // push r11  (41 53)
    s[9]=0x41; s[10]=0x53;

    // mov ecx, idx  (B9 xx xx xx xx)
    s[11]=0xB9;
    memcpy(s+12, &idx, 4);

    // At this point stack (relative to current rsp) looks like:
    //   [rsp+0]  = r11
    //   [rsp+8]  = r10
    //   [rsp+16] = r9
    //   [rsp+24] = r8
    //   [rsp+32] = rdx
    //   [rsp+40] = rcx   <- original rcx = arg1 to hooked fn
    //   [rsp+48] = rax
    //   [rsp+56] = return address of caller

    // mov rdx, [rsp+40]   (48 8B 54 24 28)
    s[16]=0x48; s[17]=0x8B; s[18]=0x54; s[19]=0x24; s[20]=0x28;
    // mov r8,  [rsp+32]   (4C 8B 44 24 20)
    s[21]=0x4C; s[22]=0x8B; s[23]=0x44; s[24]=0x24; s[25]=0x20;
    // mov r9,  [rsp+24]   (4C 8B 4C 24 18)
    s[26]=0x4C; s[27]=0x8B; s[28]=0x4C; s[29]=0x24; s[30]=0x18;

    // sub rsp, 40   (48 83 EC 28)
    s[31]=0x48; s[32]=0x83; s[33]=0xEC; s[34]=0x28;

    // mov rax, &HookDispatch  (48 B8 <8 bytes>)
    s[35]=0x48; s[36]=0xB8;
    uint64_t disp = (uint64_t)(void*)HookDispatch;
    memcpy(s+37, &disp, 8);
    // call rax  (FF D0)
    s[45]=0xFF; s[46]=0xD0;

    // add rsp, 40  (48 83 C4 28)
    s[47]=0x48; s[48]=0x83; s[49]=0xC4; s[50]=0x28;

    // rax = original fn ptr — save it temporarily in r10 slot
    // We need to restore rcx..r9, then jmp rax
    // pop r11  (41 5B)
    s[51]=0x41; s[52]=0x5B;
    // pop r10  (41 5A) — we'll overwrite this with our fn ptr
    s[53]=0x41; s[54]=0x5A;
    // We need rax alive through pops. Store fn ptr in r10.
    // xchg rax, r10  (49 92)  -> r10=fn, rax=old_r10 (don't care)
    s[55]=0x49; s[56]=0x92;
    // pop r9   (41 59)
    s[57]=0x41; s[58]=0x59;
    // pop r8   (41 58)
    s[59]=0x41; s[60]=0x58;
    // pop rdx  (5A)
    s[61]=0x5A;
    // pop rcx  (59)
    s[62]=0x59;
    // pop rax  (58)
    s[63]=0x58;
    // add rsp, 8  (skip saved rax slot — actually that was popped)
    // ret addr is at rsp now. jmp r10 tail-calls original with stack intact.
    // jmp r10  (41 FF E2)
    s[64]=0x41; s[65]=0xFF; s[66]=0xE2;

    return s;
}

// ---------------------------------------------------------------------------
// Enumerate exports and install hooks
// ---------------------------------------------------------------------------
static void EnumerateAndHook(HMODULE hMod) {
    auto* dos = (IMAGE_DOS_HEADER*)hMod;
    auto* nt  = (IMAGE_NT_HEADERS*)((uint8_t*)hMod + dos->e_lfanew);
    auto& expDir = nt->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT];
    if (!expDir.VirtualAddress) return;

    auto* exp = (IMAGE_EXPORT_DIRECTORY*)((uint8_t*)hMod + expDir.VirtualAddress);
    auto* names    = (DWORD*) ((uint8_t*)hMod + exp->AddressOfNames);
    auto* ordinals = (WORD*)  ((uint8_t*)hMod + exp->AddressOfNameOrdinals);
    auto* funcs    = (DWORD*) ((uint8_t*)hMod + exp->AddressOfFunctions);

    uint32_t count = min(exp->NumberOfNames, (DWORD)TRACER_MAX_EXPORTS);

    // Allocate executable stub memory
    g_stub_mem = (uint8_t*)VirtualAlloc(nullptr, count * 80,
                                         MEM_COMMIT | MEM_RESERVE,
                                         PAGE_EXECUTE_READWRITE);
    if (!g_stub_mem) return;

    // Build and send export table to tracer
    ExportInfo* info = (ExportInfo*)calloc(1, sizeof(ExportInfo));
    info->count = count;

    g_hooks.resize(count);

    for (uint32_t i = 0; i < count; i++) {
        const char* name = (const char*)((uint8_t*)hMod + names[i]);
        DWORD rva = funcs[ordinals[i]];
        void* target = (uint8_t*)hMod + rva;

        strncpy_s(g_hooks[i].name, name, _TRUNCATE);
        g_hooks[i].index  = i;
        g_hooks[i].target = target;

        strncpy_s(info->exports[i].name, name, _TRUNCATE);
        info->exports[i].rva     = rva;
        info->exports[i].ordinal = exp->Base + ordinals[i];

        // Create stub
        void* stub = MakeStub(i);

        // Install hook: target -> stub, original saved in g_hooks[i].original
        if (MH_CreateHook(target, stub, &g_hooks[i].original) == MH_OK) {
            MH_EnableHook(target);
        }
    }

    // Send export table to tracer (prefixed with a type byte 0x01)
    uint8_t type = 0x01;
    PipeWrite(&type, 1);
    PipeWrite(info, sizeof(ExportInfo));
    free(info);
}

// ---------------------------------------------------------------------------
// Command listener thread (tracer -> hook)
// ---------------------------------------------------------------------------
static void CmdListener() {
    g_pipe_cmd = CreateNamedPipeA(
        "\\\\.\\pipe\\dlltracer_cmd",
        PIPE_ACCESS_INBOUND,
        PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT,
        1, 512, 512, 0, nullptr);

    ConnectNamedPipe(g_pipe_cmd, nullptr);

    HookCommand cmd;
    DWORD read;
    while (ReadFile(g_pipe_cmd, &cmd, sizeof(cmd), &read, nullptr)) {
        if (read < sizeof(cmd)) continue;
        switch (cmd.cmd) {
            case HookCmd::EnableAll:
                for (auto& h : g_hooks) h.enabled.store(true);
                break;
            case HookCmd::DisableAll:
                for (auto& h : g_hooks) h.enabled.store(false);
                break;
            case HookCmd::EnableOne:
                if (cmd.export_index < g_hooks.size())
                    g_hooks[cmd.export_index].enabled.store(true);
                break;
            case HookCmd::DisableOne:
                if (cmd.export_index < g_hooks.size())
                    g_hooks[cmd.export_index].enabled.store(false);
                break;
        }
    }
}

// ---------------------------------------------------------------------------
// Setup entry point
// ---------------------------------------------------------------------------
static void Setup() {
    QueryPerformanceFrequency(&g_freq);
    QueryPerformanceCounter(&g_start);

    // Connect to tracer's pipe server
    for (int tries = 0; tries < 50; tries++) {
        g_pipe_out = CreateFileA(TRACER_PIPE_NAME,
            GENERIC_WRITE, 0, nullptr, OPEN_EXISTING, 0, nullptr);
        if (g_pipe_out != INVALID_HANDLE_VALUE) break;
        Sleep(100);
    }

    MH_Initialize();

    // Hook whichever DLL was loaded — tracer passes name via shared memory or
    // we default to the first non-system DLL. For now, hook all modules
    // except core system ones and pick the most interesting one.
    // In practice the tracer writes the target DLL name to a named mutex.
    // Simple approach: read target name from a well-known file dropped by tracer.
    char targetName[256] = {};
    FILE* f = fopen("dlltracer_target.txt", "r");
    if (f) { fgets(targetName, sizeof(targetName), f); fclose(f); }
    // Strip newline
    for (char* p = targetName; *p; p++) if (*p=='\n'||*p=='\r') { *p=0; break; }

    HMODULE hTarget = nullptr;
    for (int tries = 0; tries < 50 && !hTarget; tries++) {
        hTarget = GetModuleHandleA(*targetName ? targetName : nullptr);
        if (!hTarget) Sleep(100);
    }

    if (hTarget) EnumerateAndHook(hTarget);

    // Start command listener
    std::thread(CmdListener).detach();
}

BOOL APIENTRY DllMain(HMODULE hMod, DWORD reason, LPVOID) {
    if (reason == DLL_PROCESS_ATTACH) {
        DisableThreadLibraryCalls(hMod);
        std::thread(Setup).detach();
    }
    if (reason == DLL_PROCESS_DETACH) {
        MH_DisableHook(MH_ALL_HOOKS);
        MH_Uninitialize();
        if (g_pipe_out != INVALID_HANDLE_VALUE) CloseHandle(g_pipe_out);
        if (g_pipe_cmd != INVALID_HANDLE_VALUE) CloseHandle(g_pipe_cmd);
        if (g_stub_mem) VirtualFree(g_stub_mem, 0, MEM_RELEASE);
    }
    return TRUE;
}
