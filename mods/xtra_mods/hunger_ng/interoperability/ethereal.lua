-- Ethereal
--
-- Author  TenPlus1
-- Forums  https://forum.minetest.net/viewtopic.php?t=14638
-- VCS     https://notabug.org/TenPlus1/ethereal


local add = hunger_ng.add_hunger_data

-- fishing.lua
add('ethereal:fish_raw',         { satiates = 1 })
add('ethereal:fish_cooked',      { satiates = 2.5 })
add('ethereal:sashimi',          { satiates = 2 })

-- food.lua
add('ethereal:banana',           { satiates = 1.5 })
add('ethereal:banana_bunch',     { satiates = 4.5 })
add('ethereal:orange',           { satiates = 2 })
add('ethereal:pine_nuts',        { satiates = 0.5 })
add('ethereal:banana_bread',     { satiates = 6 })
add('ethereal:coconut_slice',    { satiates = 0.5 })
add('ethereal:golden_apple',     { satiates = 10, heals = 10 })
add('ethereal:hearty_stew',      { satiates = 7, returns = 'ethereal:bowl' })
add('ethereal:bucket_cactus',    { satiates = 1, returns = 'bucket:bucket_empty' })
add('ethereal:firethorn_jelly',  { satiates = 1, returns = 'vessels:glass_bottle' })
add('ethereal:lemon',            { satiates = 3 })
add('ethereal:candied_lemon',    { satiates = 5 })
add('ethereal:olive',            { satiates = 1 })

-- leaves.lua
add('ethereal:yellowleaves',     { satiates = 0.5 })

-- mushroom.lua
add('ethereal:mushroom_soup',    { satiates = 2.5, returns = 'ethereal:bowl' })

-- onion.lua
add('ethereal:wild_onion_plant', { satiates = 1.5, heals = -1 })

-- plantlife.lua
add('ethereal:fern_tubers',      { satiates = 0.5 })

-- sapling.lua
add('ethereal:bamboo_sprout',    { satiates = 1 })

-- sealife.lua
add('ethereal:seaweed',          { satiates = 0.5 })

-- strawberry.lua
add('ethereal:strawberry',       { satiates = 0.5 })
