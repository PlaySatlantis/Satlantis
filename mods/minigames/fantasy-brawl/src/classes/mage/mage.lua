local S = fbrawl.T
local NS = function(s) return s end


fbrawl.register_class("mage", {
   name = NS("Mage"),
   description = S("Wanna crush them with meteors? Pew pew them with bubbles from far away? Then the mage is for you."),
   icon = "fbrawl_mage_icon.png",
   physics_override = {
      speed = 1.6,
   },
   weapon = "fantasy_brawl:mage_staff",
   skills = {
      RMB = "fbrawl:ice_spikes", 
      LMB = "fbrawl:bubble_beam", 
      SNEAK = "fbrawl:fire_sprint", 
      Q = "fbrawl:gaia_fist", 
      ZOOM = "fbrawl:cry_of_gaia"
   },
   hp_regen_rate = 2.7
})



dofile(minetest.get_modpath("fantasy_brawl") .. "/src/classes/mage/skills/bubble_beam.lua")
dofile(minetest.get_modpath("fantasy_brawl") .. "/src/classes/mage/skills/ice_spikes.lua")
dofile(minetest.get_modpath("fantasy_brawl") .. "/src/classes/mage/skills/fire_sprint.lua")
dofile(minetest.get_modpath("fantasy_brawl") .. "/src/classes/mage/skills/cry_of_gaia.lua")
dofile(minetest.get_modpath("fantasy_brawl") .. "/src/classes/mage/skills/gaia_fist.lua")

dofile(minetest.get_modpath("fantasy_brawl") .. "/src/classes/mage/items.lua")
