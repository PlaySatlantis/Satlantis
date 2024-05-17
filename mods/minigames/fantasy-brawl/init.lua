fbrawl = {}
fbrawl.T = minetest.get_translator("fantasy_brawl")


dofile(minetest.get_modpath("fantasy_brawl") .. "/src/SETTINGS.lua")


arena_lib.register_minigame("fantasy_brawl", {
  prefix = fbrawl_settings.prefix,
  icon = "fbrawl_icon.png",
  temp_properties = {
    classes = {},  -- pl_name: string = class: {}
    match_started = false,
    scores = {}  -- pl_name: string = score: number
  },
  player_properties = {
    kills = 0,
    deaths = 0,
    ultimate_recharge = 0,
    hit_by = {}, -- {"player1" = <damage>, ...}
    is_invulnerable = false
  },
  hotbar = {
    slots = 1,
    background_image = "fbrawl_transparent.png",
    selected_image = "fbrawl_transparent.png"
  },
  hud_flags = {
    healthbar = false
  },
  disabled_damage_types = {"fall"},
  load_time = fbrawl_settings.loading_time,
  show_nametags = false,
  show_minimap = false,
  celebration_time = fbrawl_settings.celebration_time,
  time_mode = "decremental",
  join_while_in_progress = true,
  can_drop = false,
})



dofile(minetest.get_modpath("fantasy_brawl") .. "/src/deps/visible_wielditem.lua")

dofile(minetest.get_modpath("fantasy_brawl") .. "/src/hud/hud.lua")
dofile(minetest.get_modpath("fantasy_brawl") .. "/src/sounds.lua")
dofile(minetest.get_modpath("fantasy_brawl") .. "/src/score.lua")
dofile(minetest.get_modpath("fantasy_brawl") .. "/src/invulnerability.lua")

dofile(minetest.get_modpath("fantasy_brawl") .. "/src/utils.lua")
dofile(minetest.get_modpath("fantasy_brawl") .. "/src/blood_effect.lua")
dofile(minetest.get_modpath("fantasy_brawl") .. "/src/health_bar.lua")

dofile(minetest.get_modpath("fantasy_brawl") .. "/src/classes/skill_layers/proxy_layer.lua")
dofile(minetest.get_modpath("fantasy_brawl") .. "/src/classes/skill_layers/ultimate_layer.lua")

dofile(minetest.get_modpath("fantasy_brawl") .. "/src/classes/skill_proxies/item_proxy.lua")
dofile(minetest.get_modpath("fantasy_brawl") .. "/src/classes/skill_proxies/aoe_proxy.lua")

dofile(minetest.get_modpath("fantasy_brawl") .. "/src/respawn/respawn.lua")

dofile(minetest.get_modpath("fantasy_brawl") .. "/src/classes/controls.lua")
dofile(minetest.get_modpath("fantasy_brawl") .. "/src/classes/classes_system.lua")
dofile(minetest.get_modpath("fantasy_brawl") .. "/src/classes/skill_layers/meteors_layer.lua")
dofile(minetest.get_modpath("fantasy_brawl") .. "/src/classes/class_selector_formspec.lua")
dofile(minetest.get_modpath("fantasy_brawl") .. "/src/classes/hp_regen.lua")
dofile(minetest.get_modpath("fantasy_brawl") .. "/src/classes/book_pedestal.lua")

dofile(minetest.get_modpath("fantasy_brawl") .. "/src/arena_lib/callbacks.lua")
dofile(minetest.get_modpath("fantasy_brawl") .. "/src/arena_lib/utils.lua")

dofile(minetest.get_modpath("fantasy_brawl") .. "/src/classes/warrior/warrior.lua")
dofile(minetest.get_modpath("fantasy_brawl") .. "/src/classes/mage/mage.lua")
--dofile(minetest.get_modpath("fantasy_brawl") .. "/src/classes/infector/infector.lua")

--dofile(minetest.get_modpath("fantasy_brawl") .. "/src/debug/debug_cmds.lua")
--dofile(minetest.get_modpath("fantasy_brawl") .. "/src/debug/temp_entity.lua")
