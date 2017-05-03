
local my_combi = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
my_combi.name = "test-combinator"
my_combi.item_slot_count = 0
my_combi.sprites =
{
    north =
    {
        filename = "__test-mod__/orange-constant-combi.png",
        x = 158,
        width = 79,
        height = 63,
        frame_count = 1,
        shift = {0.140625, 0.140625},
    },
    east =
    {
        filename = "__test-mod__/orange-constant-combi.png",
        width = 79,
        height = 63,
        frame_count = 1,
        shift = {0.140625, 0.140625},
    },
    south =
    {
        filename = "__test-mod__/orange-constant-combi.png",
        x = 237,
        width = 79,
        height = 63,
        frame_count = 1,
        shift = {0.140625, 0.140625},
    },
    west =
    {
        filename = "__test-mod__/orange-constant-combi.png",
        x = 79,
        width = 79,
        height = 63,
        frame_count = 1,
        shift = {0.140625, 0.140625},
    },
}
my_combi.minable.result = "test-combinator"

local my_combi_item = table.deepcopy(data.raw.item["constant-combinator"])
my_combi_item.name = "test-combinator"
my_combi_item.place_result = "test-combinator"

data:extend{ my_combi, my_combi_item }
