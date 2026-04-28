/datum/controller/subsystem/playtime
	flags = SS_KEEP_TIMING
	init_order = SS_INIT_PLAYTIME
	var/list/best_playtimes = list()

/datum/controller/subsystem/playtime/Initialize()
	get_best_playtimes()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/playtime/proc/get_best_playtimes()
	set waitfor = FALSE
	set background = TRUE

	WAIT_DB_READY

	var/list/datum/view_record/playtime/all_records = DB_VIEW(/datum/view_record/playtime)
	var/list/real_best_playtimes = list()
	for(var/datum/view_record/playtime/record as anything in all_records)
		CHECK_TICK
		if(!real_best_playtimes[record.role_id])
			real_best_playtimes[record.role_id] = list(record.total_minutes, record)
			continue
		if(real_best_playtimes[record.role_id][1] > record.total_minutes)
			continue
		real_best_playtimes[record.role_id] = list(record.total_minutes, record)

	for(var/role_name in real_best_playtimes)
		CHECK_TICK
		var/list/info_list = real_best_playtimes[role_name]
		var/datum/view_record/playtime/record = info_list[2]
		if(!record)
			continue
		var/datum/view_record/players/player = SAFEPICK(DB_VIEW(/datum/view_record/players, DB_COMP("id", DB_EQUALS, record.player_id)))
		if(!player)
			continue
		best_playtimes += list(list("ckey" = player.ckey) + record.get_nanoui_data())

/datum/entity/player/ui_data(mob/user)
	if(!LAZYACCESS(playtime_data, "loaded"))
		load_timestat_data()
	return list("playtime" = playtime_data, "best_playtime" = SSplaytime.best_playtimes)
