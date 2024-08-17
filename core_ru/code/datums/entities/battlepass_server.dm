GLOBAL_DATUM(current_battlepass, /datum/entity/battlepass_server)

GLOBAL_LIST_INIT_TYPED(server_battlepasses, /datum/view_record/battlepass_server, load_server_battlepasses())

/proc/load_server_battlepasses()
	WAIT_DB_READY
	var/current_battlepass_id = 0
	var/current_name = ""
	var/list/season_battlepasses = list()
	var/list/datum/view_record/battlepass_server/battlepasses = DB_VIEW(/datum/view_record/battlepass_server)
	for(var/datum/view_record/battlepass_server/battlepass as anything in battlepasses)
		season_battlepasses[battlepass.season_name] = battlepass
		if(battlepass.season > current_battlepass_id)
			current_battlepass_id = battlepass.season
			current_name = battlepass.season_name

	GLOB.current_battlepass = DB_EKEY(/datum/entity/battlepass_server, current_name)
	if(GLOB.current_battlepass)
		GLOB.current_battlepass.sync()
	return season_battlepasses

/datum/entity/battlepass_server
	var/season
	var/season_name
	var/max_tier
	var/xp_per_tier_up

	var/rewards
	var/premium_rewards
	var/point_sources

	var/start_round_id
	var/potential_last_round_id

	var/list/mapped_rewards
	var/list/mapped_premium_rewards
	var/list/mapped_point_sources

BSQL_PROTECT_DATUM(/datum/entity/battlepass_server)

/datum/entity_meta/battlepass_server
	entity_type = /datum/entity/battlepass_server
	table_name = "battlepass_server"
	field_types = list(
		"season" = DB_FIELDTYPE_BIGINT,
		"season_name" = DB_FIELDTYPE_STRING_LARGE,
		"max_tier" = DB_FIELDTYPE_BIGINT,
		"xp_per_tier_up" = DB_FIELDTYPE_BIGINT,
		"rewards" = DB_FIELDTYPE_STRING_MAX,
		"premium_rewards" = DB_FIELDTYPE_STRING_MAX,
		"point_sources" = DB_FIELDTYPE_STRING_MAX,
		"start_round_id" = DB_FIELDTYPE_BIGINT,
		"potential_last_round_id" = DB_FIELDTYPE_BIGINT,
	)
	key_field = "season"

/datum/entity_meta/battlepass_server/map(datum/entity/battlepass_server/battlepass, list/values)
	. = ..()
	if(values["rewards"])
		battlepass.mapped_rewards = json_decode(values["rewards"])
	if(values["premium_rewards"])
		battlepass.mapped_premium_rewards = json_decode(values["premium_rewards"])
	if(values["point_sources"])
		battlepass.mapped_point_sources = json_decode(values["point_sources"])

/datum/entity_meta/battlepass_server/unmap(datum/entity/battlepass_server/battlepass)
	. = ..()
	if(length(battlepass.mapped_rewards))
		.["rewards"] = json_encode(battlepass.mapped_rewards)
	if(length(battlepass.mapped_premium_rewards))
		.["premium_rewards"] = json_encode(battlepass.mapped_premium_rewards)
	if(length(battlepass.mapped_point_sources))
		.["point_sources"] = json_encode(battlepass.mapped_point_sources)

/datum/view_record/battlepass_server
	var/season
	var/season_name
	var/max_tier
	var/xp_per_tier_up
	var/rewards
	var/premium_rewards

	var/start_round_id
	var/potential_last_round_id

	var/list/mapped_rewards
	var/list/mapped_premium_rewards

/datum/entity_view_meta/battlepass_server
	root_record_type = /datum/entity/battlepass_server
	destination_entity = /datum/view_record/battlepass_server
	fields = list(
		"season",
		"season_name",
		"max_tier",
		"xp_per_tier_up",
		"rewards",
		"premium_rewards",
		"start_round_id",
		"potential_last_round_id",
	)

/datum/entity_view_meta/battlepass_server/map(datum/view_record/battlepass_server/battlepass, list/values)
	. = ..()
	if(values["rewards"])
		battlepass.mapped_rewards = json_decode(values["rewards"])
	if(values["premium_rewards"])
		battlepass.mapped_premium_rewards = json_decode(values["premium_rewards"])
