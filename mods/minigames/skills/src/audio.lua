local function init_sound(skill, sound) end



function skills.is_sound_pool(sound_or_pool)
	if not sound_or_pool then return false end
	
	if sound_or_pool.name then
		return false
	else
		return true
	end
end



function skills.sound_play(skill, sound_or_pool, ephemeral)
	local handles = {}
	if not sound_or_pool then return end

	if not skills.is_sound_pool(sound_or_pool) then
		handles[1] = skills.sound_play_logic(init_sound(skill, sound_or_pool), ephemeral)

	-- multiple sounds
	else
		for _, sound in ipairs(sound_or_pool) do
			table.insert(handles, skills.sound_play_logic(init_sound(skill, sound)))
		end
	end

	return handles
end



function skills.sound_stop(handles)
	if not handles then return end
	for _, handle in ipairs(handles) do
		skills.sound_stop_logic(handle)
	end
end



-------------------------
-- DEFAULT SOUND LOGIC --
-------------------------

function skills.sound_play_logic(sound, ephemeral)
	return minetest.sound_play(sound, sound, ephemeral)
end

function skills.sound_stop_logic(handle)
	minetest.sound_stop(handle)
end

-------------------------
-------------------------
-------------------------



function init_sound(skill, sound)
	sound.pos = skill.player:get_pos()
	if sound.object == nil then
		sound.object = true
	end

	if sound.to_player then sound.to_player = skill.pl_name end
	if sound.object then sound.object = skill.player end
	if sound.exclude_player then sound.exclude_player = skill.pl_name end
	if sound.random_pitch then
		local min = sound.random_pitch[1] * 100
		local max = sound.random_pitch[2] * 100
		sound.pitch = math.floor(math.random() * (max - min + 1) + min) / 100
	end

	return sound
end
