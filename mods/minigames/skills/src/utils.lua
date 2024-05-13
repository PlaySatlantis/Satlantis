function skills.error(pl_name, msg)
	minetest.chat_send_player(pl_name, minetest.colorize("#f47e1b", "[!] " .. msg))
	minetest.sound_play("skills_error", {to_player = pl_name})
end


function skills.print(pl_name, msg)
	minetest.chat_send_player(pl_name, msg)
end



function skills.override_params(original, new)
	local output = table.copy(original)

   for key, new_value in pairs(new) do
		if new_value == "@@nil" then new_value = nil end

		if type(new_value) == "table" and output[key] then
			output[key] = skills.override_params(output[key], new_value)
		elseif type(new_value) ~= "function" then
			output[key] = new_value
		elseif not original[key] then
			output[key] = new_value
		end
   end

	return output
end



function skills.block_other_skills(skill)
   for skill_name, def in pairs(skills.get_unlocked_skills(skill.pl_name)) do
		if def.can_be_blocked_by_other_skills and skill_name ~= skill.internal_name then
      	skill.pl_name:stop_skill(skill_name)
		end
   end
end



function skills.cast_passive_skills(pl_name)
	for name, def in pairs(skills.get_unlocked_skills(pl_name)) do
		if def.passive and def.data._enabled then
			pl_name:start_skill(name)
		end
	end
end