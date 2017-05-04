
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
            global.active_combinator = nil
        end

        local player = game.players[e.player_index]
        log(string.format("%s mined a test combi!", player.name))
    end
end


local function name_that_signal(signal)
    local proto = { localised_name = string.format("Error: unknown signal type '%s'", signal.type) }

    if signal.type == "item" then
        proto = game.item_prototypes[signal.name]
    elseif signal.type == "fluid" then
        proto = game.fluid_prototypes[signal.name]
    elseif signal.type == "virtual" then
        proto = game.virtual_signal_prototypes[signal.name]
    end

    return proto.localised_name
end


local function update_data(player)
    local root = player.gui.left.prodmon
    if not root then return end

    if root.data and root.data.valid then root.data.destroy() end

    local data = root.add{type="table", name="data", colspan=4, style="YARM_site_table"}

    if not global.active_combinator then return end

    local red_network = global.active_combinator.get_circuit_network(defines.wire_type.red)
    local green_network = global.active_combinator.get_circuit_network(defines.wire_type.green)

    if red_network and red_network.signals then
        for _, s in pairs(red_network.signals) do
            data.add{type="label", caption="red"}
            data.add{type="label", caption=s.signal.type}
            data.add{type="label", caption=name_that_signal(s.signal)}
            data.add{type="label", caption=s.count}
        end
    end
    if green_network and green_network.signals then
        for _, s in pairs(green_network.signals) do
            data.add{type="label", caption="green"}
            data.add{type="label", caption=s.signal.type}
            data.add{type="label", caption=name_that_signal(s.signal)}
            data.add{type="label", caption=s.count}
        end
    end
end


function events.on_tick(e)
    if e.tick % 20 ~= 11 then return end

    for _, player in pairs(game.players) do
        update_data(player)
    end
end


function events.on_gui_click(e)
    local player = game.players[e.player_index]

    if not player.gui.left.prodmon then
        local root = player.gui.left.add{type="frame", name="prodmon", direction="horizontal", style="outer_frame_style"}

        root.add{type="label", caption="PM"}

        local buttons = root.add{type="flow",
                            name="buttons",
                            direction="vertical",
                            style="YARM_buttons"}

        buttons.add{type="button", name="prodmon_all", style="YARM_expando_long", tooltip="Show all signals"}
        buttons.add{type="button", name="prodmon_ores", style="YARM_expando_short", tooltip="Show ores"}
    end

    update_data(player)
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
