local INPUT_FILE = "deob.lua"
local OUTPUT_FILE = "reconstructed_script.lua"

local function readFile(path)
    local f = io.open(path, "rb")
    if not f then return nil end
    local d = f:read("*all")
    f:close()
    return d
end

local function writeFile(path, data)
    local f = io.open(path, "w")
    if not f then return false end
    f:write(data)
    f:close()
    return true
end

local function startLinearization()
    local source = readFile(INPUT_FILE)
    if not source then return print("Error: input.lua not found.") end

    -- 1. Identify Flow Variable
    local flowVar = source:match("while%s*([_%w%d]+)%s*do") or "R"
    
    -- 2. Find Initial State
    -- Looks for something like R=967243 immediately followed by the while loop
    local startVal = source:match(flowVar .. "%s*=%s*(%d+).+while") or source:match("local%s+" .. flowVar .. "%s*=%s*(%d+)")
    startVal = tonumber(startVal)

    if not startVal then
        print("Error: Could not find the entry state for " .. flowVar)
        return
    end

    print("Trace Initialization: Starting at State " .. startVal)

    -- 3. Build a map of the code blocks
    -- We find where R is assigned a value and grab the logic preceding it.
    local blockMap = {}
    -- This pattern captures any logic before an assignment to the flow variable
    for logic, stateId in source:gmatch("([%w%d%_%[%]%(%)%.,%s%+%-/*%%^<>~=#\"']+)" .. flowVar .. "%s*=%s*(%d+)") do
        local id = tonumber(stateId)
        if id then
            blockMap[id] = logic
        end
    end

    -- 4. Reconstruct Path
    local finalScript = { "-- Trace Output", "" }
    local visited = {}
    local current = startVal
    local count = 0

    while current and not visited[current] do
        visited[current] = true
        
        -- In CFF, the logic for 'current' is the chunk that SETS 'current' to the NEXT state.
        -- So we find the block where 'current' is the result of an assignment.
        local logic = blockMap[current]
        
        if logic then
            table.insert(finalScript, "--- [Block State: " .. current .. "] ---")
            -- Clean up the logic chunk (removing leading junk from the regex)
            local cleanLogic = logic:match("then%s*(.*)$") or logic:match("else%s*(.*)$") or logic
            table.insert(finalScript, cleanLogic .. flowVar .. " = " .. current .. ";")
            
            -- Find the NEXT jump from inside this logic
            -- (Wait, the logic above ALREADY contains the R=Current assignment)
            -- We need to find where the logic LEADS. 
            -- Note: In your obfuscator, the block for state A sets R to B.
            
            -- Scan the source for where R is set AFTER this logic block
            local nextState = nil
            local _, pos = source:find(logic .. flowVar .. "%s*=%s*" .. current, 1, true)
            if pos then
                -- Look ahead for the next assignment
                nextState = source:sub(pos+1):match(flowVar .. "%s*=%s*(%d+)")
            end
            
            current = tonumber(nextState)
            count = count + 1
        else
            table.insert(finalScript, "-- [Trace dead-ended at state: " .. tostring(current) .. "]")
            break
        end

        if count > 500 then break end
    end

    if writeFile(OUTPUT_FILE, table.concat(finalScript, "\n")) then
        print("Reconstruction finished. Blocks traced: " .. count)
    else
        print("Error: Disk write failed.")
    end
end

startLinearization()