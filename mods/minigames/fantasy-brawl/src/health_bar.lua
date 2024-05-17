--Copyright © 2014-2020 4aiman, Hugo Locurcio and contributors
--
--Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

local function round(v)
	if 0 < v and v < 1 then return 1 end
	return math.floor(v + 0.5)
end

-- Localize this functions for better performance,
-- as it's called on every step
local vector_distance = vector.distance
local max = {
	hp = 20,
}

local mt_5 = minetest.features.object_independent_selectionbox

function fbrawl.add_hp_bar(player)
	if player and player:is_player() then
		local entity = minetest.add_entity(player:get_pos(), "fantasy_brawl:hp_bar")

		-- Check Minetest version and set required entity heigh
		-- (The entity height offset was changed in Minetest 5.0.0)
		local height = mt_5 and 19 or 9

		entity:set_attach(player, "", {x=0, y=height, z=0}, {x=0, y=0, z=0})
		entity:get_luaentity().wielder = player
	end
end

-- credit: https://github.com/minetest/minetest/blob/6de8d77e17017cd5cc7b065d42566b6b1cd076cc/builtin/game/statbars.lua#L30-L37
local function scale_to_default_hp(player)
	-- Scale "hp" to supported amount
	local current = player["get_hp"](player)
	local max_display = math.max(player:get_properties()["hp_max"], current)
	return round(current / max_display * max["hp"])
end

local add_hp = fbrawl.add_hp_bar

minetest.register_entity("fantasy_brawl:hp_bar", {
	initial_properties = {
		visual = "sprite",
		visual_size = {x=1, y=1/12, z=1},
		textures = {"blank.png"},
		collisionbox = {0},
		physical = false,
		static_save = false,
	},
	
	on_step = function(self)
		local player = self.wielder
		local hp_bar = self.object
		local arena = arena_lib.get_arena_by_player(player:get_player_name())

		if not arena then
			hp_bar:remove()
			return
		elseif vector_distance(player:get_pos(), hp_bar:get_pos()) > 3 then -- ?
			hp_bar:remove()
			add_hp(player)
			return
		end

		local hp = scale_to_default_hp(player)

		if hp == 0 or arena.players[player:get_player_name()].is_invulnerable then
			hp_bar:set_properties({
				textures = {"blank.png"}
			})
			self.hp = -1  -- forcing the check next step
			return
		end

		if self.hp ~= hp then
			local health_t = "health_"..hp..".png"
			
			hp_bar:set_properties({
				textures = {health_t}
			})

			self.hp = hp
		end
	end,

	on_deactivate = function(self, removal) 
		local player = self.wielder
		local arena = arena_lib.get_arena_by_player(player:get_player_name())

		if arena and not arena.in_celebration then add_hp(player) end
	end
})