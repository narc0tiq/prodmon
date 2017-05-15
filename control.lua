require("signals")
require("gui")

local events = {}

function events.on_built_entity(e)
    if e.created_entity.name == "test-combinator" then
        local player = game.players[e.player_index]
        log(string.format("%s put a test combi!", player.name))
        global.active_combinator = e.created_entity
    end
end


function events.on_player_mined_entity(e)
    if e.entity.name == "test-combinator" then

        if e.entity == global.active_combinator then
            gui.remove_data_rows("red")
            gui.remove_data_rows("green")
            global.active_combinator = nil
        end

        local player = game.players[e.player_index]
        log(string.format("%s mined a test combi!", player.name))
    end
end


local function update_signals(tick)
    log("Update signals")
    if not global.active_combinator then return end

    log("Have active combi")

    local red_network = global.active_combinator.get_circuit_network(defines.wire_type.red)
    local green_network = global.active_combinator.get_circuit_network(defines.wire_type.green)

    gui.remove_data_rows("red")
    log("remove reds")
    gui.remove_data_rows("green")
    log("remove greens")

    if red_network and red_network.signals then
        log("have red network")
        for _, s in pairs(red_network.signals) do
            signals.add_sample(tick, s)
            gui.set_data_row("red", s)
            log("add red "..s.signal.name)
        end
    end
    if green_network and green_network.signals then
        log("have green network")
        for _, s in pairs(green_network.signals) do
            signals.add_sample(tick, s)
            gui.set_data_row("green", s)
            log("add green "..s.signal.name)
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
    local player = game.players[e.player_index]

    gui.create(player)
    gui.update_display(player)
end


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
