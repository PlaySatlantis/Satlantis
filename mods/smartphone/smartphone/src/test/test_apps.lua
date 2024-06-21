smartphone.register_app("smartphone:rewards", {
	icon = "app_rewards.png",
	name = "Rewards",
	get_content = function (self, player)
		return "label[2,2;Rewards]"
	end,
	priv_to_visualize = "visualize"
})

smartphone.register_app("smartphone:skins", {
	icon = "app_skins.png",
	name = "Skins",
	get_content = function (self, player)
		return "label[2,2;Skins]"
	end,
	priv_to_open = "open"
})

smartphone.register_app("smartphone:wiki", {
	icon = "app_wiki.png",
	name = "Wiki",
	get_content = function (self, player)
		return "label[2,2;Wiki]"
	end
})

smartphone.register_app("smartphone:test_page", {
	icon = "app_wiki.png",
	name = "Test Page",

	get_content = function (self, player)
		minetest.after(3, function() self:open_page(player, 1) end)
		minetest.after(5, function() self:open_page(player, 2) end)
		return "label[0.1,2;After 3s a page will open, to try the navigation feature]"
	end,

	get_content_page1 = function (self, player)
		return "label[2,3;I am the test page 1]"
	end,

	get_content_page2 = function (self, player)
		return "label[2,3;I am the test page 2]"
	end,

	open_page = function (self, player, num)
		smartphone.open_page(player, "smartphone:test_page.page"..num)
	end
})