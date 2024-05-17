-- Berry Bushes
--
-- Author  jordan4ibanez
-- Forums  https://forum.minetest.net/viewtopic.php?t=14068
-- VCS     No VCS provided


local add = hunger_ng.add_hunger_data

local berries = {
    'raspberry',
    'blackberry',
    'gooseberry',
    'strawberry',
    'mixed_berry',
    'blueberry'
}

for _,berry in pairs(berries) do
    add('bushes:'..berry..'_pie_raw', { satiates = 2, heals = -2 })
    add('bushes:'..berry..'_pie_cooked', { satiates = 5 })
    add('bushes:'..berry..'_pie_slice', { satiates = 0.8 })
    add('bushes:'..berry, { satiates = 0.5 })
end
