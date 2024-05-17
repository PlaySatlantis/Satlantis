
local function register_priv(priv, description) end
local function wrap_app_content(app, player, content, page, ...) end
local function make_scrollbaroptions_for_scroll_container(visible_l, total_l, scroll_factor) end

smartphone.apps = {}
smartphone.apps_ordered = {}  -- alphabetically ordered apps list ( {idx = def, ...} )



--[[
	def: {
		icon: string,
		name: string,
		priv_to_visualize: string,
		priv_to_open: string,
		get_content: function(self, player, [page / ...]) -> string
	}
]]
function smartphone.register_app(technical_name, def)
	assert(type(technical_name) == "string", "You're trying to register an app without a technical_name")
	assert(type(def) == "table", "The "..technical_name.." app must have a definition table!")
	assert(type(def.name) == "string", "The "..technical_name.." app must have a name!")
	assert(type(def.icon) == "string", "The "..def.name.." app must have an icon!")
	assert(type(def.get_content) == "function", "The "..def.name.." app must have a get_content() function!")

	def.technical_name = technical_name

	-- privs management
	def.priv_to_open = def.priv_to_open or def.priv_to_visualize
	register_priv(def.priv_to_visualize, "To visualize and open the "..def.name.." app")
	register_priv(def.priv_to_open, "To open the "..def.name.." app")

	smartphone.apps[technical_name] = def
	smartphone.apps_ordered[#smartphone.apps_ordered+1] = def
	table.sort(smartphone.apps_ordered, function(a, b)
		return a.name:upper() < b.name:upper()
	end)
end


function smartphone.open_smartphone(player)
	if arena_lib and arena_lib.is_player_in_arena(player:get_player_name()) then return false end
	minetest.show_formspec(player:get_player_name(), "smartphone:smartphone", smartphone.get_smartphone_formspec(player))
end


function smartphone.open_app(player, technical_name, ...)
	local pl_name = player:get_player_name()
	local app = smartphone.get_app(technical_name)
	local page = string.split(technical_name, ".")[2]

	if not app then return false end
	if arena_lib and arena_lib.is_player_in_arena(pl_name) then return false end

	if app.priv_to_open and not minetest.get_player_privs(pl_name)[app.priv_to_open] then
		smartphone.error(pl_name, "You can't open the "..app.name.." app!")
		return false
	end

	local content
	if not page then
		content = app:get_content(player, nil, ...)
	else
		app["get_content_"..page] = app["get_content_"..page] or function() return false end
		content = app["get_content_"..page](app, player, ...) or app:get_content(player, page, ...)
	end

	minetest.show_formspec(player:get_player_name(), technical_name, wrap_app_content(app, player, content, page, ...))
end



function smartphone.open_page(player, page_formname, ...)
	assert(string.split(page_formname, ".")[2], page_formname.." page is not a valid page formname")
	smartphone.open_app(player, page_formname, ...)
end



function smartphone.get_app(technical_name)
	technical_name = string.split(technical_name, ".")[1] -- remove page name if any
	return smartphone.apps[technical_name] or false
end



function smartphone.is_app(technical_name)
	return smartphone.get_app(technical_name)
end





---------------------
---------------------
-- LOCAL FUNCTIONS --
---------------------
---------------------

function register_priv(priv, description)
	if type(priv) ~= "string" or minetest.registered_privileges[priv] then return end
	minetest.register_privilege(priv, {
		description = description,
		give_to_singleplayer = false,
	})
end


function wrap_app_content(app, player, content, page, ...)
	local s = smartphone
	app.get_height = app.get_height or function() return false end
	local custom_content_height = app:get_height(player, page, ...) or s.content_height
	local scrollbaroptions = make_scrollbaroptions_for_scroll_container(s.content_height, custom_content_height, 0.1)

	return
		s.get_header(app) ..
		scrollbaroptions..
		"scrollbar[0,0;0,0;vertical;app_content;]" ..
		"scroll_container[0,"..s.content_y..";"..s.fs_width..","..s.content_height..";app_content;vertical]"..
		content ..
		"scroll_container_end[]"..
		s.smartphone_footer
end



--- Creates a scrollbaroptions for a scroll_container
--- thanks to: https://github.com/minetest/minetest/issues/12482#issuecomment-1169332395
-- @param visible_l the length of the scroll_container and scrollbar
-- @param total_l length of the scrollable area
-- @param scroll_factor as passed to scroll_container
function make_scrollbaroptions_for_scroll_container(app_height, content_height, scroll_factor)
	if content_height < app_height then
		return ("scrollbaroptions[min=0;max=0;]")
	end

	local thumb_size = (app_height / content_height) * (content_height - app_height)
	local max = content_height - app_height
	return ("scrollbaroptions[min=0;max=%f;thumbsize=%f]"):format(max / scroll_factor, thumb_size / scroll_factor)
end