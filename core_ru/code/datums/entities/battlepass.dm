GLOBAL_LIST_INIT_TYPED(current_battlepasses, /datum/view_record/battlepass_player, list())

GLOBAL_LIST_INIT_TYPED(battlepasses, /datum/view_record/battlepass_player, load_battlepasses())

/proc/load_battlepasses()
	WAIT_DB_READY
	UNTIL(GLOB.current_battlepass)
	var/list/ckeyd_battlepasses = list()
	var/list/datum/view_record/battlepass_player/battlepasses = DB_VIEW(/datum/view_record/battlepass_player)
	for(var/datum/view_record/battlepass_player/battlepass as anything in battlepasses)
		if(battlepass.season == GLOB.current_battlepass.season)
			GLOB.current_battlepasses += battlepass
		if(!length(ckeyd_battlepasses[battlepass.ckey]))
			ckeyd_battlepasses[battlepass.ckey] = list()
		ckeyd_battlepasses[battlepass.ckey] += battlepass
	return ckeyd_battlepasses

GLOBAL_LIST_INIT_TYPED(client_loaded_battlepasses, /datum/entity/battlepass_player, list())

/datum/entity/player
	var/datum/entity/battlepass_player/battlepass

/datum/entity/battlepass_player
	var/player_id
	var/season
	var/tier = 0
	var/xp = 0
	var/daily_challenges_last_updated
	var/daily_challenges
	var/rewards
	var/premium_rewards
	var/premium = FALSE

	var/datum/entity/player/owner
	var/list/datum/battlepass_challenge/mapped_daily_challenges = list()
	var/list/mapped_rewards
	var/list/mapped_premium_rewards

///BSQL_PROTECT_DATUM(/datum/entity/battlepass_player)

/datum/entity_meta/battlepass_player
	entity_type = /datum/entity/battlepass_player
	table_name = "battlepass_players"
	field_types = list(
		"player_id" = DB_FIELDTYPE_BIGINT,
		"season" = DB_FIELDTYPE_BIGINT,
		"tier" = DB_FIELDTYPE_BIGINT,
		"xp" = DB_FIELDTYPE_BIGINT,
		"daily_challenges_last_updated" = DB_FIELDTYPE_BIGINT,
		"daily_challenges" = DB_FIELDTYPE_STRING_MAX,
		"rewards" = DB_FIELDTYPE_STRING_MAX,
		"premium_rewards" = DB_FIELDTYPE_STRING_MAX,
		"premium" = DB_FIELDTYPE_BIGINT,
	)
	key_field = "player_id"

/datum/entity_meta/battlepass_player/map(datum/entity/battlepass_player/battlepass, list/values)
	. = ..()
	if(values["daily_challenges"])
		var/list/decoded = json_decode(values["daily_challenges"])
		for(var/list/entry as anything in decoded)
			if(!("type" in entry))
				continue

			var/path = entry["type"]
			var/datum/battlepass_challenge/challenge = new path()
			battlepass.mapped_daily_challenges += challenge
			battlepass.RegisterSignal(challenge, COMSIG_BATTLEPASS_CHALLENGE_COMPLETED, TYPE_PROC_REF(/datum/entity/battlepass_player, on_challenge_complete))
			challenge.deserialize(entry)

	if(values["rewards"])
		battlepass.mapped_rewards = json_decode(values["rewards"])
		if(!battlepass.mapped_rewards)
			battlepass.mapped_rewards = list()

	if(values["premium_rewards"])
		battlepass.mapped_premium_rewards = json_decode(values["premium_rewards"])
		if(!battlepass.mapped_premium_rewards)
			battlepass.mapped_premium_rewards = list()

/datum/entity_meta/battlepass_player/unmap(datum/entity/battlepass_player/battlepass)
	. = ..()
	if(length(battlepass.mapped_daily_challenges))
		var/list/challenges = list()
		for(var/datum/battlepass_challenge/challenge as anything in battlepass.mapped_daily_challenges)
			challenges += list(challenge.serialize())
		.["daily_challenges"] = json_encode(challenges)

	if(length(battlepass.mapped_rewards))
		.["rewards"] = json_encode(battlepass.mapped_rewards)

	if(length(battlepass.mapped_premium_rewards))
		.["premium_rewards"] = json_encode(battlepass.mapped_premium_rewards)



//BATTLEPASS FULLFILMENT
/datum/entity/battlepass_player/proc/verify_data()
	for(var/datum/battlepass_challenge/challenge as anything in mapped_daily_challenges)
		challenge.on_client_hooked(owner.owning_client)

	verify_rewards()
	check_tier_up()
	check_daily_challenge_reset()

/datum/entity/battlepass_player/proc/verify_rewards()
	for(var/reward as anything in GLOB.current_battlepass.mapped_rewards)
		if(GLOB.current_battlepass.mapped_rewards[reward]["tier"] > tier && !mapped_rewards[reward])
			continue
		if(apply_reward(GLOB.battlepass_rewards[reward]))
			mapped_rewards += reward

	if(premium)
		for(var/reward as anything in GLOB.current_battlepass.mapped_premium_rewards)
			if(GLOB.current_battlepass.mapped_premium_rewards[reward]["tier"] > tier && !mapped_premium_rewards[reward])
				continue
			if(apply_reward(GLOB.battlepass_rewards[reward]))
				mapped_premium_rewards += reward

	save()

/datum/entity/battlepass_player/proc/add_xp(xp_amount)
	if(tier >= GLOB.current_battlepass.max_tier)
		return
	xp += xp_amount
	check_tier_up()

/datum/entity/battlepass_player/proc/check_tier_up()
	if(tier < GLOB.current_battlepass.max_tier && xp >= GLOB.current_battlepass.xp_per_tier_up)
		xp -= GLOB.current_battlepass.xp_per_tier_up
		tier++
		on_tier_up()
		check_tier_up()

/datum/entity/battlepass_player/proc/on_tier_up()
	for(var/reward as anything in GLOB.current_battlepass.mapped_rewards)
		if(GLOB.current_battlepass.mapped_rewards[reward]["tier"] != tier)
			continue
		if(apply_reward(GLOB.battlepass_rewards[reward]))
			mapped_rewards += reward

	if(premium)
		for(var/reward as anything in GLOB.current_battlepass.mapped_premium_rewards)
			if(GLOB.current_battlepass.mapped_premium_rewards[reward]["tier"] != tier)
				continue
			if(apply_reward(GLOB.battlepass_rewards[reward]))
				mapped_premium_rewards += reward

	save()
	log_game("[owner.owning_client.mob] ([owner.owning_client.key]) has increased to battlepass tier [tier]")

/datum/entity/battlepass_player/proc/apply_reward(datum/view_record/battlepass_reward/reward)
	if(!owner)
		return FALSE
	switch(reward.reward_type)
		if("skin")
			if(!owner.donator_info)
				return FALSE
			var/datum/entity/skin/new_skin = owner.donator_info.skins[reward.mapped_reward_data["path"]]
			if(!new_skin)
				new_skin = DB_ENTITY(/datum/entity/skin)
				new_skin.player_id = owner.id
				new_skin.skin_name = reward.mapped_reward_data["path"]
			else if(new_skin.skin[reward.mapped_reward_data["skin"]])
				return FALSE
			new_skin.skin[reward.mapped_reward_data["skin"]] = reward.mapped_reward_data["skin"]
			new_skin.save()
		if("points")
			return FALSE // Not handled for now
		else
			return FALSE
	return TRUE

/// Check if it's been 24h since daily challenges were last assigned
/datum/entity/battlepass_player/proc/check_daily_challenge_reset()
	// 86400 seconds (24*60^2) is one day
	if((daily_challenges_last_updated + (24 * 60 * 60)) <= rustg_unix_timestamp())
		reset_daily_challenges()
		return TRUE
	return FALSE

/// Give the battlepass a new set of daily challenges
/datum/entity/battlepass_player/proc/reset_daily_challenges()
	// We give the player 2 marine challenges and 2 xeno challenges
	QDEL_LIST(mapped_daily_challenges)

	for(var/i in 1 to 2)
		var/gotten_path = SSbattlepass.get_challenge(CHALLENGE_HUMAN)
		var/datum/battlepass_challenge/human_challenge = new gotten_path(owner.owning_client)
		RegisterSignal(human_challenge, COMSIG_BATTLEPASS_CHALLENGE_COMPLETED, PROC_REF(on_challenge_complete))
		mapped_daily_challenges += human_challenge

	for(var/i in 1 to 2)
		var/gotten_path = SSbattlepass.get_challenge(CHALLENGE_XENO)
		var/datum/battlepass_challenge/xeno_challenge = new gotten_path(owner.owning_client)
		RegisterSignal(xeno_challenge, COMSIG_BATTLEPASS_CHALLENGE_COMPLETED, PROC_REF(on_challenge_complete))
		mapped_daily_challenges += xeno_challenge

	daily_challenges_last_updated = rustg_unix_timestamp()

/// Called whenever a challenge is completed
/datum/entity/battlepass_player/proc/on_challenge_complete(datum/battlepass_challenge/challenge)
	SIGNAL_HANDLER

	challenge.completed = TRUE
	add_xp(challenge.completion_xp)
	if(owner.owning_client)
		challenge.unhook_signals(owner.owning_client.mob)

/datum/entity/battlepass_player/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Battlepass")
		ui.open()
		ui.set_autoupdate(TRUE)

/datum/entity/battlepass_player/ui_state(mob/user)
	return GLOB.always_state

/datum/entity/battlepass_player/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/battlepass),
	)

/datum/entity/battlepass_player/ui_data(mob/user)
	var/list/data = list()

	data["tier"] = tier
	data["xp"] = tier >= GLOB.current_battlepass.max_tier ? GLOB.current_battlepass.xp_per_tier_up : xp
	data["xp_tierup"] = GLOB.current_battlepass.xp_per_tier_up

	return data

/datum/entity/battlepass_player/ui_static_data(mob/user)
	var/list/data = list()

	data["season"] = "Season: [GLOB.current_battlepass.season_name] ([GLOB.current_battlepass.season])"
	data["max_tier"] = GLOB.current_battlepass.max_tier

	data["rewards"] = list()
	for(var/reward as anything in GLOB.current_battlepass.mapped_rewards)
		data["rewards"] += list(GLOB.battlepass_rewards[reward].get_ui_data(GLOB.current_battlepass.mapped_rewards[reward]))

	data["premium"] = premium
	data["premium_rewards"] = list()
	for(var/reward as anything in GLOB.current_battlepass.mapped_premium_rewards)
		data["premium_rewards"] += list(GLOB.battlepass_rewards[reward].get_ui_data(GLOB.current_battlepass.mapped_premium_rewards[reward]))

	data["daily_challenges"] = list()
	for(var/datum/battlepass_challenge/daily_challenge as anything in mapped_daily_challenges)
		data["daily_challenges"] += list(list(
			"name" = daily_challenge.name,
			"desc" = daily_challenge.desc,
			"completed" = daily_challenge.completed,
			"category" = daily_challenge.challenge_category,
			"completion_xp" = daily_challenge.completion_xp,
			"completion_percent" = daily_challenge.get_completion_percent(),
			"completion_numerator" = daily_challenge.get_completion_numerator(),
			"completion_denominator" = daily_challenge.get_completion_denominator(),
		))

	return data



//BATTLEPASS ENTITY VIEW META
/datum/entity_link/player_to_battlepass
	parent_entity = /datum/entity/player
	child_entity = /datum/entity/battlepass_player
	child_field = "player_id"

	parent_name = "player"
	child_name = "battlepass_player"

/datum/view_record/battlepass_player
	var/player_id
	var/season
	var/tier
	var/xp
	var/daily_challenges_last_updated
	var/daily_challenges
	var/rewards
	var/premium_rewards
	var/premium = FALSE

	var/ckey
	var/list/mapped_rewards
	var/list/mapped_premium_rewards

/datum/entity_view_meta/battlepass_player
	root_record_type = /datum/entity/battlepass_player
	destination_entity = /datum/view_record/battlepass_player
	fields = list(
		"player_id",
		"season",
		"tier",
		"xp",
		"daily_challenges_last_updated",
		"daily_challenges",
		"rewards",
		"premium_rewards",
		"premium",
		"ckey" = "player.ckey"
	)

/datum/entity_view_meta/battlepass_player/map(datum/view_record/battlepass_player/battlepass, list/values)
	. = ..()
	if(values["rewards"])
		battlepass.mapped_rewards = json_decode(values["rewards"])

	if(values["premium_rewards"])
		battlepass.mapped_premium_rewards = json_decode(values["premium_rewards"])



//BATTLEPASS VIEW
/mob/verb/battlepass()
	set category = "OOC"
	set name = "Battlepass"

	if(!client.player_data?.battlepass)
		return

	client.player_data.battlepass.tgui_interact(src)
