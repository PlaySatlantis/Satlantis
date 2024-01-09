satlantis.doors = {}

satlantis.doors.toggle_door = function(pos)
    local door = minetest.get_node(pos)
    local name, state = door.name:match("^(.+_)([ab])$")

    if state == "a" then
        minetest.swap_node(pos, {name = name .. "b", param2 = (door.param2 + 1) % 4})
    else
        minetest.swap_node(pos, {name = name .. "a", param2 = (door.param2 - 1) % 4})
    end

    local above = pos + vector.new(0, 1, 0)
    local blank = minetest.get_node(above)

    if blank.name ~= "doors:_door_blank" then
        minetest.set_node(above, {name = "doors:_door_blank", param2 = door.param2})
    else
        local def = minetest.registered_nodes[door.name]

        if def.sounds then
            if blank.param2 == door.param2 and def.sounds.open then
                minetest.sound_play(def.sounds.open, {pos = pos}, true)
            elseif def.sounds.close then
                minetest.sound_play(def.sounds.close, {pos = pos}, true)
            end
        end
    end
end

satlantis.doors.on_place = function(itemstack, placer, pointed)
    local pos

    if pointed.type ~= "node" then return itemstack end

    local node = minetest.get_node(pointed.under)
    local pdef = minetest.registered_nodes[node.name]

    if pdef and pdef.on_rightclick and not placer:get_player_control().sneak then
        return pdef.on_rightclick(pointed.under, node, placer, itemstack, pointed)
    end

    if pdef and pdef.buildable_to then
        pos = pointed.under
    else
        pos = pointed.above
        node = minetest.get_node(pos)
        pdef = minetest.registered_nodes[node.name]
        if not pdef or not pdef.buildable_to then return itemstack end
    end

    local above = {x = pos.x, y = pos.y + 1, z = pos.z}
    local top_node = minetest.get_node_or_nil(above)
    local topdef = top_node and minetest.registered_nodes[top_node.name]

    if not topdef or not topdef.buildable_to then return itemstack end

    local pn = placer and placer:get_player_name() or ""
    if minetest.is_protected(pos, pn) or minetest.is_protected(above, pn) then return itemstack end

    return minetest.item_place_node(itemstack, placer, pointed)
end

satlantis.doors.after_place_node = function(pos)
    local node = minetest.get_node(pos)

    local adjacent = {
        vector.new(-1, 0, 0),
        vector.new(0, 0, 1),
        vector.new(1, 0, 0),
        vector.new(0, 0, -1),
    }

    if minetest.get_item_group(minetest.get_node(pos + adjacent[node.param2 + 1]).name, "door") > 0 then
        minetest.swap_node(pos, {name = node.name:match("^(.+_)[ab]$") .. "b", param2 = node.param2})
    end

    -- Save initial state in the blank
    minetest.set_node({x = pos.x, y = pos.y + 1, z = pos.z}, {name = "doors:_door_blank", param2 = node.param2})
end

satlantis.doors.on_blast = function(pos)
    local node = minetest.get_node(pos)
    minetest.remove_node(pos)
    minetest.remove_node({x = pos.x, y = pos.y + 1, z = pos.z})
    return {node.name}
end

satlantis.doors.on_dig = function(pos, node, digger)
    minetest.remove_node({x = pos.x, y = pos.y + 1, z = pos.z})
    minetest.set_node({x = pos.x, y = pos.y + 1, z = pos.z}, {name = "air"})
    return minetest.node_dig(pos, node, digger)
end

satlantis.register_block("doors:_door_blank", {
    drawtype = "airlike",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = false,
    floodable = false,
    drop = "",
    groups = {not_in_creative_inventory = 1},
})

satlantis.doors.register_door = function(name, definition)
    minetest.register_alias("door:" .. name, "door:" .. name .. "_a")

    definition.groups = definition.groups or {}
    definition.groups.door = 1

    satlantis.register_block("door:" .. name .. "_a", {
        description = definition.description,
        drawtype = "mesh",
        mesh = "door.obj",
        tiles = {{name = definition.tiles[1], backface_culling = true}},
        inventory_image = definition.inventory_image,
        wield_image = definition.inventory_image,
        paramtype = "light",
        sunlight_propagates = true,
        paramtype2 = "4dir",
        selection_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.5, 0.5, 1.5, -6 / 16},
        },
        collision_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.5, 0.5, 1.5, -6 / 16},
        },
        sounds = definition.sounds,
        groups = definition.groups,
        on_rightclick = satlantis.doors.toggle_door,
        on_rotate = function() return false end,
        on_dig = satlantis.doors.on_dig,
        on_blast = satlantis.doors.on_blast,
        after_place_node = satlantis.doors.after_place_node,
        use_texture_alpha = definition.use_texture_alpha,
    })

    local groups = table.copy(definition.groups or {})
    groups.not_in_creative_inventory = 1

    satlantis.register_block("door:" .. name .. "_b", {
        description = definition.description,
        drawtype = "mesh",
        mesh = "door.obj",
        tiles = {{name = definition.tiles[1] .. "^[transformFX", backface_culling = true}},
        paramtype = "light",
        sunlight_propagates = true,
        paramtype2 = "4dir",
        selection_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.5, 0.5, 1.5, -6 / 16},
        },
        collision_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.5, 0.5, 1.5, -6 / 16},
        },
        sounds = definition.sounds,
        drop = "door:" .. name .. "_a",
        groups = groups,
        on_rightclick = satlantis.doors.toggle_door,
        on_rotate = function() return false end,
        on_dig = satlantis.doors.on_dig,
        on_blast = satlantis.doors.on_blast,
        use_texture_alpha = definition.use_texture_alpha,
    })
end
