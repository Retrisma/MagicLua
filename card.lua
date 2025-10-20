local scryfall = require"scryfall"

Object = {}
local object_mt = class(Object)

function Object:new(characteristics)
    local o = {
        name = characteristics.name or nil,
        mana_cost = characteristics.mana_cost or nil,
        color_indicator = characteristics.color_indicator or nil,
        card_types = characteristics.card_types or nil,
        subtypes = characteristics.subtypes or nil,
        supertypes = characteristics.supertypes or nil,
        rules_text = characteristics.rules_text or nil,
        abilities = characteristics.abilities or nil,
        power = characteristics.power or nil,
        toughness = characteristics.toughness or nil,
        loyalty = characteristics.loyalty or nil,
        defense = characteristics.defense or nil,
        -- TODO: hand_modifier, life_modifier
    }

    return setmetatable(o, object_mt)
end

function Object:of_card_name(name)
    --todo: handle DFCs
    local details = scryfall.get_card(name)

    --todo: implement
    local card_types, subtypes, supertypes = parse_typeline(details.typeline)

    return Object:new{
        name = details.name,
        mana_cost = details.mana_cost, --todo: parse
        color_indicator = details.color_indicator or nil,
        card_types = card_types,
        subtypes = subtypes,
        supertypes = supertypes,
        rules_text = details.oracle_text,
        abilities = {}, -- todo: i think abilities should always be empty here?
        power = details.power or nil,
        toughness = details.toughness or nil,
        loyalty = details.loyalty or nil,
        defense = details.defense or nil
    }
end

Card = {}
local card_mt = class(Card)

function Card:new(object)
    local o = {
        object = object
    }

    return setmetatable(o, card_mt)
end

function Card:of_card_name(name)
    return Card:new(Object:of_card_name(name))
end