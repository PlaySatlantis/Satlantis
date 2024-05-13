skills.register_skill_based_on("fbrawl:acid_spray", "fbrawl:blood_spray", {
	name = "Blood Spray",
	attachments = {
		particles = {{
			texture = {
				name = "fbrawl_blood_particle.png",
				animation = "@@nil",
			},
			minsize = 2,
			maxsize = 4,
		}},
		hud = {{
			name = "blood",
			hud_elem_type = "image",
			text = "fbrawl_blood_spray.png",
			scale = {x=3, y=3},
			position = {x=0.5, y=0.82},
		}}
	},
	dmg_multiplier = 4.5,
	cooldown = 10,
	loop_params = {
		duration = 1.5
	}
})



controls.register_on_release(function(player, control_name)
	local pl_name = player:get_player_name()
	local blood_spray = pl_name:get_skill("fbrawl:blood_spray")

   if blood_spray and blood_spray.is_active and control_name == "LMB" then
      pl_name:stop_skill("fbrawl:blood_spray")
   end
end)
