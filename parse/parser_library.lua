---@class Parser
---@field parser_fn function Token[] -> Result

---@class ParserWrapper
---@field value Parser

---@class Success
---@field status "success"
---@field head Node
---@field tail Stream

---@class Failure
---@field status "failure"
---@field reason string

---@alias Result Success | Failure

---@alias Stream Token[]

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
---@param tail Stream
---@return Success
function success(head, tail)
    return {
        status = "success",
        head = head,
        tail = tail
    }
end

---@param reason string
---@return Failure
function failure(reason)
    return {
        status = "failure",
        reason = reason
    }
end

---Construct a new parser with the specified parsing function.
---@param parser_fn function Stream -> Result
---@return Parser
function new_parser(parser_fn)
    return setmetatable({
        parser_fn = parser_fn
    }, parser_mt)
end

---Run a parser on a stream of tokens.
---@param parser Parser
---@param stream Stream
---@return Result
---@usage parser % stream
function run_p(parser, stream)
    return parser.parser_fn(stream)
end

---Parser that always succeeds with x without consuming any input.
---@param x any The constant value that will be the head result of the parser.
---@return Parser
function return_p(x)
    return new_parser(function(stream) return success(x, stream) end)
end

---Parser that always fails with the specified reason.
---@param reason string
---@return Parser
function fail_p(reason)
    return new_parser(function(_) return failure(reason) end)
end

---Parser that binds a function to another parser by running the binding function on its head result.
---@param parser Parser
---@param binding_fn function Node -> Parser
---@return Parser
---@usage parser // binding_fn
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

---Parser that runs two parsers in sequence, and returns a parser with a pair of their results.
---@param parser_before Parser
---@param parser_after Parser
---@return Parser
---@usage parser_before & parser_after
function and_then(parser_before, parser_after)
    return (parser_before // (function (result_before)
        return parser_after // (function (result_after)
            return return_p({ result_before, result_after })
        end)
    end))
end

---Parser that runs the first parser, and returns its result if it succeeds.
---Otherwise, it returns the result of the second parser.
---@param parser_if Parser
---@param parser_else Parser
---@return Parser
---@usage parser_if | parser_else
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

---Parser that runs a list of sequencers in order, returning the first success.
---@param parsers Parser[]
---@return Parser
function choice(parsers)
    return table.reduce(parsers, or_else)
end

---Parser that passes the result of a parser to a function to transform the result's head.
---@param fn function 'a -> 'b
---@param parser Parser
---@return Parser
---@usage parser ~ fn
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

---Parser that discards its previous head in favor of a constant x.
---@param x any The constant value that will be the head result of the parser.
---@param parser Parser
---@return Parser
---@usage parser - x
function discard_p(x, parser)
    return parser // function(_)
        return return_p(x)
    end
end

---Run and_then on two parsers, but only keep the leftmost result.
---@param parser_before Parser The parser whose result will be kept.
---@param parser_after Parser The parser whose result will be discarded.
---@return Parser
---@usage parser_before << parser_after
function and_keep_left(parser_before, parser_after)
    local result = parser_before & parser_after
    return result ~ map2(function(a, _) return a end)
end

---Run and_then on two parsers, but only keep the rightmost result.
---@param parser_before Parser The parser whose result will be discarded.
---@param parser_after Parser The parser whose result will be kept.
---@return Parser
---@usage parser_before >> parser_after
function and_keep_right(parser_before, parser_after)
    local result = parser_before & parser_after
    return result ~ map2(function(_, b) return b end)
end

---Recursively apply a parser to a stream until it fails, and return all results as well as the remaining stream.
---@param parser Parser
---@param stream Stream
---@return Node[]
---@return Stream
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

---Parser that matches its component parser as many times as it can, including 0 times.
---@param parser Parser
---@return Parser
function many(parser)
    local function parser_fn(stream)
        local head, tail = zero_or_more(parser, stream)
        return success(head, tail)
    end

    return new_parser(parser_fn)
end

---Parser that matches its component parser as many times as it can.
---Fails if it can't match at at least once.
---@param parser Parser
---@return Parser
function many1(parser)
    return parser & many(parser) ~ map2(function(p, plist)
        table.insert(plist, 1, p)
        return plist
    end)
end

---Parser that returns success only if the whole stream was used.
---@param parser Parser
---@return Parser
function all(parser)
    return parser // function(result)
        return new_parser(function(stream)
            if #stream == 0 then
                return success(result, stream)
            else
                return failure("all: did not use all tokens")
            end
        end)
    end
end

---Parser that matches its first component parser as many times as it can, alternating with its second component parser.
---Fails if it can't match the first parser at least once.
---@param parser Parser
---@param sep_parser Parser
---@return Parser
function sep1(parser, sep_parser)
    local sep_then_p = sep_parser >> parser
    return (parser & many(sep_then_p)) ~ map2(function(p, plist)
        table.insert(plist, 1, p)
        return plist
    end)
end

---Parser that matches its first component parser as many times as it can, alternating with its second component parser.
---@param parser Parser
---@param sep_parser Parser
---@return Parser
function sep(parser, sep_parser)
    return sep1(parser, sep_parser) | return_p( {} )
end

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

---Parser that recursively applies an operand parser as a prefix before the main component parser.
---@param parser Parser The main component parser.
---@param op_parser Parser The prefix operand parser.
---@return Parser
function prefix1(parser, op_parser)
    local function rest()
        return op_parser // function(f) return rest() ~ f end | parser
    end

    return rest()
end

---Parser that recursively applies an operand parser as a suffix after the main component parser.
---@param parser Parser The main component parser.
---@param op_parser Parser The suffix operand parser.
---@return Parser
function suffix1(parser, op_parser)
    local function rest(base)
        return op_parser // function(f) return rest(f(base)) end | return_p(base)
    end

    return parser // rest
end

---Creates a forwarded parser that, when redefined, will allow a parser to reference itself.
---@return Parser
---@return ParserWrapper
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