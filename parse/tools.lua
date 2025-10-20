function table.has(tbl, val)
    for _,v in ipairs(tbl) do
        if v == val then return true end
    end
    return false
end

function table.reverse(tbl)
    local out = {}
    while #tbl > 0 do
        table.insert(out, table.pop(tbl))
    end
    return out
end

function table.pop(tbl)
    return table.remove(tbl, #tbl)
end

function table.peek(tbl)
    return tbl[#tbl]
end

function table.reduce(tbl, fn)
    while #tbl >= 2 do
        local a = table.remove(tbl, 1)
        local b = table.remove(tbl, 1)

        table.insert(tbl, 1, fn(a, b))
    end

    return tbl[1]
end

function map2(f)
    return function(tbl)
        return f(tbl[1], tbl[2])
    end
end

function map3(f)
    return function(tbl)
        return f(tbl[1][1], tbl[1][2], tbl[2])
    end
end

function map4(f)
    return function(tbl)
        return f(tbl[1][1][1], tbl[1][1][2], tbl[1][2], tbl[2])
    end
end

function table.map(tbl, fn)
    for k,v in pairs(tbl) do
        tbl[k] = fn(v)
    end

    return tbl
end

function print_node(node)
    io.write(node[1].."(")

    for i=2, #node do
        print_tree(node[i])

        if i ~= #node then
            io.write(", ")
        end
    end

    io.write(")")
end

function calc_node_titles()
    local out = {}

    for _,v in pairs(grammar_levels) do
        for _, node in pairs(v) do
            table.insert(out, node() and node()[1] or nil)
        end
    end

    return out
end

function print_tree(tree)
    local function iter(tree)
        if type(tree) == "table" then
            if table.has(node_titles, tree[1]) then
                print_node(tree)
            else
                print_list(tree)
            end
        else
            io.write(tree)
        end
    end
    
    function print_node(node)
        for i,v in ipairs(node) do
            if i == 1 then io.write(v, "(")
            elseif i == 2 then iter(v)
            else io.write(",") iter(v) end
        end
        io.write(")")
    end

    function print_list(list)
        io.write("{")
        for i,v in ipairs(list) do
            if i > 1 then io.write(";") end
            iter(v)
        end
        io.write("}")
    end

    iter(tree)
end