
gui = {
    data_rows = {},
    -- and functions below
}


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


local function data_table_is_valid(player)
    return player.gui.left.prodmon and player.gui.left.prodmon.valid
        and player.gui.left.prodmon.data and player.gui.left.prodmon.data.valid
end


function gui.create(player)
    if player.gui.left.prodmon then return end

    local root = player.gui.left.add{type="frame", name="prodmon", direction="horizontal", style="outer_frame_style"}

    root.add{type="label", caption={"prodmon.short-title-text"}, style="prodmon_ident", tooltip={"prodmon.short-title-tooltip"}}
    root.add{type="flow", name="buttons", direction="vertical", style="prodmon_buttons"}
    root.add{type="table", name="data", colspan=5, style="prodmon_data_table"}

    root.buttons.add{type="button", name="prodmon_all", style="YARM_expando_long", tooltip={"prodmon.show-all-tooltip"}}
    root.buttons.add{type="button", name="prodmon_ores", style="YARM_expando_short", tooltip={"prodmon.show-ores-tooltip"}}

    gui.num_display_rows = 0
end


function gui.destroy(player)
    if player.gui.left.prodmon and player.gui.left.prodmon.valid then
        player.gui.left.prodmon.destroy()
    end
end


function gui.add_data_row(title, signal)
    local new_row = {
        title = title,
        type = signal.signal.type,
        name = signal.signal.name,
        display_name = name_that_signal(signal.signal),
        value = signal.count,
        diff_rate = signals.rate_of_change(signal.signal),
    }

    table.insert(gui.data_rows, new_row)
end


function gui.remove_data_rows(title)
    for i = #gui.data_rows,1,-1 do
        local row = gui.data_rows[i]
        if row.title == title then
            table.remove(gui.data_rows, i)
        end
    end
end


function gui.update_data_row(title, signal)
    for i, row in pairs(gui.data_rows) do
        if row.title == title and row.type == signal.signal.type and row.name == signal.signal.name then
            row.value = signal.count
            row.diff_rate = signals.rate_of_change(signal.signal)

            -- Assumption: only one data row matches the title and signal
            return true
        end
    end

    return false
end


function gui.set_data_row(title, signal)
    if not gui.update_data_row(title, signal) then
        gui.add_data_row(title, signal)
    end
end


function gui.update_display(player)
    log("Update display")
    if not data_table_is_valid(player) then return end

    log("Has a valid data table")

    if gui.num_display_rows < #gui.data_rows then
        for i = gui.num_display_rows + 1, #gui.data_rows do
            gui.add_display_row(player, i)
        end
    elseif gui.num_display_rows > #gui.data_rows then
        for i = #gui.data_rows + 1, gui.num_display_rows do
            gui.remove_display_row(player, i)
        end
    end

    for i = 1, #gui.data_rows do
        gui.update_display_row(player, i, gui.data_rows[i])
    end
end


function gui.add_display_row(player, i)
    local data_root = player.gui.left.prodmon.data

    data_root.add{type="label", name=string.format("prodmon_r%d_title", i)}
    data_root.add{type="label", name=string.format("prodmon_r%d_type", i)}
    data_root.add{type="label", name=string.format("prodmon_r%d_display_name", i)}
    data_root.add{type="label", name=string.format("prodmon_r%d_value", i)}
    data_root.add{type="label", name=string.format("prodmon_r%d_diff_rate", i)}

    gui.num_display_rows = gui.num_display_rows + 1
end


function gui.remove_display_row(player, i)
    local data_root = player.gui.left.prodmon.data

    data_root[string.format("prodmon_r%d_title", i)].destroy()
    data_root[string.format("prodmon_r%d_type", i)].destroy()
    data_root[string.format("prodmon_r%d_display_name", i)].destroy()
    data_root[string.format("prodmon_r%d_value", i)].destroy()
    data_root[string.format("prodmon_r%d_diff_rate", i)].destroy()

    gui.num_display_rows = gui.num_display_rows - 1
end


function gui.update_display_row(player, i, data_row)
    local data_root = player.gui.left.prodmon.data

    data_root[string.format("prodmon_r%d_title", i)].caption = data_row.title
    data_root[string.format("prodmon_r%d_type", i)].caption = data_row.type
    data_root[string.format("prodmon_r%d_display_name", i)].caption = data_row.display_name
    data_root[string.format("prodmon_r%d_value", i)].caption = data_row.value
    data_root[string.format("prodmon_r%d_diff_rate", i)].caption = data_row.diff_rate
end


function gui.on_click(e)
end
