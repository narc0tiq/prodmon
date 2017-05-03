
require("evogui")

local events = {}
local sensor_name = "test-mod-test-sensor"

function events.on_built_entity(e)
    if e.created_entity.name == "test-combinator" then
        local player = game.players[e.player_index]

        if evogui.has_sensor(sensor_name) then
            evogui.update(sensor_name, string.format("%s put a test combi!", player.name))
        end

        global.active_combinator = e.created_entity
    end
end


function events.on_player_mined_entity(e)
    if e.entity.name == "test-combinator" then
        if e.entity == global.active_combinator then
            global.active_combinator = nil
        end

        local player = game.players[e.player_index]

        if evogui.has_sensor(sensor_name) then
            evogui.update(sensor_name, string.format("%s mined a test combi!", player.name))
        end
    end
end


local function name_it(signal)
    if signal.type == "virtual" then
        return {string.format("virtual-signal-name.%s", signal.name)}
    end

    return {string.format("%s-name.%s", signal.type, signal.name)}
end


function events.on_tick(e)
    if e.tick % 20 ~= 0 then return end

    if not global.active_combinator or not evogui.has_sensor(sensor_name) then return end

    local red_network = global.active_combinator.get_circuit_network(defines.wire_type.red)
    local green_network = global.active_combinator.get_circuit_network(defines.wire_type.green)

    local accumulator = {""}
    if red_network and red_network.signals then
        for _, s in pairs(red_network.signals) do
            table.insert(accumulator, "red, ")
            table.insert(accumulator, s.signal.type)
            table.insert(accumulator, ", ")
            table.insert(accumulator, name_it(s.signal))
            table.insert(accumulator, string.format(": %d", s.count))
            table.insert(accumulator, " |and| ")
        end
    end
    if green_network and green_network.signals then
        for _, s in pairs(green_network.signals) do
            table.insert(accumulator, "green, ")
            table.insert(accumulator, s.signal.type)
            table.insert(accumulator, ", ")
            table.insert(accumulator, name_it(s.signal))
            table.insert(accumulator, string.format(": %d", s.count))
        end
    end

    evogui.update(sensor_name, accumulator)
end


for name, func in pairs(events) do
    if not defines.events[name] then
        log(string.Format("test-mod: ignoring handler for non-existent event %s", name))
    else
        script.on_event(defines.events[name], func)
    end
end

evogui.register(sensor_name, "Initial text!", "Settings text!")
