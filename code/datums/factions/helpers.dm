GLOBAL_LIST_INIT(task_gen_list, list("sector_control" = list(/datum/faction_task/sector_control/occupy, /datum/faction_task/sector_control/occupy/hold)))
GLOBAL_LIST_INIT(task_gen_list_game_enders, list("game_enders" = list(/datum/faction_task/dominate, /datum/faction_task/hold)))

GLOBAL_LIST_INIT_TYPED(faction_datums, /datum/faction, setup_faction_list())

/proc/setup_faction_list()
	var/list/faction_datums_list = list()
	for(var/T in typesof(/datum/faction))
		var/datum/faction/F = new T
		faction_datums_list[F.faction_tag] = F
	return faction_datums_list

/proc/get_faction(faction = FACTION_MARINE)
	var/datum/faction/F = GLOB.faction_datums[faction]
	if(F)
		return F
	return GLOB.faction_datums[FACTION_NEUTRAL]
