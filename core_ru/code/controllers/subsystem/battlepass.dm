GLOBAL_LIST_INIT_TYPED(battlepass_challenges_by_code_name, /datum/battlepass_challenge, load_battlepass_challenges())

/proc/load_battlepass_challenges()
	var/list/challenges = list()
	for(var/datum/battlepass_challenge/challenge_path as anything in subtypesof(/datum/battlepass_challenge))
		challenges[initial(challenge_path.code_name)] = challenge_path
	return challenges

GLOBAL_LIST(battlepass_challenges)

SUBSYSTEM_DEF(battlepass)
	name = "Battlepass"
	flags = SS_NO_FIRE
	init_order = SS_INIT_BATTLEPASS

	var/list/marine_battlepass_earners = list()
	var/list/xeno_battlepass_earners = list()

/datum/controller/subsystem/battlepass/Initialize()
	await_initialization()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/battlepass/proc/await_initialization()
	set waitfor = FALSE
	UNTIL(GLOB.current_battlepass)
	GLOB.battlepass_challenges = list("marine_challenges" = list(), "xeno_challenges" = list())
	for(var/challenge as anything in GLOB.current_battlepass.mapped_point_sources["daily"])
		var/datum/battlepass_challenge/challenge_path = GLOB.battlepass_challenges_by_code_name[challenge]
		var/pick_weight = initial(challenge_path.pick_weight)
		if(GLOB.current_battlepass.mapped_point_sources["daily"][challenge]["piwgt"])
			pick_weight = GLOB.current_battlepass.mapped_point_sources["daily"][challenge]["piwgt"]

		switch(initial(challenge_path.challenge_category))
			if(CHALLENGE_NONE)
				continue

			if(CHALLENGE_HUMAN)
				GLOB.battlepass_challenges["marine_challenges"][challenge_path] = pick_weight

			if(CHALLENGE_XENO)
				GLOB.battlepass_challenges["xeno_challenges"][challenge_path] = pick_weight

	for(var/a in flist("data/player_saves/"))
		for(var/ckey_str in flist("data/player_saves/[a]/"))
			if(!fexists("data/player_saves/[a]/[ckey_str]/battlepass.sav"))
				continue
			fdel("data/player_saves/[a]/[ckey_str]/battlepass.sav")

/datum/controller/subsystem/battlepass/proc/get_challenge(challenge_type = CHALLENGE_NONE)
	switch(challenge_type)
		if(CHALLENGE_NONE)
			return

		if(CHALLENGE_HUMAN)
			return pick_weight(GLOB.battlepass_challenges["marine_challenges"])

		if(CHALLENGE_XENO)
			return pick_weight(GLOB.battlepass_challenges["xeno_challenges"])

/datum/controller/subsystem/battlepass/proc/give_sides_points(marine_points = 0, xeno_points = 0)
	if(marine_points)
		for(var/datum/entity/battlepass_player/battlepass in marine_battlepass_earners)
			battlepass.add_xp(marine_points)

	if(xeno_points)
		for(var/datum/entity/battlepass_player/battlepass in xeno_battlepass_earners)
			battlepass.add_xp(xeno_points)
