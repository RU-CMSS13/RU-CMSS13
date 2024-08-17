SUBSYSTEM_DEF(battlepass)
	name = "Battlepass"
	flags = SS_NO_FIRE
	init_order = SS_INIT_BATTLEPASS

	var/list/marine_challenges = list()
	var/list/xeno_challenges = list()

	var/list/marine_battlepass_earners = list()
	var/list/xeno_battlepass_earners = list()

/datum/controller/subsystem/battlepass/Initialize()
	for(var/challenge as anything in GLOB.current_battlepass.mapped_point_sources["daily"])
		var/datum/battlepass_challenge/challenge_path = GLOB.current_battlepass.mapped_point_sources["daily"][challenge]["path"]
		var/pick_weight = initial(challenge_path.pick_weight)
		if("pick_weight" in GLOB.current_battlepass.mapped_point_sources["daily"][challenge])
			pick_weight = GLOB.current_battlepass.mapped_point_sources["daily"][challenge]["pick_weight"]

		switch(initial(challenge_path.challenge_category))
			if(CHALLENGE_NONE)
				continue

			if(CHALLENGE_HUMAN)
				marine_challenges[challenge_path] = pick_weight

			if(CHALLENGE_XENO)
				xeno_challenges[challenge_path] = pick_weight

	for(var/a in flist("data/player_saves/"))
		for(var/ckey_str in flist("data/player_saves/[a]/"))
			if(!fexists("data/player_saves/[a]/[ckey_str]/battlepass.sav"))
				continue

			var/savefile/save_obj = new("data/player_saves/[a]/[ckey_str]/battlepass.sav")
			var/datum/entity/battlepass_player/battlepass = DB_ENTITY(/datum/entity/battlepass_player)
			var/datum/entity/player/bp_player = get_player_from_key(ckey_str)
			bp_player.sync()
			battlepass.player_id = bp_player.id
			battlepass.season = 1
			battlepass.tier = save_obj["tier"]
			battlepass.xp = save_obj["xp"]
			battlepass.save()
			fdel("data/player_saves/[a]/[ckey_str]/battlepass.sav")

	return SS_INIT_SUCCESS

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
		for(var/datum/entity/battlepass_player/battlepass in marine_battlepass_earners)
			battlepass.add_xp(marine_points)

	if(xeno_points)
		for(var/datum/entity/battlepass_player/battlepass in xeno_battlepass_earners)
			battlepass.add_xp(xeno_points)
