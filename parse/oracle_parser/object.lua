function ret_object_with_qual(qual)
    return return_p(function(obj)
        return object.O_WithQual(obj, qual)
    end)
end

-- BASE OBJECTS

local parse_base_object = optional(parse_word("a")) >> choice {
    parse_word("this") >> parse_type - object.O_WithQual(object.O_Base(), qualification.Is_This()),
    parse_word("it") - object.O_It(),
    parse_word("token") - object.O_WithQual(object.O_Base(), qualification.Is_Token()),
    parse_word("spell") - object.O_WithQual(object.O_Base(), qualification.Is_Spell()),
    parse_type ~ function(typ) return object.O_WithQual(object.O_Base(), qualification.Is_IsType(typ)) end,
    parse_subtype ~ function(typ) return object.O_WithQual(object.O_Base(), qualification.Is_IsType(typ)) end,
}

-- PREFIXES

---"another OBJECT"
local prefix_another = parse_word("another") >> ret_object_with_qual(qualification.Is_NotThis())

---"[color] OBJECT"
local prefix_color = parse_color_word //
    function(color) return ret_object_with_qual(qualification.Is_IsColor(color)) end

---"[power]/[toughness] OBJECT"
local prefix_power_toughness_definition = parse_pt_definition //
    function(pt) return ret_object_with_qual(qualification.Is_PowerToughness(pt)) end

---"attacking OBJECT"
local prefix_attacking = parse_word("attacking") >> ret_object_with_qual(qualification.Is_Attacking())

---"blocking OBJECT"
local prefix_blocking = parse_word("blocking") >> ret_object_with_qual(qualification.Is_Blocking())

local parse_qualification_prefix = choice {
    prefix_another,
    parse_word("nontoken") >> ret_object_with_qual(qualification.Is_NotToken()),
    prefix_color,
    prefix_power_toughness_definition,
    parse_type // function(typ) return ret_object_with_qual(qualification.Is_IsType(typ)) end,
    prefix_attacking,
    prefix_blocking,
}

-- SUFFIXES

---"OBJECT you control"
local suffix_you_control = parse_words{ "you", "control" } >> ret_object_with_qual(qualification.Is_ControlledBy(player.P_You()))

---"OBJECT an opponent controls"
local suffix_opponent_controls = parse_words{ "an", "opponent", "controls" } >> ret_object_with_qual(qualification.Is_ControlledBy(player.P_Opponent()))

---"OBJECT with [keyword]"
local suffix_with_keyword = (parse_word("with") >> parse_keyword_ability) //
    function(kw) return ret_object_with_qual(qualification.Is_HasKeyword(kw)) end

---"OBJECT with power N or greater"
local suffix_with_power_ge = (parse_words{ "with", "power" } >> parse_any_number << parse_words{ "or", "greater" }) //
    function(power) return ret_object_with_qual(qualification.Is_PowerAtLeast(power)) end

---"OBJECT with toughness N or greater"
local suffix_with_toughness_ge = (parse_words{ "with", "toughness" } >> parse_any_number << parse_words{ "or", "greater" }) // 
    function(power) return ret_object_with_qual(qualification.Is_ToughnessAtLeast(power)) end

local parse_qualification_suffix = choice {
    suffix_you_control,
    suffix_opponent_controls,
    suffix_with_keyword,
    suffix_with_power_ge,
    suffix_with_toughness_ge,
    parse_type // function(typ) return ret_object_with_qual(qualification.Is_IsType(typ)) end,
    parse_word("token") >> ret_object_with_qual(qualification.Is_Token())
}

local parse_single_object = normalize_object(suffix1(prefix1(parse_base_object, parse_qualification_prefix), parse_qualification_suffix))

parse_object_ref.value = choice {
    parse_comma_list(parse_single_object),
    parse_single_object,
}