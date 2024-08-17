/datum/battlepass_challenge/defib_players
	name = "Defibrillate Players"
	code_name = "defib"
	desc = "Successfully defibrillate AMOUNT unique marine players."
	challenge_category = CHALLENGE_HUMAN
	completion_xp_array = list(4, 6)
	pick_weight = 5
	var/minimum = 4
	var/maximum = 8
	var/requirement = 0
	var/list/mob_name_list = list()


/datum/battlepass_challenge/defib_players/datum/battlepass_challenge/kill_enemies/New(client/owning_client)
	. = ..()

	requirement = rand(minimum, maximum)
	regenerate_desc()

/datum/battlepass_challenge/defib_players/regenerate_desc()
	desc = "Successfully defibrillate [requirement] unique marine player\s."

/datum/battlepass_challenge/defib_players/hook_client_signals(datum/source, mob/logged_in_mob)
	. = ..()
	if(!.)
		return
	if(!completed)
		RegisterSignal(logged_in_mob, COMSIG_HUMAN_USED_DEFIB, PROC_REF(on_defib))

/datum/battlepass_challenge/defib_players/unhook_signals(mob/source)
	UnregisterSignal(source, COMSIG_HUMAN_USED_DEFIB)

/datum/battlepass_challenge/defib_players/check_challenge_completed()
	return (length(mob_name_list) >= requirement)

/datum/battlepass_challenge/defib_players/get_completion_percent()
	return (length(mob_name_list) / requirement)

/datum/battlepass_challenge/defib_players/get_completion_numerator()
	return length(mob_name_list)

/datum/battlepass_challenge/defib_players/get_completion_denominator()
	return requirement

/datum/battlepass_challenge/defib_players/serialize()
	. = ..()
	.["requirement"] = requirement
	.["filled"] = mob_name_list

/datum/battlepass_challenge/defib_players/deserialize(list/save_list)
	. = ..()
	requirement = save_list["requirement"]
	mob_name_list = save_list["filled"]

/// When the xeno plants a resin node
/datum/battlepass_challenge/defib_players/proc/on_defib(datum/source, mob/living/carbon/human/defibbed)
	SIGNAL_HANDLER

	mob_name_list |= defibbed.real_name
	on_possible_challenge_completed()

