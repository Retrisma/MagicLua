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

comparison = {
    Comp_OrGreater = function(num) return { "OrGreater", num } end,
    Comp_OrLess = function(num) return { "OrLess", num } end,
    Comp_EqualTo = function(num) return { "EqualTo", num } end,
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
    O_It = function() return { "It" } end,
    O_This = function() return { "This" } end,
    O_Qualified = function(quals) return { "ObjectThat", quals } end
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
    Is_NotThis = function() return { "NotThis" } end,
    Is_Token = function() return { "IsToken" } end,
    Is_NotToken = function() return { "IsNontoken" } end,
    Is_Spell = function() return { "IsSpell" } end,
    Is_IsType = function(type) return { "IsType", type } end,
    Is_IsColor = function(color) return { "IsColor", color } end,
    Is_HasKeyword = function(kw) return { "HasKeyword", kw } end,
    Is_PowerToughness = function(pt) return { "HasPowerToughness", pt } end,
    Is_Power = function(power) return { "HasPower", power } end,
    Is_Toughness = function(toughness) return { "HasToughness", toughness } end,
    Is_Attacking = function() return { "IsAttacking" } end,
    Is_Blocking = function() return { "IsBlocking" } end,
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
    KW_Deathtouch = name0("Deathtouch"),
    KW_Haste = name0("Haste"),
    KW_Prowess = name0("Prowess"),
    KW_Ward = function(cost) return { "Ward", cost } end,
}

ability = {
    A_Triggered = function(cond, effect) return { "TriggeredAbility", cond, effect} end,
    A_Activated = function(cost, effect) return { "ActivatedAbility", cost, effect } end,
    A_Static = function(full) return { "StaticAbility", full } end,
    A_Keyword = function(kw) return { "KeywordAbility", kw } end,
}

effect = {
    E_DrawCards = function(player, amount) return { "DrawCards", player, amount } end,
    E_GainLife = function(player, amount) return { "GainLife", player, amount } end,
    E_PutCounter = function(counter, object) return { "PutCounterOn", counter, object } end,
    E_CreateToken = function(quals) return { "CreateToken", quals } end,
    E_Destroy = function(obj) return { "Destroy", obj } end,
    E_Exile = function(obj) return { "Exile", obj } end,
    E_Counter = function(obj) return { "Counter", obj } end,
    E_Scry = function(player, amount) return { "Scry", player, amount } end,
    E_Surveil = function(player, amount) return { "Surveil", player, amount } end,
    E_EndTurn = function() return { "EndTheTurn" } end,
}

--effects to-do list:
--"OBJECT gets +N/+N until end of turn."
--"CARDNAME deals 3 damage to any target."
--"Add {B}{B}{B}."
--"Create a Food token."
--"Return OBJECT to its owner's hand."

cost = {
    Pay_Life = function(amount) return { "PayLife", amount } end,
    Pay_Mana = function(cost) return { "PayMana", cost } end,
    Pay_Tap = name0("PayTap"),
    Pay_Sacrifice = function(obj) return { "PaySacrifice", obj } end,
}

grammar_levels = {
    option,
    logic,
    mana_symbol,
    pt_modifier,
    comparison,
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