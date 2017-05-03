
evogui = {}

function evogui.register(sensor_name, initial_text, settings_caption)
    remote.call("EvoGUI", "create_remote_sensor",
    {
        mod_name = "test-mod",
        name = sensor_name,
        text = initial_text,
        caption = settings_caption,
    })
end

function evogui.update(sensor_name, new_text)
    remote.call("EvoGUI", "update_remote_sensor", sensor_name, new_text)
end

function evogui.has_sensor(sensor_name)
    return remote.call("EvoGUI", "has_remote_sensor", sensor_name)
end

function evogui.unregister(sensor_name)
    return remote.call("EvoGUI", "remove_remote_sensor", sensor_name)
end


