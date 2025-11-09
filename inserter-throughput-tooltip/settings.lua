local mod_name = 'inserter-throughput-tooltip'


data:extend({
-- Startup settings
    {
        type = "bool-setting",
        name = mod_name.."-add-base-max-throughput",
        setting_type = "startup",
        default_value = true,
        order = "a-a",
    },
    {
        type = "bool-setting",
        name = mod_name.."-add-per-hand-size",
        setting_type = "startup",
        default_value = true,
        order = "a-a",
    },
})