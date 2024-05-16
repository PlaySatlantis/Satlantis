-- CONFIGURE SETTINGS

local mod = "phone_rewards"

-- folder where the settings files will be copied into the world directory (if specified, must end with "/")
local settings_dir = ""

local original_files = {
	"REWARDS.lua",
}

-----------------



local modpath = minetest.get_modpath(mod)
local world_dir = minetest.get_worldpath() .. ("/%s/"):format(mod)
settings_dir = world_dir..settings_dir

minetest.mkdir(world_dir) -- init world dir
minetest.mkdir(settings_dir) -- init settings dir



local function from_path_to_file(path)
	-- path/like/this/file.(lua || md) -> file.(lua || md)
	return string.match(path, [[([^\\\/]*.lua)]]) or string.match(path, [[([^\\\/]*.md)]])
end



local function is_file_in_dir(dir, file)
	file = from_path_to_file(file)

	for i, file_ in ipairs(minetest.get_dir_list(dir, false)) do
		if file_ == file then return true end
	end
end



local function import_default(file)
	if not string.find(file, ".lua") then return end

	local default_file = ("%s/%s"):format(modpath, file)
	dofile(default_file)
end



local function import_custom(file)
	local default_file = ("%s/%s"):format(modpath, file)
	local custom_file = settings_dir..from_path_to_file(file)

	if not is_file_in_dir(settings_dir, file) then
		local default_content = io.open(default_file, "r"):read("*all")
		default_content = default_content:gsub("--!([^\n]*[\n]?)", "") -- remove warning comments

		minetest.safe_file_write(custom_file, default_content)
	end

	if not string.find(file, ".lua") then return end

	dofile(custom_file)
end



for i, file in ipairs(original_files) do
	import_default(file)
	import_custom(file)
end