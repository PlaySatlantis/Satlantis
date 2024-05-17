function fbrawl.generate_stats(player, pl_name)
	local stats_bg
	local kills
	local deaths
	local status_pointer
 
	stats_bg = player:hud_add({
	  hud_elem_type = "image",
	  position  = {x = 1, y = 0.5},
	  offset = {x = -25*3 + -25*2/3, y = 0},
	  text      = "fbrawl_hud_stats.png",
	  alignment = { x = 1, y=0.5},
	  scale     = { x = 3, y = 3},
	  number    = 0xFFFFFF,
	})
 
	kills = player:hud_add({
	  hud_elem_type = "text",
	  position  = {x = 1, y = 0.5},
	  offset = {x = -53, y = 27},
	  text      = 0,
	  number    = 0xFFFFFF,
	})
 
	deaths = player:hud_add({
	  hud_elem_type = "text",
	  position  = {x = 1, y = 0.5},
	  offset = {x = -53, y = 107.5},
	  text      = 0,
	  number    = 0xFFFFFF,
	})
 
	status_pointer = player:hud_add({
	  name = "pointer_status",
	  hud_elem_type = "image",
	  text = "fbrawl_transparent.png",
	  position = {x=0.5, y=0.5},
	  offset = {x=-18.75, y = 0},
	  scale = {x=2.5, y=2.5},
	  alignment = {x=0.5, y=0.5},
	})
 
	fbrawl.saved_huds[pl_name] = skills.override_params(fbrawl.saved_huds[pl_name], {
	  stats_bg = stats_bg,
	  kills = kills,
	  deaths = deaths,
	  status_pointer = status_pointer,
	})
 end