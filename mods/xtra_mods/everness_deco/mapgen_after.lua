--[[
    Everness. Never ending discovery in Everness mapgen.
    Copyright (C) 2024 SaKeL

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

--]]

-- Localize data buffer table outside the loop, to be re-used for all
-- mapchunks, therefore minimising memory use.
local data = {}
local p2data = {}

minetest.register_on_generated(function(minp, maxp, blockseed)
    -- Start time of mapchunk generation.
    -- local t0 = os.clock()
    local rand = PcgRandom(blockseed)
    -- Array containing the biome IDs of nodes in the most recently generated chunk by the current mapgen
    local biomemap = minetest.get_mapgen_object('biomemap')
    -- Table mapping requested generation notification types to arrays of positions at which the corresponding generated structures are located within the current chunk
    local gennotify = minetest.get_mapgen_object('gennotify')
    -- Load the voxelmanip with the result of engine mapgen
    local vm, emin, emax = minetest.get_mapgen_object('voxelmanip')
    -- 'area' is used later to get the voxelmanip indexes for positions
    local area = VoxelArea:new({ MinEdge = emin, MaxEdge = emax })
    -- Get the content ID data from the voxelmanip in the form of a flat array.
    -- Set the buffer parameter to use and reuse 'data' for this.
    vm:get_data(data)
    -- Raw `param2` data read into the `VoxelManip` object
    vm:get_param2_data(p2data)
    -- Side length of mapchunk
    local shared_args = {}

    --
    -- on_data
    --
    -- read/write to `data` what will be eventually saved (set_data)
    -- used for voxelmanip `data` manipulation
    for _, def in ipairs(Everness.on_generated_queue) do
        if def.can_run(biomemap) and def.on_data then
            shared_args[def.name] = shared_args[def.name] or {}
            def.on_data(minp, maxp, area, data, p2data, gennotify, rand, shared_args[def.name])
        end
    end

    -- set data after they have been manipulated (from above)
    vm:set_data(data)
    vm:set_param2_data(p2data)

    --
    -- after_set_data
    --
    -- read-only (but cant and should not manipulate) voxelmanip `data`
    -- used for `place_schematic_on_vmanip` which will invalidate `data`
    -- therefore we are doing it after we set the data
    for _, def in ipairs(Everness.on_generated_queue) do
        if def.can_run(biomemap) and def.after_set_data then
            shared_args[def.name] = shared_args[def.name] or {}
            def.after_set_data(minp, maxp, vm, area, data, p2data, gennotify, rand, shared_args[def.name])
        end
    end

    -- Set the lighting within the `VoxelManip` to a uniform value
    vm:set_lighting({ day = 0, night = 0 }, minp, maxp)
    -- Calculate lighting for what has been created.
    vm:calc_lighting()
    -- Liquid nodes were placed so set them flowing.
    vm:update_liquids()
    -- Write what has been created to the world.
    vm:write_to_map()

    --
    -- after_write_to_map
    --
    -- Cannot read/write voxelmanip or its data
    -- Used for direct manipulation of the world chunk nodes where the
    -- definitions of nodes are available and node callback can be executed
    -- or e.g. for `minetest.fix_light`
    for _, def in ipairs(Everness.on_generated_queue) do
        if def.can_run(biomemap) and def.after_write_to_map then
            shared_args[def.name] = shared_args[def.name] or {}
            def.after_write_to_map(shared_args[def.name], gennotify, rand)
        end
    end

    -- Print generation time of this mapchunk.
    -- local chugent = math.ceil((os.clock() - t0) * 1000)
    -- print('[Everness] Mapchunk generation time ' .. chugent .. ' ms')
end)
