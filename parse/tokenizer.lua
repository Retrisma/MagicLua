token = {
    TWord = function(word) return { "TWord", word } end,

    --includes newlines, {, •, etc
    TSym = function(sym) return { "TSym", sym } end,

    TNum = function(num) return { "TNum", num } end
}

local symbols = {
    "\n", "{", "}", ",", ".", "+", "-", "/", "—", ":", "−",
    "•", "\""
}

function construct_literal(tbl)
    out = {}
    for k,v in pairs(tbl) do
        out[k] = ""
        for c in string.gmatch(v, ".") do
            out[k] = out[k] .. "%" .. c
        end
    end
    return out
end

local symbol_regex = construct_literal(symbols)
local whitespace_regex = "^([ ]+)"
local word_regex = "^[%w']+"
local number_regex = "^%d+"
local reminder_text_regex = "^%(.*%)"

function match_reserved_symbols(str)
    for i,v in ipairs(symbol_regex) do
        if string.match(str, "^" .. v) then
            return symbol_regex[i]
        end
    end

    return nil
end

function tokenize(input)
    local token_stream = {}

    local function iter()
        --remove leading whitespace
        input = string.gsub(input, whitespace_regex, "")

        local scratch = string.match(input, number_regex)
        if scratch then
            table.insert(token_stream, token.TNum(scratch))
            input = string.gsub(input, number_regex, "")
            return
        end

        scratch = string.match(input, reminder_text_regex)
        if scratch then
            input = string.gsub(input, reminder_text_regex, "")
            return
        end

        scratch = match_reserved_symbols(input)
        if scratch then
            scratch = string.gsub(scratch, "%%", "")

            input = string.sub(input, #scratch + 1)

            if scratch == "\n" then
                scratch = "NEWLINE"
            end

            table.insert(token_stream, token.TSym(scratch))
            return
        end

        scratch = string.match(input, word_regex)
        if scratch then
            table.insert(token_stream, token.TWord(scratch:lower()))
            input = string.gsub(input, word_regex, "")
            return
        end

        error(input)
    end

    while string.len(input) > 0 do
        iter()
    end

    return token_stream
end