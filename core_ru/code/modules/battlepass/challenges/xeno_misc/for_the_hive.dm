/datum/battlepass_challenge/for_the_hive
	name = "For The Hive!"
	code_name = "xenorsuic"
	desc = "As an Acider Runner, detonate For The Hive at maximum acid AMOUNT times."
	challenge_category = CHALLENGE_XENO
	completion_xp_array = list(5, 7)
	pick_weight = 6
	var/minimum = 1
	var/maximum = 2
	var/requirement = 0
	var/filled = 0

/datum/battlepass_challenge/for_the_hive/New(client/owning_client)
	. = ..()
	if(!.)
		return .

	requirement = rand(minimum, maximum)
	regenerate_desc()

/datum/battlepass_challenge/for_the_hive/regenerate_desc()
	desc = "As an Acider Runner, detonate For The Hive at maximum acid [requirement] times."

/datum/battlepass_challenge/for_the_hive/hook_client_signals(datum/source, mob/logged_in_mob)
	. = ..()
	if(!.)
		return
	if(!completed)
		RegisterSignal(logged_in_mob, COMSIG_XENO_FTH_MAX_ACID, PROC_REF(on_sigtrigger))

/datum/battlepass_challenge/for_the_hive/unhook_signals(mob/source)
	UnregisterSignal(source, COMSIG_XENO_FTH_MAX_ACID)

/datum/battlepass_challenge/for_the_hive/check_challenge_completed()
	return (filled >= requirement)

/datum/battlepass_challenge/for_the_hive/get_completion_percent()
	return (filled / requirement)

/datum/battlepass_challenge/for_the_hive/get_completion_numerator()
	return filled

/datum/battlepass_challenge/for_the_hive/get_completion_denominator()
	return requirement

/datum/battlepass_challenge/for_the_hive/serialize()
	. = ..()
	.["requirement"] = requirement
	.["filled"] = filled

/datum/battlepass_challenge/for_the_hive/deserialize(list/save_list)
	. = ..()
	requirement = save_list["requirement"]
	filled = save_list["filled"]

/// When the xeno plants a resin node
/datum/battlepass_challenge/for_the_hive/proc/on_sigtrigger(datum/source)
	SIGNAL_HANDLER

	filled++
	on_possible_challenge_completed()


