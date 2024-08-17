/datum/battlepass_challenge/facehug
	name = "Facehug Humans"
	code_name = "xenohhug"
	desc = "As a facehugger, facehug AMOUNT humans."
	challenge_category = CHALLENGE_XENO
	completion_xp_array = list(4, 6)
	pick_weight = 7
	var/minimum = 1
	var/maximum = 3
	var/requirement = 0
	var/filled = 0

/datum/battlepass_challenge/facehug/datum/battlepass_challenge/kill_enemies/New(client/owning_client)
	. = ..()

	requirement = rand(minimum, maximum)
	regenerate_desc()

/datum/battlepass_challenge/facehug/regenerate_desc()
	desc = "As a facehugger, facehug [requirement] human\s."

/datum/battlepass_challenge/facehug/hook_client_signals(datum/source, mob/logged_in_mob)
	. = ..()
	if(!.)
		return
	if(!completed)
		RegisterSignal(logged_in_mob, COMSIG_XENO_FACEHUGGED_HUMAN, PROC_REF(on_sigtrigger))

/datum/battlepass_challenge/facehug/unhook_signals(mob/source)
	UnregisterSignal(source, COMSIG_XENO_FACEHUGGED_HUMAN)

/datum/battlepass_challenge/facehug/check_challenge_completed()
	return (filled >= requirement)

/datum/battlepass_challenge/facehug/get_completion_percent()
	return (filled / requirement)

/datum/battlepass_challenge/facehug/get_completion_numerator()
	return filled

/datum/battlepass_challenge/facehug/get_completion_denominator()
	return requirement

/datum/battlepass_challenge/facehug/serialize()
	. = ..()
	.["requirement"] = requirement
	.["filled"] = filled

/datum/battlepass_challenge/facehug/deserialize(list/save_list)
	. = ..()
	requirement = save_list["requirement"]
	filled = save_list["filled"]

/// When the xeno plants a resin node
/datum/battlepass_challenge/facehug/proc/on_sigtrigger(datum/source)
	SIGNAL_HANDLER

	filled++
	on_possible_challenge_completed()

