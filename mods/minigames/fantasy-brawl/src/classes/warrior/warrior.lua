local S = fbrawl.T
local NS = function(s) return s end


fbrawl.register_class("warrior", {
   name = NS("Warrior"),
   icon = "fbrawl_warrior_icon.png",
   description = S("Punch them with your fists and finish them with your sword! If you want some melee combat, the warrior's for you."),
   physics_override = {
      speed = 2.2,
      gravity = 0.9
   },
   weapon = "fantasy_brawl:sword_steel",
   skills = {
      LMB = "fbrawl:sword_steel",
      RMB = "fbrawl:death_twirl", 
      SNEAK = "fbrawl:warrior_jump", 
      Q = "fbrawl:iron_skin", 
      ZOOM = "fbrawl:hero_fury"
   },
   hp_regen_rate = 1.2
})

dofile(minetest.get_modpath("fantasy_brawl") .. "/src/classes/warrior/items.lua")
dofile(minetest.get_modpath("fantasy_brawl") .. "/src/classes/warrior/skills/death_twirl.lua")
dofile(minetest.get_modpath("fantasy_brawl") .. "/src/classes/warrior/skills/sword.lua")
dofile(minetest.get_modpath("fantasy_brawl") .. "/src/classes/warrior/skills/warrior_jump.lua")
dofile(minetest.get_modpath("fantasy_brawl") .. "/src/classes/warrior/skills/iron_skin.lua")
dofile(minetest.get_modpath("fantasy_brawl") .. "/src/classes/warrior/skills/hero_fury.lua")
