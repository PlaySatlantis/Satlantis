local function restore_celestial_vault(skill) end
local table_copy = table.copy


function skills.stop(self, cancelled)
	local data = self.data

	if not self.is_active then return false end
	self.is_active = false

	if not minetest.get_player_by_name(self.pl_name) then return false end

	if self.blocks_other_skills and skills.blocking_skills[self.pl_name] == self.internal_name then
		skills.blocking_skills[self.pl_name] = nil
		skills.cast_passive_skills(self.pl_name)
	end

	-- I don't know. MT is weird or maybe my code is just bugged:
	-- without this after, if the skills ends very quickly the
	-- spawner and the sound simply... don't stop.
	local bgm = table_copy(data._bgm or {})
	local particles = table_copy(data._particles or {})
	local hud = table_copy(data._hud or {})

	minetest.after(0, function()
		-- Stop sound
		skills.sound_stop(bgm)

		-- Remove particles
		if particles then
			for i, spawner_id in pairs(particles) do
				minetest.delete_particlespawner(spawner_id)
			end
		end

		-- Remove hud
		if hud then
			for name, id in pairs(hud) do
				self.player:hud_remove(id)
			end
		end
	end)

	data._bgm = {}
	data._hud = {}
	data._particles = {}

	-- Undo physics_override changes
	if self.physics then
		local reverse = {
			["multiply"] = "divide",
			["divide"] = "multiply",
			["add"] = "sub",
			["sub"] = "add",
		}
		local operation = reverse[self.physics.operation] -- multiply/divide/add/sub

		for property, value in pairs(self.physics) do
			if property ~= "operation" then
				_G["skills"][operation.."_physics"](self.pl_name, property, value)
			end
		end
	end

	if not cancelled then
		skills.sound_play(self, self.sounds.stop, true)
		restore_celestial_vault(self)
		self:on_stop()
	end

	return true
end



function restore_celestial_vault(skill)
	local data = skill.data
	local cel_vault = skill.celestial_vault or {}

	-- Restore sky
	if cel_vault.sky and data._sky then
		local pl = skill.player
		pl:set_sky(data._sky)
		data._sky = {}
	end

	-- Restore clouds
	if cel_vault.clouds and data._clouds then
		local pl = skill.player
		pl:set_clouds(data._clouds)
		data._clouds = {}
	end

	-- Restore moon
	if cel_vault.moon and data._moon  then
		local pl = skill.player
		pl:set_moon(data._moon)
		data._moon = {}
	end

	-- Restore sun
	if cel_vault.sun and data._sun then
		local pl = skill.player
		pl:set_sun(data._sun)
		data._sun = {}
	end

	-- Restore stars
	if cel_vault.stars and data._stars then
		local pl = skill.player
		pl:set_stars(data._stars)
		data._stars = {}
	end
end