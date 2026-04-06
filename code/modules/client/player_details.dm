GLOBAL_LIST_EMPTY(player_details) // ckey -> /datum/player_details

/datum/player_details
	var/list/player_actions = list()
	var/list/logging = list()
	var/list/post_login_callbacks = list()
	var/list/post_logout_callbacks = list()
	var/list/played_names = list() //List of names this key played under this round
	var/byond_version = "Unknown"
	/// The descriminator for larva pool ordering: Generally set to timeofdeath except for facehuggers/admin z-level play
	var/larva_pool_time

/* RUCM CHANGE
/datum/player_details/New()
*/
//RUCM START
/datum/player_details/New(ckey)
	player_ckey = ckey
	xeno_que_position = new /datum/queued_player/xeno(ckey)
	var/client/client = GLOB.directory[ckey]
	if(check_client_rights(client, R_MOD, FALSE))
		xeno_que_position.admin_larva_protection = TRUE
//RUCM END
	larva_pool_time = world.time
	return ..()

/proc/log_played_names(ckey, ...)
	if(!ckey)
		return
	if(length(args) < 2)
		return
	var/list/names = args.Copy(2)
	var/datum/player_details/P = GLOB.player_details[ckey]
	if(!P)
		return
	for(var/name in names)
		if(name)
			P.played_names |= name
