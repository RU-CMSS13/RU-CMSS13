/datum/entity/player/proc/load_battlepass()
//PORT OUR SAVES
	UNTIL(GLOB.current_battlepass)
	var/target_file = "data/player_saves/[copytext(ckey,1,2)]/[ckey]/battlepass.sav"
	if(fexists(target_file))
		var/savefile/battlepass_save = new(target_file)
		battlepass = new()
		battlepass.player_id = id
		battlepass.season = GLOB.current_battlepass.season
		battlepass.tier = battlepass_save["tier"]
		battlepass.xp = battlepass_save["xp"]
		battlepass.check_tier_up(FALSE)
		battlepass.check_daily_challenge_reset()
		battlepass.save()
		battlepass.sync()
		if(SSbattlepass.initialized)
			battlepass.verify_rewards()
		fdel(target_file)
	else
		DB_FILTER(/datum/entity/client_battlepass, DB_AND(DB_COMP("player_id", DB_EQUALS, id), DB_COMP("season", DB_EQUALS, GLOB.current_battlepass.season)), CALLBACK(src, TYPE_PROC_REF(/datum/entity/player, on_read_battlepass)))


/datum/entity/player/proc/on_read_battlepass(list/datum/entity/client_battlepass/_battlepass)
	if(_battlepass)
		battlepass = pick(_battlepass)
	else
		battlepass = new()
		battlepass.player_id = id
		battlepass.season = GLOB.current_battlepass.season
		battlepass.save()
		battlepass.sync()

/datum/entity/player/proc/load_donator_info()
	if(GLOB.donators_info["[ckey]"])
		donator_info = GLOB.donators_info["[ckey]"]
		donator_info.player_datum = src
		donator_info.load_info()
	else
		donator_info = new(src)
		GLOB.donators_info["[ckey]"] = donator_info
