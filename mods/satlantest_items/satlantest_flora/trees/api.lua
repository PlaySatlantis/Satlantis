-- Sapling growth
satlantis.flora.tree_can_grow = function(pos, soil_group, min_light_level, other_conditions)
    local node_under = minetest.get_node_or_nil({x = pos.x, y = pos.y - 1, z = pos.z})
    if not node_under then return false end

    if minetest.get_item_group(node_under.name, soil_group or "soil") == 0 then return false end

    local light_level = minetest.get_node_light(pos)
    if not light_level or light_level < (min_light_level or 13) then return false end

    if other_conditions and not other_conditions(pos) then return false end

    return true
end

satlantis.flora.sapling_on_construct = function(pos)
    -- minetest.get_node_timer(pos):start(math.random(300, 1500))
    minetest.get_node_timer(pos):start(2)
end

satlantis.flora.sapling_on_timer = function(name, soil_group, min_light_level, other_conditions)
    return function(pos)
        if not satlantis.flora.tree_can_grow(pos, soil_group, min_light_level, other_conditions) then
            -- minetest.get_node_timer(pos):start(300) -- Every 5 minutes
            minetest.get_node_timer(pos):start(2)
            return
        end

        local node = minetest.get_node(pos)
        if node.name == name then
            minetest.registered_nodes[node.name].grow(pos)
        end
    end
end

-- Leaf decay
satlantis.flora.leaves_after_place = function(pos, placer)
	if placer and placer:is_player() then
		local node = minetest.get_node(pos)
		node.param2 = 1
		minetest.set_node(pos, node)
	end
end

satlantis.flora.leaves_after_destruct = function(pos, radius, leaves)
	for _, v in pairs(minetest.find_nodes_in_area(vector.subtract(pos, radius), vector.add(pos, radius), leaves)) do
		local timer = minetest.get_node_timer(v)
		if minetest.get_node(v).param2 ~= 1 and not timer:is_started() then
			timer:start(math.random(20, 120) / 10)
		end
	end
end

satlantis.flora.leaves_on_timer = function(pos, radius, leaves, trunk)
	if minetest.find_node_near(pos, radius, trunk) then
		return false
	end

	local node = minetest.get_node(pos)
	local drops = minetest.get_node_drops(node.name)
	for _, item in ipairs(drops) do
		if item ~= leaves then
            if math.random() * (item.rarity or 1) <= 1 then
                minetest.add_item({
                    x = pos.x - 0.5 + math.random(),
                    y = pos.y - 0.5 + math.random(),
                    z = pos.z - 0.5 + math.random(),
                }, item)

                break
            end
        end
	end

	minetest.remove_node(pos)
	minetest.check_for_falling(pos)

	minetest.add_particlespawner({
		amount = 8,
		time = 0.001,
		minpos = vector.subtract(pos, {x = 0.5, y = 0.5, z = 0.5}),
		maxpos = vector.add(pos, {x = 0.5, y = 0.5, z = 0.5}),
		minvel = vector.new(-0.5, -1, -0.5),
		maxvel = vector.new(0.5, 0, 0.5),
		minacc = vector.new(0, -9.8, 0), -- TODO: Use local gravity
		maxacc = vector.new(0, -9.8, 0), -- TODO: Use local gravity
		minsize = 0,
		maxsize = 0,
		node = node,
	})
end

minetest.register_lbm({
	name = ":flora:start_sapling_node_timer",
	nodenames = {"group:sapling"},
	action = function(pos)
		-- minetest.get_node_timer(pos):start(math.random(300, 1500))
        minetest.get_node_timer(pos):start(2)
	end
})
