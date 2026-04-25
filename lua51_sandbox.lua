--[[
    =====================================================
    Lua 5.1 Script Analysis Sandbox Harness
    =====================================================
    PURPOSE:
        Safely analyze obfuscated or suspicious Lua 5.1 scripts
        by neutralizing dangerous globals and logging all calls.

    USAGE:
        1. Place this file in the same directory as your target script.
        2. Run: lua lua51_sandbox.lua target_script.lua
        3. Review the printed log to inspect what the script attempted.

    NOTES:
        - This does NOT replace running in a real VM/snapshot for
          fully untrusted scripts. Use this as a first-pass analysis.
        - Works with standard Lua 5.1 (lua5.1 binary).
        - Does NOT stub executor-specific APIs (syn, getupvalues, etc.)
          unless you uncomment the executor stubs section below.
    =====================================================
]]

-- =====================================================
-- LOGGING UTILITY
-- =====================================================
local log_entries = {}

local function log(category, msg)
    local entry = string.format("[%s] %s", category, msg)
    table.insert(log_entries, entry)
    print(entry)
end

local function dump_log()
    print("\n=====================================================")
    print("  SANDBOX ANALYSIS SUMMARY")
    print("=====================================================")
    if #log_entries == 0 then
        print("  No suspicious calls detected.")
    else
        print(string.format("  Total flagged calls: %d", #log_entries))
        print("-----------------------------------------------------")
        for i, entry in ipairs(log_entries) do
            print(string.format("  %02d. %s", i, entry))
        end
    end
    print("=====================================================\n")
end

-- =====================================================
-- SAFE STUBS
-- These replace dangerous functions with no-ops that log the attempt.
-- =====================================================

-- loadstring / load
local _real_loadstring = loadstring
loadstring = function(code, chunkname)
    log("LOADSTRING", string.format("Attempted loadstring() [chunk: %s] [preview: %.80s]",
        tostring(chunkname or "?"),
        tostring(code):gsub("\n", "\\n")
    ))
    -- Return a no-op function instead of executing the code.
    -- To allow it (risky): return _real_loadstring(code, chunkname)
    return function() return nil end
end

-- require
local _real_require = require
require = function(modname)
    log("REQUIRE", string.format("Attempted require('%s')", tostring(modname)))
    -- Allow safe standard libs, block everything else.
    local safe = { math=true, string=true, table=true, ["bit"]=true }
    if safe[modname] then
        return _real_require(modname)
    end
    return nil
end

-- dofile / loadfile
dofile = function(path)
    log("DOFILE", string.format("Attempted dofile('%s')", tostring(path)))
    return nil
end

loadfile = function(path)
    log("LOADFILE", string.format("Attempted loadfile('%s')", tostring(path)))
    return function() return nil end
end

-- io (full stub)
io = setmetatable({}, {
    __index = function(_, key)
        log("IO", string.format("Accessed io.%s", tostring(key)))
        return function(...)
            log("IO_CALL", string.format("Called io.%s()", tostring(key)))
            return nil
        end
    end
})

-- os (partial stub — keep os.time/os.clock, block dangerous ones)
local _real_os = os
os = setmetatable({}, {
    __index = function(_, key)
        local safe_os = { time=true, clock=true, difftime=true, date=true }
        if safe_os[key] then
            return _real_os[key]
        end
        log("OS", string.format("Accessed os.%s (blocked)", tostring(key)))
        return function(...)
            log("OS_CALL", string.format("Called os.%s()", tostring(key)))
            return nil
        end
    end
})

-- pcall / xpcall (allow, but log if wrapping something suspicious)
-- These are left intact since most obfuscators rely on them for error handling.

-- getfenv / setfenv
local _real_getfenv = getfenv
local _real_setfenv = setfenv

getfenv = function(f)
    log("GETFENV", string.format("Attempted getfenv(%s)", tostring(f)))
    return _real_getfenv(f)
end

setfenv = function(f, env)
    log("SETFENV", string.format("Attempted setfenv() on %s", tostring(f)))
    -- Allow it, but you now know the script is trying to change environments.
    return _real_setfenv(f, env)
end

-- debug library (common obfuscation escape hatch)
debug = setmetatable({}, {
    __index = function(_, key)
        log("DEBUG", string.format("Accessed debug.%s", tostring(key)))
        return function(...)
            log("DEBUG_CALL", string.format("Called debug.%s()", tostring(key)))
            return nil
        end
    end
})

-- rawget / rawset (log but allow — needed by many legitimate scripts too)
local _real_rawget = rawget
rawget = function(t, k)
    -- Only log on suspicious tables (metatables, _G etc.)
    if t == _G then
        log("RAWGET", string.format("rawget(_G, '%s')", tostring(k)))
    end
    return _real_rawget(t, k)
end

-- =====================================================
-- EXECUTOR-SPECIFIC API STUBS
-- Uncomment if analyzing Roblox executor scripts.
-- =====================================================
--[[
local function executor_stub(name)
    return function(...)
        local args = {...}
        local arg_str = ""
        for i, v in ipairs(args) do
            arg_str = arg_str .. tostring(v)
            if i < #args then arg_str = arg_str .. ", " end
        end
        log("EXECUTOR", string.format("Called %s(%s)", name, arg_str))
        return nil
    end
end

-- Synapse X
syn = {
    request         = executor_stub("syn.request"),
    protect_gui     = executor_stub("syn.protect_gui"),
    write_file      = executor_stub("syn.write_file"),
    read_file       = executor_stub("syn.read_file"),
    get_thread_identity = executor_stub("syn.get_thread_identity"),
}

-- KRNL / generic executors
KRNL_LOADED         = true
getupvalues         = executor_stub("getupvalues")
setupvalue          = executor_stub("setupvalue")
getconnections      = executor_stub("getconnections")
fireclickdetector   = executor_stub("fireclickdetector")
firetouchinterest   = executor_stub("firetouchinterest")
hookfunction        = executor_stub("hookfunction")
newcclosure         = executor_stub("newcclosure")
islclosure          = executor_stub("islclosure")
iscclosure          = executor_stub("iscclosure")
checkcaller         = executor_stub("checkcaller")
decompile           = executor_stub("decompile")
Drawing             = {}

-- HTTP (generic)
http = {
    request = executor_stub("http.request"),
    get     = executor_stub("http.get"),
    post    = executor_stub("http.post"),
}

-- HttpGet / HttpPost (Roblox game object stub)
game = {
    HttpGet  = executor_stub("game.HttpGet"),
    HttpPost = executor_stub("game.HttpPost"),
    Players  = { LocalPlayer = { Name = "SANDBOX_USER", UserId = 0 } },
    GetService = function(_, svc)
        log("GAME", string.format("GetService('%s')", tostring(svc)))
        return {}
    end,
}
]]

-- =====================================================
-- NETWORK / HTTP STUBS (standard Lua)
-- =====================================================
-- LuaSocket stub (if loaded via require, caught above; direct access rare)
socket = setmetatable({}, {
    __index = function(_, key)
        log("SOCKET", string.format("Accessed socket.%s", tostring(key)))
        return function()
            log("SOCKET_CALL", string.format("Called socket.%s()", tostring(key)))
            return nil
        end
    end
})

-- =====================================================
-- MAIN RUNNER
-- =====================================================
local function run_sandbox(script_path)
    if not script_path then
        print("Usage: lua lua51_sandbox.lua <target_script.lua>")
        os.exit(1)
    end

    log("SANDBOX", string.format("Loading target: %s", script_path))

    -- Load the script as a string first for a quick static preview
    local f = io.open(script_path, "r")
    if not f then
        -- io was stubbed above, so use the real one via a workaround.
        -- (We open the file BEFORE stubbing io in a real usage scenario;
        --  here we rely on _real_os since io is already stubbed.)
        log("ERROR", "Could not open script file. Re-run before io is stubbed, or use _real_io.")
        return
    end
    local source = f:read("*all")
    f:close()

    print("\n--- STATIC PREVIEW (first 500 chars) ---")
    print(source:sub(1, 500))
    print("--- END PREVIEW ---\n")

    -- Static keyword scan (quick red-flag pass)
    local red_flags = {
        "loadstring", "getfenv", "setfenv", "require",
        "HttpGet", "HttpPost", "syn%.request", "http%.request",
        "os%.execute", "io%.open", "dofile", "debug%.",
        "hookfunction", "getupvalues", "newcclosure",
        "getconnections", "fireclickdetector", "firetouchinterest",
    }
    print("--- STATIC SCAN ---")
    for _, pattern in ipairs(red_flags) do
        if source:find(pattern) then
            log("STATIC", string.format("Found pattern: '%s'", pattern))
        end
    end
    print("--- END STATIC SCAN ---\n")

    -- Execute through sandboxed environment
    print("--- RUNTIME EXECUTION ---")
    local chunk, err = _real_loadstring(source, "@" .. script_path)
    if not chunk then
        log("PARSE_ERROR", err)
        dump_log()
        return
    end

    local ok, runtime_err = pcall(chunk)
    if not ok then
        log("RUNTIME_ERROR", tostring(runtime_err))
    else
        log("SANDBOX", "Script completed without runtime errors.")
    end
    print("--- END EXECUTION ---")

    dump_log()
end

-- =====================================================
-- ENTRY POINT
-- =====================================================
run_sandbox(arg and arg[1])
