require("lldebugger").start()

require"class"
require"tools"
require"card"
local json = require"lib/json"

function make_test(card)
    local file = io.open("./fdn/"..card.name..".txt", "w")

    local o = {
        name = card.name,
        type = card.type_line,
        text = card.oracle_text
    }

    if file then
        file:write(json.encode(o))
        file:close()
    end
end

local scryfall = require"scryfall"

local o = scryfall.search("set:fdn unique:cards")

for _,v in ipairs(o) do
    make_test(v)
end

print"ok"