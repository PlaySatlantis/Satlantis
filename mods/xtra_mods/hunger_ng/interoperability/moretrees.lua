-- More Trees!
--
-- Author  VanessaE
-- Forums  https://forum.minetest.net/viewtopic.php?t=4394
-- VCS     https://gitlab.com/VanessaE/moretrees


local add = hunger_ng.add_hunger_data

-- Base items
add('moretrees:acorn',       { satiates = 1, heals = -1 })
add('moretrees:cedar_nuts',  { satiates = 1 })
add('moretrees:raw_coconut', { satiates = 1 })
add('moretrees:date',        { satiates = 1 })
add('moretrees:fir_nuts',    { satiates = 1 })
add('moretrees:spruce_nuts', { satiates = 1 })

-- Mixed base items
add('moretrees:acorn_muffin_batter', { satiates = 2, heals = -3 })
add('moretrees:date_nut_batter',     { satiates = 2, heals = -3 })

-- Processed food
add('moretrees:acorn_muffin',   { satiates = 2 })
add('moretrees:date_nut_bar',   { satiates = 5, heals = 2 })
add('moretrees:date_nut_cake',  { satiates = 5 })
add('moretrees:date_nut_snack', { satiates = 3, heals = 1 })
