/datum/entity/player/proc/load_battlepass()
//PORT OUR SAVES
	UNTIL(GLOB.battlepasses)
	if(GLOB.client_loaded_battlepasses[ckey])
		battlepass = GLOB.client_loaded_battlepasses[ckey]
		battlepass.owner = src
		battlepass.verify_data()
	else
		DB_FILTER(/datum/entity/battlepass_player, DB_AND(DB_COMP("player_id", DB_EQUALS, id), DB_COMP("season", DB_EQUALS, GLOB.current_battlepass.season)), CALLBACK(src, TYPE_PROC_REF(/datum/entity/player, on_read_battlepass)))

/* WORK THIS AROUND FOR CONVERTING ALL TO DB
	for(var/a in flist("data/player_saves/"))
		for(var/ckey_str in flist("data/player_saves/[a]/"))
			if(!fexists("data/player_saves/[a]/[ckey_str]/battlepass.sav"))
				continue

			var/savefile/save_obj = new("data/player_saves/[a]/[ckey_str]/battlepass.sav")
			battlepass = DB_ENTITY(/datum/entity/battlepass_player)
			battlepass.player_id = id
			battlepass.season = 1
			battlepass.tier = save_obj["tier"]
			battlepass.xp = save_obj["xp"]
			battlepass.save()
			fdel(target_file)
*/

/datum/entity/player/proc/on_read_battlepass(list/datum/entity/battlepass_player/_battlepass)
	if(_battlepass)
		battlepass = pick(_battlepass)
	else
		battlepass = DB_ENTITY(/datum/entity/battlepass_player)
		battlepass.player_id = id
		battlepass.season = GLOB.current_battlepass.season
		battlepass.save()
		battlepass.sync()

	GLOB.client_loaded_battlepasses[ckey] = battlepass

/datum/entity/player/proc/load_donator_info()
	if(GLOB.donators_info["[ckey]"])
		donator_info = GLOB.donators_info["[ckey]"]
		donator_info.player_datum = src
		donator_info.load_info()
	else
		donator_info = new(src)
		GLOB.donators_info["[ckey]"] = donator_info
