--[[
    Everness. Never ending discovery in Everness mapgen.
    Copyright (C) 2024 SaKeL

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

--]]

--
-- Blocks
--

if minetest.get_modpath('default') then
    minetest.register_craft({
        output = 'everness:snowcobble 9',
        recipe = {
            { 'default:snowblock', 'default:snowblock', 'default:snowblock' },
            { 'default:snowblock', 'default:snowblock', 'default:snowblock' },
            { 'default:snowblock', 'default:snowblock', 'default:snowblock' },
        }
    })

    minetest.register_craft({
        output = 'everness:icecobble 9',
        recipe = {
            { 'default:ice', 'default:ice', 'default:ice' },
            { 'default:ice', 'default:ice', 'default:ice' },
            { 'default:ice', 'default:ice', 'default:ice' },
        }
    })
end

minetest.register_craft({
    output = 'everness:snowcobble 9',
    recipe = {
        { 'everness:frosted_snowblock', 'everness:frosted_snowblock', 'everness:frosted_snowblock' },
        { 'everness:frosted_snowblock', 'everness:frosted_snowblock', 'everness:frosted_snowblock' },
        { 'everness:frosted_snowblock', 'everness:frosted_snowblock', 'everness:frosted_snowblock' },
    }
})

minetest.register_craft({
    output = 'everness:icecobble 9',
    recipe = {
        { 'everness:frosted_ice', 'everness:frosted_ice', 'everness:frosted_ice' },
        { 'everness:frosted_ice', 'everness:frosted_ice', 'everness:frosted_ice' },
        { 'everness:frosted_ice', 'everness:frosted_ice', 'everness:frosted_ice' },
    }
})

minetest.register_craft({
    type = 'shapeless',
    output = 'everness:frosted_ice_translucent',
    recipe = { 'everness:frosted_ice' }
})

minetest.register_craft({
    type = 'shapeless',
    output = 'everness:frosted_ice',
    recipe = { 'everness:frosted_ice_translucent' }
})

minetest.register_craft({
    output = 'everness:bamboo_block',
    recipe = {
        { 'everness:bamboo_item', 'everness:bamboo_item', 'everness:bamboo_item' },
        { 'everness:bamboo_item', 'everness:bamboo_item', 'everness:bamboo_item' },
        { 'everness:bamboo_item', 'everness:bamboo_item', 'everness:bamboo_item' },
    }
})

minetest.register_craft({
    output = 'everness:bamboo_wood',
    recipe = {
        { 'everness:bamboo_item', 'everness:bamboo_item', '' },
        { 'everness:bamboo_item', 'everness:bamboo_item', '' },
        { '', '', '' },
    }
})

minetest.register_craft({
    output = 'everness:trapdoor_bamboo 2',
    recipe = {
        { 'everness:bamboo_wood', 'everness:bamboo_wood', 'everness:bamboo_wood' },
        { 'everness:bamboo_wood', 'everness:bamboo_wood', 'everness:bamboo_wood' },
        { '', '', '' },
    }
})

minetest.register_craft({
    output = 'everness:trapdoor_crystal_wood 2',
    recipe = {
        { 'everness:crystal_wood', 'everness:crystal_wood', 'everness:crystal_wood' },
        { 'everness:crystal_wood', 'everness:crystal_wood', 'everness:crystal_wood' },
        { '', '', '' },
    }
})

minetest.register_craft({
    output = 'everness:trapdoor_cursed_wood 2',
    recipe = {
        { 'everness:dry_wood', 'everness:dry_wood', 'everness:dry_wood' },
        { 'everness:dry_wood', 'everness:dry_wood', 'everness:dry_wood' },
        { '', '', '' },
    }
})

minetest.register_craft({
    output = 'everness:trapdoor_palm_wood 2',
    recipe = {
        { 'everness:palm_tree_wood', 'everness:palm_tree_wood', 'everness:palm_tree_wood' },
        { 'everness:palm_tree_wood', 'everness:palm_tree_wood', 'everness:palm_tree_wood' },
        { '', '', '' },
    }
})

minetest.register_craft({
    output = 'everness:trapdoor_lava_tree 2',
    recipe = {
        { 'everness:lava_tree_wood', 'everness:lava_tree_wood', 'everness:lava_tree_wood' },
        { 'everness:lava_tree_wood', 'everness:lava_tree_wood', 'everness:lava_tree_wood' },
        { '', '', '' },
    }
})

minetest.register_craft({
    output = 'everness:bamboo_mosaic_wood',
    recipe = {
        { 'everness:bamboo_wood', 'everness:bamboo_wood' },
        { 'everness:bamboo_wood', 'everness:bamboo_wood' },
    }
})

minetest.register_craft({
    output = 'everness:pyriteblock',
    recipe = {
        { 'everness:pyrite_ingot', 'everness:pyrite_ingot', 'everness:pyrite_ingot' },
        { 'everness:pyrite_ingot', 'everness:pyrite_ingot', 'everness:pyrite_ingot' },
        { 'everness:pyrite_ingot', 'everness:pyrite_ingot', 'everness:pyrite_ingot' },
    }
})

minetest.register_craft({
    output = 'everness:pyrite_glass',
    recipe = {
        { 'group:glass' },
        { 'everness:pyrite_ingot' },
    }
})

if minetest.get_modpath('default') then
    minetest.register_craft({
        output = 'everness:pyrite_glass',
        recipe = {
            { 'default:glass' },
            { 'everness:pyrite_ingot' },
        }
    })
end

minetest.register_craft({
    output = 'everness:pyrite_lantern',
    recipe = {
        { 'everness:pyrite_glass' },
        { 'everness:pyrite_ingot' },
    }
})

minetest.register_craft({
    output = 'everness:tinted_glass_red 8',
    recipe = {
        { 'everness:glass', 'everness:glass', 'everness:glass' },
        { 'everness:glass', 'everness:bloodspore_plant', 'everness:glass' },
        { 'everness:glass', 'everness:glass', 'everness:glass' },
    }
})

minetest.register_craft({
    output = 'everness:tinted_glass_red 8',
    recipe = {
        { 'everness:glass', 'everness:glass', 'everness:glass' },
        { 'everness:glass', 'everness:bloodspore_plant_small', 'everness:glass' },
        { 'everness:glass', 'everness:glass', 'everness:glass' },
    }
})

minetest.register_craft({
    output = 'everness:pyriteblock_brick 4',
    recipe = {
        { 'everness:pyriteblock_forged', 'everness:pyriteblock_forged' },
        { 'everness:pyriteblock_forged', 'everness:pyriteblock_forged' },
    }
})

minetest.register_craft({
    output = 'everness:pyriteblock_slab_brick 2',
    recipe = {
        { 'everness:pyriteblock_forged', 'everness:pyriteblock_forged' },
    }
})

minetest.register_craft({
    output = 'everness:pyriteblock_spiral 8',
    recipe = {
        { 'everness:pyriteblock_forged', 'everness:pyriteblock_forged', 'everness:pyriteblock_forged' },
        { 'everness:pyriteblock_forged', '', 'everness:pyriteblock_forged' },
        { 'everness:pyriteblock_forged', 'everness:pyriteblock_forged', 'everness:pyriteblock_forged' },
    }
})

minetest.register_craft({
    output = 'everness:pyrite_roof_tile 6',
    recipe = {
        { 'everness:pyriteblock_forged', 'everness:pyriteblock_forged' },
        { 'everness:pyriteblock_forged', 'everness:pyriteblock_forged' },
        { 'everness:pyriteblock_forged', 'everness:pyriteblock_forged' },
    }
})

minetest.register_craft({
    output = 'everness:pyrite_pillar_bottom 5',
    recipe = {
        { '', 'everness:pyriteblock_forged', '' },
        { '', 'everness:pyriteblock_forged', '' },
        { 'everness:pyriteblock_forged', 'everness:pyriteblock_forged', 'everness:pyriteblock_forged' },
    }
})

minetest.register_craft({
    output = 'everness:pyrite_pillar_middle 3',
    recipe = {
        { '', 'everness:pyriteblock_forged', '' },
        { '', 'everness:pyriteblock_forged', '' },
        { '', 'everness:pyriteblock_forged', '' },
    }
})

minetest.register_craft({
    output = 'everness:pyrite_pillar_top 5',
    recipe = {
        { 'everness:pyriteblock_forged', 'everness:pyriteblock_forged', 'everness:pyriteblock_forged' },
        { '', 'everness:pyriteblock_forged', '' },
        { '', 'everness:pyriteblock_forged', '' },
    }
})

minetest.register_craft({
    output = 'everness:pyrite_pillar_small 7',
    recipe = {
        { 'everness:pyriteblock_forged', 'everness:pyriteblock_forged', 'everness:pyriteblock_forged' },
        { '', 'everness:pyriteblock_forged', '' },
        { 'everness:pyriteblock_forged', 'everness:pyriteblock_forged', 'everness:pyriteblock_forged' },
    }
})

minetest.register_craft({
    output = 'everness:pyriteblock_polished 9',
    recipe = {
        { 'everness:pyriteblock_forged', 'everness:pyriteblock_forged', 'everness:pyriteblock_forged' },
        { 'everness:pyriteblock_forged', 'everness:pyriteblock_forged', 'everness:pyriteblock_forged' },
        { 'everness:pyriteblock_forged', 'everness:pyriteblock_forged', 'everness:pyriteblock_forged' },
    }
})

minetest.register_craft({
    output = 'everness:baobab_wood 4',
    recipe = {
        { 'everness:baobab_tree' },
    }
})

minetest.register_craft({
    output = 'everness:dry_wood 4',
    recipe = {
        { 'everness:dry_tree' },
    }
})

minetest.register_craft({
    output = 'everness:coral_wood 4',
    recipe = {
        { 'everness:coral_tree' },
    }
})

minetest.register_craft({
    output = 'everness:willow_wood 4',
    recipe = {
        { 'everness:willow_tree' },
    }
})

minetest.register_craft({
    output = 'everness:sequoia_wood 4',
    recipe = {
        { 'everness:sequoia_tree' },
    }
})

minetest.register_craft({
    output = 'everness:crystal_wood 4',
    recipe = {
        { 'everness:crystal_tree' },
    }
})

minetest.register_craft({
    output = 'everness:mese_wood 4',
    recipe = {
        { 'everness:mese_tree' },
    }
})

minetest.register_craft({
    output = 'everness:lava_tree_wood 4',
    recipe = {
        { 'everness:lava_tree' },
    }
})

minetest.register_craft({
    output = 'everness:lava_tree_wood 4',
    recipe = {
        { 'everness:lava_tree_with_lava' },
    }
})

minetest.register_craft({
    output = 'everness:coral_sandstone 4',
    recipe = {
        { 'everness:coral_sand', 'everness:coral_sand' },
        { 'everness:coral_sand', 'everness:coral_sand' },
    }
})

minetest.register_craft({
    output = 'everness:coral_sandstone_brick 4',
    recipe = {
        { 'everness:coral_sandstone', 'everness:coral_sandstone' },
        { 'everness:coral_sandstone', 'everness:coral_sandstone' },
    }
})

minetest.register_craft({
    output = 'everness:coral_deep_ocean_sandstone_block 4',
    recipe = {
        { 'everness:coral_forest_deep_ocean_sand', 'everness:coral_forest_deep_ocean_sand' },
        { 'everness:coral_forest_deep_ocean_sand', 'everness:coral_forest_deep_ocean_sand' },
    }
})

minetest.register_craft({
    output = 'everness:coral_deep_ocean_sandstone_brick 4',
    recipe = {
        { 'everness:coral_deep_ocean_sandstone_block', 'everness:coral_deep_ocean_sandstone_block' },
        { 'everness:coral_deep_ocean_sandstone_block', 'everness:coral_deep_ocean_sandstone_block' },
    }
})

minetest.register_craft({
    output = 'everness:coral_sandstone_chiseled 9',
    recipe = {
        { 'everness:coral_sandstone', 'everness:coral_sandstone', 'everness:coral_sandstone' },
        { 'everness:coral_sandstone', 'everness:coral_sandstone', 'everness:coral_sandstone' },
        { 'everness:coral_sandstone', 'everness:coral_sandstone', 'everness:coral_sandstone' },
    }
})

minetest.register_craft({
    output = 'everness:coral_sandstone_carved_1 9',
    recipe = {
        { 'everness:coral_sandstone_chiseled', 'everness:coral_sandstone_chiseled' },
        { 'everness:coral_sandstone_chiseled', 'everness:coral_sandstone_chiseled' },
    }
})

minetest.register_craft({
    output = 'everness:coral_white_sandstone 4',
    recipe = {
        { 'everness:coral_white_sand', 'everness:coral_white_sand' },
        { 'everness:coral_white_sand', 'everness:coral_white_sand' },
    }
})

minetest.register_craft({
    output = 'everness:coral_white_sandstone_brick 4',
    recipe = {
        { 'everness:coral_white_sandstone', 'everness:coral_white_sandstone' },
        { 'everness:coral_white_sandstone', 'everness:coral_white_sandstone' },
    }
})

minetest.register_craft({
    output = 'everness:coral_white_sandstone_pillar 3',
    recipe = {
        { '', 'everness:coral_white_sandstone', '' },
        { '', 'everness:coral_white_sandstone', '' },
        { '', 'everness:coral_white_sandstone', '' },
    }
})

minetest.register_craft({
    output = 'everness:quartz_block 4',
    recipe = {
        { 'everness:quartz_crystal', 'everness:quartz_crystal' },
        { 'everness:quartz_crystal', 'everness:quartz_crystal' },
    }
})

minetest.register_craft({
    output = 'everness:quartz_chiseled 4',
    recipe = {
        { 'everness:quartz_block', 'everness:quartz_block' },
        { 'everness:quartz_block', 'everness:quartz_block' },
    }
})

minetest.register_craft({
    output = 'everness:quartz_pillar 3',
    recipe = {
        { '', 'everness:quartz_block', '' },
        { '', 'everness:quartz_block', '' },
        { '', 'everness:quartz_block', '' },
    }
})

minetest.register_craft({
    output = 'everness:coral_desert_stone_brick 4',
    recipe = {
        { 'everness:coral_desert_stone', 'everness:coral_desert_stone' },
        { 'everness:coral_desert_stone', 'everness:coral_desert_stone' },
    }
})

minetest.register_craft({
    output = 'everness:coral_desert_stone_block 9',
    recipe = {
        { 'everness:coral_desert_stone', 'everness:coral_desert_stone', 'everness:coral_desert_stone' },
        { 'everness:coral_desert_stone', 'everness:coral_desert_stone', 'everness:coral_desert_stone' },
        { 'everness:coral_desert_stone', 'everness:coral_desert_stone', 'everness:coral_desert_stone' },
    }
})

minetest.register_craft({
    output = 'everness:coral_bones_brick 4',
    recipe = {
        { 'everness:coral_bones_block', 'everness:coral_bones_block' },
        { 'everness:coral_bones_block', 'everness:coral_bones_block' },
    }
})

minetest.register_craft({
    output = 'everness:coral_bones_block 9',
    recipe = {
        { 'everness:coral_bones', 'everness:coral_bones', 'everness:coral_bones' },
        { 'everness:coral_bones', 'everness:coral_bones', 'everness:coral_bones' },
        { 'everness:coral_bones', 'everness:coral_bones', 'everness:coral_bones' },
    }
})

minetest.register_craft({
    output = 'everness:crystal_sandstone 4',
    recipe = {
        { 'everness:crystal_sand', 'everness:crystal_sand' },
        { 'everness:crystal_sand', 'everness:crystal_sand' },
    }
})

minetest.register_craft({
    output = 'everness:crystal_sandstone_brick 4',
    recipe = {
        { 'everness:crystal_sandstone', 'everness:crystal_sandstone' },
        { 'everness:crystal_sandstone', 'everness:crystal_sandstone' },
    }
})

minetest.register_craft({
    output = 'everness:crystal_sandstone_chiseled 9',
    recipe = {
        { 'everness:crystal_sandstone', 'everness:crystal_sandstone', 'everness:crystal_sandstone' },
        { 'everness:crystal_sandstone', 'everness:crystal_sandstone', 'everness:crystal_sandstone' },
        { 'everness:crystal_sandstone', 'everness:crystal_sandstone', 'everness:crystal_sandstone' },
    }
})

minetest.register_craft({
    output = 'everness:cursed_brick 4',
    recipe = {
        { 'everness:cursed_stone', 'everness:cursed_stone' },
        { 'everness:cursed_stone', 'everness:cursed_stone' },
    }
})

minetest.register_craft({
    output = 'everness:cursed_brick_with_growth 4',
    recipe = {
        { 'everness:cursed_brick', 'group:leaves' }
    }
})

minetest.register_craft({
    output = 'everness:cursed_brick_mixed 4',
    recipe = {
        { 'everness:cursed_stone', 'everness:cursed_brick' },
        { 'everness:cursed_brick', 'everness:cursed_stone' },
    }
})

minetest.register_craft({
    output = 'everness:cursed_brick_carved 9',
    recipe = {
        { 'everness:cursed_brick', 'everness:cursed_brick', 'everness:cursed_brick' },
        { 'everness:cursed_brick', 'everness:cursed_brick', 'everness:cursed_brick' },
        { 'everness:cursed_brick', 'everness:cursed_brick', 'everness:cursed_brick' },
    }
})

minetest.register_craft({
    output = 'everness:cursed_sandstone_block 4',
    recipe = {
        { 'everness:cursed_sand', 'everness:cursed_sand' },
        { 'everness:cursed_sand', 'everness:cursed_sand' },
    }
})

minetest.register_craft({
    output = 'everness:cursed_sandstone_brick 4',
    recipe = {
        { 'everness:cursed_sandstone_block', 'everness:cursed_sandstone_block' },
        { 'everness:cursed_sandstone_block', 'everness:cursed_sandstone_block' },
    }
})

minetest.register_craft({
    output = 'everness:forsaken_tundra_brick 4',
    recipe = {
        { 'everness:forsaken_tundra_stone', 'everness:forsaken_tundra_stone' },
        { 'everness:forsaken_tundra_stone', 'everness:forsaken_tundra_stone' },
    }
})

minetest.register_craft({
    output = 'everness:forsaken_desert_cobble',
    recipe = {
        { 'everness:forsaken_desert_cobble_red', 'everness:forsaken_desert_sand' },
    }
})

minetest.register_craft({
    output = 'everness:forsaken_desert_brick_red',
    recipe = {
        { 'everness:forsaken_desert_stone', 'everness:forsaken_desert_stone' },
        { 'everness:forsaken_desert_stone', 'everness:forsaken_desert_stone' },
    }
})

minetest.register_craft({
    output = 'everness:forsaken_desert_brick',
    recipe = {
        { 'everness:forsaken_desert_brick_red', 'everness:forsaken_desert_sand' },
    }
})

minetest.register_craft({
    output = 'everness:forsaken_desert_chiseled_stone',
    recipe = {
        { 'everness:forsaken_desert_brick_red' },
        { 'everness:forsaken_desert_brick' },
    }
})

minetest.register_craft({
    output = 'everness:forsaken_desert_engraved_stone 4',
    recipe = {
        { 'everness:forsaken_desert_brick', 'everness:forsaken_desert_brick' },
        { 'everness:forsaken_desert_brick', 'everness:forsaken_desert_brick' },
    }
})

minetest.register_craft({
    output = 'everness:coral_forest_deep_ocean_lantern 1',
    recipe = {
        { 'everness:coral_deep_ocean_sandstone_block', 'group:glass', 'everness:coral_deep_ocean_sandstone_block' },
        { 'group:glass', 'group:torch', 'group:glass' },
        { 'everness:coral_deep_ocean_sandstone_block', 'group:glass', 'everness:coral_deep_ocean_sandstone_block' },
    }
})

if minetest.get_modpath('default') then
    minetest.register_craft({
        output = 'everness:coral_forest_deep_ocean_lantern 1',
        recipe = {
            { 'everness:coral_deep_ocean_sandstone_block', 'default:glass', 'everness:coral_deep_ocean_sandstone_block' },
            { 'default:glass', 'group:torch', 'default:glass' },
            { 'everness:coral_deep_ocean_sandstone_block', 'default:glass', 'everness:coral_deep_ocean_sandstone_block' },
        }
    })
end

minetest.register_craft({
    output = 'everness:cursed_lands_deep_ocean_sandstone_block 4',
    recipe = {
        { 'everness:cursed_lands_deep_ocean_sand', 'everness:cursed_lands_deep_ocean_sand' },
        { 'everness:cursed_lands_deep_ocean_sand', 'everness:cursed_lands_deep_ocean_sand' },
    }
})

minetest.register_craft({
    output = 'everness:cursed_lands_deep_ocean_sandstone_brick 4',
    recipe = {
        { 'everness:cursed_lands_deep_ocean_sandstone_block', 'everness:cursed_lands_deep_ocean_sandstone_block' },
        { 'everness:cursed_lands_deep_ocean_sandstone_block', 'everness:cursed_lands_deep_ocean_sandstone_block' },
    }
})

minetest.register_craft({
    output = 'everness:crystal_forest_deep_ocean_sandstone_block 4',
    recipe = {
        { 'everness:crystal_forest_deep_ocean_sand', 'everness:crystal_forest_deep_ocean_sand' },
        { 'everness:crystal_forest_deep_ocean_sand', 'everness:crystal_forest_deep_ocean_sand' },
    }
})

minetest.register_craft({
    output = 'everness:crystal_forest_deep_ocean_sandstone_brick 4',
    recipe = {
        { 'everness:crystal_forest_deep_ocean_sandstone_block', 'everness:crystal_forest_deep_ocean_sandstone_block' },
        { 'everness:crystal_forest_deep_ocean_sandstone_block', 'everness:crystal_forest_deep_ocean_sandstone_block' },
    }
})

minetest.register_craft({
    output = 'everness:shell_of_underwater_breathing',
    recipe = {
        { '', '', 'group:everness_crystal_forest_deep_ocean_coral' },
        { '', 'group:everness_cursed_lands_deep_ocean_coral', '' },
        { 'group:everness_coral_forest_deep_ocean_coral', '', '' },
    }
})

minetest.register_craft({
    output = 'default:mese_crystal_fragment',
    recipe = {
        { 'everness:mese_tree_fruit', 'everness:mese_tree_fruit', 'everness:mese_tree_fruit' },
        { 'everness:mese_tree_fruit', 'everness:mese_tree_fruit', 'everness:mese_tree_fruit' },
        { 'everness:mese_tree_fruit', 'everness:mese_tree_fruit', 'everness:mese_tree_fruit' },
    }
})

minetest.register_craft({
    output = 'default:paper',
    recipe = {
        { 'everness:lotus_leaf_3', 'everness:lotus_leaf_3', 'everness:lotus_leaf_3' },
    }
})

minetest.register_craft({
    output = 'everness:mineral_stone_block 9',
    recipe = {
        { 'everness:mineral_stone', 'everness:mineral_stone', 'everness:mineral_stone' },
        { 'everness:mineral_stone', 'everness:mineral_stone', 'everness:mineral_stone' },
        { 'everness:mineral_stone', 'everness:mineral_stone', 'everness:mineral_stone' },
    }
})

minetest.register_craft({
    output = 'everness:mineral_stone_brick 4',
    recipe = {
        { 'everness:mineral_stone', 'everness:mineral_stone' },
        { 'everness:mineral_stone', 'everness:mineral_stone' },
    }
})

minetest.register_craft({
    output = 'everness:mineral_sandstone',
    recipe = {
        { 'everness:mineral_sand', 'everness:mineral_sand' },
        { 'everness:mineral_sand', 'everness:mineral_sand' },
    }
})

minetest.register_craft({
    output = 'everness:mineral_sand 4',
    recipe = {
        { 'everness:mineral_sandstone' },
    }
})

minetest.register_craft({
    output = 'everness:mineral_sandstone_brick 4',
    recipe = {
        { 'everness:mineral_sandstone', 'everness:mineral_sandstone' },
        { 'everness:mineral_sandstone', 'everness:mineral_sandstone' },
    }
})

minetest.register_craft({
    output = 'everness:mineral_sandstone_block 9',
    recipe = {
        { 'everness:mineral_sandstone', 'everness:mineral_sandstone', 'everness:mineral_sandstone' },
        { 'everness:mineral_sandstone', 'everness:mineral_sandstone', 'everness:mineral_sandstone' },
        { 'everness:mineral_sandstone', 'everness:mineral_sandstone', 'everness:mineral_sandstone' },
    }
})

minetest.register_craft({
    output = 'everness:mineral_sandstone_brick_block 6',
    recipe = {
        { 'everness:mineral_sandstone', 'everness:mineral_sandstone', 'everness:mineral_sandstone' },
        { 'everness:mineral_sandstone_brick', 'everness:mineral_sandstone_brick', 'everness:mineral_sandstone_brick' },
    }
})

minetest.register_craft({
    output = 'everness:mineral_stone_brick_with_growth 3',
    recipe = {
        { 'group:flora', 'group:flora', 'group:flora'},
        { 'everness:mineral_stone_brick', 'everness:mineral_stone_brick', 'everness:mineral_stone_brick'},
        { 'group:flora', 'group:flora', 'group:flora'},
    }
})

minetest.register_craft({
    output = 'everness:mineral_stone_brick_with_flower_growth 6',
    recipe = {
        { 'everness:mineral_stone_brick_with_growth', 'everness:mineral_stone_brick_with_growth', 'everness:mineral_stone_brick_with_growth'},
        { 'group:flower', 'group:flower', 'group:flower'},
        { 'everness:mineral_stone_brick_with_growth', 'everness:mineral_stone_brick_with_growth', 'everness:mineral_stone_brick_with_growth'}
    }
})

minetest.register_craft({
    output = 'everness:sand_castle_wall 6',
    recipe = {
        { '', '', '' },
        { 'everness:mineral_sandstone', 'everness:mineral_sandstone', 'everness:mineral_sandstone'},
        { 'everness:mineral_sandstone', 'everness:mineral_sandstone', 'everness:mineral_sandstone'},
    }
})

minetest.register_craft({
    output = 'everness:ceramic_pot_blank',
    recipe = {
        { '', 'everness:ceramic_pot_sherd_blank', ''},
        { 'everness:ceramic_pot_sherd_blank', '', 'everness:ceramic_pot_sherd_blank'},
        { '', 'everness:ceramic_pot_sherd_blank', ''},
    }
})

minetest.register_craft({
    output = 'everness:ceramic_pot_sherd_blank 4',
    type = 'shapeless',
    recipe = { 'everness:ceramic_pot_blank' }
})

-- Crystals

minetest.register_craft({
    output = 'everness:crystal_block_purple',
    recipe = {
        { 'everness:crystal_purple', 'everness:crystal_purple', 'everness:crystal_purple' },
        { 'everness:crystal_purple', 'everness:crystal_purple', 'everness:crystal_purple' },
        { 'everness:crystal_purple', 'everness:crystal_purple', 'everness:crystal_purple' },
    }
})

minetest.register_craft({
    output = 'everness:crystal_purple 9',
    type = 'shapeless',
    recipe = { 'everness:crystal_block_purple' }
})

minetest.register_craft({
    output = 'everness:crystal_block_orange',
    recipe = {
        { 'everness:crystal_orange', 'everness:crystal_orange', 'everness:crystal_orange' },
        { 'everness:crystal_orange', 'everness:crystal_orange', 'everness:crystal_orange' },
        { 'everness:crystal_orange', 'everness:crystal_orange', 'everness:crystal_orange' },
    }
})

minetest.register_craft({
    output = 'everness:crystal_orange 9',
    type = 'shapeless',
    recipe = { 'everness:crystal_block_orange' }
})

minetest.register_craft({
    output = 'everness:crystal_block_cyan',
    recipe = {
        { 'everness:crystal_cyan', 'everness:crystal_cyan', 'everness:crystal_cyan' },
        { 'everness:crystal_cyan', 'everness:crystal_cyan', 'everness:crystal_cyan' },
        { 'everness:crystal_cyan', 'everness:crystal_cyan', 'everness:crystal_cyan' },
    }
})

minetest.register_craft({
    output = 'everness:crystal_cyan 9',
    type = 'shapeless',
    recipe = { 'everness:crystal_block_cyan' }
})

--
-- Tools
--

minetest.register_craft({
    output = 'everness:vine_shears',
    recipe = {
        { '', 'everness:pyrite_ingot', '' },
        { 'group:stick', 'group:wood', 'everness:pyrite_ingot' },
        { '', '', 'group:stick' }
    }
})

minetest.register_craft({
    output = 'everness:pick_illuminating',
    recipe = {
        { 'everness:crystal_purple', 'everness:coral_tree_bioluminescent', 'everness:crystal_purple' },
        { '', 'everness:sulfur_stone', '' },
        { '', 'group:stick', '' }
    }
})

minetest.register_craft({
    output = 'everness:shovel_silk',
    recipe = {
        { 'everness:ancient_emerald_ice' },
        { 'everness:glowing_pillar' },
        { 'everness:crystal_purple' }
    }
})

minetest.register_craft({
    output = 'everness:hammer',
    recipe = {
        { 'group:everness_obsidian', 'group:everness_obsidian', 'group:everness_obsidian' },
        { 'group:everness_obsidian', 'everness:pyriteblock_forged', 'group:everness_obsidian' },
        { '', 'group:stick', '' }
    }
})

minetest.register_craft({
    output = 'everness:hammer_sharp',
    recipe = {
        { 'everness:pyriteblock_forged', 'everness:pyriteblock_forged', 'everness:pyriteblock_forged' },
        { 'everness:pyriteblock_forged', 'everness:hammer', 'everness:pyriteblock_forged' },
        { '', 'everness:hammer', '' }
    }
})

minetest.register_craft({
    output = 'everness:pick_archeological',
    recipe = {
        { 'group:stone', 'group:stone', 'group:stone' },
        { '', 'group:stick', '' },
        { 'group:stick', '', '' }
    }
})

--
-- Fuels
--

minetest.register_craft({
    type = 'fuel',
    recipe = 'everness:coral_burdock_1',
    burntime = 3,
})

minetest.register_craft({
    type = 'fuel',
    recipe = 'everness:coral_burdock_2',
    burntime = 3,
})

minetest.register_craft({
    type = 'fuel',
    recipe = 'everness:bamboo_block',
    burntime = 15,
})

minetest.register_craft({
    type = 'fuel',
    recipe = 'everness:bamboo_dry_block',
    burntime = 15,
})

minetest.register_craft({
    type = 'fuel',
    recipe = 'everness:bamboo_wood',
    burntime = 15,
})

minetest.register_craft({
    type = 'fuel',
    recipe = 'everness:crystal_wood',
    burntime = 15,
})

minetest.register_craft({
    type = 'fuel',
    recipe = 'everness:bamboo_mosaic_wood',
    burntime = 15,
})

minetest.register_craft({
    type = 'fuel',
    recipe = 'everness:mese_wood',
    burntime = 15,
})

minetest.register_craft({
    type = 'fuel',
    recipe = 'everness:lava_tree_wood',
    burntime = 30,
})

minetest.register_craft({
    type = 'fuel',
    recipe = 'everness:bamboo_item',
    burntime = 3,
})

minetest.register_craft({
    type = 'fuel',
    recipe = 'everness:trapdoor_bamboo',
    burntime = 7,
})

minetest.register_craft({
    type = 'fuel',
    recipe = 'everness:trapdoor_crystal_wood',
    burntime = 7,
})

minetest.register_craft({
    type = 'fuel',
    recipe = 'everness:door_bamboo',
    burntime = 14,
})

minetest.register_craft({
    type = 'fuel',
    recipe = 'everness:baobab_wood',
    burntime = 8,
})

minetest.register_craft({
    type = 'fuel',
    recipe = 'everness:sequoia_wood',
    burntime = 6,
})

minetest.register_craft({
    type = 'fuel',
    recipe = 'everness:sulfur_stone',
    burntime = 370,
})

minetest.register_craft({
    type = 'fuel',
    recipe = 'everness:lotus_leaf_3',
    burntime = 1,
})

--
-- Cooking recipes
--

minetest.register_craft({
    type = 'cooking',
    output = 'everness:glass',
    recipe = 'group:everness_sand',
})

minetest.register_craft({
    type = 'cooking',
    output = 'everness:coral_desert_stone',
    recipe = 'everness:coral_desert_cobble',
})

minetest.register_craft({
    type = 'cooking',
    output = 'everness:coral_desert_stone',
    recipe = 'everness:coral_desert_mossy_cobble',
})

minetest.register_craft({
    type = 'cooking',
    output = 'everness:forsaken_tundra_stone',
    recipe = 'everness:forsaken_tundra_cobble',
})

minetest.register_craft({
    type = 'cooking',
    output = 'everness:mineral_cave_stone',
    recipe = 'everness:mineral_cave_cobblestone',
})

minetest.register_craft({
    type = 'cooking',
    output = 'everness:mineral_lava_stone',
    recipe = 'everness:mineral_lava_stone_dry',
})

minetest.register_craft({
    type = 'cooking',
    output = 'everness:bamboo_dry_block',
    recipe = 'everness:bamboo_block',
})

minetest.register_craft({
    type = 'cooking',
    output = 'everness:baobab_fruit_roasted',
    recipe = 'everness:baobab_fruit',
})

minetest.register_craft({
    type = 'cooking',
    output = 'everness:pyriteblock_forged',
    recipe = 'everness:pyriteblock',
})

minetest.register_craft({
    type = 'cooking',
    output = 'everness:forsaken_desert_stone',
    recipe = 'everness:forsaken_desert_cobble_red',
})

minetest.register_craft({
    type = 'cooking',
    output = 'everness:cursed_stone_carved',
    recipe = 'everness:cursed_stone',
})

minetest.register_craft({
    type = 'cooking',
    output = 'everness:crystal_stone',
    recipe = 'everness:crystal_cobble',
})

minetest.register_craft({
    type = 'cooking',
    output = 'everness:crystal_stone',
    recipe = 'everness:crystal_mossy_cobble',
})

minetest.register_craft({
    type = 'cooking',
    output = 'everness:mineral_stone',
    recipe = 'everness:mineral_stone_cobble',
})

minetest.register_craft({
    type = 'cooking',
    output = 'everness:lotus_leaf_3',
    recipe = 'everness:lotus_leaf',
})

minetest.register_craft({
    type = 'cooking',
    output = 'everness:lotus_leaf_3',
    recipe = 'everness:lotus_leaf_2',
})

--
-- Saplings
--

minetest.register_craft({
    output = 'everness:coral_tree_bioluminescent_sapling',
    recipe = {
        { 'group:lantern' },
        { 'everness:coral_tree_sapling' },
    }
})

minetest.register_craft({
    output = 'everness:cursed_dream_tree_sapling',
    recipe = {
        { 'group:lantern' },
        { 'everness:dry_tree_sapling' },
    }
})

minetest.register_craft({
    output = 'everness:crystal_tree_large_sapling',
    recipe = {
        { 'everness:crystal_tree_sapling', 'everness:crystal_tree_sapling' },
        { 'everness:crystal_tree_sapling', 'everness:crystal_tree_sapling' }
    }
})
