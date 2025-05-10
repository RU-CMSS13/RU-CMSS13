/datum/game_mode/extended
	name = "Extended"
	config_tag = "Extended"
	required_players = 0
	latejoin_larva_drop = 0
	votable = FALSE
	taskbar_icon = 'icons/taskbar/gml_colonyrp.png'

/datum/game_mode/extended/announce()
	to_world("<B>The current game mode is - Extended!</B>")

/datum/game_mode/extended/get_roles_list()
	return GLOB.ROLES_USCM

/datum/game_mode/extended/post_setup()
	initialize_post_marine_gear_list()
	round_time_lobby = world.time
	GLOB.chemical_data.reroll_chemicals() //kickstart the research chemical contract "system"
	return ..()

/datum/game_mode/extended/process()
	if(GLOB.chemical_data.next_reroll < world.time)
		GLOB.chemical_data.reroll_chemicals()

	. = ..()

/datum/game_mode/extended/check_finished()
	if(round_finished)
		return TRUE

/datum/game_mode/extended/check_win()
	return

/datum/game_mode/extended/declare_completion()
/*
	announce_ending()
*/
//RUCM START
	. = ..()
//RUCM END

	var/musical_track = pick('sound/theme/neutral_hopeful1.ogg','sound/theme/neutral_hopeful2.ogg')
	world << musical_track

	calculate_end_statistics()
	declare_completion_announce_predators()
	declare_completion_announce_medal_awards()


	return TRUE
