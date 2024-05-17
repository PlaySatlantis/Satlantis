--!
--! DON'T TOUCH THIS.
--!
--! if you want to modify any of these settings just edit the file in <YOUR_WORLD_FOLDER>/phone_rewards/



phone_rewards.premium_priv = "premium"
phone_rewards.points_to_levelup = 50

--[[
	STRUCTURE:
	[level] = {
		normal = {
			type = "skin" / "item",
			value = "skin_1" / "default:diamonds 10"
		},
		premium = {
			type = "skin" / "item",
			value = "skin_1" / "default:diamonds 50"
		}
	},
	...
]]
phone_rewards.rewards = {
	[1] = {
		normal = {
			type = "item",
			value = "default:dirt 20"
		},
		premium = {
			type = "skin",
			value = "default_2_3"
		}
	},
	[2] = {
		normal = {
			type = "item",
			value = "default:dirt_with_grass 10"
		},
		premium = {
			type = "item",
			value = "default:dirt_with_grass 25"
		}
	},
	[3] = {
		normal = {
			type = "item",
			value = "default:dirt_with_grass 15"
		},
		premium = {
			type = "item",
			value = "default:dirt_with_grass 45"
		}
	},
}