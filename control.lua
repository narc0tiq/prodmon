
local events = {}

function events.on_built_entity(e)
    if e.created_entity.name == "test-combinator" then
        game.players[e.player_index].print("It's a test combinator!")
    end
end


for name, func in pairs(events) do
    if not defines.events[name] then
        log(string.Format("test-mod: ignoring handler for non-existent event %s", name))
    else
        script.on_event(defines.events[name], func)
    end
end
