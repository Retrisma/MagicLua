require("lldebugger").start()

require"parse/tools"
require"parse/tokenizer"
require"parse/parser_library"
require"parse/oracle_parser"
local json = require"lib/json"
local lfs = require"lfs"

node_titles = calc_node_titles()

function test_tokenizer()
    local path = "./fdn"
    for filename in lfs.dir(path) do
        if filename ~= "." and filename ~= ".." then
            local file = io.open("fdn/" .. filename, "r")

            local data

            if file then
                data = file:read("a")
                data = json.decode(data).text
                file:close()
            end

            local stream = tokenize(data)
        end
    end

    print"ok"
end

function test_parser()
    local cards = { "Sire of Seven Deaths", "Helpful Hunter" }

    for _,card in pairs(cards) do
        local file = io.open("fdn/" .. card .. ".txt")
        local data
        if file then
            data = file:read("a")
            data = json.decode(data).text
            file:close()
        end

        local stream = tokenize(data)
        
        local o = parse_card % table.reverse(stream)

        if o.status == "success" then
            print(card)

            print_tree(o.head)
            print()
        end
    end
end

test_parser()