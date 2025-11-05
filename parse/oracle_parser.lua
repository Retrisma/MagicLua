require"parse/parser_library"
require"parse/grammar"
require"parse/oracle_parser_helper"
local language = require"parse/language"

parse_object, parse_object_ref = create_parser_forwarded_to_ref()


parse_color_abbr = choose_string(language.color_abbreviations)
parse_color_word = choose_string(language.color_words)
parse_creature_type = choose_string(language.creature_subtypes)

parse_subtype = choice {
    parse_creature_type
}

parse_mana = choice {
    parse_any_number ~ mana_symbol.MS_Mana,
    parse_color_abbr ~ mana_symbol.MS_Mana
}

parse_mana_symbol = between_braces(parse_mana)

parse_tap_symbol = between_braces(parse_word("t"))

parse_cost = sep1(choice {
    many1(parse_mana_symbol) ~ cost.Pay_Mana,
    parse_word("pay") >> parse_any_number << parse_word("life") ~ cost.Pay_Life,
    parse_tap_symbol - cost.Pay_Tap(),
    parse_word("sacrifice") >> parse_object ~ cost.Pay_Sacrifice
}, parse_symbol(","))

parse_type = choice {
    parse_word_or_plural("creature") ~ card_type.T_Creature,
    parse_word_or_plural("artifact") ~ card_type.T_Artifact,
    parse_word_or_plural("enchantment") ~ card_type.T_Enchantment,
    parse_word_or_plural("land") ~ card_type.T_Land,
    parse_word_or_plural("instant") ~ card_type.T_Instant,
    parse_word_or_plural("sorcery") ~ card_type.T_Sorcery,
}

parse_pt_modifier = ((parse_plus_or_minus & parse_any_number) << parse_symbol("/")) & parse_plus_or_minus & parse_any_number ~ map4(pt_modifier.PT_Mod)
parse_pt_definition = (parse_any_number << parse_symbol("/")) & parse_any_number ~ map2(pt_modifier.PT_Def)

parse_counter = choice {
    parse_pt_modifier << parse_word("counter") ~ counter.Cntr_PT,
    parse_any_word << parse_word("counter") ~ counter.Cntr_Named,
}

parse_keyword_ability = choice {
    parse_word("flying") - keyword_ability.KW_Flying(),
    parse_word("lifelink") - keyword_ability.KW_Lifelink(),
    parse_word("trample") - keyword_ability.KW_Trample(),
    parse_word("vigilance") - keyword_ability.KW_Vigilance(),
    parse_word("reach") - keyword_ability.KW_Reach(),
    parse_word("menace") - keyword_ability.KW_Menace(),
    parse_words{"first", "strike"} - keyword_ability.KW_FirstStrike(),
    parse_words{"double", "strike"} - keyword_ability.KW_DoubleStrike(),
    parse_word("flash") - keyword_ability.KW_Flash(),
    parse_word("deathtouch") - keyword_ability.KW_Deathtouch(),
    parse_word("prowess") - keyword_ability.KW_Prowess(),
    parse_word("haste") - keyword_ability.KW_Haste(),
    (parse_word("ward") & parse_symbol("—")) >> parse_cost ~ keyword_ability.KW_Ward
}

parse_object_ref.value = require"parse/oracle_parser/object"

parse_target = parse_word("target") >> parse_object ~ target.Target

parse_object_or_target = parse_target | parse_object

parse_triggered_ability_when_condition = choice {
    (parse_object << parse_word("enters")) ~ triggered_ability_when_condition.When_Enters,
    (parse_object << parse_word("attacks")) ~ triggered_ability_when_condition.When_Attacks,
    (parse_object << parse_word("dies")) ~ triggered_ability_when_condition.When_Dies,
    (parse_object << parse_words{ "leaves", "the", "battlefield" }) ~ triggered_ability_when_condition.When_Leaves,
}

parse_triggered_ability_condition = choice {
    parse_word("when") >> parse_triggered_ability_when_condition,
    parse_word("whenever") >> parse_triggered_ability_when_condition
}

parse_effect = choice {
    parse_words{"draw", "a", "card"} - effect.E_DrawCards(player.P_You(), 1),
    parse_words{"you", "gain"} >> parse_any_number << parse_word("life") ~ function(amt) return effect.E_GainLife(player.P_You(), amt) end,
    (parse_words{"put", "a"} >> parse_counter) & (parse_word("on") >> parse_object_or_target) ~ map2(effect.E_PutCounter),
    parse_word("destroy") >> parse_object_or_target ~ effect.E_Destroy,
    parse_word("exile") >> parse_object_or_target ~ effect.E_Exile,
    parse_words{"create", "a"} >> parse_object ~ effect.E_CreateToken,
    parse_word("counter") >> parse_object_or_target ~ effect.E_Counter,
    parse_word("scry") >> parse_any_number ~ function(amt) return effect.E_Scry(player.P_You(), amt) end,
    parse_word("surveil") >> parse_any_number ~ function(amt) return effect.E_Surveil(player.P_You(), amt) end,
    parse_words{"end", "the", "turn"} - effect.E_EndTurn()
}

parse_triggered_ability = (parse_triggered_ability_condition << parse_symbol(",")) & parse_effect << parse_symbol(".") ~ map2(ability.A_Triggered)

parse_activated_ability = (parse_cost << parse_symbol(":")) & parse_effect << parse_symbol(".") ~ map2(ability.A_Activated)

parse_static_ability = choice {
    parse_keyword_ability
}

parse_ability = choice {
    parse_activated_ability,
    parse_triggered_ability,
    parse_static_ability
}

parse_permanent = all(sep(parse_ability, parse_symbol("NEWLINE") | parse_symbol(",")))
parse_spell = all(sep(parse_effect << parse_symbol("."), parse_symbol("NEWLINE")))

parse_card = parse_permanent | parse_spell