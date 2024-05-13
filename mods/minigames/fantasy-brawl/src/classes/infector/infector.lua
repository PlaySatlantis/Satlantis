local S = fbrawl.T



fbrawl.register_class("Infector", {
   name = "Infector",
   description = S("Do you want to ssslither at their back and shower them with poison? Make the ground they're walkin' an acid pool? Then, for you, there's nothing better than Infector."),
   icon = "fbrawl_infector_icon.png",
   physics_override = {
      speed = 1.8,
   },
   weapon = "fantasy_brawl:acid_spray",
   skills = {
      LMB = "fbrawl:acid_spray", 
      RMB = "fbrawl:blood_spray", 
      SNEAK = "fbrawl:gaia_fist",
      Q = "fbrawl:gaia_fist", 
      ZOOM = "fbrawl:cry_of_gaia"
   },
   hp_regen_rate = 1
})


dofile(minetest.get_modpath("fantasy_brawl") .. "/src/classes/infector/skills/acid_spray.lua")
dofile(minetest.get_modpath("fantasy_brawl") .. "/src/classes/infector/skills/blood_spray.lua")

dofile(minetest.get_modpath("fantasy_brawl") .. "/src/classes/infector/items.lua")

