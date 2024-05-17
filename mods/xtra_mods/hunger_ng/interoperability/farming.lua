-- Farming Redo
--
-- Author  TenPlus1
-- Forums  https://forum.minetest.net/viewtopic.php?t=9019
-- VCS     https://notabug.org/TenPlus1/Farming

local add = hunger_ng.add_hunger_data


-- `farming:bread` is also a part of the default `farming` mod. It’s texture
-- is used for the hunger bar if not specified to not doing so.
local ubi = hunger_ng.interoperability.settings.hunger_bar.force_builtin_image
if ubi == false then hunger_ng.hunger_bar_image = 'farming_bread.png' end


-- Farming bread
add('farming:bread', { satiates = 5 })


-- Edible stuff from farming Redo
add('farming:apple_pie',        { satiates = 6 })
add('farming:baked_potato',     { satiates = 6 })
add('farming:beans',            { satiates = 1 })
add('farming:beetroot',         { satiates = 0.6 })
add('farming:beetroot_soup',    { satiates = 4, returns = 'farming:bowl' })
add('farming:bibimbap',         { satiates = 8 })
add('farming:blueberries',      { satiates = 0.5 })
add('farming:blueberry_pie',    { satiates = 5 })
add('farming:bread_multigrain', { satiates = 6 })
add('farming:bread_slice',      { satiates = 1 })
add('farming:burger',           { satiates = 13 })
add('farming:cabbage',          { satiates = 1 })
add('farming:carrot',           { satiates = 2.5 })
add('farming:carrot_gold',      { satiates = 8, heals = 8 })
add('farming:chili_bowl',       { satiates = 7, returns = 'farming:bowl' })
add('farming:chili_pepper',     { satiates = 1, heals= -1 })
add('farming:chocolate_dark',   { satiates = 2 })
add('farming:cookie',           { satiates = 1 })
add('farming:corn',             { satiates = 2 })
add('farming:corn_cob',         { satiates = 4 })
add('farming:cucumber',         { satiates = 2 })
add('farming:donut',            { satiates = 2 })
add('farming:donut_apple',      { satiates = 3 })
add('farming:donut_chocolate',  { satiates = 2 })
add('farming:garlic',           { satiates = 1 })
add('farming:garlic_bread',     { satiates = 2 })
add('farming:grapes',           { satiates = 2 })
add('farming:jaffa_cake',       { satiates = 1.5 })
add('farming:lettuce',          { satiates = 2 })
add('farming:melon_slice',      { satiates = 1 })
add('farming:muffin_blueberry', { satiates = 4 })
add('farming:onion',            { satiates = 3, heals = -1 })
add('farming:onion_soup',       { satiates = 6, returns = 'farming:bowl' })
add('farming:pea_pod',          { satiates = 0.6 })
add('farming:pea_soup',         { satiates = 7, returns = 'farming:bowl' })
add('farming:peas',             { satiates = 0.5 })
add('farming:pepper',           { satiates = 2 })
add('farming:pepper_yellow',    { satiates = 3 })
add('farming:pepper_red',       { satiates = 4 })
add('farming:pineapple',        { satiates = 3 })
add('farming:pineapple_ring',   { satiates = 0.6 })
add('farming:porridge',         { satiates = 7 })
add('farming:potato',           { satiates = 0.5 })
add('farming:potato_salad',     { satiates = 3 })
add('farming:pumpkin_bread',    { satiates = 6 })
add('farming:pumpkin_slice',    { satiates = 1 })
add('farming:raspberries',      { satiates = 0.5 })
add('farming:rhubarb',          { satiates = 1 })
add('farming:rhubarb_pie',      { satiates = 5 })
add('farming:rice_bread',       { satiates = 2 })
add('farming:salad',            { satiates = 8 })
add('farming:soy_beans',        { satiates = 1 })
add('farming:spaghetti',        { satiates = 8 })
add('farming:toast',            { satiates = 1 })
add('farming:toast_sandwich',   { satiates = 2.5 })
add('farming:tomato',           { satiates = 3 })
add('farming:turkish_delight',  { satiates = 1 })
add('farming:vanilla',          { satiates = 1 })
