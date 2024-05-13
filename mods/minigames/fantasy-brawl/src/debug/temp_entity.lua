minetest.register_entity("fantasy_brawl:t", {
	initial_properties = {
		visual = "cube",
		textures = {"fbrawl_hotbar_selected.png", "fbrawl_hotbar_selected.png", "fbrawl_hotbar_selected.png",
			"fbrawl_hotbar_selected.png", "fbrawl_hotbar_selected.png", "fbrawl_hotbar_selected.png"},
		static_save = false,
      visual_size = {x=1, y=1, z=1}
	},
   timer = 0,
	on_step = function(self, dtime, moveresult)
		self.timer = self.timer + dtime
		if self.timer > 0.2 then
			self.object:remove()
      end
	end
})