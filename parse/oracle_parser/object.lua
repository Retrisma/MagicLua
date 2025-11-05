function ret_qual(qual)
    return return_p(function(list)
        table.insert(list, qual)
        return list
    end)
end

-- BASE OBJECTS

---"this"
local parse_this = parse_word("this") >> parse_type - object.O_This()

---"it"
local parse_it = parse_word("it") - object.O_It()

---"[card type]"
local parse_type_object = parse_type ~ qualification.Is_IsType

---"[card subtype]"
local parse_subtype_object = parse_subtype ~ qualification.Is_IsType

local parse_base_object = many1(choice {
    -- parse_it, TODO: handle separately
    parse_word("token") - qualification.Is_Token(),
    parse_word("spell") - qualification.Is_Spell(),
    parse_type_object,
    parse_subtype_object
})

-- PREFIXES

---"another OBJECT"
local prefix_another = parse_word("another") >> ret_qual(qualification.Is_NotThis())

---"nontoken OBJECT"
local prefix_nontoken = parse_word("nontoken") >> ret_qual(qualification.Is_NotToken())

---"[color] OBJECT"
local prefix_color = parse_color_word //
    function(color) return ret_qual(qualification.Is_IsColor(color)) end

---"[power]/[toughness] OBJECT"
local prefix_power_toughness_definition = parse_pt_definition //
    function(pt) return ret_qual(qualification.Is_PowerToughness(pt)) end

---"attacking OBJECT"
local prefix_attacking = parse_word("attacking") >> ret_qual(qualification.Is_Attacking())

---"blocking OBJECT"
local prefix_blocking = parse_word("blocking") >> ret_qual(qualification.Is_Blocking())

local parse_qualification_prefix = choice {
    prefix_another,
    prefix_nontoken,
    prefix_color,
    prefix_power_toughness_definition,
    prefix_attacking,
    prefix_blocking,
}

-- SUFFIXES

---"OBJECT you control"
local suffix_you_control = parse_words{ "you", "control" } >> ret_qual(qualification.Is_ControlledBy(player.P_You()))

---"OBJECT an opponent controls"
local suffix_opponent_controls = parse_words{ "an", "opponent", "controls" } >> ret_qual(qualification.Is_ControlledBy(player.P_Opponent()))

---"OBJECT with [keyword]"
local suffix_with_keyword = (parse_word("with") >> parse_keyword_ability) //
    function(kw) return ret_qual(qualification.Is_HasKeyword(kw)) end

---"OBJECT with power N or greater"
local suffix_with_power_ge = (parse_words{ "with", "power" } >> parse_comparison) //
    function(power) return ret_qual(qualification.Is_Power(power)) end

---"OBJECT with toughness N or greater"
local suffix_with_toughness_ge = (parse_words{ "with", "toughness" } >> parse_comparison) //
    function(tough) return ret_qual(qualification.Is_Toughness(tough)) end

local parse_qualification_suffix = choice {
    suffix_you_control,
    suffix_opponent_controls,
    suffix_with_keyword,
    suffix_with_power_ge,
    suffix_with_toughness_ge,
}

local parse_single_object = suffix1(prefix1(parse_base_object, parse_qualification_prefix), parse_qualification_suffix) ~ object.O_Qualified

return choice {
    parse_this,
    parse_it,
    parse_comma_list(parse_single_object),
    parse_single_object,
}