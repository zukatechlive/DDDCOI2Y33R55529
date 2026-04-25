-- ── String Extractor v4 ───────────────────────────────────────────────────────
-- Auto-detects: array name, shuffle ranges, accessor offset, alphabet, terminator
-- Works on both output.lua format and UWU preset format (and variants).
-- Usage:  luajit string_extractor.lua <obfuscated.lua>
-- ─────────────────────────────────────────────────────────────────────────────

local input_path = arg[1] or "output.lua"

local fh = io.open(input_path, "r")
if not fh then print("[!] Cannot open: " .. input_path); os.exit(1) end
local src = fh:read("*all"); fh:close()
print("[+] Read " .. #src .. " bytes from " .. input_path)

-- ── find string array ─────────────────────────────────────────────────────────
local arr_name, arr_block
for name, block in src:gmatch("local%s+([%w_]+)%s*=%s*(%b{})") do
    local count = 0
    for _ in block:gmatch('".-"') do count = count + 1 end
    if count > 10 then
        arr_name  = name
        arr_block = block
        break
    end
end
if not arr_name then print("[!] Could not find string array"); os.exit(1) end
print("[+] Array: " .. arr_name)

local raw_s = {}
for entry in arr_block:gmatch('"(.-)"') do
    raw_s[#raw_s + 1] = entry
end
print(string.format("[+] Extracted %d raw strings", #raw_s))

-- ── detect shuffle ranges ─────────────────────────────────────────────────────
local shuffle_ranges = {}
local shuffle_block = src:match("for%s+%w+%s*,%s*%w+%s+in%s+ipairs%s*%(%s*(%b{})%s*%)")
if shuffle_block then
    -- try inner-brace format: {{1,262},{1,50},...}
    for a, b in shuffle_block:gmatch("{%s*(%d+)%s*[;,]%s*(%d+)%s*}") do
        shuffle_ranges[#shuffle_ranges + 1] = {tonumber(a), tonumber(b)}
    end
    -- fallback: bare pairs of numbers
    if #shuffle_ranges == 0 then
        for a, b in shuffle_block:gmatch("(%d+)%s*[;,]%s*(%d+)") do
            shuffle_ranges[#shuffle_ranges + 1] = {tonumber(a), tonumber(b)}
        end
    end
end
if #shuffle_ranges == 0 then
    local n = #raw_s
    local m = math.floor(n / 2)
    shuffle_ranges = {{1,n},{1,m},{m+1,n}}
    print("[!] Shuffle ranges not found, using defaults")
else
    print(string.format("[+] Shuffle: %d passes", #shuffle_ranges))
end

-- apply shuffle
local s = {}
for i, v in ipairs(raw_s) do s[i] = v end
for _, R in ipairs(shuffle_ranges) do
    local lo, hi = R[1], R[2]
    while lo < hi do
        s[lo], s[hi] = s[hi], s[lo]
        lo = lo + 1; hi = hi - 1
    end
end
print("[+] Shuffle applied")

-- ── detect accessor function + offset ─────────────────────────────────────────
local acc_name, OFFSET
for fname in src:gmatch("local%s+function%s+([%w_]+)") do
    local body_start = src:find("local%s+function%s+" .. fname:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1"), 1, false)
    if body_start then
        local snippet = src:sub(body_start, body_start + 300)
        local o = snippet:match(arr_name:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1") .. "%s*%[%s*[%w_]+%s*[%-%+]%s*(%d+)%s*%]")
        if o then
            acc_name = fname
            OFFSET   = tonumber(o)
            break
        end
    end
end
if not acc_name then
    print("[!] Accessor not found, defaulting offset=0")
    OFFSET = 0
else
    print(string.format("[+] Accessor: %s()  offset: %d", acc_name, OFFSET))
end

-- ── detect base64 alphabet ────────────────────────────────────────────────────
local K = {}
for tblock in src:gmatch("local%s+[%w_]+%s*=%s*{[^}]-}") do
    local total = 0
    for _ in tblock:gmatch('%["?.%"?%]%s*=%s*%d+') do total = total + 1 end
    for _ in tblock:gmatch('[%a]%s*=%s*%d+')       do total = total + 1 end
    if total > 30 then
        for ch, val in tblock:gmatch('%["(.)"%]%s*=%s*(%d+)') do K[ch] = tonumber(val) end
        for ch, val in tblock:gmatch("'(.)'%s*=%s*(%d+)")     do K[ch] = tonumber(val) end
        for ch, val in tblock:gmatch('([%a])%s*=%s*(%d+)')    do if #ch==1 then K[ch]=tonumber(val) end end
        if next(K) then break end
    end
end
if not next(K) then
    -- built-in UWU alphabet fallback
    K={Q=51,p=24,u=5,Z=55,X=41,K=53,["8"]=31,D=39,S=49,W=60,B=61,s=8,H=47,
       T=56,e=12,E=62,Y=46,M=44,["7"]=28,r=2,N=43,["1"]=36,["+"]=1,["5"]=32,
       F=59,G=52,j=19,C=54,t=6,w=4,x=14,U=48,m=11,["4"]=33,f=18,g=16,A=57,
       a=7,P=63,O=38,J=50,q=22,I=58,v=3,n=9,h=10,b=26,["0"]=29,["3"]=34,
       k=17,V=42,d=13,["9"]=37,o=20,["6"]=30,["2"]=35,z=21,y=25,i=15,R=40,
       ["/"]=0,L=45,c=23,l=27}
    print("[!] Alphabet not found, using UWU built-in")
else
    local cnt=0; for _ in pairs(K) do cnt=cnt+1 end
    print(string.format("[+] Alphabet: %d chars", cnt))
end

-- ── detect terminator ─────────────────────────────────────────────────────────
local terminator = nil
for ch in src:gmatch('elseif%s+[%w_]+%s*==%s*"(.)"') do
    if not K[ch] then terminator = ch; break end
end
if not terminator then
    for ch in src:gmatch("elseif%s+[%w_]+%s*==%s*'(.)'") do
        if not K[ch] then terminator = ch; break end
    end
end
if not terminator and not K["="] then terminator = "=" end
print("[+] Terminator: " .. (terminator and ("'" .. terminator .. "'") or "none"))

-- ── decode ────────────────────────────────────────────────────────────────────
local function decode(enc)
    if enc == "" then return "" end
    local fl  = math.floor
    local out = {}
    local acc, fill = 0, 0
    for pos = 1, #enc do
        local ch  = enc:sub(pos, pos)
        local val = K[ch]
        if val then
            acc  = acc + val * (64 ^ (3 - fill))
            fill = fill + 1
            if fill == 4 then
                fill = 0
                table.insert(out, string.char(fl(acc/65536), fl((acc%65536)/256), acc%256))
                acc = 0
            end
        elseif terminator and ch == terminator then
            if fill >= 1 then table.insert(out, string.char(fl(acc/65536))) end
            if fill >= 2 then table.insert(out, string.char(fl((acc%65536)/256))) end
            break
        end
    end
    if not terminator then
        if fill >= 2 then table.insert(out, string.char(fl(acc/65536))) end
        if fill >= 3 then table.insert(out, string.char(fl((acc%65536)/256))) end
    end
    return table.concat(out)
end

local decoded = {}
for i = 1, #s do decoded[i] = decode(s[i]) end
print("[+] All strings decoded")

-- ── helpers ───────────────────────────────────────────────────────────────────
local function hex_dump(str)
    local h = {}
    for i = 1, #str do h[#h+1] = string.format("%02x", str:byte(i)) end
    return table.concat(h, " ")
end

local function is_strict_ascii(str)
    if #str == 0 then return false end
    for i = 1, #str do
        local b = str:byte(i)
        if b < 32 or b > 126 then return false end
    end
    return true
end

local function safe_display(str)
    return (str:gsub("[%c\128-\255]", function(ch)
        return string.format("\\x%02x", ch:byte(1))
    end))
end

local function unpack_ints(str)
    if #str == 0 then return {} end
    local bytes, res = {}, {}
    for i = 1, #str do bytes[#bytes+1] = str:byte(i) end
    local u8s = {}
    for _, b in ipairs(bytes) do u8s[#u8s+1] = string.format("%3d", b) end
    res[#res+1] = "  u8 : {" .. table.concat(u8s, ", ") .. "}"
    if #bytes % 2 == 0 then
        local u16s = {}
        for i = 1, #bytes, 2 do u16s[#u16s+1] = string.format("%5d", bytes[i]*256+bytes[i+1]) end
        res[#res+1] = "  u16: {" .. table.concat(u16s, ", ") .. "}"
    end
    if #bytes % 4 == 0 then
        local u32s = {}
        for i = 1, #bytes, 4 do
            u32s[#u32s+1] = string.format("%10d",
                bytes[i]*16777216 + bytes[i+1]*65536 + bytes[i+2]*256 + bytes[i+3])
        end
        res[#res+1] = "  u32: {" .. table.concat(u32s, ", ") .. "}"
    end
    return res
end

local function esc_pat(str)
    return str:gsub("([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
end
local function esc_str(str)
    return str:gsub("\\","\\\\"):gsub('"','\\"'):gsub("\n","\\n"):gsub("\r","\\r"):gsub("\0","\\0")
end

-- ── collect accessor calls ────────────────────────────────────────────────────
local seen = {}
if acc_name then
    local esc = acc_name:gsub("([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
    for call in src:gmatch(esc .. "%(%-?%d+%)") do
        local n = tonumber(call:match("%-?%d+"))
        if n then seen[n] = true end
    end
end
local sorted = {}
for n in pairs(seen) do sorted[#sorted+1] = n end
table.sort(sorted)
print(string.format("[+] Found %d unique accessor calls", #sorted))

-- ── categorise ────────────────────────────────────────────────────────────────
local entries, readable_map = {}, {}
local str_count, bin_count, emp_count = 0, 0, 0

for _, n in ipairs(sorted) do
    local idx = n + OFFSET
    local dec = decoded[idx]
    local kind
    if not dec then
        kind = "oor"
    elseif #dec == 0 then
        kind = "empty"; emp_count = emp_count + 1
    elseif is_strict_ascii(dec) then
        kind = "string"; str_count = str_count + 1; readable_map[n] = dec
    else
        kind = "binary"; bin_count = bin_count + 1
    end
    entries[#entries+1] = {n=n, idx=idx, dec=dec or "", kind=kind}
end

-- ── build report ──────────────────────────────────────────────────────────────
local lines = {}
local function L(str) lines[#lines+1] = str or "" end
local SEP  = string.rep("=", 72)
local SEP2 = string.rep("-", 72)
local pfx  = acc_name or "c"

L(SEP)
L("  STRING EXTRACTION REPORT  v4")
L("  Source  : " .. input_path)
L("  Array   : " .. arr_name .. "  (" .. #raw_s .. " entries)")
L("  Offset  : " .. OFFSET)
L("  Accessor: " .. pfx .. "()")
L("  Term    : " .. (terminator and ("'" .. terminator .. "'") or "none"))
L(SEP)

-- section 1
L(""); L("  SECTION 1 — ALL ACCESSOR CALLS  (" .. #sorted .. " unique)"); L(SEP2)
L(string.format("  %-30s  %-5s  %-8s  %s", "CALL", "s[]", "TYPE", "VALUE"))
L(SEP2)
for _, e in ipairs(entries) do
    local cs = pfx .. "(" .. e.n .. ")"
    if e.kind == "oor" then
        L(string.format("  %-30s  [%3d]  OOR      (out of range)", cs, e.idx))
    elseif e.kind == "empty" then
        L(string.format("  %-30s  [%3d]  EMPTY    \"\"", cs, e.idx))
    elseif e.kind == "string" then
        L(string.format("  %-30s  [%3d]  STRING   \"%s\"", cs, e.idx, e.dec))
    else
        L(string.format("  %-30s  [%3d]  BINARY   %s", cs, e.idx, hex_dump(e.dec):sub(1,36)))
        for _, line in ipairs(unpack_ints(e.dec)) do L("                                        " .. line) end
    end
end

-- section 2
L(""); L("  SECTION 2 — READABLE STRINGS ONLY"); L(SEP2)
local any = false
for _, e in ipairs(entries) do
    if e.kind == "string" then
        L(string.format("  %s(%d)  =  \"%s\"", pfx, e.n, e.dec))
        any = true
    end
end
if not any then L("  (none — all values are binary VM data)") end

-- section 3
L(""); L("  SECTION 3 — FULL s[] TABLE (" .. #decoded .. " entries post-shuffle)"); L(SEP2)
L(string.format("  %-6s  %-30s  %-8s  %s", "s[]", "ACCESSOR", "TYPE", "VALUE"))
L(SEP2)
for i = 1, #decoded do
    local dec = decoded[i]
    local n   = i - OFFSET
    local kind, disp
    if #dec == 0 then
        kind="EMPTY"; disp="\"\""
    elseif is_strict_ascii(dec) then
        kind="STRING"; disp='"'..dec..'"'
    else
        kind="BINARY"; disp=hex_dump(dec)
    end
    L(string.format("  [%3d]  %-30s  %-8s %s", i, pfx.."("..n..")", kind, disp:sub(1,36)))
    if kind == "BINARY" then
        for _, line in ipairs(unpack_ints(dec)) do
            L("                                              " .. line)
        end
    end
end

-- section 4
L(""); L("  SECTION 4 — CALL SITES FOR READABLE STRINGS"); L(SEP2)
for _, e in ipairs(entries) do
    if e.kind == "string" then
        local cs    = pfx .. "(" .. e.n .. ")"
        local sites = {}
        local ln    = 0
        for line in (src.."\n"):gmatch("([^\n]*)\n") do
            ln = ln + 1
            if line:find(cs, 1, true) then
                sites[#sites+1] = string.format("    line %5d: %s", ln,
                    line:match("^%s*(.-)%s*$"):sub(1,65))
            end
        end
        L(string.format("  %s(%d)  \"%s\"  (%d site%s)",
            pfx, e.n, e.dec, #sites, #sites==1 and "" or "s"))
        for _, site in ipairs(sites) do L(site) end
    end
end

L(""); L(SEP)
L(string.format("  SUMMARY: %d calls  |  %d strings  |  %d binary  |  %d empty",
    #sorted, str_count, bin_count, emp_count))
L(SEP)

-- ── write report ──────────────────────────────────────────────────────────────
local report_path = input_path:gsub("%.lua$","") .. "_report.txt"
local rf = io.open(report_path, "w")
if rf then
    rf:write(table.concat(lines,"\n")); rf:write("\n"); rf:close()
    print("[+] Report -> " .. report_path)
else print("[!] Could not write report") end

-- ── write inlined source ──────────────────────────────────────────────────────
local patched, replaced = src, 0
for n, dec in pairs(readable_map) do
    local lit        = '"' .. esc_str(dec) .. '"'
    local pat        = esc_pat(pfx .. "(" .. n .. ")")
    local new, count = patched:gsub(pat, lit)
    patched  = new
    replaced = replaced + count
end
local inlined_path = input_path:gsub("%.lua$","") .. "_inlined.lua"
local of = io.open(inlined_path,"w")
if of then
    of:write(patched); of:close()
    print(string.format("[+] Inlined %d calls -> %s", replaced, inlined_path))
end

print("[+] Done.")