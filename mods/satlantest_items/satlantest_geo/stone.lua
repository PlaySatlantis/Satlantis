satlantis.require("stone/andesite.lua") -- "regular" stone
satlantis.require("stone/basalt.lua")
satlantis.require("stone/diorite.lua")
satlantis.require("stone/granite.lua")
satlantis.require("stone/obsidian.lua")

satlantis.register_block("geo:gravel", {
	description = "Gravel",
	tiles = {"gravel.png"},
	groups = {crumbly = 2, falling_node = 1},
	drop = {
		max_items = 1,
		items = {
			{items = {"geo:flint"}, rarity = 10},
			{items = {"geo:gravel"}}
		}
	}
})

satlantis.register_item("geo:flint", {
	description = "Flint",
	inventory_image = "flint.png"
})
