local function change_celestial_vault(skill) end
local T = minetest.get_translator("skills")
local get_player_by_name = minetest.get_player_by_name



function skills.start(self, def, ...)
	local attachments = self.attachments
	local loop_params = self.loop_params
	local sounds = self.sounds
	local data = self.data

	if
		not skills.basic_checks_in_order_to_cast(self)
		or (not loop_params and not def.on_start and not def.on_stop)
		or self.is_active
	then
		return false
	end

	if self.cooldown_timer > 0 then
		skills.print_remaining_cooldown_seconds(self)
		return false
	end

	self.is_active = true

	-- Create particle spawners
	if attachments.particles then
		data._particles = {}

		for i, spawner in ipairs(attachments.particles) do
			spawner.attached = self.player
			data._particles[i] = minetest.add_particlespawner(spawner)
		end
	end

	-- Create hud
	if self.hud then
		data._hud = {}

		for i, hud_element in ipairs(self.hud) do
			local name = hud_element.name
			data._hud[name] = self.player:hud_add(hud_element)
		end
	end

	-- Attach entities
	if attachments.entities then
		for i, entity_def in ipairs(attachments.entities) do
			skills.attach_expiring_entity(self, entity_def)
		end
	end

	-- Change physics_override
	if self.physics then
		local operation = self.physics.operation -- multiply/divide/add/sub

		for property, value in pairs(self.physics) do
			if property ~= "operation" then
				_G["skills"][operation.."_physics"](self.pl_name, property, value)
			end
		end
	end

	if self:on_start(...) == false then
		self:stop("cancelled")
		return false
	end

	change_celestial_vault(self)

	if self.blocks_other_skills then
		skills.blocking_skills[self.pl_name] = self.internal_name
		skills.block_other_skills(self)
	end

	-- Play sounds
	skills.sound_play(self, sounds.start, true)
	data._bgm = skills.sound_play(self, sounds.bgm)

	-- Stop skill after duration
	if loop_params and loop_params.duration then
		minetest.after(loop_params.duration, function() self:stop() end)
	end

	skills.start_cooldown(self)

	if loop_params and loop_params.cast_rate then
		self:cast(...)
	end

	return true
end



function change_celestial_vault(skill)
	local cel_vault = skill.celestial_vault or {}
	local data = skill.data

	-- Change sky
	if cel_vault.sky then
		local pl = skill.player
		data._sky = pl:get_sky(true)
		pl:set_sky(cel_vault.sky)
	end

	-- Change moon
	if cel_vault.moon then
		local pl = skill.player
		data._moon = pl:get_moon()
		pl:set_moon(cel_vault.moon)
	end

	-- Change sun
	if cel_vault.sun then
		local pl = skill.player
		data._sun = pl:get_sun()
		pl:set_sun(cel_vault.sun)
	end

	-- Change stars
	if cel_vault.stars then
		local pl = skill.player
		data._stars = pl:get_stars()
		pl:set_stars(cel_vault.stars)
	end

	-- Change clouds
	if cel_vault.clouds then
		local pl = skill.player
		data._clouds = pl:get_clouds()
		pl:set_clouds(cel_vault.clouds)
	end
end
