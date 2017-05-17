
combinators = {
    by_name = {}
}


function combinators.add(entity)
    local temp_name = string.format("Monitor @%d,%d", entity.position.x, entity.position.y)
    if combinators.by_name[temp_name] then error(string.format("Combinator named \"%s\" already exists!", temp_name)) end

    combinators.by_name[temp_name] = entity
    return temp_name
end


function combinators.rename(old_name, new_name)
    if not combinators.by_name[old_name] then error(string.format("Combinator named \"%s\" does not exist!", old_name)) end
    if combinators.by_name[new_name] then error(string.format("Combinator named \"%s\" already exists!", new_name)) end

    combinators.by_name[new_name] = combinators.by_name[old_name]
    combinators.by_name[old_name] = nil
end


function combinators.name_entity(entity)
    for name, possible in pairs(combinators.by_name) do
        if possible == entity then return name end
    end
end


function combinators.remove_by_name(name)
    if not combinators.by_name[name] then error(string.format("Combinator named \"%s\" does not exist!", name)) end

    combinators.by_name[name] = nil
end


function combinators.remove_entity(entity)
    local name = combinators.name_entity(entity)
    if not name then error(string.format("Combinator at %d, %d does not have a name!", entity.position.x, entity.position.y)) end

    combinators.remove_by_name(name)
end
