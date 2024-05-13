-- used for areas
local dummy = {
  initial_properties = {
    physical = false,
    visual = "sprite",
    visual_size = {x = 0, y = 0, z = 0},
    collisionbox = {0, 0, 0, 0, 0, 0},

    textures = { "blank.png" }
  }
}

minetest.register_entity("arena_lib:spectate_dummy", dummy)
