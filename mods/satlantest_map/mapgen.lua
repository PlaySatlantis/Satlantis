minetest.register_alias("mapgen_stone", "geo:stone")
minetest.register_alias("mapgen_water_source", "hydro:water_source")
minetest.register_alias("mapgen_river_water_source", "hydro:water_source")

-- local OFFSET = 0
-- local old_register_biome = minetest.register_biome
-- minetest.register_biome = function(definition)
--     if definition.y_min then
--         definition.y_min = math.max(-31000, definition.y_min + OFFSET)
--     end
--     if definition.y_max then
--         definition.y_max = math.max(-31000, definition.y_max + OFFSET)
--     end
--     old_register_biome(definition)
-- end

--
-- Register ores
--

local function register_ores()
	-- Stratum ores.
	-- These obviously first.

	-- Sandstone

	minetest.register_ore({
		ore_type        = "stratum",
		ore             = "geo:sandstone",
		wherein         = {"geo:stone"},
		clust_scarcity  = 1,
		y_max           = 46,
		y_min           = 10,
		noise_params    = {
			offset = 28,
			scale = 16,
			spread = {x = 128, y = 128, z = 128},
			seed = 90122,
			octaves = 1,
		},
		stratum_thickness = 4,
		biomes = {"desert"},
	})

	minetest.register_ore({
		ore_type        = "stratum",
		ore             = "geo:sandstone",
		wherein         = {"geo:stone"},
		clust_scarcity  = 1,
		y_max           = 42,
		y_min           = 6,
		noise_params    = {
			offset = 24,
			scale = 16,
			spread = {x = 128, y = 128, z = 128},
			seed = 90122,
			octaves = 1,
		},
		stratum_thickness = 2,
		biomes = {"desert"},
	})

	-- Blob ore.
	-- These before scatter ores to avoid other ores in blobs.

	-- Clay

	minetest.register_ore({
		ore_type        = "blob",
		ore             = "geo:clay",
		wherein         = {"geo:sand"},
		clust_scarcity  = 16 * 16 * 16,
		clust_size      = 5,
		y_max           = 0,
		y_min           = -15,
		noise_threshold = 0.0,
		noise_params    = {
			offset = 0.5,
			scale = 0.2,
			spread = {x = 5, y = 5, z = 5},
			seed = -316,
			octaves = 1,
			persist = 0.0
		},
	})

	-- Dirt

	minetest.register_ore({
		ore_type        = "blob",
		ore             = "geo:dirt",
		wherein         = {"geo:stone"},
		clust_scarcity  = 16 * 16 * 16,
		clust_size      = 5,
		y_max           = 31000,
		y_min           = -31,
		noise_threshold = 0.0,
		noise_params    = {
			offset = 0.5,
			scale = 0.2,
			spread = {x = 5, y = 5, z = 5},
			seed = 17676,
			octaves = 1,
			persist = 0.0
		},
		-- Only where geo:dirt is present as surface material
		biomes = {"taiga", "snowy_grassland", "grassland", "coniferous_forest",
				"deciduous_forest", "deciduous_forest_shore", "rainforest",
				"rainforest_swamp"}
	})

	-- Gravel

	minetest.register_ore({
		ore_type        = "blob",
		ore             = "geo:gravel",
		wherein         = {"geo:stone"},
		clust_scarcity  = 16 * 16 * 16,
		clust_size      = 5,
		y_max           = 31000,
		y_min           = -31000,
		noise_threshold = 0.0,
		noise_params    = {
			offset = 0.5,
			scale = 0.2,
			spread = {x = 5, y = 5, z = 5},
			seed = 766,
			octaves = 1,
			persist = 0.0
		},
	})

	-- Scatter ores

	-- Coal

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "geo:coal_ore",
		wherein        = "geo:stone",
		clust_scarcity = 8 * 8 * 8,
		clust_num_ores = 9,
		clust_size     = 3,
		y_max          = 31000,
		y_min          = 1025,
	})

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "geo:coal_ore",
		wherein        = "geo:stone",
		clust_scarcity = 8 * 8 * 8,
		clust_num_ores = 8,
		clust_size     = 3,
		y_max          = 64,
		y_min          = -127,
	})

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "geo:coal_ore",
		wherein        = "geo:stone",
		clust_scarcity = 12 * 12 * 12,
		clust_num_ores = 30,
		clust_size     = 5,
		y_max          = -128,
		y_min          = -31000,
	})

	-- Copper

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "geo:copper_ore",
		wherein        = "geo:stone",
		clust_scarcity = 9 * 9 * 9,
		clust_num_ores = 5,
		clust_size     = 3,
		y_max          = 31000,
		y_min          = 1025,
	})

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "geo:copper_ore",
		wherein        = "geo:stone",
		clust_scarcity = 12 * 12 * 12,
		clust_num_ores = 4,
		clust_size     = 3,
		y_max          = -64,
		y_min          = -127,
	})

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "geo:copper_ore",
		wherein        = "geo:stone",
		clust_scarcity = 9 * 9 * 9,
		clust_num_ores = 5,
		clust_size     = 3,
		y_max          = -128,
		y_min          = -31000,
	})

	-- Iron

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "geo:iron_ore",
		wherein        = "geo:stone",
		clust_scarcity = 9 * 9 * 9,
		clust_num_ores = 12,
		clust_size     = 3,
		y_max          = 31000,
		y_min          = 1025,
	})

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "geo:iron_ore",
		wherein        = "geo:stone",
		clust_scarcity = 7 * 7 * 7,
		clust_num_ores = 5,
		clust_size     = 3,
		y_max          = -128,
		y_min          = -255,
	})

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "geo:iron_ore",
		wherein        = "geo:stone",
		clust_scarcity = 12 * 12 * 12,
		clust_num_ores = 29,
		clust_size     = 5,
		y_max          = -256,
		y_min          = -31000,
	})

	-- Gold

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "geo:gold_ore",
		wherein        = "geo:stone",
		clust_scarcity = 13 * 13 * 13,
		clust_num_ores = 5,
		clust_size     = 3,
		y_max          = 31000,
		y_min          = 1025,
	})

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "geo:gold_ore",
		wherein        = "geo:stone",
		clust_scarcity = 15 * 15 * 15,
		clust_num_ores = 3,
		clust_size     = 2,
		y_max          = -256,
		y_min          = -511,
	})

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "geo:gold_ore",
		wherein        = "geo:stone",
		clust_scarcity = 13 * 13 * 13,
		clust_num_ores = 5,
		clust_size     = 3,
		y_max          = -512,
		y_min          = -31000,
	})

	-- Diamond

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "geo:diamond_ore",
		wherein        = "geo:stone",
		clust_scarcity = 15 * 15 * 15,
		clust_num_ores = 4,
		clust_size     = 3,
		y_max          = 31000,
		y_min          = 1025,
	})

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "geo:diamond_ore",
		wherein        = "geo:stone",
		clust_scarcity = 17 * 17 * 17,
		clust_num_ores = 4,
		clust_size     = 3,
		y_max          = -1024,
		y_min          = -2047,
	})

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "geo:diamond_ore",
		wherein        = "geo:stone",
		clust_scarcity = 15 * 15 * 15,
		clust_num_ores = 4,
		clust_size     = 3,
		y_max          = -2048,
		y_min          = -31000,
	})
end


--
-- Register biomes
--

local function register_biomes()

	-- Icesheet

	minetest.register_biome({
		name = "icesheet",
		node_dust = "hydro:snow_block",
		node_top = "hydro:snow_block",
		depth_top = 1,
		node_filler = "hydro:snow_block",
		depth_filler = 3,
		node_stone = "hydro:cave_ice",
		node_water_top = "hydro:ice",
		depth_water_top = 10,
		node_river_water = "hydro:ice",
		node_riverbed = "geo:gravel",
		depth_riverbed = 2,
		y_max = 31000,
		y_min = -8,
		heat_point = 0,
		humidity_point = 73,
	})

	minetest.register_biome({
		name = "icesheet_ocean",
		node_dust = "hydro:snow_block",
		node_top = "geo:sand",
		depth_top = 1,
		node_filler = "geo:sand",
		depth_filler = 3,
		node_water_top = "hydro:ice",
		depth_water_top = 10,
		node_cave_liquid = "hydro:water_source",
		y_max = -9,
		y_min = -255,
		heat_point = 0,
		humidity_point = 73,
	})

	minetest.register_biome({
		name = "icesheet_under",
		node_cave_liquid = {"hydro:water_source", "geo:lava_source"},
		y_max = -256,
		y_min = -31000,
		heat_point = 0,
		humidity_point = 73,
	})

	-- Tundra

	minetest.register_biome({
		name = "tundra_highland",
		node_dust = "hydro:snow",
		node_riverbed = "geo:gravel",
		depth_riverbed = 2,
		y_max = 31000,
		y_min = 47,
		heat_point = 0,
		humidity_point = 40,
	})

	minetest.register_biome({
		name = "tundra",
		node_top = "geo:dirt",
		depth_top = 1,
		node_filler = "geo:dirt",
		depth_filler = 1,
		node_riverbed = "geo:gravel",
		depth_riverbed = 2,
		vertical_blend = 4,
		y_max = 46,
		y_min = 2,
		heat_point = 0,
		humidity_point = 40,
	})

	minetest.register_biome({
		name = "tundra_beach",
		node_top = "geo:gravel",
		depth_top = 1,
		node_filler = "geo:gravel",
		depth_filler = 2,
		node_riverbed = "geo:gravel",
		depth_riverbed = 2,
		vertical_blend = 1,
		y_max = 1,
		y_min = -3,
		heat_point = 0,
		humidity_point = 40,
	})

	minetest.register_biome({
		name = "tundra_ocean",
		node_top = "geo:sand",
		depth_top = 1,
		node_filler = "geo:sand",
		depth_filler = 3,
		node_riverbed = "geo:gravel",
		depth_riverbed = 2,
		node_cave_liquid = "hydro:water_source",
		vertical_blend = 1,
		y_max = -4,
		y_min = -255,
		heat_point = 0,
		humidity_point = 40,
	})

	minetest.register_biome({
		name = "tundra_under",
		node_cave_liquid = {"hydro:water_source", "geo:lava_source"},
		y_max = -256,
		y_min = -31000,
		heat_point = 0,
		humidity_point = 40,
	})

	-- Taiga

	minetest.register_biome({
		name = "taiga",
		node_dust = "hydro:snow",
		node_top = "geo:dirt_snowy",
		depth_top = 1,
		node_filler = "geo:dirt",
		depth_filler = 3,
		node_riverbed = "geo:sand",
		depth_riverbed = 2,
		y_max = 31000,
		y_min = 4,
		heat_point = 25,
		humidity_point = 70,
	})

	minetest.register_biome({
		name = "taiga_ocean",
		node_dust = "hydro:snow",
		node_top = "geo:sand",
		depth_top = 1,
		node_filler = "geo:sand",
		depth_filler = 3,
		node_riverbed = "geo:sand",
		depth_riverbed = 2,
		node_cave_liquid = "hydro:water_source",
		vertical_blend = 1,
		y_max = 3,
		y_min = -255,
		heat_point = 25,
		humidity_point = 70,
	})

	minetest.register_biome({
		name = "taiga_under",
		node_cave_liquid = {"hydro:water_source", "geo:lava_source"},
		y_max = -256,
		y_min = -31000,
		heat_point = 25,
		humidity_point = 70,
	})

	-- Snowy grassland

	minetest.register_biome({
		name = "snowy_grassland",
		node_dust = "hydro:snow",
		node_top = "geo:dirt_snowy",
		depth_top = 1,
		node_filler = "geo:dirt",
		depth_filler = 1,
		node_riverbed = "geo:sand",
		depth_riverbed = 2,
		y_max = 31000,
		y_min = 4,
		heat_point = 20,
		humidity_point = 35,
	})

	minetest.register_biome({
		name = "snowy_grassland_ocean",
		node_dust = "hydro:snow",
		node_top = "geo:sand",
		depth_top = 1,
		node_filler = "geo:sand",
		depth_filler = 3,
		node_riverbed = "geo:sand",
		depth_riverbed = 2,
		node_cave_liquid = "hydro:water_source",
		vertical_blend = 1,
		y_max = 3,
		y_min = -255,
		heat_point = 20,
		humidity_point = 35,
	})

	minetest.register_biome({
		name = "snowy_grassland_under",
		node_cave_liquid = {"hydro:water_source", "geo:lava_source"},
		y_max = -256,
		y_min = -31000,
		heat_point = 20,
		humidity_point = 35,
	})

	-- Grassland

	minetest.register_biome({
		name = "grassland",
		node_top = "geo:dirt_grassy",
		depth_top = 1,
		node_filler = "geo:dirt",
		depth_filler = 1,
		node_riverbed = "geo:sand",
		depth_riverbed = 2,
		y_max = 31000,
		y_min = 6,
		heat_point = 50,
		humidity_point = 35,
	})

	minetest.register_biome({
		name = "grassland_dunes",
		node_top = "geo:sand",
		depth_top = 1,
		node_filler = "geo:sand",
		depth_filler = 2,
		node_riverbed = "geo:sand",
		depth_riverbed = 2,
		vertical_blend = 1,
		y_max = 5,
		y_min = 4,
		heat_point = 50,
		humidity_point = 35,
	})

	minetest.register_biome({
		name = "grassland_ocean",
		node_top = "geo:sand",
		depth_top = 1,
		node_filler = "geo:sand",
		depth_filler = 3,
		node_riverbed = "geo:sand",
		depth_riverbed = 2,
		node_cave_liquid = "hydro:water_source",
		y_max = 3,
		y_min = -255,
		heat_point = 50,
		humidity_point = 35,
	})

	minetest.register_biome({
		name = "grassland_under",
		node_cave_liquid = {"hydro:water_source", "geo:lava_source"},
		y_max = -256,
		y_min = -31000,
		heat_point = 50,
		humidity_point = 35,
	})

	-- Coniferous forest

	minetest.register_biome({
		name = "coniferous_forest",
		node_top = "geo:dirt_grassy",
		depth_top = 1,
		node_filler = "geo:dirt",
		depth_filler = 3,
		node_riverbed = "geo:sand",
		depth_riverbed = 2,
		y_max = 31000,
		y_min = 6,
		heat_point = 45,
		humidity_point = 70,
	})

	minetest.register_biome({
		name = "coniferous_forest_dunes",
		node_top = "geo:sand",
		depth_top = 1,
		node_filler = "geo:sand",
		depth_filler = 3,
		node_riverbed = "geo:sand",
		depth_riverbed = 2,
		vertical_blend = 1,
		y_max = 5,
		y_min = 4,
		heat_point = 45,
		humidity_point = 70,
	})

	minetest.register_biome({
		name = "coniferous_forest_ocean",
		node_top = "geo:sand",
		depth_top = 1,
		node_filler = "geo:sand",
		depth_filler = 3,
		node_riverbed = "geo:sand",
		depth_riverbed = 2,
		node_cave_liquid = "hydro:water_source",
		y_max = 3,
		y_min = -255,
		heat_point = 45,
		humidity_point = 70,
	})

	minetest.register_biome({
		name = "coniferous_forest_under",
		node_cave_liquid = {"hydro:water_source", "geo:lava_source"},
		y_max = -256,
		y_min = -31000,
		heat_point = 45,
		humidity_point = 70,
	})

	-- Deciduous forest

	minetest.register_biome({
		name = "deciduous_forest",
		node_top = "geo:dirt_grassy",
		depth_top = 1,
		node_filler = "geo:dirt",
		depth_filler = 3,
		node_riverbed = "geo:sand",
		depth_riverbed = 2,
		y_max = 31000,
		y_min = 1,
		heat_point = 60,
		humidity_point = 68,
	})

	minetest.register_biome({
		name = "deciduous_forest_shore",
		node_top = "geo:dirt",
		depth_top = 1,
		node_filler = "geo:dirt",
		depth_filler = 3,
		node_riverbed = "geo:sand",
		depth_riverbed = 2,
		y_max = 0,
		y_min = -1,
		heat_point = 60,
		humidity_point = 68,
	})

	minetest.register_biome({
		name = "deciduous_forest_ocean",
		node_top = "geo:sand",
		depth_top = 1,
		node_filler = "geo:sand",
		depth_filler = 3,
		node_riverbed = "geo:sand",
		depth_riverbed = 2,
		node_cave_liquid = "hydro:water_source",
		vertical_blend = 1,
		y_max = -2,
		y_min = -255,
		heat_point = 60,
		humidity_point = 68,
	})

	minetest.register_biome({
		name = "deciduous_forest_under",
		node_cave_liquid = {"hydro:water_source", "geo:lava_source"},
		y_max = -256,
		y_min = -31000,
		heat_point = 60,
		humidity_point = 68,
	})

	-- Desert

	minetest.register_biome({
		name = "desert",
		node_top = "geo:red_sand",
		depth_top = 1,
		node_filler = "geo:red_sand",
		depth_filler = 1,
		node_stone = "geo:stone",
		node_riverbed = "geo:red_sand",
		depth_riverbed = 2,
		y_max = 31000,
		y_min = 4,
		heat_point = 92,
		humidity_point = 16,
	})

	minetest.register_biome({
		name = "desert_ocean",
		node_top = "geo:sand",
		depth_top = 1,
		node_filler = "geo:red_sand",
		depth_filler = 3,
		node_stone = "geo:stone",
		node_riverbed = "geo:red_sand",
		depth_riverbed = 2,
		node_cave_liquid = "hydro:water_source",
		vertical_blend = 1,
		y_max = 3,
		y_min = -255,
		heat_point = 92,
		humidity_point = 16,
	})

	minetest.register_biome({
		name = "desert_under",
		node_cave_liquid = {"hydro:water_source", "geo:lava_source"},
		y_max = -256,
		y_min = -31000,
		heat_point = 92,
		humidity_point = 16,
	})

	-- Sandstone desert

	minetest.register_biome({
		name = "sandstone_desert",
		node_top = "geo:red_sand",
		depth_top = 1,
		node_filler = "geo:red_sand",
		depth_filler = 1,
		node_stone = "geo:red_sandstone",
		node_riverbed = "geo:sand",
		depth_riverbed = 2,
		y_max = 31000,
		y_min = 4,
		heat_point = 60,
		humidity_point = 0,
	})

	minetest.register_biome({
		name = "sandstone_desert_ocean",
		node_top = "geo:red_sand",
		depth_top = 1,
		node_filler = "geo:red_sand",
		depth_filler = 3,
		node_stone = "geo:sandstone",
		node_riverbed = "geo:red_sand",
		depth_riverbed = 2,
		node_cave_liquid = "hydro:water_source",
		y_max = 3,
		y_min = -255,
		heat_point = 60,
		humidity_point = 0,
	})

	minetest.register_biome({
		name = "sandstone_desert_under",
		node_cave_liquid = {"hydro:water_source", "geo:lava_source"},
		y_max = -256,
		y_min = -31000,
		heat_point = 60,
		humidity_point = 0,
	})

	-- Cold desert

	minetest.register_biome({
		name = "cold_desert",
		node_top = "geo:sand",
		depth_top = 1,
		node_filler = "geo:sand",
		depth_filler = 1,
		node_riverbed = "geo:sand",
		depth_riverbed = 2,
		y_max = 31000,
		y_min = 4,
		heat_point = 40,
		humidity_point = 0,
	})

	minetest.register_biome({
		name = "cold_desert_ocean",
		node_top = "geo:sand",
		depth_top = 1,
		node_filler = "geo:sand",
		depth_filler = 3,
		node_riverbed = "geo:sand",
		depth_riverbed = 2,
		node_cave_liquid = "hydro:water_source",
		vertical_blend = 1,
		y_max = 3,
		y_min = -255,
		heat_point = 40,
		humidity_point = 0,
	})

	minetest.register_biome({
		name = "cold_desert_under",
		node_cave_liquid = {"hydro:water_source", "geo:lava_source"},
		y_max = -256,
		y_min = -31000,
		heat_point = 40,
		humidity_point = 0,
	})

	-- Savanna

	minetest.register_biome({
		name = "savanna",
		node_top = "geo:dirt_grassy",
		depth_top = 1,
		node_filler = "geo:dirt",
		depth_filler = 1,
		node_riverbed = "geo:sand",
		depth_riverbed = 2,
		y_max = 31000,
		y_min = 1,
		heat_point = 89,
		humidity_point = 42,
	})

	minetest.register_biome({
		name = "savanna_shore",
		node_top = "geo:dirt",
		depth_top = 1,
		node_filler = "geo:dirt",
		depth_filler = 3,
		node_riverbed = "geo:sand",
		depth_riverbed = 2,
		y_max = 0,
		y_min = -1,
		heat_point = 89,
		humidity_point = 42,
	})

	minetest.register_biome({
		name = "savanna_ocean",
		node_top = "geo:sand",
		depth_top = 1,
		node_filler = "geo:sand",
		depth_filler = 3,
		node_riverbed = "geo:sand",
		depth_riverbed = 2,
		node_cave_liquid = "hydro:water_source",
		vertical_blend = 1,
		y_max = -2,
		y_min = -255,
		heat_point = 89,
		humidity_point = 42,
	})

	minetest.register_biome({
		name = "savanna_under",
		node_cave_liquid = {"hydro:water_source", "geo:lava_source"},
		y_max = -256,
		y_min = -31000,
		heat_point = 89,
		humidity_point = 42,
	})

	-- Rainforest

	minetest.register_biome({
		name = "rainforest",
		node_top = "geo:dirt_grassy",
		depth_top = 1,
		node_filler = "geo:dirt",
		depth_filler = 3,
		node_riverbed = "geo:sand",
		depth_riverbed = 2,
		y_max = 31000,
		y_min = 1,
		heat_point = 86,
		humidity_point = 65,
	})

	minetest.register_biome({
		name = "rainforest_swamp",
		node_top = "geo:dirt",
		depth_top = 1,
		node_filler = "geo:dirt",
		depth_filler = 3,
		node_riverbed = "geo:sand",
		depth_riverbed = 2,
		y_max = 0,
		y_min = -1,
		heat_point = 86,
		humidity_point = 65,
	})

	minetest.register_biome({
		name = "rainforest_ocean",
		node_top = "geo:sand",
		depth_top = 1,
		node_filler = "geo:sand",
		depth_filler = 3,
		node_riverbed = "geo:sand",
		depth_riverbed = 2,
		node_cave_liquid = "hydro:water_source",
		vertical_blend = 1,
		y_max = -2,
		y_min = -255,
		heat_point = 86,
		humidity_point = 65,
	})

	minetest.register_biome({
		name = "rainforest_under",
		node_cave_liquid = {"hydro:water_source", "geo:lava_source"},
		y_max = -256,
		y_min = -31000,
		heat_point = 86,
		humidity_point = 65,
	})
end


--
-- Register decorations
--

local function register_grass_decoration()
	minetest.register_decoration({
		name = "flora:grass",
		deco_type = "simple",
		place_on = {"geo:dirt_grassy"},
		sidelen = 16,
		noise_params = {
			offset = 0,
			scale = 0.06,
			spread = {x = 200, y = 200, z = 200},
			seed = 329,
			octaves = 3,
			persist = 0.6
		},
		biomes = {"grassland", "deciduous_forest"},
		y_max = 31000,
		y_min = 1,
		decoration = "flora:grass",
	})

    minetest.register_decoration({
		name = "flora:grass",
		deco_type = "simple",
		place_on = {"geo:dirt_grassy"},
		sidelen = 16,
		noise_params = {
			offset = 0.05,
			scale = 0.01,
			spread = {x = 200, y = 200, z = 200},
			seed = 329,
			octaves = 3,
			persist = 0.6
		},
		biomes = {"savanna"},
		y_max = 31000,
		y_min = 1,
		decoration = "flora:grass",
	})

	minetest.register_decoration({
		name = "flora:grass",
		deco_type = "simple",
		place_on = {"geo:dirt_grassy"},
		sidelen = 16,
		noise_params = {
			offset = 0,
			scale = 0.2,
			spread = {x = 100, y = 100, z = 100},
			seed = 801,
			octaves = 3,
			persist = 0.7
		},
		biomes = {"coniferous_forest"},
		y_max = 31000,
		y_min = 6,
		decoration = "flora:grass",
	})

	minetest.register_decoration({
		name = "flora:junglegrass",
		deco_type = "simple",
		place_on = {"geo:dirt_grassy"},
		sidelen = 80,
		fill_ratio = 0.1,
		biomes = {"rainforest"},
		y_max = 31000,
		y_min = 1,
		decoration = "flora:grass",
	})
end

local function register_decorations()
	-- Savanna bare dirt patches.
	-- Must come before all savanna decorations that are placed on dry grass.
	-- Noise is similar to long dry grass noise, but scale inverted, to appear
	-- where long dry grass is least dense and shortest.

	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"geo:dirt_grassy"},
		sidelen = 4,
		noise_params = {
			offset = -1.5,
			scale = -1.5,
			spread = {x = 200, y = 200, z = 200},
			seed = 329,
			octaves = 4,
			persist = 1.0
		},
		biomes = {"savanna"},
		y_max = 31000,
		y_min = 1,
		decoration = "geo:dirt",
		place_offset_y = -1,
		flags = "force_placement",
	})

	-- Oak tree and log

	minetest.register_decoration({
		name = "geo:oak_tree",
		deco_type = "schematic",
		place_on = {"geo:dirt_grassy"},
		sidelen = 16,
		noise_params = {
			offset = 0.024,
			scale = 0.015,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"deciduous_forest"},
		y_max = 31000,
		y_min = 1,
		schematic = satlantis.flora.tree_schematics.oak,
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})

	-- Emergent jungle tree
	-- Due to 32 node height, altitude is limited and prescence depends on chunksize

	local chunksize = tonumber(minetest.get_mapgen_setting("chunksize"))
	if chunksize >= 5 then
		minetest.register_decoration({
			name = "flora:emergent_jungle_tree",
			deco_type = "schematic",
			place_on = {"geo:dirt_grassy"},
			sidelen = 80,
			noise_params = {
				offset = 0.0,
				scale = 0.0025,
				spread = {x = 250, y = 250, z = 250},
				seed = 2685,
				octaves = 3,
				persist = 0.7
			},
			biomes = {"rainforest"},
			y_max = 32,
			y_min = 1,
			schematic = satlantis.flora.tree_schematics.jungle_emergent,
			flags = "place_center_x, place_center_z",
			rotation = "random",
			place_offset_y = -4,
		})
	end

	-- Jungle tree and log

	minetest.register_decoration({
		name = "flora:jungle_tree",
		deco_type = "schematic",
		place_on = {"geo:dirt_grassy"},
		sidelen = 80,
		fill_ratio = 0.1,
		biomes = {"rainforest"},
		y_max = 31000,
		y_min = 1,
		schematic = satlantis.flora.tree_schematics.jungle,
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})

	-- Swamp jungle trees

	minetest.register_decoration({
		name = "flora:jungle_tree(swamp)",
		deco_type = "schematic",
		place_on = {"geo:dirt"},
		sidelen = 16,
		-- Noise tuned to place swamp trees where papyrus is absent
		noise_params = {
			offset = 0.0,
			scale = -0.1,
			spread = {x = 200, y = 200, z = 200},
			seed = 354,
			octaves = 1,
			persist = 0.5
		},
		biomes = {"rainforest_swamp"},
		y_max = 0,
		y_min = -1,
		schematic = satlantis.flora.tree_schematics.jungle,
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})

	-- Taiga and temperate coniferous forest pine tree, small pine tree and log

	minetest.register_decoration({
		name = "flora:spruce_tree",
		deco_type = "schematic",
		place_on = {"geo:dirt_snowy", "geo:dirt_grassy"},
		sidelen = 16,
		noise_params = {
			offset = 0.010,
			scale = 0.048,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"taiga", "coniferous_forest"},
		y_max = 31000,
		y_min = 4,
		schematic = satlantis.flora.tree_schematics.spruce,
		flags = "place_center_x, place_center_z",
	})

	minetest.register_decoration({
		name = "flora:small_spruce_tree",
		deco_type = "schematic",
		place_on = {"geo:dirt_snowy", "geo:dirt_grassy"},
		sidelen = 16,
		noise_params = {
			offset = 0.010,
			scale = -0.048,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"taiga", "coniferous_forest"},
		y_max = 31000,
		y_min = 4,
		schematic = satlantis.flora.tree_schematics.spruce_small,
		flags = "place_center_x, place_center_z",
	})

	-- Acacia tree and log

	minetest.register_decoration({
		name = "flora:acacia_tree",
		deco_type = "schematic",
		place_on = {"geo:dirt_grassy"},
		sidelen = 16,
		noise_params = {
			offset = 0,
			scale = 0.002,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"savanna"},
		y_max = 31000,
		y_min = 1,
		schematic = satlantis.flora.tree_schematics.acaica,
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})

	-- Aspen tree and log

	minetest.register_decoration({
		name = "flora:aspen_tree",
		deco_type = "schematic",
		place_on = {"geo:dirt_grassy"},
		sidelen = 16,
		noise_params = {
			offset = 0.0,
			scale = -0.015,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"deciduous_forest"},
		y_max = 31000,
		y_min = 1,
		schematic = satlantis.flora.tree_schematics.aspen,
		flags = "place_center_x, place_center_z",
	})


	-- Cactus

	minetest.register_decoration({
		name = "flora:cactus",
		deco_type = "simple",
		place_on = {"geo:red_sand"},
		sidelen = 16,
		noise_params = {
			offset = -0.0003,
			scale = 0.0009,
			spread = {x = 200, y = 200, z = 200},
			seed = 230,
			octaves = 3,
			persist = 0.6
		},
		biomes = {"desert"},
		y_max = 31000,
		y_min = 4,
		decoration = "flora:cactus",
		height = 1,
		height_max = 5,
	})

	-- Papyrus

	-- Dirt version for rainforest swamp

	minetest.register_decoration({
		name = "flora:papyrus_on_dirt",
		deco_type = "simple",
		place_on = {"geo:dirt"},
		sidelen = 16,
		noise_params = {
			offset = -0.3,
			scale = 0.7,
			spread = {x = 200, y = 200, z = 200},
			seed = 354,
			octaves = 3,
			persist = 0.7
		},
		biomes = {"rainforest_swamp"},
		y_max = 0,
		y_min = 0,
		decoration = "flora:papyrus",
		height = 1,
		height_max = 5,
	})

	-- Dry dirt version for savanna shore

	minetest.register_decoration({
		name = "flora:papyrus_on_dry_dirt",
		deco_type = "simple",
		place_on = {"geo:dirt"},
		sidelen = 16,
		noise_params = {
			offset = -0.3,
			scale = 0.7,
			spread = {x = 200, y = 200, z = 200},
			seed = 354,
			octaves = 3,
			persist = 0.7
		},
		biomes = {"savanna_shore"},
		y_max = 0,
		y_min = 0,
		decoration = "flora:papyrus",
		height = 1,
		height_max = 5,
	})

	-- Grasses

	register_grass_decoration()

	-- Marram grass

	minetest.register_decoration({
		name = "flora:marram_grass",
		deco_type = "simple",
		place_on = {"geo:sand"},
		sidelen = 4,
		noise_params = {
			offset = -0.7,
			scale = 4.0,
			spread = {x = 16, y = 16, z = 16},
			seed = 513337,
			octaves = 1,
			persist = 0.0,
			flags = "absvalue, eased"
		},
		biomes = {"coniferous_forest_dunes", "grassland_dunes"},
		y_max = 6,
		y_min = 4,
		decoration = "flora:grass",
	})

	-- Tundra moss

	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"geo:dirt"},
		sidelen = 4,
		noise_params = {
			offset = -0.8,
			scale = 2.0,
			spread = {x = 100, y = 100, z = 100},
			seed = 53995,
			octaves = 3,
			persist = 1.0
		},
		biomes = {"tundra"},
		y_max = 50,
		y_min = 2,
		decoration = "geo:dirt_grassy",
		place_offset_y = -1,
		flags = "force_placement",
	})

	-- Tundra patchy snow

	minetest.register_decoration({
		deco_type = "simple",
		place_on = {
			"geo:dirt_grassy",
			"geo:dirt",
			"geo:stone",
			"geo:gravel"
		},
		sidelen = 4,
		noise_params = {
			offset = 0,
			scale = 1.0,
			spread = {x = 100, y = 100, z = 100},
			seed = 172555,
			octaves = 3,
			persist = 1.0
		},
		biomes = {"tundra", "tundra_beach"},
		y_max = 50,
		y_min = 1,
		decoration = "hydro:snow",
	})
end

--
-- Detect mapgen to select functions
--

minetest.clear_registered_biomes()
minetest.clear_registered_ores()
minetest.clear_registered_decorations()

register_biomes()
register_ores()
register_decorations()
