---@class Parser
---@field parser_fn function Token[] -> Result

---@class Result
---@field status "success"|"failure"

parser_mt = {
    __band = function (a, b) return and_then(a, b) end,
    __bor = function (a, b) return or_else(a, b) end,

    __mod = function (a, b) return run_p(a, b) end,
    __bxor = function (a, b) return map_p(b, a) end,
    __sub = function(a, b) return discard_p(b, a) end,

    __shl = function (a, b) return and_keep_left(a, b) end,
    __shr = function (a, b) return and_keep_right(a, b) end,

    __idiv = function (a, b) return bind_p(b, a) end
}

---@param head Node
---@param tail Token[]
---@return Result
function success(head, tail)
    return {
        status = "success",
        head = head,
        tail = tail
    }
end

function failure(reason)
    return {
        status = "failure",
        reason = reason
    }
end

---@param parser_fn function Token[] -> Result
---@return Parser
function new_parser(parser_fn)
    return setmetatable({
        parser_fn = parser_fn
    }, parser_mt)
end

---@param parser Parser
---@param stream Token[]
---@return Result
function run_p(parser, stream)
    return parser.parser_fn(stream)
end

---@param x any
---@return Parser
function return_p(x)
    return new_parser(function(stream) return success(x, stream) end)
end

---@param parser Parser
---@param binding_fn function Node -> Parser
---@return Parser
function bind_p(binding_fn, parser)
    return new_parser(
        function(stream)
            local result = parser % stream

            if result.status == "success" then
                return binding_fn(result.head) % result.tail
            else
                return result
            end
        end
    )
end

---@param parser_before Parser
---@param parser_after Parser
---@return Parser
function and_then(parser_before, parser_after)
    return (parser_before // (function (result_before)
        return parser_after // (function (result_after)
            return return_p({ result_before, result_after })
        end)
    end))
end

---@param parser_if Parser
---@param parser_else Parser
---@return Parser
function or_else(parser_if, parser_else)
    local function parser_fn(stream)
        local pre_stream = table.copy(stream)

        local result = parser_if % stream

        if result.status == "success" then
            return result
        else
            return parser_else % pre_stream
        end
    end

    return new_parser(parser_fn)
end

---@param parsers Parser[]
---@return Parser
function choice(parsers)
    return table.reduce(parsers, or_else)
end

---@param fn function a -> b
---@param parser Parser
---@return Parser
function map_p(fn, parser)
    local function parser_fn(stream)
        local result = parser % stream

        if result.status == "success" then
            result.head = fn(result.head)
        end

        return result
    end

    return new_parser(parser_fn)
end

---@param o any
---@param parser Parser
---@return Parser
function discard_p(o, parser)
    local function parser_fn(stream)
        local result = parser % stream

        if result.status == "success" then
            result.head = o
        end

        return result
    end

    return new_parser(parser_fn)
end

---@param parser_before Parser
---@param parser_after Parser
---@return Parser
function and_keep_left(parser_before, parser_after)
    local result = parser_before & parser_after
    return result ~ map2(function(a, _) return a end)
end

---@param parser_before Parser
---@param parser_after Parser
---@return Parser
function and_keep_right(parser_before, parser_after)
    local result = parser_before & parser_after
    return result ~ map2(function(_, b) return b end)
end

---@param parser Parser
---@param stream Token[]
---@return Node[]
---@return Token[]
function zero_or_more(parser, stream)
    local result = parser % stream

    if result.status == "success" then
        local head, tail = zero_or_more(parser, result.tail)
        table.insert(head, 1, result.head)
        return head, tail
    else
        return {}, stream
    end
end

---@param parser Parser
---@return Parser
function many(parser)
    local function parser_fn(stream)
        local head, tail = zero_or_more(parser, stream)
        return success(head, tail)
    end

    return new_parser(parser_fn)
end

---@param parser Parser
---@return Parser
function many1(parser)
    local function parser_fn(stream)
        local head, tail = zero_or_more(parser, stream)
        if #head == 0 then
            return failure("not many1")
        end
        return success(head, tail)
    end

    return new_parser(parser_fn)
end

function optional(parser)
    local function parser_fn(stream)
        local result = parser % stream

        if result.status == "success" then
            return success(option.Some(result.head), result.tail)
        else
            return success(option.None(), stream)
        end
    end

    return new_parser(parser_fn)
end

function sep_by_1(parser, sep_parser)
    local sep_then_p = sep_parser >> parser
    return (parser & many(sep_then_p)) ~ map2(function(p, plist)
        table.insert(plist, 1, p)
        return plist
    end)
end

function sep(parser, sep_parser)
    return sep_by_1(parser, sep_parser) | return_p( {} )
end

function sep_and_end(parser, sep_parser)
    return sep(parser, sep_parser) << optional(sep_parser)
end

function between(symbol1, parser, symbol2)
    return parse_symbol(symbol1) >> parser << parse_symbol(symbol2)
end

function between_parens(parser) return between("(", parser, ")") end
function between_brackets(parser) return between("[", parser, "]") end
function between_braces(parser) return between("{", parser, "}") end
function between_colons(parser) return between("::", parser, "::") end

--todo: operator precedence
function chainl1(parser, op_parser)
    local function rest(acc)
        return op_parser // function (f)
            return parser // function (v)
                return rest(f(acc, v))
            end
        end | return_p(acc)
    end

    return parser // rest
end

function prefix1(parser, op_parser)
    local function rest()
        return op_parser // function(f) return rest () ~ f end | parser
    end

    return rest()
end

function suffix1(parser, op_parser)
    local function rest(base)
        return op_parser // function(f) return rest(f(base)) end | return_p(base)
    end

    return parser // rest
end

function create_parser_forwarded_to_ref()
    local dummy_parser = new_parser(function() error "unfixed forwarded parser" end)

    local parser_ref = {
        value = dummy_parser
    }

    local forwarded_parser = new_parser(function(stream)
        return parser_ref.value.parser_fn(stream)
    end)

    return forwarded_parser, parser_ref
end