awards.register_on_unlock(function(p_name, def)
	phone_rewards.add_points(p_name, def.points or 0)
end)