-- I had no idea how to do it, so, uhm... this is how Minetest handles callbacks
local function make_registration()
  local t = {}
  local registerfunc = function(func)
    t[#t+1] = func
  end
  return t, registerfunc
end

collectible_skins.registered_on_set_skin, collectible_skins.register_on_set_skin = make_registration()
