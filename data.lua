
local my_combi = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
my_combi.name = "production-monitor"
my_combi.item_slot_count = 0
my_combi.sprites =
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
my_combi.minable.result = "production-monitor"

local my_combi_item = table.deepcopy(data.raw.item["constant-combinator"])
my_combi_item.name = "production-monitor"
my_combi_item.place_result = "production-monitor"

data:extend{ my_combi, my_combi_item }

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
