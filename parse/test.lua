-- test_parser.lua
require"parse/tools"
require"parse/tokenizer"
require"parse/parser_library"
require"parse/oracle_parser"

node_titles = calc_node_titles()

function parse_with(parser, string)
    local stream = tokenize(string)
    local o = parser % table.reverse(stream)

    if o.status == "success" then
        return { status = "success", result = o.head, remaining = o.tail }
    else
        return { status = "failure", reason = o.reason }
    end
end

