minetest.register_node(":platform", {
    tiles = {"blank.png^[invert:rgba^[colorize:grey:255"},
    groups = {breakable = 1},
    tool_capabilities = {
        full_punch_interval = 1.0,
        groupcaps = {
            breakable = {times = {0.1}},
        },
    },
})
