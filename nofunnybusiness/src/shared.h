#pragma once
#include <Windows.h>
#include <cstdint>

#define TRACER_PIPE_NAME  "\\\\.\\pipe\\dlltracer_gui"
#define TRACER_MAX_EXPORTS 2048

// Sent over the pipe from hook.dll -> tracer.exe for every intercepted call
#pragma pack(push, 1)
struct CallRecord {
    uint64_t timestamp_us;   // microseconds since hook loaded
    uint32_t export_index;   // index into the export table
    uint64_t rcx, rdx, r8, r9; // first 4 integer args (x64 fastcall)
    uint64_t ret_addr;       // return address (caller location)
    uint64_t rax;            // return value (filled on exit hook)
    char     name[128];      // export name
};
#pragma pack(pop)

// Sent once from hook.dll -> tracer.exe right after injection
// Contains the full export table of the target DLL
#pragma pack(push, 1)
struct ExportInfo {
    uint32_t count;
    struct Entry {
        char     name[128];
        uint64_t rva;        // relative virtual address
        uint32_t ordinal;
    } exports[TRACER_MAX_EXPORTS];
};
#pragma pack(pop)

// Commands sent from tracer.exe -> hook.dll over a second pipe
enum class HookCmd : uint32_t {
    EnableAll  = 1,
    DisableAll = 2,
    EnableOne  = 3,
    DisableOne = 4,
};

#pragma pack(push, 1)
struct HookCommand {
    HookCmd  cmd;
    uint32_t export_index; // used for EnableOne / DisableOne
};
#pragma pack(pop)
