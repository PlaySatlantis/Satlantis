local S = minetest.get_translator("skills")
local skills_with_cooldowns = {}



-- For each skill of each player decreases the cooldown_timer
minetest.register_globalstep(function(dtime)
	local recharged_skills = {}

	for skill_name, def in pairs(skills_with_cooldowns) do
		def.cooldown_timer = def.cooldown_timer - dtime

		if def.cooldown_timer < 0 then
			def.cooldown_timer = 0
			table.insert(recharged_skills, skill_name)
		end

	end

	for i, skill_name in ipairs(recharged_skills) do
		skills_with_cooldowns[skill_name] = nil
	end
end)



function skills.start_cooldown(skill)
	skill.cooldown_timer = skill.cooldown or 0
	skills_with_cooldowns[skill.pl_name .. ":" .. skill.internal_name] = skill
end



function skills.print_remaining_cooldown_seconds(skill)
	local remaining_seconds = math.floor(skill.cooldown_timer*10) / 10

	if skills.settings.chat_warnings.cooldown ~= false then
		skills.error(skill.pl_name, S("You have to wait @1 seconds to use this again!", remaining_seconds))
	end
end