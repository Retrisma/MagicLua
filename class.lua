--instantiate a class's metatable
function class(members)
    members = members or {}
    local mt = {
        __metatable = members,
        __index = members
    }

    return mt
end

--simple inheritance method
function inherits(baseclass, members)
    local newclass = members or {}

    if baseclass then
        setmetatable( newclass, { __index = baseclass } )
    end

    return newclass
end