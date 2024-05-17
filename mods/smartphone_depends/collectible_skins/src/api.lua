local yaml = dofile(minetest.get_modpath("collectible_skins") .. "/libs/tinyyaml.lua")
local storage = minetest.get_mod_storage()

local function migrate_old_skins() end

local players_skins = {}                        -- KEY: p_name; VALUE: {skin IDs}
local loaded_skins = {}                         -- KEY: id; VALUE: {skin info}
local skin_collections = {}                     -- KEY: coll_name; VALUE: {skin IDs}
local equipped_skin = {}                        -- KEY: p_name; VALUE: skin ID
local default_skins = collectible_skins.SETTINGS.default_skins
local skins_to_migrate = collectible_skins.SETTINGS.migrate_skins



local function register_hand_from_texture(name, texture)
	local hand_name = "collectible_skins:hand_" .. name
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

      for name, skin in pairs(skins) do
        ID = 0 -- poi toglilo
        -- TODO vedere come si comporta questo decodificatore
        -- il decodificatore aggiunge _N ai doppioni, per diversificarli e salvarli entrambi. Tolgo quindi _ecc
        -- da eventuali cifre iniziali per vedere se già esiste (se è stringa, è errore a prescindere)
        if type(ID) == "string" then
          assert(loaded_skins[tonumber(ID:match("(%d+)_"))] == nil,  "[SKINS COLLECTIBLE] There are two or more skins with the same name!")
          error("[SKINS COLLECTIBLE] Invalid skin ID '" .. ID .. "': numbers only!")
        end
        assert(skin.name,         "[SKINS COLLECTIBLE] Skin `" .. name .. "` has no name!")
        assert(skin.description,  "[SKINS COLLECTIBLE] Skin `" .. name .. "` has no description!")
        assert(skin.texture,      "[SKINS COLLECTIBLE] Skin `" .. name .. "` has no texture!")

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

        assert(sk_preview ~= "", "[SKINS COLLECTIBLE] Skin `" .. name .. "` has no preview!")

        local sk_collection = skin.collection or "Default"

        if not skin_collections[sk_collection] then
          skin_collections[sk_collection] = {}
        end

        skin_collections[sk_collection][name] = true

        -- TODO: preview e splash_art da rimuovere
        loaded_skins[name] = {
          technical_name  = name,         -- for cross-reference
          name            = skin.name,
          description     = skin.description,
          collection      = sk_collection,
          hint            = skin.hint or "(locked)",
          model           = skin.model,
          texture         = skin.texture,
          preview         = sk_preview,
          splash_art      = sk_splash,
          tier            = skin.tier or 1,
          author          = skin.author or "???",
        }

        register_hand_from_texture(name, skin.texture)
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

  -- se lə giocante entra per la prima volta o ha perso il metadato, lo inizializzo...
  -- il controllo del metadato è l'unico modo che ho trovato di sapere se qualcuno ha usato
  -- minetest.remove_player sul giocatore.
  if storage:get_string(p_name) == "" or not player:get_meta():contains("collectible_skins:skin") then
    players_skins[p_name] = {}

    -- migrazione vecchio sistema basato sugli id
    if player:get_meta():contains("collectible_skins:skin_ID") then
      local p_skins = minetest.deserialize(storage:get_string(p_name))

      -- se p_skins non esiste significa che hanno cancellato il mod storage, ma non i metadati degli utenti
      if p_skins then
        migrate_old_skins(player, p_name)
        return
      end

      player:get_meta():set_string("collectible_skins:skin_ID", "")
    end

    -- sblocco le skin base
    for _, name in pairs(default_skins) do
      players_skins[p_name][name] = true
    end

    storage:set_string(p_name, minetest.serialize(players_skins[p_name]))

    -- ...e gli assegno una skin casuale
    local random_ID = math.random(#default_skins)
    collectible_skins.set_skin(player, default_skins[random_ID], true, true)

  --sennò gli assegno la skin che aveva
  else
    local skin_name = player:get_meta():get_string("collectible_skins:skin")

    players_skins[p_name] = minetest.deserialize(storage:get_string(p_name))
    collectible_skins.set_skin(player, skin_name, false, true)
  end
end



function collectible_skins.unlock_skin(p_name, skin_name)
  -- se la skin non esiste, annullo
  if not loaded_skins[skin_name] then
    local error = "[collectible_skins] There has been an attempt to give player " .. p_name .. " a skin that doesn't exist (`" .. skin_name .. "`)!"
    minetest.log("warning", error)
    return false, error end

  -- se il giocatore non si è mai connesso, annullo
  if storage:get_string(p_name) == "" then
    local error = "[SKINS COLLECTIBLE] Player " .. p_name .. " is not in the skin database (meaning the player has never connected)"
    minetest.log("warning", error)
    return false, error end

  -- se ce l'ha già, annullo
  if collectible_skins.is_skin_unlocked(p_name, skin_name) then
    return end

  local p_skins

  -- se è online
  if minetest.get_player_by_name(p_name) then
    p_skins = players_skins[p_name]
    minetest.chat_send_player(p_name, "You've unlocked the skin " .. loaded_skins[skin_name].name .. "!")
  -- se è offline
  else
    p_skins = minetest.deserialize(storage:get_string(p_name))
  end

  p_skins[skin_name] = true
  storage:set_string(p_name, minetest.serialize(p_skins))
end



function collectible_skins.remove_skin(p_name, skin_name)
  -- se la skin non esiste, annullo
  if not loaded_skins[skin_name] then
    local error = "[collectible_skins] There has been an attempt to remove player " .. p_name .. " a skin that doesn't exist (`" .. skin_name .. "`)!"
    minetest.log("warning", error)
    return false, error end

  -- se il giocatore non si è mai connesso, annullo
  if storage:get_string(p_name) == "" then
    local error = "[SKINS COLLECTIBLE] Player " .. p_name .. " is not in the skin database (meaning the player has never connected)"
    minetest.log("warning", error)
    return false, error end

  -- se già gli manca, annullo
  if not collectible_skins.is_skin_unlocked(p_name, skin_name) then
    return end

  local p_skins

  -- se è online
  if minetest.get_player_by_name(p_name) then
    p_skins = players_skins[p_name]
    minetest.chat_send_player(p_name, "Your skin " .. loaded_skins[skin_name].name .. " has been removed...")
  -- se è offline
  else
    p_skins = minetest.deserialize(storage:get_string(p_name))
  end

  -- rimuovo
  p_skins[skin_name] = false
  storage:set_string(p_name, minetest.serialize(p_skins))
end





----------------------------------------------
--------------------UTILS---------------------
----------------------------------------------

function collectible_skins.is_skin_unlocked(p_name, skin_name)
  -- per controllare anche giocatori offline
  local p_skins = players_skins[p_name] or minetest.deserialize(storage:get_string(p_name))

  if p_skins and p_skins[skin_name] then return true
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

  for name, _ in pairs(skin_collections[collection]) do
    skins[name] = loaded_skins[name]
  end

  return table.copy(skins)
end



function collectible_skins.get_collections()
  local collections = {}

  for coll, _ in pairs(skin_collections) do
    table.insert(collections, coll)
  end

  return collections
end



function collectible_skins.get_skin(skin_name)
  return table.copy(loaded_skins[skin_name])
end



function collectible_skins.get_portrait(skin)
  return "([combine:24x24:0,0=" .. skin.texture .. "^[mask:cskins_portraitmask.png)"
end



function collectible_skins.get_player_skins(p_name)
  local skins_table = {}

  for name, _ in pairs(players_skins[p_name]) do
    skins_table[name] = loaded_skins[name]
  end

  return table.copy(skins_table)
end



function collectible_skins.get_player_skin(p_name)
  return table.copy(loaded_skins[equipped_skin[p_name]])
end





----------------------------------------------
-----------------SETTERS----------------------
----------------------------------------------

-- at_login è un parametro interno che serve solo per evitare di lanciare il richiamo
-- on_set_skin anche quando si connettono
function collectible_skins.set_skin(player, skin_name, is_permanent, at_login)
  -- TODO: se skin_name non è più in memoria mettigliene una tra quelle predefinite. Sennò crasha
  player_api.set_texture(player, 1, loaded_skins[skin_name].texture)

  local p_name = player:get_player_name()

  equipped_skin[p_name] = skin_name
  player:get_inventory():set_size("hand", 1)
  player:get_inventory():set_stack("hand", 1, "collectible_skins:hand_" .. tostring(skin_name))

  if is_permanent then
    player:get_meta():set_string("collectible_skins:skin", skin_name)
  end

  if at_login then return end

  -- eventuali richiami
  for _, callback in ipairs(collectible_skins.registered_on_set_skin) do
    callback(player:get_player_name(), skin_name, at_login)
  end
end





----------------------------------------------
------------------DEPRECATED------------------
----------------------------------------------

-- to remove in 1.0 (or 2.0, I don't know)
function migrate_old_skins(player, p_name)
  assert(skins_to_migrate ~= nil, "[COLLECTIBLE_SKINS] You need to migrate your skins using the new nomenclature system instead of IDs!"
          .. "Check out the DOCS to learn about the new structure and use the setting `migrate_skins` to migrate "
          .. "(it's probably only in the IGNOREME folder of the mod, just copy it)")

  local curr_skin_id = player:get_meta():get_int("collectible_skins:skin_ID")
  local p_skins = minetest.deserialize(storage:get_string(p_name))

  for id, name in pairs(skins_to_migrate) do
    if p_skins[id] then
      players_skins[p_name][name] = true

      if id == curr_skin_id then
        collectible_skins.set_skin(player, name, true, true)
      end
    end
  end
  

  storage:set_string(p_name, minetest.serialize(players_skins[p_name]))
  player:get_meta():set_string("collectible_skins:skin_ID", "")
end