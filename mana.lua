---CR 105.1
---There are five colors in the Magic game: white, blue, black, red, and green.
color = {
    WHITE = { name = "white", symbol = "W" },
    BLUE = { name = "blue", symbol = "U" },
    BLACK = { name = "black", symbol = "B" },
    RED = { name = "red", symbol = "R" },
    GREEN = { name = "green", symbol = "G" }
}

---CR 106.1
---Mana is the primary resource in the game. Players spend mana to pay costs, usually when
---casting spells and activating abilities.
Mana = {}
local mana_mt = class(Mana)

function Mana:init(type)
