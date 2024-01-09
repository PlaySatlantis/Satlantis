local colors = {
    black = "Black",
    blue = "Blue",
    brown = "Brown",
    cyan = "Cyan",
    gray = "Gray",
    green = "Green",
    light_blue = "Light Blue",
    light_gray = "Light Gray",
    lime = "Lime",
    magenta = "Magenta",
    orange = "Orange",
    pink = "Pink",
    purple = "Purple",
    red = "Red",
    white = "White",
    yellow = "Yellow",
}

for name, desc in pairs(colors) do
    satlantis.register_block("geo:glass_stained_" .. name, {
        description = "Stained Glass (" .. desc .. ")",
        drawtype = "glasslike_framed_optional",
        tiles = {"glass_stained_" .. name .. ".png"},
        use_texture_alpha = "blend",
        paramtype = "light",
        sunlight_propagates = true,
        is_ground_content = false,
        groups = {cracky = 3, oddly_breakable_by_hand = 3},
    })

    satlantis.panes.register_pane("glass_stained_" .. name, {
        description = "Stained Glass Pane (" .. desc .. ")",
        textures = {"glass_stained_" .. name .. ".png", "", "glass_stained_" .. name .. "_pane_top.png"},
        use_texture_alpha = true,
        inventory_image = "glass_stained_" .. name .. ".png",
        wield_image = "glass_stained_" .. name .. ".png",
        groups = {snappy=2, cracky=3, oddly_breakable_by_hand=3},
        recipe = {
            {"geo:glass_stained_" .. name, "geo:glass_stained_" .. name, "geo:glass_stained_" .. name},
            {"geo:glass_stained_" .. name, "geo:glass_stained_" .. name, "geo:glass_stained_" .. name}
        }
    })
end
