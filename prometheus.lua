local __DARKLUA_BUNDLE_MODULES = {cache = {}}

do
    do
        local function __modImpl()
            local NAME, REVISION, VERSION, BY = 'Prometheus', 'Alpha', 'v0.2', 'levno-710'

            for _, currArg in pairs(arg)do
                if currArg == '--CI' then
                    local releaseName = string.gsub(string.format('%s %s %s', NAME, REVISION, VERSION), '%s', '-')

                    print(releaseName)
                end
                if currArg == '--FullVersion' then
                    print(VERSION)
                end
            end

            return {
                Name = NAME,
                NameUpper = string.upper(NAME),
                NameAndVersion = string.format('%s %s', NAME, VERSION),
                Version = VERSION,
                Revision = REVISION,
                IdentPrefix = '__prometheus_',
                SPACE = ' ',
                TAB = '\t',
            }
        end

        function __DARKLUA_BUNDLE_MODULES.a()
            local v = __DARKLUA_BUNDLE_MODULES.cache.a

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.a = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Ast, AstKind = {}, {
                TopNode = 'TopNode',
                Block = 'Block',
                ContinueStatement = 'ContinueStatement',
                BreakStatement = 'BreakStatement',
                DoStatement = 'DoStatement',
                WhileStatement = 'WhileStatement',
                ReturnStatement = 'ReturnStatement',
                RepeatStatement = 'RepeatStatement',
                ForInStatement = 'ForInStatement',
                ForStatement = 'ForStatement',
                IfStatement = 'IfStatement',
                FunctionDeclaration = 'FunctionDeclaration',
                LocalFunctionDeclaration = 'LocalFunctionDeclaration',
                LocalVariableDeclaration = 'LocalVariableDeclaration',
                FunctionCallStatement = 'FunctionCallStatement',
                PassSelfFunctionCallStatement = 'PassSelfFunctionCallStatement',
                AssignmentStatement = 'AssignmentStatement',
                CompoundAddStatement = 'CompoundAddStatement',
                CompoundSubStatement = 'CompoundSubStatement',
                CompoundMulStatement = 'CompoundMulStatement',
                CompoundDivStatement = 'CompoundDivStatement',
                CompoundModStatement = 'CompoundModStatement',
                CompoundPowStatement = 'CompoundPowStatement',
                CompoundConcatStatement = 'CompoundConcatStatement',
                AssignmentIndexing = 'AssignmentIndexing',
                AssignmentVariable = 'AssignmentVariable',
                BooleanExpression = 'BooleanExpression',
                NumberExpression = 'NumberExpression',
                StringExpression = 'StringExpression',
                NilExpression = 'NilExpression',
                VarargExpression = 'VarargExpression',
                OrExpression = 'OrExpression',
                AndExpression = 'AndExpression',
                LessThanExpression = 'LessThanExpression',
                GreaterThanExpression = 'GreaterThanExpression',
                LessThanOrEqualsExpression = 'LessThanOrEqualsExpression',
                GreaterThanOrEqualsExpression = 'GreaterThanOrEqualsExpression',
                NotEqualsExpression = 'NotEqualsExpression',
                EqualsExpression = 'EqualsExpression',
                StrCatExpression = 'StrCatExpression',
                AddExpression = 'AddExpression',
                SubExpression = 'SubExpression',
                MulExpression = 'MulExpression',
                DivExpression = 'DivExpression',
                ModExpression = 'ModExpression',
                NotExpression = 'NotExpression',
                LenExpression = 'LenExpression',
                NegateExpression = 'NegateExpression',
                PowExpression = 'PowExpression',
                IndexExpression = 'IndexExpression',
                FunctionCallExpression = 'FunctionCallExpression',
                PassSelfFunctionCallExpression = 'PassSelfFunctionCallExpression',
                VariableExpression = 'VariableExpression',
                FunctionLiteralExpression = 'FunctionLiteralExpression',
                TableConstructorExpression = 'TableConstructorExpression',
                TableEntry = 'TableEntry',
                KeyedTableEntry = 'KeyedTableEntry',
                NopStatement = 'NopStatement',
                IfElseExpression = 'IfElseExpression',
            }
            local astKindExpressionLookup = {
                [AstKind.BooleanExpression] = 0,
                [AstKind.NumberExpression] = 0,
                [AstKind.StringExpression] = 0,
                [AstKind.NilExpression] = 0,
                [AstKind.VarargExpression] = 0,
                [AstKind.OrExpression] = 12,
                [AstKind.AndExpression] = 11,
                [AstKind.LessThanExpression] = 10,
                [AstKind.GreaterThanExpression] = 10,
                [AstKind.LessThanOrEqualsExpression] = 10,
                [AstKind.GreaterThanOrEqualsExpression] = 10,
                [AstKind.NotEqualsExpression] = 10,
                [AstKind.EqualsExpression] = 10,
                [AstKind.StrCatExpression] = 9,
                [AstKind.AddExpression] = 8,
                [AstKind.SubExpression] = 8,
                [AstKind.MulExpression] = 7,
                [AstKind.DivExpression] = 7,
                [AstKind.ModExpression] = 7,
                [AstKind.NotExpression] = 5,
                [AstKind.LenExpression] = 5,
                [AstKind.NegateExpression] = 5,
                [AstKind.PowExpression] = 4,
                [AstKind.IndexExpression] = 1,
                [AstKind.AssignmentIndexing] = 1,
                [AstKind.FunctionCallExpression] = 2,
                [AstKind.PassSelfFunctionCallExpression] = 2,
                [AstKind.VariableExpression] = 0,
                [AstKind.AssignmentVariable] = 0,
                [AstKind.FunctionLiteralExpression] = 3,
                [AstKind.TableConstructorExpression] = 3,
            }

            Ast.AstKind = AstKind

            function Ast.astKindExpressionToNumber(kind)
                return astKindExpressionLookup[kind] or 100
            end
            function Ast.ConstantNode(val)
                if type(val) == 'nil' then
                    return Ast.NilExpression()
                end
                if type(val) == 'string' then
                    return Ast.StringExpression(val)
                end
                if type(val) == 'number' then
                    return Ast.NumberExpression(val)
                end
                if type(val) == 'boolean' then
                    return Ast.BooleanExpression(val)
                end
            end
            function Ast.NopStatement()
                return {
                    kind = AstKind.NopStatement,
                }
            end
            function Ast.IfElseExpression(condition, true_value, false_value)
                return {
                    kind = AstKind.IfElseExpression,
                    condition = condition,
                    true_value = true_value,
                    false_value = false_value,
                }
            end
            function Ast.TopNode(body, globalScope)
                return {
                    kind = AstKind.TopNode,
                    body = body,
                    globalScope = globalScope,
                }
            end
            function Ast.TableEntry(value)
                return {
                    kind = AstKind.TableEntry,
                    value = value,
                }
            end
            function Ast.KeyedTableEntry(key, value)
                return {
                    kind = AstKind.KeyedTableEntry,
                    key = key,
                    value = value,
                }
            end
            function Ast.TableConstructorExpression(entries)
                return {
                    kind = AstKind.TableConstructorExpression,
                    entries = entries,
                }
            end
            function Ast.Block(statements, scope)
                return {
                    kind = AstKind.Block,
                    statements = statements,
                    scope = scope,
                }
            end
            function Ast.BreakStatement(loop, scope)
                return {
                    kind = AstKind.BreakStatement,
                    loop = loop,
                    scope = scope,
                }
            end
            function Ast.ContinueStatement(loop, scope)
                return {
                    kind = AstKind.ContinueStatement,
                    loop = loop,
                    scope = scope,
                }
            end
            function Ast.PassSelfFunctionCallStatement(
                base,
                passSelfFunctionName,
                args
            )
                return {
                    kind = AstKind.PassSelfFunctionCallStatement,
                    base = base,
                    passSelfFunctionName = passSelfFunctionName,
                    args = args,
                }
            end
            function Ast.AssignmentStatement(lhs, rhs)
                if (#lhs < 1) then
                    print(debug.traceback())
                    error'Something went wrong!'
                end

                return {
                    kind = AstKind.AssignmentStatement,
                    lhs = lhs,
                    rhs = rhs,
                }
            end
            function Ast.CompoundAddStatement(lhs, rhs)
                return {
                    kind = AstKind.CompoundAddStatement,
                    lhs = lhs,
                    rhs = rhs,
                }
            end
            function Ast.CompoundSubStatement(lhs, rhs)
                return {
                    kind = AstKind.CompoundSubStatement,
                    lhs = lhs,
                    rhs = rhs,
                }
            end
            function Ast.CompoundMulStatement(lhs, rhs)
                return {
                    kind = AstKind.CompoundMulStatement,
                    lhs = lhs,
                    rhs = rhs,
                }
            end
            function Ast.CompoundDivStatement(lhs, rhs)
                return {
                    kind = AstKind.CompoundDivStatement,
                    lhs = lhs,
                    rhs = rhs,
                }
            end
            function Ast.CompoundPowStatement(lhs, rhs)
                return {
                    kind = AstKind.CompoundPowStatement,
                    lhs = lhs,
                    rhs = rhs,
                }
            end
            function Ast.CompoundModStatement(lhs, rhs)
                return {
                    kind = AstKind.CompoundModStatement,
                    lhs = lhs,
                    rhs = rhs,
                }
            end
            function Ast.CompoundConcatStatement(lhs, rhs)
                return {
                    kind = AstKind.CompoundConcatStatement,
                    lhs = lhs,
                    rhs = rhs,
                }
            end
            function Ast.FunctionCallStatement(base, args)
                return {
                    kind = AstKind.FunctionCallStatement,
                    base = base,
                    args = args,
                }
            end
            function Ast.ReturnStatement(args)
                return {
                    kind = AstKind.ReturnStatement,
                    args = args,
                }
            end
            function Ast.DoStatement(body)
                return {
                    kind = AstKind.DoStatement,
                    body = body,
                }
            end
            function Ast.WhileStatement(body, condition, parentScope)
                return {
                    kind = AstKind.WhileStatement,
                    body = body,
                    condition = condition,
                    parentScope = parentScope,
                }
            end
            function Ast.ForInStatement(
                scope,
                vars,
                expressions,
                body,
                parentScope
            )
                return {
                    kind = AstKind.ForInStatement,
                    scope = scope,
                    ids = vars,
                    vars = vars,
                    expressions = expressions,
                    body = body,
                    parentScope = parentScope,
                }
            end
            function Ast.ForStatement(
                scope,
                id,
                initialValue,
                finalValue,
                incrementBy,
                body,
                parentScope
            )
                return {
                    kind = AstKind.ForStatement,
                    scope = scope,
                    id = id,
                    initialValue = initialValue,
                    finalValue = finalValue,
                    incrementBy = incrementBy,
                    body = body,
                    parentScope = parentScope,
                }
            end
            function Ast.RepeatStatement(condition, body, parentScope)
                return {
                    kind = AstKind.RepeatStatement,
                    body = body,
                    condition = condition,
                    parentScope = parentScope,
                }
            end
            function Ast.IfStatement(condition, body, elseifs, elsebody)
                return {
                    kind = AstKind.IfStatement,
                    condition = condition,
                    body = body,
                    elseifs = elseifs,
                    elsebody = elsebody,
                }
            end
            function Ast.FunctionDeclaration(scope, id, indices, args, body)
                return {
                    kind = AstKind.FunctionDeclaration,
                    scope = scope,
                    baseScope = scope,
                    id = id,
                    baseId = id,
                    indices = indices,
                    args = args,
                    body = body,
                    getName = function(self)
                        return self.scope:getVariableName(self.id)
                    end,
                }
            end
            function Ast.LocalFunctionDeclaration(scope, id, args, body)
                return {
                    kind = AstKind.LocalFunctionDeclaration,
                    scope = scope,
                    id = id,
                    args = args,
                    body = body,
                    getName = function(self)
                        return self.scope:getVariableName(self.id)
                    end,
                }
            end
            function Ast.LocalVariableDeclaration(scope, ids, expressions)
                return {
                    kind = AstKind.LocalVariableDeclaration,
                    scope = scope,
                    ids = ids,
                    expressions = expressions,
                }
            end
            function Ast.VarargExpression()
                return {
                    kind = AstKind.VarargExpression,
                    isConstant = false,
                }
            end
            function Ast.BooleanExpression(value)
                return {
                    kind = AstKind.BooleanExpression,
                    isConstant = true,
                    value = value,
                }
            end
            function Ast.NilExpression()
                return {
                    kind = AstKind.NilExpression,
                    isConstant = true,
                    value = nil,
                }
            end
            function Ast.NumberExpression(value)
                return {
                    kind = AstKind.NumberExpression,
                    isConstant = true,
                    value = value,
                }
            end
            function Ast.StringExpression(value)
                return {
                    kind = AstKind.StringExpression,
                    isConstant = true,
                    value = value,
                }
            end
            function Ast.OrExpression(lhs, rhs, simplify)
                if (simplify and rhs.isConstant and lhs.isConstant) then
                    local success, val = pcall(function()
                        return lhs.value or rhs.value
                    end)

                    if success then
                        return Ast.ConstantNode(val)
                    end
                end

                return {
                    kind = AstKind.OrExpression,
                    lhs = lhs,
                    rhs = rhs,
                    isConstant = false,
                }
            end
            function Ast.AndExpression(lhs, rhs, simplify)
                if (simplify and rhs.isConstant and lhs.isConstant) then
                    local success, val = pcall(function()
                        return lhs.value and rhs.value
                    end)

                    if success then
                        return Ast.ConstantNode(val)
                    end
                end

                return {
                    kind = AstKind.AndExpression,
                    lhs = lhs,
                    rhs = rhs,
                    isConstant = false,
                }
            end
            function Ast.LessThanExpression(lhs, rhs, simplify)
                if (simplify and rhs.isConstant and lhs.isConstant) then
                    local success, val = pcall(function()
                        return lhs.value < rhs.value
                    end)

                    if success then
                        return Ast.ConstantNode(val)
                    end
                end

                return {
                    kind = AstKind.LessThanExpression,
                    lhs = lhs,
                    rhs = rhs,
                    isConstant = false,
                }
            end
            function Ast.GreaterThanExpression(lhs, rhs, simplify)
                if (simplify and rhs.isConstant and lhs.isConstant) then
                    local success, val = pcall(function()
                        return lhs.value > rhs.value
                    end)

                    if success then
                        return Ast.ConstantNode(val)
                    end
                end

                return {
                    kind = AstKind.GreaterThanExpression,
                    lhs = lhs,
                    rhs = rhs,
                    isConstant = false,
                }
            end
            function Ast.LessThanOrEqualsExpression(lhs, rhs, simplify)
                if (simplify and rhs.isConstant and lhs.isConstant) then
                    local success, val = pcall(function()
                        return lhs.value <= rhs.value
                    end)

                    if success then
                        return Ast.ConstantNode(val)
                    end
                end

                return {
                    kind = AstKind.LessThanOrEqualsExpression,
                    lhs = lhs,
                    rhs = rhs,
                    isConstant = false,
                }
            end
            function Ast.GreaterThanOrEqualsExpression(lhs, rhs, simplify)
                if (simplify and rhs.isConstant and lhs.isConstant) then
                    local success, val = pcall(function()
                        return lhs.value >= rhs.value
                    end)

                    if success then
                        return Ast.ConstantNode(val)
                    end
                end

                return {
                    kind = AstKind.GreaterThanOrEqualsExpression,
                    lhs = lhs,
                    rhs = rhs,
                    isConstant = false,
                }
            end
            function Ast.NotEqualsExpression(lhs, rhs, simplify)
                if (simplify and rhs.isConstant and lhs.isConstant) then
                    local success, val = pcall(function()
                        return lhs.value ~= rhs.value
                    end)

                    if success then
                        return Ast.ConstantNode(val)
                    end
                end

                return {
                    kind = AstKind.NotEqualsExpression,
                    lhs = lhs,
                    rhs = rhs,
                    isConstant = false,
                }
            end
            function Ast.EqualsExpression(lhs, rhs, simplify)
                if (simplify and rhs.isConstant and lhs.isConstant) then
                    local success, val = pcall(function()
                        return lhs.value == rhs.value
                    end)

                    if success then
                        return Ast.ConstantNode(val)
                    end
                end

                return {
                    kind = AstKind.EqualsExpression,
                    lhs = lhs,
                    rhs = rhs,
                    isConstant = false,
                }
            end
            function Ast.StrCatExpression(lhs, rhs, simplify)
                if (simplify and rhs.isConstant and lhs.isConstant) then
                    local success, val = pcall(function()
                        return lhs.value .. rhs.value
                    end)

                    if success then
                        return Ast.ConstantNode(val)
                    end
                end

                return {
                    kind = AstKind.StrCatExpression,
                    lhs = lhs,
                    rhs = rhs,
                    isConstant = false,
                }
            end
            function Ast.AddExpression(lhs, rhs, simplify)
                if (simplify and rhs.isConstant and lhs.isConstant) then
                    local success, val = pcall(function()
                        return lhs.value + rhs.value
                    end)

                    if success then
                        return Ast.ConstantNode(val)
                    end
                end

                return {
                    kind = AstKind.AddExpression,
                    lhs = lhs,
                    rhs = rhs,
                    isConstant = false,
                }
            end
            function Ast.SubExpression(lhs, rhs, simplify)
                if (simplify and rhs.isConstant and lhs.isConstant) then
                    local success, val = pcall(function()
                        return lhs.value - rhs.value
                    end)

                    if success then
                        return Ast.ConstantNode(val)
                    end
                end

                return {
                    kind = AstKind.SubExpression,
                    lhs = lhs,
                    rhs = rhs,
                    isConstant = false,
                }
            end
            function Ast.MulExpression(lhs, rhs, simplify)
                if (simplify and rhs.isConstant and lhs.isConstant) then
                    local success, val = pcall(function()
                        return lhs.value * rhs.value
                    end)

                    if success then
                        return Ast.ConstantNode(val)
                    end
                end

                return {
                    kind = AstKind.MulExpression,
                    lhs = lhs,
                    rhs = rhs,
                    isConstant = false,
                }
            end
            function Ast.DivExpression(lhs, rhs, simplify)
                if (simplify and rhs.isConstant and lhs.isConstant and rhs.value ~= 0) then
                    local success, val = pcall(function()
                        return lhs.value / rhs.value
                    end)

                    if success then
                        return Ast.ConstantNode(val)
                    end
                end

                return {
                    kind = AstKind.DivExpression,
                    lhs = lhs,
                    rhs = rhs,
                    isConstant = false,
                }
            end
            function Ast.ModExpression(lhs, rhs, simplify)
                if (simplify and rhs.isConstant and lhs.isConstant) then
                    local success, val = pcall(function()
                        return lhs.value % rhs.value
                    end)

                    if success then
                        return Ast.ConstantNode(val)
                    end
                end

                return {
                    kind = AstKind.ModExpression,
                    lhs = lhs,
                    rhs = rhs,
                    isConstant = false,
                }
            end
            function Ast.NotExpression(rhs, simplify)
                if (simplify and rhs.isConstant) then
                    local success, val = pcall(function()
                        return not rhs.value
                    end)

                    if success then
                        return Ast.ConstantNode(val)
                    end
                end

                return {
                    kind = AstKind.NotExpression,
                    rhs = rhs,
                    isConstant = false,
                }
            end
            function Ast.NegateExpression(rhs, simplify)
                if (simplify and rhs.isConstant) then
                    local success, val = pcall(function()
                        return -rhs.value
                    end)

                    if success then
                        return Ast.ConstantNode(val)
                    end
                end

                return {
                    kind = AstKind.NegateExpression,
                    rhs = rhs,
                    isConstant = false,
                }
            end
            function Ast.LenExpression(rhs, simplify)
                if (simplify and rhs.isConstant) then
                    local success, val = pcall(function()
                        return #rhs.value
                    end)

                    if success then
                        return Ast.ConstantNode(val)
                    end
                end

                return {
                    kind = AstKind.LenExpression,
                    rhs = rhs,
                    isConstant = false,
                }
            end
            function Ast.PowExpression(lhs, rhs, simplify)
                if (simplify and rhs.isConstant and lhs.isConstant) then
                    local success, val = pcall(function()
                        return lhs.value ^ rhs.value
                    end)

                    if success then
                        return Ast.ConstantNode(val)
                    end
                end

                return {
                    kind = AstKind.PowExpression,
                    lhs = lhs,
                    rhs = rhs,
                    isConstant = false,
                }
            end
            function Ast.IndexExpression(base, index)
                return {
                    kind = AstKind.IndexExpression,
                    base = base,
                    index = index,
                    isConstant = false,
                }
            end
            function Ast.AssignmentIndexing(base, index)
                return {
                    kind = AstKind.AssignmentIndexing,
                    base = base,
                    index = index,
                    isConstant = false,
                }
            end
            function Ast.PassSelfFunctionCallExpression(
                base,
                passSelfFunctionName,
                args
            )
                return {
                    kind = AstKind.PassSelfFunctionCallExpression,
                    base = base,
                    passSelfFunctionName = passSelfFunctionName,
                    args = args,
                }
            end
            function Ast.FunctionCallExpression(base, args)
                return {
                    kind = AstKind.FunctionCallExpression,
                    base = base,
                    args = args,
                }
            end
            function Ast.VariableExpression(scope, id)
                scope.addReference(scope, id)

                return {
                    kind = AstKind.VariableExpression,
                    scope = scope,
                    id = id,
                    getName = function(self)
                        return self.scope.getVariableName(self.id)
                    end,
                }
            end
            function Ast.AssignmentVariable(scope, id)
                scope.addReference(scope, id)

                return {
                    kind = AstKind.AssignmentVariable,
                    scope = scope,
                    id = id,
                    getName = function(self)
                        return self.scope.getVariableName(self.id)
                    end,
                }
            end
            function Ast.FunctionLiteralExpression(args, body)
                return {
                    kind = AstKind.FunctionLiteralExpression,
                    args = args,
                    body = body,
                }
            end

            return Ast
        end

        function __DARKLUA_BUNDLE_MODULES.b()
            local v = __DARKLUA_BUNDLE_MODULES.cache.b

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.b = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local keys, escapeString = {
                reset = 0,
                bright = 1,
                dim = 2,
                underline = 4,
                blink = 5,
                reverse = 7,
                hidden = 8,
                black = 30,
                pink = 91,
                red = 31,
                green = 32,
                yellow = 33,
                blue = 34,
                magenta = 35,
                cyan = 36,
                grey = 37,
                gray = 37,
                white = 97,
                blackbg = 40,
                redbg = 41,
                greenbg = 42,
                yellowbg = 43,
                bluebg = 44,
                magentabg = 45,
                cyanbg = 46,
                greybg = 47,
                graybg = 47,
                whitebg = 107,
            }, string.char(27) .. '[%dm'

            local function escapeNumber(number)
                return escapeString.format(escapeString, number)
            end

            local settings = {enabled = true}

            local function colors(str, ...)
                if not settings.enabled then
                    return str
                end

                str = tostring(str or '')

                local escapes = {}

                for i, name in ipairs{...}do
                    table.insert(escapes, escapeNumber(keys[name]))
                end

                return escapeNumber(keys.reset) .. table.concat(escapes) .. str .. escapeNumber(keys.reset)
            end

            return setmetatable(settings, {
                __call = function(_, ...)
                    return colors(...)
                end,
            })
        end

        function __DARKLUA_BUNDLE_MODULES.c()
            local v = __DARKLUA_BUNDLE_MODULES.cache.c

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.c = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local logger, config, colors = {}, __DARKLUA_BUNDLE_MODULES.a(), __DARKLUA_BUNDLE_MODULES.c()

            logger.LogLevel = {
                Error = 0,
                Warn = 1,
                Log = 2,
                Info = 2,
                Debug = 3,
            }
            logger.logLevel = logger.LogLevel.Log
            logger.debugCallback = function(...)
                print(colors(config.NameUpper .. ': ' ..  ..., 'grey'))
            end

            function logger.debug(self, ...)
                if self.logLevel >= self.LogLevel.Debug then
                    self.debugCallback(...)
                end
            end

            logger.logCallback = function(...)
                print(colors(config.NameUpper .. ': ', 'magenta') ..  ...)
            end

            function logger.log(self, ...)
                if self.logLevel >= self.LogLevel.Log then
                    self.logCallback(...)
                end
            end
            function logger.info(self, ...)
                if self.logLevel >= self.LogLevel.Log then
                    self.logCallback(...)
                end
            end

            logger.warnCallback = function(...)
                print(colors(config.NameUpper .. ': ' ..  ..., 'yellow'))
            end

            function logger.warn(self, ...)
                if self.logLevel >= self.LogLevel.Warn then
                    self.warnCallback(...)
                end
            end

            logger.errorCallback = function(...)
                print(colors(config.NameUpper .. ': ' ..  ..., 'red'))
                error(...)
            end

            function logger.error(self, ...)
                self.errorCallback(...)
                error(config.NameUpper .. ': logger.errorCallback did not throw an Error!')
            end

            return logger
        end

        function __DARKLUA_BUNDLE_MODULES.d()
            local v = __DARKLUA_BUNDLE_MODULES.cache.d

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.d = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local M, floor, MOD = {
                _TYPE = 'module',
                _NAME = 'bit.numberlua',
                _VERSION = '0.3.1.20120131',
            }, math.floor, 4294967296
            local MODM = MOD - 1

            local function memoize(f)
                local mt = {}
                local t = setmetatable({}, mt)

                function mt.__index(self, k)
                    local v = f(k)

                    t[k] = v

                    return v
                end

                return t
            end
            local function make_bitop_uncached(t, m)
                local function bitop(a, b)
                    local res, p = 0, 1

                    while a ~= 0 and b ~= 0 do
                        local am, bm = a % m, b % m

                        res = res + t[am][bm] * p
                        a = (a - am) / m
                        b = (b - bm) / m
                        p = p * m
                    end

                    res = res + (a + b) * p

                    return res
                end

                return bitop
            end
            local function make_bitop(t)
                local op1 = make_bitop_uncached(t, 2)
                local op2 = memoize(function(a)
                    return memoize(function(b)
                        return op1(a, b)
                    end)
                end)

                return make_bitop_uncached(op2, 2 ^ (t.n or 1))
            end

            function M.tobit(x)
                return x % 4294967296
            end

            M.bxor = make_bitop{
                [0] = {
                    [0] = 0,
                    [1] = 1,
                },
                [1] = {
                    [0] = 1,
                    [1] = 0,
                },
                n = 4,
            }

            local bxor = M.bxor

            function M.bnot(a)
                return MODM - a
            end

            local bnot = M.bnot

            function M.band(a, b)
                return ((a + b) - bxor(a, b)) / 2
            end

            local band = M.band

            function M.bor(a, b)
                return MODM - band(MODM - a, MODM - b)
            end

            local bor, lshift, rshift = M.bor, nil, nil

            function M.rshift(a, disp)
                if disp < 0 then
                    return lshift(a, -disp)
                end

                return floor(a % 4294967296 / 2 ^ disp)
            end

            rshift = M.rshift

            function M.lshift(a, disp)
                if disp < 0 then
                    return rshift(a, -disp)
                end

                return (a * 2 ^ disp) % 4294967296
            end

            lshift = M.lshift

            function M.tohex(x, n)
                n = n or 8

                local up

                if n <= 0 then
                    if n == 0 then
                        return ''
                    end

                    up = true
                    n = -n
                end

                x = band(x, 16 ^ n - 1)

                return ('%0' .. n .. (up and 'X' or 'x')):format(x)
            end

            local tohex = M.tohex

            function M.extract(n, field, width)
                width = width or 1

                return band(rshift(n, field), 2 ^ width - 1)
            end

            local extract = M.extract

            function M.replace(n, v, field, width)
                width = width or 1

                local mask1 = 2 ^ width - 1

                v = band(v, mask1)

                local mask = bnot(lshift(mask1, field))

                return band(n, mask) + lshift(v, field)
            end

            local replace = M.replace

            function M.bswap(x)
                local a = band(x, 255)

                x = rshift(x, 8)

                local b = band(x, 255)

                x = rshift(x, 8)

                local c = band(x, 255)

                x = rshift(x, 8)

                local d = band(x, 255)

                return lshift(lshift(lshift(a, 8) + b, 8) + c, 8) + d
            end

            local bswap = M.bswap

            function M.rrotate(x, disp)
                disp = disp % 32

                local low = band(x, 2 ^ disp - 1)

                return rshift(x, disp) + lshift(low, 32 - disp)
            end

            local rrotate = M.rrotate

            function M.lrotate(x, disp)
                return rrotate(x, -disp)
            end

            local lrotate = M.lrotate

            M.rol = M.lrotate
            M.ror = M.rrotate

            function M.arshift(x, disp)
                local z = rshift(x, disp)

                if x >= 2147483648 then
                    z = z + lshift(2 ^ disp - 1, 32 - disp)
                end

                return z
            end

            local arshift = M.arshift

            function M.btest(x, y)
                return band(x, y) ~= 0
            end

            M.bit32 = {}

            local function bit32_bnot(x)
                return (-1 - x) % MOD
            end

            M.bit32.bnot = bit32_bnot

            local function bit32_bxor(a, b, c, ...)
                local z

                if b then
                    a = a % MOD
                    b = b % MOD
                    z = bxor(a, b)

                    if c then
                        z = bit32_bxor(z, c, ...)
                    end

                    return z
                elseif a then
                    return a % MOD
                else
                    return 0
                end
            end

            M.bit32.bxor = bit32_bxor

            local function bit32_band(a, b, c, ...)
                local z

                if b then
                    a = a % MOD
                    b = b % MOD
                    z = ((a + b) - bxor(a, b)) / 2

                    if c then
                        z = bit32_band(z, c, ...)
                    end

                    return z
                elseif a then
                    return a % MOD
                else
                    return MODM
                end
            end

            M.bit32.band = bit32_band

            local function bit32_bor(a, b, c, ...)
                local z

                if b then
                    a = a % MOD
                    b = b % MOD
                    z = MODM - band(MODM - a, MODM - b)

                    if c then
                        z = bit32_bor(z, c, ...)
                    end

                    return z
                elseif a then
                    return a % MOD
                else
                    return 0
                end
            end

            M.bit32.bor = bit32_bor

            function M.bit32.btest(...)
                return bit32_band(...) ~= 0
            end
            function M.bit32.lrotate(x, disp)
                return lrotate(x % MOD, disp)
            end
            function M.bit32.rrotate(x, disp)
                return rrotate(x % MOD, disp)
            end
            function M.bit32.lshift(x, disp)
                if disp > 31 or disp < -31 then
                    return 0
                end

                return lshift(x % MOD, disp)
            end
            function M.bit32.rshift(x, disp)
                if disp > 31 or disp < -31 then
                    return 0
                end

                return rshift(x % MOD, disp)
            end
            function M.bit32.arshift(x, disp)
                x = x % MOD

                if disp >= 0 then
                    if disp > 31 then
                        return (x >= 2147483648) and MODM or 0
                    else
                        local z = rshift(x, disp)

                        if x >= 2147483648 then
                            z = z + lshift(2 ^ disp - 1, 32 - disp)
                        end

                        return z
                    end
                else
                    return lshift(x, -disp)
                end
            end
            function M.bit32.extract(x, field, ...)
                local width = ... or 1

                if field < 0 or field > 31 or width < 0 or field + width > 32 then
                    error'out of range'
                end

                x = x % MOD

                return extract(x, field, ...)
            end
            function M.bit32.replace(x, v, field, ...)
                local width = ... or 1

                if field < 0 or field > 31 or width < 0 or field + width > 32 then
                    error'out of range'
                end

                x = x % MOD
                v = v % MOD

                return replace(x, v, field, ...)
            end

            M.bit = {}

            function M.bit.tobit(x)
                x = x % MOD

                if x >= 2147483648 then
                    x = x - MOD
                end

                return x
            end

            local bit_tobit = M.bit.tobit

            function M.bit.tohex(x, ...)
                return tohex(x % MOD, ...)
            end
            function M.bit.bnot(x)
                return bit_tobit(bnot(x % MOD))
            end

            local function bit_bor(a, b, c, ...)
                if c then
                    return bit_bor(bit_bor(a, b), c, ...)
                elseif b then
                    return bit_tobit(bor(a % MOD, b % MOD))
                else
                    return bit_tobit(a)
                end
            end

            M.bit.bor = bit_bor

            local function bit_band(a, b, c, ...)
                if c then
                    return bit_band(bit_band(a, b), c, ...)
                elseif b then
                    return bit_tobit(band(a % MOD, b % MOD))
                else
                    return bit_tobit(a)
                end
            end

            M.bit.band = bit_band

            local function bit_bxor(a, b, c, ...)
                if c then
                    return bit_bxor(bit_bxor(a, b), c, ...)
                elseif b then
                    return bit_tobit(bxor(a % MOD, b % MOD))
                else
                    return bit_tobit(a)
                end
            end

            M.bit.bxor = bit_bxor

            function M.bit.lshift(x, n)
                return bit_tobit(lshift(x % MOD, n % 32))
            end
            function M.bit.rshift(x, n)
                return bit_tobit(rshift(x % MOD, n % 32))
            end
            function M.bit.arshift(x, n)
                return bit_tobit(arshift(x % MOD, n % 32))
            end
            function M.bit.rol(x, n)
                return bit_tobit(lrotate(x % MOD, n % 32))
            end
            function M.bit.ror(x, n)
                return bit_tobit(rrotate(x % MOD, n % 32))
            end
            function M.bit.bswap(x)
                return bit_tobit(bswap(x % MOD))
            end

            return M
        end

        function __DARKLUA_BUNDLE_MODULES.e()
            local v = __DARKLUA_BUNDLE_MODULES.cache.e

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.e = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local logger, bit32, MAX_UNPACK_COUNT = __DARKLUA_BUNDLE_MODULES.d(), __DARKLUA_BUNDLE_MODULES.e().bit32, 195

            local function lookupify(tb)
                local tb2 = {}

                for _, v in ipairs(tb)do
                    tb2[v] = true
                end

                return tb2
            end
            local function unlookupify(tb)
                local tb2 = {}

                for v, _ in pairs(tb)do
                    table.insert(tb2, v)
                end

                return tb2
            end
            local function escape(str)
                return str.gsub(str, '.', function(char)
                    if char.match(char, '[^ %-~\n\t\a\b\v\r"\']') then
                        return string.format('\\%03d', string.byte(char))
                    end
                    if (char == '\\') then
                        return '\\\\'
                    end
                    if (char == '\n') then
                        return '\\n'
                    end
                    if (char == '\r') then
                        return '\\r'
                    end
                    if (char == '\t') then
                        return '\\t'
                    end
                    if (char == '\a') then
                        return '\\a'
                    end
                    if (char == '\b') then
                        return '\\b'
                    end
                    if (char == '\v') then
                        return '\\v'
                    end
                    if (char == '"') then
                        return '\\"'
                    end
                    if (char == "'") then
                        return "\\'"
                    end

                    return char
                end)
            end
            local function chararray(str)
                local tb = {}

                for i = 1, str.len(str), 1 do
                    table.insert(tb, str.sub(str, i, i))
                end

                return tb
            end
            local function keys(tb)
                local keyset, n = {}, 0

                for k, v in pairs(tb)do
                    n = n + 1
                    keyset[n] = k
                end

                return keyset
            end

            local utf8char

            do
                local string_char = string.char

                function utf8char(cp)
                    if cp < 128 then
                        return string_char(cp)
                    end

                    local suffix = cp % 64
                    local c4 = 128 + suffix

                    cp = (cp - suffix) / 64

                    if cp < 32 then
                        return string_char(192 + cp, c4)
                    end

                    suffix = cp % 64

                    local c3 = 128 + suffix

                    cp = (cp - suffix) / 64

                    if cp < 16 then
                        return string_char(224 + cp, c3, c4)
                    end

                    suffix = cp % 64
                    cp = (cp - suffix) / 64

                    return string_char(240 + cp, 128 + suffix, c3, c4)
                end
            end

            local function shuffle(tb)
                for i = #tb, 2, -1 do
                    local j = math.random(i)

                    tb[i], tb[j] = tb[j], tb[i]
                end

                return tb
            end
            local function shuffle_string(str)
                local len, t = #str, {}

                for i = 1, len do
                    t[i] = string.sub(str, i, i)
                end
                for i = 1, len do
                    local j = math.random(i, len)

                    t[i], t[j] = t[j], t[i]
                end

                return table.concat(t)
            end
            local function readDouble(bytes)
                local sign, mantissa = 1, bytes[2] % 16

                for i = 3, 8 do
                    mantissa = mantissa * 256 + bytes[i]
                end

                if bytes[1] > 127 then
                    sign = -1
                end

                local exponent = (bytes[1] % 128) * 16 + math.floor(bytes[2] / 16)

                if exponent == 0 then
                    return 0
                end

                mantissa = (math.ldexp(mantissa, -52) + 1) * sign

                return math.ldexp(mantissa, exponent - 1023)
            end
            local function writeDouble(num)
                local bytes = {
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                }

                if num == 0 then
                    return bytes
                end

                local anum = math.abs(num)
                local mantissa, exponent = math.frexp(anum)

                exponent = exponent - 1
                mantissa = mantissa * 2 - 1

                local sign = num ~= anum and 128 or 0

                exponent = exponent + 1023
                bytes[1] = sign + math.floor(exponent / 16)
                mantissa = mantissa * 16

                local currentmantissa = math.floor(mantissa)

                mantissa = mantissa - currentmantissa
                bytes[2] = (exponent % 16) * 16 + currentmantissa

                for i = 3, 8 do
                    mantissa = mantissa * 256
                    currentmantissa = math.floor(mantissa)
                    mantissa = mantissa - currentmantissa
                    bytes[i] = currentmantissa
                end

                return bytes
            end
            local function writeU16(u16)
                if (u16 < 0 or u16 > 65535) then
                    logger.error(logger, string.format('u16 out of bounds: %d', u16))
                end

                local lower, upper = bit32.band(u16, 255), bit32.rshift(u16, 8)

                return {lower, upper}
            end
            local function readU16(arr)
                return bit32.bor(arr[1], bit32.lshift(arr[2], 8))
            end
            local function writeU24(u24)
                if (u24 < 0 or u24 > 16777215) then
                    logger.error(logger, string.format('u24 out of bounds: %d', u24))
                end

                local arr = {}

                for i = 0, 2 do
                    arr[i + 1] = bit32.band(bit32.rshift(u24, 8 * i), 255)
                end

                return arr
            end
            local function readU24(arr)
                local val = 0

                for i = 0, 2 do
                    val = bit32.bor(val, bit32.lshift(arr[i + 1], 8 * i))
                end

                return val
            end
            local function writeU32(u32)
                if (u32 < 0 or u32 > 4294967295) then
                    logger.error(logger, string.format('u32 out of bounds: %d', u32))
                end

                local arr = {}

                for i = 0, 3 do
                    arr[i + 1] = bit32.band(bit32.rshift(u32, 8 * i), 255)
                end

                return arr
            end
            local function readU32(arr)
                local val = 0

                for i = 0, 3 do
                    val = bit32.bor(val, bit32.lshift(arr[i + 1], 8 * i))
                end

                return val
            end
            local function bytesToString(arr)
                local length = arr.n or #arr

                if length < MAX_UNPACK_COUNT then
                    return string.char(table.unpack(arr))
                end

                local str, overflow = '', length % MAX_UNPACK_COUNT

                for i = 1, (#arr - overflow) / MAX_UNPACK_COUNT do
                    str = str .. string.char(table.unpack(arr, (i - 1) * MAX_UNPACK_COUNT + 1, i * MAX_UNPACK_COUNT))
                end

                return str .. (overflow > 0 and string.char(table.unpack(arr, length - overflow + 1, length)) or '')
            end
            local function isNaN(n)
                return type(n) == 'number' and n ~= n
            end
            local function isInt(n)
                return math.floor(n) == n
            end
            local function isU32(n)
                return n >= 0 and n <= 4294967295 and isInt(n)
            end
            local function toBits(num)
                local t, rest = {}, nil

                while num > 0 do
                    rest = math.fmod(num, 2)
                    t[#t + 1] = rest
                    num = (num - rest) / 2
                end

                return t
            end
            local function readonly(obj)
                local r = newproxy(true)

                getmetatable(r).__index = obj

                return r
            end

            return {
                lookupify = lookupify,
                unlookupify = unlookupify,
                escape = escape,
                chararray = chararray,
                keys = keys,
                shuffle = shuffle,
                shuffle_string = shuffle_string,
                readDouble = readDouble,
                writeDouble = writeDouble,
                readU16 = readU16,
                writeU16 = writeU16,
                readU32 = readU32,
                writeU32 = writeU32,
                readU24 = readU24,
                writeU24 = writeU24,
                isNaN = isNaN,
                isU32 = isU32,
                isInt = isInt,
                utf8char = utf8char,
                toBits = toBits,
                bytesToString = bytesToString,
                readonly = readonly,
            }
        end

        function __DARKLUA_BUNDLE_MODULES.f()
            local v = __DARKLUA_BUNDLE_MODULES.cache.f

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.f = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Enums, chararray = {}, __DARKLUA_BUNDLE_MODULES.f().chararray

            Enums.LuaVersion = {
                LuaU = 'LuaU',
                Lua51 = 'Lua51',
            }
            Enums.Conventions = {
                [Enums.LuaVersion.Lua51] = {
                    Keywords = {
                        'and',
                        'break',
                        'do',
                        'else',
                        'elseif',
                        'end',
                        'false',
                        'for',
                        'function',
                        'if',
                        'in',
                        'local',
                        'nil',
                        'not',
                        'or',
                        'repeat',
                        'return',
                        'then',
                        'true',
                        'until',
                        'while',
                    },
                    SymbolChars = chararray'+-*/%^#=~<>(){}[];:,.',
                    MaxSymbolLength = 3,
                    Symbols = {
                        '+',
                        '-',
                        '*',
                        '/',
                        '%',
                        '^',
                        '#',
                        '==',
                        '~=',
                        '<=',
                        '>=',
                        '<',
                        '>',
                        '=',
                        '(',
                        ')',
                        '{',
                        '}',
                        '[',
                        ']',
                        ';',
                        ':',
                        ',',
                        '.',
                        '..',
                        '...',
                    },
                    IdentChars = chararray
[[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789]],
                    NumberChars = chararray'0123456789',
                    HexNumberChars = chararray'0123456789abcdefABCDEF',
                    BinaryNumberChars = {
                        '0',
                        '1',
                    },
                    DecimalExponent = {
                        'e',
                        'E',
                    },
                    HexadecimalNums = {
                        'x',
                        'X',
                    },
                    BinaryNums = {
                        'b',
                        'B',
                    },
                    DecimalSeperators = false,
                    EscapeSequences = {
                        a = '\a',
                        b = '\b',
                        f = '\f',
                        n = '\n',
                        r = '\r',
                        t = '\t',
                        v = '\v',
                        ['\\'] = '\\',
                        ['"'] = '"',
                        ["'"] = "'",
                    },
                    NumericalEscapes = true,
                    EscapeZIgnoreNextWhitespace = true,
                    HexEscapes = true,
                    UnicodeEscapes = true,
                },
                [Enums.LuaVersion.LuaU] = {
                    Keywords = {
                        'and',
                        'break',
                        'do',
                        'else',
                        'elseif',
                        'continue',
                        'end',
                        'false',
                        'for',
                        'function',
                        'if',
                        'in',
                        'local',
                        'nil',
                        'not',
                        'or',
                        'repeat',
                        'return',
                        'then',
                        'true',
                        'until',
                        'while',
                    },
                    SymbolChars = chararray'+-*/%^#=~<>(){}[];:,.',
                    MaxSymbolLength = 3,
                    Symbols = {
                        '+',
                        '-',
                        '*',
                        '/',
                        '%',
                        '^',
                        '#',
                        '==',
                        '~=',
                        '<=',
                        '>=',
                        '<',
                        '>',
                        '=',
                        '+=',
                        '-=',
                        '/=',
                        '%=',
                        '^=',
                        '..=',
                        '*=',
                        '(',
                        ')',
                        '{',
                        '}',
                        '[',
                        ']',
                        ';',
                        ':',
                        ',',
                        '.',
                        '..',
                        '...',
                        '::',
                        '->',
                        '?',
                        '|',
                        '&',
                    },
                    IdentChars = chararray
[[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789]],
                    NumberChars = chararray'0123456789',
                    HexNumberChars = chararray'0123456789abcdefABCDEF',
                    BinaryNumberChars = {
                        '0',
                        '1',
                    },
                    DecimalExponent = {
                        'e',
                        'E',
                    },
                    HexadecimalNums = {
                        'x',
                        'X',
                    },
                    BinaryNums = {
                        'b',
                        'B',
                    },
                    DecimalSeperators = {
                        '_',
                    },
                    EscapeSequences = {
                        a = '\a',
                        b = '\b',
                        f = '\f',
                        n = '\n',
                        r = '\r',
                        t = '\t',
                        v = '\v',
                        ['\\'] = '\\',
                        ['"'] = '"',
                        ["'"] = "'",
                    },
                    NumericalEscapes = true,
                    EscapeZIgnoreNextWhitespace = true,
                    HexEscapes = true,
                    UnicodeEscapes = true,
                },
            }

            return Enums
        end

        function __DARKLUA_BUNDLE_MODULES.g()
            local v = __DARKLUA_BUNDLE_MODULES.cache.g

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.g = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Enums, util, logger, config = __DARKLUA_BUNDLE_MODULES.g(), __DARKLUA_BUNDLE_MODULES.f(), __DARKLUA_BUNDLE_MODULES.d(), __DARKLUA_BUNDLE_MODULES.a()
            local LuaVersion, lookupify, unlookupify, escape, chararray, keys, Tokenizer = Enums.LuaVersion, util.lookupify, util.unlookupify, util.escape, util.chararray, util.keys, {}

            Tokenizer.EOF_CHAR = '<EOF>'
            Tokenizer.WHITESPACE_CHARS = lookupify{
                ' ',
                '\t',
                '\n',
                '\r',
            }
            Tokenizer.ANNOTATION_CHARS = lookupify(chararray
[[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_]])
            Tokenizer.ANNOTATION_START_CHARS = lookupify(chararray'!@')
            Tokenizer.Conventions = Enums.Conventions
            Tokenizer.TokenKind = {
                Eof = 'Eof',
                Keyword = 'Keyword',
                Symbol = 'Symbol',
                Ident = 'Identifier',
                Number = 'Number',
                String = 'String',
            }
            Tokenizer.EOF_TOKEN = {
                kind = Tokenizer.TokenKind.Eof,
                value = '<EOF>',
                startPos = -1,
                endPos = -1,
                source = '<EOF>',
            }

            local function token(self, startPos, kind, value)
                local line, linePos = self.getPosition(self, self.index)
                local annotations = self.annotations

                self.annotations = {}

                return {
                    kind = kind,
                    value = value,
                    startPos = startPos,
                    endPos = self.index,
                    source = self.source:sub(startPos + 1, self.index),
                    line = line,
                    linePos = linePos,
                    annotations = annotations,
                }
            end
            local function generateError(self, message)
                local line, linePos = self.getPosition(self, self.index)

                return 'Lexing Error at Position ' .. tostring(line) .. ':' .. tostring(linePos) .. ', ' .. message
            end
            local function generateWarning(token, message)
                return 'Warning at Position ' .. tostring(token.line) .. ':' .. tostring(token.linePos) .. ', ' .. message
            end

            function Tokenizer.getPosition(self, i)
                local column = self.columnMap[i]

                if not column then
                    column = self.columnMap[#self.columnMap]
                end

                return column.id, column.charMap[i]
            end
            function Tokenizer.prepareGetPosition(self)
                local columnMap, column = {}, {
                    charMap = {},
                    id = 1,
                    length = 0,
                }

                for index = 1, self.length do
                    local character, columnLength = string.sub(self.source, index, index), column.length + 1

                    column.length = columnLength
                    column.charMap[index] = columnLength

                    if character == '\n' then
                        column = {
                            charMap = {},
                            id = column.id + 1,
                            length = 0,
                        }
                    end

                    columnMap[index] = column
                end

                self.columnMap = columnMap
            end
            function Tokenizer.new(self, settings)
                local luaVersion = (settings and (settings.luaVersion or settings.LuaVersion)) or LuaVersion.LuaU
                local conventions = Tokenizer.Conventions[luaVersion]

                if (conventions == nil) then
                    logger.error(logger, 'The Lua Version "' .. luaVersion .. 
[[" is not recognised by the Tokenizer! Please use one of the following: "]] .. table.concat(keys(Tokenizer.Conventions), '","') .. '"')
                end

                local tokenizer = {
                    index = 0,
                    length = 0,
                    source = '',
                    luaVersion = luaVersion,
                    conventions = conventions,
                    NumberChars = conventions.NumberChars,
                    NumberCharsLookup = lookupify(conventions.NumberChars),
                    Keywords = conventions.Keywords,
                    KeywordsLookup = lookupify(conventions.Keywords),
                    BinaryNumberChars = conventions.BinaryNumberChars,
                    BinaryNumberCharsLookup = lookupify(conventions.BinaryNumberChars),
                    BinaryNums = conventions.BinaryNums,
                    HexadecimalNums = conventions.HexadecimalNums,
                    HexNumberChars = conventions.HexNumberChars,
                    HexNumberCharsLookup = lookupify(conventions.HexNumberChars),
                    DecimalExponent = conventions.DecimalExponent,
                    DecimalSeperators = conventions.DecimalSeperators,
                    IdentChars = conventions.IdentChars,
                    IdentCharsLookup = lookupify(conventions.IdentChars),
                    EscapeSequences = conventions.EscapeSequences,
                    NumericalEscapes = conventions.NumericalEscapes,
                    EscapeZIgnoreNextWhitespace = conventions.EscapeZIgnoreNextWhitespace,
                    HexEscapes = conventions.HexEscapes,
                    UnicodeEscapes = conventions.UnicodeEscapes,
                    SymbolChars = conventions.SymbolChars,
                    SymbolCharsLookup = lookupify(conventions.SymbolChars),
                    MaxSymbolLength = conventions.MaxSymbolLength,
                    Symbols = conventions.Symbols,
                    SymbolsLookup = lookupify(conventions.Symbols),
                    StringStartLookup = lookupify{
                        '"',
                        "'",
                    },
                    annotations = {},
                }

                setmetatable(tokenizer, self)

                self.__index = self

                return tokenizer
            end
            function Tokenizer.reset(self)
                self.index = 0
                self.length = 0
                self.source = ''
                self.annotations = {}
                self.columnMap = {}
            end
            function Tokenizer.append(self, code)
                self.source = self.source .. code
                self.length = self.length + code.len(code)

                self.prepareGetPosition(self)
            end

            local function peek(self, n)
                n = n or 0

                local i = self.index + n + 1

                if i > self.length then
                    return Tokenizer.EOF_CHAR
                end

                return self.source:sub(i, i)
            end
            local function get(self)
                local i = self.index + 1

                if i > self.length then
                    logger.error(logger, generateError(self, 'Unexpected end of Input'))
                end

                self.index = self.index + 1

                return self.source:sub(i, i)
            end
            local function expect(self, charOrLookup)
                if (type(charOrLookup) == 'string') then
                    charOrLookup = {[charOrLookup] = true}
                end

                local char = peek(self)

                if charOrLookup[char] ~= true then
                    local etb = unlookupify(charOrLookup)

                    for i, v in ipairs(etb)do
                        etb[i] = escape(v)
                    end

                    local errorMessage = 'Unexpected char "' .. escape(char) .. '"! Expected one of "' .. table.concat(etb, '","') .. '"'

                    logger.error(logger, generateError(self, errorMessage))
                end

                self.index = self.index + 1

                return char
            end
            local function is(self, charOrLookup, n)
                local char = peek(self, n)

                if (type(charOrLookup) == 'string') then
                    return char == charOrLookup
                end

                return charOrLookup[char]
            end

            function Tokenizer.parseAnnotation(self)
                if is(self, Tokenizer.ANNOTATION_START_CHARS) then
                    self.index = self.index + 1

                    local source, length = {}, 0

                    while(is(self, Tokenizer.ANNOTATION_CHARS)) do
                        source[length + 1] = get(self)
                        length = #source
                    end

                    if length > 0 then
                        self.annotations[string.lower(table.concat(source))] = true
                    end

                    return nil
                end

                return get(self)
            end
            function Tokenizer.skipComment(self)
                if (is(self, '-', 0) and is(self, '-', 1)) then
                    self.index = self.index + 2

                    if (is(self, '[')) then
                        self.index = self.index + 1

                        local eqCount = 0

                        while(is(self, '=')) do
                            self.index = self.index + 1
                            eqCount = eqCount + 1
                        end

                        if (is(self, '[')) then
                            while true do
                                if (self.parseAnnotation(self) == ']') then
                                    local eqCount2 = 0

                                    while(is(self, '=')) do
                                        self.index = self.index + 1
                                        eqCount2 = eqCount2 + 1
                                    end

                                    if (is(self, ']')) then
                                        if (eqCount2 == eqCount) then
                                            self.index = self.index + 1

                                            return true
                                        end
                                    end
                                end
                            end
                        end
                    end

                    while(self.index < self.length and self.parseAnnotation(self) ~= '\n') do end

                    return true
                end

                return false
            end
            function Tokenizer.skipWhitespaceAndComments(self)
                while self.skipComment(self) do end
                while is(self, Tokenizer.WHITESPACE_CHARS) do
                    self.index = self.index + 1

                    while self.skipComment(self) do end
                end
            end

            local function int(self, chars, seperators)
                local buffer = {}

                while true do
                    if (is(self, chars)) then
                        buffer[#buffer + 1] = get(self)
                    elseif (is(self, seperators)) then
                        self.index = self.index + 1
                    else
                        break
                    end
                end

                return table.concat(buffer)
            end

            function Tokenizer.number(self)
                local startPos, source = self.index, expect(self, setmetatable({
                    ['.'] = true,
                }, {
                    __index = self.NumberCharsLookup,
                }))

                if source == '0' then
                    if self.BinaryNums and is(self, lookupify(self.BinaryNums)) then
                        self.index = self.index + 1
                        source = int(self, self.BinaryNumberCharsLookup, lookupify(self.DecimalSeperators or {}))

                        local value = tonumber(source, 2)

                        return token(self, startPos, Tokenizer.TokenKind.Number, value)
                    end
                    if self.HexadecimalNums and is(self, lookupify(self.HexadecimalNums)) then
                        self.index = self.index + 1
                        source = int(self, self.HexNumberCharsLookup, lookupify(self.DecimalSeperators or {}))

                        local value = tonumber(source, 16)

                        return token(self, startPos, Tokenizer.TokenKind.Number, value)
                    end
                end
                if source == '.' then
                    source = source .. int(self, self.NumberCharsLookup, lookupify(self.DecimalSeperators or {}))
                else
                    source = source .. int(self, self.NumberCharsLookup, lookupify(self.DecimalSeperators or {}))

                    if (is(self, '.')) then
                        source = source .. get(self) .. int(self, self.NumberCharsLookup, lookupify(self.DecimalSeperators or {}))
                    end
                end
                if (self.DecimalExponent and is(self, lookupify(self.DecimalExponent))) then
                    source = source .. get(self)

                    if (is(self, lookupify{
                        '+',
                        '-',
                    })) then
                        source = source .. get(self)
                    end

                    local v = int(self, self.NumberCharsLookup, lookupify(self.DecimalSeperators or {}))

                    if (v.len(v) < 1) then
                        logger.error(logger, generateError(self, 'Expected a Valid Exponent!'))
                    end

                    source = source .. v
                end

                local value = tonumber(source)

                return token(self, startPos, Tokenizer.TokenKind.Number, value)
            end
            function Tokenizer.ident(self)
                local startPos, source = self.index, expect(self, self.IdentCharsLookup)
                local sourceAddContent = {source}

                while(is(self, self.IdentCharsLookup)) do
                    table.insert(sourceAddContent, get(self))
                end

                source = table.concat(sourceAddContent)

                if (self.KeywordsLookup[source]) then
                    return token(self, startPos, Tokenizer.TokenKind.Keyword, source)
                end

                local tk = token(self, startPos, Tokenizer.TokenKind.Ident, source)

                if (string.sub(source, 1, string.len(config.IdentPrefix)) == config.IdentPrefix) then
                    logger.warn(logger, generateWarning(tk, string.format(
[[identifiers should not start with "%s" as this may break the program]], config.IdentPrefix)))
                end

                return tk
            end
            function Tokenizer.singleLineString(self)
                local startPos, startChar, buffer = self.index, expect(self, self.StringStartLookup), {}

                while(not is(self, startChar)) do
                    local char = get(self)

                    if (char == '\n') then
                        self.index = self.index - 1

                        logger.error(logger, generateError(self, 'Unterminated String'))
                    end
                    if (char == '\\') then
                        char = get(self)

                        local escape = self.EscapeSequences[char]

                        if (type(escape) == 'string') then
                            char = escape
                        elseif (self.NumericalEscapes and self.NumberCharsLookup[char]) then
                            local numstr = char

                            if (is(self, self.NumberCharsLookup)) then
                                char = get(self)
                                numstr = numstr .. char
                            end
                            if (is(self, self.NumberCharsLookup)) then
                                char = get(self)
                                numstr = numstr .. char
                            end

                            char = string.char(tonumber(numstr))
                        elseif (self.UnicodeEscapes and char == 'u') then
                            expect(self, '{')

                            local num = ''

                            while(is(self, self.HexNumberCharsLookup)) do
                                num = num .. get(self)
                            end

                            expect(self, '}')

                            char = util.utf8char(tonumber(num, 16))
                        elseif (self.HexEscapes and char == 'x') then
                            local hex = expect(self, self.HexNumberCharsLookup) .. expect(self, self.HexNumberCharsLookup)

                            char = string.char(tonumber(hex, 16))
                        elseif (self.EscapeZIgnoreNextWhitespace and char == 'z') then
                            char = ''

                            while(is(self, Tokenizer.WHITESPACE_CHARS)) do
                                self.index = self.index + 1
                            end
                        end
                    end

                    buffer[#buffer + 1] = char
                end

                expect(self, startChar)

                return token(self, startPos, Tokenizer.TokenKind.String, table.concat(buffer))
            end
            function Tokenizer.multiLineString(self)
                local startPos = self.index

                if (is(self, '[')) then
                    self.index = self.index + 1

                    local eqCount = 0

                    while(is(self, '=')) do
                        self.index = self.index + 1
                        eqCount = eqCount + 1
                    end

                    if (is(self, '[')) then
                        self.index = self.index + 1

                        if (is(self, '\n')) then
                            self.index = self.index + 1
                        end

                        local value = ''

                        while true do
                            local char = get(self)

                            if (char == ']') then
                                local eqCount2 = 0

                                while(is(self, '=')) do
                                    char = char .. get(self)
                                    eqCount2 = eqCount2 + 1
                                end

                                if (is(self, ']')) then
                                    if (eqCount2 == eqCount) then
                                        self.index = self.index + 1

                                        return token(self, startPos, Tokenizer.TokenKind.String, value), true
                                    end
                                end
                            end

                            value = value .. char
                        end
                    end
                end

                self.index = startPos

                return nil, false
            end
            function Tokenizer.symbol(self)
                local startPos = self.index

                for len = self.MaxSymbolLength, 1, -1 do
                    local str = self.source:sub(self.index + 1, self.index + len)

                    if self.SymbolsLookup[str] then
                        self.index = self.index + len

                        return token(self, startPos, Tokenizer.TokenKind.Symbol, str)
                    end
                end

                logger.error(logger, generateError(self, 'Unknown Symbol'))
            end
            function Tokenizer.next(self)
                self.skipWhitespaceAndComments(self)

                local startPos = self.index

                if startPos >= self.length then
                    return token(self, startPos, Tokenizer.TokenKind.Eof)
                end
                if (is(self, self.NumberCharsLookup)) then
                    return self.number(self)
                end
                if (is(self, self.IdentCharsLookup)) then
                    return self.ident(self)
                end
                if (is(self, self.StringStartLookup)) then
                    return self.singleLineString(self)
                end
                if (is(self, '[', 0)) then
                    local value, isString = self.multiLineString(self)

                    if isString then
                        return value
                    end
                end
                if (is(self, '.') and is(self, self.NumberCharsLookup, 1)) then
                    return self.number(self)
                end
                if (is(self, self.SymbolCharsLookup)) then
                    return self.symbol(self)
                end

                logger.error(logger, generateError(self, 'Unexpected char "' .. escape(peek(self)) .. '"!'))
            end
            function Tokenizer.scanAll(self)
                local tb = {}

                repeat
                    local token = self.next(self)

                    table.insert(tb, token)
                until token.kind == Tokenizer.TokenKind.Eof

                return tb
            end

            return Tokenizer
        end

        function __DARKLUA_BUNDLE_MODULES.h()
            local v = __DARKLUA_BUNDLE_MODULES.cache.h

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.h = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local logger, config, Scope, scopeI = __DARKLUA_BUNDLE_MODULES.d(), __DARKLUA_BUNDLE_MODULES.a(), {}, 0

            local function nextName()
                scopeI = scopeI + 1

                return 'local_scope_' .. tostring(scopeI)
            end
            local function generateWarning(token, message)
                return 'Warning at Position ' .. tostring(token.line) .. ':' .. tostring(token.linePos) .. ', ' .. message
            end

            function Scope.new(self, parentScope, name)
                local scope = {
                    isGlobal = false,
                    parentScope = parentScope,
                    variables = {},
                    referenceCounts = {},
                    variablesLookup = {},
                    variablesFromHigherScopes = {},
                    skipIdLookup = {},
                    name = name or nextName(),
                    children = {},
                    level = parentScope.level and (parentScope.level + 1) or 1,
                }

                setmetatable(scope, self)

                self.__index = self

                parentScope.addChild(parentScope, scope)

                return scope
            end
            function Scope.newGlobal(self)
                local scope = {
                    isGlobal = true,
                    parentScope = nil,
                    variables = {},
                    variablesLookup = {},
                    referenceCounts = {},
                    skipIdLookup = {},
                    name = 'global_scope',
                    children = {},
                    level = 0,
                }

                setmetatable(scope, self)

                self.__index = self

                return scope
            end
            function Scope.getParent(self, parentScope)
                return self.parentScope
            end
            function Scope.setParent(self, parentScope)
                self.parentScope:removeChild(self)
                parentScope.addChild(parentScope, self)

                self.parentScope = parentScope
                self.level = parentScope.level + 1
            end

            local next_name_i = 1

            function Scope.addVariable(self, name, token)
                if (not name) then
                    name = string.format('%s%i', config.IdentPrefix, next_name_i)
                    next_name_i = next_name_i + 1
                end
                if self.variablesLookup[name] ~= nil then
                    if (token) then
                        logger.warn(logger, generateWarning(token, 'the variable "' .. name .. '" is already defined in that scope'))
                    else
                        logger.error(logger, string.format(
[[A variable with the name "%s" was already defined, you should have no variables starting with "%s"]], name, config.IdentPrefix))
                    end
                end

                table.insert(self.variables, name)

                local id = #self.variables

                self.variablesLookup[name] = id

                return id
            end
            function Scope.enableVariable(self, id)
                local name = self.variables[id]

                self.variablesLookup[name] = id
            end
            function Scope.addDisabledVariable(self, name, token)
                if (not name) then
                    name = string.format('%s%i', config.IdentPrefix, next_name_i)
                    next_name_i = next_name_i + 1
                end
                if self.variablesLookup[name] ~= nil then
                    if (token) then
                        logger.warn(logger, generateWarning(token, 'the variable "' .. name .. '" is already defined in that scope'))
                    else
                        logger.warn(logger, string.format('a variable with the name "%s" was already defined', name))
                    end
                end

                table.insert(self.variables, name)

                local id = #self.variables

                return id
            end
            function Scope.addIfNotExists(self, id)
                if (not self.variables[id]) then
                    local name = string.format('%s%i', config.IdentPrefix, next_name_i)

                    next_name_i = next_name_i + 1
                    self.variables[id] = name
                    self.variablesLookup[name] = id
                end

                return id
            end
            function Scope.hasVariable(self, name)
                if (self.isGlobal) then
                    if self.variablesLookup[name] == nil then
                        self.addVariable(self, name)
                    end

                    return true
                end

                return self.variablesLookup[name] ~= nil
            end
            function Scope.getVariables(self)
                return self.variables
            end
            function Scope.resetReferences(self, id)
                self.referenceCounts[id] = 0
            end
            function Scope.getReferences(self, id)
                return self.referenceCounts[id] or 0
            end
            function Scope.removeReference(self, id)
                self.referenceCounts[id] = (self.referenceCounts[id] or 0) - 1
            end
            function Scope.addReference(self, id)
                self.referenceCounts[id] = (self.referenceCounts[id] or 0) + 1
            end
            function Scope.resolve(self, name)
                if (self.hasVariable(self, name)) then
                    return self, self.variablesLookup[name]
                end

                assert(self.parentScope, 
[[No Global Variable Scope was Created! This should not be Possible!]])

                local scope, id = self.parentScope:resolve(name)

                self.addReferenceToHigherScope(self, scope, id, nil, true)

                return scope, id
            end
            function Scope.resolveGlobal(self, name)
                if (self.isGlobal and self.hasVariable(self, name)) then
                    return self, self.variablesLookup[name]
                end

                assert(self.parentScope, 
[[No Global Variable Scope was Created! This should not be Possible!]])

                local scope, id = self.parentScope:resolveGlobal(name)

                self.addReferenceToHigherScope(self, scope, id, nil, true)

                return scope, id
            end
            function Scope.getVariableName(self, id)
                return self.variables[id]
            end
            function Scope.removeVariable(self, id)
                local name = self.variables[id]

                self.variables[id] = nil
                self.variablesLookup[name] = nil
                self.skipIdLookup[id] = true
            end
            function Scope.addChild(self, scope)
                for scope, ids in pairs(scope.variablesFromHigherScopes)do
                    for id, count in pairs(ids)do
                        if count and count > 0 then
                            self.addReferenceToHigherScope(self, scope, id, count)
                        end
                    end
                end

                table.insert(self.children, scope)
            end
            function Scope.clearReferences(self)
                self.referenceCounts = {}
                self.variablesFromHigherScopes = {}
            end
            function Scope.removeChild(self, child)
                for i, v in ipairs(self.children)do
                    if (v == child) then
                        for scope, ids in pairs(v.variablesFromHigherScopes)do
                            for id, count in pairs(ids)do
                                if count and count > 0 then
                                    self.removeReferenceToHigherScope(self, scope, id, count)
                                end
                            end
                        end

                        return table.remove(self.children, i)
                    end
                end
            end
            function Scope.getMaxId(self)
                return #self.variables
            end
            function Scope.addReferenceToHigherScope(self, scope, id, n, b)
                n = n or 1

                if self.isGlobal then
                    if not scope.isGlobal then
                        logger.error(logger, string.format('Could not resolve Scope "%s"', scope.name))
                    end

                    return
                end
                if scope == self then
                    self.referenceCounts[id] = (self.referenceCounts[id] or 0) + n

                    return
                end
                if not self.variablesFromHigherScopes[scope] then
                    self.variablesFromHigherScopes[scope] = {}
                end

                local scopeReferences = self.variablesFromHigherScopes[scope]

                if scopeReferences[id] then
                    scopeReferences[id] = scopeReferences[id] + n
                else
                    scopeReferences[id] = n
                end
                if not b then
                    self.parentScope:addReferenceToHigherScope(scope, id, n)
                end
            end
            function Scope.removeReferenceToHigherScope(self, scope, id, n, b)
                n = n or 1

                if self.isGlobal then
                    return
                end
                if scope == self then
                    self.referenceCounts[id] = (self.referenceCounts[id] or 0) - n

                    return
                end
                if not self.variablesFromHigherScopes[scope] then
                    self.variablesFromHigherScopes[scope] = {}
                end

                local scopeReferences = self.variablesFromHigherScopes[scope]

                if scopeReferences[id] then
                    scopeReferences[id] = scopeReferences[id] - n
                else
                    scopeReferences[id] = 0
                end
                if not b then
                    self.parentScope:removeReferenceToHigherScope(scope, id, n)
                end
            end
            function Scope.renameVariables(self, settings)
                if (not self.isGlobal) then
                    local prefix, forbiddenNamesLookup = settings.prefix or '', {}

                    for _, keyword in pairs(settings.Keywords)do
                        forbiddenNamesLookup[keyword] = true
                    end
                    for scope, ids in pairs(self.variablesFromHigherScopes)do
                        for id, count in pairs(ids)do
                            if count and count > 0 then
                                local name = scope.getVariableName(scope, id)

                                forbiddenNamesLookup[name] = true
                            end
                        end
                    end

                    self.variablesLookup = {}

                    local i = 0

                    for id, originalName in pairs(self.variables)do
                        if (not self.skipIdLookup[id] and (self.referenceCounts[id] or 0) >= 0) then
                            local name

                            repeat
                                name = prefix .. settings.generateName(i, self, originalName)

                                if name == nil then
                                    name = originalName
                                end

                                i = i + 1
                            until not forbiddenNamesLookup[name]

                            self.variables[id] = name
                            self.variablesLookup[name] = id
                        end
                    end
                end

                for _, scope in pairs(self.children)do
                    scope.renameVariables(scope, settings)
                end
            end

            return Scope
        end

        function __DARKLUA_BUNDLE_MODULES.i()
            local v = __DARKLUA_BUNDLE_MODULES.cache.i

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.i = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Tokenizer, Enums, util, Ast, Scope, logger = __DARKLUA_BUNDLE_MODULES.h(), __DARKLUA_BUNDLE_MODULES.g(), __DARKLUA_BUNDLE_MODULES.f(), __DARKLUA_BUNDLE_MODULES.b(), __DARKLUA_BUNDLE_MODULES.i(), __DARKLUA_BUNDLE_MODULES.d()
            local AstKind, LuaVersion, lookupify, unlookupify, escape, chararray, keys, TokenKind, Parser = Ast.AstKind, Enums.LuaVersion, util.lookupify, util.unlookupify, util.escape, util.chararray, util.keys, Tokenizer.TokenKind, {}
            local ASSIGNMENT_NO_WARN_LOOKUP = lookupify{
                AstKind.NilExpression,
                AstKind.FunctionCallExpression,
                AstKind.PassSelfFunctionCallExpression,
                AstKind.VarargExpression,
            }

            local function generateError(self, message)
                local token

                if (self.index > self.length) then
                    token = self.tokens[self.length]
                elseif (self.index < 1) then
                    return 'Parsing Error at Position 0:0, ' .. message
                else
                    token = self.tokens[self.index]
                end

                return 'Parsing Error at Position ' .. tostring(token.line) .. ':' .. tostring(token.linePos) .. ', ' .. message
            end
            local function generateWarning(token, message)
                return 'Warning at Position ' .. tostring(token.line) .. ':' .. tostring(token.linePos) .. ', ' .. message
            end

            function Parser.new(self, settings)
                local luaVersion = (settings and (settings.luaVersion or settings.LuaVersion)) or LuaVersion.LuaU
                local parser = {
                    luaVersion = luaVersion,
                    tokenizer = Tokenizer.new(Tokenizer, {luaVersion = luaVersion}),
                    tokens = {},
                    length = 0,
                    index = 0,
                }

                setmetatable(parser, self)

                self.__index = self

                return parser
            end

            local function peek(self, n)
                n = n or 0

                local i = self.index + n + 1

                if i > self.length then
                    return Tokenizer.EOF_TOKEN
                end

                return self.tokens[i]
            end
            local function get(self)
                local i = self.index + 1

                if i > self.length then
                    error(generateError(self, 'Unexpected end of Input'))
                end

                self.index = self.index + 1

                local tk = self.tokens[i]

                return tk
            end
            local function is(self, kind, sourceOrN, n)
                local token, source = peek(self, n), nil

                if (type(sourceOrN) == 'string') then
                    source = sourceOrN
                else
                    n = sourceOrN
                end

                n = n or 0

                if (token.kind == kind) then
                    if (source == nil or token.source == source) then
                        return true
                    end
                end

                return false
            end
            local function consume(self, kind, source)
                if (is(self, kind, source)) then
                    self.index = self.index + 1

                    return true
                end

                return false
            end
            local function expect(self, kind, source)
                if (is(self, kind, source, 0)) then
                    return get(self)
                end

                local token = peek(self)

                if self.disableLog then
                    error()
                end
                if (source) then
                    logger.error(logger, generateError(self, string.format('unexpected token <%s> "%s", expected <%s> "%s"', token.kind, token.source, kind, source)))
                else
                    logger.error(logger, generateError(self, string.format('unexpected token <%s> "%s", expected <%s>', token.kind, token.source, kind)))
                end
            end

            function Parser.parse(self, code)
                self.tokenizer:append(code)

                self.tokens = self.tokenizer:scanAll()
                self.length = #self.tokens

                local globalScope = Scope.newGlobal(Scope)
                local ast = Ast.TopNode(self.block(self, globalScope, false), globalScope)

                expect(self, TokenKind.Eof)
                logger.debug(logger, 'Cleaning up Parser for next Use ...')
                self.tokenizer:reset()

                self.tokens = {}
                self.index = 0
                self.length = 0

                logger.debug(logger, 'Cleanup Done')

                return ast
            end
            function Parser.block(self, parentScope, currentLoop, scope)
                scope = scope or Scope.new(Scope, parentScope)

                local statements = {}

                repeat
                    local statement, isTerminatingStatement = self.statement(self, scope, currentLoop)

                    table.insert(statements, statement)
                until isTerminatingStatement or not statement

                consume(self, TokenKind.Symbol, ';')

                return Ast.Block(statements, scope)
            end
            function Parser.statement(self, scope, currentLoop)
                while(consume(self, TokenKind.Symbol, ';')) do end

                if (consume(self, TokenKind.Keyword, 'break')) then
                    if (not currentLoop) then
                        if self.disableLog then
                            error()
                        end

                        logger.error(logger, generateError(self, 'the break Statement is only valid inside of loops'))
                    end

                    return Ast.BreakStatement(currentLoop, scope), true
                end
                if (self.luaVersion == LuaVersion.LuaU and consume(self, TokenKind.Keyword, 'continue')) then
                    if (not currentLoop) then
                        if self.disableLog then
                            error()
                        end

                        logger.error(logger, generateError(self, 'the continue Statement is only valid inside of loops'))
                    end

                    return Ast.ContinueStatement(currentLoop, scope), true
                end
                if (consume(self, TokenKind.Keyword, 'do')) then
                    local body = self.block(self, scope, currentLoop)

                    expect(self, TokenKind.Keyword, 'end')

                    return Ast.DoStatement(body)
                end
                if (consume(self, TokenKind.Keyword, 'while')) then
                    local condition = self.expression(self, scope)

                    expect(self, TokenKind.Keyword, 'do')

                    local stat = Ast.WhileStatement(nil, condition, scope)

                    stat.body = self.block(self, scope, stat)

                    expect(self, TokenKind.Keyword, 'end')

                    return stat
                end
                if (consume(self, TokenKind.Keyword, 'repeat')) then
                    local repeatScope, stat = Scope.new(Scope, scope), Ast.RepeatStatement(nil, nil, scope)

                    stat.body = self.block(self, nil, stat, repeatScope)

                    expect(self, TokenKind.Keyword, 'until')

                    stat.condition = self.expression(self, repeatScope)

                    return stat
                end
                if (consume(self, TokenKind.Keyword, 'return')) then
                    local args = {}

                    if (not is(self, TokenKind.Keyword, 'end') and not is(self, TokenKind.Keyword, 'elseif') and not is(self, TokenKind.Keyword, 'else') and not is(self, TokenKind.Symbol, ';') and not is(self, TokenKind.Eof)) then
                        args = self.exprList(self, scope)
                    end

                    return Ast.ReturnStatement(args), true
                end
                if (consume(self, TokenKind.Keyword, 'if')) then
                    local condition = self.expression(self, scope)

                    expect(self, TokenKind.Keyword, 'then')

                    local body, elseifs = self.block(self, scope, currentLoop), {}

                    while(consume(self, TokenKind.Keyword, 'elseif')) do
                        local condition = self.expression(self, scope)

                        expect(self, TokenKind.Keyword, 'then')

                        local body = self.block(self, scope, currentLoop)

                        table.insert(elseifs, {
                            condition = condition,
                            body = body,
                        })
                    end

                    local elsebody

                    if (consume(self, TokenKind.Keyword, 'else')) then
                        elsebody = self.block(self, scope, currentLoop)
                    end

                    expect(self, TokenKind.Keyword, 'end')

                    return Ast.IfStatement(condition, body, elseifs, elsebody)
                end
                if (consume(self, TokenKind.Keyword, 'function')) then
                    local obj = self.funcName(self, scope)
                    local baseScope, baseId, indices, funcScope = obj.scope, obj.id, obj.indices, Scope.new(Scope, scope)

                    expect(self, TokenKind.Symbol, '(')

                    local args = self.functionArgList(self, funcScope)

                    expect(self, TokenKind.Symbol, ')')

                    if (obj.passSelf) then
                        local id = funcScope.addVariable(funcScope, 'self', obj.token)

                        table.insert(args, 1, Ast.VariableExpression(funcScope, id))
                    end

                    local body = self.block(self, nil, false, funcScope)

                    expect(self, TokenKind.Keyword, 'end')

                    return Ast.FunctionDeclaration(baseScope, baseId, indices, args, body)
                end
                if (consume(self, TokenKind.Keyword, 'local')) then
                    if (consume(self, TokenKind.Keyword, 'function')) then
                        local ident = expect(self, TokenKind.Ident)
                        local name = ident.value
                        local id, funcScope = scope.addVariable(scope, name, ident), Scope.new(Scope, scope)

                        expect(self, TokenKind.Symbol, '(')

                        local args = self.functionArgList(self, funcScope)

                        expect(self, TokenKind.Symbol, ')')

                        local body = self.block(self, nil, false, funcScope)

                        expect(self, TokenKind.Keyword, 'end')

                        return Ast.LocalFunctionDeclaration(scope, id, args, body)
                    end

                    local ids, expressions = self.nameList(self, scope), {}

                    if (consume(self, TokenKind.Symbol, '=')) then
                        expressions = self.exprList(self, scope)
                    end

                    self.enableNameList(self, scope, ids)

                    if (#expressions > #ids) then
                        logger.warn(logger, generateWarning(peek(self, -1), string.format('assigning %d values to %d variable' .. ((#ids > 1 and 's') or ''), #expressions, #ids)))
                    elseif (#ids > #expressions and #expressions > 0 and not ASSIGNMENT_NO_WARN_LOOKUP[expressions[#expressions].kind]) then
                        logger.warn(logger, generateWarning(peek(self, -1), string.format('assigning %d value' .. ((#expressions > 1 and 's') or '') .. 
[[ to %d variables initializes extra variables with nil, add a nil value to silence]], #expressions, #ids)))
                    end

                    return Ast.LocalVariableDeclaration(scope, ids, expressions)
                end
                if (consume(self, TokenKind.Keyword, 'for')) then
                    if (is(self, TokenKind.Symbol, '=', 1)) then
                        local forScope, ident = Scope.new(Scope, scope), expect(self, TokenKind.Ident)
                        local varId = forScope.addDisabledVariable(forScope, ident.value, ident)

                        expect(self, TokenKind.Symbol, '=')

                        local initialValue = self.expression(self, scope)

                        expect(self, TokenKind.Symbol, ',')

                        local finalValue, incrementBy = self.expression(self, scope), Ast.NumberExpression(1)

                        if (consume(self, TokenKind.Symbol, ',')) then
                            incrementBy = self.expression(self, scope)
                        end

                        local stat = Ast.ForStatement(forScope, varId, initialValue, finalValue, incrementBy, nil, scope)

                        forScope.enableVariable(forScope, varId)
                        expect(self, TokenKind.Keyword, 'do')

                        stat.body = self.block(self, nil, stat, forScope)

                        expect(self, TokenKind.Keyword, 'end')

                        return stat
                    end

                    local forScope = Scope.new(Scope, scope)
                    local ids = self.nameList(self, forScope)

                    expect(self, TokenKind.Keyword, 'in')

                    local expressions = self.exprList(self, scope)

                    self.enableNameList(self, forScope, ids)
                    expect(self, TokenKind.Keyword, 'do')

                    local stat = Ast.ForInStatement(forScope, ids, expressions, nil, scope)

                    stat.body = self.block(self, nil, stat, forScope)

                    expect(self, TokenKind.Keyword, 'end')

                    return stat
                end

                local expr = self.primaryExpression(self, scope)

                if expr then
                    if (expr.kind == AstKind.FunctionCallExpression) then
                        return Ast.FunctionCallStatement(expr.base, expr.args)
                    end
                    if (expr.kind == AstKind.PassSelfFunctionCallExpression) then
                        return Ast.PassSelfFunctionCallStatement(expr.base, expr.passSelfFunctionName, expr.args)
                    end
                    if (expr.kind == AstKind.IndexExpression or expr.kind == AstKind.VariableExpression) then
                        if (expr.kind == AstKind.IndexExpression) then
                            expr.kind = AstKind.AssignmentIndexing
                        end
                        if (expr.kind == AstKind.VariableExpression) then
                            expr.kind = AstKind.AssignmentVariable
                        end
                        if (self.luaVersion == LuaVersion.LuaU) then
                            if (consume(self, TokenKind.Symbol, '+=')) then
                                local rhs = self.expression(self, scope)

                                return Ast.CompoundAddStatement(expr, rhs)
                            end
                            if (consume(self, TokenKind.Symbol, '-=')) then
                                local rhs = self.expression(self, scope)

                                return Ast.CompoundSubStatement(expr, rhs)
                            end
                            if (consume(self, TokenKind.Symbol, '*=')) then
                                local rhs = self.expression(self, scope)

                                return Ast.CompoundMulStatement(expr, rhs)
                            end
                            if (consume(self, TokenKind.Symbol, '/=')) then
                                local rhs = self.expression(self, scope)

                                return Ast.CompoundDivStatement(expr, rhs)
                            end
                            if (consume(self, TokenKind.Symbol, '%=')) then
                                local rhs = self.expression(self, scope)

                                return Ast.CompoundModStatement(expr, rhs)
                            end
                            if (consume(self, TokenKind.Symbol, '^=')) then
                                local rhs = self.expression(self, scope)

                                return Ast.CompoundPowStatement(expr, rhs)
                            end
                            if (consume(self, TokenKind.Symbol, '..=')) then
                                local rhs = self.expression(self, scope)

                                return Ast.CompoundConcatStatement(expr, rhs)
                            end
                        end

                        local lhs = {expr}

                        while consume(self, TokenKind.Symbol, ',') do
                            expr = self.primaryExpression(self, scope)

                            if (not expr) then
                                if self.disableLog then
                                    error()
                                end

                                logger.error(logger, generateError(self, string.format'expected a valid assignment statement lhs part but got nil'))
                            end
                            if (expr.kind == AstKind.IndexExpression or expr.kind == AstKind.VariableExpression) then
                                if (expr.kind == AstKind.IndexExpression) then
                                    expr.kind = AstKind.AssignmentIndexing
                                end
                                if (expr.kind == AstKind.VariableExpression) then
                                    expr.kind = AstKind.AssignmentVariable
                                end

                                table.insert(lhs, expr)
                            else
                                if self.disableLog then
                                    error()
                                end

                                logger.error(logger, generateError(self, string.format('expected a valid assignment statement lhs part but got <%s>', expr.kind)))
                            end
                        end

                        expect(self, TokenKind.Symbol, '=')

                        local rhs = self.exprList(self, scope)

                        return Ast.AssignmentStatement(lhs, rhs)
                    end
                    if self.disableLog then
                        error()
                    end

                    logger.error(logger, generateError(self, 'expressions are not valid statements!'))
                end

                return nil
            end
            function Parser.primaryExpression(self, scope)
                local i, s = self.index, self

                self.disableLog = true

                local status, val = pcall(self.expressionFunctionCall, self, scope)

                self.disableLog = false

                if (status) then
                    return val
                else
                    self.index = i

                    return nil
                end
            end
            function Parser.exprList(self, scope)
                local expressions = {
                    self.expression(self, scope),
                }

                while(consume(self, TokenKind.Symbol, ',')) do
                    table.insert(expressions, self.expression(self, scope))
                end

                return expressions
            end
            function Parser.nameList(self, scope)
                local ids, ident = {}, expect(self, TokenKind.Ident)
                local id = scope.addDisabledVariable(scope, ident.value, ident)

                table.insert(ids, id)

                while(consume(self, TokenKind.Symbol, ',')) do
                    ident = expect(self, TokenKind.Ident)
                    id = scope.addDisabledVariable(scope, ident.value, ident)

                    table.insert(ids, id)
                end

                return ids
            end
            function Parser.enableNameList(self, scope, list)
                for i, id in ipairs(list)do
                    scope.enableVariable(scope, id)
                end
            end
            function Parser.funcName(self, scope)
                local ident = expect(self, TokenKind.Ident)
                local baseName = ident.value
                local baseScope, baseId = scope.resolve(scope, baseName)
                local indices, passSelf = {}, false

                while(consume(self, TokenKind.Symbol, '.')) do
                    table.insert(indices, expect(self, TokenKind.Ident).value)
                end

                if (consume(self, TokenKind.Symbol, ':')) then
                    table.insert(indices, expect(self, TokenKind.Ident).value)

                    passSelf = true
                end

                return {
                    scope = baseScope,
                    id = baseId,
                    indices = indices,
                    passSelf = passSelf,
                    token = ident,
                }
            end
            function Parser.expression(self, scope)
                return self.expressionOr(self, scope)
            end
            function Parser.expressionOr(self, scope)
                local lhs = self.expressionAnd(self, scope)

                if (consume(self, TokenKind.Keyword, 'or')) then
                    local rhs = self.expressionOr(self, scope)

                    return Ast.OrExpression(lhs, rhs, true)
                end

                return lhs
            end
            function Parser.expressionAnd(self, scope)
                local lhs = self.expressionComparision(self, scope)

                if (consume(self, TokenKind.Keyword, 'and')) then
                    local rhs = self.expressionAnd(self, scope)

                    return Ast.AndExpression(lhs, rhs, true)
                end

                return lhs
            end
            function Parser.expressionComparision(self, scope)
                local curr = self.expressionStrCat(self, scope)

                repeat
                    local found = false

                    if (consume(self, TokenKind.Symbol, '<')) then
                        local rhs = self.expressionStrCat(self, scope)

                        curr = Ast.LessThanExpression(curr, rhs, true)
                        found = true
                    end
                    if (consume(self, TokenKind.Symbol, '>')) then
                        local rhs = self.expressionStrCat(self, scope)

                        curr = Ast.GreaterThanExpression(curr, rhs, true)
                        found = true
                    end
                    if (consume(self, TokenKind.Symbol, '<=')) then
                        local rhs = self.expressionStrCat(self, scope)

                        curr = Ast.LessThanOrEqualsExpression(curr, rhs, true)
                        found = true
                    end
                    if (consume(self, TokenKind.Symbol, '>=')) then
                        local rhs = self.expressionStrCat(self, scope)

                        curr = Ast.GreaterThanOrEqualsExpression(curr, rhs, true)
                        found = true
                    end
                    if (consume(self, TokenKind.Symbol, '~=')) then
                        local rhs = self.expressionStrCat(self, scope)

                        curr = Ast.NotEqualsExpression(curr, rhs, true)
                        found = true
                    end
                    if (consume(self, TokenKind.Symbol, '==')) then
                        local rhs = self.expressionStrCat(self, scope)

                        curr = Ast.EqualsExpression(curr, rhs, true)
                        found = true
                    end
                until not found

                return curr
            end
            function Parser.expressionStrCat(self, scope)
                local lhs = self.expressionAddSub(self, scope)

                if (consume(self, TokenKind.Symbol, '..')) then
                    local rhs = self.expressionStrCat(self, scope)

                    return Ast.StrCatExpression(lhs, rhs, true)
                end

                return lhs
            end
            function Parser.expressionAddSub(self, scope)
                local curr = self.expressionMulDivMod(self, scope)

                repeat
                    local found = false

                    if (consume(self, TokenKind.Symbol, '+')) then
                        local rhs = self.expressionMulDivMod(self, scope)

                        curr = Ast.AddExpression(curr, rhs, true)
                        found = true
                    end
                    if (consume(self, TokenKind.Symbol, '-')) then
                        local rhs = self.expressionMulDivMod(self, scope)

                        curr = Ast.SubExpression(curr, rhs, true)
                        found = true
                    end
                until not found

                return curr
            end
            function Parser.expressionMulDivMod(self, scope)
                local curr = self.expressionUnary(self, scope)

                repeat
                    local found = false

                    if (consume(self, TokenKind.Symbol, '*')) then
                        local rhs = self.expressionUnary(self, scope)

                        curr = Ast.MulExpression(curr, rhs, true)
                        found = true
                    end
                    if (consume(self, TokenKind.Symbol, '/')) then
                        local rhs = self.expressionUnary(self, scope)

                        curr = Ast.DivExpression(curr, rhs, true)
                        found = true
                    end
                    if (consume(self, TokenKind.Symbol, '%')) then
                        local rhs = self.expressionUnary(self, scope)

                        curr = Ast.ModExpression(curr, rhs, true)
                        found = true
                    end
                until not found

                return curr
            end
            function Parser.expressionUnary(self, scope)
                if (consume(self, TokenKind.Keyword, 'not')) then
                    local rhs = self.expressionUnary(self, scope)

                    return Ast.NotExpression(rhs, true)
                end
                if (consume(self, TokenKind.Symbol, '#')) then
                    local rhs = self.expressionUnary(self, scope)

                    return Ast.LenExpression(rhs, true)
                end
                if (consume(self, TokenKind.Symbol, '-')) then
                    local rhs = self.expressionUnary(self, scope)

                    return Ast.NegateExpression(rhs, true)
                end

                return self.expressionPow(self, scope)
            end
            function Parser.expressionPow(self, scope)
                local lhs = self.tableOrFunctionLiteral(self, scope)

                if (consume(self, TokenKind.Symbol, '^')) then
                    local rhs = self.expressionPow(self, scope)

                    return Ast.PowExpression(lhs, rhs, true)
                end

                return lhs
            end
            function Parser.tableOrFunctionLiteral(self, scope)
                if (is(self, TokenKind.Symbol, '{')) then
                    return self.tableConstructor(self, scope)
                end
                if (is(self, TokenKind.Keyword, 'function')) then
                    return self.expressionFunctionLiteral(self, scope)
                end

                return self.expressionFunctionCall(self, scope)
            end
            function Parser.expressionFunctionLiteral(self, parentScope)
                local scope = Scope.new(Scope, parentScope)

                expect(self, TokenKind.Keyword, 'function')
                expect(self, TokenKind.Symbol, '(')

                local args = self.functionArgList(self, scope)

                expect(self, TokenKind.Symbol, ')')

                local body = self.block(self, nil, false, scope)

                expect(self, TokenKind.Keyword, 'end')

                return Ast.FunctionLiteralExpression(args, body)
            end
            function Parser.functionArgList(self, scope)
                local args = {}

                if (consume(self, TokenKind.Symbol, '...')) then
                    table.insert(args, Ast.VarargExpression())

                    return args
                end
                if (is(self, TokenKind.Ident)) then
                    local ident = get(self)
                    local name = ident.value
                    local id = scope.addVariable(scope, name, ident)

                    table.insert(args, Ast.VariableExpression(scope, id))

                    while(consume(self, TokenKind.Symbol, ',')) do
                        if (consume(self, TokenKind.Symbol, '...')) then
                            table.insert(args, Ast.VarargExpression())

                            return args
                        end

                        ident = get(self)
                        name = ident.value
                        id = scope.addVariable(scope, name, ident)

                        table.insert(args, Ast.VariableExpression(scope, id))
                    end
                end

                return args
            end
            function Parser.expressionFunctionCall(self, scope, base)
                base = base or self.expressionIndex(self, scope)

                local args = {}

                if (is(self, TokenKind.String)) then
                    args = {
                        Ast.StringExpression(get(self).value),
                    }
                elseif (is(self, TokenKind.Symbol, '{')) then
                    args = {
                        self.tableConstructor(self, scope),
                    }
                elseif (consume(self, TokenKind.Symbol, '(')) then
                    if (not is(self, TokenKind.Symbol, ')')) then
                        args = self.exprList(self, scope)
                    end

                    expect(self, TokenKind.Symbol, ')')
                else
                    return base
                end

                local node = Ast.FunctionCallExpression(base, args)

                if (is(self, TokenKind.Symbol, '.') or is(self, TokenKind.Symbol, '[') or is(self, TokenKind.Symbol, ':')) then
                    return self.expressionIndex(self, scope, node)
                end
                if (is(self, TokenKind.Symbol, '(') or is(self, TokenKind.Symbol, '{') or is(self, TokenKind.String)) then
                    return self.expressionFunctionCall(self, scope, node)
                end

                return node
            end
            function Parser.expressionIndex(self, scope, base)
                base = base or self.expressionLiteral(self, scope)

                while(consume(self, TokenKind.Symbol, '[')) do
                    local expr = self.expression(self, scope)

                    expect(self, TokenKind.Symbol, ']')

                    base = Ast.IndexExpression(base, expr)
                end
                while consume(self, TokenKind.Symbol, '.') do
                    local ident = expect(self, TokenKind.Ident)

                    base = Ast.IndexExpression(base, Ast.StringExpression(ident.value))

                    while(consume(self, TokenKind.Symbol, '[')) do
                        local expr = self.expression(self, scope)

                        expect(self, TokenKind.Symbol, ']')

                        base = Ast.IndexExpression(base, expr)
                    end
                end

                if (consume(self, TokenKind.Symbol, ':')) then
                    local passSelfFunctionName, args = expect(self, TokenKind.Ident).value, {}

                    if (is(self, TokenKind.String)) then
                        args = {
                            Ast.StringExpression(get(self).value),
                        }
                    elseif (is(self, TokenKind.Symbol, '{')) then
                        args = {
                            self.tableConstructor(self, scope),
                        }
                    else
                        expect(self, TokenKind.Symbol, '(')

                        if (not is(self, TokenKind.Symbol, ')')) then
                            args = self.exprList(self, scope)
                        end

                        expect(self, TokenKind.Symbol, ')')
                    end

                    local node = Ast.PassSelfFunctionCallExpression(base, passSelfFunctionName, args)

                    if (is(self, TokenKind.Symbol, '.') or is(self, TokenKind.Symbol, '[') or is(self, TokenKind.Symbol, ':')) then
                        return self.expressionIndex(self, scope, node)
                    end
                    if (is(self, TokenKind.Symbol, '(') or is(self, TokenKind.Symbol, '{') or is(self, TokenKind.String)) then
                        return self.expressionFunctionCall(self, scope, node)
                    end

                    return node
                end
                if (is(self, TokenKind.Symbol, '(') or is(self, TokenKind.Symbol, '{') or is(self, TokenKind.String)) then
                    return self.expressionFunctionCall(self, scope, base)
                end

                return base
            end
            function Parser.expressionLiteral(self, scope)
                if (consume(self, TokenKind.Symbol, '(')) then
                    local expr = self.expression(self, scope)

                    expect(self, TokenKind.Symbol, ')')

                    return expr
                end
                if (is(self, TokenKind.String)) then
                    return Ast.StringExpression(get(self).value)
                end
                if (is(self, TokenKind.Number)) then
                    return Ast.NumberExpression(get(self).value)
                end
                if (consume(self, TokenKind.Keyword, 'true')) then
                    return Ast.BooleanExpression(true)
                end
                if (consume(self, TokenKind.Keyword, 'false')) then
                    return Ast.BooleanExpression(false)
                end
                if (consume(self, TokenKind.Keyword, 'nil')) then
                    return Ast.NilExpression()
                end
                if (consume(self, TokenKind.Symbol, '...')) then
                    return Ast.VarargExpression()
                end
                if (is(self, TokenKind.Ident)) then
                    local ident = get(self)
                    local name = ident.value
                    local scope, id = scope.resolve(scope, name)

                    return Ast.VariableExpression(scope, id)
                end
                if (LuaVersion.LuaU) then
                    if (consume(self, TokenKind.Keyword, 'if')) then
                        local condition = self.expression(self, scope)

                        expect(self, TokenKind.Keyword, 'then')

                        local true_value = self.expression(self, scope)

                        expect(self, TokenKind.Keyword, 'else')

                        local false_value = self.expression(self, scope)

                        return Ast.IfElseExpression(condition, true_value, false_value)
                    end
                end
                if (self.disableLog) then
                    error()
                end

                logger.error(logger, generateError(self, 'Unexpected Token "' .. peek(self).source .. '". Expected a Expression!'))
            end
            function Parser.tableConstructor(self, scope)
                local entries = {}

                expect(self, TokenKind.Symbol, '{')

                while(not consume(self, TokenKind.Symbol, '}')) do
                    if (consume(self, TokenKind.Symbol, '[')) then
                        local key = self.expression(self, scope)

                        expect(self, TokenKind.Symbol, ']')
                        expect(self, TokenKind.Symbol, '=')

                        local value = self.expression(self, scope)

                        table.insert(entries, Ast.KeyedTableEntry(key, value))
                    elseif (is(self, TokenKind.Ident, 0) and is(self, TokenKind.Symbol, '=', 1)) then
                        local key = Ast.StringExpression(get(self).value)

                        expect(self, TokenKind.Symbol, '=')

                        local value = self.expression(self, scope)

                        table.insert(entries, Ast.KeyedTableEntry(key, value))
                    else
                        local value = self.expression(self, scope)

                        table.insert(entries, Ast.TableEntry(value))
                    end
                    if (not consume(self, TokenKind.Symbol, ';') and not consume(self, TokenKind.Symbol, ',') and not is(self, TokenKind.Symbol, '}')) then
                        if self.disableLog then
                            error()
                        end

                        logger.error(logger, generateError(self, 'expected a ";" or a ","'))
                    end
                end

                return Ast.TableConstructorExpression(entries)
            end

            return Parser
        end

        function __DARKLUA_BUNDLE_MODULES.j()
            local v = __DARKLUA_BUNDLE_MODULES.cache.j

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.j = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local config, Ast, Enums, util, logger = __DARKLUA_BUNDLE_MODULES.a(), __DARKLUA_BUNDLE_MODULES.b(), __DARKLUA_BUNDLE_MODULES.g(), __DARKLUA_BUNDLE_MODULES.f(), __DARKLUA_BUNDLE_MODULES.d()
            local lookupify, LuaVersion, AstKind, Unparser = util.lookupify, Enums.LuaVersion, Ast.AstKind, {}

            Unparser.SPACE = config.SPACE
            Unparser.TAB = config.TAB

            local function escapeString(str)
                str = util.escape(str)

                return str
            end

            function Unparser.new(self, settings)
                local luaVersion = settings.LuaVersion or LuaVersion.LuaU
                local conventions = Enums.Conventions[luaVersion]
                local unparser = {
                    luaVersion = luaVersion,
                    conventions = conventions,
                    identCharsLookup = lookupify(conventions.IdentChars),
                    numberCharsLookup = lookupify(conventions.NumberChars),
                    prettyPrint = settings and settings.PrettyPrint or false,
                    notIdentPattern = '[^' .. table.concat(conventions.IdentChars, '') .. ']',
                    numberPattern = '^[' .. table.concat(conventions.NumberChars, '') .. ']',
                    highlight = settings and settings.Highlight or false,
                    keywordsLookup = lookupify(conventions.Keywords),
                }

                setmetatable(unparser, self)

                self.__index = self

                return unparser
            end
            function Unparser.isValidIdentifier(self, source)
                if (string.find(source, self.notIdentPattern)) then
                    return false
                end
                if (string.find(source, self.numberPattern)) then
                    return false
                end
                if self.keywordsLookup[source] then
                    return false
                end

                return #source > 0
            end
            function Unparser.setPrettyPrint(self, prettyPrint)
                self.prettyPrint = prettyPrint
            end
            function Unparser.getPrettyPrint(self)
                return self.prettyPrint
            end
            function Unparser.tabs(self, i, ws_needed)
                return self.prettyPrint and string.rep(self.TAB, i) or ws_needed and self.SPACE or ''
            end
            function Unparser.newline(self, ws_needed)
                return self.prettyPrint and '\n' or ws_needed and self.SPACE or ''
            end
            function Unparser.whitespaceIfNeeded(self, following, ws)
                if (self.prettyPrint or self.identCharsLookup[string.sub(following, 1, 1)]) then
                    return ws or self.SPACE
                end

                return ''
            end
            function Unparser.whitespaceIfNeeded2(self, leading, ws)
                if (self.prettyPrint or self.identCharsLookup[string.sub(leading, #leading, #leading)]) then
                    return ws or self.SPACE
                end

                return ''
            end
            function Unparser.optionalWhitespace(self, ws)
                return self.prettyPrint and (ws or self.SPACE) or ''
            end
            function Unparser.whitespace(self, ws)
                return self.SPACE or ws
            end
            function Unparser.unparse(self, ast)
                if (ast.kind ~= AstKind.TopNode) then
                    logger.error(logger, 'Unparser:unparse expects a TopNode as first argument')
                end

                return self.unparseBlock(self, ast.body)
            end
            function Unparser.unparseBlock(self, block, tabbing)
                local code = ''

                if (#block.statements < 1) then
                    return self.whitespace(self)
                end

                for i, statement in ipairs(block.statements)do
                    if (statement.kind ~= AstKind.NopStatement) then
                        local statementCode = self.unparseStatement(self, statement, tabbing)

                        if (not self.prettyPrint and #code > 0 and string.sub(statementCode, 1, 1) == '(') then
                            statementCode = ';' .. statementCode
                        end

                        local ws = self.whitespaceIfNeeded2(self, code, self.whitespaceIfNeeded(self, statementCode, self.newline(self, true)))

                        if i ~= 1 then
                            code = code .. ws
                        end
                        if (self.prettyPrint) then
                            statementCode = statementCode .. ';'
                        end

                        code = code .. statementCode
                    end
                end

                return code
            end
            function Unparser.unparseStatement(self, statement, tabbing)
                tabbing = tabbing and tabbing + 1 or 0

                local code = ''

                if (statement.kind == AstKind.ContinueStatement) then
                    code = 'continue'
                elseif (statement.kind == AstKind.BreakStatement) then
                    code = 'break'
                elseif (statement.kind == AstKind.DoStatement) then
                    local bodyCode = self.unparseBlock(self, statement.body, tabbing)

                    code = 'do' .. self.whitespaceIfNeeded(self, bodyCode, self.newline(self, true)) .. bodyCode .. self.newline(self, false) .. self.whitespaceIfNeeded2(self, bodyCode, self.tabs(self, tabbing, true)) .. 'end'
                elseif (statement.kind == AstKind.WhileStatement) then
                    local expressionCode, bodyCode = self.unparseExpression(self, statement.condition, tabbing), self.unparseBlock(self, statement.body, tabbing)

                    code = 'while' .. self.whitespaceIfNeeded(self, expressionCode) .. expressionCode .. self.whitespaceIfNeeded2(self, expressionCode) .. 'do' .. self.whitespaceIfNeeded(self, bodyCode, self.newline(self, true)) .. bodyCode .. self.newline(self, false) .. self.whitespaceIfNeeded2(self, bodyCode, self.tabs(self, tabbing, true)) .. 'end'
                elseif (statement.kind == AstKind.RepeatStatement) then
                    local expressionCode, bodyCode = self.unparseExpression(self, statement.condition, tabbing), self.unparseBlock(self, statement.body, tabbing)

                    code = 'repeat' .. self.whitespaceIfNeeded(self, bodyCode, self.newline(self, true)) .. bodyCode .. self.whitespaceIfNeeded2(self, bodyCode, self.newline(self) .. self.tabs(self, tabbing, true)) .. 'until' .. self.whitespaceIfNeeded(self, expressionCode) .. expressionCode
                elseif (statement.kind == AstKind.ForStatement) then
                    local bodyCode = self.unparseBlock(self, statement.body, tabbing)

                    code = 'for' .. self.whitespace(self) .. statement.scope:getVariableName(statement.id) .. self.optionalWhitespace(self) .. '='
                    code = code .. self.optionalWhitespace(self) .. self.unparseExpression(self, statement.initialValue, tabbing) .. ','
                    code = code .. self.optionalWhitespace(self) .. self.unparseExpression(self, statement.finalValue, tabbing) .. ','

                    local incrementByCode = statement.incrementBy and self.unparseExpression(self, statement.incrementBy, tabbing) or '1'

                    code = code .. self.optionalWhitespace(self) .. incrementByCode .. self.whitespaceIfNeeded2(self, incrementByCode) .. 'do' .. self.whitespaceIfNeeded(self, bodyCode, self.newline(self, true)) .. bodyCode .. self.newline(self, false) .. self.whitespaceIfNeeded2(self, bodyCode, self.tabs(self, tabbing, true)) .. 'end'
                elseif (statement.kind == AstKind.ForInStatement) then
                    code = 'for' .. self.whitespace(self)

                    for i, id in ipairs(statement.ids)do
                        if (i ~= 1) then
                            code = code .. ',' .. self.optionalWhitespace(self)
                        end

                        code = code .. statement.scope:getVariableName(id)
                    end

                    code = code .. self.whitespace(self) .. 'in'

                    local exprcode = self.unparseExpression(self, statement.expressions[1], tabbing)

                    code = code .. self.whitespaceIfNeeded(self, exprcode) .. exprcode

                    for i = 2, #statement.expressions, 1 do
                        exprcode = self.unparseExpression(self, statement.expressions[i], tabbing)
                        code = code .. ',' .. self.optionalWhitespace(self) .. exprcode
                    end

                    local bodyCode = self.unparseBlock(self, statement.body, tabbing)

                    code = code .. self.whitespaceIfNeeded2(self, code) .. 'do' .. self.whitespaceIfNeeded(self, bodyCode, self.newline(self, true)) .. bodyCode .. self.newline(self, false) .. self.whitespaceIfNeeded2(self, bodyCode, self.tabs(self, tabbing, true)) .. 'end'
                elseif (statement.kind == AstKind.IfStatement) then
                    local exprcode, bodyCode = self.unparseExpression(self, statement.condition, tabbing), self.unparseBlock(self, statement.body, tabbing)

                    code = 'if' .. self.whitespaceIfNeeded(self, exprcode) .. exprcode .. self.whitespaceIfNeeded2(self, exprcode) .. 'then' .. self.whitespaceIfNeeded(self, bodyCode, self.newline(self, true)) .. bodyCode

                    for i, eif in ipairs(statement.elseifs)do
                        exprcode = self.unparseExpression(self, eif.condition, tabbing)
                        bodyCode = self.unparseBlock(self, eif.body, tabbing)
                        code = code .. self.newline(self, false) .. self.whitespaceIfNeeded2(self, code, self.tabs(self, tabbing, true)) .. 'elseif' .. self.whitespaceIfNeeded(self, exprcode) .. exprcode .. self.whitespaceIfNeeded2(self, exprcode) .. 'then' .. self.whitespaceIfNeeded(self, bodyCode, self.newline(self, true)) .. bodyCode
                    end

                    if (statement.elsebody) then
                        bodyCode = self.unparseBlock(self, statement.elsebody, tabbing)
                        code = code .. self.newline(self, false) .. self.whitespaceIfNeeded2(self, code, self.tabs(self, tabbing, true)) .. 'else' .. self.whitespaceIfNeeded(self, bodyCode, self.newline(self, true)) .. bodyCode
                    end

                    code = code .. self.newline(self, false) .. self.whitespaceIfNeeded2(self, bodyCode, self.tabs(self, tabbing, true)) .. 'end'
                elseif (statement.kind == AstKind.FunctionDeclaration) then
                    local funcname = statement.scope:getVariableName(statement.id)

                    for _, index in ipairs(statement.indices)do
                        funcname = funcname .. '.' .. index
                    end

                    code = 'function' .. self.whitespace(self) .. funcname .. '('

                    for i, arg in ipairs(statement.args)do
                        if i > 1 then
                            code = code .. ',' .. self.optionalWhitespace(self)
                        end
                        if (arg.kind == AstKind.VarargExpression) then
                            code = code .. '...'
                        else
                            code = code .. arg.scope:getVariableName(arg.id)
                        end
                    end

                    code = code .. ')'

                    local bodyCode = self.unparseBlock(self, statement.body, tabbing)

                    code = code .. self.newline(self, false) .. bodyCode .. self.newline(self, false) .. self.whitespaceIfNeeded2(self, bodyCode, self.tabs(self, tabbing, true)) .. 'end'
                elseif (statement.kind == AstKind.LocalFunctionDeclaration) then
                    local funcname = statement.scope:getVariableName(statement.id)

                    code = 'local' .. self.whitespace(self) .. 'function' .. self.whitespace(self) .. funcname .. '('

                    for i, arg in ipairs(statement.args)do
                        if i > 1 then
                            code = code .. ',' .. self.optionalWhitespace(self)
                        end
                        if (arg.kind == AstKind.VarargExpression) then
                            code = code .. '...'
                        else
                            code = code .. arg.scope:getVariableName(arg.id)
                        end
                    end

                    code = code .. ')'

                    local bodyCode = self.unparseBlock(self, statement.body, tabbing)

                    code = code .. self.newline(self, false) .. bodyCode .. self.newline(self, false) .. self.whitespaceIfNeeded2(self, bodyCode, self.tabs(self, tabbing, true)) .. 'end'
                elseif (statement.kind == AstKind.LocalVariableDeclaration) then
                    code = 'local' .. self.whitespace(self)

                    for i, id in ipairs(statement.ids)do
                        if i > 1 then
                            code = code .. ',' .. self.optionalWhitespace(self)
                        end

                        code = code .. statement.scope:getVariableName(id)
                    end

                    if (#statement.expressions > 0) then
                        code = code .. self.optionalWhitespace(self) .. '=' .. self.optionalWhitespace(self)

                        for i, expr in ipairs(statement.expressions)do
                            if i > 1 then
                                code = code .. ',' .. self.optionalWhitespace(self)
                            end

                            code = code .. self.unparseExpression(self, expr, tabbing + 1)
                        end
                    end
                elseif (statement.kind == AstKind.FunctionCallStatement) then
                    if not (statement.base.kind == AstKind.IndexExpression or statement.base.kind == AstKind.VariableExpression) then
                        code = '(' .. self.unparseExpression(self, statement.base, tabbing) .. ')'
                    else
                        code = self.unparseExpression(self, statement.base, tabbing)
                    end

                    code = code .. '('

                    for i, arg in ipairs(statement.args)do
                        if i > 1 then
                            code = code .. ',' .. self.optionalWhitespace(self)
                        end

                        code = code .. self.unparseExpression(self, arg, tabbing)
                    end

                    code = code .. ')'
                elseif (statement.kind == AstKind.PassSelfFunctionCallStatement) then
                    if not (statement.base.kind == AstKind.IndexExpression or statement.base.kind == AstKind.VariableExpression) then
                        code = '(' .. self.unparseExpression(self, statement.base, tabbing) .. ')'
                    else
                        code = self.unparseExpression(self, statement.base, tabbing)
                    end

                    code = code .. ':' .. statement.passSelfFunctionName
                    code = code .. '('

                    for i, arg in ipairs(statement.args)do
                        if i > 1 then
                            code = code .. ',' .. self.optionalWhitespace(self)
                        end

                        code = code .. self.unparseExpression(self, arg, tabbing)
                    end

                    code = code .. ')'
                elseif (statement.kind == AstKind.AssignmentStatement) then
                    for i, primary_expr in ipairs(statement.lhs)do
                        if i > 1 then
                            code = code .. ',' .. self.optionalWhitespace(self)
                        end

                        code = code .. self.unparseExpression(self, primary_expr, tabbing)
                    end

                    code = code .. self.optionalWhitespace(self) .. '=' .. self.optionalWhitespace(self)

                    for i, expr in ipairs(statement.rhs)do
                        if i > 1 then
                            code = code .. ',' .. self.optionalWhitespace(self)
                        end

                        code = code .. self.unparseExpression(self, expr, tabbing + 1)
                    end
                elseif (statement.kind == AstKind.ReturnStatement) then
                    code = 'return'

                    if (#statement.args > 0) then
                        local exprcode = self.unparseExpression(self, statement.args[1], tabbing)

                        code = code .. self.whitespaceIfNeeded(self, exprcode) .. exprcode

                        for i = 2, #statement.args, 1 do
                            exprcode = self.unparseExpression(self, statement.args[i], tabbing)
                            code = code .. ',' .. self.optionalWhitespace(self) .. exprcode
                        end
                    end
                elseif self.luaVersion == LuaVersion.LuaU then
                    local compoundOperators = {
                        [AstKind.CompoundAddStatement] = '+=',
                        [AstKind.CompoundSubStatement] = '-=',
                        [AstKind.CompoundMulStatement] = '*=',
                        [AstKind.CompoundDivStatement] = '/=',
                        [AstKind.CompoundModStatement] = '%=',
                        [AstKind.CompoundPowStatement] = '^=',
                        [AstKind.CompoundConcatStatement] = '..=',
                    }
                    local operator = compoundOperators[statement.kind]

                    if operator then
                        code = code .. self.unparseExpression(self, statement.lhs, tabbing) .. self.optionalWhitespace(self) .. operator .. self.optionalWhitespace(self) .. self.unparseExpression(self, statement.rhs, tabbing)
                    else
                        logger.error(logger, string.format('"%s" is not a valid unparseable statement in %s!', statement.kind, self.luaVersion))
                    end
                end

                return self.tabs(self, tabbing, false) .. code
            end

            local function randomTrueNode()
                local op = math.random(1, 2)

                if (op == 1) then
                    local a = math.random(1, 9)
                    local b = math.random(0, a - 1)

                    return tostring(a) .. '>' .. tostring(b)
                else
                    local a = math.random(1, 9)
                    local b = math.random(0, a - 1)

                    return tostring(b) .. '<' .. tostring(a)
                end
            end
            local function randomFalseNode()
                local op = math.random(1, 2)

                if (op == 1) then
                    local a = math.random(1, 9)
                    local b = math.random(0, a - 1)

                    return tostring(b) .. '>' .. tostring(a)
                else
                    local a = math.random(1, 9)
                    local b = math.random(0, a - 1)

                    return tostring(a) .. '<' .. tostring(b)
                end
            end

            function Unparser.unparseExpression(self, expression, tabbing)
                local code = ''

                if (expression.kind == AstKind.BooleanExpression) then
                    if (expression.value) then
                        return 'true'
                    else
                        return 'false'
                    end
                end
                if (expression.kind == AstKind.NumberExpression) then
                    local str = tostring(expression.value)

                    if (str == 'inf') then
                        return '2e1024'
                    end
                    if (str == '-inf') then
                        return '-2e1024'
                    end
                    if (str.sub(str, 1, 2) == '0.') then
                        str = str.sub(str, 2)
                    end

                    return str
                end
                if (expression.kind == AstKind.VariableExpression or expression.kind == AstKind.AssignmentVariable) then
                    return expression.scope:getVariableName(expression.id)
                end
                if (expression.kind == AstKind.StringExpression) then
                    return '"' .. escapeString(expression.value) .. '"'
                end
                if (expression.kind == AstKind.NilExpression) then
                    return 'nil'
                end
                if (expression.kind == AstKind.VarargExpression) then
                    return '...'
                end

                local k = AstKind.OrExpression

                if (expression.kind == k) then
                    local lhs, rhs = self.unparseExpression(self, expression.lhs, tabbing), self.unparseExpression(self, expression.rhs, tabbing)

                    return lhs .. self.whitespaceIfNeeded2(self, lhs) .. 'or' .. self.whitespaceIfNeeded(self, rhs) .. rhs
                end

                k = AstKind.AndExpression

                if (expression.kind == k) then
                    local lhs = self.unparseExpression(self, expression.lhs, tabbing)

                    if (Ast.astKindExpressionToNumber(expression.lhs.kind) >= Ast.astKindExpressionToNumber(k)) then
                        lhs = '(' .. lhs .. ')'
                    end

                    local rhs = self.unparseExpression(self, expression.rhs, tabbing)

                    if (Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
                        rhs = '(' .. rhs .. ')'
                    end

                    return lhs .. self.whitespaceIfNeeded2(self, lhs) .. 'and' .. self.whitespaceIfNeeded(self, rhs) .. rhs
                end

                k = AstKind.LessThanExpression

                if (expression.kind == k) then
                    local lhs = self.unparseExpression(self, expression.lhs, tabbing)

                    if (Ast.astKindExpressionToNumber(expression.lhs.kind) >= Ast.astKindExpressionToNumber(k)) then
                        lhs = '(' .. lhs .. ')'
                    end

                    local rhs = self.unparseExpression(self, expression.rhs, tabbing)

                    if (Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
                        rhs = '(' .. rhs .. ')'
                    end

                    return lhs .. self.optionalWhitespace(self) .. '<' .. self.optionalWhitespace(self) .. rhs
                end

                k = AstKind.GreaterThanExpression

                if (expression.kind == k) then
                    local lhs = self.unparseExpression(self, expression.lhs, tabbing)

                    if (Ast.astKindExpressionToNumber(expression.lhs.kind) >= Ast.astKindExpressionToNumber(k)) then
                        lhs = '(' .. lhs .. ')'
                    end

                    local rhs = self.unparseExpression(self, expression.rhs, tabbing)

                    if (Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
                        rhs = '(' .. rhs .. ')'
                    end

                    return lhs .. self.optionalWhitespace(self) .. '>' .. self.optionalWhitespace(self) .. rhs
                end

                k = AstKind.LessThanOrEqualsExpression

                if (expression.kind == k) then
                    local lhs = self.unparseExpression(self, expression.lhs, tabbing)

                    if (Ast.astKindExpressionToNumber(expression.lhs.kind) >= Ast.astKindExpressionToNumber(k)) then
                        lhs = '(' .. lhs .. ')'
                    end

                    local rhs = self.unparseExpression(self, expression.rhs, tabbing)

                    if (Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
                        rhs = '(' .. rhs .. ')'
                    end

                    return lhs .. self.optionalWhitespace(self) .. '<=' .. self.optionalWhitespace(self) .. rhs
                end

                k = AstKind.GreaterThanOrEqualsExpression

                if (expression.kind == k) then
                    local lhs = self.unparseExpression(self, expression.lhs, tabbing)

                    if (Ast.astKindExpressionToNumber(expression.lhs.kind) >= Ast.astKindExpressionToNumber(k)) then
                        lhs = '(' .. lhs .. ')'
                    end

                    local rhs = self.unparseExpression(self, expression.rhs, tabbing)

                    if (Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
                        rhs = '(' .. rhs .. ')'
                    end

                    return lhs .. self.optionalWhitespace(self) .. '>=' .. self.optionalWhitespace(self) .. rhs
                end

                k = AstKind.NotEqualsExpression

                if (expression.kind == k) then
                    local lhs = self.unparseExpression(self, expression.lhs, tabbing)

                    if (Ast.astKindExpressionToNumber(expression.lhs.kind) >= Ast.astKindExpressionToNumber(k)) then
                        lhs = '(' .. lhs .. ')'
                    end

                    local rhs = self.unparseExpression(self, expression.rhs, tabbing)

                    if (Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
                        rhs = '(' .. rhs .. ')'
                    end

                    return lhs .. self.optionalWhitespace(self) .. '~=' .. self.optionalWhitespace(self) .. rhs
                end

                k = AstKind.EqualsExpression

                if (expression.kind == k) then
                    local lhs = self.unparseExpression(self, expression.lhs, tabbing)

                    if (Ast.astKindExpressionToNumber(expression.lhs.kind) >= Ast.astKindExpressionToNumber(k)) then
                        lhs = '(' .. lhs .. ')'
                    end

                    local rhs = self.unparseExpression(self, expression.rhs, tabbing)

                    if (Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
                        rhs = '(' .. rhs .. ')'
                    end

                    return lhs .. self.optionalWhitespace(self) .. '==' .. self.optionalWhitespace(self) .. rhs
                end

                k = AstKind.StrCatExpression

                if (expression.kind == k) then
                    local lhs = self.unparseExpression(self, expression.lhs, tabbing)

                    if (Ast.astKindExpressionToNumber(expression.lhs.kind) >= Ast.astKindExpressionToNumber(k)) then
                        lhs = '(' .. lhs .. ')'
                    end

                    local rhs = self.unparseExpression(self, expression.rhs, tabbing)

                    if (Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
                        rhs = '(' .. rhs .. ')'
                    end
                    if (self.numberCharsLookup[string.sub(lhs, #lhs, #lhs)]) then
                        lhs = lhs .. ' '
                    end

                    return lhs .. self.optionalWhitespace(self) .. '..' .. self.optionalWhitespace(self) .. rhs
                end

                k = AstKind.AddExpression

                if (expression.kind == k) then
                    local lhs = self.unparseExpression(self, expression.lhs, tabbing)

                    if (Ast.astKindExpressionToNumber(expression.lhs.kind) >= Ast.astKindExpressionToNumber(k)) then
                        lhs = '(' .. lhs .. ')'
                    end

                    local rhs = self.unparseExpression(self, expression.rhs, tabbing)

                    if (Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
                        rhs = '(' .. rhs .. ')'
                    end

                    return lhs .. self.optionalWhitespace(self) .. '+' .. self.optionalWhitespace(self) .. rhs
                end

                k = AstKind.SubExpression

                if (expression.kind == k) then
                    local lhs = self.unparseExpression(self, expression.lhs, tabbing)

                    if (Ast.astKindExpressionToNumber(expression.lhs.kind) >= Ast.astKindExpressionToNumber(k)) then
                        lhs = '(' .. lhs .. ')'
                    end

                    local rhs = self.unparseExpression(self, expression.rhs, tabbing)

                    if (Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
                        rhs = '(' .. rhs .. ')'
                    end
                    if string.sub(rhs, 1, 1) == '-' then
                        rhs = '(' .. rhs .. ')'
                    end

                    return lhs .. self.optionalWhitespace(self) .. '-' .. self.optionalWhitespace(self) .. rhs
                end

                k = AstKind.MulExpression

                if (expression.kind == k) then
                    local lhs = self.unparseExpression(self, expression.lhs, tabbing)

                    if (Ast.astKindExpressionToNumber(expression.lhs.kind) >= Ast.astKindExpressionToNumber(k)) then
                        lhs = '(' .. lhs .. ')'
                    end

                    local rhs = self.unparseExpression(self, expression.rhs, tabbing)

                    if (Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
                        rhs = '(' .. rhs .. ')'
                    end

                    return lhs .. self.optionalWhitespace(self) .. '*' .. self.optionalWhitespace(self) .. rhs
                end

                k = AstKind.DivExpression

                if (expression.kind == k) then
                    local lhs = self.unparseExpression(self, expression.lhs, tabbing)

                    if (Ast.astKindExpressionToNumber(expression.lhs.kind) >= Ast.astKindExpressionToNumber(k)) then
                        lhs = '(' .. lhs .. ')'
                    end

                    local rhs = self.unparseExpression(self, expression.rhs, tabbing)

                    if (Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
                        rhs = '(' .. rhs .. ')'
                    end

                    return lhs .. self.optionalWhitespace(self) .. '/' .. self.optionalWhitespace(self) .. rhs
                end

                k = AstKind.ModExpression

                if (expression.kind == k) then
                    local lhs = self.unparseExpression(self, expression.lhs, tabbing)

                    if (Ast.astKindExpressionToNumber(expression.lhs.kind) >= Ast.astKindExpressionToNumber(k)) then
                        lhs = '(' .. lhs .. ')'
                    end

                    local rhs = self.unparseExpression(self, expression.rhs, tabbing)

                    if (Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
                        rhs = '(' .. rhs .. ')'
                    end

                    return lhs .. self.optionalWhitespace(self) .. '%' .. self.optionalWhitespace(self) .. rhs
                end

                k = AstKind.PowExpression

                if (expression.kind == k) then
                    local lhs = self.unparseExpression(self, expression.lhs, tabbing)

                    if (Ast.astKindExpressionToNumber(expression.lhs.kind) >= Ast.astKindExpressionToNumber(k)) then
                        lhs = '(' .. lhs .. ')'
                    end

                    local rhs = self.unparseExpression(self, expression.rhs, tabbing)

                    if (Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
                        rhs = '(' .. rhs .. ')'
                    end

                    return lhs .. self.optionalWhitespace(self) .. '^' .. self.optionalWhitespace(self) .. rhs
                end

                k = AstKind.NotExpression

                if (expression.kind == k) then
                    local rhs = self.unparseExpression(self, expression.rhs, tabbing)

                    if (Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
                        rhs = '(' .. rhs .. ')'
                    end

                    return 'not' .. self.whitespaceIfNeeded(self, rhs) .. rhs
                end

                k = AstKind.NegateExpression

                if (expression.kind == k) then
                    local rhs = self.unparseExpression(self, expression.rhs, tabbing)

                    if (Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
                        rhs = '(' .. rhs .. ')'
                    end
                    if string.sub(rhs, 1, 1) == '-' then
                        rhs = '(' .. rhs .. ')'
                    end

                    return '-' .. rhs
                end

                k = AstKind.LenExpression

                if (expression.kind == k) then
                    local rhs = self.unparseExpression(self, expression.rhs, tabbing)

                    if (Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
                        rhs = '(' .. rhs .. ')'
                    end

                    return '#' .. rhs
                end

                k = AstKind.IndexExpression

                if (expression.kind == k or expression.kind == AstKind.AssignmentIndexing) then
                    local base = self.unparseExpression(self, expression.base, tabbing)

                    if (expression.base.kind == AstKind.VarargExpression or Ast.astKindExpressionToNumber(expression.base.kind) > Ast.astKindExpressionToNumber(k)) then
                        base = '(' .. base .. ')'
                    end
                    if (expression.index.kind == AstKind.StringExpression and self.isValidIdentifier(self, expression.index.value)) then
                        return base .. '.' .. expression.index.value
                    end

                    local index = self.unparseExpression(self, expression.index, tabbing)

                    return base .. '[' .. index .. ']'
                end

                k = AstKind.FunctionCallExpression

                if (expression.kind == k) then
                    if not (expression.base.kind == AstKind.IndexExpression or expression.base.kind == AstKind.VariableExpression) then
                        code = '(' .. self.unparseExpression(self, expression.base, tabbing) .. ')'
                    else
                        code = self.unparseExpression(self, expression.base, tabbing)
                    end

                    code = code .. '('

                    for i, arg in ipairs(expression.args)do
                        if i > 1 then
                            code = code .. ',' .. self.optionalWhitespace(self)
                        end

                        code = code .. self.unparseExpression(self, arg, tabbing)
                    end

                    code = code .. ')'

                    return code
                end

                k = AstKind.PassSelfFunctionCallExpression

                if (expression.kind == k) then
                    if not (expression.base.kind == AstKind.IndexExpression or expression.base.kind == AstKind.VariableExpression) then
                        code = '(' .. self.unparseExpression(self, expression.base, tabbing) .. ')'
                    else
                        code = self.unparseExpression(self, expression.base, tabbing)
                    end

                    code = code .. ':' .. expression.passSelfFunctionName
                    code = code .. '('

                    for i, arg in ipairs(expression.args)do
                        if i > 1 then
                            code = code .. ',' .. self.optionalWhitespace(self)
                        end

                        code = code .. self.unparseExpression(self, arg, tabbing)
                    end

                    code = code .. ')'

                    return code
                end

                k = AstKind.FunctionLiteralExpression

                if (expression.kind == k) then
                    code = 'function('

                    for i, arg in ipairs(expression.args)do
                        if i > 1 then
                            code = code .. ',' .. self.optionalWhitespace(self)
                        end
                        if (arg.kind == AstKind.VarargExpression) then
                            code = code .. '...'
                        else
                            code = code .. arg.scope:getVariableName(arg.id)
                        end
                    end

                    code = code .. ')'

                    local bodyCode = self.unparseBlock(self, expression.body, tabbing)

                    code = code .. self.newline(self, false) .. bodyCode .. self.newline(self, false) .. self.whitespaceIfNeeded2(self, bodyCode, self.tabs(self, tabbing, true)) .. 'end'

                    return code
                end

                k = AstKind.TableConstructorExpression

                if (expression.kind == k) then
                    if (#expression.entries == 0) then
                        return '{}'
                    end

                    local inlineTable, tableTabbing = #expression.entries <= 3, tabbing + 1

                    code = '{'

                    if inlineTable then
                        code = code .. self.optionalWhitespace(self)
                    else
                        code = code .. self.optionalWhitespace(self, self.newline(self) .. self.tabs(self, tableTabbing))
                    end

                    local p = false

                    for i, entry in ipairs(expression.entries)do
                        p = true

                        local sep = self.prettyPrint and ',' or (math.random(1, 2) == 1 and ',' or ';')

                        if i > 1 and not inlineTable then
                            code = code .. sep .. self.optionalWhitespace(self, self.newline(self) .. self.tabs(self, tableTabbing))
                        elseif i > 1 then
                            code = code .. sep .. self.optionalWhitespace(self)
                        end
                        if (entry.kind == AstKind.KeyedTableEntry) then
                            if (entry.key.kind == AstKind.StringExpression and self.isValidIdentifier(self, entry.key.value)) then
                                code = code .. entry.key.value
                            else
                                code = code .. '[' .. self.unparseExpression(self, entry.key, tableTabbing) .. ']'
                            end

                            code = code .. self.optionalWhitespace(self) .. '=' .. self.optionalWhitespace(self) .. self.unparseExpression(self, entry.value, tableTabbing)
                        else
                            code = code .. self.unparseExpression(self, entry.value, tableTabbing)
                        end
                    end

                    if inlineTable then
                        return code .. self.optionalWhitespace(self) .. '}'
                    end

                    return code .. self.optionalWhitespace(self, (p and ',' or '') .. self.newline(self) .. self.tabs(self, tabbing)) .. '}'
                end
                if (self.luaVersion == LuaVersion.LuaU) then
                    k = AstKind.IfElseExpression

                    if (expression.kind == k) then
                        code = 'if '
                        code = code .. self.unparseExpression(self, expression.condition)
                        code = code .. ' then '
                        code = code .. self.unparseExpression(self, expression.true_value)
                        code = code .. ' else '
                        code = code .. self.unparseExpression(self, expression.false_value)

                        return code
                    end
                end

                logger.error(logger, string.format('"%s" is not a valid unparseable expression', expression.kind))
            end

            return Unparser
        end

        function __DARKLUA_BUNDLE_MODULES.k()
            local v = __DARKLUA_BUNDLE_MODULES.cache.k

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.k = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local util = __DARKLUA_BUNDLE_MODULES.f()
            local chararray, idGen = util.chararray, 0
            local VarDigits, VarStartDigits = chararray
[[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_]], chararray'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'

            return function(id, scope)
                local name, d = '', id % #VarStartDigits

                id = (id - d) / #VarStartDigits
                name = name .. VarStartDigits[d + 1]

                while id > 0 do
                    local d = id % #VarDigits

                    id = (id - d) / #VarDigits
                    name = name .. VarDigits[d + 1]
                end

                return name
            end
        end

        function __DARKLUA_BUNDLE_MODULES.l()
            local v = __DARKLUA_BUNDLE_MODULES.cache.l

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.l = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local util = __DARKLUA_BUNDLE_MODULES.f()
            local chararray = util.chararray
            local VarDigits, VarStartDigits = chararray
[[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_]], chararray'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'

            local function generateName(id, scope)
                local name, d = '', id % #VarStartDigits

                id = (id - d) / #VarStartDigits
                name = name .. VarStartDigits[d + 1]

                while id > 0 do
                    local d = id % #VarDigits

                    id = (id - d) / #VarDigits
                    name = name .. VarDigits[d + 1]
                end

                return name
            end
            local function prepare(ast)
                util.shuffle(VarDigits)
                util.shuffle(VarStartDigits)
            end

            return {
                generateName = generateName,
                prepare = prepare,
            }
        end

        function __DARKLUA_BUNDLE_MODULES.m()
            local v = __DARKLUA_BUNDLE_MODULES.cache.m

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.m = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local MIN_CHARACTERS, MAX_INITIAL_CHARACTERS, util = 5, 10, __DARKLUA_BUNDLE_MODULES.f()
            local chararray, offset = util.chararray, 0
            local VarDigits, VarStartDigits = chararray'Il1', chararray'Il'

            local function generateName(id, scope)
                local name = ''

                id = id + offset

                local d = id % #VarStartDigits

                id = (id - d) / #VarStartDigits
                name = name .. VarStartDigits[d + 1]

                while id > 0 do
                    local d = id % #VarDigits

                    id = (id - d) / #VarDigits
                    name = name .. VarDigits[d + 1]
                end

                return name
            end
            local function prepare(ast)
                util.shuffle(VarDigits)
                util.shuffle(VarStartDigits)

                offset = math.random(3 ^ MIN_CHARACTERS, 3 ^ MAX_INITIAL_CHARACTERS)
            end

            return {
                generateName = generateName,
                prepare = prepare,
            }
        end

        function __DARKLUA_BUNDLE_MODULES.n()
            local v = __DARKLUA_BUNDLE_MODULES.cache.n

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.n = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local PREFIX = '_'

            return function(id, scope)
                return PREFIX .. tostring(id)
            end
        end

        function __DARKLUA_BUNDLE_MODULES.o()
            local v = __DARKLUA_BUNDLE_MODULES.cache.o

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.o = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local util = __DARKLUA_BUNDLE_MODULES.f()
            local chararray, varNames = util.chararray, {
                'index',
                'iterator',
                'length',
                'size',
                'key',
                'value',
                'data',
                'count',
                'increment',
                'include',
                'string',
                'number',
                'type',
                'void',
                'int',
                'float',
                'bool',
                'char',
                'double',
                'long',
                'short',
                'unsigned',
                'signed',
                'program',
                'factory',
                'Factory',
                'new',
                'delete',
                'table',
                'array',
                'object',
                'class',
                'arr',
                'obj',
                'cls',
                'dir',
                'directory',
                'isWindows',
                'isLinux',
                'game',
                'roblox',
                'gmod',
                'gsub',
                'gmatch',
                'gfind',
                'onload',
                'load',
                'loadstring',
                'loadfile',
                'dofile',
                'require',
                'parse',
                'byte',
                'code',
                'bytecode',
                'idx',
                'const',
                'loader',
                'loaders',
                'module',
                'export',
                'exports',
                'import',
                'imports',
                'package',
                'packages',
                '_G',
                'math',
                'os',
                'io',
                'write',
                'print',
                'read',
                'readline',
                'readlines',
                'close',
                'flush',
                'open',
                'popen',
                'tmpfile',
                'tmpname',
                'rename',
                'remove',
                'seek',
                'setvbuf',
                'lines',
                'call',
                'apply',
                'raise',
                'pcall',
                'xpcall',
                'coroutine',
                'create',
                'resume',
                'status',
                'wrap',
                'yield',
                'debug',
                'traceback',
                'getinfo',
                'getlocal',
                'setlocal',
                'getupvalue',
                'setupvalue',
                'getuservalue',
                'setuservalue',
                'upvalueid',
                'upvaluejoin',
                'sethook',
                'gethook',
                'hookfunction',
                'hooks',
                'error',
                'setmetatable',
                'getmetatable',
                'rand',
                'randomseed',
                'next',
                'ipairs',
                'hasnext',
                'loadlib',
                'searchpath',
                'oldpath',
                'newpath',
                'path',
                'rawequal',
                'rawset',
                'rawget',
                'rawnew',
                'rawlen',
                'select',
                'tonumber',
                'tostring',
                'assert',
                'collectgarbage',
                'a',
                'b',
                'c',
                'i',
                'j',
                'm',
            }

            local function generateName(id, scope)
                local name, d = {}, id % #varNames

                id = (id - d) / #varNames

                table.insert(name, varNames[d + 1])

                while id > 0 do
                    local d = id % #varNames

                    id = (id - d) / #varNames

                    table.insert(name, varNames[d + 1])
                end

                return table.concat(name, '_')
            end
            local function prepare(ast)
                util.shuffle(varNames)
            end

            return {
                generateName = generateName,
                prepare = prepare,
            }
        end

        function __DARKLUA_BUNDLE_MODULES.p()
            local v = __DARKLUA_BUNDLE_MODULES.cache.p

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.p = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            return {
                Mangled = __DARKLUA_BUNDLE_MODULES.l(),
                MangledShuffled = __DARKLUA_BUNDLE_MODULES.m(),
                Il = __DARKLUA_BUNDLE_MODULES.n(),
                Number = __DARKLUA_BUNDLE_MODULES.o(),
                Confuse = __DARKLUA_BUNDLE_MODULES.p(),
            }
        end

        function __DARKLUA_BUNDLE_MODULES.q()
            local v = __DARKLUA_BUNDLE_MODULES.cache.q

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.q = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local logger, util = __DARKLUA_BUNDLE_MODULES.d(), __DARKLUA_BUNDLE_MODULES.f()
            local lookupify, Step = util.lookupify, {}

            Step.SettingsDescriptor = {}

            function Step.new(self, settings)
                local instance = {}

                setmetatable(instance, self)

                self.__index = self

                if type(settings) ~= 'table' then
                    settings = {}
                end

                for key, data in pairs(self.SettingsDescriptor)do
                    if settings[key] == nil then
                        if data.default == nil then
                            logger.error(logger, string.format('The Setting "%s" was not provided for the Step "%s"', key, self.Name))
                        end

                        instance[key] = data.default
                    elseif (data.type == 'enum') then
                        local lookup = lookupify(data.values)

                        if not lookup[settings[key] ] then
                            logger.error(logger, string.format(
[[Invalid value for the Setting "%s" of the Step "%s". It must be one of the following: %s]], key, self.Name, table.concat(data, ', ')))
                        end

                        instance[key] = settings[key]
                    elseif (type(settings[key]) ~= data.type) then
                        logger.error(logger, string.format(
[[Invalid value for the Setting "%s" of the Step "%s". It must be a %s]], key, self.Name, data.type))
                    else
                        if data.min then
                            if settings[key] < data.min then
                                logger.error(logger, string.format(
[[Invalid value for the Setting "%s" of the Step "%s". It must be at least %d]], key, self.Name, data.min))
                            end
                        end
                        if data.max then
                            if settings[key] > data.max then
                                logger.error(logger, string.format(
[[Invalid value for the Setting "%s" of the Step "%s". The biggest allowed value is %d]], key, self.Name, data.min))
                            end
                        end

                        instance[key] = settings[key]
                    end
                end

                instance.init(instance)

                return instance
            end
            function Step.init(self)
                logger.error(logger, 'Abstract Steps cannot be Created')
            end
            function Step.extend(self)
                local ext = {}

                setmetatable(ext, self)

                self.__index = self

                return ext
            end
            function Step.apply(self, ast, pipeline)
                logger.error(logger, 'Abstract Steps cannot be Applied')
            end

            Step.Name = 'Abstract Step'
            Step.Description = 'Abstract Step'

            return Step
        end

        function __DARKLUA_BUNDLE_MODULES.r()
            local v = __DARKLUA_BUNDLE_MODULES.cache.r

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.r = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Step, Ast, Scope = __DARKLUA_BUNDLE_MODULES.r(), __DARKLUA_BUNDLE_MODULES.b(), __DARKLUA_BUNDLE_MODULES.i()
            local WrapInFunction = Step.extend(Step)

            WrapInFunction.Description = 'This Step Wraps the Entire Script into a Function'
            WrapInFunction.Name = 'Wrap in Function'
            WrapInFunction.SettingsDescriptor = {
                Iterations = {
                    name = 'Iterations',
                    description = 'The Number Of Iterations',
                    type = 'number',
                    default = 1,
                    min = 1,
                    max = nil,
                },
            }

            function WrapInFunction.init(self, settings) end
            function WrapInFunction.apply(self, ast)
                for i = 1, self.Iterations, 1 do
                    local body, scope = ast.body, Scope.new(Scope, ast.globalScope)

                    body.scope:setParent(scope)

                    ast.body = Ast.Block({
                        Ast.ReturnStatement{
                            Ast.FunctionCallExpression(Ast.FunctionLiteralExpression({
                                Ast.VarargExpression(),
                            }, body), {
                                Ast.VarargExpression(),
                            }),
                        },
                    }, scope)
                end
            end

            return WrapInFunction
        end

        function __DARKLUA_BUNDLE_MODULES.s()
            local v = __DARKLUA_BUNDLE_MODULES.cache.s

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.s = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Ast, util = __DARKLUA_BUNDLE_MODULES.b(), __DARKLUA_BUNDLE_MODULES.f()
            local AstKind, lookupify, visitAst, visitBlock, visitStatement, visitExpression = Ast.AstKind, util.lookupify, nil, nil, nil, nil

            function visitAst(ast, previsit, postvisit, data)
                ast.isAst = true
                data = data or {}
                data.scopeStack = {}
                data.functionData = {
                    depth = 0,
                    scope = ast.body.scope,
                    node = ast,
                }
                data.scope = ast.globalScope
                data.globalScope = ast.globalScope

                if (type(previsit) == 'function') then
                    local node, skip = previsit(ast, data)

                    ast = node or ast

                    if skip then
                        return ast
                    end
                end

                visitBlock(ast.body, previsit, postvisit, data, true)

                if (type(postvisit) == 'function') then
                    ast = postvisit(ast, data) or ast
                end

                return ast
            end

            local compundStats = lookupify{
                AstKind.CompoundAddStatement,
                AstKind.CompoundSubStatement,
                AstKind.CompoundMulStatement,
                AstKind.CompoundDivStatement,
                AstKind.CompoundModStatement,
                AstKind.CompoundPowStatement,
                AstKind.CompoundConcatStatement,
            }

            function visitBlock(
                block,
                previsit,
                postvisit,
                data,
                isFunctionBlock
            )
                block.isBlock = true
                block.isFunctionBlock = isFunctionBlock or false
                data.scope = block.scope

                local parentBlockData = data.blockData

                data.blockData = {}

                table.insert(data.scopeStack, block.scope)

                if (type(previsit) == 'function') then
                    local node, skip = previsit(block, data)

                    block = node or block

                    if skip then
                        data.scope = table.remove(data.scopeStack)

                        return block
                    end
                end

                local i = 1

                while i <= #block.statements do
                    local statement = table.remove(block.statements, i)

                    i = i - 1

                    local returnedStatements = {
                        visitStatement(statement, previsit, postvisit, data),
                    }

                    for j, statement in ipairs(returnedStatements)do
                        i = i + 1

                        table.insert(block.statements, i, statement)
                    end

                    i = i + 1
                end

                if (type(postvisit) == 'function') then
                    block = postvisit(block, data) or block
                end

                data.scope = table.remove(data.scopeStack)
                data.blockData = parentBlockData

                return block
            end
            function visitStatement(statement, previsit, postvisit, data)
                statement.isStatement = true

                if (type(previsit) == 'function') then
                    local node, skip = previsit(statement, data)

                    statement = node or statement

                    if skip then
                        return statement
                    end
                end
                if (statement.kind == AstKind.ReturnStatement) then
                    for i, expression in ipairs(statement.args)do
                        statement.args[i] = visitExpression(expression, previsit, postvisit, data)
                    end
                elseif (statement.kind == AstKind.PassSelfFunctionCallStatement or statement.kind == AstKind.FunctionCallStatement) then
                    statement.base = visitExpression(statement.base, previsit, postvisit, data)

                    for i, expression in ipairs(statement.args)do
                        statement.args[i] = visitExpression(expression, previsit, postvisit, data)
                    end
                elseif (statement.kind == AstKind.AssignmentStatement) then
                    for i, primaryExpr in ipairs(statement.lhs)do
                        statement.lhs[i] = visitExpression(primaryExpr, previsit, postvisit, data)
                    end
                    for i, expression in ipairs(statement.rhs)do
                        statement.rhs[i] = visitExpression(expression, previsit, postvisit, data)
                    end
                elseif (statement.kind == AstKind.FunctionDeclaration or statement.kind == AstKind.LocalFunctionDeclaration) then
                    local parentFunctionData = data.functionData

                    data.functionData = {
                        depth = parentFunctionData.depth + 1,
                        scope = statement.body.scope,
                        node = statement,
                    }
                    statement.body = visitBlock(statement.body, previsit, postvisit, data, true)
                    data.functionData = parentFunctionData
                elseif (statement.kind == AstKind.DoStatement) then
                    statement.body = visitBlock(statement.body, previsit, postvisit, data, false)
                elseif (statement.kind == AstKind.WhileStatement) then
                    statement.condition = visitExpression(statement.condition, previsit, postvisit, data)
                    statement.body = visitBlock(statement.body, previsit, postvisit, data, false)
                elseif (statement.kind == AstKind.RepeatStatement) then
                    statement.body = visitBlock(statement.body, previsit, postvisit, data)
                    statement.condition = visitExpression(statement.condition, previsit, postvisit, data)
                elseif (statement.kind == AstKind.ForStatement) then
                    statement.initialValue = visitExpression(statement.initialValue, previsit, postvisit, data)
                    statement.finalValue = visitExpression(statement.finalValue, previsit, postvisit, data)
                    statement.incrementBy = visitExpression(statement.incrementBy, previsit, postvisit, data)
                    statement.body = visitBlock(statement.body, previsit, postvisit, data, false)
                elseif (statement.kind == AstKind.ForInStatement) then
                    for i, expression in ipairs(statement.expressions)do
                        statement.expressions[i] = visitExpression(expression, previsit, postvisit, data)
                    end

                    visitBlock(statement.body, previsit, postvisit, data, false)
                elseif (statement.kind == AstKind.IfStatement) then
                    statement.condition = visitExpression(statement.condition, previsit, postvisit, data)
                    statement.body = visitBlock(statement.body, previsit, postvisit, data, false)

                    for i, eif in ipairs(statement.elseifs)do
                        eif.condition = visitExpression(eif.condition, previsit, postvisit, data)
                        eif.body = visitBlock(eif.body, previsit, postvisit, data, false)
                    end

                    if (statement.elsebody) then
                        statement.elsebody = visitBlock(statement.elsebody, previsit, postvisit, data, false)
                    end
                elseif (statement.kind == AstKind.LocalVariableDeclaration) then
                    for i, expression in ipairs(statement.expressions)do
                        statement.expressions[i] = visitExpression(expression, previsit, postvisit, data)
                    end
                elseif compundStats[statement.kind] then
                    statement.lhs = visitExpression(statement.lhs, previsit, postvisit, data)
                    statement.rhs = visitExpression(statement.rhs, previsit, postvisit, data)
                end
                if (type(postvisit) == 'function') then
                    local statements = {
                        postvisit(statement, data),
                    }

                    if #statements > 0 then
                        return unpack(statements)
                    end
                end

                return statement
            end

            local binaryExpressions = lookupify{
                AstKind.OrExpression,
                AstKind.AndExpression,
                AstKind.LessThanExpression,
                AstKind.GreaterThanExpression,
                AstKind.LessThanOrEqualsExpression,
                AstKind.GreaterThanOrEqualsExpression,
                AstKind.NotEqualsExpression,
                AstKind.EqualsExpression,
                AstKind.StrCatExpression,
                AstKind.AddExpression,
                AstKind.SubExpression,
                AstKind.MulExpression,
                AstKind.DivExpression,
                AstKind.ModExpression,
                AstKind.PowExpression,
            }

            function visitExpression(expression, previsit, postvisit, data)
                expression.isExpression = true

                if (type(previsit) == 'function') then
                    local node, skip = previsit(expression, data)

                    expression = node or expression

                    if skip then
                        return expression
                    end
                end
                if (binaryExpressions[expression.kind]) then
                    expression.lhs = visitExpression(expression.lhs, previsit, postvisit, data)
                    expression.rhs = visitExpression(expression.rhs, previsit, postvisit, data)
                end
                if (expression.kind == AstKind.NotExpression or expression.kind == AstKind.NegateExpression or expression.kind == AstKind.LenExpression) then
                    expression.rhs = visitExpression(expression.rhs, previsit, postvisit, data)
                end
                if (expression.kind == AstKind.PassSelfFunctionCallExpression or expression.kind == AstKind.FunctionCallExpression) then
                    expression.base = visitExpression(expression.base, previsit, postvisit, data)

                    for i, arg in ipairs(expression.args)do
                        expression.args[i] = visitExpression(arg, previsit, postvisit, data)
                    end
                end
                if (expression.kind == AstKind.FunctionLiteralExpression) then
                    local parentFunctionData = data.functionData

                    data.functionData = {
                        depth = parentFunctionData.depth + 1,
                        scope = expression.body.scope,
                        node = expression,
                    }
                    expression.body = visitBlock(expression.body, previsit, postvisit, data, true)
                    data.functionData = parentFunctionData
                end
                if (expression.kind == AstKind.TableConstructorExpression) then
                    for i, entry in ipairs(expression.entries)do
                        if entry.kind == AstKind.KeyedTableEntry then
                            entry.key = visitExpression(entry.key, previsit, postvisit, data)
                        end

                        entry.value = visitExpression(entry.value, previsit, postvisit, data)
                    end
                end
                if (expression.kind == AstKind.IndexExpression or expression.kind == AstKind.AssignmentIndexing) then
                    expression.base = visitExpression(expression.base, previsit, postvisit, data)
                    expression.index = visitExpression(expression.index, previsit, postvisit, data)
                end
                if (expression.kind == AstKind.IfElseExpression) then
                    expression.condition = visitExpression(expression.condition, previsit, postvisit, data)
                    expression.true_expr = visitExpression(expression.true_expr, previsit, postvisit, data)
                    expression.false_expr = visitExpression(expression.false_expr, previsit, postvisit, data)
                end
                if (type(postvisit) == 'function') then
                    expression = postvisit(expression, data) or expression
                end

                return expression
            end

            return visitAst
        end

        function __DARKLUA_BUNDLE_MODULES.t()
            local v = __DARKLUA_BUNDLE_MODULES.cache.t

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.t = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Step, Ast, visitAst, Parser, util, enums = __DARKLUA_BUNDLE_MODULES.r(), __DARKLUA_BUNDLE_MODULES.b(), __DARKLUA_BUNDLE_MODULES.t(), __DARKLUA_BUNDLE_MODULES.j(), __DARKLUA_BUNDLE_MODULES.f(), __DARKLUA_BUNDLE_MODULES.g()
            local LuaVersion, SplitStrings = enums.LuaVersion, Step.extend(Step)

            SplitStrings.Description = 'This Step splits Strings to a specific or random length'
            SplitStrings.Name = 'Split Strings'
            SplitStrings.SettingsDescriptor = {
                Treshold = {
                    name = 'Treshold',
                    description = 'The relative amount of nodes that will be affected',
                    type = 'number',
                    default = 1,
                    min = 0,
                    max = 1,
                },
                MinLength = {
                    name = 'MinLength',
                    description = 
[[The minimal length for the chunks in that the Strings are splitted]],
                    type = 'number',
                    default = 5,
                    min = 1,
                    max = nil,
                },
                MaxLength = {
                    name = 'MaxLength',
                    description = 
[[The maximal length for the chunks in that the Strings are splitted]],
                    type = 'number',
                    default = 5,
                    min = 1,
                    max = nil,
                },
                ConcatenationType = {
                    name = 'ConcatenationType',
                    description = 
[[The Functions used for Concatenation. Note that when using custom, the String Array will also be Shuffled]],
                    type = 'enum',
                    values = {
                        'strcat',
                        'table',
                        'custom',
                    },
                    default = 'custom',
                },
                CustomFunctionType = {
                    name = 'CustomFunctionType',
                    description = 
[[The Type of Function code injection This Option only applies when custom Concatenation is selected.
Note that when chosing inline, the code size may increase significantly!]],
                    type = 'enum',
                    values = {
                        'global',
                        'local',
                        'inline',
                    },
                    default = 'global',
                },
                CustomLocalFunctionsCount = {
                    name = 'CustomLocalFunctionsCount',
                    description = 
[[The number of local functions per scope. This option only applies when CustomFunctionType = local]],
                    type = 'number',
                    default = 2,
                    min = 1,
                },
            }

            function SplitStrings.init(self, settings) end

            local function generateTableConcatNode(chunks, data)
                local chunkNodes = {}

                for i, chunk in ipairs(chunks)do
                    table.insert(chunkNodes, Ast.TableEntry(Ast.StringExpression(chunk)))
                end

                local tb = Ast.TableConstructorExpression(chunkNodes)

                data.scope:addReferenceToHigherScope(data.tableConcatScope, data.tableConcatId)

                return Ast.FunctionCallExpression(Ast.VariableExpression(data.tableConcatScope, data.tableConcatId), {tb})
            end
            local function generateStrCatNode(chunks)
                local generatedNode

                for i, chunk in ipairs(chunks)do
                    if generatedNode then
                        generatedNode = Ast.StrCatExpression(generatedNode, Ast.StringExpression(chunk))
                    else
                        generatedNode = Ast.StringExpression(chunk)
                    end
                end

                return generatedNode
            end

            local customVariants, custom1Code, custom2Code = 2, 'function custom(table)\n    local stringTable, str = table[#table], "";\n    for i=1,#stringTable, 1 do\n        str = str .. stringTable[table[i]];\n\tend\n\treturn str\nend\n', 'function custom(tb)\n\tlocal str = "";\n\tfor i=1, #tb / 2, 1 do\n\t\tstr = str .. tb[#tb / 2 + tb[i]];\n\tend\n\treturn str\nend\n'

            local function generateCustomNodeArgs(chunks, data, variant)
                local shuffled, shuffledIndices = {}, {}

                for i = 1, #chunks, 1 do
                    shuffledIndices[i] = i
                end

                util.shuffle(shuffledIndices)

                for i, v in ipairs(shuffledIndices)do
                    shuffled[v] = chunks[i]
                end

                if variant == 1 then
                    local args, tbNodes = {}, {}

                    for i, v in ipairs(shuffledIndices)do
                        table.insert(args, Ast.TableEntry(Ast.NumberExpression(v)))
                    end
                    for i, chunk in ipairs(shuffled)do
                        table.insert(tbNodes, Ast.TableEntry(Ast.StringExpression(chunk)))
                    end

                    local tb = Ast.TableConstructorExpression(tbNodes)

                    table.insert(args, Ast.TableEntry(tb))

                    return {
                        Ast.TableConstructorExpression(args),
                    }
                else
                    local args = {}

                    for i, v in ipairs(shuffledIndices)do
                        table.insert(args, Ast.TableEntry(Ast.NumberExpression(v)))
                    end
                    for i, chunk in ipairs(shuffled)do
                        table.insert(args, Ast.TableEntry(Ast.StringExpression(chunk)))
                    end

                    return {
                        Ast.TableConstructorExpression(args),
                    }
                end
            end
            local function generateCustomFunctionLiteral(parentScope, variant)
                local parser = Parser.new(Parser, {
                    LuaVersion = LuaVersion.Lua52,
                })

                if variant == 1 then
                    local funcDeclNode = parser.parse(parser, custom1Code).body.statements[1]
                    local funcBody, funcArgs = funcDeclNode.body, funcDeclNode.args

                    funcBody.scope:setParent(parentScope)

                    return Ast.FunctionLiteralExpression(funcArgs, funcBody)
                else
                    local funcDeclNode = parser.parse(parser, custom2Code).body.statements[1]
                    local funcBody, funcArgs = funcDeclNode.body, funcDeclNode.args

                    funcBody.scope:setParent(parentScope)

                    return Ast.FunctionLiteralExpression(funcArgs, funcBody)
                end
            end
            local function generateGlobalCustomFunctionDeclaration(ast, data)
                local parser = Parser.new(Parser, {
                    LuaVersion = LuaVersion.Lua52,
                })

                if data.customFunctionVariant == 1 then
                    local astScope, funcDeclNode = ast.body.scope, parser.parse(parser, custom1Code).body.statements[1]
                    local funcBody, funcArgs = funcDeclNode.body, funcDeclNode.args

                    funcBody.scope:setParent(astScope)

                    return Ast.LocalVariableDeclaration(astScope, {
                        data.customFuncId,
                    }, {
                        Ast.FunctionLiteralExpression(funcArgs, funcBody),
                    })
                else
                    local astScope, funcDeclNode = ast.body.scope, parser.parse(parser, custom2Code).body.statements[1]
                    local funcBody, funcArgs = funcDeclNode.body, funcDeclNode.args

                    funcBody.scope:setParent(astScope)

                    return Ast.LocalVariableDeclaration(data.customFuncScope, {
                        data.customFuncId,
                    }, {
                        Ast.FunctionLiteralExpression(funcArgs, funcBody),
                    })
                end
            end

            function SplitStrings.variant(self)
                return math.random(1, customVariants)
            end
            function SplitStrings.apply(self, ast, pipeline)
                local data = {}

                if (self.ConcatenationType == 'table') then
                    local scope = ast.body.scope
                    local id = scope.addVariable(scope)

                    data.tableConcatScope = scope
                    data.tableConcatId = id
                elseif (self.ConcatenationType == 'custom') then
                    data.customFunctionType = self.CustomFunctionType

                    if data.customFunctionType == 'global' then
                        local scope = ast.body.scope
                        local id = scope.addVariable(scope)

                        data.customFuncScope = scope
                        data.customFuncId = id
                        data.customFunctionVariant = self.variant(self)
                    end
                end

                local customLocalFunctionsCount, self2 = self.CustomLocalFunctionsCount, self

                visitAst(ast, function(node, data)
                    if (self.ConcatenationType == 'custom' and data.customFunctionType == 'local' and node.kind == Ast.AstKind.Block and node.isFunctionBlock) then
                        data.functionData.localFunctions = {}

                        for i = 1, customLocalFunctionsCount, 1 do
                            local scope = data.scope
                            local id, variant = scope.addVariable(scope), self.variant(self)

                            table.insert(data.functionData.localFunctions, {
                                scope = scope,
                                id = id,
                                variant = variant,
                                used = false,
                            })
                        end
                    end
                end, function(node, data)
                    if (self.ConcatenationType == 'custom' and data.customFunctionType == 'local' and node.kind == Ast.AstKind.Block and node.isFunctionBlock) then
                        for i, func in ipairs(data.functionData.localFunctions)do
                            if func.used then
                                local literal = generateCustomFunctionLiteral(func.scope, func.variant)

                                table.insert(node.statements, 1, Ast.LocalVariableDeclaration(func.scope, {
                                    func.id,
                                }, {literal}))
                            end
                        end
                    end
                    if (node.kind == Ast.AstKind.StringExpression) then
                        local str, chunks, i = node.value, {}, 1

                        while i <= string.len(str) do
                            local len = math.random(self.MinLength, self.MaxLength)

                            table.insert(chunks, string.sub(str, i, i + len - 1))

                            i = i + len
                        end

                        if (#chunks > 1) then
                            if math.random() < self.Treshold then
                                if self.ConcatenationType == 'strcat' then
                                    node = generateStrCatNode(chunks)
                                elseif self.ConcatenationType == 'table' then
                                    node = generateTableConcatNode(chunks, data)
                                elseif self.ConcatenationType == 'custom' then
                                    if self.CustomFunctionType == 'global' then
                                        local args = generateCustomNodeArgs(chunks, data, data.customFunctionVariant)

                                        data.scope:addReferenceToHigherScope(data.customFuncScope, data.customFuncId)

                                        node = Ast.FunctionCallExpression(Ast.VariableExpression(data.customFuncScope, data.customFuncId), args)
                                    elseif self.CustomFunctionType == 'local' then
                                        local lfuncs = data.functionData.localFunctions
                                        local idx = math.random(1, #lfuncs)
                                        local func = lfuncs[idx]
                                        local args = generateCustomNodeArgs(chunks, data, func.variant)

                                        func.used = true

                                        data.scope:addReferenceToHigherScope(func.scope, func.id)

                                        node = Ast.FunctionCallExpression(Ast.VariableExpression(func.scope, func.id), args)
                                    elseif self.CustomFunctionType == 'inline' then
                                        local variant = self.variant(self)
                                        local args, literal = generateCustomNodeArgs(chunks, data, variant), generateCustomFunctionLiteral(data.scope, variant)

                                        node = Ast.FunctionCallExpression(literal, args)
                                    end
                                end
                            end
                        end

                        return node, true
                    end
                end, data)

                if (self.ConcatenationType == 'table') then
                    local globalScope = data.globalScope
                    local tableScope, tableId = globalScope.resolve(globalScope, 'table')

                    ast.body.scope:addReferenceToHigherScope(globalScope, tableId)
                    table.insert(ast.body.statements, 1, Ast.LocalVariableDeclaration(data.tableConcatScope, {
                        data.tableConcatId,
                    }, {
                        Ast.IndexExpression(Ast.VariableExpression(tableScope, tableId), Ast.StringExpression'concat'),
                    }))
                elseif (self.ConcatenationType == 'custom' and self.CustomFunctionType == 'global') then
                    table.insert(ast.body.statements, 1, generateGlobalCustomFunctionDeclaration(ast, data))
                end
            end

            return SplitStrings
        end

        function __DARKLUA_BUNDLE_MODULES.u()
            local v = __DARKLUA_BUNDLE_MODULES.cache.u

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.u = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Ast, utils = __DARKLUA_BUNDLE_MODULES.b(), __DARKLUA_BUNDLE_MODULES.f()
            local charset = utils.chararray
[[qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890]]

            local function randomString(wordsOrLen)
                if type(wordsOrLen) == 'table' then
                    return wordsOrLen[math.random(1, #wordsOrLen)]
                end

                wordsOrLen = wordsOrLen or math.random(2, 15)

                if wordsOrLen > 0 then
                    return randomString(wordsOrLen - 1) .. charset[math.random(1, #charset)]
                else
                    return ''
                end
            end
            local function randomStringNode(wordsOrLen)
                return Ast.StringExpression(randomString(wordsOrLen))
            end

            return {
                randomString = randomString,
                randomStringNode = randomStringNode,
            }
        end

        function __DARKLUA_BUNDLE_MODULES.v()
            local v = __DARKLUA_BUNDLE_MODULES.cache.v

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.v = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local MAX_REGS, MAX_REGS_MUL, Compiler, Ast, Scope, logger, util, visitast, randomStrings = 100, 0, {}, __DARKLUA_BUNDLE_MODULES.b(), __DARKLUA_BUNDLE_MODULES.i(), __DARKLUA_BUNDLE_MODULES.d(), __DARKLUA_BUNDLE_MODULES.f(), __DARKLUA_BUNDLE_MODULES.t(), __DARKLUA_BUNDLE_MODULES.v()
            local lookupify, AstKind, unpack = util.lookupify, Ast.AstKind, unpack or table.unpack

            function Compiler.new(self)
                local compiler = {
                    blocks = {},
                    registers = {},
                    activeBlock = nil,
                    registersForVar = {},
                    usedRegisters = 0,
                    maxUsedRegister = 0,
                    registerVars = {},
                    VAR_REGISTER = newproxy(false),
                    RETURN_ALL = newproxy(false),
                    POS_REGISTER = newproxy(false),
                    RETURN_REGISTER = newproxy(false),
                    UPVALUE = newproxy(false),
                    BIN_OPS = lookupify{
                        AstKind.LessThanExpression,
                        AstKind.GreaterThanExpression,
                        AstKind.LessThanOrEqualsExpression,
                        AstKind.GreaterThanOrEqualsExpression,
                        AstKind.NotEqualsExpression,
                        AstKind.EqualsExpression,
                        AstKind.StrCatExpression,
                        AstKind.AddExpression,
                        AstKind.SubExpression,
                        AstKind.MulExpression,
                        AstKind.DivExpression,
                        AstKind.ModExpression,
                        AstKind.PowExpression,
                    },
                }

                setmetatable(compiler, self)

                self.__index = self

                return compiler
            end
            function Compiler.createBlock(self)
                local id

                repeat
                    id = math.random(0, 16777216)
                until not self.usedBlockIds[id]

                self.usedBlockIds[id] = true

                local scope = Scope.new(Scope, self.containerFuncScope)
                local block = {
                    id = id,
                    statements = {},
                    scope = scope,
                    advanceToNextBlock = true,
                }

                table.insert(self.blocks, block)

                return block
            end
            function Compiler.setActiveBlock(self, block)
                self.activeBlock = block
            end
            function Compiler.addStatement(
                self,
                statement,
                writes,
                reads,
                usesUpvals
            )
                if (self.activeBlock.advanceToNextBlock) then
                    table.insert(self.activeBlock.statements, {
                        statement = statement,
                        writes = lookupify(writes),
                        reads = lookupify(reads),
                        usesUpvals = usesUpvals or false,
                    })
                end
            end
            function Compiler.compile(self, ast)
                self.blocks = {}
                self.registers = {}
                self.activeBlock = nil
                self.registersForVar = {}
                self.scopeFunctionDepths = {}
                self.maxUsedRegister = 0
                self.usedRegisters = 0
                self.registerVars = {}
                self.usedBlockIds = {}
                self.upvalVars = {}
                self.registerUsageStack = {}
                self.upvalsProxyLenReturn = math.random(-4194304, 4194304)

                local newGlobalScope = Scope.newGlobal(Scope)
                local psc, _, getfenvVar = Scope.new(Scope, newGlobalScope, nil), newGlobalScope.resolve(newGlobalScope, 'getfenv')
                local _, tableVar = newGlobalScope.resolve(newGlobalScope, 'table')
                local _, unpackVar = newGlobalScope.resolve(newGlobalScope, 'unpack')
                local _, envVar = newGlobalScope.resolve(newGlobalScope, '_ENV')
                local _, newproxyVar = newGlobalScope.resolve(newGlobalScope, 'newproxy')
                local _, setmetatableVar = newGlobalScope.resolve(newGlobalScope, 'setmetatable')
                local _, getmetatableVar = newGlobalScope.resolve(newGlobalScope, 'getmetatable')
                local _, selectVar = newGlobalScope.resolve(newGlobalScope, 'select')

                psc.addReferenceToHigherScope(psc, newGlobalScope, getfenvVar, 2)
                psc.addReferenceToHigherScope(psc, newGlobalScope, tableVar)
                psc.addReferenceToHigherScope(psc, newGlobalScope, unpackVar)
                psc.addReferenceToHigherScope(psc, newGlobalScope, envVar)
                psc.addReferenceToHigherScope(psc, newGlobalScope, newproxyVar)
                psc.addReferenceToHigherScope(psc, newGlobalScope, setmetatableVar)
                psc.addReferenceToHigherScope(psc, newGlobalScope, getmetatableVar)

                self.scope = Scope.new(Scope, psc)
                self.envVar = self.scope:addVariable()
                self.containerFuncVar = self.scope:addVariable()
                self.unpackVar = self.scope:addVariable()
                self.newproxyVar = self.scope:addVariable()
                self.setmetatableVar = self.scope:addVariable()
                self.getmetatableVar = self.scope:addVariable()
                self.selectVar = self.scope:addVariable()

                local argVar = self.scope:addVariable()

                self.containerFuncScope = Scope.new(Scope, self.scope)
                self.whileScope = Scope.new(Scope, self.containerFuncScope)
                self.posVar = self.containerFuncScope:addVariable()
                self.argsVar = self.containerFuncScope:addVariable()
                self.currentUpvaluesVar = self.containerFuncScope:addVariable()
                self.detectGcCollectVar = self.containerFuncScope:addVariable()
                self.returnVar = self.containerFuncScope:addVariable()
                self.upvaluesTable = self.scope:addVariable()
                self.upvaluesReferenceCountsTable = self.scope:addVariable()
                self.allocUpvalFunction = self.scope:addVariable()
                self.currentUpvalId = self.scope:addVariable()
                self.upvaluesProxyFunctionVar = self.scope:addVariable()
                self.upvaluesGcFunctionVar = self.scope:addVariable()
                self.freeUpvalueFunc = self.scope:addVariable()
                self.createClosureVars = {}
                self.createVarargClosureVar = self.scope:addVariable()

                local createClosureScope = Scope.new(Scope, self.scope)
                local createClosurePosArg, createClosureUpvalsArg, createClosureProxyObject, createClosureFuncVar, createClosureSubScope, upvalEntries, upvalueIds = createClosureScope.addVariable(createClosureScope), createClosureScope.addVariable(createClosureScope), createClosureScope.addVariable(createClosureScope), createClosureScope.addVariable(createClosureScope), Scope.new(Scope, createClosureScope), {}, {}

                self.getUpvalueId = function(self, scope, id)
                    local expression, scopeFuncDepth = nil, self.scopeFunctionDepths[scope]

                    if (scopeFuncDepth == 0) then
                        if upvalueIds[id] then
                            return upvalueIds[id]
                        end

                        expression = Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.allocUpvalFunction), {})
                    else
                        logger.error(logger, 'Unresolved Upvalue, this error should not occur!')
                    end

                    table.insert(upvalEntries, Ast.TableEntry(expression))

                    local uid = #upvalEntries

                    upvalueIds[id] = uid

                    return uid
                end

                createClosureSubScope.addReferenceToHigherScope(createClosureSubScope, self.scope, self.containerFuncVar)
                createClosureSubScope.addReferenceToHigherScope(createClosureSubScope, createClosureScope, createClosurePosArg)
                createClosureSubScope.addReferenceToHigherScope(createClosureSubScope, createClosureScope, createClosureUpvalsArg, 1)
                createClosureScope.addReferenceToHigherScope(createClosureScope, self.scope, self.upvaluesProxyFunctionVar)
                createClosureSubScope.addReferenceToHigherScope(createClosureSubScope, createClosureScope, createClosureProxyObject)
                self.compileTopNode(self, ast)

                local functionNodeAssignments, tbl = {
                    {
                        var = Ast.AssignmentVariable(self.scope, self.containerFuncVar),
                        val = Ast.FunctionLiteralExpression({
                            Ast.VariableExpression(self.containerFuncScope, self.posVar),
                            Ast.VariableExpression(self.containerFuncScope, self.argsVar),
                            Ast.VariableExpression(self.containerFuncScope, self.currentUpvaluesVar),
                            Ast.VariableExpression(self.containerFuncScope, self.detectGcCollectVar),
                        }, self.emitContainerFuncBody(self)),
                    },
                    {
                        var = Ast.AssignmentVariable(self.scope, self.createVarargClosureVar),
                        val = Ast.FunctionLiteralExpression({
                            Ast.VariableExpression(createClosureScope, createClosurePosArg),
                            Ast.VariableExpression(createClosureScope, createClosureUpvalsArg),
                        }, Ast.Block({
                            Ast.LocalVariableDeclaration(createClosureScope, {createClosureProxyObject}, {
                                Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.upvaluesProxyFunctionVar), {
                                    Ast.VariableExpression(createClosureScope, createClosureUpvalsArg),
                                }),
                            }),
                            Ast.LocalVariableDeclaration(createClosureScope, {createClosureFuncVar}, {
                                Ast.FunctionLiteralExpression({
                                    Ast.VarargExpression(),
                                }, Ast.Block({
                                    Ast.ReturnStatement{
                                        Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.containerFuncVar), {
                                            Ast.VariableExpression(createClosureScope, createClosurePosArg),
                                            Ast.TableConstructorExpression{
                                                Ast.TableEntry(Ast.VarargExpression()),
                                            },
                                            Ast.VariableExpression(createClosureScope, createClosureUpvalsArg),
                                            Ast.VariableExpression(createClosureScope, createClosureProxyObject),
                                        }),
                                    },
                                }, createClosureSubScope)),
                            }),
                            Ast.ReturnStatement{
                                Ast.VariableExpression(createClosureScope, createClosureFuncVar),
                            },
                        }, createClosureScope)),
                    },
                    {
                        var = Ast.AssignmentVariable(self.scope, self.upvaluesTable),
                        val = Ast.TableConstructorExpression{},
                    },
                    {
                        var = Ast.AssignmentVariable(self.scope, self.upvaluesReferenceCountsTable),
                        val = Ast.TableConstructorExpression{},
                    },
                    {
                        var = Ast.AssignmentVariable(self.scope, self.allocUpvalFunction),
                        val = self.createAllocUpvalFunction(self),
                    },
                    {
                        var = Ast.AssignmentVariable(self.scope, self.currentUpvalId),
                        val = Ast.NumberExpression(0),
                    },
                    {
                        var = Ast.AssignmentVariable(self.scope, self.upvaluesProxyFunctionVar),
                        val = self.createUpvaluesProxyFunc(self),
                    },
                    {
                        var = Ast.AssignmentVariable(self.scope, self.upvaluesGcFunctionVar),
                        val = self.createUpvaluesGcFunc(self),
                    },
                    {
                        var = Ast.AssignmentVariable(self.scope, self.freeUpvalueFunc),
                        val = self.createFreeUpvalueFunc(self),
                    },
                }, {
                    Ast.VariableExpression(self.scope, self.containerFuncVar),
                    Ast.VariableExpression(self.scope, self.createVarargClosureVar),
                    Ast.VariableExpression(self.scope, self.upvaluesTable),
                    Ast.VariableExpression(self.scope, self.upvaluesReferenceCountsTable),
                    Ast.VariableExpression(self.scope, self.allocUpvalFunction),
                    Ast.VariableExpression(self.scope, self.currentUpvalId),
                    Ast.VariableExpression(self.scope, self.upvaluesProxyFunctionVar),
                    Ast.VariableExpression(self.scope, self.upvaluesGcFunctionVar),
                    Ast.VariableExpression(self.scope, self.freeUpvalueFunc),
                }

                for i, entry in pairs(self.createClosureVars)do
                    table.insert(functionNodeAssignments, entry)
                    table.insert(tbl, Ast.VariableExpression(entry.var.scope, entry.var.id))
                end

                util.shuffle(functionNodeAssignments)

                local assignmentStatLhs, assignmentStatRhs = {}, {}

                for i, v in ipairs(functionNodeAssignments)do
                    assignmentStatLhs[i] = v.var
                    assignmentStatRhs[i] = v.val
                end

                local functionNode = Ast.FunctionLiteralExpression({
                    Ast.VariableExpression(self.scope, self.envVar),
                    Ast.VariableExpression(self.scope, self.unpackVar),
                    Ast.VariableExpression(self.scope, self.newproxyVar),
                    Ast.VariableExpression(self.scope, self.setmetatableVar),
                    Ast.VariableExpression(self.scope, self.getmetatableVar),
                    Ast.VariableExpression(self.scope, self.selectVar),
                    Ast.VariableExpression(self.scope, argVar),
                    unpack(util.shuffle(tbl)),
                }, Ast.Block({
                    Ast.AssignmentStatement(assignmentStatLhs, assignmentStatRhs),
                    Ast.ReturnStatement{
                        Ast.FunctionCallExpression(Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.createVarargClosureVar), {
                            Ast.NumberExpression(self.startBlockId),
                            Ast.TableConstructorExpression(upvalEntries),
                        }), {
                            Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.unpackVar), {
                                Ast.VariableExpression(self.scope, argVar),
                            }),
                        }),
                    },
                }, self.scope))

                return Ast.TopNode(Ast.Block({
                    Ast.ReturnStatement{
                        Ast.FunctionCallExpression(functionNode, {
                            Ast.OrExpression(Ast.AndExpression(Ast.VariableExpression(newGlobalScope, getfenvVar), Ast.FunctionCallExpression(Ast.VariableExpression(newGlobalScope, getfenvVar), {})), Ast.VariableExpression(newGlobalScope, envVar)),
                            Ast.OrExpression(Ast.VariableExpression(newGlobalScope, unpackVar), Ast.IndexExpression(Ast.VariableExpression(newGlobalScope, tableVar), Ast.StringExpression'unpack')),
                            Ast.VariableExpression(newGlobalScope, newproxyVar),
                            Ast.VariableExpression(newGlobalScope, setmetatableVar),
                            Ast.VariableExpression(newGlobalScope, getmetatableVar),
                            Ast.VariableExpression(newGlobalScope, selectVar),
                            Ast.TableConstructorExpression{
                                Ast.TableEntry(Ast.VarargExpression()),
                            },
                        }),
                    },
                }, psc), newGlobalScope)
            end
            function Compiler.getCreateClosureVar(self, argCount)
                if not self.createClosureVars[argCount] then
                    local var, createClosureScope = Ast.AssignmentVariable(self.scope, self.scope:addVariable()), Scope.new(Scope, self.scope)
                    local createClosureSubScope, createClosurePosArg, createClosureUpvalsArg, createClosureProxyObject, createClosureFuncVar = Scope.new(Scope, createClosureScope), createClosureScope.addVariable(createClosureScope), createClosureScope.addVariable(createClosureScope), createClosureScope.addVariable(createClosureScope), createClosureScope.addVariable(createClosureScope)

                    createClosureSubScope.addReferenceToHigherScope(createClosureSubScope, self.scope, self.containerFuncVar)
                    createClosureSubScope.addReferenceToHigherScope(createClosureSubScope, createClosureScope, createClosurePosArg)
                    createClosureSubScope.addReferenceToHigherScope(createClosureSubScope, createClosureScope, createClosureUpvalsArg, 1)
                    createClosureScope.addReferenceToHigherScope(createClosureScope, self.scope, self.upvaluesProxyFunctionVar)
                    createClosureSubScope.addReferenceToHigherScope(createClosureSubScope, createClosureScope, createClosureProxyObject)

                    local argsTb, argsTb2 = {}, {}

                    for i = 1, argCount do
                        local arg = createClosureSubScope.addVariable(createClosureSubScope)

                        argsTb[i] = Ast.VariableExpression(createClosureSubScope, arg)
                        argsTb2[i] = Ast.TableEntry(Ast.VariableExpression(createClosureSubScope, arg))
                    end

                    local val = Ast.FunctionLiteralExpression({
                        Ast.VariableExpression(createClosureScope, createClosurePosArg),
                        Ast.VariableExpression(createClosureScope, createClosureUpvalsArg),
                    }, Ast.Block({
                        Ast.LocalVariableDeclaration(createClosureScope, {createClosureProxyObject}, {
                            Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.upvaluesProxyFunctionVar), {
                                Ast.VariableExpression(createClosureScope, createClosureUpvalsArg),
                            }),
                        }),
                        Ast.LocalVariableDeclaration(createClosureScope, {createClosureFuncVar}, {
                            Ast.FunctionLiteralExpression(argsTb, Ast.Block({
                                Ast.ReturnStatement{
                                    Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.containerFuncVar), {
                                        Ast.VariableExpression(createClosureScope, createClosurePosArg),
                                        Ast.TableConstructorExpression(argsTb2),
                                        Ast.VariableExpression(createClosureScope, createClosureUpvalsArg),
                                        Ast.VariableExpression(createClosureScope, createClosureProxyObject),
                                    }),
                                },
                            }, createClosureSubScope)),
                        }),
                        Ast.ReturnStatement{
                            Ast.VariableExpression(createClosureScope, createClosureFuncVar),
                        },
                    }, createClosureScope))

                    self.createClosureVars[argCount] = {
                        var = var,
                        val = val,
                    }
                end

                local var = self.createClosureVars[argCount].var

                return var.scope, var.id
            end
            function Compiler.pushRegisterUsageInfo(self)
                table.insert(self.registerUsageStack, {
                    usedRegisters = self.usedRegisters,
                    registers = self.registers,
                })

                self.usedRegisters = 0
                self.registers = {}
            end
            function Compiler.popRegisterUsageInfo(self)
                local info = table.remove(self.registerUsageStack)

                self.usedRegisters = info.usedRegisters
                self.registers = info.registers
            end
            function Compiler.createUpvaluesGcFunc(self)
                local scope = Scope.new(Scope, self.scope)
                local selfVar, iteratorVar, valueVar, whileScope = scope.addVariable(scope), scope.addVariable(scope), scope.addVariable(scope), Scope.new(Scope, scope)

                whileScope.addReferenceToHigherScope(whileScope, self.scope, self.upvaluesReferenceCountsTable, 3)
                whileScope.addReferenceToHigherScope(whileScope, scope, valueVar, 3)
                whileScope.addReferenceToHigherScope(whileScope, scope, iteratorVar, 3)

                local ifScope = Scope.new(Scope, whileScope)

                ifScope.addReferenceToHigherScope(ifScope, self.scope, self.upvaluesReferenceCountsTable, 1)
                ifScope.addReferenceToHigherScope(ifScope, self.scope, self.upvaluesTable, 1)

                return Ast.FunctionLiteralExpression({
                    Ast.VariableExpression(scope, selfVar),
                }, Ast.Block({
                    Ast.LocalVariableDeclaration(scope, {iteratorVar, valueVar}, {
                        Ast.NumberExpression(1),
                        Ast.IndexExpression(Ast.VariableExpression(scope, selfVar), Ast.NumberExpression(1)),
                    }),
                    Ast.WhileStatement(Ast.Block({
                        Ast.AssignmentStatement({
                            Ast.AssignmentIndexing(Ast.VariableExpression(self.scope, self.upvaluesReferenceCountsTable), Ast.VariableExpression(scope, valueVar)),
                            Ast.AssignmentVariable(scope, iteratorVar),
                        }, {
                            Ast.SubExpression(Ast.IndexExpression(Ast.VariableExpression(self.scope, self.upvaluesReferenceCountsTable), Ast.VariableExpression(scope, valueVar)), Ast.NumberExpression(1)),
                            Ast.AddExpression(unpack(util.shuffle{
                                Ast.VariableExpression(scope, iteratorVar),
                                Ast.NumberExpression(1),
                            })),
                        }),
                        Ast.IfStatement(Ast.EqualsExpression(unpack(util.shuffle{
                            Ast.IndexExpression(Ast.VariableExpression(self.scope, self.upvaluesReferenceCountsTable), Ast.VariableExpression(scope, valueVar)),
                            Ast.NumberExpression(0),
                        })), Ast.Block({
                            Ast.AssignmentStatement({
                                Ast.AssignmentIndexing(Ast.VariableExpression(self.scope, self.upvaluesReferenceCountsTable), Ast.VariableExpression(scope, valueVar)),
                                Ast.AssignmentIndexing(Ast.VariableExpression(self.scope, self.upvaluesTable), Ast.VariableExpression(scope, valueVar)),
                            }, {
                                Ast.NilExpression(),
                                Ast.NilExpression(),
                            }),
                        }, ifScope), {}, nil),
                        Ast.AssignmentStatement({
                            Ast.AssignmentVariable(scope, valueVar),
                        }, {
                            Ast.IndexExpression(Ast.VariableExpression(scope, selfVar), Ast.VariableExpression(scope, iteratorVar)),
                        }),
                    }, whileScope), Ast.VariableExpression(scope, valueVar), scope),
                }, scope))
            end
            function Compiler.createFreeUpvalueFunc(self)
                local scope = Scope.new(Scope, self.scope)
                local argVar, ifScope = scope.addVariable(scope), Scope.new(Scope, scope)

                ifScope.addReferenceToHigherScope(ifScope, scope, argVar, 3)
                scope.addReferenceToHigherScope(scope, self.scope, self.upvaluesReferenceCountsTable, 2)

                return Ast.FunctionLiteralExpression({
                    Ast.VariableExpression(scope, argVar),
                }, Ast.Block({
                    Ast.AssignmentStatement({
                        Ast.AssignmentIndexing(Ast.VariableExpression(self.scope, self.upvaluesReferenceCountsTable), Ast.VariableExpression(scope, argVar)),
                    }, {
                        Ast.SubExpression(Ast.IndexExpression(Ast.VariableExpression(self.scope, self.upvaluesReferenceCountsTable), Ast.VariableExpression(scope, argVar)), Ast.NumberExpression(1)),
                    }),
                    Ast.IfStatement(Ast.EqualsExpression(unpack(util.shuffle{
                        Ast.IndexExpression(Ast.VariableExpression(self.scope, self.upvaluesReferenceCountsTable), Ast.VariableExpression(scope, argVar)),
                        Ast.NumberExpression(0),
                    })), Ast.Block({
                        Ast.AssignmentStatement({
                            Ast.AssignmentIndexing(Ast.VariableExpression(self.scope, self.upvaluesReferenceCountsTable), Ast.VariableExpression(scope, argVar)),
                            Ast.AssignmentIndexing(Ast.VariableExpression(self.scope, self.upvaluesTable), Ast.VariableExpression(scope, argVar)),
                        }, {
                            Ast.NilExpression(),
                            Ast.NilExpression(),
                        }),
                    }, ifScope), {}, nil),
                }, scope))
            end
            function Compiler.createUpvaluesProxyFunc(self)
                local scope = Scope.new(Scope, self.scope)

                scope.addReferenceToHigherScope(scope, self.scope, self.newproxyVar)

                local entriesVar, ifScope = scope.addVariable(scope), Scope.new(Scope, scope)
                local proxyVar, metatableVar, elseScope = ifScope.addVariable(ifScope), ifScope.addVariable(ifScope), Scope.new(Scope, scope)

                ifScope.addReferenceToHigherScope(ifScope, self.scope, self.newproxyVar)
                ifScope.addReferenceToHigherScope(ifScope, self.scope, self.getmetatableVar)
                ifScope.addReferenceToHigherScope(ifScope, self.scope, self.upvaluesGcFunctionVar)
                ifScope.addReferenceToHigherScope(ifScope, scope, entriesVar)
                elseScope.addReferenceToHigherScope(elseScope, self.scope, self.setmetatableVar)
                elseScope.addReferenceToHigherScope(elseScope, scope, entriesVar)
                elseScope.addReferenceToHigherScope(elseScope, self.scope, self.upvaluesGcFunctionVar)

                local forScope = Scope.new(Scope, scope)
                local forArg = forScope.addVariable(forScope)

                forScope.addReferenceToHigherScope(forScope, self.scope, self.upvaluesReferenceCountsTable, 2)
                forScope.addReferenceToHigherScope(forScope, scope, entriesVar, 2)

                return Ast.FunctionLiteralExpression({
                    Ast.VariableExpression(scope, entriesVar),
                }, Ast.Block({
                    Ast.ForStatement(forScope, forArg, Ast.NumberExpression(1), Ast.LenExpression(Ast.VariableExpression(scope, entriesVar)), Ast.NumberExpression(1), Ast.Block({
                        Ast.AssignmentStatement({
                            Ast.AssignmentIndexing(Ast.VariableExpression(self.scope, self.upvaluesReferenceCountsTable), Ast.IndexExpression(Ast.VariableExpression(scope, entriesVar), Ast.VariableExpression(forScope, forArg))),
                        }, {
                            Ast.AddExpression(unpack(util.shuffle{
                                Ast.IndexExpression(Ast.VariableExpression(self.scope, self.upvaluesReferenceCountsTable), Ast.IndexExpression(Ast.VariableExpression(scope, entriesVar), Ast.VariableExpression(forScope, forArg))),
                                Ast.NumberExpression(1),
                            })),
                        }),
                    }, forScope), scope),
                    Ast.IfStatement(Ast.VariableExpression(self.scope, self.newproxyVar), Ast.Block({
                        Ast.LocalVariableDeclaration(ifScope, {proxyVar}, {
                            Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.newproxyVar), {
                                Ast.BooleanExpression(true),
                            }),
                        }),
                        Ast.LocalVariableDeclaration(ifScope, {metatableVar}, {
                            Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.getmetatableVar), {
                                Ast.VariableExpression(ifScope, proxyVar),
                            }),
                        }),
                        Ast.AssignmentStatement({
                            Ast.AssignmentIndexing(Ast.VariableExpression(ifScope, metatableVar), Ast.StringExpression'__index'),
                            Ast.AssignmentIndexing(Ast.VariableExpression(ifScope, metatableVar), Ast.StringExpression'__gc'),
                            Ast.AssignmentIndexing(Ast.VariableExpression(ifScope, metatableVar), Ast.StringExpression'__len'),
                        }, {
                            Ast.VariableExpression(scope, entriesVar),
                            Ast.VariableExpression(self.scope, self.upvaluesGcFunctionVar),
                            Ast.FunctionLiteralExpression({}, Ast.Block({
                                Ast.ReturnStatement{
                                    Ast.NumberExpression(self.upvalsProxyLenReturn),
                                },
                            }, Scope.new(Scope, ifScope))),
                        }),
                        Ast.ReturnStatement{
                            Ast.VariableExpression(ifScope, proxyVar),
                        },
                    }, ifScope), {}, Ast.Block({
                        Ast.ReturnStatement{
                            Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.setmetatableVar), {
                                Ast.TableConstructorExpression{},
                                Ast.TableConstructorExpression{
                                    Ast.KeyedTableEntry(Ast.StringExpression'__gc', Ast.VariableExpression(self.scope, self.upvaluesGcFunctionVar)),
                                    Ast.KeyedTableEntry(Ast.StringExpression'__index', Ast.VariableExpression(scope, entriesVar)),
                                    Ast.KeyedTableEntry(Ast.StringExpression'__len', Ast.FunctionLiteralExpression({}, Ast.Block({
                                        Ast.ReturnStatement{
                                            Ast.NumberExpression(self.upvalsProxyLenReturn),
                                        },
                                    }, Scope.new(Scope, ifScope)))),
                                },
                            }),
                        },
                    }, elseScope)),
                }, scope))
            end
            function Compiler.createAllocUpvalFunction(self)
                local scope = Scope.new(Scope, self.scope)

                scope.addReferenceToHigherScope(scope, self.scope, self.currentUpvalId, 4)
                scope.addReferenceToHigherScope(scope, self.scope, self.upvaluesReferenceCountsTable, 1)

                return Ast.FunctionLiteralExpression({}, Ast.Block({
                    Ast.AssignmentStatement({
                        Ast.AssignmentVariable(self.scope, self.currentUpvalId),
                    }, {
                        Ast.AddExpression(unpack(util.shuffle{
                            Ast.VariableExpression(self.scope, self.currentUpvalId),
                            Ast.NumberExpression(1),
                        })),
                    }),
                    Ast.AssignmentStatement({
                        Ast.AssignmentIndexing(Ast.VariableExpression(self.scope, self.upvaluesReferenceCountsTable), Ast.VariableExpression(self.scope, self.currentUpvalId)),
                    }, {
                        Ast.NumberExpression(1),
                    }),
                    Ast.ReturnStatement{
                        Ast.VariableExpression(self.scope, self.currentUpvalId),
                    },
                }, scope))
            end
            function Compiler.emitContainerFuncBody(self)
                local blocks = {}

                util.shuffle(self.blocks)

                for _, block in ipairs(self.blocks)do
                    local id, blockstats = block.id, block.statements

                    for i = 2, #blockstats do
                        local stat = blockstats[i]
                        local reads, writes, maxShift, usesUpvals = stat.reads, stat.writes, 0, stat.usesUpvals

                        for shift = 1, i - 1 do
                            local stat2 = blockstats[i - shift]

                            if stat2.usesUpvals and usesUpvals then
                                break
                            end

                            local reads2, writes2, f = stat2.reads, stat2.writes, true

                            for r, b in pairs(reads2)do
                                if (writes[r]) then
                                    f = false

                                    break
                                end
                            end

                            if f then
                                for r, b in pairs(writes2)do
                                    if (writes[r]) then
                                        f = false

                                        break
                                    end
                                    if (reads[r]) then
                                        f = false

                                        break
                                    end
                                end
                            end
                            if not f then
                                break
                            end

                            maxShift = shift
                        end

                        local shift = math.random(0, maxShift)

                        for j = 1, shift do
                            blockstats[i - j], blockstats[i - j + 1] = blockstats[i - j + 1], blockstats[i - j]
                        end
                    end

                    blockstats = {}

                    for i, stat in ipairs(block.statements)do
                        table.insert(blockstats, stat.statement)
                    end

                    table.insert(blocks, {
                        id = id,
                        block = Ast.Block(blockstats, block.scope),
                    })
                end

                table.sort(blocks, function(a, b)
                    return a.id < b.id
                end)

                local function buildIfBlock(scope, id, lBlock, rBlock)
                    return Ast.Block({
                        Ast.IfStatement(Ast.LessThanExpression(self.pos(self, scope), Ast.NumberExpression(id)), lBlock, {}, rBlock),
                    }, scope)
                end
                local function buildWhileBody(tb, l, r, pScope, scope)
                    local len = r - l + 1

                    if len == 1 then
                        tb[r].block.scope:setParent(pScope)

                        return tb[r].block
                    elseif len == 0 then
                        return nil
                    end

                    local mid = l + math.ceil(len / 2)
                    local bound, ifScope = math.random(tb[mid - 1].id + 1, tb[mid].id), scope or Scope.new(Scope, pScope)
                    local lBlock, rBlock = buildWhileBody(tb, l, mid - 1, ifScope), buildWhileBody(tb, mid, r, ifScope)

                    return buildIfBlock(ifScope, bound, lBlock, rBlock)
                end

                local whileBody = buildWhileBody(blocks, 1, #blocks, self.containerFuncScope, self.whileScope)

                self.whileScope:addReferenceToHigherScope(self.containerFuncScope, self.returnVar, 1)
                self.whileScope:addReferenceToHigherScope(self.containerFuncScope, self.posVar)
                self.containerFuncScope:addReferenceToHigherScope(self.scope, self.unpackVar)

                local declarations = {
                    self.returnVar,
                }

                for i, var in pairs(self.registerVars)do
                    if (i ~= MAX_REGS) then
                        table.insert(declarations, var)
                    end
                end

                local stats = {
                    Ast.LocalVariableDeclaration(self.containerFuncScope, util.shuffle(declarations), {}),
                    Ast.WhileStatement(whileBody, Ast.VariableExpression(self.containerFuncScope, self.posVar)),
                    Ast.AssignmentStatement({
                        Ast.AssignmentVariable(self.containerFuncScope, self.posVar),
                    }, {
                        Ast.LenExpression(Ast.VariableExpression(self.containerFuncScope, self.detectGcCollectVar)),
                    }),
                    Ast.ReturnStatement{
                        Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.unpackVar), {
                            Ast.VariableExpression(self.containerFuncScope, self.returnVar),
                        }),
                    },
                }

                if self.maxUsedRegister >= MAX_REGS then
                    table.insert(stats, 1, Ast.LocalVariableDeclaration(self.containerFuncScope, {
                        self.registerVars[MAX_REGS],
                    }, {
                        Ast.TableConstructorExpression{},
                    }))
                end

                return Ast.Block(stats, self.containerFuncScope)
            end
            function Compiler.freeRegister(self, id, force)
                if force or not (self.registers[id] == self.VAR_REGISTER) then
                    self.usedRegisters = self.usedRegisters - 1
                    self.registers[id] = false
                end
            end
            function Compiler.isVarRegister(self, id)
                return self.registers[id] == self.VAR_REGISTER
            end
            function Compiler.allocRegister(self, isVar)
                self.usedRegisters = self.usedRegisters + 1

                if not isVar then
                    if not self.registers[self.POS_REGISTER] then
                        self.registers[self.POS_REGISTER] = true

                        return self.POS_REGISTER
                    end
                    if not self.registers[self.RETURN_REGISTER] then
                        self.registers[self.RETURN_REGISTER] = true

                        return self.RETURN_REGISTER
                    end
                end

                local id = 0

                if self.usedRegisters < MAX_REGS * MAX_REGS_MUL then
                    repeat
                        id = math.random(1, MAX_REGS - 1)
                    until not self.registers[id]
                else
                    repeat
                        id = id + 1
                    until not self.registers[id]
                end
                if id > self.maxUsedRegister then
                    self.maxUsedRegister = id
                end
                if (isVar) then
                    self.registers[id] = self.VAR_REGISTER
                else
                    self.registers[id] = true
                end

                return id
            end
            function Compiler.isUpvalue(self, scope, id)
                return self.upvalVars[scope] and self.upvalVars[scope][id]
            end
            function Compiler.makeUpvalue(self, scope, id)
                if (not self.upvalVars[scope]) then
                    self.upvalVars[scope] = {}
                end

                self.upvalVars[scope][id] = true
            end
            function Compiler.getVarRegister(
                self,
                scope,
                id,
                functionDepth,
                potentialId
            )
                if (not self.registersForVar[scope]) then
                    self.registersForVar[scope] = {}
                    self.scopeFunctionDepths[scope] = functionDepth
                end

                local reg = self.registersForVar[scope][id]

                if not reg then
                    if potentialId and self.registers[potentialId] ~= self.VAR_REGISTER and potentialId ~= self.POS_REGISTER and potentialId ~= self.RETURN_REGISTER then
                        self.registers[potentialId] = self.VAR_REGISTER
                        reg = potentialId
                    else
                        reg = self.allocRegister(self, true)
                    end

                    self.registersForVar[scope][id] = reg
                end

                return reg
            end
            function Compiler.getRegisterVarId(self, id)
                local varId = self.registerVars[id]

                if not varId then
                    varId = self.containerFuncScope:addVariable()
                    self.registerVars[id] = varId
                end

                return varId
            end
            function Compiler.register(self, scope, id)
                if id == self.POS_REGISTER then
                    return self.pos(self, scope)
                end
                if id == self.RETURN_REGISTER then
                    return self.getReturn(self, scope)
                end
                if id < MAX_REGS then
                    local vid = self.getRegisterVarId(self, id)

                    scope.addReferenceToHigherScope(scope, self.containerFuncScope, vid)

                    return Ast.VariableExpression(self.containerFuncScope, vid)
                end

                local vid = self.getRegisterVarId(self, MAX_REGS)

                scope.addReferenceToHigherScope(scope, self.containerFuncScope, vid)

                return Ast.IndexExpression(Ast.VariableExpression(self.containerFuncScope, vid), Ast.NumberExpression((id - MAX_REGS) + 1))
            end
            function Compiler.registerList(self, scope, ids)
                local l = {}

                for i, id in ipairs(ids)do
                    table.insert(l, self.register(self, scope, id))
                end

                return l
            end
            function Compiler.registerAssignment(self, scope, id)
                if id == self.POS_REGISTER then
                    return self.posAssignment(self, scope)
                end
                if id == self.RETURN_REGISTER then
                    return self.returnAssignment(self, scope)
                end
                if id < MAX_REGS then
                    local vid = self.getRegisterVarId(self, id)

                    scope.addReferenceToHigherScope(scope, self.containerFuncScope, vid)

                    return Ast.AssignmentVariable(self.containerFuncScope, vid)
                end

                local vid = self.getRegisterVarId(self, MAX_REGS)

                scope.addReferenceToHigherScope(scope, self.containerFuncScope, vid)

                return Ast.AssignmentIndexing(Ast.VariableExpression(self.containerFuncScope, vid), Ast.NumberExpression((id - MAX_REGS) + 1))
            end
            function Compiler.setRegister(self, scope, id, val, compundArg)
                if (compundArg) then
                    return compundArg(self.registerAssignment(self, scope, id), val)
                end

                return Ast.AssignmentStatement({
                    self.registerAssignment(self, scope, id),
                }, {val})
            end
            function Compiler.setRegisters(self, scope, ids, vals)
                local idStats = {}

                for i, id in ipairs(ids)do
                    table.insert(idStats, self.registerAssignment(self, scope, id))
                end

                return Ast.AssignmentStatement(idStats, vals)
            end
            function Compiler.copyRegisters(self, scope, to, from)
                local idStats, vals = {}, {}

                for i, id in ipairs(to)do
                    local from = from[i]

                    if (from ~= id) then
                        table.insert(idStats, self.registerAssignment(self, scope, id))
                        table.insert(vals, self.register(self, scope, from))
                    end
                end

                if (#idStats > 0 and #vals > 0) then
                    return Ast.AssignmentStatement(idStats, vals)
                end
            end
            function Compiler.resetRegisters(self)
                self.registers = {}
            end
            function Compiler.pos(self, scope)
                scope.addReferenceToHigherScope(scope, self.containerFuncScope, self.posVar)

                return Ast.VariableExpression(self.containerFuncScope, self.posVar)
            end
            function Compiler.posAssignment(self, scope)
                scope.addReferenceToHigherScope(scope, self.containerFuncScope, self.posVar)

                return Ast.AssignmentVariable(self.containerFuncScope, self.posVar)
            end
            function Compiler.args(self, scope)
                scope.addReferenceToHigherScope(scope, self.containerFuncScope, self.argsVar)

                return Ast.VariableExpression(self.containerFuncScope, self.argsVar)
            end
            function Compiler.unpack(self, scope)
                scope.addReferenceToHigherScope(scope, self.scope, self.unpackVar)

                return Ast.VariableExpression(self.scope, self.unpackVar)
            end
            function Compiler.env(self, scope)
                scope.addReferenceToHigherScope(scope, self.scope, self.envVar)

                return Ast.VariableExpression(self.scope, self.envVar)
            end
            function Compiler.jmp(self, scope, to)
                scope.addReferenceToHigherScope(scope, self.containerFuncScope, self.posVar)

                return Ast.AssignmentStatement({
                    Ast.AssignmentVariable(self.containerFuncScope, self.posVar),
                }, {to})
            end
            function Compiler.setPos(self, scope, val)
                if not val then
                    local v = Ast.IndexExpression(self.env(self, scope), randomStrings.randomStringNode(math.random(12, 14)))

                    scope.addReferenceToHigherScope(scope, self.containerFuncScope, self.posVar)

                    return Ast.AssignmentStatement({
                        Ast.AssignmentVariable(self.containerFuncScope, self.posVar),
                    }, {v})
                end

                scope.addReferenceToHigherScope(scope, self.containerFuncScope, self.posVar)

                return Ast.AssignmentStatement({
                    Ast.AssignmentVariable(self.containerFuncScope, self.posVar),
                }, {
                    Ast.NumberExpression(val) or Ast.NilExpression(),
                })
            end
            function Compiler.setReturn(self, scope, val)
                scope.addReferenceToHigherScope(scope, self.containerFuncScope, self.returnVar)

                return Ast.AssignmentStatement({
                    Ast.AssignmentVariable(self.containerFuncScope, self.returnVar),
                }, {val})
            end
            function Compiler.getReturn(self, scope)
                scope.addReferenceToHigherScope(scope, self.containerFuncScope, self.returnVar)

                return Ast.VariableExpression(self.containerFuncScope, self.returnVar)
            end
            function Compiler.returnAssignment(self, scope)
                scope.addReferenceToHigherScope(scope, self.containerFuncScope, self.returnVar)

                return Ast.AssignmentVariable(self.containerFuncScope, self.returnVar)
            end
            function Compiler.setUpvalueMember(
                self,
                scope,
                idExpr,
                valExpr,
                compoundConstructor
            )
                scope.addReferenceToHigherScope(scope, self.scope, self.upvaluesTable)

                if compoundConstructor then
                    return compoundConstructor(Ast.AssignmentIndexing(Ast.VariableExpression(self.scope, self.upvaluesTable), idExpr), valExpr)
                end

                return Ast.AssignmentStatement({
                    Ast.AssignmentIndexing(Ast.VariableExpression(self.scope, self.upvaluesTable), idExpr),
                }, {valExpr})
            end
            function Compiler.getUpvalueMember(self, scope, idExpr)
                scope.addReferenceToHigherScope(scope, self.scope, self.upvaluesTable)

                return Ast.IndexExpression(Ast.VariableExpression(self.scope, self.upvaluesTable), idExpr)
            end
            function Compiler.compileTopNode(self, node)
                local startBlock = self.createBlock(self)
                local scope = startBlock.scope

                self.startBlockId = startBlock.id

                self.setActiveBlock(self, startBlock)

                local varAccessLookup, functionLookup = lookupify{
                    AstKind.AssignmentVariable,
                    AstKind.VariableExpression,
                    AstKind.FunctionDeclaration,
                    AstKind.LocalFunctionDeclaration,
                }, lookupify{
                    AstKind.FunctionDeclaration,
                    AstKind.LocalFunctionDeclaration,
                    AstKind.FunctionLiteralExpression,
                    AstKind.TopNode,
                }

                visitast(node, function(node, data)
                    if node.kind == AstKind.Block then
                        node.scope.__depth = data.functionData.depth
                    end
                    if varAccessLookup[node.kind] then
                        if not node.scope.isGlobal then
                            if node.scope.__depth < data.functionData.depth then
                                if not self.isUpvalue(self, node.scope, node.id) then
                                    self.makeUpvalue(self, node.scope, node.id)
                                end
                            end
                        end
                    end
                end, nil, nil)

                self.varargReg = self.allocRegister(self, true)

                scope.addReferenceToHigherScope(scope, self.containerFuncScope, self.argsVar)
                scope.addReferenceToHigherScope(scope, self.scope, self.selectVar)
                scope.addReferenceToHigherScope(scope, self.scope, self.unpackVar)
                self.addStatement(self, self.setRegister(self, scope, self.varargReg, Ast.VariableExpression(self.containerFuncScope, self.argsVar)), {
                    self.varargReg,
                }, {}, false)
                self.compileBlock(self, node.body, 0)

                if (self.activeBlock.advanceToNextBlock) then
                    self.addStatement(self, self.setPos(self, self.activeBlock.scope, nil), {
                        self.POS_REGISTER,
                    }, {}, false)
                    self.addStatement(self, self.setReturn(self, self.activeBlock.scope, Ast.TableConstructorExpression{}), {
                        self.RETURN_REGISTER,
                    }, {}, false)

                    self.activeBlock.advanceToNextBlock = false
                end

                self.resetRegisters(self)
            end
            function Compiler.compileFunction(self, node, funcDepth)
                funcDepth = funcDepth + 1

                local oldActiveBlock, upperVarargReg = self.activeBlock, self.varargReg

                self.varargReg = nil

                local upvalueExpressions, upvalueIds, usedRegs, oldGetUpvalueId = {}, {}, {}, self.getUpvalueId

                self.getUpvalueId = function(self, scope, id)
                    if (not upvalueIds[scope]) then
                        upvalueIds[scope] = {}
                    end
                    if (upvalueIds[scope][id]) then
                        return upvalueIds[scope][id]
                    end

                    local scopeFuncDepth, expression = self.scopeFunctionDepths[scope], nil

                    if (scopeFuncDepth == funcDepth) then
                        oldActiveBlock.scope:addReferenceToHigherScope(self.scope, self.allocUpvalFunction)

                        expression = Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.allocUpvalFunction), {})
                    elseif (scopeFuncDepth == funcDepth - 1) then
                        local varReg = self.getVarRegister(self, scope, id, scopeFuncDepth, nil)

                        expression = self.register(self, oldActiveBlock.scope, varReg)

                        table.insert(usedRegs, varReg)
                    else
                        local higherId = oldGetUpvalueId(self, scope, id)

                        oldActiveBlock.scope:addReferenceToHigherScope(self.containerFuncScope, self.currentUpvaluesVar)

                        expression = Ast.IndexExpression(Ast.VariableExpression(self.containerFuncScope, self.currentUpvaluesVar), Ast.NumberExpression(higherId))
                    end

                    table.insert(upvalueExpressions, Ast.TableEntry(expression))

                    local uid = #upvalueExpressions

                    upvalueIds[scope][id] = uid

                    return uid
                end

                local block = self.createBlock(self)

                self.setActiveBlock(self, block)

                local scope = self.activeBlock.scope

                self.pushRegisterUsageInfo(self)

                for i, arg in ipairs(node.args)do
                    if (arg.kind == AstKind.VariableExpression) then
                        if (self.isUpvalue(self, arg.scope, arg.id)) then
                            scope.addReferenceToHigherScope(scope, self.scope, self.allocUpvalFunction)

                            local argReg = self.getVarRegister(self, arg.scope, arg.id, funcDepth, nil)

                            self.addStatement(self, self.setRegister(self, scope, argReg, Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.allocUpvalFunction), {})), {argReg}, {}, false)
                            self.addStatement(self, self.setUpvalueMember(self, scope, self.register(self, scope, argReg), Ast.IndexExpression(Ast.VariableExpression(self.containerFuncScope, self.argsVar), Ast.NumberExpression(i))), {}, {argReg}, true)
                        else
                            local argReg = self.getVarRegister(self, arg.scope, arg.id, funcDepth, nil)

                            scope.addReferenceToHigherScope(scope, self.containerFuncScope, self.argsVar)
                            self.addStatement(self, self.setRegister(self, scope, argReg, Ast.IndexExpression(Ast.VariableExpression(self.containerFuncScope, self.argsVar), Ast.NumberExpression(i))), {argReg}, {}, false)
                        end
                    else
                        self.varargReg = self.allocRegister(self, true)

                        scope.addReferenceToHigherScope(scope, self.containerFuncScope, self.argsVar)
                        scope.addReferenceToHigherScope(scope, self.scope, self.selectVar)
                        scope.addReferenceToHigherScope(scope, self.scope, self.unpackVar)
                        self.addStatement(self, self.setRegister(self, scope, self.varargReg, Ast.TableConstructorExpression{
                            Ast.TableEntry(Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.selectVar), {
                                Ast.NumberExpression(i),
                                Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.unpackVar), {
                                    Ast.VariableExpression(self.containerFuncScope, self.argsVar),
                                }),
                            })),
                        }), {
                            self.varargReg,
                        }, {}, false)
                    end
                end

                self.compileBlock(self, node.body, funcDepth)

                if (self.activeBlock.advanceToNextBlock) then
                    self.addStatement(self, self.setPos(self, self.activeBlock.scope, nil), {
                        self.POS_REGISTER,
                    }, {}, false)
                    self.addStatement(self, self.setReturn(self, self.activeBlock.scope, Ast.TableConstructorExpression{}), {
                        self.RETURN_REGISTER,
                    }, {}, false)

                    self.activeBlock.advanceToNextBlock = false
                end
                if (self.varargReg) then
                    self.freeRegister(self, self.varargReg, true)
                end

                self.varargReg = upperVarargReg
                self.getUpvalueId = oldGetUpvalueId

                self.popRegisterUsageInfo(self)
                self.setActiveBlock(self, oldActiveBlock)

                local scope, retReg, isVarargFunction, retrieveExpression = self.activeBlock.scope, self.allocRegister(self, false), #node.args > 0 and node.args[#node.args].kind == AstKind.VarargExpression, nil

                if isVarargFunction then
                    scope.addReferenceToHigherScope(scope, self.scope, self.createVarargClosureVar)

                    retrieveExpression = Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.createVarargClosureVar), {
                        Ast.NumberExpression(block.id),
                        Ast.TableConstructorExpression(upvalueExpressions),
                    })
                else
                    local varScope, var = self.getCreateClosureVar(self, #node.args + math.random(0, 5))

                    scope.addReferenceToHigherScope(scope, varScope, var)

                    retrieveExpression = Ast.FunctionCallExpression(Ast.VariableExpression(varScope, var), {
                        Ast.NumberExpression(block.id),
                        Ast.TableConstructorExpression(upvalueExpressions),
                    })
                end

                self.addStatement(self, self.setRegister(self, scope, retReg, retrieveExpression), {retReg}, usedRegs, false)

                return retReg
            end
            function Compiler.compileBlock(self, block, funcDepth)
                for i, stat in ipairs(block.statements)do
                    self.compileStatement(self, stat, funcDepth)
                end

                local scope = self.activeBlock.scope

                for id, name in ipairs(block.scope.variables)do
                    local varReg = self.getVarRegister(self, block.scope, id, funcDepth, nil)

                    if self.isUpvalue(self, block.scope, id) then
                        scope.addReferenceToHigherScope(scope, self.scope, self.freeUpvalueFunc)
                        self.addStatement(self, self.setRegister(self, scope, varReg, Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.freeUpvalueFunc), {
                            self.register(self, scope, varReg),
                        })), {varReg}, {varReg}, false)
                    else
                        self.addStatement(self, self.setRegister(self, scope, varReg, Ast.NilExpression()), {varReg}, {}, false)
                    end

                    self.freeRegister(self, varReg, true)
                end
            end
            function Compiler.compileStatement(self, statement, funcDepth)
                local scope = self.activeBlock.scope

                if (statement.kind == AstKind.ReturnStatement) then
                    local entries, regs = {}, {}

                    for i, expr in ipairs(statement.args)do
                        if i == #statement.args and (expr.kind == AstKind.FunctionCallExpression or expr.kind == AstKind.PassSelfFunctionCallExpression or expr.kind == AstKind.VarargExpression) then
                            local reg = self.compileExpression(self, expr, funcDepth, self.RETURN_ALL)[1]

                            table.insert(entries, Ast.TableEntry(Ast.FunctionCallExpression(self.unpack(self, scope), {
                                self.register(self, scope, reg),
                            })))
                            table.insert(regs, reg)
                        else
                            local reg = self.compileExpression(self, expr, funcDepth, 1)[1]

                            table.insert(entries, Ast.TableEntry(self.register(self, scope, reg)))
                            table.insert(regs, reg)
                        end
                    end
                    for _, reg in ipairs(regs)do
                        self.freeRegister(self, reg, false)
                    end

                    self.addStatement(self, self.setReturn(self, scope, Ast.TableConstructorExpression(entries)), {
                        self.RETURN_REGISTER,
                    }, regs, false)
                    self.addStatement(self, self.setPos(self, self.activeBlock.scope, nil), {
                        self.POS_REGISTER,
                    }, {}, false)

                    self.activeBlock.advanceToNextBlock = false

                    return
                end
                if (statement.kind == AstKind.LocalVariableDeclaration) then
                    local exprregs = {}

                    for i, expr in ipairs(statement.expressions)do
                        if (i == #statement.expressions and #statement.ids > #statement.expressions) then
                            local regs = self.compileExpression(self, expr, funcDepth, #statement.ids - #statement.expressions + 1)

                            for i, reg in ipairs(regs)do
                                table.insert(exprregs, reg)
                            end
                        else
                            if statement.ids[i] or expr.kind == AstKind.FunctionCallExpression or expr.kind == AstKind.PassSelfFunctionCallExpression then
                                local reg = self.compileExpression(self, expr, funcDepth, 1)[1]

                                table.insert(exprregs, reg)
                            end
                        end
                    end

                    if #exprregs == 0 then
                        for i = 1, #statement.ids do
                            table.insert(exprregs, self.compileExpression(self, Ast.NilExpression(), funcDepth, 1)[1])
                        end
                    end

                    for i, id in ipairs(statement.ids)do
                        if (exprregs[i]) then
                            if (self.isUpvalue(self, statement.scope, id)) then
                                local varreg, varReg = self.getVarRegister(self, statement.scope, id, funcDepth), self.getVarRegister(self, statement.scope, id, funcDepth, nil)

                                scope.addReferenceToHigherScope(scope, self.scope, self.allocUpvalFunction)
                                self.addStatement(self, self.setRegister(self, scope, varReg, Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.allocUpvalFunction), {})), {varReg}, {}, false)
                                self.addStatement(self, self.setUpvalueMember(self, scope, self.register(self, scope, varReg), self.register(self, scope, exprregs[i])), {}, {
                                    varReg,
                                    exprregs[i],
                                }, true)
                                self.freeRegister(self, exprregs[i], false)
                            else
                                local varreg = self.getVarRegister(self, statement.scope, id, funcDepth, exprregs[i])

                                self.addStatement(self, self.copyRegisters(self, scope, {varreg}, {
                                    exprregs[i],
                                }), {varreg}, {
                                    exprregs[i],
                                }, false)
                                self.freeRegister(self, exprregs[i], false)
                            end
                        end
                    end

                    if not self.scopeFunctionDepths[statement.scope] then
                        self.scopeFunctionDepths[statement.scope] = funcDepth
                    end

                    return
                end
                if (statement.kind == AstKind.FunctionCallStatement) then
                    local baseReg, retReg, regs, args = self.compileExpression(self, statement.base, funcDepth, 1)[1], self.allocRegister(self, false), {}, {}

                    for i, expr in ipairs(statement.args)do
                        if i == #statement.args and (expr.kind == AstKind.FunctionCallExpression or expr.kind == AstKind.PassSelfFunctionCallExpression or expr.kind == AstKind.VarargExpression) then
                            local reg = self.compileExpression(self, expr, funcDepth, self.RETURN_ALL)[1]

                            table.insert(args, Ast.FunctionCallExpression(self.unpack(self, scope), {
                                self.register(self, scope, reg),
                            }))
                            table.insert(regs, reg)
                        else
                            local reg = self.compileExpression(self, expr, funcDepth, 1)[1]

                            table.insert(args, self.register(self, scope, reg))
                            table.insert(regs, reg)
                        end
                    end

                    self.addStatement(self, self.setRegister(self, scope, retReg, Ast.FunctionCallExpression(self.register(self, scope, baseReg), args)), {retReg}, {
                        baseReg,
                        unpack(regs),
                    }, true)
                    self.freeRegister(self, baseReg, false)
                    self.freeRegister(self, retReg, false)

                    for i, reg in ipairs(regs)do
                        self.freeRegister(self, reg, false)
                    end

                    return
                end
                if (statement.kind == AstKind.PassSelfFunctionCallStatement) then
                    local baseReg, tmpReg = self.compileExpression(self, statement.base, funcDepth, 1)[1], self.allocRegister(self, false)
                    local args, regs = {
                        self.register(self, scope, baseReg),
                    }, {baseReg}

                    for i, expr in ipairs(statement.args)do
                        if i == #statement.args and (expr.kind == AstKind.FunctionCallExpression or expr.kind == AstKind.PassSelfFunctionCallExpression or expr.kind == AstKind.VarargExpression) then
                            local reg = self.compileExpression(self, expr, funcDepth, self.RETURN_ALL)[1]

                            table.insert(args, Ast.FunctionCallExpression(self.unpack(self, scope), {
                                self.register(self, scope, reg),
                            }))
                            table.insert(regs, reg)
                        else
                            local reg = self.compileExpression(self, expr, funcDepth, 1)[1]

                            table.insert(args, self.register(self, scope, reg))
                            table.insert(regs, reg)
                        end
                    end

                    self.addStatement(self, self.setRegister(self, scope, tmpReg, Ast.StringExpression(statement.passSelfFunctionName)), {tmpReg}, {}, false)
                    self.addStatement(self, self.setRegister(self, scope, tmpReg, Ast.IndexExpression(self.register(self, scope, baseReg), self.register(self, scope, tmpReg))), {tmpReg}, {tmpReg, baseReg}, false)
                    self.addStatement(self, self.setRegister(self, scope, tmpReg, Ast.FunctionCallExpression(self.register(self, scope, tmpReg), args)), {tmpReg}, {
                        tmpReg,
                        unpack(regs),
                    }, true)
                    self.freeRegister(self, tmpReg, false)

                    for i, reg in ipairs(regs)do
                        self.freeRegister(self, reg, false)
                    end

                    return
                end
                if (statement.kind == AstKind.LocalFunctionDeclaration) then
                    if (self.isUpvalue(self, statement.scope, statement.id)) then
                        local varReg = self.getVarRegister(self, statement.scope, statement.id, funcDepth, nil)

                        scope.addReferenceToHigherScope(scope, self.scope, self.allocUpvalFunction)
                        self.addStatement(self, self.setRegister(self, scope, varReg, Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.allocUpvalFunction), {})), {varReg}, {}, false)

                        local retReg = self.compileFunction(self, statement, funcDepth)

                        self.addStatement(self, self.setUpvalueMember(self, scope, self.register(self, scope, varReg), self.register(self, scope, retReg)), {}, {varReg, retReg}, true)
                        self.freeRegister(self, retReg, false)
                    else
                        local retReg = self.compileFunction(self, statement, funcDepth)
                        local varReg = self.getVarRegister(self, statement.scope, statement.id, funcDepth, retReg)

                        self.addStatement(self, self.copyRegisters(self, scope, {varReg}, {retReg}), {varReg}, {retReg}, false)
                        self.freeRegister(self, retReg, false)
                    end

                    return
                end
                if (statement.kind == AstKind.FunctionDeclaration) then
                    local retReg = self.compileFunction(self, statement, funcDepth)

                    if (#statement.indices > 0) then
                        local tblReg

                        if statement.scope.isGlobal then
                            tblReg = self.allocRegister(self, false)

                            self.addStatement(self, self.setRegister(self, scope, tblReg, Ast.StringExpression(statement.scope:getVariableName(statement.id))), {tblReg}, {}, false)
                            self.addStatement(self, self.setRegister(self, scope, tblReg, Ast.IndexExpression(self.env(self, scope), self.register(self, scope, tblReg))), {tblReg}, {tblReg}, true)
                        else
                            if self.scopeFunctionDepths[statement.scope] == funcDepth then
                                if self.isUpvalue(self, statement.scope, statement.id) then
                                    tblReg = self.allocRegister(self, false)

                                    local reg = self.getVarRegister(self, statement.scope, statement.id, funcDepth)

                                    self.addStatement(self, self.setRegister(self, scope, tblReg, self.getUpvalueMember(self, scope, self.register(self, scope, reg))), {tblReg}, {reg}, true)
                                else
                                    tblReg = self.getVarRegister(self, statement.scope, statement.id, funcDepth, retReg)
                                end
                            else
                                tblReg = self.allocRegister(self, false)

                                local upvalId = self.getUpvalueId(self, statement.scope, statement.id)

                                scope.addReferenceToHigherScope(scope, self.containerFuncScope, self.currentUpvaluesVar)
                                self.addStatement(self, self.setRegister(self, scope, tblReg, self.getUpvalueMember(self, scope, Ast.IndexExpression(Ast.VariableExpression(self.containerFuncScope, self.currentUpvaluesVar), Ast.NumberExpression(upvalId)))), {tblReg}, {}, true)
                            end
                        end

                        for i = 1, #statement.indices - 1 do
                            local index = statement.indices[i]
                            local indexReg, tblRegOld = self.compileExpression(self, Ast.StringExpression(index), funcDepth, 1)[1], tblReg

                            tblReg = self.allocRegister(self, false)

                            self.addStatement(self, self.setRegister(self, scope, tblReg, Ast.IndexExpression(self.register(self, scope, tblRegOld), self.register(self, scope, indexReg))), {tblReg}, {tblReg, indexReg}, false)
                            self.freeRegister(self, tblRegOld, false)
                            self.freeRegister(self, indexReg, false)
                        end

                        local index = statement.indices[#statement.indices]
                        local indexReg = self.compileExpression(self, Ast.StringExpression(index), funcDepth, 1)[1]

                        self.addStatement(self, Ast.AssignmentStatement({
                            Ast.AssignmentIndexing(self.register(self, scope, tblReg), self.register(self, scope, indexReg)),
                        }, {
                            self.register(self, scope, retReg),
                        }), {}, {tblReg, indexReg, retReg}, true)
                        self.freeRegister(self, indexReg, false)
                        self.freeRegister(self, tblReg, false)
                        self.freeRegister(self, retReg, false)

                        return
                    end
                    if statement.scope.isGlobal then
                        local tmpReg = self.allocRegister(self, false)

                        self.addStatement(self, self.setRegister(self, scope, tmpReg, Ast.StringExpression(statement.scope:getVariableName(statement.id))), {tmpReg}, {}, false)
                        self.addStatement(self, Ast.AssignmentStatement({
                            Ast.AssignmentIndexing(self.env(self, scope), self.register(self, scope, tmpReg)),
                        }, {
                            self.register(self, scope, retReg),
                        }), {}, {tmpReg, retReg}, true)
                        self.freeRegister(self, tmpReg, false)
                    else
                        if self.scopeFunctionDepths[statement.scope] == funcDepth then
                            if self.isUpvalue(self, statement.scope, statement.id) then
                                local reg = self.getVarRegister(self, statement.scope, statement.id, funcDepth)

                                self.addStatement(self, self.setUpvalueMember(self, scope, self.register(self, scope, reg), self.register(self, scope, retReg)), {}, {reg, retReg}, true)
                            else
                                local reg = self.getVarRegister(self, statement.scope, statement.id, funcDepth, retReg)

                                if reg ~= retReg then
                                    self.addStatement(self, self.setRegister(self, scope, reg, self.register(self, scope, retReg)), {reg}, {retReg}, false)
                                end
                            end
                        else
                            local upvalId = self.getUpvalueId(self, statement.scope, statement.id)

                            scope.addReferenceToHigherScope(scope, self.containerFuncScope, self.currentUpvaluesVar)
                            self.addStatement(self, self.setUpvalueMember(self, scope, Ast.IndexExpression(Ast.VariableExpression(self.containerFuncScope, self.currentUpvaluesVar), Ast.NumberExpression(upvalId)), self.register(self, scope, retReg)), {}, {retReg}, true)
                        end
                    end

                    self.freeRegister(self, retReg, false)

                    return
                end
                if (statement.kind == AstKind.AssignmentStatement) then
                    local exprregs, assignmentIndexingRegs = {}, {}

                    for i, primaryExpr in ipairs(statement.lhs)do
                        if (primaryExpr.kind == AstKind.AssignmentIndexing) then
                            assignmentIndexingRegs[i] = {
                                base = self.compileExpression(self, primaryExpr.base, funcDepth, 1)[1],
                                index = self.compileExpression(self, primaryExpr.index, funcDepth, 1)[1],
                            }
                        end
                    end
                    for i, expr in ipairs(statement.rhs)do
                        if (i == #statement.rhs and #statement.lhs > #statement.rhs) then
                            local regs = self.compileExpression(self, expr, funcDepth, #statement.lhs - #statement.rhs + 1)

                            for i, reg in ipairs(regs)do
                                if (self.isVarRegister(self, reg)) then
                                    local ro = reg

                                    reg = self.allocRegister(self, false)

                                    self.addStatement(self, self.copyRegisters(self, scope, {reg}, {ro}), {reg}, {ro}, false)
                                end

                                table.insert(exprregs, reg)
                            end
                        else
                            if statement.lhs[i] or expr.kind == AstKind.FunctionCallExpression or expr.kind == AstKind.PassSelfFunctionCallExpression then
                                local reg = self.compileExpression(self, expr, funcDepth, 1)[1]

                                if (self.isVarRegister(self, reg)) then
                                    local ro = reg

                                    reg = self.allocRegister(self, false)

                                    self.addStatement(self, self.copyRegisters(self, scope, {reg}, {ro}), {reg}, {ro}, false)
                                end

                                table.insert(exprregs, reg)
                            end
                        end
                    end
                    for i, primaryExpr in ipairs(statement.lhs)do
                        if primaryExpr.kind == AstKind.AssignmentVariable then
                            if primaryExpr.scope.isGlobal then
                                local tmpReg = self.allocRegister(self, false)

                                self.addStatement(self, self.setRegister(self, scope, tmpReg, Ast.StringExpression(primaryExpr.scope:getVariableName(primaryExpr.id))), {tmpReg}, {}, false)
                                self.addStatement(self, Ast.AssignmentStatement({
                                    Ast.AssignmentIndexing(self.env(self, scope), self.register(self, scope, tmpReg)),
                                }, {
                                    self.register(self, scope, exprregs[i]),
                                }), {}, {
                                    tmpReg,
                                    exprregs[i],
                                }, true)
                                self.freeRegister(self, tmpReg, false)
                            else
                                if self.scopeFunctionDepths[primaryExpr.scope] == funcDepth then
                                    if self.isUpvalue(self, primaryExpr.scope, primaryExpr.id) then
                                        local reg = self.getVarRegister(self, primaryExpr.scope, primaryExpr.id, funcDepth)

                                        self.addStatement(self, self.setUpvalueMember(self, scope, self.register(self, scope, reg), self.register(self, scope, exprregs[i])), {}, {
                                            reg,
                                            exprregs[i],
                                        }, true)
                                    else
                                        local reg = self.getVarRegister(self, primaryExpr.scope, primaryExpr.id, funcDepth, exprregs[i])

                                        if reg ~= exprregs[i] then
                                            self.addStatement(self, self.setRegister(self, scope, reg, self.register(self, scope, exprregs[i])), {reg}, {
                                                exprregs[i],
                                            }, false)
                                        end
                                    end
                                else
                                    local upvalId = self.getUpvalueId(self, primaryExpr.scope, primaryExpr.id)

                                    scope.addReferenceToHigherScope(scope, self.containerFuncScope, self.currentUpvaluesVar)
                                    self.addStatement(self, self.setUpvalueMember(self, scope, Ast.IndexExpression(Ast.VariableExpression(self.containerFuncScope, self.currentUpvaluesVar), Ast.NumberExpression(upvalId)), self.register(self, scope, exprregs[i])), {}, {
                                        exprregs[i],
                                    }, true)
                                end
                            end
                        elseif primaryExpr.kind == AstKind.AssignmentIndexing then
                            local baseReg, indexReg = assignmentIndexingRegs[i].base, assignmentIndexingRegs[i].index

                            self.addStatement(self, Ast.AssignmentStatement({
                                Ast.AssignmentIndexing(self.register(self, scope, baseReg), self.register(self, scope, indexReg)),
                            }, {
                                self.register(self, scope, exprregs[i]),
                            }), {}, {
                                exprregs[i],
                                baseReg,
                                indexReg,
                            }, true)
                            self.freeRegister(self, exprregs[i], false)
                            self.freeRegister(self, baseReg, false)
                            self.freeRegister(self, indexReg, false)
                        else
                            error(string.format('Invalid Assignment lhs: %s', statement.lhs))
                        end
                    end

                    return
                end
                if (statement.kind == AstKind.IfStatement) then
                    local conditionReg, finalBlock, nextBlock = self.compileExpression(self, statement.condition, funcDepth, 1)[1], self.createBlock(self), nil

                    if statement.elsebody or #statement.elseifs > 0 then
                        nextBlock = self.createBlock(self)
                    else
                        nextBlock = finalBlock
                    end

                    local innerBlock = self.createBlock(self)

                    self.addStatement(self, self.setRegister(self, scope, self.POS_REGISTER, Ast.OrExpression(Ast.AndExpression(self.register(self, scope, conditionReg), Ast.NumberExpression(innerBlock.id)), Ast.NumberExpression(nextBlock.id))), {
                        self.POS_REGISTER,
                    }, {conditionReg}, false)
                    self.freeRegister(self, conditionReg, false)
                    self.setActiveBlock(self, innerBlock)

                    scope = innerBlock.scope

                    self.compileBlock(self, statement.body, funcDepth)
                    self.addStatement(self, self.setRegister(self, scope, self.POS_REGISTER, Ast.NumberExpression(finalBlock.id)), {
                        self.POS_REGISTER,
                    }, {}, false)

                    for i, eif in ipairs(statement.elseifs)do
                        self.setActiveBlock(self, nextBlock)

                        conditionReg = self.compileExpression(self, eif.condition, funcDepth, 1)[1]

                        local innerBlock = self.createBlock(self)

                        if statement.elsebody or i < #statement.elseifs then
                            nextBlock = self.createBlock(self)
                        else
                            nextBlock = finalBlock
                        end

                        local scope = self.activeBlock.scope

                        self.addStatement(self, self.setRegister(self, scope, self.POS_REGISTER, Ast.OrExpression(Ast.AndExpression(self.register(self, scope, conditionReg), Ast.NumberExpression(innerBlock.id)), Ast.NumberExpression(nextBlock.id))), {
                            self.POS_REGISTER,
                        }, {conditionReg}, false)
                        self.freeRegister(self, conditionReg, false)
                        self.setActiveBlock(self, innerBlock)

                        scope = innerBlock.scope

                        self.compileBlock(self, eif.body, funcDepth)
                        self.addStatement(self, self.setRegister(self, scope, self.POS_REGISTER, Ast.NumberExpression(finalBlock.id)), {
                            self.POS_REGISTER,
                        }, {}, false)
                    end

                    if statement.elsebody then
                        self.setActiveBlock(self, nextBlock)
                        self.compileBlock(self, statement.elsebody, funcDepth)
                        self.addStatement(self, self.setRegister(self, scope, self.POS_REGISTER, Ast.NumberExpression(finalBlock.id)), {
                            self.POS_REGISTER,
                        }, {}, false)
                    end

                    self.setActiveBlock(self, finalBlock)

                    return
                end
                if (statement.kind == AstKind.DoStatement) then
                    self.compileBlock(self, statement.body, funcDepth)

                    return
                end
                if (statement.kind == AstKind.WhileStatement) then
                    local innerBlock, finalBlock, checkBlock = self.createBlock(self), self.createBlock(self), self.createBlock(self)

                    statement.__start_block = checkBlock
                    statement.__final_block = finalBlock

                    self.addStatement(self, self.setPos(self, scope, checkBlock.id), {
                        self.POS_REGISTER,
                    }, {}, false)
                    self.setActiveBlock(self, checkBlock)

                    local scope, conditionReg = self.activeBlock.scope, self.compileExpression(self, statement.condition, funcDepth, 1)[1]

                    self.addStatement(self, self.setRegister(self, scope, self.POS_REGISTER, Ast.OrExpression(Ast.AndExpression(self.register(self, scope, conditionReg), Ast.NumberExpression(innerBlock.id)), Ast.NumberExpression(finalBlock.id))), {
                        self.POS_REGISTER,
                    }, {conditionReg}, false)
                    self.freeRegister(self, conditionReg, false)
                    self.setActiveBlock(self, innerBlock)

                    local scope = self.activeBlock.scope

                    self.compileBlock(self, statement.body, funcDepth)
                    self.addStatement(self, self.setPos(self, scope, checkBlock.id), {
                        self.POS_REGISTER,
                    }, {}, false)
                    self.setActiveBlock(self, finalBlock)

                    return
                end
                if (statement.kind == AstKind.RepeatStatement) then
                    local innerBlock, finalBlock, checkBlock = self.createBlock(self), self.createBlock(self), self.createBlock(self)

                    statement.__start_block = checkBlock
                    statement.__final_block = finalBlock

                    local conditionReg = self.compileExpression(self, statement.condition, funcDepth, 1)[1]

                    self.addStatement(self, self.setRegister(self, scope, self.POS_REGISTER, Ast.NumberExpression(innerBlock.id)), {
                        self.POS_REGISTER,
                    }, {}, false)
                    self.freeRegister(self, conditionReg, false)
                    self.setActiveBlock(self, innerBlock)
                    self.compileBlock(self, statement.body, funcDepth)

                    local scope = self.activeBlock.scope

                    self.addStatement(self, self.setPos(self, scope, checkBlock.id), {
                        self.POS_REGISTER,
                    }, {}, false)
                    self.setActiveBlock(self, checkBlock)

                    local scope, conditionReg = self.activeBlock.scope, self.compileExpression(self, statement.condition, funcDepth, 1)[1]

                    self.addStatement(self, self.setRegister(self, scope, self.POS_REGISTER, Ast.OrExpression(Ast.AndExpression(self.register(self, scope, conditionReg), Ast.NumberExpression(finalBlock.id)), Ast.NumberExpression(innerBlock.id))), {
                        self.POS_REGISTER,
                    }, {conditionReg}, false)
                    self.freeRegister(self, conditionReg, false)
                    self.setActiveBlock(self, finalBlock)

                    return
                end
                if (statement.kind == AstKind.ForStatement) then
                    local checkBlock, innerBlock, finalBlock = self.createBlock(self), self.createBlock(self), self.createBlock(self)

                    statement.__start_block = checkBlock
                    statement.__final_block = finalBlock

                    local posState = self.registers[self.POS_REGISTER]

                    self.registers[self.POS_REGISTER] = self.VAR_REGISTER

                    local initialReg, finalExprReg, finalReg = self.compileExpression(self, statement.initialValue, funcDepth, 1)[1], self.compileExpression(self, statement.finalValue, funcDepth, 1)[1], self.allocRegister(self, false)

                    self.addStatement(self, self.copyRegisters(self, scope, {finalReg}, {finalExprReg}), {finalReg}, {finalExprReg}, false)
                    self.freeRegister(self, finalExprReg)

                    local incrementExprReg, incrementReg = self.compileExpression(self, statement.incrementBy, funcDepth, 1)[1], self.allocRegister(self, false)

                    self.addStatement(self, self.copyRegisters(self, scope, {incrementReg}, {incrementExprReg}), {incrementReg}, {incrementExprReg}, false)
                    self.freeRegister(self, incrementExprReg)

                    local tmpReg = self.allocRegister(self, false)

                    self.addStatement(self, self.setRegister(self, scope, tmpReg, Ast.NumberExpression(0)), {tmpReg}, {}, false)

                    local incrementIsNegReg = self.allocRegister(self, false)

                    self.addStatement(self, self.setRegister(self, scope, incrementIsNegReg, Ast.LessThanExpression(self.register(self, scope, incrementReg), self.register(self, scope, tmpReg))), {incrementIsNegReg}, {incrementReg, tmpReg}, false)
                    self.freeRegister(self, tmpReg)

                    local currentReg = self.allocRegister(self, true)

                    self.addStatement(self, self.setRegister(self, scope, currentReg, Ast.SubExpression(self.register(self, scope, initialReg), self.register(self, scope, incrementReg))), {currentReg}, {initialReg, incrementReg}, false)
                    self.freeRegister(self, initialReg)
                    self.addStatement(self, self.jmp(self, scope, Ast.NumberExpression(checkBlock.id)), {
                        self.POS_REGISTER,
                    }, {}, false)
                    self.setActiveBlock(self, checkBlock)

                    scope = checkBlock.scope

                    self.addStatement(self, self.setRegister(self, scope, currentReg, Ast.AddExpression(self.register(self, scope, currentReg), self.register(self, scope, incrementReg))), {currentReg}, {currentReg, incrementReg}, false)

                    local tmpReg1, tmpReg2 = self.allocRegister(self, false), self.allocRegister(self, false)

                    self.addStatement(self, self.setRegister(self, scope, tmpReg2, Ast.NotExpression(self.register(self, scope, incrementIsNegReg))), {tmpReg2}, {incrementIsNegReg}, false)
                    self.addStatement(self, self.setRegister(self, scope, tmpReg1, Ast.LessThanOrEqualsExpression(self.register(self, scope, currentReg), self.register(self, scope, finalReg))), {tmpReg1}, {currentReg, finalReg}, false)
                    self.addStatement(self, self.setRegister(self, scope, tmpReg1, Ast.AndExpression(self.register(self, scope, tmpReg2), self.register(self, scope, tmpReg1))), {tmpReg1}, {tmpReg1, tmpReg2}, false)
                    self.addStatement(self, self.setRegister(self, scope, tmpReg2, Ast.GreaterThanOrEqualsExpression(self.register(self, scope, currentReg), self.register(self, scope, finalReg))), {tmpReg2}, {currentReg, finalReg}, false)
                    self.addStatement(self, self.setRegister(self, scope, tmpReg2, Ast.AndExpression(self.register(self, scope, incrementIsNegReg), self.register(self, scope, tmpReg2))), {tmpReg2}, {tmpReg2, incrementIsNegReg}, false)
                    self.addStatement(self, self.setRegister(self, scope, tmpReg1, Ast.OrExpression(self.register(self, scope, tmpReg2), self.register(self, scope, tmpReg1))), {tmpReg1}, {tmpReg1, tmpReg2}, false)
                    self.freeRegister(self, tmpReg2)

                    tmpReg2 = self.compileExpression(self, Ast.NumberExpression(innerBlock.id), funcDepth, 1)[1]

                    self.addStatement(self, self.setRegister(self, scope, self.POS_REGISTER, Ast.AndExpression(self.register(self, scope, tmpReg1), self.register(self, scope, tmpReg2))), {
                        self.POS_REGISTER,
                    }, {tmpReg1, tmpReg2}, false)
                    self.freeRegister(self, tmpReg2)
                    self.freeRegister(self, tmpReg1)

                    tmpReg2 = self.compileExpression(self, Ast.NumberExpression(finalBlock.id), funcDepth, 1)[1]

                    self.addStatement(self, self.setRegister(self, scope, self.POS_REGISTER, Ast.OrExpression(self.register(self, scope, self.POS_REGISTER), self.register(self, scope, tmpReg2))), {
                        self.POS_REGISTER,
                    }, {
                        self.POS_REGISTER,
                        tmpReg2,
                    }, false)
                    self.freeRegister(self, tmpReg2)
                    self.setActiveBlock(self, innerBlock)

                    scope = innerBlock.scope
                    self.registers[self.POS_REGISTER] = posState

                    local varReg = self.getVarRegister(self, statement.scope, statement.id, funcDepth, nil)

                    if (self.isUpvalue(self, statement.scope, statement.id)) then
                        scope.addReferenceToHigherScope(scope, self.scope, self.allocUpvalFunction)
                        self.addStatement(self, self.setRegister(self, scope, varReg, Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.allocUpvalFunction), {})), {varReg}, {}, false)
                        self.addStatement(self, self.setUpvalueMember(self, scope, self.register(self, scope, varReg), self.register(self, scope, currentReg)), {}, {varReg, currentReg}, true)
                    else
                        self.addStatement(self, self.setRegister(self, scope, varReg, self.register(self, scope, currentReg)), {varReg}, {currentReg}, false)
                    end

                    self.compileBlock(self, statement.body, funcDepth)
                    self.addStatement(self, self.setRegister(self, scope, self.POS_REGISTER, Ast.NumberExpression(checkBlock.id)), {
                        self.POS_REGISTER,
                    }, {}, false)

                    self.registers[self.POS_REGISTER] = self.VAR_REGISTER

                    self.freeRegister(self, finalReg)
                    self.freeRegister(self, incrementIsNegReg)
                    self.freeRegister(self, incrementReg)
                    self.freeRegister(self, currentReg, true)

                    self.registers[self.POS_REGISTER] = posState

                    self.setActiveBlock(self, finalBlock)

                    return
                end
                if (statement.kind == AstKind.ForInStatement) then
                    local expressionsLength, exprregs = #statement.expressions, {}

                    for i, expr in ipairs(statement.expressions)do
                        if (i == expressionsLength and expressionsLength < 3) then
                            local regs = self.compileExpression(self, expr, funcDepth, 4 - expressionsLength)

                            for i = 1, 4 - expressionsLength do
                                table.insert(exprregs, regs[i])
                            end
                        else
                            if i <= 3 then
                                table.insert(exprregs, self.compileExpression(self, expr, funcDepth, 1)[1])
                            else
                                self.freeRegister(self, self.compileExpression(self, expr, funcDepth, 1)[1], false)
                            end
                        end
                    end
                    for i, reg in ipairs(exprregs)do
                        if reg and self.registers[reg] ~= self.VAR_REGISTER and reg ~= self.POS_REGISTER and reg ~= self.RETURN_REGISTER then
                            self.registers[reg] = self.VAR_REGISTER
                        else
                            exprregs[i] = self.allocRegister(self, true)

                            self.addStatement(self, self.copyRegisters(self, scope, {
                                exprregs[i],
                            }, {reg}), {
                                exprregs[i],
                            }, {reg}, false)
                        end
                    end

                    local checkBlock, bodyBlock, finalBlock = self.createBlock(self), self.createBlock(self), self.createBlock(self)

                    statement.__start_block = checkBlock
                    statement.__final_block = finalBlock

                    self.addStatement(self, self.setPos(self, scope, checkBlock.id), {
                        self.POS_REGISTER,
                    }, {}, false)
                    self.setActiveBlock(self, checkBlock)

                    local scope, varRegs = self.activeBlock.scope, {}

                    for i, id in ipairs(statement.ids)do
                        varRegs[i] = self.getVarRegister(self, statement.scope, id, funcDepth)
                    end

                    self.addStatement(self, Ast.AssignmentStatement({
                        self.registerAssignment(self, scope, exprregs[3]),
                        varRegs[2] and self.registerAssignment(self, scope, varRegs[2]),
                    }, {
                        Ast.FunctionCallExpression(self.register(self, scope, exprregs[1]), {
                            self.register(self, scope, exprregs[2]),
                            self.register(self, scope, exprregs[3]),
                        }),
                    }), {
                        exprregs[3],
                        varRegs[2],
                    }, {
                        exprregs[1],
                        exprregs[2],
                        exprregs[3],
                    }, true)
                    self.addStatement(self, Ast.AssignmentStatement({
                        self.posAssignment(self, scope),
                    }, {
                        Ast.OrExpression(Ast.AndExpression(self.register(self, scope, exprregs[3]), Ast.NumberExpression(bodyBlock.id)), Ast.NumberExpression(finalBlock.id)),
                    }), {
                        self.POS_REGISTER,
                    }, {
                        exprregs[3],
                    }, false)
                    self.setActiveBlock(self, bodyBlock)

                    local scope = self.activeBlock.scope

                    self.addStatement(self, self.copyRegisters(self, scope, {
                        varRegs[1],
                    }, {
                        exprregs[3],
                    }), {
                        varRegs[1],
                    }, {
                        exprregs[3],
                    }, false)

                    for i = 3, #varRegs do
                        self.addStatement(self, self.setRegister(self, scope, varRegs[i], Ast.NilExpression()), {
                            varRegs[i],
                        }, {}, false)
                    end

                    for i, id in ipairs(statement.ids)do
                        if (self.isUpvalue(self, statement.scope, id)) then
                            local varreg, tmpReg = varRegs[i], self.allocRegister(self, false)

                            scope.addReferenceToHigherScope(scope, self.scope, self.allocUpvalFunction)
                            self.addStatement(self, self.setRegister(self, scope, tmpReg, Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.allocUpvalFunction), {})), {tmpReg}, {}, false)
                            self.addStatement(self, self.setUpvalueMember(self, scope, self.register(self, scope, tmpReg), self.register(self, scope, varreg)), {}, {tmpReg, varreg}, true)
                            self.addStatement(self, self.copyRegisters(self, scope, {varreg}, {tmpReg}), {varreg}, {tmpReg}, false)
                            self.freeRegister(self, tmpReg, false)
                        end
                    end

                    self.compileBlock(self, statement.body, funcDepth)
                    self.addStatement(self, self.setPos(self, scope, checkBlock.id), {
                        self.POS_REGISTER,
                    }, {}, false)
                    self.setActiveBlock(self, finalBlock)

                    for i, reg in ipairs(exprregs)do
                        self.freeRegister(self, exprregs[i], true)
                    end

                    return
                end
                if (statement.kind == AstKind.DoStatement) then
                    self.compileBlock(self, statement.body, funcDepth)

                    return
                end
                if (statement.kind == AstKind.BreakStatement) then
                    local toFreeVars, statScope = {}, nil

                    repeat
                        statScope = statScope and statScope.parentScope or statement.scope

                        for id, name in ipairs(statScope.variables)do
                            table.insert(toFreeVars, {
                                scope = statScope,
                                id = id,
                            })
                        end
                    until statScope == statement.loop.body.scope

                    for i, var in pairs(toFreeVars)do
                        local varScope, id = var.scope, var.id
                        local varReg = self.getVarRegister(self, varScope, id, nil, nil)

                        if self.isUpvalue(self, varScope, id) then
                            scope.addReferenceToHigherScope(scope, self.scope, self.freeUpvalueFunc)
                            self.addStatement(self, self.setRegister(self, scope, varReg, Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.freeUpvalueFunc), {
                                self.register(self, scope, varReg),
                            })), {varReg}, {varReg}, false)
                        else
                            self.addStatement(self, self.setRegister(self, scope, varReg, Ast.NilExpression()), {varReg}, {}, false)
                        end
                    end

                    self.addStatement(self, self.setPos(self, scope, statement.loop.__final_block.id), {
                        self.POS_REGISTER,
                    }, {}, false)

                    self.activeBlock.advanceToNextBlock = false

                    return
                end
                if (statement.kind == AstKind.ContinueStatement) then
                    local toFreeVars, statScope = {}, nil

                    repeat
                        statScope = statScope and statScope.parentScope or statement.scope

                        for id, name in pairs(statScope.variables)do
                            table.insert(toFreeVars, {
                                scope = statScope,
                                id = id,
                            })
                        end
                    until statScope == statement.loop.body.scope

                    for i, var in ipairs(toFreeVars)do
                        local varScope, id = var.scope, var.id
                        local varReg = self.getVarRegister(self, varScope, id, nil, nil)

                        if self.isUpvalue(self, varScope, id) then
                            scope.addReferenceToHigherScope(scope, self.scope, self.freeUpvalueFunc)
                            self.addStatement(self, self.setRegister(self, scope, varReg, Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.freeUpvalueFunc), {
                                self.register(self, scope, varReg),
                            })), {varReg}, {varReg}, false)
                        else
                            self.addStatement(self, self.setRegister(self, scope, varReg, Ast.NilExpression()), {varReg}, {}, false)
                        end
                    end

                    self.addStatement(self, self.setPos(self, scope, statement.loop.__start_block.id), {
                        self.POS_REGISTER,
                    }, {}, false)

                    self.activeBlock.advanceToNextBlock = false

                    return
                end

                local compoundConstructors = {
                    [AstKind.CompoundAddStatement] = Ast.CompoundAddStatement,
                    [AstKind.CompoundSubStatement] = Ast.CompoundSubStatement,
                    [AstKind.CompoundMulStatement] = Ast.CompoundMulStatement,
                    [AstKind.CompoundDivStatement] = Ast.CompoundDivStatement,
                    [AstKind.CompoundModStatement] = Ast.CompoundModStatement,
                    [AstKind.CompoundPowStatement] = Ast.CompoundPowStatement,
                    [AstKind.CompoundConcatStatement] = Ast.CompoundConcatStatement,
                }

                if compoundConstructors[statement.kind] then
                    local compoundConstructor = compoundConstructors[statement.kind]

                    if statement.lhs.kind == AstKind.AssignmentIndexing then
                        local indexing = statement.lhs
                        local baseReg, indexReg, valueReg = self.compileExpression(self, indexing.base, funcDepth, 1)[1], self.compileExpression(self, indexing.index, funcDepth, 1)[1], self.compileExpression(self, statement.rhs, funcDepth, 1)[1]

                        self.addStatement(self, compoundConstructor(Ast.AssignmentIndexing(self.register(self, scope, baseReg), self.register(self, scope, indexReg)), self.register(self, scope, valueReg)), {}, {baseReg, indexReg, valueReg}, true)
                    else
                        local valueReg, primaryExpr = self.compileExpression(self, statement.rhs, funcDepth, 1)[1], statement.lhs

                        if primaryExpr.scope.isGlobal then
                            local tmpReg = self.allocRegister(self, false)

                            self.addStatement(self, self.setRegister(self, scope, tmpReg, Ast.StringExpression(primaryExpr.scope:getVariableName(primaryExpr.id))), {tmpReg}, {}, false)
                            self.addStatement(self, Ast.AssignmentStatement({
                                Ast.AssignmentIndexing(self.env(self, scope), self.register(self, scope, tmpReg)),
                            }, {
                                self.register(self, scope, valueReg),
                            }), {}, {tmpReg, valueReg}, true)
                            self.freeRegister(self, tmpReg, false)
                        else
                            if self.scopeFunctionDepths[primaryExpr.scope] == funcDepth then
                                if self.isUpvalue(self, primaryExpr.scope, primaryExpr.id) then
                                    local reg = self.getVarRegister(self, primaryExpr.scope, primaryExpr.id, funcDepth)

                                    self.addStatement(self, self.setUpvalueMember(self, scope, self.register(self, scope, reg), self.register(self, scope, valueReg), compoundConstructor), {}, {reg, valueReg}, true)
                                else
                                    local reg = self.getVarRegister(self, primaryExpr.scope, primaryExpr.id, funcDepth, valueReg)

                                    if reg ~= valueReg then
                                        self.addStatement(self, self.setRegister(self, scope, reg, self.register(self, scope, valueReg), compoundConstructor), {reg}, {valueReg}, false)
                                    end
                                end
                            else
                                local upvalId = self.getUpvalueId(self, primaryExpr.scope, primaryExpr.id)

                                scope.addReferenceToHigherScope(scope, self.containerFuncScope, self.currentUpvaluesVar)
                                self.addStatement(self, self.setUpvalueMember(self, scope, Ast.IndexExpression(Ast.VariableExpression(self.containerFuncScope, self.currentUpvaluesVar), Ast.NumberExpression(upvalId)), self.register(self, scope, valueReg), compoundConstructor), {}, {valueReg}, true)
                            end
                        end
                    end

                    return
                end

                logger.error(logger, string.format('%s is not a compileable statement!', statement.kind))
            end
            function Compiler.compileExpression(
                self,
                expression,
                funcDepth,
                numReturns
            )
                local scope = self.activeBlock.scope

                if (expression.kind == AstKind.StringExpression) then
                    local regs = {}

                    for i = 1, numReturns, 1 do
                        regs[i] = self.allocRegister(self)

                        if (i == 1) then
                            self.addStatement(self, self.setRegister(self, scope, regs[i], Ast.StringExpression(expression.value)), {
                                regs[i],
                            }, {}, false)
                        else
                            self.addStatement(self, self.setRegister(self, scope, regs[i], Ast.NilExpression()), {
                                regs[i],
                            }, {}, false)
                        end
                    end

                    return regs
                end
                if (expression.kind == AstKind.NumberExpression) then
                    local regs = {}

                    for i = 1, numReturns do
                        regs[i] = self.allocRegister(self)

                        if (i == 1) then
                            self.addStatement(self, self.setRegister(self, scope, regs[i], Ast.NumberExpression(expression.value)), {
                                regs[i],
                            }, {}, false)
                        else
                            self.addStatement(self, self.setRegister(self, scope, regs[i], Ast.NilExpression()), {
                                regs[i],
                            }, {}, false)
                        end
                    end

                    return regs
                end
                if (expression.kind == AstKind.BooleanExpression) then
                    local regs = {}

                    for i = 1, numReturns do
                        regs[i] = self.allocRegister(self)

                        if (i == 1) then
                            self.addStatement(self, self.setRegister(self, scope, regs[i], Ast.BooleanExpression(expression.value)), {
                                regs[i],
                            }, {}, false)
                        else
                            self.addStatement(self, self.setRegister(self, scope, regs[i], Ast.NilExpression()), {
                                regs[i],
                            }, {}, false)
                        end
                    end

                    return regs
                end
                if (expression.kind == AstKind.NilExpression) then
                    local regs = {}

                    for i = 1, numReturns do
                        regs[i] = self.allocRegister(self)

                        self.addStatement(self, self.setRegister(self, scope, regs[i], Ast.NilExpression()), {
                            regs[i],
                        }, {}, false)
                    end

                    return regs
                end
                if (expression.kind == AstKind.VariableExpression) then
                    local regs = {}

                    for i = 1, numReturns do
                        if (i == 1) then
                            if (expression.scope.isGlobal) then
                                regs[i] = self.allocRegister(self, false)

                                local tmpReg = self.allocRegister(self, false)

                                self.addStatement(self, self.setRegister(self, scope, tmpReg, Ast.StringExpression(expression.scope:getVariableName(expression.id))), {tmpReg}, {}, false)
                                self.addStatement(self, self.setRegister(self, scope, regs[i], Ast.IndexExpression(self.env(self, scope), self.register(self, scope, tmpReg))), {
                                    regs[i],
                                }, {tmpReg}, true)
                                self.freeRegister(self, tmpReg, false)
                            else
                                if (self.scopeFunctionDepths[expression.scope] == funcDepth) then
                                    if self.isUpvalue(self, expression.scope, expression.id) then
                                        local reg, varReg = self.allocRegister(self, false), self.getVarRegister(self, expression.scope, expression.id, funcDepth, nil)

                                        self.addStatement(self, self.setRegister(self, scope, reg, self.getUpvalueMember(self, scope, self.register(self, scope, varReg))), {reg}, {varReg}, true)

                                        regs[i] = reg
                                    else
                                        regs[i] = self.getVarRegister(self, expression.scope, expression.id, funcDepth, nil)
                                    end
                                else
                                    local reg, upvalId = self.allocRegister(self, false), self.getUpvalueId(self, expression.scope, expression.id)

                                    scope.addReferenceToHigherScope(scope, self.containerFuncScope, self.currentUpvaluesVar)
                                    self.addStatement(self, self.setRegister(self, scope, reg, self.getUpvalueMember(self, scope, Ast.IndexExpression(Ast.VariableExpression(self.containerFuncScope, self.currentUpvaluesVar), Ast.NumberExpression(upvalId)))), {reg}, {}, true)

                                    regs[i] = reg
                                end
                            end
                        else
                            regs[i] = self.allocRegister(self)

                            self.addStatement(self, self.setRegister(self, scope, regs[i], Ast.NilExpression()), {
                                regs[i],
                            }, {}, false)
                        end
                    end

                    return regs
                end
                if (expression.kind == AstKind.FunctionCallExpression) then
                    local baseReg, retRegs, returnAll = self.compileExpression(self, expression.base, funcDepth, 1)[1], {}, numReturns == self.RETURN_ALL

                    if returnAll then
                        retRegs[1] = self.allocRegister(self, false)
                    else
                        for i = 1, numReturns do
                            retRegs[i] = self.allocRegister(self, false)
                        end
                    end

                    local regs, args = {}, {}

                    for i, expr in ipairs(expression.args)do
                        if i == #expression.args and (expr.kind == AstKind.FunctionCallExpression or expr.kind == AstKind.PassSelfFunctionCallExpression or expr.kind == AstKind.VarargExpression) then
                            local reg = self.compileExpression(self, expr, funcDepth, self.RETURN_ALL)[1]

                            table.insert(args, Ast.FunctionCallExpression(self.unpack(self, scope), {
                                self.register(self, scope, reg),
                            }))
                            table.insert(regs, reg)
                        else
                            local reg = self.compileExpression(self, expr, funcDepth, 1)[1]

                            table.insert(args, self.register(self, scope, reg))
                            table.insert(regs, reg)
                        end
                    end

                    if (returnAll) then
                        self.addStatement(self, self.setRegister(self, scope, retRegs[1], Ast.TableConstructorExpression{
                            Ast.TableEntry(Ast.FunctionCallExpression(self.register(self, scope, baseReg), args)),
                        }), {
                            retRegs[1],
                        }, {
                            baseReg,
                            unpack(regs),
                        }, true)
                    else
                        if (numReturns > 1) then
                            local tmpReg = self.allocRegister(self, false)

                            self.addStatement(self, self.setRegister(self, scope, tmpReg, Ast.TableConstructorExpression{
                                Ast.TableEntry(Ast.FunctionCallExpression(self.register(self, scope, baseReg), args)),
                            }), {tmpReg}, {
                                baseReg,
                                unpack(regs),
                            }, true)

                            for i, reg in ipairs(retRegs)do
                                self.addStatement(self, self.setRegister(self, scope, reg, Ast.IndexExpression(self.register(self, scope, tmpReg), Ast.NumberExpression(i))), {reg}, {tmpReg}, false)
                            end

                            self.freeRegister(self, tmpReg, false)
                        else
                            self.addStatement(self, self.setRegister(self, scope, retRegs[1], Ast.FunctionCallExpression(self.register(self, scope, baseReg), args)), {
                                retRegs[1],
                            }, {
                                baseReg,
                                unpack(regs),
                            }, true)
                        end
                    end

                    self.freeRegister(self, baseReg, false)

                    for i, reg in ipairs(regs)do
                        self.freeRegister(self, reg, false)
                    end

                    return retRegs
                end
                if (expression.kind == AstKind.PassSelfFunctionCallExpression) then
                    local baseReg, retRegs, returnAll = self.compileExpression(self, expression.base, funcDepth, 1)[1], {}, numReturns == self.RETURN_ALL

                    if returnAll then
                        retRegs[1] = self.allocRegister(self, false)
                    else
                        for i = 1, numReturns do
                            retRegs[i] = self.allocRegister(self, false)
                        end
                    end

                    local args, regs = {
                        self.register(self, scope, baseReg),
                    }, {baseReg}

                    for i, expr in ipairs(expression.args)do
                        if i == #expression.args and (expr.kind == AstKind.FunctionCallExpression or expr.kind == AstKind.PassSelfFunctionCallExpression or expr.kind == AstKind.VarargExpression) then
                            local reg = self.compileExpression(self, expr, funcDepth, self.RETURN_ALL)[1]

                            table.insert(args, Ast.FunctionCallExpression(self.unpack(self, scope), {
                                self.register(self, scope, reg),
                            }))
                            table.insert(regs, reg)
                        else
                            local reg = self.compileExpression(self, expr, funcDepth, 1)[1]

                            table.insert(args, self.register(self, scope, reg))
                            table.insert(regs, reg)
                        end
                    end

                    if (returnAll or numReturns > 1) then
                        local tmpReg = self.allocRegister(self, false)

                        self.addStatement(self, self.setRegister(self, scope, tmpReg, Ast.StringExpression(expression.passSelfFunctionName)), {tmpReg}, {}, false)
                        self.addStatement(self, self.setRegister(self, scope, tmpReg, Ast.IndexExpression(self.register(self, scope, baseReg), self.register(self, scope, tmpReg))), {tmpReg}, {baseReg, tmpReg}, false)

                        if returnAll then
                            self.addStatement(self, self.setRegister(self, scope, retRegs[1], Ast.TableConstructorExpression{
                                Ast.TableEntry(Ast.FunctionCallExpression(self.register(self, scope, tmpReg), args)),
                            }), {
                                retRegs[1],
                            }, {
                                tmpReg,
                                unpack(regs),
                            }, true)
                        else
                            self.addStatement(self, self.setRegister(self, scope, tmpReg, Ast.TableConstructorExpression{
                                Ast.TableEntry(Ast.FunctionCallExpression(self.register(self, scope, tmpReg), args)),
                            }), {tmpReg}, {
                                tmpReg,
                                unpack(regs),
                            }, true)

                            for i, reg in ipairs(retRegs)do
                                self.addStatement(self, self.setRegister(self, scope, reg, Ast.IndexExpression(self.register(self, scope, tmpReg), Ast.NumberExpression(i))), {reg}, {tmpReg}, false)
                            end
                        end

                        self.freeRegister(self, tmpReg, false)
                    else
                        local tmpReg = retRegs[1] or self.allocRegister(self, false)

                        self.addStatement(self, self.setRegister(self, scope, tmpReg, Ast.StringExpression(expression.passSelfFunctionName)), {tmpReg}, {}, false)
                        self.addStatement(self, self.setRegister(self, scope, tmpReg, Ast.IndexExpression(self.register(self, scope, baseReg), self.register(self, scope, tmpReg))), {tmpReg}, {baseReg, tmpReg}, false)
                        self.addStatement(self, self.setRegister(self, scope, retRegs[1], Ast.FunctionCallExpression(self.register(self, scope, tmpReg), args)), {
                            retRegs[1],
                        }, {
                            baseReg,
                            unpack(regs),
                        }, true)
                    end

                    for i, reg in ipairs(regs)do
                        self.freeRegister(self, reg, false)
                    end

                    return retRegs
                end
                if (expression.kind == AstKind.IndexExpression) then
                    local regs = {}

                    for i = 1, numReturns do
                        regs[i] = self.allocRegister(self)

                        if (i == 1) then
                            local baseReg, indexReg = self.compileExpression(self, expression.base, funcDepth, 1)[1], self.compileExpression(self, expression.index, funcDepth, 1)[1]

                            self.addStatement(self, self.setRegister(self, scope, regs[i], Ast.IndexExpression(self.register(self, scope, baseReg), self.register(self, scope, indexReg))), {
                                regs[i],
                            }, {baseReg, indexReg}, true)
                            self.freeRegister(self, baseReg, false)
                            self.freeRegister(self, indexReg, false)
                        else
                            self.addStatement(self, self.setRegister(self, scope, regs[i], Ast.NilExpression()), {
                                regs[i],
                            }, {}, false)
                        end
                    end

                    return regs
                end
                if (self.BIN_OPS[expression.kind]) then
                    local regs = {}

                    for i = 1, numReturns do
                        regs[i] = self.allocRegister(self)

                        if (i == 1) then
                            local lhsReg, rhsReg = self.compileExpression(self, expression.lhs, funcDepth, 1)[1], self.compileExpression(self, expression.rhs, funcDepth, 1)[1]

                            self.addStatement(self, self.setRegister(self, scope, regs[i], Ast[expression.kind](self.register(self, scope, lhsReg), self.register(self, scope, rhsReg))), {
                                regs[i],
                            }, {lhsReg, rhsReg}, true)
                            self.freeRegister(self, rhsReg, false)
                            self.freeRegister(self, lhsReg, false)
                        else
                            self.addStatement(self, self.setRegister(self, scope, regs[i], Ast.NilExpression()), {
                                regs[i],
                            }, {}, false)
                        end
                    end

                    return regs
                end
                if (expression.kind == AstKind.NotExpression) then
                    local regs = {}

                    for i = 1, numReturns do
                        regs[i] = self.allocRegister(self)

                        if (i == 1) then
                            local rhsReg = self.compileExpression(self, expression.rhs, funcDepth, 1)[1]

                            self.addStatement(self, self.setRegister(self, scope, regs[i], Ast.NotExpression(self.register(self, scope, rhsReg))), {
                                regs[i],
                            }, {rhsReg}, false)
                            self.freeRegister(self, rhsReg, false)
                        else
                            self.addStatement(self, self.setRegister(self, scope, regs[i], Ast.NilExpression()), {
                                regs[i],
                            }, {}, false)
                        end
                    end

                    return regs
                end
                if (expression.kind == AstKind.NegateExpression) then
                    local regs = {}

                    for i = 1, numReturns do
                        regs[i] = self.allocRegister(self)

                        if (i == 1) then
                            local rhsReg = self.compileExpression(self, expression.rhs, funcDepth, 1)[1]

                            self.addStatement(self, self.setRegister(self, scope, regs[i], Ast.NegateExpression(self.register(self, scope, rhsReg))), {
                                regs[i],
                            }, {rhsReg}, true)
                            self.freeRegister(self, rhsReg, false)
                        else
                            self.addStatement(self, self.setRegister(self, scope, regs[i], Ast.NilExpression()), {
                                regs[i],
                            }, {}, false)
                        end
                    end

                    return regs
                end
                if (expression.kind == AstKind.LenExpression) then
                    local regs = {}

                    for i = 1, numReturns do
                        regs[i] = self.allocRegister(self)

                        if (i == 1) then
                            local rhsReg = self.compileExpression(self, expression.rhs, funcDepth, 1)[1]

                            self.addStatement(self, self.setRegister(self, scope, regs[i], Ast.LenExpression(self.register(self, scope, rhsReg))), {
                                regs[i],
                            }, {rhsReg}, true)
                            self.freeRegister(self, rhsReg, false)
                        else
                            self.addStatement(self, self.setRegister(self, scope, regs[i], Ast.NilExpression()), {
                                regs[i],
                            }, {}, false)
                        end
                    end

                    return regs
                end
                if (expression.kind == AstKind.OrExpression) then
                    local posState = self.registers[self.POS_REGISTER]

                    self.registers[self.POS_REGISTER] = self.VAR_REGISTER

                    local regs = {}

                    for i = 1, numReturns do
                        regs[i] = self.allocRegister(self)

                        if (i ~= 1) then
                            self.addStatement(self, self.setRegister(self, scope, regs[i], Ast.NilExpression()), {
                                regs[i],
                            }, {}, false)
                        end
                    end

                    local resReg, tmpReg = regs[1], nil

                    if posState then
                        tmpReg = self.allocRegister(self, false)

                        self.addStatement(self, self.copyRegisters(self, scope, {tmpReg}, {
                            self.POS_REGISTER,
                        }), {tmpReg}, {
                            self.POS_REGISTER,
                        }, false)
                    end

                    local lhsReg = self.compileExpression(self, expression.lhs, funcDepth, 1)[1]

                    if (expression.rhs.isConstant) then
                        local rhsReg = self.compileExpression(self, expression.rhs, funcDepth, 1)[1]

                        self.addStatement(self, self.setRegister(self, scope, resReg, Ast.OrExpression(self.register(self, scope, lhsReg), self.register(self, scope, rhsReg))), {resReg}, {lhsReg, rhsReg}, false)

                        if tmpReg then
                            self.freeRegister(self, tmpReg, false)
                        end

                        self.freeRegister(self, lhsReg, false)
                        self.freeRegister(self, rhsReg, false)

                        return regs
                    end

                    local block1, block2 = self.createBlock(self), self.createBlock(self)

                    self.addStatement(self, self.copyRegisters(self, scope, {resReg}, {lhsReg}), {resReg}, {lhsReg}, false)
                    self.addStatement(self, self.setRegister(self, scope, self.POS_REGISTER, Ast.OrExpression(Ast.AndExpression(self.register(self, scope, lhsReg), Ast.NumberExpression(block2.id)), Ast.NumberExpression(block1.id))), {
                        self.POS_REGISTER,
                    }, {lhsReg}, false)
                    self.freeRegister(self, lhsReg, false)

                    do
                        self.setActiveBlock(self, block1)

                        local scope, rhsReg = block1.scope, self.compileExpression(self, expression.rhs, funcDepth, 1)[1]

                        self.addStatement(self, self.copyRegisters(self, scope, {resReg}, {rhsReg}), {resReg}, {rhsReg}, false)
                        self.freeRegister(self, rhsReg, false)
                        self.addStatement(self, self.setRegister(self, scope, self.POS_REGISTER, Ast.NumberExpression(block2.id)), {
                            self.POS_REGISTER,
                        }, {}, false)
                    end

                    self.registers[self.POS_REGISTER] = posState

                    self.setActiveBlock(self, block2)

                    scope = block2.scope

                    if tmpReg then
                        self.addStatement(self, self.copyRegisters(self, scope, {
                            self.POS_REGISTER,
                        }, {tmpReg}), {
                            self.POS_REGISTER,
                        }, {tmpReg}, false)
                        self.freeRegister(self, tmpReg, false)
                    end

                    return regs
                end
                if (expression.kind == AstKind.AndExpression) then
                    local posState = self.registers[self.POS_REGISTER]

                    self.registers[self.POS_REGISTER] = self.VAR_REGISTER

                    local regs = {}

                    for i = 1, numReturns do
                        regs[i] = self.allocRegister(self)

                        if (i ~= 1) then
                            self.addStatement(self, self.setRegister(self, scope, regs[i], Ast.NilExpression()), {
                                regs[i],
                            }, {}, false)
                        end
                    end

                    local resReg, tmpReg = regs[1], nil

                    if posState then
                        tmpReg = self.allocRegister(self, false)

                        self.addStatement(self, self.copyRegisters(self, scope, {tmpReg}, {
                            self.POS_REGISTER,
                        }), {tmpReg}, {
                            self.POS_REGISTER,
                        }, false)
                    end

                    local lhsReg = self.compileExpression(self, expression.lhs, funcDepth, 1)[1]

                    if (expression.rhs.isConstant) then
                        local rhsReg = self.compileExpression(self, expression.rhs, funcDepth, 1)[1]

                        self.addStatement(self, self.setRegister(self, scope, resReg, Ast.AndExpression(self.register(self, scope, lhsReg), self.register(self, scope, rhsReg))), {resReg}, {lhsReg, rhsReg}, false)

                        if tmpReg then
                            self.freeRegister(self, tmpReg, false)
                        end

                        self.freeRegister(self, lhsReg, false)
                        self.freeRegister(self, rhsReg, false)

                        return regs
                    end

                    local block1, block2 = self.createBlock(self), self.createBlock(self)

                    self.addStatement(self, self.copyRegisters(self, scope, {resReg}, {lhsReg}), {resReg}, {lhsReg}, false)
                    self.addStatement(self, self.setRegister(self, scope, self.POS_REGISTER, Ast.OrExpression(Ast.AndExpression(self.register(self, scope, lhsReg), Ast.NumberExpression(block1.id)), Ast.NumberExpression(block2.id))), {
                        self.POS_REGISTER,
                    }, {lhsReg}, false)
                    self.freeRegister(self, lhsReg, false)

                    do
                        self.setActiveBlock(self, block1)

                        scope = block1.scope

                        local rhsReg = self.compileExpression(self, expression.rhs, funcDepth, 1)[1]

                        self.addStatement(self, self.copyRegisters(self, scope, {resReg}, {rhsReg}), {resReg}, {rhsReg}, false)
                        self.freeRegister(self, rhsReg, false)
                        self.addStatement(self, self.setRegister(self, scope, self.POS_REGISTER, Ast.NumberExpression(block2.id)), {
                            self.POS_REGISTER,
                        }, {}, false)
                    end

                    self.registers[self.POS_REGISTER] = posState

                    self.setActiveBlock(self, block2)

                    scope = block2.scope

                    if tmpReg then
                        self.addStatement(self, self.copyRegisters(self, scope, {
                            self.POS_REGISTER,
                        }, {tmpReg}), {
                            self.POS_REGISTER,
                        }, {tmpReg}, false)
                        self.freeRegister(self, tmpReg, false)
                    end

                    return regs
                end
                if (expression.kind == AstKind.TableConstructorExpression) then
                    local regs = {}

                    for i = 1, numReturns do
                        regs[i] = self.allocRegister(self)

                        if (i == 1) then
                            local entries, entryRegs = {}, {}

                            for i, entry in ipairs(expression.entries)do
                                if (entry.kind == AstKind.TableEntry) then
                                    local value = entry.value

                                    if i == #expression.entries and (value.kind == AstKind.FunctionCallExpression or value.kind == AstKind.PassSelfFunctionCallExpression or value.kind == AstKind.VarargExpression) then
                                        local reg = self.compileExpression(self, entry.value, funcDepth, self.RETURN_ALL)[1]

                                        table.insert(entries, Ast.TableEntry(Ast.FunctionCallExpression(self.unpack(self, scope), {
                                            self.register(self, scope, reg),
                                        })))
                                        table.insert(entryRegs, reg)
                                    else
                                        local reg = self.compileExpression(self, entry.value, funcDepth, 1)[1]

                                        table.insert(entries, Ast.TableEntry(self.register(self, scope, reg)))
                                        table.insert(entryRegs, reg)
                                    end
                                else
                                    local keyReg, valReg = self.compileExpression(self, entry.key, funcDepth, 1)[1], self.compileExpression(self, entry.value, funcDepth, 1)[1]

                                    table.insert(entries, Ast.KeyedTableEntry(self.register(self, scope, keyReg), self.register(self, scope, valReg)))
                                    table.insert(entryRegs, valReg)
                                    table.insert(entryRegs, keyReg)
                                end
                            end

                            self.addStatement(self, self.setRegister(self, scope, regs[i], Ast.TableConstructorExpression(entries)), {
                                regs[i],
                            }, entryRegs, false)

                            for i, reg in ipairs(entryRegs)do
                                self.freeRegister(self, reg, false)
                            end
                        else
                            self.addStatement(self, self.setRegister(self, scope, regs[i], Ast.NilExpression()), {
                                regs[i],
                            }, {}, false)
                        end
                    end

                    return regs
                end
                if (expression.kind == AstKind.FunctionLiteralExpression) then
                    local regs = {}

                    for i = 1, numReturns do
                        if (i == 1) then
                            regs[i] = self.compileFunction(self, expression, funcDepth)
                        else
                            regs[i] = self.allocRegister(self)

                            self.addStatement(self, self.setRegister(self, scope, regs[i], Ast.NilExpression()), {
                                regs[i],
                            }, {}, false)
                        end
                    end

                    return regs
                end
                if (expression.kind == AstKind.VarargExpression) then
                    if numReturns == self.RETURN_ALL then
                        return {
                            self.varargReg,
                        }
                    end

                    local regs = {}

                    for i = 1, numReturns do
                        regs[i] = self.allocRegister(self, false)

                        self.addStatement(self, self.setRegister(self, scope, regs[i], Ast.IndexExpression(self.register(self, scope, self.varargReg), Ast.NumberExpression(i))), {
                            regs[i],
                        }, {
                            self.varargReg,
                        }, false)
                    end

                    return regs
                end

                logger.error(logger, string.format('%s is not an compliable expression!', expression.kind))
            end

            return Compiler
        end

        function __DARKLUA_BUNDLE_MODULES.w()
            local v = __DARKLUA_BUNDLE_MODULES.cache.w

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.w = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Step, Compiler = __DARKLUA_BUNDLE_MODULES.r(), __DARKLUA_BUNDLE_MODULES.w()
            local Vmify = Step.extend(Step)

            Vmify.Description = 
[[This Step will Compile your script into a fully-custom (not a half custom like other lua obfuscators) Bytecode Format and emit a vm for executing it.]]
            Vmify.Name = 'Vmify'
            Vmify.SettingsDescriptor = {}

            function Vmify.init(self, settings) end
            function Vmify.apply(self, ast)
                local compiler = Compiler.new(Compiler)

                return compiler.compile(compiler, ast)
            end

            return Vmify
        end

        function __DARKLUA_BUNDLE_MODULES.x()
            local v = __DARKLUA_BUNDLE_MODULES.cache.x

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.x = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Step, Ast, Scope, visitast, util, Parser, enums = __DARKLUA_BUNDLE_MODULES.r(), __DARKLUA_BUNDLE_MODULES.b(), __DARKLUA_BUNDLE_MODULES.i(), __DARKLUA_BUNDLE_MODULES.t(), __DARKLUA_BUNDLE_MODULES.f(), __DARKLUA_BUNDLE_MODULES.j(), __DARKLUA_BUNDLE_MODULES.g()
            local LuaVersion, AstKind, ConstantArray = enums.LuaVersion, Ast.AstKind, Step.extend(Step)

            ConstantArray.Description = 
[[This Step will Extract all Constants and put them into an Array at the beginning of the script]]
            ConstantArray.Name = 'Constant Array'
            ConstantArray.SettingsDescriptor = {
                Treshold = {
                    name = 'Treshold',
                    description = 'The relative amount of nodes that will be affected',
                    type = 'number',
                    default = 1,
                    min = 0,
                    max = 1,
                },
                StringsOnly = {
                    name = 'StringsOnly',
                    description = 'Wether to only Extract Strings',
                    type = 'boolean',
                    default = false,
                },
                Shuffle = {
                    name = 'Shuffle',
                    description = 'Wether to shuffle the order of Elements in the Array',
                    type = 'boolean',
                    default = true,
                },
                Rotate = {
                    name = 'Rotate',
                    description = 
[[Wether to rotate the String Array by a specific (random) amount. This will be undone on runtime.]],
                    type = 'boolean',
                    default = true,
                },
                LocalWrapperTreshold = {
                    name = 'LocalWrapperTreshold',
                    description = 
[[The relative amount of nodes functions, that will get local wrappers]],
                    type = 'number',
                    default = 1,
                    min = 0,
                    max = 1,
                },
                LocalWrapperCount = {
                    name = 'LocalWrapperCount',
                    description = 
[[The number of Local wrapper Functions per scope. This only applies if LocalWrapperTreshold is greater than 0]],
                    type = 'number',
                    min = 0,
                    max = 512,
                    default = 0,
                },
                LocalWrapperArgCount = {
                    name = 'LocalWrapperArgCount',
                    description = 'The number of Arguments to the Local wrapper Functions',
                    type = 'number',
                    min = 1,
                    default = 10,
                    max = 200,
                },
                MaxWrapperOffset = {
                    name = 'MaxWrapperOffset',
                    description = 'The Max Offset for the Wrapper Functions',
                    type = 'number',
                    min = 0,
                    default = 65535,
                },
                Encoding = {
                    name = 'Encoding',
                    description = 'The Encoding to use for the Strings',
                    type = 'enum',
                    default = 'base64',
                    values = {
                        'none',
                        'base64',
                    },
                },
            }

            local function callNameGenerator(generatorFunction, ...)
                if (type(generatorFunction) == 'table') then
                    generatorFunction = generatorFunction.generateName
                end

                return generatorFunction(...)
            end

            function ConstantArray.init(self, settings) end
            function ConstantArray.createArray(self)
                local entries = {}

                for i, v in ipairs(self.constants)do
                    if type(v) == 'string' then
                        v = self.encode(self, v)
                    end

                    entries[i] = Ast.TableEntry(Ast.ConstantNode(v))
                end

                return Ast.TableConstructorExpression(entries)
            end
            function ConstantArray.indexing(self, index, data)
                if self.LocalWrapperCount > 0 and data.functionData.local_wrappers then
                    local wrappers = data.functionData.local_wrappers
                    local wrapper, args = wrappers[math.random(#wrappers)], {}
                    local ofs = index - self.wrapperOffset - wrapper.offset

                    for i = 1, self.LocalWrapperArgCount, 1 do
                        if i == wrapper.arg then
                            args[i] = Ast.NumberExpression(ofs)
                        else
                            args[i] = Ast.NumberExpression(math.random(ofs - 1024, ofs + 1024))
                        end
                    end

                    data.scope:addReferenceToHigherScope(wrappers.scope, wrappers.id)

                    return Ast.FunctionCallExpression(Ast.IndexExpression(Ast.VariableExpression(wrappers.scope, wrappers.id), Ast.StringExpression(wrapper.index)), args)
                else
                    data.scope:addReferenceToHigherScope(self.rootScope, self.wrapperId)

                    return Ast.FunctionCallExpression(Ast.VariableExpression(self.rootScope, self.wrapperId), {
                        Ast.NumberExpression(index - self.wrapperOffset),
                    })
                end
            end
            function ConstantArray.getConstant(self, value, data)
                if (self.lookup[value]) then
                    return self.indexing(self, self.lookup[value], data)
                end

                local idx = #self.constants + 1

                self.constants[idx] = value
                self.lookup[value] = idx

                return self.indexing(self, idx, data)
            end
            function ConstantArray.addConstant(self, value)
                if (self.lookup[value]) then
                    return
                end

                local idx = #self.constants + 1

                self.constants[idx] = value
                self.lookup[value] = idx
            end

            local function reverse(t, i, j)
                while i < j do
                    t[i], t[j] = t[j], t[i]
                    i, j = i + 1, j - 1
                end
            end
            local function rotate(t, d, n)
                n = n or #t
                d = (d or 1) % n

                reverse(t, 1, n)
                reverse(t, 1, d)
                reverse(t, d + 1, n)
            end

            local rotateCode = '\tfor i, v in ipairs({{1, LEN}, {1, SHIFT}, {SHIFT + 1, LEN}}) do\n\t\twhile v[1] < v[2] do\n\t\t\tARR[v[1]], ARR[v[2]], v[1], v[2] = ARR[v[2]], ARR[v[1]], v[1] + 1, v[2] - 1\n\t\tend\n\tend\n'

            function ConstantArray.addRotateCode(self, ast, shift)
                local parser = Parser.new(Parser, {
                    LuaVersion = LuaVersion.Lua51,
                })
                local newAst = parser.parse(parser, string.gsub(string.gsub(rotateCode, 'SHIFT', tostring(shift)), 'LEN', tostring(#self.constants)))
                local forStat = newAst.body.statements[1]

                forStat.body.scope:setParent(ast.body.scope)
                visitast(newAst, nil, function(node, data)
                    if (node.kind == AstKind.VariableExpression) then
                        if (node.scope:getVariableName(node.id) == 'ARR') then
                            data.scope:removeReferenceToHigherScope(node.scope, node.id)
                            data.scope:addReferenceToHigherScope(self.rootScope, self.arrId)

                            node.scope = self.rootScope
                            node.id = self.arrId
                        end
                    end
                end)
                table.insert(ast.body.statements, 1, forStat)
            end
            function ConstantArray.addDecodeCode(self, ast)
                if self.Encoding == 'base64' then
                    local base64DecodeCode, parser = '\tdo ' .. table.concat(util.shuffle{
                        'local lookup = LOOKUP_TABLE;',
                        'local len = string.len;',
                        'local sub = string.sub;',
                        'local floor = math.floor;',
                        'local strchar = string.char;',
                        'local insert = table.insert;',
                        'local concat = table.concat;',
                        'local type = type;',
                        'local arr = ARR;',
                    }) .. '\t\tfor i = 1, #arr do\n\t\t\tlocal data = arr[i];\n\t\t\tif type(data) == "string" then\n\t\t\t\tlocal length = len(data)\n\t\t\t\tlocal parts = {}\n\t\t\t\tlocal index = 1\n\t\t\t\tlocal value = 0\n\t\t\t\tlocal count = 0\n\t\t\t\twhile index <= length do\n\t\t\t\t\tlocal char = sub(data, index, index)\n\t\t\t\t\tlocal code = lookup[char]\n\t\t\t\t\tif code then\n\t\t\t\t\t\tvalue = value + code * (64 ^ (3 - count))\n\t\t\t\t\t\tcount = count + 1\n\t\t\t\t\t\tif count == 4 then\n\t\t\t\t\t\t\tcount = 0\n\t\t\t\t\t\t\tlocal c1 = floor(value / 65536)\n\t\t\t\t\t\t\tlocal c2 = floor(value % 65536 / 256)\n\t\t\t\t\t\t\tlocal c3 = value % 256\n\t\t\t\t\t\t\tinsert(parts, strchar(c1, c2, c3))\n\t\t\t\t\t\t\tvalue = 0\n\t\t\t\t\t\tend\n\t\t\t\t\telseif char == "=" then\n\t\t\t\t\t\tinsert(parts, strchar(floor(value / 65536)));\n\t\t\t\t\t\tif index >= length or sub(data, index + 1, index + 1) ~= "=" then\n\t\t\t\t\t\t\tinsert(parts, strchar(floor(value % 65536 / 256)));\n\t\t\t\t\t\tend\n\t\t\t\t\t\tbreak\n\t\t\t\t\tend\n\t\t\t\t\tindex = index + 1\n\t\t\t\tend\n\t\t\t\tarr[i] = concat(parts)\n\t\t\tend\n\t\tend\n\tend\n', Parser.new(Parser, {
                        LuaVersion = LuaVersion.Lua51,
                    })
                    local newAst = parser.parse(parser, base64DecodeCode)
                    local forStat = newAst.body.statements[1]

                    forStat.body.scope:setParent(ast.body.scope)
                    visitast(newAst, nil, function(node, data)
                        if (node.kind == AstKind.VariableExpression) then
                            if (node.scope:getVariableName(node.id) == 'ARR') then
                                data.scope:removeReferenceToHigherScope(node.scope, node.id)
                                data.scope:addReferenceToHigherScope(self.rootScope, self.arrId)

                                node.scope = self.rootScope
                                node.id = self.arrId
                            end
                            if (node.scope:getVariableName(node.id) == 'LOOKUP_TABLE') then
                                data.scope:removeReferenceToHigherScope(node.scope, node.id)

                                return self.createBase64Lookup(self)
                            end
                        end
                    end)
                    table.insert(ast.body.statements, 1, forStat)
                end
            end
            function ConstantArray.createBase64Lookup(self)
                local entries, i = {}, 0

                for char in string.gmatch(self.base64chars, '.')do
                    table.insert(entries, Ast.KeyedTableEntry(Ast.StringExpression(char), Ast.NumberExpression(i)))

                    i = i + 1
                end

                util.shuffle(entries)

                return Ast.TableConstructorExpression(entries)
            end
            function ConstantArray.encode(self, str)
                if self.Encoding == 'base64' then
                    return ((str.gsub(str, '.', function(x)
                        local r, b = '', x.byte(x)

                        for i = 8, 1, -1 do
                            r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0')
                        end

                        return r
                    end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
                        if (#x < 6) then
                            return ''
                        end

                        local c = 0

                        for i = 1, 6 do
                            c = c + (x.sub(x, i, i) == '1' and 2 ^ (6 - i) or 0)
                        end

                        return self.base64chars:sub(c + 1, c + 1)
                    end) .. ({
                        '',
                        '==',
                        '=',
                    })[#str % 3 + 1])
                end
            end
            function ConstantArray.apply(self, ast, pipeline)
                self.rootScope = ast.body.scope
                self.arrId = self.rootScope:addVariable()
                self.base64chars = table.concat(util.shuffle{
                    'A',
                    'B',
                    'C',
                    'D',
                    'E',
                    'F',
                    'G',
                    'H',
                    'I',
                    'J',
                    'K',
                    'L',
                    'M',
                    'N',
                    'O',
                    'P',
                    'Q',
                    'R',
                    'S',
                    'T',
                    'U',
                    'V',
                    'W',
                    'X',
                    'Y',
                    'Z',
                    'a',
                    'b',
                    'c',
                    'd',
                    'e',
                    'f',
                    'g',
                    'h',
                    'i',
                    'j',
                    'k',
                    'l',
                    'm',
                    'n',
                    'o',
                    'p',
                    'q',
                    'r',
                    's',
                    't',
                    'u',
                    'v',
                    'w',
                    'x',
                    'y',
                    'z',
                    '0',
                    '1',
                    '2',
                    '3',
                    '4',
                    '5',
                    '6',
                    '7',
                    '8',
                    '9',
                    '+',
                    '/',
                })
                self.constants = {}
                self.lookup = {}

                visitast(ast, nil, function(node, data)
                    if math.random() <= self.Treshold then
                        node.__apply_constant_array = true

                        if node.kind == AstKind.StringExpression then
                            self.addConstant(self, node.value)
                        elseif not self.StringsOnly then
                            if node.isConstant then
                                if node.value ~= nil then
                                    self.addConstant(self, node.value)
                                end
                            end
                        end
                    end
                end)

                if self.Shuffle then
                    self.constants = util.shuffle(self.constants)
                    self.lookup = {}

                    for i, v in ipairs(self.constants)do
                        self.lookup[v] = i
                    end
                end

                self.wrapperOffset = math.random(-self.MaxWrapperOffset, self.MaxWrapperOffset)
                self.wrapperId = self.rootScope:addVariable()

                visitast(ast, function(node, data)
                    if self.LocalWrapperCount > 0 and node.kind == AstKind.Block and node.isFunctionBlock and math.random() <= self.LocalWrapperTreshold then
                        local id = node.scope:addVariable()

                        data.functionData.local_wrappers = {
                            id = id,
                            scope = node.scope,
                        }

                        local nameLookup = {}

                        for i = 1, self.LocalWrapperCount, 1 do
                            local name

                            repeat
                                name = callNameGenerator(pipeline.namegenerator, math.random(1, self.LocalWrapperArgCount * 16))
                            until not nameLookup[name]

                            nameLookup[name] = true

                            local offset, argPos = math.random(-self.MaxWrapperOffset, self.MaxWrapperOffset), math.random(1, self.LocalWrapperArgCount)

                            data.functionData.local_wrappers[i] = {
                                arg = argPos,
                                index = name,
                                offset = offset,
                            }
                            data.functionData.__used = false
                        end
                    end
                    if node.__apply_constant_array then
                        data.functionData.__used = true
                    end
                end, function(node, data)
                    if node.__apply_constant_array then
                        if node.kind == AstKind.StringExpression then
                            return self.getConstant(self, node.value, data)
                        elseif not self.StringsOnly then
                            if node.isConstant then
                                return node.value ~= nil and self.getConstant(self, node.value, data)
                            end
                        end

                        node.__apply_constant_array = nil
                    end
                    if self.LocalWrapperCount > 0 and node.kind == AstKind.Block and node.isFunctionBlock and data.functionData.local_wrappers and data.functionData.__used then
                        data.functionData.__used = nil

                        local elems, wrappers = {}, data.functionData.local_wrappers

                        for i = 1, self.LocalWrapperCount, 1 do
                            local wrapper = wrappers[i]
                            local argPos, offset, name, funcScope, arg, args = wrapper.arg, wrapper.offset, wrapper.index, Scope.new(Scope, node.scope), nil, {}

                            for i = 1, self.LocalWrapperArgCount, 1 do
                                args[i] = funcScope.addVariable(funcScope)

                                if i == argPos then
                                    arg = args[i]
                                end
                            end

                            local addSubArg

                            if offset < 0 then
                                addSubArg = Ast.SubExpression(Ast.VariableExpression(funcScope, arg), Ast.NumberExpression(
-offset))
                            else
                                addSubArg = Ast.AddExpression(Ast.VariableExpression(funcScope, arg), Ast.NumberExpression(offset))
                            end

                            funcScope.addReferenceToHigherScope(funcScope, self.rootScope, self.wrapperId)

                            local callArg, fargs = Ast.FunctionCallExpression(Ast.VariableExpression(self.rootScope, self.wrapperId), {addSubArg}), {}

                            for i, v in ipairs(args)do
                                fargs[i] = Ast.VariableExpression(funcScope, v)
                            end

                            elems[i] = Ast.KeyedTableEntry(Ast.StringExpression(name), Ast.FunctionLiteralExpression(fargs, Ast.Block({
                                Ast.ReturnStatement{callArg},
                            }, funcScope)))
                        end

                        table.insert(node.statements, 1, Ast.LocalVariableDeclaration(node.scope, {
                            wrappers.id,
                        }, {
                            Ast.TableConstructorExpression(elems),
                        }))
                    end
                end)
                self.addDecodeCode(self, ast)

                local steps = util.shuffle{
                    function()
                        local funcScope = Scope.new(Scope, self.rootScope)

                        funcScope.addReferenceToHigherScope(funcScope, self.rootScope, self.arrId)

                        local arg, addSubArg = funcScope.addVariable(funcScope), nil

                        if self.wrapperOffset < 0 then
                            addSubArg = Ast.SubExpression(Ast.VariableExpression(funcScope, arg), Ast.NumberExpression(
-self.wrapperOffset))
                        else
                            addSubArg = Ast.AddExpression(Ast.VariableExpression(funcScope, arg), Ast.NumberExpression(self.wrapperOffset))
                        end

                        table.insert(ast.body.statements, 1, Ast.LocalFunctionDeclaration(self.rootScope, self.wrapperId, {
                            Ast.VariableExpression(funcScope, arg),
                        }, Ast.Block({
                            Ast.ReturnStatement{
                                Ast.IndexExpression(Ast.VariableExpression(self.rootScope, self.arrId), addSubArg),
                            },
                        }, funcScope)))
                    end,
                    function()
                        if self.Rotate and #self.constants > 1 then
                            local shift = math.random(1, #self.constants - 1)

                            rotate(self.constants, -shift)
                            self.addRotateCode(self, ast, shift)
                        end
                    end,
                }

                for i, f in ipairs(steps)do
                    f()
                end

                table.insert(ast.body.statements, 1, Ast.LocalVariableDeclaration(self.rootScope, {
                    self.arrId,
                }, {
                    self.createArray(self),
                }))

                self.rootScope = nil
                self.arrId = nil
                self.constants = nil
                self.lookup = nil
            end

            return ConstantArray
        end

        function __DARKLUA_BUNDLE_MODULES.y()
            local v = __DARKLUA_BUNDLE_MODULES.cache.y

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.y = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Ast, RandomStrings, RandomLiterals = __DARKLUA_BUNDLE_MODULES.b(), __DARKLUA_BUNDLE_MODULES.v(), {}

            local function callNameGenerator(generatorFunction, ...)
                if (type(generatorFunction) == 'table') then
                    generatorFunction = generatorFunction.generateName
                end

                return generatorFunction(...)
            end

            function RandomLiterals.String(pipeline)
                return Ast.StringExpression(callNameGenerator(pipeline.namegenerator, math.random(1, 4096)))
            end
            function RandomLiterals.Dictionary()
                return RandomStrings.randomStringNode(true)
            end
            function RandomLiterals.Number()
                return Ast.NumberExpression(math.random(-8388608, 8388607))
            end
            function RandomLiterals.Any(pipeline)
                local type = math.random(1, 3)

                if type == 1 then
                    return RandomLiterals.String(pipeline)
                elseif type == 2 then
                    return RandomLiterals.Number()
                elseif type == 3 then
                    return RandomLiterals.Dictionary()
                end
            end

            return RandomLiterals
        end

        function __DARKLUA_BUNDLE_MODULES.z()
            local v = __DARKLUA_BUNDLE_MODULES.cache.z

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.z = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Step, Ast, Scope, visitast, RandomLiterals = __DARKLUA_BUNDLE_MODULES.r(), __DARKLUA_BUNDLE_MODULES.b(), __DARKLUA_BUNDLE_MODULES.i(), __DARKLUA_BUNDLE_MODULES.t(), __DARKLUA_BUNDLE_MODULES.z()
            local AstKind, ProifyLocals = Ast.AstKind, Step.extend(Step)

            ProifyLocals.Description = 'This Step wraps all locals into Proxy Objects'
            ProifyLocals.Name = 'Proxify Locals'
            ProifyLocals.SettingsDescriptor = {
                LiteralType = {
                    name = 'LiteralType',
                    description = 'The type of the randomly generated literals',
                    type = 'enum',
                    values = {
                        'dictionary',
                        'number',
                        'string',
                        'any',
                    },
                    default = 'string',
                },
            }

            local function shallowcopy(orig)
                local orig_type, copy = type(orig), nil

                if orig_type == 'table' then
                    copy = {}

                    for orig_key, orig_value in pairs(orig)do
                        copy[orig_key] = orig_value
                    end
                else
                    copy = orig
                end

                return copy
            end
            local function callNameGenerator(generatorFunction, ...)
                if (type(generatorFunction) == 'table') then
                    generatorFunction = generatorFunction.generateName
                end

                return generatorFunction(...)
            end

            local MetatableExpressions = {
                {
                    constructor = Ast.AddExpression,
                    key = '__add',
                },
                {
                    constructor = Ast.SubExpression,
                    key = '__sub',
                },
                {
                    constructor = Ast.IndexExpression,
                    key = '__index',
                },
                {
                    constructor = Ast.MulExpression,
                    key = '__mul',
                },
                {
                    constructor = Ast.DivExpression,
                    key = '__div',
                },
                {
                    constructor = Ast.PowExpression,
                    key = '__pow',
                },
                {
                    constructor = Ast.StrCatExpression,
                    key = '__concat',
                },
            }

            function ProifyLocals.init(self, settings) end

            local function generateLocalMetatableInfo(pipeline)
                local usedOps, info = {}, {}

                for i, v in ipairs{
                    'setValue',
                    'getValue',
                    'index',
                }do
                    local rop

                    repeat
                        rop = MetatableExpressions[math.random(#MetatableExpressions)]
                    until not usedOps[rop]

                    usedOps[rop] = true
                    info[v] = rop
                end

                info.valueName = callNameGenerator(pipeline.namegenerator, math.random(1, 4096))

                return info
            end

            function ProifyLocals.CreateAssignmentExpression(
                self,
                info,
                expr,
                parentScope
            )
                local metatableVals, setValueFunctionScope = {}, Scope.new(Scope, parentScope)
                local setValueSelf, setValueArg = setValueFunctionScope.addVariable(setValueFunctionScope), setValueFunctionScope.addVariable(setValueFunctionScope)
                local setvalueFunctionLiteral = Ast.FunctionLiteralExpression({
                    Ast.VariableExpression(setValueFunctionScope, setValueSelf),
                    Ast.VariableExpression(setValueFunctionScope, setValueArg),
                }, Ast.Block({
                    Ast.AssignmentStatement({
                        Ast.AssignmentIndexing(Ast.VariableExpression(setValueFunctionScope, setValueSelf), Ast.StringExpression(info.valueName)),
                    }, {
                        Ast.VariableExpression(setValueFunctionScope, setValueArg),
                    }),
                }, setValueFunctionScope))

                table.insert(metatableVals, Ast.KeyedTableEntry(Ast.StringExpression(info.setValue.key), setvalueFunctionLiteral))

                local getValueFunctionScope = Scope.new(Scope, parentScope)
                local getValueSelf, getValueArg, getValueIdxExpr = getValueFunctionScope.addVariable(getValueFunctionScope), getValueFunctionScope.addVariable(getValueFunctionScope), nil

                if (info.getValue.key == '__index' or info.setValue.key == '__index') then
                    getValueIdxExpr = Ast.FunctionCallExpression(Ast.VariableExpression(getValueFunctionScope.resolveGlobal(getValueFunctionScope, 'rawget')), {
                        Ast.VariableExpression(getValueFunctionScope, getValueSelf),
                        Ast.StringExpression(info.valueName),
                    })
                else
                    getValueIdxExpr = Ast.IndexExpression(Ast.VariableExpression(getValueFunctionScope, getValueSelf), Ast.StringExpression(info.valueName))
                end

                local getvalueFunctionLiteral = Ast.FunctionLiteralExpression({
                    Ast.VariableExpression(getValueFunctionScope, getValueSelf),
                    Ast.VariableExpression(getValueFunctionScope, getValueArg),
                }, Ast.Block({
                    Ast.ReturnStatement{getValueIdxExpr},
                }, getValueFunctionScope))

                table.insert(metatableVals, Ast.KeyedTableEntry(Ast.StringExpression(info.getValue.key), getvalueFunctionLiteral))
                parentScope.addReferenceToHigherScope(parentScope, self.setMetatableVarScope, self.setMetatableVarId)

                return Ast.FunctionCallExpression(Ast.VariableExpression(self.setMetatableVarScope, self.setMetatableVarId), {
                    Ast.TableConstructorExpression{
                        Ast.KeyedTableEntry(Ast.StringExpression(info.valueName), expr),
                    },
                    Ast.TableConstructorExpression(metatableVals),
                })
            end
            function ProifyLocals.apply(self, ast, pipeline)
                local localMetatableInfos = {}

                local function getLocalMetatableInfo(scope, id)
                    if (scope.isGlobal) then
                        return nil
                    end

                    localMetatableInfos[scope] = localMetatableInfos[scope] or {}

                    if localMetatableInfos[scope][id] then
                        if localMetatableInfos[scope][id].locked then
                            return nil
                        end

                        return localMetatableInfos[scope][id]
                    end

                    local localMetatableInfo = generateLocalMetatableInfo(pipeline)

                    localMetatableInfos[scope][id] = localMetatableInfo

                    return localMetatableInfo
                end
                local function disableMetatableInfo(scope, id)
                    if (scope.isGlobal) then
                        return nil
                    end

                    localMetatableInfos[scope] = localMetatableInfos[scope] or {}
                    localMetatableInfos[scope][id] = {locked = true}
                end

                self.setMetatableVarScope = ast.body.scope
                self.setMetatableVarId = ast.body.scope:addVariable()
                self.emptyFunctionScope = ast.body.scope
                self.emptyFunctionId = ast.body.scope:addVariable()
                self.emptyFunctionUsed = false

                table.insert(ast.body.statements, 1, Ast.LocalVariableDeclaration(self.emptyFunctionScope, {
                    self.emptyFunctionId,
                }, {
                    Ast.FunctionLiteralExpression({}, Ast.Block({}, Scope.new(Scope, ast.body.scope))),
                }))
                visitast(ast, function(node, data)
                    if (node.kind == AstKind.ForStatement) then
                        disableMetatableInfo(node.scope, node.id)
                    end
                    if (node.kind == AstKind.ForInStatement) then
                        for i, id in ipairs(node.ids)do
                            disableMetatableInfo(node.scope, id)
                        end
                    end
                    if (node.kind == AstKind.FunctionDeclaration or node.kind == AstKind.LocalFunctionDeclaration or node.kind == AstKind.FunctionLiteralExpression) then
                        for i, expr in ipairs(node.args)do
                            if expr.kind == AstKind.VariableExpression then
                                disableMetatableInfo(expr.scope, expr.id)
                            end
                        end
                    end
                    if (node.kind == AstKind.AssignmentStatement) then
                        if (#node.lhs == 1 and node.lhs[1].kind == AstKind.AssignmentVariable) then
                            local variable = node.lhs[1]
                            local localMetatableInfo = getLocalMetatableInfo(variable.scope, variable.id)

                            if localMetatableInfo then
                                local args, vexp = shallowcopy(node.rhs), Ast.VariableExpression(variable.scope, variable.id)

                                vexp.__ignoreProxifyLocals = true
                                args[1] = localMetatableInfo.setValue.constructor(vexp, args[1])
                                self.emptyFunctionUsed = true

                                data.scope:addReferenceToHigherScope(self.emptyFunctionScope, self.emptyFunctionId)

                                return Ast.FunctionCallStatement(Ast.VariableExpression(self.emptyFunctionScope, self.emptyFunctionId), args)
                            end
                        end
                    end
                end, function(node, data)
                    if (node.kind == AstKind.LocalVariableDeclaration) then
                        for i, id in ipairs(node.ids)do
                            local expr, localMetatableInfo = node.expressions[i] or Ast.NilExpression(), getLocalMetatableInfo(node.scope, id)

                            if localMetatableInfo then
                                local newExpr = self.CreateAssignmentExpression(self, localMetatableInfo, expr, node.scope)

                                node.expressions[i] = newExpr
                            end
                        end
                    end
                    if (node.kind == AstKind.VariableExpression and not node.__ignoreProxifyLocals) then
                        local localMetatableInfo = getLocalMetatableInfo(node.scope, node.id)

                        if localMetatableInfo then
                            local literal

                            if self.LiteralType == 'dictionary' then
                                literal = RandomLiterals.Dictionary()
                            elseif self.LiteralType == 'number' then
                                literal = RandomLiterals.Number()
                            elseif self.LiteralType == 'string' then
                                literal = RandomLiterals.String(pipeline)
                            else
                                literal = RandomLiterals.Any(pipeline)
                            end

                            return localMetatableInfo.getValue.constructor(node, literal)
                        end
                    end
                    if (node.kind == AstKind.AssignmentVariable) then
                        local localMetatableInfo = getLocalMetatableInfo(node.scope, node.id)

                        if localMetatableInfo then
                            return Ast.AssignmentIndexing(node, Ast.StringExpression(localMetatableInfo.valueName))
                        end
                    end
                    if (node.kind == AstKind.LocalFunctionDeclaration) then
                        local localMetatableInfo = getLocalMetatableInfo(node.scope, node.id)

                        if localMetatableInfo then
                            local funcLiteral = Ast.FunctionLiteralExpression(node.args, node.body)
                            local newExpr = self.CreateAssignmentExpression(self, localMetatableInfo, funcLiteral, node.scope)

                            return Ast.LocalVariableDeclaration(node.scope, {
                                node.id,
                            }, {newExpr})
                        end
                    end
                    if (node.kind == AstKind.FunctionDeclaration) then
                        local localMetatableInfo = getLocalMetatableInfo(node.scope, node.id)

                        if (localMetatableInfo) then
                            table.insert(node.indices, 1, localMetatableInfo.valueName)
                        end
                    end
                end)
                table.insert(ast.body.statements, 1, Ast.LocalVariableDeclaration(self.setMetatableVarScope, {
                    self.setMetatableVarId,
                }, {
                    Ast.VariableExpression(self.setMetatableVarScope:resolveGlobal'setmetatable'),
                }))
            end

            return ProifyLocals
        end

        function __DARKLUA_BUNDLE_MODULES.A()
            local v = __DARKLUA_BUNDLE_MODULES.cache.A

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.A = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Step, Ast, Scope, RandomStrings, Parser, Enums, logger = __DARKLUA_BUNDLE_MODULES.r(), __DARKLUA_BUNDLE_MODULES.b(), __DARKLUA_BUNDLE_MODULES.i(), __DARKLUA_BUNDLE_MODULES.v(), __DARKLUA_BUNDLE_MODULES.j(), __DARKLUA_BUNDLE_MODULES.g(), __DARKLUA_BUNDLE_MODULES.d()
            local AntiTamper = Step.extend(Step)

            AntiTamper.Description = 
[[This Step Breaks your Script when it is modified. This is only effective when using the new VM.]]
            AntiTamper.Name = 'Anti Tamper'
            AntiTamper.SettingsDescriptor = {
            }

            function AntiTamper.init(self, settings) end
            function AntiTamper.apply(self, ast, pipeline)
                if pipeline.PrettyPrint then
                    logger.warn(logger, string.format('"%s" cannot be used with PrettyPrint, ignoring "%s"', self.Name, self.Name))

                    return ast
                end

                local code = 'do local valid = true;'

                code = code .. 
[[local function tampersigma() if getfenv()["abc123youarecooked456"] then error("Tamper Detected!") end end tampersigma() 
local gmatch = string.gmatch;
    local err = function() error("Tamper Detected!") end;

    local pcallIntact2 = false;
    local pcallIntact = pcall(function()
        pcallIntact2 = true;
    end) and pcallIntact2;

    local random = math.random;
    local tblconcat = table.concat;
    local unpkg = table and table.unpack or unpack;
    local n = random(3, 65);
    local acc1 = 0;
    local acc2 = 0;
    local pcallRet = {pcall(function() local a = ]] .. tostring(math.random(1, 16777216)) .. ' - "' .. RandomStrings.randomString() .. '" ^ ' .. tostring(math.random(1, 16777216)) .. ' return "' .. RandomStrings.randomString() .. 
[[" / a; end)};
    local origMsg = pcallRet[2];
    local line = tonumber(gmatch(tostring(origMsg), ':(%d*):')());
    for i = 1, n do
        local len = math.random(1, 100);
        local n2 = random(0, 255);
        local pos = random(1, len);
        local shouldErr = random(1, 2) == 1;
        local msg = origMsg:gsub(':(%d*):', ':' .. tostring(random(0, 10000)) .. ':');
        local arr = {pcall(function()
            if random(1, 2) == 1 or i == n then
                local line2 = tonumber(gmatch(tostring(({pcall(function() local a = ]] .. tostring(math.random(1, 16777216)) .. ' - "' .. RandomStrings.randomString() .. '" ^ ' .. tostring(math.random(1, 16777216)) .. ' return "' .. RandomStrings.randomString() .. 
[[" / a; end)})[2]), ':(%d*):')());
                valid = valid and line == line2;
            end
            if shouldErr then
                error(msg, 0);
            end
            local arr = {};
            for i = 1, len do
                arr[i] = random(0, 255);
            end
            arr[pos] = n2;
            return unpkg(arr);
        end)};
        if shouldErr then
            valid = valid and arr[1] == false and arr[2] == msg;
        else
            valid = valid and arr[1];
            acc1 = (acc1 + arr[pos + 1]) % 256;
            acc2 = (acc2 + n2) % 256;
        end
    end
    valid = valid and acc1 == acc2;

    if valid then else
        repeat 
            return (function()
                while true do
                    l1, l2 = l2, l1;
                    err();
                end
            end)(); 
        until true;
        while true do
            l2 = random(1, 6);
            if l2 > 2 then
                l2 = tostring(l1);
            else
                l1 = l2;
            end
        end
        return;
    end
end

    -- Anti Function Arg Hook
    local obj = setmetatable({}, {
        __tostring = err,
    });
    obj[math.random(1, 100)] = obj;
    (function() end)(obj);

    repeat until valid;
    ]]

                local parsed = Parser.new(Parser, {
                    LuaVersion = Enums.LuaVersion.Lua51,
                }):parse(code)
                local doStat = parsed.body.statements[1]

                doStat.body.scope:setParent(ast.body.scope)
                table.insert(ast.body.statements, 1, doStat)

                return ast
            end

            return AntiTamper
        end

        function __DARKLUA_BUNDLE_MODULES.B()
            local v = __DARKLUA_BUNDLE_MODULES.cache.B

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.B = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Step, Ast, Scope, RandomStrings, Parser, Enums, logger, visitast, util = __DARKLUA_BUNDLE_MODULES.r(), __DARKLUA_BUNDLE_MODULES.b(), __DARKLUA_BUNDLE_MODULES.i(), __DARKLUA_BUNDLE_MODULES.v(), __DARKLUA_BUNDLE_MODULES.j(), __DARKLUA_BUNDLE_MODULES.g(), __DARKLUA_BUNDLE_MODULES.d(), __DARKLUA_BUNDLE_MODULES.t(), __DARKLUA_BUNDLE_MODULES.f()
            local AstKind, EncryptStrings = Ast.AstKind, Step.extend(Step)

            EncryptStrings.Description = 'This Step will encrypt strings within your Program.'
            EncryptStrings.Name = 'Encrypt Strings'
            EncryptStrings.SettingsDescriptor = {}

            function EncryptStrings.init(self, settings) end
            function EncryptStrings.CreateEncrypionService(self)
                local usedSeeds, secret_key_6, secret_key_7, secret_key_44, secret_key_8, floor = {}, math.random(0, 63), math.random(0, 127), math.random(0, 17592186044415), math.random(0, 255), math.floor

                local function primitive_root_257(idx)
                    local g, m, d = 1, 128, 2 * idx + 1

                    repeat
                        g, m, d = g * g * (d >= m and 3 or 1) % 257, m / 2, d % m
                    until m < 1

                    return g
                end

                local param_mul_8, param_mul_45, param_add_45, state_45, state_8, prev_values = primitive_root_257(secret_key_7), secret_key_6 * 4 + 1, secret_key_44 * 2 + 1, 0, 2, {}

                local function set_seed(seed_53)
                    state_45 = seed_53 % 35184372088832
                    state_8 = seed_53 % 255 + 2
                    prev_values = {}
                end
                local function gen_seed()
                    local seed

                    repeat
                        seed = math.random(0, 35184372088832)
                    until not usedSeeds[seed]

                    usedSeeds[seed] = true

                    return seed
                end
                local function get_random_32()
                    state_45 = (state_45 * param_mul_45 + param_add_45) % 35184372088832

                    repeat
                        state_8 = state_8 * param_mul_8 % 257
                    until state_8 ~= 1

                    local r = state_8 % 32
                    local n = floor(state_45 / 2 ^ (13 - (state_8 - r) / 32)) % 4294967296 / 2 ^ r

                    return floor(n % 1 * 4294967296) + floor(n)
                end
                local function get_next_pseudo_random_byte()
                    if #prev_values == 0 then
                        local rnd = get_random_32()
                        local low_16 = rnd % 65536
                        local high_16, b1 = (rnd - low_16) / 65536, low_16 % 256
                        local b2, b3 = (low_16 - b1) / 256, high_16 % 256
                        local b4 = (high_16 - b3) / 256

                        prev_values = {
                            b1,
                            b2,
                            b3,
                            b4,
                        }
                    end

                    return table.remove(prev_values)
                end
                local function encrypt(str)
                    local seed = gen_seed()

                    set_seed(seed)

                    local len, out, prevVal = string.len(str), {}, secret_key_8

                    for i = 1, len do
                        local byte = string.byte(str, i)

                        out[i] = string.char((byte - (get_next_pseudo_random_byte() + prevVal)) % 256)
                        prevVal = byte
                    end

                    return table.concat(out), seed
                end
                local function genCode()
                    local code = 'do\n\tlocal floor = math.floor\n\tlocal random = math.random;\n\tlocal remove = table.remove;\n\tlocal char = string.char;\n\tlocal state_45 = 0\n\tlocal state_8 = 2\n\tlocal digits = {}\n\tlocal charmap = {};\n\tlocal i = 0;\n\n\tlocal nums = {};\n\tfor i = 1, 256 do\n\t\tnums[i] = i;\n\tend\n\n\trepeat\n\t\tlocal idx = random(1, #nums);\n\t\tlocal n = remove(nums, idx);\n\t\tcharmap[n] = char(n - 1);\n\tuntil #nums == 0;\n\n\tlocal prev_values = {}\n\tlocal function get_next_pseudo_random_byte()\n\t\tif #prev_values == 0 then\n\t\t\tstate_45 = (state_45 * ' .. tostring(param_mul_45) .. ' + ' .. tostring(param_add_45) .. ') % 35184372088832\n\t\t\trepeat\n\t\t\t\tstate_8 = state_8 * ' .. tostring(param_mul_8) .. ' % 257\n\t\t\tuntil state_8 ~= 1\n\t\t\tlocal r = state_8 % 32\n\t\t\tlocal n = floor(state_45 / 2 ^ (13 - (state_8 - r) / 32)) % 2 ^ 32 / 2 ^ r\n\t\t\tlocal rnd = floor(n % 1 * 2 ^ 32) + floor(n)\n\t\t\tlocal low_16 = rnd % 65536\n\t\t\tlocal high_16 = (rnd - low_16) / 65536\n\t\t\tlocal b1 = low_16 % 256\n\t\t\tlocal b2 = (low_16 - b1) / 256\n\t\t\tlocal b3 = high_16 % 256\n\t\t\tlocal b4 = (high_16 - b3) / 256\n\t\t\tprev_values = { b1, b2, b3, b4 }\n\t\tend\n\t\treturn table.remove(prev_values)\n\tend\n\n\tlocal realStrings = {};\n\tSTRINGS = setmetatable({}, {\n\t\t__index = realStrings;\n\t\t__metatable = nil;\n\t});\n  \tfunction DECRYPT(str, seed)\n\t\tlocal realStringsLocal = realStrings;\n\t\tif(realStringsLocal[seed]) then else\n\t\t\tprev_values = {};\n\t\t\tlocal chars = charmap;\n\t\t\tstate_45 = seed % 35184372088832\n\t\t\tstate_8 = seed % 255 + 2\n\t\t\tlocal len = string.len(str);\n\t\t\trealStringsLocal[seed] = "";\n\t\t\tlocal prevVal = ' .. tostring(secret_key_8) .. ';\n\t\t\tfor i=1, len do\n\t\t\t\tprevVal = (string.byte(str, i) + get_next_pseudo_random_byte() + prevVal) % 256\n\t\t\t\trealStringsLocal[seed] = realStringsLocal[seed] .. chars[prevVal + 1];\n\t\t\tend\n\t\tend\n\t\treturn seed;\n\tend\nend'

                    return code
                end

                return {
                    encrypt = encrypt,
                    param_mul_45 = param_mul_45,
                    param_mul_8 = param_mul_8,
                    param_add_45 = param_add_45,
                    secret_key_8 = secret_key_8,
                    genCode = genCode,
                }
            end
            function EncryptStrings.apply(self, ast, pipeline)
                local Encryptor = self.CreateEncrypionService(self)
                local code = Encryptor.genCode()
                local newAst = Parser.new(Parser, {
                    LuaVersion = Enums.LuaVersion.Lua51,
                }):parse(code)
                local doStat, scope = newAst.body.statements[1], ast.body.scope
                local decryptVar, stringsVar = scope.addVariable(scope), scope.addVariable(scope)

                doStat.body.scope:setParent(ast.body.scope)
                visitast(newAst, nil, function(node, data)
                    if (node.kind == AstKind.FunctionDeclaration) then
                        if (node.scope:getVariableName(node.id) == 'DECRYPT') then
                            data.scope:removeReferenceToHigherScope(node.scope, node.id)
                            data.scope:addReferenceToHigherScope(scope, decryptVar)

                            node.scope = scope
                            node.id = decryptVar
                        end
                    end
                    if (node.kind == AstKind.AssignmentVariable or node.kind == AstKind.VariableExpression) then
                        if (node.scope:getVariableName(node.id) == 'STRINGS') then
                            data.scope:removeReferenceToHigherScope(node.scope, node.id)
                            data.scope:addReferenceToHigherScope(scope, stringsVar)

                            node.scope = scope
                            node.id = stringsVar
                        end
                    end
                end)
                visitast(ast, nil, function(node, data)
                    if (node.kind == AstKind.StringExpression) then
                        data.scope:addReferenceToHigherScope(scope, stringsVar)
                        data.scope:addReferenceToHigherScope(scope, decryptVar)

                        local encrypted, seed = Encryptor.encrypt(node.value)

                        return Ast.IndexExpression(Ast.VariableExpression(scope, stringsVar), Ast.FunctionCallExpression(Ast.VariableExpression(scope, decryptVar), {
                            Ast.StringExpression(encrypted),
                            Ast.NumberExpression(seed),
                        }))
                    end
                end)
                table.insert(ast.body.statements, 1, doStat)
                table.insert(ast.body.statements, 1, Ast.LocalVariableDeclaration(scope, util.shuffle{decryptVar, stringsVar}, {}))

                return ast
            end

            return EncryptStrings
        end

        function __DARKLUA_BUNDLE_MODULES.C()
            local v = __DARKLUA_BUNDLE_MODULES.cache.C

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.C = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            unpack = unpack or table.unpack

            local Step, Ast, Scope, visitast, util = __DARKLUA_BUNDLE_MODULES.r(), __DARKLUA_BUNDLE_MODULES.b(), __DARKLUA_BUNDLE_MODULES.i(), __DARKLUA_BUNDLE_MODULES.t(), __DARKLUA_BUNDLE_MODULES.f()
            local AstKind, NumbersToExpressions = Ast.AstKind, Step.extend(Step)

            NumbersToExpressions.Description = 'This Step Converts number Literals to Expressions'
            NumbersToExpressions.Name = 'Numbers To Expressions'
            NumbersToExpressions.SettingsDescriptor = {
                Treshold = {
                    type = 'number',
                    default = 1,
                    min = 0,
                    max = 1,
                },
                InternalTreshold = {
                    type = 'number',
                    default = 0.2,
                    min = 0,
                    max = 0.8,
                },
            }

            function NumbersToExpressions.init(self, settings)
                self.ExpressionGenerators = {
                    function(val, depth)
                        local val2 = math.random(-1048576, 1048576)
                        local diff = val - val2

                        if tonumber(tostring(diff)) + tonumber(tostring(val2)) ~= val then
                            return false
                        end

                        return Ast.AddExpression(self.CreateNumberExpression(self, val2, depth), self.CreateNumberExpression(self, diff, depth), false)
                    end,
                    function(val, depth)
                        local val2 = math.random(-1048576, 1048576)
                        local diff = val + val2

                        if tonumber(tostring(diff)) - tonumber(tostring(val2)) ~= val then
                            return false
                        end

                        return Ast.SubExpression(self.CreateNumberExpression(self, diff, depth), self.CreateNumberExpression(self, val2, depth), false)
                    end,
                }
            end
            function NumbersToExpressions.CreateNumberExpression(
                self,
                val,
                depth
            )
                if depth > 0 and math.random() >= self.InternalTreshold or depth > 15 then
                    return Ast.NumberExpression(val)
                end

                local generators = util.shuffle{
                    unpack(self.ExpressionGenerators),
                }

                for i, generator in ipairs(generators)do
                    local node = generator(val, depth + 1)

                    if node then
                        return node
                    end
                end

                return Ast.NumberExpression(val)
            end
            function NumbersToExpressions.apply(self, ast)
                visitast(ast, nil, function(node, data)
                    if node.kind == AstKind.NumberExpression then
                        if math.random() <= self.Treshold then
                            return self.CreateNumberExpression(self, node.value, 0)
                        end
                    end
                end)
            end

            return NumbersToExpressions
        end

        function __DARKLUA_BUNDLE_MODULES.D()
            local v = __DARKLUA_BUNDLE_MODULES.cache.D

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.D = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Step, Ast, visitast = __DARKLUA_BUNDLE_MODULES.r(), __DARKLUA_BUNDLE_MODULES.b(), __DARKLUA_BUNDLE_MODULES.t()
            local AstKind, AddVararg = Ast.AstKind, Step.extend(Step)

            AddVararg.Description = 'This Step Adds Vararg to all Functions'
            AddVararg.Name = 'Add Vararg'
            AddVararg.SettingsDescriptor = {}

            function AddVararg.init(self, settings) end
            function AddVararg.apply(self, ast)
                visitast(ast, nil, function(node)
                    if node.kind == AstKind.FunctionDeclaration or node.kind == AstKind.LocalFunctionDeclaration or node.kind == AstKind.FunctionLiteralExpression then
                        if #node.args < 1 or node.args[#node.args].kind ~= AstKind.VarargExpression then
                            node.args[#node.args + 1] = Ast.VarargExpression()
                        end
                    end
                end)
            end

            return AddVararg
        end

        function __DARKLUA_BUNDLE_MODULES.E()
            local v = __DARKLUA_BUNDLE_MODULES.cache.E

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.E = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Step, Ast, Scope = __DARKLUA_BUNDLE_MODULES.r(), __DARKLUA_BUNDLE_MODULES.b(), __DARKLUA_BUNDLE_MODULES.i()
            local Watermark = Step.extend(Step)

            Watermark.Description = 'This Step will add a watermark to the script'
            Watermark.Name = 'Watermark'
            Watermark.SettingsDescriptor = {
                Content = {
                    name = 'Content',
                    description = 'The Content of the Watermark',
                    type = 'string',
                    default = 
[[This Script is Part of the Prometheus Obfuscator by Levno_710]],
                },
                CustomVariable = {
                    name = 'Custom Variable',
                    description = 'The Variable that will be used for the Watermark',
                    type = 'string',
                    default = '_WATERMARK',
                },
            }

            function Watermark.init(self, settings) end
            function Watermark.apply(self, ast)
                local body = ast.body

                if string.len(self.Content) > 0 then
                    local scope, variable = ast.globalScope:resolve(self.CustomVariable)
                    local watermark, functionScope = Ast.AssignmentVariable(ast.globalScope, variable), Scope.new(Scope, body.scope)

                    functionScope.addReferenceToHigherScope(functionScope, ast.globalScope, variable)

                    local arg = functionScope.addVariable(functionScope)
                    local statement = Ast.PassSelfFunctionCallStatement(Ast.StringExpression(self.Content), 'gsub', {
                        Ast.StringExpression'.+',
                        Ast.FunctionLiteralExpression({
                            Ast.VariableExpression(functionScope, arg),
                        }, Ast.Block({
                            Ast.AssignmentStatement({watermark}, {
                                Ast.VariableExpression(functionScope, arg),
                            }),
                        }, functionScope)),
                    })

                    table.insert(ast.body.statements, 1, statement)
                end
            end

            return Watermark
        end

        function __DARKLUA_BUNDLE_MODULES.F()
            local v = __DARKLUA_BUNDLE_MODULES.cache.F

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.F = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Step, Ast, Scope, Watermark = __DARKLUA_BUNDLE_MODULES.r(), __DARKLUA_BUNDLE_MODULES.b(), __DARKLUA_BUNDLE_MODULES.i(), __DARKLUA_BUNDLE_MODULES.F()
            local WatermarkCheck = Step.extend(Step)

            WatermarkCheck.Description = 'This Step will add a watermark to the script'
            WatermarkCheck.Name = 'WatermarkCheck'
            WatermarkCheck.SettingsDescriptor = {
                Content = {
                    name = 'Content',
                    description = 'The Content of the WatermarkCheck',
                    type = 'string',
                    default = 
[[This Script is Part of the Prometheus Obfuscator by Levno_710]],
                },
            }

            local function callNameGenerator(generatorFunction, ...)
                if (type(generatorFunction) == 'table') then
                    generatorFunction = generatorFunction.generateName
                end

                return generatorFunction(...)
            end

            function WatermarkCheck.init(self, settings) end
            function WatermarkCheck.apply(self, ast, pipeline)
                self.CustomVariable = '_' .. callNameGenerator(pipeline.namegenerator, math.random(10000000000, 100000000000))

                pipeline.addStep(pipeline, Watermark.new(Watermark, self))

                local body, watermarkExpression, scope, variable = ast.body, Ast.StringExpression(self.Content), ast.globalScope:resolve(self.CustomVariable)
                local watermark = Ast.VariableExpression(ast.globalScope, variable)
                local notEqualsExpression, ifBody = Ast.NotEqualsExpression(watermark, watermarkExpression), Ast.Block({
                    Ast.ReturnStatement{},
                }, Scope.new(Scope, ast.body.scope))

                table.insert(body.statements, 1, Ast.IfStatement(notEqualsExpression, ifBody, {}, nil))
            end

            return WatermarkCheck
        end

        function __DARKLUA_BUNDLE_MODULES.G()
            local v = __DARKLUA_BUNDLE_MODULES.cache.G

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.G = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            return {
                WrapInFunction = __DARKLUA_BUNDLE_MODULES.s(),
                SplitStrings = __DARKLUA_BUNDLE_MODULES.u(),
                Vmify = __DARKLUA_BUNDLE_MODULES.x(),
                ConstantArray = __DARKLUA_BUNDLE_MODULES.y(),
                ProxifyLocals = __DARKLUA_BUNDLE_MODULES.A(),
                AntiTamper = __DARKLUA_BUNDLE_MODULES.B(),
                EncryptStrings = __DARKLUA_BUNDLE_MODULES.C(),
                NumbersToExpressions = __DARKLUA_BUNDLE_MODULES.D(),
                AddVararg = __DARKLUA_BUNDLE_MODULES.E(),
                WatermarkCheck = __DARKLUA_BUNDLE_MODULES.G(),
            }
        end

        function __DARKLUA_BUNDLE_MODULES.H()
            local v = __DARKLUA_BUNDLE_MODULES.cache.H

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.H = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local config, Ast, Enums, util, Parser, Unparser, logger, NameGenerators, Steps = __DARKLUA_BUNDLE_MODULES.a(), __DARKLUA_BUNDLE_MODULES.b(), __DARKLUA_BUNDLE_MODULES.g(), __DARKLUA_BUNDLE_MODULES.f(), __DARKLUA_BUNDLE_MODULES.j(), __DARKLUA_BUNDLE_MODULES.k(), __DARKLUA_BUNDLE_MODULES.d(), __DARKLUA_BUNDLE_MODULES.q(), __DARKLUA_BUNDLE_MODULES.H()
            local lookupify, LuaVersion, AstKind, isWindows = util.lookupify, Enums.LuaVersion, Ast.AstKind, package and package.config and type(package.config) == 'string' and package.config:sub(1, 1) == '\\'

            local function gettime()
                if isWindows then
                    return os.clock()
                else
                    return os.time()
                end
            end

            local Pipeline = {
                NameGenerators = NameGenerators,
                Steps = Steps,
                DefaultSettings = {
                    LuaVersion = LuaVersion.LuaU,
                    PrettyPrint = false,
                    Seed = 0,
                    VarNamePrefix = '',
                },
            }

            function Pipeline.new(self, settings)
                local luaVersion = settings.luaVersion or settings.LuaVersion or Pipeline.DefaultSettings.LuaVersion
                local conventions = Enums.Conventions[luaVersion]

                if (not conventions) then
                    logger.error(logger, 'The Lua Version "' .. luaVersion .. 
[[" is not recognised by the Tokenizer! Please use one of the following: "]] .. table.concat(util.keys(Enums.Conventions), '","') .. '"')
                end

                local prettyPrint, prefix, seed = settings.PrettyPrint or Pipeline.DefaultSettings.PrettyPrint, settings.VarNamePrefix or Pipeline.DefaultSettings.VarNamePrefix, settings.Seed or 0
                local pipeline = {
                    LuaVersion = luaVersion,
                    PrettyPrint = prettyPrint,
                    VarNamePrefix = prefix,
                    Seed = seed,
                    parser = Parser.new(Parser, {LuaVersion = luaVersion}),
                    unparser = Unparser.new(Unparser, {
                        LuaVersion = luaVersion,
                        PrettyPrint = prettyPrint,
                        Highlight = settings.Highlight,
                    }),
                    namegenerator = Pipeline.NameGenerators.MangledShuffled,
                    conventions = conventions,
                    steps = {},
                }

                setmetatable(pipeline, self)

                self.__index = self

                return pipeline
            end
            function Pipeline.fromConfig(self, config)
                config = config or {}

                local pipeline = Pipeline.new(Pipeline, {
                    LuaVersion = config.LuaVersion or LuaVersion.Lua51,
                    PrettyPrint = config.PrettyPrint or false,
                    VarNamePrefix = config.VarNamePrefix or '',
                    Seed = config.Seed or 0,
                })

                pipeline.setNameGenerator(pipeline, config.namegenerator or 'Il')

                local steps = config.Steps or {}

                for i, step in ipairs(steps)do
                    if type(step.Name) ~= 'string' then
                        logger.error(logger, 'Step.Name must be a String')
                    end

                    local constructor = pipeline.Steps[step.Name]

                    if not constructor then
                        logger.error(logger, string.format('The Step "%s" was not found!', step.Name))
                    end

                    pipeline.addStep(pipeline, constructor.new(constructor, step.Settings or {}))
                end

                return pipeline
            end
            function Pipeline.addStep(self, step)
                table.insert(self.steps, step)
            end
            function Pipeline.resetSteps(self, step)
                self.steps = {}
            end
            function Pipeline.getSteps(self)
                return self.steps
            end
            function Pipeline.setOption(self, name, value)
                assert(false, 'TODO')

                if (Pipeline.DefaultSettings[name] ~= nil) then
                else
                    logger.error(logger, string.format'"%s" is not a valid setting')
                end
            end
            function Pipeline.setLuaVersion(self, luaVersion)
                local conventions = Enums.Conventions[luaVersion]

                if (not conventions) then
                    logger.error(logger, 'The Lua Version "' .. luaVersion .. 
[[" is not recognised by the Tokenizer! Please use one of the following: "]] .. table.concat(util.keys(Enums.Conventions), '","') .. '"')
                end

                self.parser = Parser.new(Parser, {luaVersion = luaVersion})
                self.unparser = Unparser.new(Unparser, {luaVersion = luaVersion})
                self.conventions = conventions
            end
            function Pipeline.getLuaVersion(self)
                return self.luaVersion
            end
            function Pipeline.setNameGenerator(self, nameGenerator)
                if (type(nameGenerator) == 'string') then
                    nameGenerator = Pipeline.NameGenerators[nameGenerator]
                end
                if (type(nameGenerator) == 'function' or type(nameGenerator) == 'table') then
                    self.namegenerator = nameGenerator

                    return
                else
                    logger.error(logger, 
[[The Argument to Pipeline:setNameGenerator must be a valid NameGenerator function or function name e.g: "mangled"]])
                end
            end
            function Pipeline.apply(self, code, filename)
                local startTime = gettime()

                filename = filename or 'Anonymus Script'

                logger.info(logger, string.format('Applying Obfuscation Pipeline to %s ...', filename))

                if (self.Seed > 0) then
                    math.randomseed(self.Seed)
                else
                    math.randomseed(os.time())
                end

                logger.info(logger, 'Parsing ...')

                local parserStartTime, sourceLen, ast = gettime(), string.len(code), self.parser:parse(code)
                local parserTimeDiff = gettime() - parserStartTime

                logger.info(logger, string.format('Parsing Done in %.2f seconds', parserTimeDiff))

                for i, step in ipairs(self.steps)do
                    local stepStartTime = gettime()

                    logger.info(logger, string.format('Applying Step "%s" ...', step.Name or 'Unnamed'))

                    local newAst = step.apply(step, ast, self)

                    if type(newAst) == 'table' then
                        ast = newAst
                    end

                    logger.info(logger, string.format('Step "%s" Done in %.2f seconds', step.Name or 'Unnamed', gettime() - stepStartTime))
                end

                self.renameVariables(self, ast)

                code = self.unparse(self, ast)

                local timeDiff = gettime() - startTime

                logger.info(logger, string.format('Obfuscation Done in %.2f seconds', timeDiff))
                logger.info(logger, string.format('Generated Code size is %.2f%% of the Source Code size', (string.len(code) / sourceLen) * 100))

                return code
            end
            function Pipeline.unparse(self, ast)
                local startTime = gettime()

                logger.info(logger, 'Generating Code ...')

                local unparsed, timeDiff = self.unparser:unparse(ast), gettime() - startTime

                logger.info(logger, string.format('Code Generation Done in %.2f seconds', timeDiff))

                return unparsed
            end
            function Pipeline.renameVariables(self, ast)
                local startTime = gettime()

                logger.info(logger, 'Renaming Variables ...')

                local generatorFunction = self.namegenerator or Pipeline.NameGenerators.mangled

                if (type(generatorFunction) == 'table') then
                    if (type(generatorFunction.prepare) == 'function') then
                        generatorFunction.prepare(ast)
                    end

                    generatorFunction = generatorFunction.generateName
                end
                if not self.unparser:isValidIdentifier(self.VarNamePrefix) and #self.VarNamePrefix ~= 0 then
                    logger.error(logger, string.format('The Prefix "%s" is not a valid Identifier in %s', self.VarNamePrefix, self.LuaVersion))
                end

                local globalScope = ast.globalScope

                globalScope.renameVariables(globalScope, {
                    Keywords = self.conventions.Keywords,
                    generateName = generatorFunction,
                    prefix = self.VarNamePrefix,
                })

                local timeDiff = gettime() - startTime

                logger.info(logger, string.format('Renaming Done in %.2f seconds', timeDiff))
            end

            return Pipeline
        end

        function __DARKLUA_BUNDLE_MODULES.I()
            local v = __DARKLUA_BUNDLE_MODULES.cache.I

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.I = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Tokenizer, colors = __DARKLUA_BUNDLE_MODULES.h(), __DARKLUA_BUNDLE_MODULES.c()
            local TokenKind, lookupify = Tokenizer.TokenKind, __DARKLUA_BUNDLE_MODULES.f().lookupify

            return function(code, luaVersion)
                local out, tokenizer = '', Tokenizer.new(Tokenizer, {LuaVersion = luaVersion})

                tokenizer.append(tokenizer, code)

                local tokens, nonColorSymbols, defaultGlobals, currentPos = tokenizer.scanAll(tokenizer), lookupify{
                    ',',
                    ';',
                    '(',
                    ')',
                    '{',
                    '}',
                    '.',
                    ':',
                    '[',
                    ']',
                }, lookupify{
                    'string',
                    'table',
                    'bit32',
                    'bit',
                }, 1

                for _, token in ipairs(tokens)do
                    if token.startPos >= currentPos then
                        out = out .. string.sub(code, currentPos, token.startPos)
                    end
                    if token.kind == TokenKind.Ident then
                        if defaultGlobals[token.source] then
                            out = out .. colors(token.source, 'red')
                        else
                            out = out .. token.source
                        end
                    elseif token.kind == TokenKind.Keyword then
                        if token.source == 'nil' then
                            out = out .. colors(token.source, 'yellow')
                        else
                            out = out .. colors(token.source, 'yellow')
                        end
                    elseif token.kind == TokenKind.Symbol then
                        if nonColorSymbols[token.source] then
                            out = out .. token.source
                        else
                            out = out .. colors(token.source, 'yellow')
                        end
                    elseif token.kind == TokenKind.String then
                        out = out .. colors(token.source, 'green')
                    elseif token.kind == TokenKind.Number then
                        out = out .. colors(token.source, 'red')
                    else
                        out = out .. token.source
                    end

                    currentPos = token.endPos + 1
                end

                return out
            end
        end

        function __DARKLUA_BUNDLE_MODULES.J()
            local v = __DARKLUA_BUNDLE_MODULES.cache.J

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.J = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            return {
                Minify = {
                    LuaVersion = 'Lua51',
                    VarNamePrefix = '',
                    NameGenerator = 'Il',
                    PrettyPrint = false,
                    Seed = 0,
                    Steps = {},
                },
                Weak = {
                    LuaVersion = 'Lua51',
                    VarNamePrefix = '',
                    NameGenerator = 'Il',
                    PrettyPrint = false,
                    Seed = 0,
                    Steps = {
                        {
                            Name = 'Vmify',
                            Settings = {},
                        },
                        {
                            Name = 'ConstantArray',
                            Settings = {
                                Treshold = 1,
                                StringsOnly = true,
                            },
                        },
                        {
                            Name = 'WrapInFunction',
                            Settings = {},
                        },
                    },
                },
                Medium = {
                    LuaVersion = 'Lua51',
                    VarNamePrefix = '',
                    NameGenerator = 'Il',
                    PrettyPrint = false,
                    Seed = 0,
                    Steps = {
                        {
                            Name = 'EncryptStrings',
                            Settings = {},
                        },
                        {
                            Name = 'AntiTamper',
                            Settings = {},
                        },
                        {
                            Name = 'Vmify',
                            Settings = {},
                        },
                        {
                            Name = 'ConstantArray',
                            Settings = {
                                Treshold = 1,
                                StringsOnly = true,
                                Shuffle = true,
                                Rotate = true,
                                LocalWrapperTreshold = 0,
                            },
                        },
                        {
                            Name = 'NumbersToExpressions',
                            Settings = {},
                        },
                        {
                            Name = 'WrapInFunction',
                            Settings = {},
                        },
                    },
                },
                Strong = {
                    LuaVersion = 'Lua51',
                    VarNamePrefix = '',
                    NameGenerator = 'Il',
                    PrettyPrint = false,
                    Seed = 0,
                    Steps = {
                        {
                            Name = 'Vmify',
                            Settings = {},
                        },
                        {
                            Name = 'EncryptStrings',
                            Settings = {},
                        },
                        {
                            Name = 'AntiTamper',
                            Settings = {},
                        },
                        {
                            Name = 'Vmify',
                            Settings = {},
                        },
                        {
                            Name = 'ConstantArray',
                            Settings = {
                                Treshold = 1,
                                StringsOnly = true,
                                Shuffle = true,
                                Rotate = true,
                                LocalWrapperTreshold = 0,
                            },
                        },
                        {
                            Name = 'NumbersToExpressions',
                            Settings = {},
                        },
                        {
                            Name = 'WrapInFunction',
                            Settings = {},
                        },
                    },
                },
            }
        end

        function __DARKLUA_BUNDLE_MODULES.K()
            local v = __DARKLUA_BUNDLE_MODULES.cache.K

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.K = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            if not pcall(function()
                return math.random(1, 1099511627776)
            end) then
                local oldMathRandom = math.random

                math.random = function(a, b)
                    if not a and b then
                        return oldMathRandom()
                    end
                    if not b then
                        return math.random(1, a)
                    end
                    if a > b then
                        a, b = b, a
                    end

                    local diff = b - a

                    assert(diff >= 0)

                    if diff > 2147483647 then
                        return math.floor(oldMathRandom() * diff + a)
                    else
                        return oldMathRandom(a, b)
                    end
                end
            end

            _G.newproxy = _G.newproxy or function(arg)
                if arg then
                    return setmetatable({}, {})
                end

                return {}
            end

            local Pipeline, highlight, colors, Logger, Presets, Config, util = __DARKLUA_BUNDLE_MODULES.I(), __DARKLUA_BUNDLE_MODULES.J(), __DARKLUA_BUNDLE_MODULES.c(), __DARKLUA_BUNDLE_MODULES.d(), __DARKLUA_BUNDLE_MODULES.K(), __DARKLUA_BUNDLE_MODULES.a(), __DARKLUA_BUNDLE_MODULES.f()

            return {
                Pipeline = Pipeline,
                colors = colors,
                Config = util.readonly(Config),
                Logger = Logger,
                highlight = highlight,
                Presets = Presets,
            }
        end

        function __DARKLUA_BUNDLE_MODULES.L()
            local v = __DARKLUA_BUNDLE_MODULES.cache.L

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.L = v
            end

            return v.c
        end
    end
end

local Prometheus = __DARKLUA_BUNDLE_MODULES.L()

Prometheus.Logger.logLevel = Prometheus.Logger.LogLevel.Info

local function file_exists(file)
    local f = io.open(file, 'rb')

    if f then
        f.close(f)
    end

    return f ~= nil
end

string.split = function(str, sep)
    local fields, pattern = {}, string.format('([^%s]+)', sep)

    str.gsub(str, pattern, function(c)
        fields[#fields + 1] = c
    end)

    return fields
end

local function lines_from(file)
    if not file_exists(file) then
        return {}
    end

    local lines = {}

    for line in io.lines(file)do
        lines[#lines + 1] = line
    end

    return lines
end

local config, sourceFile, outFile, luaVersion, prettyPrint

Prometheus.colors.enabled = true

local i = 1

while i <= #arg do
    local curr = arg[i]

    if curr.sub(curr, 1, 2) == '--' then
        if curr == '--preset' or curr == '--p' then
            if config then
                Prometheus.Logger:warn'The config was set multiple times'
            end

            i = i + 1

            local preset = Prometheus.Presets[arg[i] ]

            if not preset then
                Prometheus.Logger:error(string.format('A Preset with the name "%s" was not found!', tostring(arg[i])))
            end

            config = preset
        elseif curr == '--config' or curr == '--c' then
            i = i + 1

            local filename = tostring(arg[i])

            if not file_exists(filename) then
                Prometheus.Logger:error(string.format('The config file "%s" was not found!', filename))
            end

            local content = table.concat(lines_from(filename), '\n')
            local func = loadstring(content)

            setfenv(func, {})

            config = func()
        elseif curr == '--out' or curr == '--o' then
            i = i + 1

            if outFile then
                Prometheus.Logger:warn'The output file was specified multiple times!'
            end

            outFile = arg[i]
        elseif curr == '--nocolors' then
            Prometheus.colors.enabled = false
        elseif curr == '--Lua51' then
            luaVersion = 'Lua51'
        elseif curr == '--LuaU' then
            luaVersion = 'LuaU'
        elseif curr == '--pretty' then
            prettyPrint = true
        elseif curr == '--saveerrors' then
            Prometheus.Logger.errorCallback = function(...)
                print(Prometheus.colors(Prometheus.Config.NameUpper .. ': ' .. 
..., 'red'))

                local args = {...}
                local message, fileName = table.concat(args, ' '), sourceFile.sub(sourceFile, 
-4) == '.lua' and sourceFile.sub(sourceFile, 0, -5) .. '.error.txt' or sourceFile .. '.error.txt'
                local handle = io.open(fileName, 'w')

                handle.write(handle, message)
                handle.close(handle)
                os.exit(1)
            end
        else
            Prometheus.Logger:warn(string.format('The option "%s" is not valid and therefore ignored', curr))
        end
    else
        if sourceFile then
            Prometheus.Logger:error(string.format('Unexpected argument "%s"', arg[i]))
        end

        sourceFile = tostring(arg[i])
    end

    i = i + 1
end

if not sourceFile then
    Prometheus.Logger:error'No input file was specified!'
end
if not config then
    Prometheus.Logger:warn'No config was specified, falling back to Minify preset'

    config = Prometheus.Presets.Minify
end

config.LuaVersion = luaVersion or config.LuaVersion
config.PrettyPrint = prettyPrint ~= nil and prettyPrint or config.PrettyPrint

if not file_exists(sourceFile) then
    Prometheus.Logger:error(string.format('The File "%s" was not found!', sourceFile))
end
if not outFile then
    if sourceFile.sub(sourceFile, -4) == '.lua' then
        outFile = sourceFile.sub(sourceFile, 0, -5) .. '.obfuscated.lua'
    else
        outFile = sourceFile .. '.obfuscated.lua'
    end
end

local source, pipeline = table.concat(lines_from(sourceFile), '\n'), Prometheus.Pipeline:fromConfig(config)
local out = pipeline.apply(pipeline, source, sourceFile)

Prometheus.Logger:info(string.format('Writing output to "%s"', outFile))

local handle = io.open(outFile, 'w')

handle.write(handle, out)
handle.close(handle)
