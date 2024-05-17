local S = minetest.get_translator("arena_lib")

local function get_weather_formspec() end
local function colstr() end
local function set_temp_particles() end

local temp_particles = {}                       -- KEY: p_name; VALUE: { ID, particles, col }
local curr_section = {}
local palette_str, palette_id = arena_lib.get_palette_col_and_sorted_table()    -- palette id KEY = hex value; VALUE = id



minetest.register_tool("arena_lib:customise_weather", {
    description = S("Weather condition"),
    inventory_image = "arenalib_customise_weather.png",
    groups = {not_in_creative_inventory = 1},
    on_place = function() end,
    on_drop = function() end,

    on_use = function(itemstack, user, pointed_thing)
      local mod         = user:get_meta():get_string("arena_lib_editor.mod")
      local arena_name  = user:get_meta():get_string("arena_lib_editor.arena")
      local _, arena    = arena_lib.get_arena_by_name(mod, arena_name)
      local p_name      = user:get_player_name()

      temp_particles[p_name] = {}
      curr_section[p_name] = "rain"

      if arena.weather then
        arena_lib.set_editor_particlespawner(p_name, nil)

        local particles = arena.weather
        local texture = particles.texture.name

        particles.playername = p_name
        particles.attached = user
        temp_particles[p_name].ID = minetest.add_particlespawner(arena.weather)
        temp_particles[p_name].particles = arena.weather
        temp_particles[p_name].amount = particles.amount / 500    -- ogni quantità è amount * 5 (qui) * 100 (API)

        if texture == "arenalib_particle_snow.png" then
          curr_section[p_name] = "snow"
        elseif string.match(texture, "arenalib_particle_dust.png") then
          curr_section[p_name] = "dust"
        end
      end

      minetest.show_formspec(p_name, "arena_lib:weather", get_weather_formspec(p_name, curr_section[p_name]))
    end
})





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function get_weather_formspec(p_name, section)
  local colour = ""
  if section == "dust" then
    colour = "label[0,2.35;" .. S("Colour") .. "]dropdown[1.35,2.05;2.9,0.6;dust_col;" .. palette_str .. ";" .. (palette_id[colstr(temp_particles[p_name].col)] or 1) ..  "]"
  end

  local formspec = {
    "formspec_version[4]",
    "size[6.2,6.9]",
    "bgcolor[;neither]",
    "no_prepend[]",
    "style_type[image_button;border=false]",
    "scrollbaroptions[min=1;max=3;arrows=hide]",
    "container[1,1]",
    "tooltip[rain_btn;" .. S("Rain") .."]",
    "tooltip[snow_btn;" .. S("Snow") .."]",
    "tooltip[dust_btn;" .. S("Dust") .."]",
    "image_button[0,0;1,1;arenalib_weather_rain.png" .. (section == "rain" and "^[multiply:#777777" or "") .. ";rain_btn;]",
    "image_button[1.6,0;1,1;arenalib_weather_snow.png" .. (section == "snow" and "^[multiply:#777777" or "") .. ";snow_btn;]",
    "image_button[3.2,0;1,1;arenalib_weather_dust.png" .. (section == "dust" and "^[multiply:#777777" or "") .. ";dust_btn;]",
    "container_end[]",
    "container[1,1.8]",
    "label[0,1;" .. S("Strength") .. "]",
    "label[0,1.5;1]",
    "label[4,1.5;3]",
    "scrollbar[0.3,1.35;3.55,0.3;horizontal;strength;" .. (temp_particles[p_name].amount or 2) .. "]",
    colour,
    "button[0,3.6;1.9,0.7;reset;" .. S("Reset") .."]",
    "button[2.2,3.6;1.9,0.7;apply;" .. S("Apply") .."]",
    "container_end[]",
  }

  return table.concat(formspec, "")
end



function colstr(col)
  if type(col) == "table" then
    return minetest.rgba(col.r, col.g, col.b)
  else
    return col
  end
end



function set_temp_particles(p_name)
  local particles_data = temp_particles[p_name].particles

  if temp_particles[p_name].ID then
    minetest.delete_particlespawner(temp_particles[p_name].ID)
  end

  local particles = {
    amount = 100 * particles_data.amount,
    time = 0,
    pos = {
      min = {x = -50, y = particles_data.height - 3.5, z = -50},
      max = {x = 50, y = particles_data.height + 3.5, z = 50}
    },
    vel = {
      min = vector.new(0, particles_data.vel - 0.15, 0),
      max = vector.new(0, particles_data.vel + 0.15, 0),
    },
    minsize = particles_data.scale - 1.5,
    maxsize = particles_data.scale + 1.5,
    texture = {
      name = particles_data.texture,
      alpha_tween = particles_data.opacity,
      scale_tween = {
        {x = 1, y = 1},
        {x = 0.2, y = 0.2},
      },
    },
    collisiondetection = particles_data.collide,
    collision_removal = particles_data.remove_on_coll,
    minexptime = 3,
    maxexptime = 5,
  }

  particles.playername = p_name
  particles.attached = minetest.get_player_by_name(p_name)

  temp_particles[p_name].ID = minetest.add_particlespawner(particles)
end





----------------------------------------------
---------------GESTIONE CAMPI-----------------
----------------------------------------------

minetest.register_on_player_receive_fields(function(player, formname, fields)
  if formname ~= "arena_lib:weather" then return end

  local p_name = player:get_player_name()
  local mod         = player:get_meta():get_string("arena_lib_editor.mod")
  local arena_name  = player:get_meta():get_string("arena_lib_editor.arena")
  local _, arena    = arena_lib.get_arena_by_name(mod, arena_name)

  -- se abbandona...
  if fields.quit then
    minetest.delete_particlespawner(temp_particles[p_name].ID or -1)

    if arena.weather then
      local particles = table.copy(arena.weather)

      particles.playername = p_name
      particles.attached = player
      arena_lib.set_editor_particlespawner(p_name, minetest.add_particlespawner(particles))
    end

    temp_particles[p_name] = nil
    curr_section[p_name] = nil
    return

  -- ...o se ripristina, non c'è bisogno di andare oltre
  elseif fields.reset then
    arena_lib.set_weather_condition(p_name, mod, arena_name, nil, true)
    arena_lib.set_editor_particlespawner(p_name, nil)
    minetest.delete_particlespawner(temp_particles[p_name].ID or -1)
    temp_particles[p_name] = {}

    -- TEMP MT 5.9: close e after da rimuovere grazie a https://github.com/minetest/minetest/pull/14010
    minetest.close_formspec(p_name, "arena_lib:weather")

    -- riapro il formspec sul quale mi trovavo
    minetest.after(0.1, function()
      minetest.show_formspec(p_name, "arena_lib:weather", get_weather_formspec(p_name, curr_section[p_name]))
    end)
    return
  end

  -- cambio sezione
  if fields.rain_btn and curr_section[p_name] ~= "rain" then
    curr_section[p_name] = "rain"
    minetest.show_formspec(p_name, "arena_lib:weather", get_weather_formspec(p_name, curr_section[p_name]))
  elseif fields.snow_btn and curr_section[p_name] ~= "snow" then
    curr_section[p_name] = "snow"
    minetest.show_formspec(p_name, "arena_lib:weather", get_weather_formspec(p_name, curr_section[p_name]))
  elseif fields.dust_btn and curr_section[p_name] ~= "dust" then
    curr_section[p_name] = "dust"
    minetest.show_formspec(p_name, "arena_lib:weather", get_weather_formspec(p_name, curr_section[p_name]))
  end

  -- aggiorno i parametri
  temp_particles[p_name].amount = minetest.explode_scrollbar_event(fields.strength).value

  if fields.dust_col and fields.dust_col ~= "___" then
    temp_particles[p_name].col = arena_lib.PALETTE[fields.dust_col]
  end

  local strength = temp_particles[p_name].amount
  local amount = temp_particles[p_name].amount * 5

  -- crea definizione tabella
  if curr_section[p_name] == "rain" then
    temp_particles[p_name].particles = {
      texture = "arenalib_particle_rain.png",
      height = 22.5,
      amount = amount,
      vel = -20,
      scale = 3,
      opacity = {0.3 * strength, 1},
      collide = true,
      remove_on_coll = true
    }
  elseif curr_section[p_name] == "snow" then
    temp_particles[p_name].particles = {
      texture = "arenalib_particle_snow.png",
      height = 22.5,
      amount = amount,
      vel = -5.5,
      scale = 1.5 * strength,
      opacity = {0.5, 1},
      collide = true
    }
  else
    local multiply = temp_particles[p_name].col or "#FFFFFF"
    temp_particles[p_name].particles = {
      texture = "arenalib_particle_dust.png^[multiply:" .. multiply,
      height = 3,
      amount = amount,
      vel = -0.25,
      scale = 0.35 * strength,
      opacity = {0.4, 1}
    }
  end

  if fields.apply then
    local particle_copy = table.copy(temp_particles[p_name].particles)
    particle_copy.playername = nil
    particle_copy.attached = nil
    arena_lib.set_weather_condition(p_name, mod, arena_name, particle_copy, true)
  end

  -- imposto
  set_temp_particles(p_name)
end)