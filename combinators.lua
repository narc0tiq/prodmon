
combinators = {}


function combinators.on_init()
    global.combinators = { by_name = {} }
end


function combinators.add(entity)
    local temp_name = string.format("Monitor @%d,%d", entity.position.x, entity.position.y)
    if global.combinators.by_name[temp_name] then return false, string.format("Combinator named \"%s\" already exists!", temp_name) end

    global.combinators.by_name[temp_name] = entity
    return true, temp_name
end


function combinators.rename(old_name, new_name)
    if not global.combinators.by_name[old_name] then return false, string.format("Combinator named \"%s\" does not exist!", old_name) end
    if global.combinators.by_name[new_name] then return false, string.format("Combinator named \"%s\" already exists!", new_name) end

    global.combinators.by_name[new_name] = global.combinators.by_name[old_name]
    global.combinators.by_name[old_name] = nil

    return true
end


function combinators.name_entity(entity)
    for name, possible in pairs(global.combinators.by_name) do
        if possible == entity then return true, name end
    end

    return false, "Entity not registered."
end


function combinators.remove_by_name(name)
    if not global.combinators.by_name[name] then return false, string.format("Combinator named \"%s\" does not exist!", name) end

    global.combinators.by_name[name] = nil
    return true
end


function combinators.remove_entity(entity)
    local name = combinators.name_entity(entity)
    if not name then return false, string.format("Combinator at %d, %d does not have a name!", entity.position.x, entity.position.y) end

    return combinators.remove_by_name(name)
end


function combinators.each()
    return pairs(global.combinators.by_name)
end
