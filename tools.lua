function table.reduce(tbl, fn)
    while #tbl >= 2 do
        local a = table.remove(tbl, 1)
        local b = table.remove(tbl, 1)

        table.insert(tbl, 1, fn(a, b))
    end

    return tbl[1]
end

function table.append(tbl1, tbl2)
    for _,v in pairs(tbl2) do
        table.insert(tbl1, v)
    end
end

function parse_typeline(typeline)
    --todo: implement
    return { "Legendary" }, { "Artifact", "Creature" }, { "Golem" }
end