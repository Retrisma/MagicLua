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

function parse_words(words)
    local parsers = table.map(words, function(x) return parse_word(x) end)
    return table.reduce(parsers, function(a, b) return a & b end)
end

local parse_color_abbr = choice {
    parse_word("W"),
    parse_word("U"),
    parse_word("B"),
    parse_word("R"),
    parse_word("G"),
    parse_word("C")
}

parse_mana = choice {
    parse_any_number ~ mana_symbol.MS_Mana,
    parse_color_abbr ~ mana_symbol.MS_Mana
}

parse_mana_symbol = between_brackets(parse_mana)

parse_cost = choice {
    --many1(parse_mana_symbol) ~ cost.C_PayMana,
    parse_word("pay") >> parse_any_number << parse_word("life") ~ cost.C_PayLife
}

parse_object = choice {
    parse_words{"this", "creature"} ~ object.O_This

}

parse_triggered_ability_when_condition = choice {
    (parse_object << parse_word("enters")) ~ triggered_ability_when_condition.WhenEnters
}

parse_triggered_ability_condition = choice {
    parse_word("when") >> parse_triggered_ability_when_condition
}

parse_effect = choice {
    parse_words{"draw", "a", "card"} ~ effect.E_DrawCard
}

parse_triggered_ability = choice {
    (parse_triggered_ability_condition << parse_symbol(",")) & parse_effect << parse_symbol(".")
}

parse_keyword_ability = choice {
    parse_word("flying") ~ ability.A_Keyword,
    parse_word("lifelink") ~ ability.A_Keyword,
    parse_word("trample") ~ ability.A_Keyword,
    parse_word("vigilance") ~ ability.A_Keyword,
    parse_word("reach") ~ ability.A_Keyword,
    parse_word("menace") ~ ability.A_Keyword,
    parse_words{"first", "strike"} ~ function() return ability.A_Keyword("first strike") end,
    parse_words{"double", "strike"} ~ function() return ability.A_Keyword("double strike") end,
    (parse_word("ward") & parse_symbol("—")) >> parse_cost ~ ability.A_Ward
}

parse_static_ability = choice {
    parse_keyword_ability
}

parse_ability = choice {
    parse_triggered_ability,
    parse_static_ability
}

parse_card = sep(parse_ability, parse_symbol("NEWLINE") | parse_symbol(","))