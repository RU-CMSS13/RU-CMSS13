SUBSYSTEM_DEF(battlepass)
	name = "Battlepass"
	flags = SS_NO_FIRE
	init_order = SS_INIT_BATTLEPASS

	var/list/actual_challenges

	var/list/marine_challenges = list()
	var/list/xeno_challenges = list()

	var/list/marine_battlepass_earners = list()
	var/list/xeno_battlepass_earners = list()

/datum/controller/subsystem/battlepass/Initialize()
	actual_challenges = GLOB.current_battlepass.mapped_point_sources["daily"]
	for(var/challenge as anything in actual_challenges)
		var/datum/battlepass_challenge/challenge_path = actual_challenges[challenge]["path"]
		var/pick_weight = initial(challenge_path.pick_weight)
		if("pick_weight" in actual_challenges[challenge])
			pick_weight = actual_challenges[challenge]["pick_weight"]

		switch(initial(challenge_path.challenge_category))
			if(CHALLENGE_NONE)
				continue

			if(CHALLENGE_HUMAN)
				marine_challenges[challenge_path] = actual_challenges[challenge]["pick_weight"]

			if(CHALLENGE_XENO)
				xeno_challenges[challenge_path] = actual_challenges[challenge]["pick_weight"]

	for(var/client/client as anything in GLOB.clients)
		if(!client.player_data?.battlepass)
			continue

		client.player_data.battlepass.verify_rewards()

	return SS_INIT_SUCCESS

/// Returns a typepath of a challenge of the given category
/datum/controller/subsystem/battlepass/proc/get_challenge(challenge_type = CHALLENGE_NONE)
	switch(challenge_type)
		if(CHALLENGE_NONE)
			return

		if(CHALLENGE_HUMAN)
			return pick_weight(marine_challenges)

		if(CHALLENGE_XENO)
			return pick_weight(xeno_challenges)


/datum/controller/subsystem/battlepass/proc/give_sides_points(marine_points = 0, xeno_points = 0)
	if(marine_points)
		give_side_points(marine_points, marine_battlepass_earners)

	if(xeno_points)
		give_side_points(xeno_points, xeno_battlepass_earners)

/datum/controller/subsystem/battlepass/proc/give_side_points(point_amount = 0, ckey_list)
	if(!islist(ckey_list))
		CRASH("give_side_points in SSbattlepass called without giving a list of ckeys")

	for(var/ckey in ckey_list)
		if(ckey in GLOB.directory)
			var/client/ckey_client = GLOB.directory[ckey]
			if(ckey_client.player_data?.battlepass)
				ckey_client.player_data.battlepass.add_xp(point_amount)
		else
			if(!fexists("data/player_saves/[copytext(ckey,1,2)]/[ckey]/battlepass.sav"))
				continue

			var/savefile/ckey_save = new("data/player_saves/[copytext(ckey,1,2)]/[ckey]/battlepass.sav")

			ckey_save["xp"] += point_amount // if they're >=10 XP, it'll get sorted next time they log on

/datum/controller/subsystem/battlepass/proc/get_bp_ge_to_tier(mob/caller, tiernum = 1)
	var/i = 0
	for(var/a in flist("data/player_saves/"))
		for(var/ckey_str in flist("data/player_saves/[a]/"))
			if(!fexists("data/player_saves/[a]/[ckey_str]/battlepass.sav"))
				continue

			var/savefile/save_obj = new("data/player_saves/[a]/[ckey_str]/battlepass.sav")
			if(save_obj["tier"] >= tiernum)
				i++
	to_chat(caller, SPAN_NOTICE("[i]"))


/datum/controller/subsystem/battlepass/proc/get_bp_xp_total(mob/caller)
	var/xp = 0
	for(var/a in flist("data/player_saves/"))
		for(var/ckey_str in flist("data/player_saves/[a]/"))
			if(!fexists("data/player_saves/[a]/[ckey_str]/battlepass.sav"))
				continue

			var/savefile/save_obj = new("data/player_saves/[a]/[ckey_str]/battlepass.sav")
			xp += (((save_obj["tier"] - 1) * 10) + save_obj["xp"])
	to_chat(caller, SPAN_NOTICE("[xp]"))
