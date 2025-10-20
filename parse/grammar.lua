option = {
    Some = function(val) return { "Some", val } end,
    None = function() return { "None" } end
}

mana_symbol = {
    MS_Mana = function(mana) return { "Mana", mana } end,
}

counter = {
    Counter = function(counter) return { "Counter", counter } end,
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
    WhenEnters = function(object) return { "WhenEnters", object } end,
    WhenDies = function(object) return { "WhenDies", object } end,
    WhenLeaves = function(object) return { "WhenLeaves", object } end,
    WhenCast = function(object) return { "WhenCast", object } end,
    WhenAttacks = function(object) return { "WhenAttacks", object } end,
}

object = {
    O_This = function() return { "ThisObject" } end,
    O_WithQuals = function(quals) return { "ObjectThat", quals } end
}

player = {
    P_You = function() return { "You" } end,
    P_Opponent = function() return { "Opponent" } end
}

qualification = {
    Q_ControlledBy = function(player) return { "ControlledBy", player } end,
    Q_NotThis = function() return { "NotThis" } end,
    Q_IsType = function(type) return { "IsType", type } end,
}

ability = {
    A_Triggered = function(cond, i_if, effect) return { "TriggeredAbility", cond, i_if, effect} end,
    A_Static = function(full) return { "StaticAbility", full } end,
    A_Keyword = function(kw) return { "KeywordAbility", kw } end,
    A_Ward = function(cost) return { "Ward", cost } end,
}

effect = {
    E_DrawCard = function() return { "DrawACard" } end
}

cost = {
    C_PayLife = function(amount) return { "PayLife", amount } end,
    C_PayMana = function(cost) return { "PayMana", cost } end
}

grammar_levels = {
    option,
    mana_symbol,
    counter,
    card_type,
    triggered_ability_condition_lhs,
    triggered_ability_when_condition,
    object,
    player,
    qualification,
    ability,
    effect,
    cost,
}