local storage = minetest.get_mod_storage()


function phone_travel.get_destinations(pl_name)
	local json = storage:get_string("destinations|"..pl_name)
	local destinations = {}
	if json ~= "" then
		destinations = minetest.parse_json(json)
	end

	return destinations
end

function phone_travel.get_invites(pl_name)
	local json = storage:get_string("invites|"..pl_name)
	local invites = {}
	if json ~= "" then
		invites = minetest.parse_json(json)
	end

	if invites == nil then
		invites = {}
	end
	return invites
end

function phone_travel.add_destination(pl_name, island_type, island_name, description)
	local destinations = phone_travel.get_destinations(pl_name)
	local player = minetest.get_player_by_name(island_name)

	local pos
	if player ~= nil then
		local skyblock = satlantis.skyblock
		pos = skyblock.get_home(player)
	end

	table.insert(destinations, 
	{type = island_type,
	name = island_name,
	description = description,
	pos = pos})

	storage:set_string("destinations|"..pl_name, minetest.write_json(destinations))

	local invites = phone_travel.get_invites(pl_name)
	table.insert(invites, pl_name)
	storage:set_string("invites|"..island_name, minetest.write_json(invites))
end

local function index_destination(array, value)
    for i, v in ipairs(array) do
        if v.name == value then
            return i
        end
    end
    return nil
end

local function index(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

function phone_travel.remove_access(pl_name, island_name)
	local destinations = phone_travel.get_destinations(pl_name)
	table.remove(destinations, index(destinations, island_name))
	storage:set_string("destinations|"..pl_name, minetest.write_json(destinations))

	local invites = phone_travel.get_invites(pl_name)
	table.remove(invites, index(invites, pl_name))
	storage:set_string("invites|"..island_name, minetest.write_json(invites))
end

function phone_travel.go_to(pl_name, island_type, island_name)
	if island_type == "lobby" then
		minetest.registered_chatcommands["lobby"].func(pl_name, "")
	elseif island_type == "overworld" then
		minetest.registered_chatcommands["overworld"].func(pl_name, "")
	elseif island_type == "personal_island" then
		minetest.registered_chatcommands["home"].func(pl_name, "")
	else
		local skyblock = satlantis.skyblock()
		local destinations = phone_travel.get_destinations(pl_name)
		local i = index_destination(destinations, island_name)
		local pos = phone_travel.get_destinations(pl_name)[i]
		skyblock.enter_cel(pl_name, pos.pos)
	end
end

function phone_travel.is_pos_allowed(pl)
	local checklist = {}

    local destinations = phone_travel.get_destinations(pl:get_player_name())
    for i, destination in pairs(destinations) do
        if destination.type == "external_island" then
			table.insert(checklist, destination.name)
		end
	end

	table.insert(checklist, pl:get_player_name())

	local skyblock = satlantis.skyblock()

	for i, player in pairs(checklist) do
		local cel = skyblock.get_player_cel(player)

		if not cel then goto continue end

		local min = cel.bounds.min - vector.new(1, 1.5, 1)
		local max = cel.bounds.max + vector.new(1, -0.5, 1)

		if skyblock.pos_in_bounds(pl:get_pos(), min, max) then
			return true
		end
		::continue::
	end

	return false
end
	

minetest.register_on_joinplayer(function(player, last_login)
	local pl_name = player:get_player_name()

	local json = storage:get_string("destinations|"..pl_name)
	if json == "" then
		phone_travel.add_destination(pl_name, "lobby", "Lobby", "The lobby!")
		phone_travel.add_destination(pl_name, "overworld", "Overworld", "The overworld where you can get resources!")
		phone_travel.add_destination(pl_name, "personal_island", "Orbiter", "Your personal island!")
	end
end)

minetest.register_chatcommand("add", {func = function(name, param)
	local json = storage:get_string("destinations|"..param)
	if json == "" or json == nil or json == "null" then
		minetest.chat_send_player(name, "The name you provided is not valid or does not exist!")
		return
	end
	phone_travel.add_destination(param, "external_island", name, "This is the island of "..name.."!")
	minetest.chat_send_player(name, "Added "..param.." to your island!")
	end,
	description = "Add an player to your personal island!",
})

minetest.registered_chatcommands["invite"] = minetest.registered_chatcommands["add"]