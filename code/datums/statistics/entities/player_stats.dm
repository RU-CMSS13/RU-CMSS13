<<<<<<< HEAD
// TODO: Some day do custom count effect on stats updated, so don't copy this procs and also do it flexible like right now (I don't wanna change it, because on next merge upstream in this rep it will fuck up all calls on that and fixing more flexible shit will be harder)
// Also, make it wait and count like every +-30 minutes, so our DB don't fuck up in INF!, funny... (Right now if you tru to update that very often it will fuck up all, so better make it affect already taken rows, in case if no rows, just make new)

// Ignore above TODO and funny comment, I'll leave it remain here, until it's merged and I'll do new pr with creating finnal touchs (originaly this comment from mine offstream, but I forgot to remove it, plus this contain really useful information about what to do next with this to increase it realability and prettyisdajghhfh)
=======
/datum/entity/player_stats
	var/datum/entity/player_entity/player = null // "mattatlas"
	var/total_kills = 0
	var/total_deaths = 0
	var/total_playtime = 0
	var/total_rounds_played = 0
	var/steps_walked = 0
	var/round_played = FALSE
	var/datum/entity/statistic/nemesis // "runner" = 3
	var/list/niche_stats = list() // list of type /datum/entity/statistic, "Total Executions" = number
	var/list/humans_killed = list() // list of type /datum/entity/statistic, "jobname2" = number
	var/list/xenos_killed = list() // list of type /datum/entity/statistic, "caste" = number
	var/list/death_list = list() // list of type /datum/entity/death_stats
	var/display_stat = TRUE
>>>>>>> parent of 35de48867e (Squash my asss (STATISTIC))

/datum/entity/player_stats/Destroy(force)
	QDEL_NULL(nemesis)
	QDEL_LIST_ASSOC_VAL(niche_stats)
	QDEL_LIST_ASSOC_VAL(humans_killed)
	QDEL_LIST_ASSOC_VAL(xenos_killed)
	QDEL_LIST_ASSOC_VAL(death_list)
	return ..()

/datum/entity/player_stats/proc/get_playtime()
	return total_playtime

/datum/entity/player_stats/proc/count_personal_human_kill(job_name, cause, job)
	return

/datum/entity/player_stats/proc/count_personal_xeno_kill(job_name, cause, job)
	return

/datum/entity/player_stats/proc/count_human_kill(job_name, cause, job)
	if(!job_name)
		return
	if(!humans_killed["[job_name]"])
		var/datum/entity/statistic/N = new()
		N.name = job_name
		humans_killed["[job_name]"] = N
	var/datum/entity/statistic/S = humans_killed["[job_name]"]
	S.value++
	if(job)
		count_personal_human_kill(job_name, cause, job)
	total_kills++

/datum/entity/player_stats/proc/count_xeno_kill(caste, cause, job)
	if(!caste)
		return
	if(!xenos_killed["[caste]"])
		var/datum/entity/statistic/N = new()
		N.name = caste
		xenos_killed["[caste]"] = N
	var/datum/entity/statistic/S = xenos_killed["[caste]"]
	S.value++
	if(job)
		count_personal_xeno_kill(caste, cause, job)
	total_kills++

//*****************
//Mob Procs - death
//*****************

/datum/entity/player_stats/proc/recalculate_nemesis()
	var/list/causes = list()
	for(var/datum/entity/statistic/death/stat_entity in death_list)
		if(!stat_entity.cause_name)
			continue
		causes["[stat_entity.cause_name]"]++
		if(!nemesis)
			nemesis = new()
			nemesis.name = stat_entity.cause_name
			nemesis.value = 1
			continue
		if(causes["[stat_entity.cause_name]"] > nemesis.value)
			nemesis.name = stat_entity.cause_name
			nemesis.value = causes["[stat_entity.cause_name]"]

/datum/entity/player_stats/proc/count_personal_death(job)
	return

<<<<<<< HEAD
/mob/proc/can_track_statistic()
	if(statistic_exempt || statistic_tracked || !client?.player_data || !faction)
		return FALSE
	return TRUE

/mob/proc/track_death_calculations()
	if(!can_track_statistic())
		return FALSE

=======
/mob/proc/track_death_calculations()
	if(statistic_exempt || statistic_tracked)
		return
	if(GLOB.round_statistics)
		GLOB.round_statistics.recalculate_nemesis()
	if(mind && mind.player_entity)
		mind.player_entity.update_panel_data(GLOB.round_statistics)
>>>>>>> parent of 35de48867e (Squash my asss (STATISTIC))
	statistic_tracked = TRUE

<<<<<<< HEAD
/mob/proc/count_statistic_stat(statistic_name, amount = 1, weapon)
	if(!can_track_statistic())
		return FALSE
	return TRUE

/mob/proc/track_steps_walked()
	if(!can_track_statistic())
		return FALSE
	return TRUE

/mob/proc/track_hit(weapon, amount = 1, statistic_name = STATISTICS_HIT)
	if(!can_track_statistic())
		return FALSE
	return TRUE

/mob/proc/track_friendly_hit(weapon, amount = 1, statistic_name = STATISTICS_FF_HIT)
	if(!can_track_statistic())
		return FALSE
	return TRUE

/mob/proc/track_shot(weapon, amount = 1, statistic_name = STATISTICS_SHOT)
	if(!can_track_statistic())
		return FALSE
	return TRUE

/mob/proc/track_shot_hit(weapon, mob/shot_mob, amount = 1, statistic_name = STATISTICS_SHOT_HIT)
	if(!can_track_statistic())
		return FALSE

	if(GLOB.round_statistics)
		GLOB.round_statistics.total_projectiles_hit += amount
		if(shot_mob)
			if(ishuman(shot_mob))
				GLOB.round_statistics.total_projectiles_hit_human += amount
			else if(isxeno(shot_mob))
				GLOB.round_statistics.total_projectiles_hit_xeno += amount
	return TRUE

/mob/proc/track_damage(weapon, mob/damaged_mob, amount = 1, statistic_name = STATISTICS_DAMAGE)
	if(!can_track_statistic())
		return FALSE
	return TRUE

/mob/proc/track_friendly_damage(weapon, mob/damaged_mob, amount = 1, statistic_name = STATISTICS_FF_DAMAGE)
	if(!can_track_statistic())
		return FALSE
	return TRUE

/mob/proc/track_heal_damage(weapon, mob/healed_mob, amount = 1, statistic_name = STATISTICS_HEALED_DAMAGE)
	if(!can_track_statistic())
		return FALSE
	return TRUE

/mob/proc/track_friendly_fire(weapon, amount = 1, statistic_name = STATISTICS_FF_SHOT_HIT)
	if(!can_track_statistic())
		return FALSE

	if(GLOB.round_statistics)
		GLOB.round_statistics.total_friendly_fire_instances += amount

	return TRUE

/mob/proc/track_revive(amount = 1, statistic_name = STATISTICS_REVIVED)
	if(!can_track_statistic())
		return FALSE
	return TRUE

/mob/proc/track_life_saved(amount = 1, statistic_name = STATISTICS_REVIVE)
	if(!can_track_statistic())
		return FALSE
	return TRUE

/mob/proc/track_scream(amount = 1, statistic_name = STATISTICS_SCREAM)
	if(!can_track_statistic())
		return FALSE
	return TRUE

/mob/proc/track_slashes(caste, amount = 1, statistic_name = STATISTICS_SLASH)
	if(!can_track_statistic())
		return FALSE

	if(GLOB.round_statistics)
		GLOB.round_statistics.total_slashes += amount

	return TRUE

/mob/proc/track_ability_usage(ability, caste, amount = 1)
	if(!can_track_statistic())
		return FALSE
	return TRUE

/////////////////////////////////////////////////////////////////////////////////////
//Human


/mob/living/carbon/human/track_death_calculations()
	. = ..()
	if(!.)
		return FALSE

	track_statistic_earned(faction, STATISTIC_TYPE_JOB, get_role_name(), STATISTICS_ROUNDS_PLAYED, 1, client.player_data)

/mob/living/carbon/human/count_statistic_stat(statistic_name, amount = 1, weapon)
	. = ..()
	if(!.)
		return FALSE

	track_statistic_earned(faction, STATISTIC_TYPE_JOB, get_role_name(), statistic_name, amount, client.player_data)
	if(weapon)
		track_statistic_earned(faction, STATISTIC_TYPE_WEAPON, weapon, statistic_name, amount, client.player_data)

/mob/living/carbon/human/track_steps_walked(amount = 1, statistic_name = STATISTICS_STEPS_WALKED)
	. = ..()
	if(!.)
		return FALSE

	track_statistic_earned(faction, STATISTIC_TYPE_JOB, get_role_name(), statistic_name, amount, client.player_data)

/mob/living/carbon/human/track_hit(weapon, amount = 1, statistic_name = STATISTICS_HIT)
	. = ..()
	if(!.)
		return FALSE

	track_statistic_earned(faction, STATISTIC_TYPE_JOB, get_role_name(), statistic_name, amount, client.player_data)
	if(weapon)
		track_statistic_earned(faction, STATISTIC_TYPE_WEAPON, weapon, statistic_name, amount, client.player_data)

/mob/living/carbon/human/track_friendly_hit(weapon, amount = 1, statistic_name = STATISTICS_FF_HIT)
	. = ..()
	if(!.)
		return FALSE

	track_statistic_earned(faction, STATISTIC_TYPE_JOB, get_role_name(), statistic_name, amount, client.player_data)
	if(weapon)
		track_statistic_earned(faction, STATISTIC_TYPE_WEAPON, weapon, statistic_name, amount, client.player_data)

/mob/living/carbon/human/track_shot(weapon, amount = 1, statistic_name = STATISTICS_SHOT)
	. = ..()
	if(!.)
		return FALSE

	track_statistic_earned(faction, STATISTIC_TYPE_JOB, get_role_name(), statistic_name, amount, client.player_data)
	if(weapon)
		track_statistic_earned(faction, STATISTIC_TYPE_WEAPON, weapon, statistic_name, amount, client.player_data)

/mob/living/carbon/human/track_shot_hit(weapon, mob/shot_mob, amount = 1, statistic_name = STATISTICS_SHOT_HIT)
	. = ..()
	if(!.)
		return FALSE

	track_statistic_earned(faction, STATISTIC_TYPE_JOB, get_role_name(), statistic_name, amount, client.player_data)
	if(weapon)
		track_statistic_earned(faction, STATISTIC_TYPE_WEAPON, weapon, statistic_name, amount, client.player_data)

/mob/living/carbon/human/track_damage(weapon, mob/damaged_mob, amount = 1, statistic_name = STATISTICS_DAMAGE)
	. = ..()
	if(!.)
		return FALSE

	track_statistic_earned(faction, STATISTIC_TYPE_JOB, get_role_name(), statistic_name, amount, client.player_data)
	if(weapon)
		track_statistic_earned(faction, STATISTIC_TYPE_WEAPON, weapon, statistic_name, amount, client.player_data)

/mob/living/carbon/human/track_friendly_damage(weapon, mob/damaged_mob, amount = 1, statistic_name = STATISTICS_FF_DAMAGE)
	. = ..()
	if(!.)
		return FALSE

	track_statistic_earned(faction, STATISTIC_TYPE_JOB, get_role_name(), statistic_name, amount, client.player_data)
	if(weapon)
		track_statistic_earned(faction, STATISTIC_TYPE_WEAPON, weapon, statistic_name, amount, client.player_data)

/mob/living/carbon/human/track_heal_damage(weapon, mob/healed_mob, amount = 1, statistic_name = STATISTICS_HEALED_DAMAGE)
	. = ..()
	if(!.)
		return FALSE

	track_statistic_earned(faction, STATISTIC_TYPE_JOB, get_role_name(), statistic_name, amount, client.player_data)
	if(weapon)
		track_statistic_earned(faction, STATISTIC_TYPE_WEAPON, weapon, statistic_name, amount, client.player_data)

/mob/living/carbon/human/track_friendly_fire(weapon, amount = 1, statistic_name = STATISTICS_FF_SHOT_HIT)
	. = ..()
	if(!.)
		return FALSE

	track_statistic_earned(faction, STATISTIC_TYPE_JOB, get_role_name(), statistic_name, amount, client.player_data)
	if(weapon)
		track_statistic_earned(faction, STATISTIC_TYPE_WEAPON, weapon, statistic_name, amount, client.player_data)

/mob/living/carbon/human/track_revive(amount = 1, statistic_name = STATISTICS_REVIVED)
	. = ..()
	if(!.)
		return FALSE

	track_statistic_earned(faction, STATISTIC_TYPE_JOB, get_role_name(), statistic_name, amount, client.player_data)

/mob/living/carbon/human/track_life_saved(amount = 1, statistic_name = STATISTICS_REVIVE)
	. = ..()
	if(!.)
		return FALSE

	track_statistic_earned(faction, STATISTIC_TYPE_JOB, get_role_name(), statistic_name, amount, client.player_data)

/mob/living/carbon/human/track_scream(amount = 1, statistic_name = STATISTICS_SCREAM)
	. = ..()
	if(!.)
		return FALSE

	track_statistic_earned(faction, STATISTIC_TYPE_JOB, get_role_name(), statistic_name, amount, client.player_data)

/////////////////////////////////////////////////////////////////////////////////////
//Xenomorph

/mob/living/carbon/xenomorph/track_death_calculations()
	. = ..()
	if(!. || !faction)
		return

	track_statistic_earned(faction, STATISTIC_TYPE_CASTE, get_role_name(), STATISTICS_ROUNDS_PLAYED, 1, client.player_data)

/mob/living/carbon/xenomorph/count_statistic_stat(statistic_name, amount = 1, weapon)
	. = ..()
	if(!.)
		return FALSE

	track_statistic_earned(faction, STATISTIC_TYPE_CASTE, caste_type, statistic_name, amount, client.player_data)
	if(weapon)
		track_statistic_earned(faction, STATISTIC_TYPE_WEAPON, weapon, statistic_name, amount, client.player_data)

/mob/living/carbon/xenomorph/track_steps_walked(amount = 1, statistic_name = STATISTICS_STEPS_WALKED)
	. = ..()
	if(!.)
		return FALSE

	track_statistic_earned(faction, STATISTIC_TYPE_CASTE, caste_type, statistic_name, amount, client.player_data)

/mob/living/carbon/xenomorph/track_hit(weapon, amount = 1, statistic_name = STATISTICS_HIT)
	. = ..()
	if(!.)
		return FALSE

	track_statistic_earned(faction, STATISTIC_TYPE_CASTE, get_role_name(), statistic_name, amount, client.player_data)
	if(weapon)
		track_statistic_earned(faction, STATISTIC_TYPE_WEAPON, weapon, statistic_name, amount, client.player_data)

/mob/living/carbon/xenomorph/track_friendly_hit(weapon, amount = 1, statistic_name = STATISTICS_FF_HIT)
	. = ..()
	if(!.)
		return FALSE

	track_statistic_earned(faction, STATISTIC_TYPE_CASTE, get_role_name(), statistic_name, amount, client.player_data)
	if(weapon)
		track_statistic_earned(faction, STATISTIC_TYPE_WEAPON, weapon, statistic_name, amount, client.player_data)

/mob/living/carbon/xenomorph/track_shot(weapon, amount = 1, statistic_name = STATISTICS_SHOT)
	. = ..()
	if(!.)
		return FALSE

	track_statistic_earned(faction, STATISTIC_TYPE_CASTE, get_role_name(), statistic_name, amount, client.player_data)
	if(weapon)
		track_statistic_earned(faction, STATISTIC_TYPE_WEAPON, weapon, statistic_name, amount, client.player_data)

/mob/living/carbon/xenomorph/track_shot_hit(weapon, mob/shot_mob, amount = 1, statistic_name = STATISTICS_SHOT_HIT)
	. = ..()
	if(!.)
		return FALSE

	track_statistic_earned(faction, STATISTIC_TYPE_CASTE, get_role_name(), statistic_name, amount, client.player_data)
	if(weapon)
		track_statistic_earned(faction, STATISTIC_TYPE_WEAPON, weapon, statistic_name, amount, client.player_data)

/mob/living/carbon/xenomorph/track_damage(weapon, mob/damaged_mob, amount = 1, statistic_name = STATISTICS_DAMAGE)
	. = ..()
	if(!.)
		return FALSE

	track_statistic_earned(faction, STATISTIC_TYPE_CASTE, get_role_name(), statistic_name, amount, client.player_data)
	if(weapon)
		track_statistic_earned(faction, STATISTIC_TYPE_WEAPON, weapon, statistic_name, amount, client.player_data)

/mob/living/carbon/xenomorph/track_friendly_damage(weapon, mob/damaged_mob, amount = 1, statistic_name = STATISTICS_FF_DAMAGE)
	. = ..()
	if(!.)
		return FALSE

	track_statistic_earned(faction, STATISTIC_TYPE_CASTE, get_role_name(), statistic_name, amount, client.player_data)
	if(weapon)
		track_statistic_earned(faction, STATISTIC_TYPE_WEAPON, weapon, statistic_name, amount, client.player_data)

/mob/living/carbon/xenomorph/track_heal_damage(weapon, mob/healed_mob, amount = 1, statistic_name = STATISTICS_HEALED_DAMAGE)
	. = ..()
	if(!.)
		return FALSE

	track_statistic_earned(faction, STATISTIC_TYPE_CASTE, get_role_name(), statistic_name, amount, client.player_data)
	if(weapon)
		track_statistic_earned(faction, STATISTIC_TYPE_WEAPON, weapon, statistic_name, amount, client.player_data)

/mob/living/carbon/xenomorph/track_friendly_fire(weapon, amount = 1, statistic_name = STATISTICS_FF_SHOT_HIT)
	. = ..()
	if(!.)
		return FALSE

	track_statistic_earned(faction, STATISTIC_TYPE_CASTE, get_role_name(), statistic_name, amount, client.player_data)
	if(weapon)
		track_statistic_earned(faction, STATISTIC_TYPE_WEAPON, weapon, statistic_name, amount, client.player_data)

/mob/living/carbon/xenomorph/track_revive(amount = 1, statistic_name = STATISTICS_REVIVED)
	. = ..()
	if(!.)
		return FALSE

	track_statistic_earned(faction, STATISTIC_TYPE_CASTE, get_role_name(), statistic_name, amount, client.player_data)

/mob/living/carbon/xenomorph/track_life_saved(amount = 1, statistic_name = STATISTICS_REVIVE)
	. = ..()
	if(!.)
		return FALSE

	track_statistic_earned(faction, STATISTIC_TYPE_CASTE, get_role_name(), statistic_name, amount, client.player_data)

/mob/living/carbon/xenomorph/track_scream(amount = 1, statistic_name = STATISTICS_SCREAM)
	. = ..()
	if(!.)
		return FALSE

	track_statistic_earned(faction, STATISTIC_TYPE_CASTE, get_role_name(), statistic_name, amount, client.player_data)

/mob/living/carbon/xenomorph/track_slashes(caste, amount = 1, statistic_name = STATISTICS_SLASH)
	. = ..()
	if(!.)
		return FALSE

	track_statistic_earned(faction, STATISTIC_TYPE_CASTE, caste, statistic_name, amount, client.player_data)

/mob/living/carbon/xenomorph/track_ability_usage(ability, caste, amount = 1)
	. = ..()
	if(!.)
		return FALSE

	track_statistic_earned(faction, STATISTIC_TYPE_CASTE_ABILITIES, caste, ability, amount, client.player_data)
	track_statistic_earned(faction, STATISTIC_TYPE_CASTE, caste, STATISTICS_ABILITES, amount, client.player_data)
=======
//*****************
//Mob Procs - kills
//*****************

/mob/proc/count_human_kill(job_name, cause)
	return

/mob/proc/count_xeno_kill(killed_caste, cause)
	return

/mob/proc/count_niche_stat(niche_name, amount = 1)
	return

//Human
/mob/living/carbon/human/count_human_kill(job_name, cause)
	if(statistic_exempt || !mind)
		return
	var/datum/entity/player_stats/human/human_stats = mind.setup_human_stats()
	var/job_actual = get_actual_job_name(src)
	human_stats.count_human_kill(job_name, cause, job_actual)

/mob/living/carbon/human/count_xeno_kill(killed_caste, cause)
	if(statistic_exempt || !mind)
		return
	var/datum/entity/player_stats/human/human_stats = mind.setup_human_stats()
	var/job_actual = get_actual_job_name(src)
	human_stats.count_xeno_kill(killed_caste, cause, job_actual)

/mob/living/carbon/human/count_niche_stat(niche_name, amount = 1, weapon_name)
	if(statistic_exempt || !mind)
		return
	var/job_actual = get_actual_job_name(src)
	var/datum/entity/player_stats/human/human_stats = mind.setup_human_stats()
	human_stats.count_niche_stat(niche_name, amount, job_actual, weapon_name)

//Xeno
/mob/living/carbon/xenomorph/count_human_kill(job_name, cause)
	if(statistic_exempt || !mind)
		return
	var/datum/entity/player_stats/xeno/xeno_stats = mind.setup_xeno_stats()
	if(isnull(xeno_stats))
		return
	xeno_stats.count_human_kill(job_name, cause, caste_type)

/mob/living/carbon/xenomorph/count_xeno_kill(killed_caste, cause)
	if(statistic_exempt || !mind)
		return
	var/datum/entity/player_stats/xeno/xeno_stats = mind.setup_xeno_stats()
	if(isnull(xeno_stats))
		return
	xeno_stats.count_xeno_kill(killed_caste, cause, caste_type)

/mob/living/carbon/xenomorph/count_niche_stat(niche_name, amount = 1)
	if(statistic_exempt || !mind)
		return
	var/datum/entity/player_stats/xeno/xeno_stats = mind.setup_xeno_stats()
	if(isnull(xeno_stats))
		return
	xeno_stats.count_niche_stat(niche_name, amount, caste_type)

//*****************
//Mob Procs - minor
//*****************

/datum/entity/player_stats/proc/count_personal_niche_stat(niche_name, amount = 1, job)
	return

/datum/entity/player_stats/proc/count_niche_stat(niche_name, amount = 1, job)
	if(!niche_name)
		return
	if(!niche_stats["[niche_name]"])
		var/datum/entity/statistic/N = new()
		N.name = niche_name
		niche_stats["[niche_name]"] = N
	var/datum/entity/statistic/S = niche_stats["[niche_name]"]
	S.value += amount
	if(job)
		count_personal_niche_stat(niche_name, amount, job)

/datum/entity/player_stats/proc/count_personal_steps_walked(job)
	return

/mob/proc/track_steps_walked()
	return
>>>>>>> parent of 35de48867e (Squash my asss (STATISTIC))
