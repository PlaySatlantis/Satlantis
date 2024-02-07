joules = {}

local WORLDPATH = minetest.get_worldpath()
local storage = minetest.get_mod_storage()

joules.config = {
    ratios = {},
}

local convertible_list = ""
local joule_ratios = {}

joules.get_config = function()
    -- Read lua config file if it exists
    local path = WORLDPATH .. "/joules.lua"
    local file = io.open(path, "r")
    if file then
        joules.config = loadstring(file:read("*a"))()
        file:close()
    end

    -- Make list of valid items
    local items = {}
    local groups = {}
    for itemname, ratio in pairs(joules.config.ratios) do
        if itemname:sub(1,6) == "group:" then
            groups[itemname:sub(7)] = ratio
        else
            items[itemname] = ratio
        end
    end

    local convertable = {}
    for itemname, def in pairs(minetest.registered_items) do
        if items[itemname] then
            table.insert(convertable, def.description)
            joule_ratios[itemname] = items[itemname]
        else -- Check if matches any groups
            for group, ratio in pairs(groups) do
                if minetest.get_item_group(itemname, group) > 0 then
                    table.insert(convertable, def.description)
                    joule_ratios[itemname] = ratio
                    break
                end
            end
        end
    end

    convertible_list = table.concat(convertable, ",")
end

-- FIXME: Cant split stacks due to textlist??
local joule_form = [[
    size[16,12]
    no_prepend[]
    real_coordinates[true]
    bgcolor[#002b3d]

    button_exit[15,0.5;0.5,0.5;exit;X]

    label[1.1,2;Your joules: %dJ]
    label[6,0.75;-- JOULE CONVERSION --]
    label[4,1.2;This interface may change in the future. Please report any issues.]

    label[7.35,2;Estimated joules: +%dJ]
    button[7.35,2.25;3.5,0.75;convert;Convert to Joules]

    list[detached:joules:%s;holding;1.1,3.25;8,2;]
    list[current_player;main;1.1,6.5;8,4;]
    listring[current_player;main]
    listring[detached:joules:%s;holding]

    label[11.5,2.75;Convertable Items]
    textlist[11.5,3.25;3.5,8;convertable;%s]
]]

local function show_joule_form(name)
    local inv = minetest.get_inventory({type = "detached", name = "joules:" .. name})
    local estimate = 0

    for _, stack in pairs(inv:get_list("holding")) do
        local itemname = stack:get_name()
        local ratio = joule_ratios[itemname]

        if ratio then
            estimate = estimate + math.floor(ratio * stack:get_count())
        end
    end

    minetest.show_formspec(name, "joules:convert:" .. name, joule_form:format(
        storage:get_int(name),
        math.floor(estimate), -- No fractional joules
        name,
        name,
        convertible_list)
    )
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    local name = player:get_player_name()
    if formname == "joules:convert:" .. name then
        local jinv = minetest.get_inventory({type = "detached", name = "joules:" .. name})

        if fields.quit then
            -- Put items back in player inventory
            local pinv = player:get_inventory()
            local pos = player:get_pos()
            for _, stack in pairs(jinv:get_list("holding")) do
                jinv:remove_item("holding", stack)
                local leftover = pinv:add_item("main", stack)

                if leftover then
                    minetest.add_item(pos, leftover)
                end
            end

            return
        end

        if fields.convert then
            local total_joules = storage:get_int(name)
            local items = {}

            -- Count each item type
            for _, stack in pairs(jinv:get_list("holding")) do
                local itemname = stack:get_name()
                if joule_ratios[itemname] then
                    items[itemname] = (items[itemname] or 0) + stack:get_count()
                end
            end

            for itemname, count in pairs(items) do
                local ratio = joule_ratios[itemname]
                local remove_count = count - (count % (1 / ratio)) -- Only remove enough items to make whole joules

                jinv:remove_item("holding", ItemStack(itemname .. " " .. remove_count))
                total_joules = total_joules + (remove_count * ratio)
            end

            storage:set_int(name, total_joules)
            show_joule_form(name)
        end
    end
end)

minetest.register_on_mods_loaded(function()
    joules.get_config()
end)

local on_joule_form_update = function(_, _, _, _, player)
    show_joule_form(player:get_player_name())
end

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()

    local inv = minetest.create_detached_inventory("joules:" .. name, {
        on_put = on_joule_form_update,
        on_take = on_joule_form_update,
    }, name)

    inv:set_size("holding", 16)
end)

minetest.register_chatcommand("joules", {
    func = show_joule_form,
})

minetest.register_chatcommand("refreshjouleconfig", {
    privs = {server = true},
    func = function()
        joules.get_config()
        return true, "Refreshed joule configuration."
    end
})
