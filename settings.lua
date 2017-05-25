data:extend{
    {
        type = "int-setting",
        name = "prodmon-sample-frequency",
        setting_type = "runtime-global",
        default_value = 60,
        minimum_value = 10,
        maximum_value = 300,
        order = "a",
    },
    {
        type = "int-setting",
        name = "prodmon-sample-count",
        setting_type = "runtime-global",
        default_value = 16,
        minimum_value = 10,
        maximum_value = 50,
        order = "b",
    },
}
