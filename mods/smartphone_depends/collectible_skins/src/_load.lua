local function load_folder()
  local wrld_dir = minetest.get_worldpath() .. "/skins"
  local files = minetest.get_dir_list(wrld_dir, false)

  local modpath = minetest.get_modpath("collectible_skins")
  local i18n_dir = modpath .. "/locale/skins"
  local txtr_dir = modpath .. "/textures/skins"
  local menu_ui_dir = modpath .. "/textures/menu"

  -- se la cartella delle skin non esiste/è vuota, copio la cartella base `skins`
  -- dentro quella del mondo
  if not next(files) then
    local src_dir = minetest.get_modpath("collectible_skins") .. "/IGNOREME"
    minetest.cpdir(src_dir, wrld_dir)
    os.remove(wrld_dir .. "/README.md")
  end

  --v------------------ LEGACY UPDATE, to remove in 1.0 -------------------v
  local old_settings = io.open(modpath .. "/SETTINGS.lua", "r")

  if old_settings then
    minetest.safe_file_write(wrld_dir .. "/SETTINGS.lua", old_settings:read("*a"))
    old_settings:close()
    os.remove(modpath .. "/SETTINGS.lua")
  end

  if next(minetest.get_dir_list(txtr_dir)) then
    minetest.rmdir(i18n_dir)
    minetest.rmdir(menu_ui_dir)
    minetest.rmdir(txtr_dir)
  end
  --^------------------ LEGACY UPDATE, to remove in 1.0 -------------------^

  minetest.cpdir(wrld_dir .. "/locale", i18n_dir)

  -- carico quel che posso dalla cartella del mondo (non davvero media dinamici,
  -- dato che vengon eseguiti all'avvio del server)
  local function iterate_dirs(dir)
    for _, f_name in pairs(minetest.get_dir_list(dir, false)) do
      minetest.dynamic_add_media({filepath = dir .. "/" .. f_name}, function(name) end)
    end
    for _, subdir in pairs(minetest.get_dir_list(dir, true)) do
      iterate_dirs(dir .. "/" .. subdir)
    end
  end

  -- TEMP MT 5.9: per ora non si possono aggiungere contenuti dinamici all'avvio
  -- del server. Poi rimuovi anche 2° param da dynamic_add_media qui in alto
  minetest.after(0.1, function()
    iterate_dirs(wrld_dir .. "/menu")
    iterate_dirs(wrld_dir .. "/textures")
  end)


end



load_folder()

dofile(minetest.get_worldpath("collectible_skins") .. "/skins/SETTINGS.lua")
