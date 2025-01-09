/datum/game_mode/bootcamp
	name = "Boot Camp"
	config_tag = "Boot Camp"
	required_players = 1
	latejoin_larva_drop = 0
	static_comms_amount = 1
	var/research_allocation_interval = 10 MINUTES
	var/next_research_allocation = 0
	taskbar_icon = 'icons/taskbar/gml_colonyrp.png'

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/* Pre-pre-startup */
/datum/game_mode/colonialmarines/can_start(bypass_checks = FALSE)
	initialize_special_clamps()
	return TRUE

/datum/game_mode/colonialmarines/announce()
	to_chat_spaced(world, type = MESSAGE_TYPE_SYSTEM, html = SPAN_ROUNDHEADER("The current map is - [SSmapping.configs[GROUND_MAP].map_name]!"))

/datum/game_mode/announce()
	to_world("<B>The current game mode is - Boot Camp!</B>")

/datum/game_mode/extended/get_roles_list()
	return GLOB.ROLES_USCM

////////////////////////////////////////////////////////////////////////////////////////

/datum/game_mode/bootcamp/get_affected_zlevels()
	if(is_in_endgame)
		. = SSmapping.levels_by_any_trait(list(ZTRAIT_GROUND))
		return

/datum/game_mode/extended/post_setup()
	initialize_post_marine_gear_list()
	for(var/mob/new_player/np in GLOB.new_player_list)
		np.new_player_panel_proc()
	round_time_lobby = world.time
	return ..()

/datum/game_mode/extended/process()
	. = ..()
	if(next_research_allocation < world.time)
		GLOB.chemical_data.update_credits(GLOB.chemical_data.research_allocation_amount)
		next_research_allocation = world.time + research_allocation_interval

	if(GLOB.round_statistics)
		GLOB.round_statistics.game_mode = name
		GLOB.round_statistics.round_length = world.time
		GLOB.round_statistics.end_round_player_population = length(GLOB.clients)
		GLOB.round_statistics.log_round_statistics()

	calculate_end_statistics()
	declare_completion_announce_predators()
	declare_completion_announce_medal_awards()


	return TRUE
