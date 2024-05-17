local fmspecs_cache = {} -- ["file.md"] = formspec



local app_def = {
	icon = "app_wiki.png",
	name = "Wiki",
	bg_color = "#7a9090",
	
	get_height = function (self, player, page)
		if page then return false end
		return #wiki.index * 1.2
	end,
	
	get_content = function (self, player, page)
		if not page then
			local title = "hypertext[0.5,0;"..(smartphone.fs_width-1)..",2;title;<global size=64 halign=center valign=middle><b>Wiki</b>]"
			local subtitle = "hypertext[0.5,1.5;"..(smartphone.fs_width-1)..",2;title;<global size=21 halign=center valign=middle><b>Click on one of the index elements to navigate to the corresponding page</b>]"
			local index = ""
			local pages = wiki.index

			-- hypertext[<X>,<Y>;<W>,<H>;<name>;<text>]
			local y = 3.6
			for i, page in ipairs(pages) do
				local formatted_page_name = page:gsub(".md", ""):gsub("_", " ")
				local btn_name = "page_btn|"..page:gsub(".md", "")
				index = index .. ("hypertext[0.5,%f;%f,6;%s;<big><center><action name=%s><style color=#ffffff>%s</style></action></center></big>]"):format(y, (smartphone.fs_width-1), btn_name, btn_name, formatted_page_name)
				y = y + 0.8
			end

			return title..subtitle..index
		else
			local file = minetest.get_worldpath().."/wiki/"..page..".md"
			local file_exists = io.open(file, "r")
			
			if not file_exists then
				return "label[1,1;Error: Page not found]"
			end
			file_exists:close()

			local white = "#ffffff"
			local settings = {
				background_color = "#00000000",
				font_color = white,
				heading_1_color = white,
				heading_2_color = white,
				heading_3_color = white,
				heading_4_color = white,
				heading_5_color = white,
				heading_6_color = white,
				code_block_mono_color = white,
				mono_color = white,
				block_quote_color = white,
				heading_1_size = "64",
				heading_2_size = "48",
				heading_3_size = "24",
				heading_4_size = "18",
				heading_5_size = "14",
				heading_6_size = "11",
			}
			fmspecs_cache[page] =
				fmspecs_cache[page]
				or md2f.md2ff(0.5, 0, (smartphone.fs_width-1), smartphone.content_height, file, nil, settings)

			return fmspecs_cache[page]
		end
	end
}

smartphone.register_app("wiki:wiki", app_def)



minetest.register_on_player_receive_fields(function(player, formname, fields)
	local app = smartphone.get_app(formname)

	if not app or not app.technical_name == "wiki:wiki" then return false end

	for field, _ in pairs(fields) do
		if string.find(field, "page_btn") then
			local page_name = string.split(field, "|")[2] or "none"
			smartphone.open_page(player, "wiki:wiki."..page_name)
			return true
		end
	end

	return false
end)