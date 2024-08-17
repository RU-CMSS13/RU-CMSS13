GLOBAL_LIST_INIT_TYPED(current_battlepasses, /datum/view_record/client_battlepass, list())

GLOBAL_LIST_INIT_TYPED(battlepasses, /datum/view_record/client_battlepass, load_battlepasses())

/proc/load_battlepasses()
	WAIT_DB_READY
	UNTIL(GLOB.current_battlepass)
	var/list/ckeyd_battlepasses = list()
	var/list/datum/view_record/client_battlepass/battlepasses = DB_VIEW(/datum/view_record/client_battlepass)
	for(var/datum/view_record/client_battlepass/battlepass as anything in battlepasses)
		if(battlepass.season == GLOB.current_battlepass.season)
			GLOB.current_battlepasses += battlepass
		if(!length(ckeyd_battlepasses[battlepass.ckey]))
			ckeyd_battlepasses[battlepass.ckey] = list()
		ckeyd_battlepasses[battlepass.ckey] += battlepass
	return ckeyd_battlepasses

GLOBAL_LIST_INIT_TYPED(client_loaded_battlepasses, /datum/entity/client_battlepass, list())

/datum/entity/player
	var/datum/entity/client_battlepass/battlepass
	var/list/datum/view_record/client_battlepass/all_seasons_battlepass

/datum/entity/client_battlepass
	var/player_id
	var/season
	var/tier = 0
	var/xp = 0
	var/daily_challenges_last_updated
	var/daily_challenges
	var/rewards
	var/previous_on_tier_up_tier
	var/premium = FALSE

	var/season_name
	var/datum/entity/player/owner
	var/list/datum/battlepass_challenge/mapped_daily_challenges = list()
	var/list/mapped_rewards

BSQL_PROTECT_DATUM(/datum/entity/client_battlepass)

/datum/entity_meta/client_battlepass
	entity_type = /datum/entity/client_battlepass
	table_name = "player_battlepasses"
	field_types = list(
		"player_id" = DB_FIELDTYPE_BIGINT,
		"season" = DB_FIELDTYPE_BIGINT,
		"tier" = DB_FIELDTYPE_BIGINT,
		"xp" = DB_FIELDTYPE_BIGINT,
		"daily_challenges_last_updated" = DB_FIELDTYPE_BIGINT,
		"daily_challenges" = DB_FIELDTYPE_STRING_MAX,
		"rewards" = DB_FIELDTYPE_STRING_MAX,
		"previous_on_tier_up_tier" = DB_FIELDTYPE_BIGINT,
		"premium" = DB_FIELDTYPE_BIGINT,
	)
	key_field = "player_id"

/datum/entity_meta/client_battlepass/map(datum/entity/client_battlepass/battlepass, list/values)
	..()

	battlepass.check_tier_up(FALSE)
	if(values["daily_challenges"])
		var/list/decoded = json_decode(values["daily_challenges"])
		for(var/list/entry as anything in decoded)
			if(!("type" in entry))
				continue

			var/path = entry["type"]
			var/datum/battlepass_challenge/challenge = new path()
			battlepass.mapped_daily_challenges += challenge
			battlepass.RegisterSignal(challenge, COMSIG_BATTLEPASS_CHALLENGE_COMPLETED, TYPE_PROC_REF(/datum/entity/client_battlepass, on_challenge_complete))
			challenge.deserialize(entry)

	if(values["rewards"])
		battlepass.mapped_rewards = json_decode(values["rewards"])

	battlepass.check_daily_challenge_reset()
	battlepass.verify_rewards()

/datum/entity_meta/client_battlepass/unmap(datum/entity/client_battlepass/battlepass)
	. = ..()
	if(length(battlepass.mapped_daily_challenges))
		var/list/challenges = list()
		for(var/datum/battlepass_challenge/challenge as anything in battlepass.mapped_daily_challenges)
			challenges += list(challenge.serialize())
		.["daily_challenges"] = json_encode(challenges)

	if(length(battlepass.mapped_rewards))
		.["rewards"] = json_encode(battlepass.mapped_rewards)



//BATTLEPASS FULLFILMENT
/datum/entity/client_battlepass/proc/verify_data()
	for(var/datum/battlepass_challenge/challenge as anything in mapped_daily_challenges)
		challenge.on_client_hooked(owner.owning_client)

	check_tier_up(FALSE)
	check_daily_challenge_reset()






//BATTLEPASS ACTIONS
/mob/verb/battlepass()
	set category = "OOC"
	set name = "Battlepass"

	if(!client.player_data?.battlepass)
		return

	client.player_data.battlepass.tgui_interact(src)

/*
/mob/living/carbon/verb/claim_battlepass_reward()
	set category = "OOC"
	set name = "Claim Battlepass Reward"

	if(!client)
		return

	var/list/acceptable_rewards = list()
	for(var/datum/battlepass_reward/reward as anything in client.player_data.battlepass.rewards)
		if(reward.can_claim(src))
			acceptable_rewards += reward

	if(!length(acceptable_rewards))
		to_chat(src, SPAN_WARNING("You have no rewards to claim."))
		return

	var/datum/battlepass_reward/chosen_reward = tgui_input_list(src, "Claim a battlepass reward.", "Claim Reward", acceptable_rewards)
	if(!chosen_reward || !chosen_reward.can_claim(src))
		return

	if(chosen_reward.on_claim(src))
		claimed_reward_categories |= chosen_reward.category

/datum/entity/client_battlepass/proc/on_tier_up()
	if(previous_on_tier_up_tier == tier)
		return

	for(var/i in previous_on_tier_up_tier + 1 to tier)
		if(SSbattlepass.season_rewards.len < i)
			break
		var/reward_path = SSbattlepass.season_rewards[i]
		var/datum/battlepass_reward/reward = new reward_path
		rewards += reward
		reward_paths += reward_path

	if(display_popup)
		display_tier_up_popup()

	var/list/types_in_rewards = list()
	for(var/datum/battlepass_reward/reward as anything in rewards)
		if(reward.type in types_in_rewards)
			rewards -= reward
			reward_paths -= reward.type
			qdel(reward)
			continue

		types_in_rewards += reward.type

	previous_on_tier_up_tier = tier
	log_game("[owner.owning_client.mob] ([owner.owning_client.key]) has increased to battlepass tier [tier]")
*/

/* Not really used by now
/datum/entity/client_battlepass/proc/display_tier_up_popup()
	var/client/user_client = owner.owning_client
	if(!user_client.mob)
		return

	playsound_client(user_client, 'core_ru/sound/effects/bp_levelup.mp3', get_turf(user_client.mob), 70, FALSE) // .mp3, sue me
	user_client.mob.overlay_fullscreen("battlepass_tierup", /atom/movable/screen/fullscreen/battlepass)
	addtimer(CALLBACK(user_client.mob, TYPE_PROC_REF(/mob, clear_fullscreen), "battlepass_tierup", 0), 1.2 SECONDS)
*/

/// Check that the user has all the rewards they should (in case rewards shifted in config or etc).
/// Doesn't remove ones that aren't in their tiers (in case they have some from a previous season, for example)
/datum/entity/client_battlepass/proc/verify_rewards()
/*
	for(var/i = 1 to tier)
		if(SSbattlepass.season_rewards.len < i)
			break
		var/reward_path = SSbattlepass.season_rewards[i]
		if(reward_path in reward_paths)
			continue

		rewards += new reward_path
		reward_paths += reward_path
*/

/datum/entity/client_battlepass/proc/add_xp(xp_amount)
	if(tier >= GLOB.current_battlepass.max_tier)
		return
	xp += xp_amount
	check_tier_up()

/datum/entity/client_battlepass/proc/check_tier_up()
	if(xp >= GLOB.current_battlepass.xp_per_tier_up)
		var/tier_increase = round(xp / GLOB.current_battlepass.xp_per_tier_up)
		xp -= (tier_increase * GLOB.current_battlepass.xp_per_tier_up)
		tier += tier_increase
		if(!tier_increase)
			return
		on_tier_up(tier_increase)

/datum/entity/client_battlepass/proc/on_tier_up(tier_increase)
	for(var/i in previous_on_tier_up_tier + 1 to tier)
		if(SSbattlepass.season_rewards.len < i)
			break
		var/reward_path = SSbattlepass.season_rewards[i]
		var/datum/battlepass_reward/reward = new reward_path
		rewards += reward
		reward_paths += reward_path

/// Check if it's been 24h since daily challenges were last assigned
/datum/entity/client_battlepass/proc/check_daily_challenge_reset()
	// 86400 seconds (24*60^2) is one day
	if((daily_challenges_last_updated + (24 * 60 * 60)) <= rustg_unix_timestamp())
		reset_daily_challenges()
		return TRUE
	return FALSE

/// Give the battlepass a new set of daily challenges
/datum/entity/client_battlepass/proc/reset_daily_challenges()
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
/datum/entity/client_battlepass/proc/on_challenge_complete(datum/battlepass_challenge/challenge)
	SIGNAL_HANDLER

	challenge.completed = TRUE
	add_xp(challenge.completion_xp)
	if(owner.owning_client)
		challenge.unhook_signals(owner.owning_client.mob)

/datum/entity/client_battlepass/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Battlepass")
		ui.open()
		ui.set_autoupdate(TRUE)

/datum/entity/client_battlepass/ui_state(mob/user)
	return GLOB.always_state

/datum/entity/client_battlepass/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/battlepass),
	)

/datum/entity/client_battlepass/ui_data(mob/user)
	var/list/data = list()

	data["tier"] = tier
	data["xp"] = tier >= GLOB.current_battlepass.max_tier ? GLOB.current_battlepass.xp_per_tier_up : xp
	data["xp_tierup"] = GLOB.current_battlepass.xp_per_tier_up

	return data

/datum/entity/client_battlepass/ui_static_data(mob/user)
	var/list/data = list()

	data["season"] = "Season: [GLOB.current_battlepass.season_name] ([GLOB.current_battlepass.season])"
	data["max_tier"] = GLOB.current_battlepass.max_tier

	data["rewards"] = list()
	for(var/reward as anything in GLOB.current_battlepass.mapped_rewards)
		data["rewards"] += list(GLOB.current_battlepass.mapped_rewards[reward])

	data["premium_rewards"] = list()
	for(var/reward as anything in GLOB.current_battlepass.mapped_premium_rewards)
		data["premium_rewards"] += list(GLOB.current_battlepass.mapped_premium_rewards[reward])

	data["daily_challenges"] = list()
	for(var/datum/battlepass_challenge/daily_challenge as anything in daily_challenges)
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
	child_entity = /datum/entity/client_battlepass
	child_field = "player_id"

	parent_name = "player"
	child_name = "client_battlepass"

/datum/entity_link/player_to_battlepass
	parent_entity = /datum/entity/player
	child_entity = /datum/entity/client_battlepass
	child_field = "player_id"

	parent_name = "player"
	child_name = "client_battlepass"

/datum/view_record/client_battlepass
	var/player_id
	var/season
	var/tier
	var/xp
	var/daily_challenges_last_updated
	var/premium = FALSE

	var/ckey

/datum/entity_view_meta/client_battlepass
	root_record_type = /datum/entity/client_battlepass
	destination_entity = /datum/view_record/client_battlepass
	fields = list(
		"player_id",
		"season",
		"tier",
		"xp",
		"daily_challenges_last_updated",
		"daily_challenges",
		"rewards",
		"premium",
		"ckey" = "player.ckey",
	)
