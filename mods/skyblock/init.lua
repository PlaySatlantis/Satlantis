skyblock = {}

local storage = minetest.get_mod_storage()

local CEL_SIZE = 256
local CEL_PADDING = 256
local CEL_TOTAL_SIZE = CEL_SIZE + CEL_PADDING

local MAX_WIDTH = 60000
local GRID_WIDTH = math.floor(MAX_WIDTH / CEL_TOTAL_SIZE)
local GRID_VOLUME = GRID_WIDTH * GRID_WIDTH

local MIN_POS = vector.new(-30000, 30000 - CEL_TOTAL_SIZE, -30000)

skyblock.get_cel = function(id)
    if id >= GRID_VOLUME then return end

    local grid_x = id % GRID_WIDTH
    local grid_z = math.floor(id / GRID_WIDTH)

    local cel_pos = vector.new(grid_x * CEL_TOTAL_SIZE, 0, grid_z * CEL_TOTAL_SIZE)
    local cel_center = vector.new(CEL_TOTAL_SIZE / 2, CEL_TOTAL_SIZE / 2, CEL_TOTAL_SIZE / 2):floor()
    local padded_pos = cel_pos + vector.new(CEL_PADDING / 2, CEL_PADDING / 2, CEL_PADDING / 2)

    return {
        pos = cel_pos + MIN_POS,
        center = cel_center + MIN_POS,
        padded = padded_pos + MIN_POS,
    }
end

minetest.register_node("skyblock:wall", {
    drawtype = "airlike",
    -- tiles = {"blank.png^[invert:rgba"},
    pointable = false,
    walkable = true,
    diggable = false,
    paramtype = "light",
    sunlight_propagates = true,
})

local CID_WALL = minetest.get_content_id("skyblock:wall")
local PLATFORM_NODE = "default:steelblock"
local PLATFORM_RADIUS = 2

local function generate_wall(pos1, pos2)
    local vm = minetest.get_voxel_manip(pos1, pos2)
    local emin, emax = vm:get_emerged_area()
    local data = vm:get_data()

    local va = VoxelArea(emin, emax)
    print(dump(va:getExtent()))
    for idx in va:iterp(pos1, pos2) do
        data[idx] = CID_WALL
    end

    vm:set_data(data)
    vm:write_to_map(true)
end

skyblock.generate_cel = function(id)
    local cel = skyblock.get_cel(id)

    local opposite = cel.padded + vector.new(CEL_SIZE, CEL_SIZE, CEL_SIZE)

    generate_wall(cel.padded, cel.padded + vector.new(CEL_SIZE, CEL_SIZE, 0))
    generate_wall(cel.padded, cel.padded + vector.new(0, CEL_SIZE, CEL_SIZE))
    generate_wall(cel.padded + vector.new(CEL_SIZE, 0, 0), cel.padded + opposite)
    generate_wall(cel.padded + vector.new(0, CEL_SIZE, 0), cel.padded + opposite)
    generate_wall(cel.padded + vector.new(0, 0, CEL_SIZE), cel.padded + opposite)

    for x = cel.center.x - PLATFORM_RADIUS, cel.center.x + PLATFORM_RADIUS do
        for z = cel.center.z - PLATFORM_RADIUS, cel.center.z + PLATFORM_RADIUS do
            minetest.set_node(vector.new(x, cel.center.y, z), {name = PLATFORM_NODE})
        end
    end
end
