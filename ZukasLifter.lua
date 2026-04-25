print("lifter...")
local root = "./"
package.path = package.path .. ";" .. root .. "src/?.lua"
package.path = package.path .. ";" .. root .. "build/lua/?.lua"
package.path = package.path .. ";" .. root .. "?.lua"
local status, Parser = pcall(require, "prometheus.parser")
if not status then
    print("\n[!] ERROR: Could not find Prometheus source files.")
    print("Search path used: " .. package.path)
    return
end
local Ast      = require("prometheus.ast")
local visitAst = require("prometheus.visitast")
local Unparser = require("prometheus.unparser")
local util     = require("prometheus.util")
local enums    = require("prometheus.enums")
local AstKind  = Ast.AstKind

-- ── zukv2 integration ─────────────────────────────────────────────────────────
-- zukv2core exposes three globals after task.defer fires:
--   _ZUK_DECOMPILE(bytecode: string) -> string
--   _ZUK_PRETTYPRINT(text: string)   -> string
--   _ZUK_CLEANOUTPUT(text: string)   -> string
-- We try to load zukv2core.lua (or .txt) from the same directory as this script.
-- If unavailable (running outside Roblox) we fall back gracefully.
local ZUK_AVAILABLE = false
do
    local zuk_src = nil
    for _, name in ipairs({ "zukv2core.lua", "zukv2core.txt" }) do
        local fh = io.open(root .. name, "r")
        if fh then
            zuk_src = fh:read("*all")
            fh:close()
            break
        end
    end
    if zuk_src then
        local ok, err = pcall(function()
            local fn = assert(loadstring(zuk_src))
            fn()
        end)
        if ok then
            -- task.defer is async; yield if we are in a Roblox coroutine context
            if type(task) == "table" and type(task.wait) == "function" then
                task.wait()
            end
            ZUK_AVAILABLE = (type(_ZUK_DECOMPILE) == "function")
            if ZUK_AVAILABLE then
                print("[ZUK] zukv2core loaded – bytecode decompilation enabled")
            else
                print("[ZUK] zukv2core loaded but _ZUK_DECOMPILE not ready (task.defer pending)")
            end
        else
            print("[ZUK] zukv2core load error: " .. tostring(err))
        end
    else
        print("[ZUK] zukv2core not found – bytecode decompilation disabled")
    end
end

local function zuk_decompile(bytecode)
    if not ZUK_AVAILABLE then return nil end
    local ok, result = pcall(_ZUK_DECOMPILE, bytecode)
    if not ok then
        print("[ZUK] Decompile error: " .. tostring(result))
        return nil
    end
    if type(_ZUK_CLEANOUTPUT) == "function" then
        local ok2, cleaned = pcall(_ZUK_CLEANOUTPUT, result)
        if ok2 then result = cleaned end
    end
    if type(_ZUK_PRETTYPRINT) == "function" then
        local ok3, pretty = pcall(_ZUK_PRETTYPRINT, result)
        if ok3 then result = pretty end
    end
    return result
end
-- ─────────────────────────────────────────────────────────────────────────────

local function create_safe_sandbox()
    local safe_env = {
        tostring = tostring, tonumber = tonumber, type = type,
        pairs = pairs, ipairs = ipairs, next = next,
        select = select, error = error, assert = assert,
        unpack = unpack, rawget = rawget, rawset = rawset,
        rawlen = rawlen, getmetatable = getmetatable, setmetatable = setmetatable,
        math = {
            floor = math.floor, ceil = math.ceil, min = math.min,
            max = math.max, abs = math.abs, sqrt = math.sqrt,
            random = math.random, fmod = math.fmod,
        },
        string = {
            sub = string.sub, len = string.len, char = string.char,
            byte = string.byte, format = string.format, gsub = string.gsub,
            find = string.find, match = string.match, gmatch = string.gmatch,
            reverse = string.reverse, upper = string.upper,
            lower = string.lower, rep = string.rep,
        },
        table = {
            insert = table.insert, remove = table.remove,
            concat = table.concat, sort = table.sort,
        },
        bit = bit or bit32,
    }
    return safe_env
end

local function execute_wrapped_code(code)
    print("[WRAPPER] Executing function wrapper...")
    if not code:match("^%s*return%s*%(%s*function%s*%(") then
        print("  [!] Not a function wrapper, skipping execution")
        return nil
    end
    local success, result = pcall(loadstring(code))
    if success and type(result) == "string" then
        print(string.format("  [+] Successfully executed wrapper! Got %d bytes of code", #result))
        return result
    elseif success and result then
        print(string.format("  [+] Execution returned result of type: %s", type(result)))
        if type(result) == "function" then
            print("  [!] Result is a function, attempting to call it...")
            local success2, result2 = pcall(result)
            if success2 and type(result2) == "string" then
                print(string.format("  [+] Function returned string: %d bytes", #result2))
                return result2
            elseif success2 then
                print(string.format("  [+] Function call succeeded, returned type: %s", type(result2)))
            else
                print(string.format("  [!] Function call failed: %s", tostring(result2)))
            end
        end
        return nil
    else
        print(string.format("  [!] Execution failed: %s", tostring(result)))
        return nil
    end
end

local function extract_wrapper_body_from_ast(ast)
    print("[WRAPPER-AST] Attempting to extract wrapped function body from AST...")
    if ast and ast.body and ast.body.statements and #ast.body.statements > 0 then
        local first_stmt = ast.body.statements[1]
        if first_stmt.kind == AstKind.ReturnStatement then
            print("  [+] First statement is a ReturnStatement")
            local return_values = first_stmt.args or first_stmt.values
            if return_values and #return_values > 0 then
                local return_value = return_values[1]
                if return_value.kind == AstKind.FunctionCallExpression then
                    print("  [+] Return value is FunctionCallExpression")
                    local func = return_value.base
                    if not func then
                        print("  [!] Could not find 'base' in FunctionCallExpression")
                        return nil
                    end
                    print(string.format("  [*] Function kind: %s", tostring(func.kind)))
                    local actual_func = func
                    if func.kind == AstKind.ParenthesesExpression then
                        print("  [*] Function is wrapped in parentheses")
                        actual_func = func.expression
                        print(string.format("  [*] Inner expression kind: %s", tostring(actual_func.kind)))
                    end
                    if actual_func and actual_func.kind == AstKind.FunctionLiteralExpression then
                        print("  [+] Function is FunctionLiteralExpression!")
                        local wrapped_body = actual_func.body
                        if wrapped_body and wrapped_body.statements then
                            print(string.format("  [+] Extracted %d statements from wrapper body", #wrapped_body.statements))
                            return Ast.TopNode(wrapped_body, ast.globalScope)
                        end
                    else
                        print(string.format("  [!] Function is not FunctionLiteralExpression: %s",
                            tostring(actual_func and actual_func.kind or "nil")))
                    end
                end
            end
        end
    end
    print("  [!] Could not extract wrapped body from AST")
    return nil
end

local function unwrap_function_wrapper(code)
    print("[WRAPPER] Checking for function wrappers...")
    local decoded = execute_wrapped_code(code)
    if decoded and #decoded > 0 then
        print("  [+] Successfully extracted decoded code from wrapper")
        return decoded
    else
        print("  [!] Could not execute wrapper (likely has anti-tamper)")
        return code
    end
end

local function decode_escape_sequences(str)
    local result = {}
    local i = 1
    while i <= #str do
        if str:sub(i, i) == "\\" and i + 1 <= #str then
            local nc = str:sub(i + 1, i + 1)
            if nc:match("%d") then
                local octal = str:match("^(%d%d?%d?)", i + 1)
                if octal then
                    local cc = tonumber(octal, 8) or tonumber(octal)
                    if cc and cc <= 255 then
                        table.insert(result, string.char(cc))
                        i = i + 1 + #octal
                    else
                        table.insert(result, str:sub(i, i))
                        i = i + 1
                    end
                else
                    table.insert(result, str:sub(i, i))
                    i = i + 1
                end
            elseif nc == "x" and i + 3 <= #str then
                local hex = str:sub(i + 2, i + 3)
                if hex:match("^%x%x$") then
                    table.insert(result, string.char(tonumber(hex, 16)))
                    i = i + 4
                else
                    table.insert(result, str:sub(i, i))
                    i = i + 1
                end
            elseif nc == "n"  then table.insert(result, "\n");  i = i + 2
            elseif nc == "t"  then table.insert(result, "\t");  i = i + 2
            elseif nc == "r"  then table.insert(result, "\r");  i = i + 2
            elseif nc == "\\" then table.insert(result, "\\");  i = i + 2
            elseif nc == '"'  then table.insert(result, '"');   i = i + 2
            else
                table.insert(result, str:sub(i, i))
                i = i + 1
            end
        else
            table.insert(result, str:sub(i, i))
            i = i + 1
        end
    end
    return table.concat(result)
end

local function extract_constant_arrays(ast)
    print("[CONST-ARRAY] Extracting constant string arrays...")
    local arrays = {}
    local count = 0
    visitAst(ast, function(node, data)
        if node.kind == AstKind.LocalVariable and node.value and node.value.kind == AstKind.TableExpression then
            print(string.format("  [+] Found table assignment to variable '%s'", node.name))
            local strings = {}
            local has_strings = false
            if node.value.fields then
                for idx, field in ipairs(node.value.fields) do
                    local fv = field.value or field
                    if fv and fv.kind == AstKind.StringExpression then
                        strings[idx] = decode_escape_sequences(fv.value)
                        has_strings = true
                    elseif fv and fv.kind == AstKind.ConstantNode and type(fv.value) == "string" then
                        strings[idx] = fv.value
                        has_strings = true
                    end
                end
            end
            if has_strings and #strings > 3 then
                print(string.format("    [+] Array '%s' has %d decoded strings", node.name, #strings))
                arrays[node.name] = { strings = strings, variable = node, indices = strings }
                count = count + 1
            end
        end
    end)
    print(string.format("  [+] Extracted %d constant arrays with %d total strings", count,
        (function() local t = 0; for _, a in pairs(arrays) do t = t + #a.strings end; return t end)()))
    return arrays
end

local function analyze_string_accessors(ast, arrays)
    print("[STRING-ACCESS] Analyzing string accessor functions...")
    local accessors = {}
    local accessor_count = 0
    visitAst(ast, function(node, data)
        if node.kind == AstKind.LocalFunction then
            local func_name = node.name
            local body = node.body
            if body and body.statements and #body.statements > 0 then
                local first_stmt = body.statements[1]
                if first_stmt and first_stmt.kind == AstKind.ReturnStatement
                    and first_stmt.values and #first_stmt.values > 0 then
                    local return_expr = first_stmt.values[1]
                    if return_expr and return_expr.kind == AstKind.IndexExpression then
                        local indexed = return_expr.object
                        local index   = return_expr.index
                        if indexed and indexed.kind == AstKind.VariableExpression then
                            local array_name = indexed.scope:getVariableName(indexed.id)
                            if arrays[array_name] then
                                print(string.format("  [+] Found accessor '%s' → array '%s'", func_name, array_name))
                                local offset = 0
                                if index.kind == AstKind.BinaryExpression then
                                    if index.operator == "+" or index.operator == "-" then
                                        local l, r = index.lhs, index.rhs
                                        if r.kind == AstKind.NumberExpression then
                                            offset = (index.operator == "+") and r.value or -r.value
                                        elseif l.kind == AstKind.NumberExpression then
                                            offset = (index.operator == "+") and l.value or -l.value
                                        end
                                    end
                                elseif index.kind == AstKind.NumberExpression then
                                    offset = index.value
                                end
                                accessors[func_name] = {
                                    array        = array_name,
                                    array_strings= arrays[array_name].strings,
                                    offset       = offset,
                                    node         = node,
                                }
                                accessor_count = accessor_count + 1
                            end
                        end
                    end
                end
            end
        end
    end)
    print(string.format("  [+] Identified %d string accessor functions", accessor_count))
    return accessors
end

-- ── BUG FIX: inline_decoded_strings now actually performs the replacements ────
local function inline_decoded_strings(code, arrays, accessors)
    print("[INLINE] Inlining decoded strings into code...")
    local modified = code
    local total_replacements = 0

    local function esc(s)
        return s:gsub("([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
    end

    for accessor_name, info in pairs(accessors) do
        local array_strings = info.array_strings
        local offset        = info.offset
        print(string.format("  [*] Processing accessor '%s' (offset=%d, strings=%d)",
            accessor_name, offset, #array_strings))

        -- collect all replacements before mutating the string
        local replacements = {}
        local esc_name = esc(accessor_name)
        for full_match, inner in modified:gmatch("(" .. esc_name .. "%s*%(%s*([^)]*)%s*%))") do
            local expr  = inner:match("^%s*(.-)%s*$")
            local index = nil
            if expr:match("^%-?%d+$") then
                index = tonumber(expr)
            else
                local a, op, b = expr:match("^(%d+)([%+%-])%(([^)]*)%)$")
                if a and op and b then
                    local bval = tonumber(b)
                    if bval then
                        index = (op == "+") and (tonumber(a) + bval) or (tonumber(a) - bval)
                    end
                end
            end
            if index then
                local ai = index + offset
                if ai >= 1 and ai <= #array_strings and array_strings[ai] then
                    local sv = array_strings[ai]
                    local escaped = sv
                        :gsub("\\", "\\\\"):gsub('"', '\\"')
                        :gsub("\n", "\\n"):gsub("\r", "\\r")
                    print(string.format("    [+] %s(%s) → \"%s\"",
                        accessor_name, expr, escaped:sub(1, 40)))
                    table.insert(replacements, { from = full_match, to = '"' .. escaped .. '"' })
                end
            end
        end

        -- apply replacements (plain string, not pattern)
        for _, rep in ipairs(replacements) do
            modified = modified:gsub(esc(rep.from), rep.to, 1)
            total_replacements = total_replacements + 1
        end

        if #replacements > 0 then
            print(string.format("  [+] Replaced %d calls to '%s'", #replacements, accessor_name))
        end
    end

    if total_replacements > 0 then
        print(string.format("  [+] Inlined %d total string accessor calls", total_replacements))
    else
        print("  [!] No inlineable calls found (may need runtime evaluation)")
    end
    return modified
end

local function base64_decode(encoded)
    local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="
    local decoded = {}
    local i = 1
    while i <= #encoded do
        local b1 = B64:find(encoded:sub(i,   i),   1, true)
        local b2 = B64:find(encoded:sub(i+1, i+1), 1, true)
        local b3 = B64:find(encoded:sub(i+2, i+2), 1, true)
        local b4 = B64:find(encoded:sub(i+3, i+3), 1, true)
        if not (b1 and b2) then break end
        b1, b2 = b1 - 1, b2 - 1
        b3, b4 = (b3 or 1) - 1, (b4 or 1) - 1
        local n = b1 * 262144 + b2 * 4096 + b3 * 64 + b4
        table.insert(decoded, string.char(math.floor(n / 65536)))
        if b3 ~= 0 or (i+2 <= #encoded and encoded:sub(i+2, i+2) ~= "=") then
            table.insert(decoded, string.char(math.floor((n % 65536) / 256)))
        end
        if b4 ~= 0 or (i+3 <= #encoded and encoded:sub(i+3, i+3) ~= "=") then
            table.insert(decoded, string.char(n % 256))
        end
        i = i + 4
    end
    return table.concat(decoded)
end

-- Luau bytecode starts with a version byte in range 3-6
local function looks_like_luau_bytecode(s)
    local b = s:byte(1) or 0
    return b >= 3 and b <= 6
end

-- ── BUG FIX + ZUK INTEGRATION ─────────────────────────────────────────────────
local function extract_loadstring_calls(ast, parser, unparser, out_dir)
    print("[LOADSTRING] Scanning for loadstring/load calls...")
    out_dir = out_dir or "."
    local extracted_code = {}
    local count = 0

    local function try_zuk(data, label)
        if not ZUK_AVAILABLE then return nil end
        if not looks_like_luau_bytecode(data) then return nil end
        print("    [ZUK] " .. label .. " looks like Luau bytecode – decompiling...")
        local result = zuk_decompile(data)
        if result and #result > 0 then
            print(string.format("    [ZUK] Decompiled: %d bytes of source", #result))
            return result
        end
        print("    [ZUK] Decompile returned empty")
        return nil
    end

    local function try_parse_source(data)
        local ok, parsed = pcall(function()
            local p = Parser:new({ LuaVersion = "LuaU" })
            return p:parse(data)
        end)
        return ok and parsed or nil
    end

    local function handle_payload(payload, func_name)
        if #payload == 0 then return end
        print(string.format("  [+] Found %s with %d byte payload", func_name, #payload))

        -- Path 1: raw bytecode → zuk
        local decompiled = try_zuk(payload, "raw payload")
        if decompiled then
            count = count + 1
            local sp = out_dir .. "/extracted_bytecode_" .. count .. ".lua"
            local sf = io.open(sp, "w")
            if sf then sf:write(decompiled); sf:close()
                print("    [ZUK] Written to " .. sp)
            end
            table.insert(extracted_code, { source = decompiled, size = #decompiled, kind = "bytecode" })
            return
        end

        -- Path 2: base64 decode
        local decoded = base64_decode(payload)
        if #decoded > 0 and decoded ~= payload then
            print(string.format("    [+] base64 decoded: %d → %d bytes", #payload, #decoded))

            -- inner bytecode → zuk
            local decompiled2 = try_zuk(decoded, "decoded payload")
            if decompiled2 then
                count = count + 1
                local sp = out_dir .. "/extracted_bytecode_b64_" .. count .. ".lua"
                local sf = io.open(sp, "w")
                if sf then sf:write(decompiled2); sf:close() end
                table.insert(extracted_code, { source = decompiled2, size = #decompiled2, kind = "bytecode_b64" })
                return
            end

            -- inner source parse
            local parsed = try_parse_source(decoded)
            if parsed then
                print("    [+] Decoded payload parsed as Lua source!")
                count = count + 1
                table.insert(extracted_code, { ast = parsed, source = decoded, size = #decoded, kind = "source_b64" })
                return
            end
        end

        -- Path 3: raw source parse
        local parsed = try_parse_source(payload)
        if parsed then
            print("    [+] Payload parsed as raw Lua source!")
            count = count + 1
            table.insert(extracted_code, { ast = parsed, source = payload, size = #payload, kind = "source_raw" })
        end
    end

    visitAst(ast, function(node, data)
        if node.kind == AstKind.FunctionCallExpression or node.kind == AstKind.FunctionCallStatement then
            local func_name = ""
            if node.func and node.func.kind == AstKind.VariableExpression then
                func_name = node.func.name or ""
            end
            if (func_name == "loadstring" or func_name == "load")
                and node.arguments and #node.arguments > 0 then
                local arg = node.arguments[1]
                if arg.kind == AstKind.StringExpression then
                    handle_payload(arg.value, func_name)
                end
            end
        end
    end)

    print(string.format("  [+] Extracted %d loadstring payloads", count))
    return extracted_code
end

local function fold_constants(ast)
    print("[STAGE 1] Constant Folding & Math Simplification...")
    local folded = 0
    local binOps = {
        [AstKind.AddExpression]    = function(a, b) return a + b end,
        [AstKind.SubExpression]    = function(a, b) return a - b end,
        [AstKind.MulExpression]    = function(a, b) return a * b end,
        [AstKind.DivExpression]    = function(a, b) if b == 0 then return nil end return a / b end,
        [AstKind.ModExpression]    = function(a, b) if b == 0 then return nil end return a % b end,
        [AstKind.PowExpression]    = function(a, b) return a ^ b end,
        [AstKind.StrCatExpression] = function(a, b) return tostring(a) .. tostring(b) end,
    }
    local function is_constant(node)
        return node.kind == AstKind.NumberExpression  or
               node.kind == AstKind.StringExpression  or
               node.kind == AstKind.BooleanExpression or
               node.kind == AstKind.NilExpression
    end
    local function get_value(node)
        if node.kind == AstKind.NumberExpression  then return node.value end
        if node.kind == AstKind.StringExpression  then return node.value end
        if node.kind == AstKind.BooleanExpression then return node.value end
        return nil
    end
    ast = visitAst(ast, nil, function(node, data)
        if binOps[node.kind] and is_constant(node.lhs) and is_constant(node.rhs) then
            local ok, res = pcall(binOps[node.kind], get_value(node.lhs), get_value(node.rhs))
            if ok and res ~= nil then
                folded = folded + 1
                return Ast.ConstantNode(res)
            end
        end
        if node.kind == AstKind.NegateExpression and is_constant(node.rhs) then
            folded = folded + 1
            return Ast.ConstantNode(-get_value(node.rhs))
        end
        if node.kind == AstKind.NotExpression and is_constant(node.rhs) then
            folded = folded + 1
            return Ast.ConstantNode(not get_value(node.rhs))
        end
        if node.kind == AstKind.LenExpression and node.rhs.kind == AstKind.StringExpression then
            folded = folded + 1
            return Ast.NumberExpression(#get_value(node.rhs))
        end
        return node
    end)
    print(string.format("  [+] Folded %d constant expressions", folded))
    return ast
end

local function collect_statements_properly(ast)
    print("[*] Collecting statements from main AST only...")
    local statements = {}
    if ast and ast.body and ast.body.statements then
        for _, stmt in ipairs(ast.body.statements) do
            table.insert(statements, stmt)
        end
    end
    print(string.format("  [+] Collected %d top-level statements", #statements))
    return statements
end

-- ── BUG FIX: tightened large-number pattern so it doesn't nuke real code ──────
-- Old: `=%s*%d%d%d%d+` matched ANY assignment of a 4-digit number.
-- New: only matches a bare integer on the RHS with no operators, tables, or calls,
--      and only for single-char / underscore-heavy obfuscator variable names.
local function detect_and_remove_obfuscation(statements, unparser)
    print("[STAGE 3] Detecting and removing obfuscation patterns...")
    local removed = { jumps = 0, math_random = 0, dummy_vars = 0, empty_blocks = 0 }
    local cleaned = {}
    for _, stat in ipairs(statements) do
        local u   = unparser:unparseStatement(stat)
        local keep = true
        -- junk jump-table: short obf name = large bare integer
        if u:match("^%s*local%s+[_%a][_%w]*%s*=%s*%d%d%d%d+%s*$")
        or u:match("^%s*[_%a][_%w]*%s*=%s*%d%d%d%d+%s*$") then
            removed.jumps = removed.jumps + 1
            keep = false
        -- standalone math.random() call with no assignment (pure junk spin)
        elseif u:match("^%s*math%.random%s*%(") then
            removed.math_random = removed.math_random + 1
            keep = false
        -- single-char local = small literal (obf dummy register)
        elseif u:match("^%s*local%s+[_%a]%s*=%s*%d+%s*$") then
            removed.dummy_vars = removed.dummy_vars + 1
            keep = false
        -- empty do...end
        elseif u:match("^%s*do%s*end%s*$") then
            removed.empty_blocks = removed.empty_blocks + 1
            keep = false
        end
        if keep then table.insert(cleaned, stat) end
    end
    print(string.format("  [+] Removed %d jumps, %d random calls, %d dummy vars, %d empty blocks",
        removed.jumps, removed.math_random, removed.dummy_vars, removed.empty_blocks))
    return cleaned
end

local function simplify_control_flow(statements, unparser)
    print("[STAGE 4] Simplifying control flow...")
    local simplified = 0
    for _, stat in ipairs(statements) do
        if stat.kind == AstKind.IfStatement and stat.condition then
            if stat.condition.kind == AstKind.BooleanExpression
            or stat.condition.kind == AstKind.NumberExpression then
                simplified = simplified + 1
            end
        end
    end
    print(string.format("  [+] Identified %d simplifiable control flow statements", simplified))
    return statements
end

-- Iterative AST walk – avoids stack overflow on deep/large ASTs
local function analyze_variable_usage(statements)
    print("[STAGE 5] Analyzing variable usage...")
    local var_usage = {}
    local var_decls = {}
    local visited   = {}   -- guard against cycles (some AST nodes share references)

    -- use an explicit work-list instead of recursion
    local queue = {}
    for _, stmt in ipairs(statements) do
        queue[#queue + 1] = stmt
    end

    local qi = 1
    while qi <= #queue do
        local node = queue[qi]
        qi = qi + 1

        if type(node) ~= "table" or visited[node] then goto continue end
        visited[node] = true

        -- record variable declarations and usages
        if node.kind == AstKind.LocalVariable and node.name then
            var_usage[node.name] = var_usage[node.name] or { decl = 0, use = 0 }
            var_usage[node.name].decl = var_usage[node.name].decl + 1
            var_decls[node.name] = var_decls[node.name] or {}
            table.insert(var_decls[node.name], node)
        elseif node.kind == AstKind.VariableExpression and node.name then
            var_usage[node.name] = var_usage[node.name] or { decl = 0, use = 0 }
            var_usage[node.name].use = var_usage[node.name].use + 1
        end

        -- enqueue children
        for k, v in pairs(node) do
            if k ~= "kind" and k ~= "parent" and type(v) == "table" and not visited[v] then
                if v.kind then
                    queue[#queue + 1] = v
                elseif v[1] and type(v[1]) == "table" then
                    for _, child in ipairs(v) do
                        if type(child) == "table" and not visited[child] then
                            queue[#queue + 1] = child
                        end
                    end
                end
            end
        end

        ::continue::
    end

    local total, unused = 0, 0
    for _, info in pairs(var_usage) do
        total = total + 1
        if info.decl > 0 and info.use == 0 then unused = unused + 1 end
    end
    print(string.format("  [+] Tracked %d variables, %d appear unused", total, unused))
    return var_usage, var_decls
end

local function decode_ast_string_constants(ast)
    print("[STAGE 7] Decoding escape sequences in AST string constants...")
    local replacements = 0
    local function visit_and_decode(node)
        if not node then return end
        if node.kind == AstKind.StringConstant and node.value and node.value:find("\\") then
            local decoded = decode_escape_sequences(node.value)
            if decoded ~= node.value then
                node.value = decoded
                replacements = replacements + 1
            end
        end
        for key, value in pairs(node) do
            if key ~= "kind" and key ~= "value" and type(value) == "table" then
                if value.kind then
                    visit_and_decode(value)
                elseif value[1] and type(value[1]) == "table" then
                    for _, child in ipairs(value) do
                        if type(child) == "table" and child.kind then
                            visit_and_decode(child)
                        end
                    end
                end
            end
        end
    end
    if ast.body then
        for _, stat in ipairs(ast.body) do visit_and_decode(stat) end
    end
    print(string.format("  [+] Decoded %d escape sequences in AST", replacements))
    return ast
end

local function decode_escape_sequences_in_code(code)
    print("[STAGE 7b] Decoding remaining escape sequences in text...")
    local replacements = 0
    local function _decode(str)
        local result = {}
        local i = 1
        while i <= #str do
            if str:sub(i, i) == "\\" and i + 1 <= #str then
                local nc = str:sub(i + 1, i + 1)
                if nc:match("%d") then
                    local octal = str:match("^(%d%d?%d?)", i + 1)
                    if octal then
                        local cc = tonumber(octal, 8) or tonumber(octal)
                        if cc and cc <= 255 then
                            table.insert(result, string.char(cc))
                            i = i + 1 + #octal
                        else
                            table.insert(result, str:sub(i, i))
                            i = i + 1
                        end
                    else
                        table.insert(result, str:sub(i, i))
                        i = i + 1
                    end
                else
                    table.insert(result, str:sub(i, i))
                    i = i + 1
                end
            else
                table.insert(result, str:sub(i, i))
                i = i + 1
            end
        end
        return table.concat(result)
    end
    local decoded = code:gsub('"([^"]*)"', function(content)
        if content:find("\\%d") then
            local dc = _decode(content)
            dc = dc:gsub('\\', '\\\\'):gsub('"', '\\"')
                   :gsub('\n', '\\n'):gsub('\r', '\\r'):gsub('\t', '\\t')
            replacements = replacements + 1
            return '"' .. dc .. '"'
        end
        return '"' .. content .. '"'
    end)
    print(string.format("  [+] Decoded %d remaining escape sequences in text", replacements))
    return decoded
end

-- ── BUG FIX: removed the fragile hardcoded truncation replacement table ────────
-- Those entries (`"prin"` → `"print"` etc.) would silently corrupt any user
-- string that happened to match. The concat-collapse loop already handles
-- Prometheus split-string obfuscation correctly without them.
local function reconstruct_strings(code)
    print("[STAGE 6] Reconstructing split strings and code...")
    local iterations = 0
    for _ = 1, 20 do
        local before = code
        code = code:gsub('"([^"]*?)"%s*%.%.%s*"([^"]*?)"', function(a, b)
            iterations = iterations + 1
            return '"' .. a .. b .. '"'
        end)
        if code == before then break end
    end
    print(string.format("  [+] Performed %d string concatenation collapses", iterations))
    return code
end

local function deobfuscate_complete(input_path, output_path)
    print("\n" .. string.rep("=", 75))
    print("PROMETHEUS COMPLETE DEOBFUSCATOR v2.1")
    print("With Static Constant Array Extraction, Pattern Detection & ZukV2 Bytecode")
    print(string.rep("=", 75) .. "\n")
    print("[*] Reading input file: " .. input_path)
    local f = io.open(input_path, "r")
    if not f then
        print("[!] ERROR: File not found")
        return
    end
    local original_code = f:read("*all")
    f:close()
    local original_size = #original_code
    print(string.format("  [+] File size: %.2f KB", original_size / 1024))

    print("\n[*] Checking for function wrappers...")
    local working_code = unwrap_function_wrapper(original_code)
    if working_code ~= original_code then
        print("  [+] Successfully unwrapped function via execution")
    else
        print("  [*] Execution unwrapping failed, will use static analysis")
        working_code = original_code
    end

    print("\n[*] Parsing code into AST...")
    local p = Parser:new({ LuaVersion = "LuaU" })
    local ast, err = p:parse(working_code)
    if not ast then
        print("[!] Parse error: " .. tostring(err))
        return
    end
    print("  [+] AST parsed successfully")

    print("\n[*] Checking for wrapped function bodies in AST...")
    local unwrapped_ast = extract_wrapper_body_from_ast(ast)
    if unwrapped_ast then
        print("  [+] Successfully extracted wrapper body from AST")
        ast = unwrapped_ast
    else
        print("  [*] No wrapped function body found in AST, using full AST")
    end

    local temp_u = Unparser:new({ LuaVersion = "LuaU" })
    print("\n[*] STARTING ENHANCED DEOBFUSCATION PIPELINE...\n")

    local const_arrays = extract_constant_arrays(ast)
    local accessors    = analyze_string_accessors(ast, const_arrays)
    if next(accessors) then
        working_code = inline_decoded_strings(working_code, const_arrays, accessors)
        -- re-parse so downstream stages see the inlined strings
        local ok2, ast2 = pcall(function()
            return Parser:new({ LuaVersion = "LuaU" }):parse(working_code)
        end)
        if ok2 and ast2 then
            ast = ast2
            print("  [+] Re-parsed AST after string inlining")
        end
    end

    -- derive side-file output directory from output path
    local out_dir = output_path:match("^(.*)[/\\][^/\\]+$") or "."
    local extracted = extract_loadstring_calls(ast, p, temp_u, out_dir)

    print("[STAGE 1] Constant Folding & Math Simplification...")
    ast = fold_constants(ast)
    local statements = collect_statements_properly(ast)
    statements = detect_and_remove_obfuscation(statements, temp_u)
    simplify_control_flow(statements, temp_u)
    local var_usage, var_decls = analyze_variable_usage(statements)
    ast = decode_ast_string_constants(ast)

    print("\n[*] Generating deobfuscated code...")
    local u = Unparser:new({ LuaVersion = "LuaU", PrettyPrint = true, IndentSpaces = 4 })
    local final_ast = Ast.TopNode(Ast.Block(statements, ast.globalScope), ast.globalScope)
    local code = u:unparse(final_ast)
    code = reconstruct_strings(code)
    code = decode_escape_sequences_in_code(code)

    -- append zuk-decompiled bytecode payloads as labelled sections
    local appended = 0
    for i, payload in ipairs(extracted) do
        if payload.kind and payload.kind:find("bytecode") and payload.source then
            code = code
                .. "\n\n-- ── ZUK DECOMPILED PAYLOAD #" .. i
                .. " [" .. payload.kind .. "] ──\n"
                .. payload.source
            appended = appended + 1
        end
    end
    if appended > 0 then
        print(string.format("  [+] Appended %d zuk-decompiled payload(s) to output", appended))
    end

    print("\n[*] Finalizing output...")
    code = code:gsub("\n%s*\n%s*\n+", "\n\n")
    code = code:gsub("%s+\n", "\n")
    code = code:gsub("\t", "    ")

    local out = io.open(output_path, "w")
    if not out then
        print("[!] ERROR: Could not open output file for writing")
        return
    end
    out:write(code)
    out:close()

    local final_size   = #code
    local compression  = (1 - final_size / original_size) * 100
    print("\n" .. string.rep("=", 75))
    print("[+] SUCCESS: Deobfuscation complete!")
    print(string.format("  Original size:    %.2f KB", original_size / 1024))
    print(string.format("  Deobfuscated:     %.2f KB", final_size / 1024))
    print(string.format("  Compression:      %.1f%%", compression))
    print(string.format("  Arrays extracted: %d", next(const_arrays) and 1 or 0))
    print(string.format("  Accessors found:  %d", next(accessors) and 1 or 0))
    print(string.format("  Extracted:        %d loadstring payloads", #extracted))
    print(string.format("  ZukV2 available:  %s", ZUK_AVAILABLE and "YES" or "NO"))
    print(string.format("  Output file:      %s", output_path))
    print(string.rep("=", 75) .. "\n")
end

local input  = arg[1] or "input.lua"
local output = arg[2] or "output.lua"
deobfuscate_complete(input, output)