/datum/battlepass_challenge_module/kill
	var/name = "Kill"
	var/desc = "Kill ###AMMOUNT###"
	var/code_name = "ki"

	module_exp = list(5, 7)
	req_gen = list("kills" = list(0, 0))
	var/list/valid_kill_paths = list()

/datum/battlepass_challenge/kill_enemies/hook_signals(datum/source, mob/logged_in_mob)
	. = ..()
	if(!.)
		return
	RegisterSignal(logged_in_mob, COMSIG_MOB_KILL_TOTAL_INCREASED, PROC_REF(on_kill))

/datum/battlepass_challenge/kill_enemies/unhook_signals(mob/source)
	. = ..()
	if(!.)
		return
	UnregisterSignal(source, COMSIG_MOB_KILL_TOTAL_INCREASED)

/datum/battlepass_challenge/kill_enemies/check_challenge_completed()
	return (enemy_kills_required <= current_enemy_kills)

/datum/battlepass_challenge/kill_enemies/get_completion_percent()
	return (current_enemy_kills / enemy_kills_required)

/datum/battlepass_challenge/kill_enemies/get_completion_numerator()
	return current_enemy_kills

/datum/battlepass_challenge/kill_enemies/get_completion_denominator()
	return enemy_kills_required

/datum/battlepass_challenge/kill_enemies/serialize()
	. = ..()
	.["enemy_kills_required"] = enemy_kills_required
	.["current_enemy_kills"] = current_enemy_kills
	.["valid_kill_paths"] = valid_kill_paths

/datum/battlepass_challenge/kill_enemies/deserialize(list/save_list)
	. = ..()
	enemy_kills_required = save_list["enemy_kills_required"]
	current_enemy_kills = save_list["current_enemy_kills"]
	valid_kill_paths = save_list["valid_kill_paths"]

/datum/battlepass_challenge/kill_enemies/proc/on_kill(mob/source, mob/killed_mob, datum/cause_data/cause_data)
	SIGNAL_HANDLER

	// Facehuggers and lessers have a life_value of 0, so they aren't counted
	if(is_type_in_list(killed_mob, valid_kill_paths) && killed_mob.life_value)
		current_enemy_kills++

	on_possible_challenge_completed()
