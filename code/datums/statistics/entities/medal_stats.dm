<<<<<<< HEAD
/datum/entity/statistic_medal
=======
/datum/entity/statistic/medal
>>>>>>> parent of 35de48867e (Squash my asss (STATISTIC))
	var/player_id
	var/round_id

	var/medal_type
	var/recipient_name
	var/recipient_role
	var/citation

	var/giver_name
	var/giver_player_id

<<<<<<< HEAD
BSQL_PROTECT_DATUM(/datum/entity/statistic_medal)

/datum/entity_meta/statistic_medal
	entity_type = /datum/entity/statistic_medal
	table_name = "player_statistic_medal"
=======
/datum/entity_meta/statistic_medal
	entity_type = /datum/entity/statistic/medal
	table_name = "log_player_statistic_medal"
>>>>>>> parent of 35de48867e (Squash my asss (STATISTIC))
	field_types = list(
		"player_id" = DB_FIELDTYPE_BIGINT,
		"round_id" = DB_FIELDTYPE_BIGINT,

		"medal_type" = DB_FIELDTYPE_STRING_LARGE,
		"recipient_name" = DB_FIELDTYPE_STRING_LARGE,
		"recipient_role" = DB_FIELDTYPE_STRING_LARGE,
		"citation" = DB_FIELDTYPE_STRING_MAX,

		"giver_name" = DB_FIELDTYPE_STRING_LARGE,
		"giver_player_id" = DB_FIELDTYPE_BIGINT
	)

/datum/view_record/medal_view
	var/player_id
	var/round_id
	var/medal_type
	var/recipient_name
	var/recipient_role
	var/citation
	var/giver_name
	var/giver_player_id
	var/id

<<<<<<< HEAD
/datum/entity_view_meta/statistic_medal_ordered
	root_record_type = /datum/entity/statistic_medal
	destination_entity = /datum/view_record/statistic_medal
=======
/datum/entity_view_meta/medal_view
	root_record_type = /datum/entity/statistic/medal
	destination_entity = /datum/view_record/medal_view
>>>>>>> parent of 35de48867e (Squash my asss (STATISTIC))
	fields = list(
		"player_id",
		"round_id",
		"medal_type",
		"recipient_name",
		"recipient_role",
		"citation",
		"giver_name",
		"giver_player_id",
		"id",
	)

/datum/entity/player_entity/proc/track_medal_earned(new_medal_type, mob/new_recipient, new_recipient_role, new_citation, mob/giver)
	if(!new_medal_type || !new_recipient || new_recipient.statistic_exempt || !new_recipient_role || !new_citation || !giver)
		return

<<<<<<< HEAD
	var/datum/entity/statistic_medal/new_medal = DB_ENTITY(/datum/entity/statistic_medal)
	var/datum/entity/player/player_entity = get_player_from_key(new_recipient.ckey)
=======
	var/datum/entity/statistic/medal/new_medal = DB_ENTITY(/datum/entity/statistic/medal)
	var/datum/entity/player/player_entity = get_player_from_key(new_recipient.persistent_ckey)
>>>>>>> parent of 35de48867e (Squash my asss (STATISTIC))
	if(player_entity)
		new_medal.player_id = player_entity.id

	new_medal.round_id = SSperf_logging.round.id
	new_medal.medal_type = new_medal_type
	new_medal.recipient_name = new_recipient.real_name
	new_medal.recipient_role = new_recipient_role
	new_medal.citation = new_citation

	new_medal.giver_name = giver.real_name

	var/datum/entity/player/giver_player = get_player_from_key(giver.ckey)
	if(giver_player)
		new_medal.giver_player_id = giver_player.id

<<<<<<< HEAD
	var/datum/entity/player/recipient_player = get_player_from_key(new_recipient.ckey)
	if(recipient_player)
		track_statistic_earned(new_recipient.faction, STATISTICS_MEDALS, 1, recipient_player)

	statistics_medals += new_medal
=======
>>>>>>> parent of 35de48867e (Squash my asss (STATISTIC))
	new_medal.save()
	new_medal.detach()

	if (isxeno(new_recipient))
		var/datum/entity/player_stats/xeno/xeno_stats = setup_xeno_stats()
		xeno_stats.count_niche_stat(STATISTICS_NICHE_MEDALS, 1, new_recipient_role)
		xeno_stats.medal_list.Insert(1, new_medal)
	else
		var/datum/entity/player_stats/human/human_stats = setup_human_stats()
		human_stats.count_niche_stat(STATISTICS_NICHE_MEDALS, 1, new_recipient_role)
		human_stats.medal_list.Insert(1, new_medal)

/datum/entity/player_entity/proc/untrack_medal_earned(medal_type, mob/recipient, citation)
	if(!medal_type || !recipient || recipient.statistic_exempt || !citation)
		return FALSE

	if(!check_rights(R_MOD))
		return FALSE

<<<<<<< HEAD

	var/datum/entity/player/recipient_player = get_player_from_key(recipient.ckey)
	if(recipient_player)
		track_statistic_earned(recipient.faction, STATISTICS_MEDALS, 1, recipient_player)

	var/round_id = SSperf_logging.round?.id
	for(var/datum/entity/statistic_medal/new_medal as anything in statistics_medals)
		if(new_medal.round_id == round_id && new_medal.recipient_name == recipient.real_name && new_medal.medal_type == medal_type && new_medal.citation == citation)
			statistics_medals -= new_medal
			new_medal.delete()
			break
=======
	// Remove the stats for the job/caste, individual, and the stat's list of medals
	var/round_id = SSperf_logging.round.id
	if (isxeno(recipient))
		// Xeno jellies
		var/mob/living/carbon/xenomorph/xeno = recipient
		var/caste = xeno.caste_type
		var/datum/entity/player_stats/xeno/xeno_stats = setup_xeno_stats()
		xeno_stats.count_niche_stat(STATISTICS_NICHE_MEDALS, -1, caste)

		for(var/datum/entity/statistic/medal/medal as anything in xeno_stats.medal_list)
			if(medal.round_id == round_id && medal.recipient_name == recipient.real_name && medal.medal_type == medal_type && medal.citation == citation)
				xeno_stats.medal_list.Remove(medal)
				medal.delete()
				break
	else
		// Marine medals
		var/rank
		var/weak_ref_recipient = WEAKREF(recipient)
		for(var/list/marine_manifest_list in list(GLOB.data_core.general))
			for(var/datum/data/record/record in marine_manifest_list)
				if(record.fields["ref"] == weak_ref_recipient)
					rank = record.fields["rank"]
					break
		var/datum/entity/player_stats/human/human_stats = setup_human_stats()
		human_stats.count_niche_stat(STATISTICS_NICHE_MEDALS, -1, rank)

		for(var/datum/entity/statistic/medal/medal as anything in human_stats.medal_list)
			if(medal.round_id == round_id && medal.recipient_name == recipient.real_name && medal.medal_type == medal_type && medal.citation == citation)
				human_stats.medal_list.Remove(medal)
				medal.delete()
				break

>>>>>>> parent of 35de48867e (Squash my asss (STATISTIC))
	return TRUE

