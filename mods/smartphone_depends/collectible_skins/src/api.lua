local yaml = dofile(minetest.get_modpath("collectible_skins") .. "/libs/tinyyaml.lua")
local storage = minetest.get_mod_storage()
local players_skins = {}                        -- KEY: p_name; VALUE: {skin IDs}
local loaded_skins = {}                         -- KEY: id; VALUE: {skin info}
local skin_collections = {}                     -- KEY: coll_name; VALUE: {skin IDs}
local equipped_skin = {}                        -- KEY: p_name; VALUE: skin ID
local default_skins = collectible_skins.SETTINGS.default_skins


local function register_hand_from_texture(skin_ID, texture)
	local hand_name = "collectible_skins:hand_" .. tostring(skin_ID)
	local hand_def = {}

  -- costruisco la definizione per una nuova mano prendendo le proprietà
  -- che non mi interessano e impostandole ai valori di base
	for key, value in pairs(minetest.registered_items[""]) do
		if key ~= "mod_origin" and key ~= "type" and key ~= "wield_image" then
			hand_def[key] = value
		end
	end

	hand_def.tiles = {texture}
	hand_def.visual_scale = 1
	hand_def.wield_scale = {x=4,y=4.5,z=4.5}
	hand_def.paramtype = "light"
	hand_def.drawtype = "mesh"

  hand_def.mesh = "cskins_hand.obj"

	hand_def.use_texture_alpha = "clip"
	minetest.register_node(hand_name, hand_def)
end



local function load_skins()
  local dir = minetest.get_worldpath() .. "/skins"
  local files = minetest.get_dir_list(dir, false)
  local txtr_dir = minetest.get_worldpath() .. "/skins/textures"

  for _, f_name in pairs(files) do
    if f_name:sub(-4) == ".yml" or f_name:sub(-5) == ".yaml" then
      local file = io.open(dir .. "/" .. f_name, "r")
      local skins = yaml.parse(file:read("*all"))

      for ID, skin in pairs(skins) do
        -- il decodificatore aggiunge _N ai doppioni, per diversificarli e salvarli entrambi. Tolgo quindi _ecc
        -- da eventuali cifre iniziali per vedere se già esiste (se è stringa, è errore a prescindere)
        if type(ID) == "string" then
          assert(loaded_skins[tonumber(ID:match("(%d+)_"))] == nil,  "[SKINS COLLECTIBLE] There are two or more skins with the same ID!")
          error("[SKINS COLLECTIBLE] Invalid skin ID '" .. ID .. "': numbers only!")
        end
        assert(skin.name,         "[SKINS COLLECTIBLE] Skin #" .. ID .. " has no name!")
        assert(skin.description,  "[SKINS COLLECTIBLE] Skin #" .. ID .. " has no description!")
        assert(skin.texture,      "[SKINS COLLECTIBLE] Skin #" .. ID .. " has no texture!")

        local sk_preview = ""
        local sk_splash = "blank.png"
        local sk_txtr_noprefix = string.match(skin.texture, "(.*)%.png")

        -- calcolo anteprima e splash, dato che devono corrispondere a un nome
        -- specifico (e se non trova l'anteprima, interrompo)
        for _, txtr_name in pairs(minetest.get_dir_list(txtr_dir)) do
          if     txtr_name == sk_txtr_noprefix .. "_preview.png" then sk_preview = txtr_name
          elseif txtr_name == sk_txtr_noprefix .. "_splash.png"  then sk_splash = txtr_name
          end
        end

        assert(sk_preview ~= "", "[SKINS COLLECTIBLE] Skin #" .. ID .. " has no preview!")

        local sk_collection = skin.collection or "Default"

        if not skin_collections[sk_collection] then
          skin_collections[sk_collection] = {}
        end

        skin_collections[sk_collection][ID] = true

        loaded_skins[ID] = {
          id          = ID,         -- for cross-reference
          name        = skin.name,
          description = skin.description,
          collection  = sk_collection,
          hint        = skin.hint or "(locked)",
          model       = skin.model,
          texture     = skin.texture,
          preview     = sk_preview,
          splash_art  = sk_splash,
          tier        = skin.tier or 1,
          author      = skin.author or "???",
        }

        register_hand_from_texture(ID, skin.texture)
      end

      file:close()
    end
  end
end

load_skins()



----------------------------------------------
-------------------CORPO----------------------
----------------------------------------------

function collectible_skins.load_player_data(player)
  local p_name = player:get_player_name()

  -- se il giocatore entra per la prima volta o ha perso il metadato, lo inizializzo...
  -- il controllo del metadato è l'unico modo che ho trovato di sapere se qualcuno ha usato
  -- minetest.remove_player sul giocatore.
  if storage:get_string(p_name) == "" or not player:get_meta():contains("collectible_skins:skin_ID") then
    players_skins[p_name] = {}

    -- sblocco le skin base
    for _, ID in pairs(default_skins) do
      players_skins[p_name][ID] = true
    end

    storage:set_string(p_name, minetest.serialize(players_skins[p_name]))

    -- ...e gli assegno una skin casuale
    local random_ID = math.random(#default_skins)
    collectible_skins.set_skin(player, random_ID, true, true)

  --sennò gli assegno la skin che aveva
  else
    local skin_ID = player:get_meta():get_int("collectible_skins:skin_ID")

    players_skins[p_name] = minetest.deserialize(storage:get_string(p_name))
    collectible_skins.set_skin(player, skin_ID, false, true)
  end
end



function collectible_skins.unlock_skin(p_name, skin_ID)
  -- se la skin non esiste, annullo
  if not loaded_skins[skin_ID] then
    local error = "[collectible_skins] There has been an attempt to give player " .. p_name .. " a skin that doesn't exist (ID = " .. skin_ID .. ")!"
    minetest.log("warning", error)
    return false, error end

  -- se il giocatore non si è mai connesso, annullo
  if storage:get_string(p_name) == "" then
    local error = "[SKINS COLLECTIBLE] Player " .. p_name .. " is not in the skin database (meaning the player has never connected)"
    minetest.log("warning", error)
    return false, error end

  -- se ce l'ha già, annullo
  if collectible_skins.is_skin_unlocked(p_name, skin_ID) then
    return end

  local p_skins

  -- se è online
  if minetest.get_player_by_name(p_name) then
    p_skins = players_skins[p_name]
    minetest.chat_send_player(p_name, "You've unlocked the skin " .. loaded_skins[skin_ID].name .. "!")
  -- se è offline
  else
    p_skins = minetest.deserialize(storage:get_string(p_name))
  end

  p_skins[skin_ID] = true
  storage:set_string(p_name, minetest.serialize(p_skins))
end



function collectible_skins.remove_skin(p_name, skin_ID)
  -- se la skin non esiste, annullo
  if not loaded_skins[skin_ID] then
    local error = "[collectible_skins] There has been an attempt to remove player " .. p_name .. " a skin that doesn't exist (ID = " .. skin_ID .. ")!"
    minetest.log("warning", error)
    return false, error end

  -- se il giocatore non si è mai connesso, annullo
  if storage:get_string(p_name) == "" then
    local error = "[SKINS COLLECTIBLE] Player " .. p_name .. " is not in the skin database (meaning the player has never connected)"
    minetest.log("warning", error)
    return false, error end

  -- se già gli manca, annullo
  if not collectible_skins.is_skin_unlocked(p_name, skin_ID) then
    return end

  local p_skins

  -- se è online
  if minetest.get_player_by_name(p_name) then
    p_skins = players_skins[p_name]
    minetest.chat_send_player(p_name, "Your skin " .. loaded_skins[skin_ID].name .. " has been removed...")
  -- se è offline
  else
    p_skins = minetest.deserialize(storage:get_string(p_name))
  end

  -- rimuovo
  p_skins[skin_ID] = false
  storage:set_string(p_name, minetest.serialize(p_skins))
end





----------------------------------------------
--------------------UTILS---------------------
----------------------------------------------

function collectible_skins.is_skin_unlocked(p_name, skin_ID)
  -- per controllare anche giocatori offline
  local p_skins = players_skins[p_name] or minetest.deserialize(storage:get_string(p_name))

  if p_skins and p_skins[skin_ID] then return true
  else return false end
end



function collectible_skins.does_collection_exist(collection)
  return skin_collections[collection] ~= nil
end





----------------------------------------------
-----------------GETTERS----------------------
----------------------------------------------

function collectible_skins.get_skins()
  return table.copy(loaded_skins)
end



function collectible_skins.get_skins_by_collection(collection)
  assert(skin_collections[collection], "[COLLECTIBLE SKINS] Collection '" .. collection .. "' doesn't exist!")
  local skins = {}

  for id, _ in pairs(skin_collections[collection]) do
    skins[id] = loaded_skins[id]
  end

  return table.copy(skins)
end



function collectible_skins.get_skin(skin_ID)
  return table.copy(loaded_skins[skin_ID])
end



function collectible_skins.get_portrait(skin)
  return "([combine:24x24:0,0=" .. skin.texture .. "^[mask:cskins_portraitmask.png)"
end



function collectible_skins.get_player_skins(p_name)
  local skins_table = {}

  for id, _ in pairs(players_skins[p_name]) do
    skins_table[id] = loaded_skins[id]
  end

  return table.copy(skins_table)
end



function collectible_skins.get_player_skin(p_name)
  return table.copy(loaded_skins[equipped_skin[p_name]])
end



function collectible_skins.get_player_skin_ID(p_name)
  return equipped_skin[p_name]
end





----------------------------------------------
-----------------SETTERS----------------------
----------------------------------------------

-- at_login è un parametro interno che serve solo per evitare di lanciare il richiamo
-- on_set_skin anche quando si connettono
function collectible_skins.set_skin(player, skin_ID, is_permanent, at_login)
  -- TODO: se l'ID non è più in memoria (es. erano 10, aveva la 9 ma ora sono 6) mettigliene una tra quelle di default. Sennò crasha
  player_api.set_texture(player, 1, loaded_skins[skin_ID].texture)

  local p_name = player:get_player_name()

  equipped_skin[p_name] = skin_ID
  player:get_inventory():set_size("hand", 1)
  player:get_inventory():set_stack("hand", 1, "collectible_skins:hand_" .. tostring(skin_ID))

  if is_permanent then
    player:get_meta():set_int("collectible_skins:skin_ID", skin_ID)
  end

  if at_login then return end

  -- eventuali callback
  for _, callback in ipairs(collectible_skins.registered_on_set_skin) do
    callback(player:get_player_name(), skin_ID, at_login)
  end
end
