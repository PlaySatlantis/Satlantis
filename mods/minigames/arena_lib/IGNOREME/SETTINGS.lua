-- The entrance type that is set by default to every new arena
arena_lib.DEFAULT_ENTRANCE = "sign"

-- The physics override to apply when a player leaves a match (whether by quitting,
-- winning etc). This comes in handy for hybrid servers (i.e. survival/creative
-- ones featuring some minigames). If you're aiming for a full minigame server,
-- ignore this parameter and let the mod Hub supersede it =>
-- https://gitlab.com/zughy-friends-minetest/hub
arena_lib.SERVER_PHYSICS = {
  speed = 1,
  jump = 1,
  gravity = 1,
  speed_climb = 1,
  speed_crouch = 1,
  liquid_fluidity = 1,
  liquid_fluidity_smooth = 1,
  liquid_sink = 1,
  acceleration_default = 1,
  acceleration_air = 1,
  sneak = true,
  sneak_glitch = false,
  new_move = true
}

-- instead of letting modders put whatever colour they want in the sky settings,
-- arena_lib offers a curated palette to pick from. The palette is Zughy 32 (yes,
-- that's me) => https://lospec.com/palette-list/zughy-32. I invite you *not* to
-- edit it manually; instead, if you want to change it, pick your favourite from
-- Lospec: https://lospec.com/palette-list, edit the list and it'll be
-- automatically updated in game. Do not remove "___" and keep all letters
-- uppercase
arena_lib.PALETTE = {
  ___ = "",
  skin_espresso = "#472D3C",
  skin_cocoa = "#5E3643",
  skin_toffee = "#7A444A",
  skin_bronze = "#A05B5E",
  skin_almond = "#BF7958",
  skin_beige = "#EEA160",
  skin_vanilla = "#F4CCA1",
  green_light = "#B6D53C",
  green = "#71AA34",
  green_dark = "#397B44",
  green_deep = "#3C5956",
  black = "#302C2E",
  grey_dark = "#5A5353",
  grey = "#7D7071",
  grey_light = "#A0938E",
  grey_fog = "#CFC6B8",
  white = "#DFF6F5",
  celeste = "#8AEBF1",
  blue_sky = "#28CCDF",
  azure = "#3978A8",
  blue = "#394778",
  blue_dark = "#39314B",
  purple_dark = "#564064",
  purple = "#8E478C",
  magenta = "#CD6093",
  pink = "#FFAEB6",
  yellow = "#F4B41B",
  orange = "#F47E1B",
  red = "#E6482E",
  red_dark = "#A93B3B",
  purple_mauve = "#827094",
  blue_spruce = "#4F546B"
}

-- For minigames with map regeneration enabled. The amount of nodes to reset on
-- each step. The higher you set it the faster it'll go, but it'll also increase lag
arena_lib.RESET_NODES_PER_TICK = 40

-- When true, if a player crashes inside an arena, and the minigame they were
-- playing in allows to join whilst in progress, arena_lib will ask them if they
-- want to rejoin as soon as they reconnect (the match still has to be in progress).
-- The dialog is shown after 0.1s from the login
arena_lib.SHOW_REJOIN_DIALOG = true

-- Commands that players (admins included) won't be able to use during a match
arena_lib.BLOCKED_CMDS = {
  "clearinv",
  "pulverize"
}