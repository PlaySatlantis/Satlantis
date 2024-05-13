local modname = minetest.get_current_modname()
loadfile(minetest.get_modpath(modname) .. "/exported.lua")(function(def)
    local myname = modname .. ":" .. def._raw_name:gsub(":", "__")
    -- if def._alias_to then
    --     local myalias = modname .. ":" .. def._alias_to:gsub(":", "__")
    --     return minetest.register_alias(myname, myalias)
    -- end
    -- def._raw_name = nil
    local ret =  minetest.register_item(myname, def)

    minetest.register_alias( def._raw_name, myname)

    return ret
end)
