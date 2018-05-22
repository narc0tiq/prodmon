
gui = {
    data_rows = {},
    -- and functions below
}


function gui.on_init()
    global.gui = {}
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


local function data_table_is_valid(player)
    return player.gui.left.prodmon and player.gui.left.prodmon.valid
        and player.gui.left.prodmon.data and player.gui.left.prodmon.data.valid
end


function gui.create(player)
    if player.gui.left.prodmon then return end

    local root = player.gui.left.add{type="frame", name="prodmon", direction="horizontal", style="outer_frame"}

    root.add{type="label", caption={"prodmon.short-title-text"}, style="prodmon_ident", tooltip={"prodmon.short-title-tooltip"}}
    root.add{type="flow", name="buttons", direction="vertical", style="prodmon_buttons"}
    root.add{type="table", name="data", column_count=7, style="prodmon_data_table"}

    root.buttons.add{type="button", name="prodmon_all", style="YARM_expando_long", tooltip={"prodmon.show-all-tooltip"}}
    root.buttons.add{type="button", name="prodmon_ores", style="YARM_expando_short", tooltip={"prodmon.show-ores-tooltip"}}

    global.gui.num_display_rows = 0
end


function gui.destroy(player)
    if player.gui.left.prodmon and player.gui.left.prodmon.valid then
        player.gui.left.prodmon.destroy()
    end
end


function gui.add_data_row(signal)
    local new_row = {
        title = signal.title,
        type = signal.signal.type,
        name = signal.signal.name,
        display_name = name_that_signal(signal.signal),
        value = signal.count,
        percent = signals.percent_remaining(signal),
        diff_rate = signals.rate_of_change(signal),
        to_depletion = signals.estimate_to_depletion(signal),
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


function gui.update_data_row(signal)
    for i, row in pairs(gui.data_rows) do
        if row.title == signal.title and row.type == signal.signal.type and row.name == signal.signal.name then
            row.value = signal.count
            row.percent = signals.percent_remaining(signal)
            row.diff_rate = signals.rate_of_change(signal)
            row.to_depletion = signals.estimate_to_depletion(signal)

            -- Assumption: only one data row matches the title and signal
            return true
        end
    end

    return false
end


function gui.set_data_row(signal)
    if not signal.title then return end

    if not gui.update_data_row(signal) then
        gui.add_data_row(signal)
    end
end


local function sort_data_rows(left, right)
    if left.percent < right.percent then return true
    elseif left.percent > right.percent then return false end

    if left.value < right.value then return true
    elseif left.value > right.value then return false end

    if left.title < right.title then return true
    elseif left.title > right.title then return false end

    if left.name < right.name then return true
    elseif left.name > right.name then return false end

    return false
end


function gui.update_display(player)
    if not data_table_is_valid(player) then return end
    if not global.gui.num_display_rows then global.gui.num_display_rows = 0 end

    if global.gui.num_display_rows < #gui.data_rows then
        for i = global.gui.num_display_rows + 1, #gui.data_rows do
            gui.add_display_row(player, i)
        end
    elseif global.gui.num_display_rows > #gui.data_rows then
        for i = #gui.data_rows + 1, global.gui.num_display_rows do
            gui.remove_display_row(player, i)
        end
    end

    table.sort(gui.data_rows, sort_data_rows)

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
    data_root.add{type="label", name=string.format("prodmon_r%d_percent", i)}
    data_root.add{type="label", name=string.format("prodmon_r%d_diff_rate", i)}
    data_root.add{type="label", name=string.format("prodmon_r%d_to_depletion", i)}

    global.gui.num_display_rows = global.gui.num_display_rows + 1
end


function gui.remove_display_row(player, i)
    local data_root = player.gui.left.prodmon.data

    data_root[string.format("prodmon_r%d_title", i)].destroy()
    data_root[string.format("prodmon_r%d_type", i)].destroy()
    data_root[string.format("prodmon_r%d_display_name", i)].destroy()
    data_root[string.format("prodmon_r%d_value", i)].destroy()
    data_root[string.format("prodmon_r%d_percent", i)].destroy()
    data_root[string.format("prodmon_r%d_diff_rate", i)].destroy()
    data_root[string.format("prodmon_r%d_to_depletion", i)].destroy()

    global.gui.num_display_rows = global.gui.num_display_rows - 1
end


local function format_number(n) -- credit http://richard.warburton.it
    local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
    return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end


local function color_from_percent(percent)
    local color = {
        r=math.floor(10 * 255 / percent),
        g=math.floor(percent * 255 / 10),
        b=0
    }
    if color.r > 255 then color.r = 255
    elseif color.r < 2 then color.r = 2 end

    if color.g > 255 then color.g = 255
    elseif color.g < 2 then color.g = 2 end

    return color
end


function gui.update_display_row(player, i, data_row)
    local data_root = player.gui.left.prodmon.data
    local color = color_from_percent(data_row.percent)

    local cell = data_root[string.format("prodmon_r%d_title", i)]
    cell.caption = data_row.title
    cell.style.font_color = color

    cell = data_root[string.format("prodmon_r%d_type", i)]
    cell.caption = data_row.type
    cell.style.font_color = color

    cell = data_root[string.format("prodmon_r%d_display_name", i)]
    cell.caption = data_row.display_name
    cell.style.font_color = color

    cell = data_root[string.format("prodmon_r%d_value", i)]
    cell.caption = format_number(data_row.value)
    cell.style.font_color = color

    cell = data_root[string.format("prodmon_r%d_percent", i)]
    cell.caption = string.format("%.1f %%", data_row.percent)
    cell.style.font_color = color

    cell = data_root[string.format("prodmon_r%d_diff_rate", i)]
    cell.caption = data_row.diff_rate
    cell.style.font_color = color

    cell = data_root[string.format("prodmon_r%d_to_depletion", i)]
    cell.caption = data_row.to_depletion
    cell.style.font_color = color
end


function string.starts_with(haystack, needle)
    return string.sub(haystack, 1, string.len(needle)) == needle
end


function string.ends_with(haystack, needle)
    return string.sub(haystack, -string.len(needle)) == needle
end


function gui.rename_monitor(player, old_name)
    local rename_root = player.gui.center.add{ type="frame", direction="vertical", name="prodmon_rename_"..old_name }
    rename_root.add{ type="label", caption=string.format("Rename the monitor \"%s\" to:", old_name) }
    rename_root.add{ type="textfield", name="new_name", text=old_name }
    rename_root.add{ type="label", name="message", caption=string.format("Press OK to submit or Cancel to leave the old name.", old_name) }

    local buttons = rename_root.add{ type="flow", direction="horizontal" }
    buttons.add{ type="button", caption="OK", name="prodmon_rename_ok_"..old_name }
    buttons.add{ type="button", caption="Cancel", name="prodmon_rename_cancel_"..old_name }
end


function gui.on_click(e)
    if string.starts_with(e.element.name, "prodmon_rename_ok_") then
        gui.on_rename_ok(e)
    elseif string.starts_with(e.element.name, "prodmon_rename_cancel_") then
        gui.on_rename_cancel(e)
    end
end


function gui.on_rename_ok(e)
    local player = game.players[e.player_index]
    local old_name = string.sub(e.element.name, 1 + string.len("prodmon_rename_ok_"))

    local rename_root = player.gui.center["prodmon_rename_"..old_name]

    local new_name = rename_root.new_name.text
    local success, err = combinators.rename(old_name, new_name)

    if not success then
        rename_root.message.caption = err
    else
        rename_root.destroy()
    end
end


function gui.on_rename_cancel(e)
    local player = game.players[e.player_index]
    local old_name = string.sub(e.element.name, 1 + string.len("prodmon_rename_cancel_"))

    player.gui.center["prodmon_rename_"..old_name].destroy()
end
