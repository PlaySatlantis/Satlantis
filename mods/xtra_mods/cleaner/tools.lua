
--- Cleaner Tools
--
--  @topic tools


local S = core.get_translator(cleaner.modname)


local aux = dofile(cleaner.modpath .. "/misc_functions.lua")

--- Master Pencil
--
--  @tool cleaner:pencil
--  @img cleaner_pencil.png
--  @priv server
--  @usage
--  place (right-click):
--  - when not pointing at a node, changes modes
--  - when pointing at a node, sets node to be used
--
--  use (left-click):
--  - executes action for current mode:
--    - erase: erases pointed node
--    - write: adds node
--    - swap:  replaces pointed node
core.register_tool(cleaner.modname .. ":pencil", {
	description = S("Master Pencil"),
	inventory_image = "cleaner_pencil.png",
	liquids_pointable = true,
	on_use = aux.tool.on_use,
	on_secondary_use = aux.tool.on_secondary_use,
	on_place = aux.tool.on_place,
})

core.register_tool(cleaner.modname .. ":pencil_1", {
	description = S("Master Pencil"),
	inventory_image = "cleaner_pencil.png^[transformFXFY",
	liquids_pointable = true,
	groups = {not_in_creative_inventory=1},
	on_use = aux.tool.on_use,
	on_secondary_use = aux.tool.on_secondary_use,
	on_place = aux.tool.on_place,
})
