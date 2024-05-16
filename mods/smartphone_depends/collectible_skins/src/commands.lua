local S = minetest.get_translator("collectible_skins")



ChatCmdBuilder.new("skins", function(cmd)
    -- sblocco skin
    cmd:sub("unlock :playername :skinID:int", function(sender, p_name, skinID)

      local had_skin = collectible_skins.is_skin_unlocked(p_name, skinID)
      local _, error = collectible_skins.unlock_skin(p_name, skinID)

      if error then
        minetest.chat_send_player(sender, error)
        return end

      if had_skin then
        minetest.chat_send_player(sender, "Player " .. p_name .. " already has this skin!")
        return end

      minetest.chat_send_player(sender, "Skin " .. collectible_skins.get_skin(skinID).name .. " for " .. p_name .. " successfully unlocked!")
    end)

    -- rimozione skin
    cmd:sub("remove :playername :skinID:int", function(sender, p_name, skinID)

      local had_skin = collectible_skins.is_skin_unlocked(p_name, skinID)
      local _, error = collectible_skins.remove_skin(p_name, skinID)

      if error then
        minetest.chat_send_player(sender, error)
        return end

      if not had_skin then
        minetest.chat_send_player(sender, "Player " .. p_name .. " doesn't have this skin!")
        return end

      minetest.chat_send_player(sender, "Skin " .. collectible_skins.get_skin(skinID).name .. " for " .. p_name .. " successfully removed")
    end)

    -- aiuto
    cmd:sub("help", function(sender)
      minetest.chat_send_player(sender,
        minetest.colorize("#ffff00", S("COMMANDS")) .. "\n"
        .. minetest.colorize("#00ffff", "/skins remove") .. " <" .. S("player") .. "> <ID>: " .. S("unlocks a skin") .. "\n"
        .. minetest.colorize("#00ffff", "/skins unlock") .. " <" .. S("player") .. "> <ID>: " .. S("unlocks a skin")
      )
    end)

end, {
  params = "help",
  description = S("Manage players skins. It requires cskins_admin"),
  privs = { cskins_admin = true }
})
