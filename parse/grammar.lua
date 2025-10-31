local function name0(name)
    return function() return { name } end
end

option = {
    Some = function(val) return { "Some", val } end,
    None = function() return { "None" } end
}

logic = {
    Or = function(op1, op2) return { "Or", op1, op2 } end,
    And = function(op1, op2) return { "And", op1, op2 } end,
    OrList = function(list) return { "OrList", list } end,
    AndList = function(list) return { "AndList", list } end,
}

mana_symbol = {
    MS_Mana = function(mana) return { "Mana", mana } end,
}

pt_modifier = {
    PT_Mod = function(sign1, power, sign2, toughness)
        --TODO: horrible calc_node_titles side effect
        if not sign1 then return { "PTModifier" } end

        return { "PTModifier", sign1 .. power .. "/" .. sign2 .. toughness }
    end,
    PT_Def = function(power, toughness)
        if not power then return { "PTDefinition" } end

        return { "PTDefinition", power .. "/" .. toughness }
    end
}

counter = {
    Cntr_Named = function(counter) return { "NamedCounter", counter } end,
    Cntr_PT = function(mod) return { "PTCounter", mod } end
}

card_type = {
    T_Creature = function() return { "Creature" } end,
    T_Land = function() return { "Land" } end,
    T_Artifact = function() return { "Artifact" } end,
    T_Enchantment = function() return { "Enchantment" } end,
    T_Planeswalker = function() return { "Planeswalker" } end,
    T_Sorcery = function() return { "Sorcery" } end,
    T_Instant = function() return { "Instant" } end,
}

triggered_ability_condition_lhs = {
    TA_Whenever = function(cond) return { "Whenever", cond } end,
    TA_When = function(cond) return { "When", cond } end,
    TA_At = function(cond) return { "At", cond } end
}

triggered_ability_when_condition = {
    When_Enters = function(object) return { "WhenEnters", object } end,
    When_Dies = function(object) return { "WhenDies", object } end,
    When_Leaves = function(object) return { "WhenLeaves", object } end,
    When_Cast = function(object) return { "WhenCast", object } end,
    When_Attacks = function(object) return { "WhenAttacks", object } end,
}

object = {
    O_Base = function() return { "BaseObject" } end,
    O_It = function() return { "It" } end,
    O_WithQual = function(obj, qual) return { "ObjectThat", obj, qual } end,
    O_Qualified = function(quals) return { "QualifiedObject", quals } end
}

target = {
    Target = function(obj) return { "Target", obj } end
}

player = {
    P_You = function() return { "You" } end,
    P_Opponent = function() return { "Opponent" } end
}

qualification = {
    Is_ControlledBy = function(player) return { "ControlledBy", player } end,
    Is_This = function() return { "This" } end,
    Is_NotThis = function() return { "NotThis" } end,
    Is_Token = function() return { "IsToken" } end,
    Is_NotToken = function() return { "IsNontoken" } end,
    Is_IsType = function(type) return { "IsType", type } end,
    Is_IsColor = function(color) return { "IsColor", color } end,
    Is_HasKeyword = function(kw) return { "HasKeyword", kw } end,
    Is_PowerToughness = function(pt) return { "HasPowerToughness", pt } end,
}

keyword_ability = {
    KW_Flying = name0("Flying"),
    KW_Lifelink = name0("Lifelink"),
    KW_Trample = name0("Trample"),
    KW_Vigilance = name0("Vigilance"),
    KW_Reach = name0("Reach"),
    KW_Menace = name0("Menace"),
    KW_FirstStrike = name0("First Strike"),
    KW_DoubleStrike = name0("Double Strike"),
    KW_Flash = name0("Flash"),
    KW_Ward = function(cost) return { "Ward", cost } end,
}

ability = {
    A_Triggered = function(cond, effect) return { "TriggeredAbility", cond, effect} end,
    A_Static = function(full) return { "StaticAbility", full } end,
    A_Keyword = function(kw) return { "KeywordAbility", kw } end,
}

effect = {
    E_DrawCards = function(player, amount) return { "DrawCards", player, amount } end,
    E_GainLife = function(player, amount) return { "GainLife", player, amount } end,
    E_PutCounter = function(counter, object) return { "PutCounterOn", counter, object } end,
    E_CreateToken = function(quals) return { "CreateToken", quals } end,
    E_Destroy = function(obj) return { "Destroy", obj } end,
}

cost = {
    Pay_Life = function(amount) return { "PayLife", amount } end,
    Pay_Mana = function(cost) return { "PayMana", cost } end,
    Pay_Tap = name0("PayTap")
}

grammar_levels = {
    option,
    logic,
    mana_symbol,
    pt_modifier,
    counter,
    card_type,
    triggered_ability_condition_lhs,
    triggered_ability_when_condition,
    object,
    target,
    player,
    qualification,
    keyword_ability,
    ability,
    effect,
    cost,
}