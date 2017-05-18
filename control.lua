require("combinators")
require("signals")
require("gui")
require("remote")

local events = {}

local function on_entity_built(e)
    if e.created_entity.name == "test-combinator" then
        local success, name = combinators.add(e.created_entity)
        log(string.format("Remembering combinator named %s", name))

        if e.player_index then
            local player = game.players[e.player_index]
            gui.rename_monitor(player, name)
        end
    end
end
events.on_built_entity = on_entity_built
events.on_robot_built_entity = on_entity_built


local function on_entity_remove(e)
    log(string.format("Event %s", e.name))
    if e.entity.name ~= "test-combinator" then return end

    local success, name = combinators.name_entity(e.entity)
    log(string.format("Got the name \"%s\"", name))
    if not name then return end

    local red_network = e.entity.get_circuit_network(defines.wire_type.red)

    if red_network then
        log("had a red network")
    else
        log("didn't have a red network")
    end

    gui.remove_data_rows("red")
    gui.remove_data_rows("green")
    combinators.remove_by_name(name)
end
events.on_preplayer_mined_item = on_entity_remove
events.on_entity_died = on_entity_remove
events.on_robot_pre_mined = on_entity_remove


local function merged_signals_from(entity)
    local red_network = entity.get_circuit_network(defines.wire_type.red)
    local green_network = entity.get_circuit_network(defines.wire_type.green)

    local merged = {}
    if red_network and red_network.signals then
        for _, s in pairs(red_network.signals) do
            if not merged[s.signal.type] then merged[s.signal.type] = {} end

            local old_val = merged[s.signal.type][s.signal.name] or 0
            merged[s.signal.type][s.signal.name] = old_val +  s.count
        end
    end
    if green_network and green_network.signals then
        for _, s in pairs(green_network.signals) do
            if not merged[s.signal.type] then merged[s.signal.type] = {} end

            local old_val = merged[s.signal.type][s.signal.name] or 0
            merged[s.signal.type][s.signal.name] = old_val +  s.count
        end
    end

    local merged_signals = {}
    for type, sig in pairs(merged) do
        for name, count in pairs(sig) do
            local new_sig = {
                signal = { type = type, name = name },
                count = count
            }
            table.insert(merged_signals, new_sig)
        end
    end

    return pairs(merged_signals)
end


local function update_signals(tick)
    log("Update signals")

    for name, combi in combinators.each() do
        gui.remove_data_rows(name)
        for _, s in merged_signals_from(combi) do
            signals.add_sample(tick, s)
            gui.set_data_row(name, s)
        end
    end
end


function events.on_tick(e)
    if e.tick % 300 == 11 then
        update_signals(e.tick)
    end

    if e.tick % 120 == 11 then
        for _, player in pairs(game.players) do
            gui.update_display(player)
        end
    end
end


function events.on_gui_click(e)
    gui.on_click(e)
end


function events.on_player_joined_game(e)
    local player = game.players[e.player_index]

    gui.create(player)
    gui.update_display(player)
end


script.on_init(function()
    combinators.on_init()
    gui.on_init()

    for _, player in pairs(game.players) do
        gui.create(player)
        gui.update_display(player)
    end
end)


for name, func in pairs(events) do
    if not defines.events[name] then
        log(string.format("test-mod: ignoring handler for non-existent event %s", name))
    else
        script.on_event(defines.events[name], function(e)
            local success, err = pcall(func, e)

            if not success then
                log(string.format("Event %s failed with error %s!", name, err))
            end
        end)
    end
end
