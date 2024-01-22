satlantis.require("beacon.lua")
satlantis.require("tools.lua")

satlantis.register_block("tool:torch", {
    description = "Torch",
    drawtype = "nodebox",
    tiles = {"torch.png"},
    node_box = {
        type = "fixed",
        fixed = {-1 / 16, -8 / 16, -1 / 16, 1 / 16, 0, 1 / 16},
    },
    paramtype = "light",
    light_source = 13,
    groups = {choppy = 1, oddly_breakable_by_hand = 1},
})
