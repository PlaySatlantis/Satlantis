satlantis.register_tool("tools:hoe", {
    description = "Iron Hoe",
    inventory_image = "iron_hoe.png",
    on_use = function(_, _, pointed)
        if pointed.type ~= "node" then return end
        if pointed.above.y ~= pointed.under.y + 1 then return end -- must be top of node

        local dirt = minetest.get_node(pointed.under).name:split("_")
        if dirt[1] ~= "geo:dirt" then return end -- must be dirt

        if not dirt[2] then -- just dirt
            minetest.set_node(pointed.under, {name = "geo:dirt_loose"})
        elseif dirt[2] == "snowy" then
            minetest.set_node(pointed.under, {name = "geo:dirt_grassy"})
        elseif dirt[2] == "grassy" then
            minetest.set_node(pointed.under, {name = "geo:dirt"})
        end
    end
})
