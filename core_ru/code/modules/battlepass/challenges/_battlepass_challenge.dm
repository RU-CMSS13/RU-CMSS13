/datum/battlepass_challenge
	var/name = ""
	var/code_name = ""
	var/desc = ""

	var/completion_xp = 0
	var/list/completion_xp_array = list(0, 0)

	var/completed = FALSE
	var/challenge_category = CHALLENGE_NONE
	var/pick_weight = 1

/datum/battlepass_challenge/New(client/owner)
	. = ..()
	if(!completion_xp)
		if(length(completion_xp_array))
			completion_xp = rand(completion_xp_array[1], completion_xp_array[2])
		if(GLOB.current_battlepass.mapped_point_sources["daily"][code_name] && length(GLOB.current_battlepass.mapped_point_sources["daily"][code_name]["xp"]))
			completion_xp = rand(GLOB.current_battlepass.mapped_point_sources["daily"][code_name]["xp"][1], GLOB.current_battlepass.mapped_point_sources["daily"][code_name]["xp"][2])

	if(owner)
		on_client_hooked(owner)

//Signalls
/datum/battlepass_challenge/proc/on_client_hooked(client/owner)
	if(owner && !completed)
		if(owner.mob)
			hook_client_signals(src, owner.mob)
		else
			RegisterSignal(owner, COMSIG_CLIENT_MOB_LOGGED_IN, PROC_REF(hook_client_signals))

/datum/battlepass_challenge/proc/hook_client_signals(datum/source, mob/logged_in_mob)
	SIGNAL_HANDLER
	SHOULD_CALL_PARENT(TRUE)

	UnregisterSignal(logged_in_mob.client, COMSIG_CLIENT_MOB_LOGGED_IN)
	RegisterSignal(logged_in_mob, COMSIG_MOB_LOGOUT, PROC_REF(unhook_client_signals))

	if(logged_in_mob.statistic_exempt)
		return FALSE
	return TRUE

/datum/battlepass_challenge/proc/unhook_client_signals(mob/source)
	SIGNAL_HANDLER
	SHOULD_CALL_PARENT(TRUE)

	unhook_signals(source)
	UnregisterSignal(source, COMSIG_MOB_LOGOUT)
	if(source.logging_ckey in GLOB.directory)
		RegisterSignal(GLOB.directory[source.logging_ckey], COMSIG_CLIENT_MOB_LOGGED_IN, PROC_REF(hook_client_signals))

/datum/battlepass_challenge/proc/unhook_signals(mob/source)
	return


//Basic
/datum/battlepass_challenge/proc/regenerate_desc()
	return

/datum/battlepass_challenge/proc/check_challenge_completed()
	return TRUE

/datum/battlepass_challenge/proc/on_possible_challenge_completed()
	if(!check_challenge_completed())
		return FALSE
	SEND_SIGNAL(src, COMSIG_BATTLEPASS_CHALLENGE_COMPLETED)
	return TRUE

/// Get how completed the challenge is as a percentage out of 1
/datum/battlepass_challenge/proc/get_completion_percent()
	return 0

/datum/battlepass_challenge/proc/get_completion_numerator()
	return 0

/datum/battlepass_challenge/proc/get_completion_denominator()
	return 1

/datum/battlepass_challenge/proc/serialize()
	SHOULD_CALL_PARENT(TRUE)
	return list(
		"type" = type,
		"name" = name,
		"desc" = desc,
		"completion_xp" = completion_xp,
		"completed" = completed
	)

/// Given a list, update the challenge data accordingly
/datum/battlepass_challenge/proc/deserialize(list/info)
	SHOULD_CALL_PARENT(TRUE)
	name = info["name"]
	desc = info["desc"]
	completion_xp = info["completion_xp"]
	completed = info["completed"]
