local delete_particlespawner = minetest.delete_particlespawner
local add_particlespawner = minetest.add_particlespawner
local vec_equals = vector.equals
local vec_distance = vector.distance



local function generate_hud(skill, args)
	local waypoint = fbrawl.get_hud(skill.pl_name, "waypoint")
	local waypoint_table = skill.player:hud_get(waypoint)
	local ray = fbrawl.look_raycast(skill.player, args.max_range)
	local pos = ray:next() or {}
	pos = pos.above
	local particlespawner = args.particlespawner

	if pos and not vec_equals(waypoint_table.world_pos, pos) then
		local scale = 62 / vec_distance(pos, skill.player:get_pos())

		skill.player:hud_change(waypoint, "text", args.pointer_texture)
		skill.player:hud_change(waypoint, "scale", {x=scale, y=scale})
		skill.player:hud_change(waypoint, "world_pos", pos)

		if skill.data.particlespawner then
			delete_particlespawner(skill.data.particlespawner)
		end

		particlespawner.pos = pos
		particlespawner.playername = skill.pl_name
		skill.data.particlespawner = add_particlespawner(particlespawner)
	end
end


skills.register_skill_based_on("fbrawl:item_proxy", "fbrawl:aoe_proxy", {
	name = "AOE Proxy",
	data = {
		particlespawner = nil
	},

	-- args: max_range: int, particlespawner: table, pointer_texture: string

	on_start = function (self, args)
		generate_hud(self, args)
	end,
	cast = function (self, args)
		generate_hud(self, args)
	end,
	on_stop = function (self)
		local waypoint = fbrawl.get_hud(self.pl_name, "waypoint")

		if self.data.particlespawner then
			delete_particlespawner(self.data.particlespawner)
		end

		self.data.particlespawner = nil
		self.player:hud_change(waypoint, "scale", {x=0.00001, y=0.00001})
	end
})
