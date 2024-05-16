-- if arena_lib is loaded, we want to remove armor and give it back again when the player enters and leaves the arena

local storage = minetest.get_mod_storage()
local function save_armor_inv(p_name)
    -- get the player's armor inventory
    local player = minetest.get_player_by_name(p_name)
    if not player then return end

    local name, inv = armor:get_valid_player(player)
    if not name or not inv then
        return
    end
    local list = inv:get_list("armor")
    local tbl = {}
    for k,v in ipairs(list) do
        table.insert(tbl, v:to_string())
        inv:set_stack("armor", k, "")
    end
    armor:update_player_visuals(player)
    storage:set_string("arena_saved_armor_" .. p_name, minetest.serialize(tbl))
end

local function recall_armor_inv(p_name)
    local val = storage:get_string("arena_saved_armor_" .. p_name)
    if val == "" then
        return
    end
    local tbl = minetest.deserialize(val)  -- Pass the serialized string here
    if not tbl then
        return
    end
    local player = minetest.get_player_by_name(p_name)
    if not player then return end

    local name, inv = armor:get_valid_player(player)
    if not name or not inv then
        return
    end

    for k, v in ipairs(tbl) do
        inv:set_stack("armor", k, ItemStack(v))
    end
    armor:update_player_visuals(player)
    -- clear the storage
    storage:set_string("arena_saved_armor_" .. p_name, "")
end

minetest.register_on_mods_loaded(function()
    if arena_lib then
        arena_lib.register_on_load(function(mod, arena)
            for pl_name, stats in pairs(arena.players) do
                save_armor_inv(pl_name)
            end
        end)
        arena_lib.register_on_join(function(mod, arena, p_name)
            save_armor_inv(p_name)
        end)
        arena_lib.register_on_quit(function(mod, arena, p_name, is_spectator, reason)
            recall_armor_inv(p_name)
        end)
        arena_lib.register_on_eliminate(function(mod, arena, p_name)
            recall_armor_inv(p_name)
        end)
        arena_lib.register_on_end(function(mod, arena, winners, is_forced)
            for pl_name, stats in pairs(arena.players) do
                recall_armor_inv(pl_name)
            end
        end)
        minetest.register_on_joinplayer(function(player) recall_armor_inv(player:get_player_name()) end)
    end
end)
