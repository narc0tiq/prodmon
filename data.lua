
local prodmon_combinator = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
prodmon_combinator.name = "production-monitor"
prodmon_combinator.item_slot_count = 0
prodmon_combinator.sprites =
{
    north =
    {
        filename = "__prodmon__/gfx/prodmon-combinator.png",
        x = 158,
        width = 79,
        height = 63,
        frame_count = 1,
        shift = {0.140625, 0.140625},
    },
    east =
    {
        filename = "__prodmon__/gfx/prodmon-combinator.png",
        width = 79,
        height = 63,
        frame_count = 1,
        shift = {0.140625, 0.140625},
    },
    south =
    {
        filename = "__prodmon__/gfx/prodmon-combinator.png",
        x = 237,
        width = 79,
        height = 63,
        frame_count = 1,
        shift = {0.140625, 0.140625},
    },
    west =
    {
        filename = "__prodmon__/gfx/prodmon-combinator.png",
        x = 79,
        width = 79,
        height = 63,
        frame_count = 1,
        shift = {0.140625, 0.140625},
    },
}
prodmon_combinator.minable.result = "production-monitor"

local prodmon_combinator_item = table.deepcopy(data.raw.item["constant-combinator"])
prodmon_combinator_item.name = "production-monitor"
prodmon_combinator_item.place_result = "production-monitor"

local prodmon_combinator_recipe = {
    type = "recipe",
    name = "production-monitor",
    enabled = false,
    ingredients =
    {
        {"copper-cable", 5},
        {"electronic-circuit", 4},
    },
    result = "production-monitor",
}

data:extend{ prodmon_combinator, prodmon_combinator_item, prodmon_combinator_recipe }

local prodmon_combinator_effect = { type = "unlock-recipe", recipe = "production-monitor" }
table.insert(data.raw.technology["circuit-network"].effects, prodmon_combinator_effect)


local default_gui = data.raw["gui-style"].default

default_gui.prodmon_ident = {
    type = "label_style",
    parent = "label",
    font = "default-small-semibold",
}

default_gui.prodmon_data_table = {
    type = "table_style",
    horizontal_spacing = 3,
    vertical_spacing = 1,
}

default_gui.prodmon_buttons = {
    type = "vertical_flow_style",
    parent = "description_vertical_flow",
    horizontal_spacing = 1,
    vertical_spacing = 5,
    top_padding = 4,
}
