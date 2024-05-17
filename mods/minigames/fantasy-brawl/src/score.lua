local function assign_tier() end
local function update_tiers_hud() end


function fbrawl.update_score(arena)
	local scores = {}
	local score_id = 0

	for pl_name, props in pairs(arena.players) do
		local score = props.kills - (props.deaths / 2)
		table.insert(scores, {pl_name = pl_name, kills = props.kills, score = score, id = score_id})
		score_id = score_id + 1
	end

	table.sort(scores, function (a, b)
		if	a.kills ~= b.kills then return a.kills > b.kills
		elseif a.score ~= b.score then return a.score > b.score 
		else return a.id > b.id end
	end)

	arena.scores = scores
end



function fbrawl.update_score_hud(pl_name)
	local arena = arena_lib.get_arena_by_player(pl_name)

	fbrawl.update_score(arena)
	update_tiers_hud(pl_name)
end



function update_tiers_hud(pl_name) 
	local arena = arena_lib.get_arena_by_player(pl_name)

	for i=1, 3, 1 do
		local classified_pl_name = "-"

		if arena.scores[i] then classified_pl_name = arena.scores[i].pl_name end

		if i == 1 then
			assign_tier("golden", pl_name, classified_pl_name)
		elseif i == 2 then
			assign_tier("iron", pl_name, classified_pl_name)
		elseif i == 3 then
			assign_tier("bronze", pl_name, classified_pl_name)
		else
			break
		end
	end
end



function assign_tier(tier, pl_name, classified_pl_name) 
	local panel = panel_lib.get_panel(pl_name, "fbrawl:podium")
	local arena = arena_lib.get_arena_by_player(pl_name)
	local override_hud_value = false

	if classified_pl_name == "-" then override_hud_value = "-" end

	if 
		not arena.players 
		or 
		((not arena.players[classified_pl_name] or not arena.players[classified_pl_name].kills) and not override_hud_value)
	then
		return
	end
	
	panel:update(nil, {
		[tier.."_pl_name"] = {text=override_hud_value or classified_pl_name},
		[tier.."_deaths_value"] = {text=override_hud_value or arena.players[classified_pl_name].deaths},
		[tier.."_kills_value"] = {text=override_hud_value or arena.players[classified_pl_name].kills},
	}, nil)
end