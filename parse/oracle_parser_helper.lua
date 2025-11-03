require"parse/tools"
require"parse/parser_library"
require"parse/grammar"

---@param token_type "TWord"|"TNum"|"TSym"
---@return Parser
function parse_any(token_type)
    return new_parser(function(stream)
        if #stream == 0 then
            return failure("no more input")
        end

        local head = table.peek(stream)

        if head[1] == token_type then
            return success(table.pop(stream)[2], stream)
        else
            return failure("not a " .. token_type)
        end
    end)
end

---@type Parser
parse_any_number = parse_any("TNum")

---@type Parser
parse_any_symbol = parse_any("TSym")

---@type Parser
parse_any_word = parse_any("TWord")

---@param token_type "TWord"|"TNum"|"TSym"
---@param content any
---@return Parser
function parse_specific(token_type, content)
    return new_parser(function(stream)
        if #stream == 0 then
            return failure("no more input")
        end

        local head = table.peek(stream)

        if head[1] == token_type and head[2] == content then
            return success(table.pop(stream)[2], stream)
        else
            return failure("not a " .. content)
        end
    end)
end

---@param num number
---@return Parser
function parse_number(num)
    return parse_specific("TNum", num)
end

---@param symbol string
---@return Parser
function parse_symbol(symbol)
    return parse_specific("TSym", symbol)
end

---@param word string
---@return Parser
function parse_word(word)
    return parse_specific("TWord", word)
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

function parse_plural(word)
    local function parser_fn(stream)
        local result = parse_word(word .. "s") % stream

        if result.status == "success" then
            return success(word, result.tail)
        end

        return failure("not plural of " .. word)
    end

    return new_parser(parser_fn)
end

---@param word string
---@return Parser
--TODO: handle more plurals
function parse_word_or_plural(word)
    return parse_word(word) | parse_plural(word)
end

---@param words table<string>
---@return Parser
function parse_words(words)
    local parsers = table.map(words, function(x) return parse_word(x) end)
    return table.reduce(parsers, function(a, b) return a & b end)
end

---@param words table<string>
---@return Parser
function choose_string(words)
    return parse_any_word // function(word)
        if table.has(words, word) then
            return return_p(word)
        else
            return fail_p("choose_string: did not have specified string")
        end
    end
end

--TODO: reimplement choose_string_or_plural

---@type Parser
parse_plus_or_minus = parse_symbol("+") | parse_symbol("-")

---@param each Parser
---@returns Parser
parse_comma_list = function(each)
    local comma_separator = parse_symbol(",")
    local or_separator = optional(parse_symbol(",")) & parse_word("or")
    
    local function parser_fn(stream)
        local result = sep(each, (or_separator | comma_separator)) % stream

        if result.status == "success" then
            if #result.head >= 2 then
                return success(logic.OrList(result.head), result.tail)
            end
        end

        return failure("comma list needs at least 2 entries")
    end

    return new_parser(parser_fn)
end

function normalize_object(parser)
    return parser ~ function (obj)
        if obj[1] == "ObjectThat" then
            local function flatten_nesting(current, accum)
                if current[1] == "ObjectThat" then
                    table.insert(accum, current[3])
                    return flatten_nesting(current[2], accum)
                else
                    return object.O_Qualified(accum)
                end
            end
            
            return flatten_nesting(obj, {})
        end
        
        return obj
    end
end