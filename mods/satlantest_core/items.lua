local group_solid = {
    normal = true,
    glasslike = true,
    glasslike_framed = true,
    allfaces = true,
}

satlantis.register_block = function(name, definition)
    definition.groups = definition.groups or {}
    definition.groups.all = 1

    if not definition.drawtype or group_solid[definition.drawtype] then
        definition.groups.solid = 1
    end

    minetest.register_node(":" .. name, definition)
end

satlantis.register_item = function(name, definition)
    minetest.register_craftitem(":" .. name, definition)
end

satlantis.register_tool = function(name, definition)
    minetest.register_tool(":" .. name, definition)
end

-- "Creative" inventory
local itemlist_inv = minetest.create_detached_inventory("itemlist", {
    allow_move = function() return 0 end,
    allow_put = function() return -1 end,
    allow_take = function() return -1 end,
})

local total_items = 0
local itemlist_form = [[
    formspec_version[7]
    size[17,14]
    no_prepend[]

    scrollbaroptions[max=%s;thumbsize=10]
    scrollbar[16,1;0.25,6;vertical;scrollbar;]

    scroll_container[1,1;15,6;scrollbar;vertical]
    list[detached:itemlist;list;0,0;12,%s;]
    scroll_container_end[]

    list[current_player;main;3.5,8;8,4]
    listring[detached:itemlist;list]
    listring[current_player;main]
]]

minetest.register_on_mods_loaded(function()
    minetest.after(0, function()
        local sorted = {}

        -- Count all items, sort by description
        for itemname, definition in pairs(minetest.registered_items) do
            if definition.groups.not_in_creative_inventory ~= 1 then
                total_items = total_items + 1
                table.insert(sorted, {itemname, definition.description})
            end
        end

        table.sort(sorted, function(a, b) return b[2] > a[2] end)

        itemlist_inv:set_size("list", total_items)

        for _, item in ipairs(sorted) do
            itemlist_inv:add_item("list", ItemStack(item[1]))
        end

        local rows = math.ceil(total_items / 12)
        itemlist_form = itemlist_form:format(rows * 10, rows)

        minetest.register_on_joinplayer(function(player)
            player:set_inventory_formspec(itemlist_form)
        end)
    end)
end)

minetest.register_chatcommand("items", {
    func = function(name)
        minetest.show_formspec(name, "itemlist", itemlist_form)
    end
})

-- Test node
minetest.register_node(":platform", {
    tiles = {"blank.png^[invert:rgba^[colorize:grey:255"},
    groups = {breakable = 1},
    tool_capabilities = {
        full_punch_interval = 1.0,
        groupcaps = {
            breakable = {times = {0.1}},
            choppy = {times = {0.1, 0.1, 0.1}},
            oddly_breakable_by_hand = {times = {0.1}}
        },
    },
})
