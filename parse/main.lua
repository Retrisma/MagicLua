require("lldebugger").start()

require"parse/tools"
require"parse/tokenizer"
require"parse/parser_library"
require"parse/oracle_parser_helper"
require"parse/oracle_parser"
local json = require"lib/json"
local lfs = require"lfs"

node_titles = calc_node_titles()

function test_all(fun)
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

            fun(filename, data)
        end
    end

    print"ok"
end

function test_single(cardname, fun)
    local filename = cardname .. ".txt"
    local file = io.open("fdn/" .. filename, "r")

    local data

    if file then
        data = file:read("a")
        data = json.decode(data).text
        file:close()
    end

    fun(filename .. ".txt", data)
end

function test_parser(card)
    local file = io.open("fdn/" .. card .. ".txt")
    local data
    if file then
        data = file:read("a")
        data = json.decode(data).text
        file:close()
    end

    parse_with(parse_card, data)
end

function parse_with(parser, string)
    local stream = tokenize(string)

    local o = parser % table.reverse(stream)

    if o.status == "success" then
        print_tree(o.head)
        print()
    else
        print("fail")
        print(o.reason)
    end
end

function test(card, data)
    local stream = tokenize(data)
    
    local o = parse_card % table.reverse(stream)

    if o.status == "success" and #o.tail == 0 then
        print(string.sub(card, 1, -5))
        print_tree(o.head)
        print()
    else
        --print("fail")
    end
end

test_all(test)