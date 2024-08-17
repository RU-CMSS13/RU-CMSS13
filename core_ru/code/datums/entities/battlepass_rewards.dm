GLOBAL_LIST_INIT_TYPED(battlepass_rewards, /datum/view_record/battlepass_reward, load_battlepass_rewards())

/proc/load_battlepass_rewards()
	WAIT_DB_READY
	var/list/all_rewards = list()
	var/list/datum/view_record/battlepass_reward/rewards = DB_VIEW(/datum/view_record/battlepass_reward)
	for(var/datum/view_record/battlepass_reward/reward as anything in rewards)
		all_rewards[reward.unique_name] = reward
	return all_rewards

/datum/entity/battlepass_reward
	var/unique_name

BSQL_PROTECT_DATUM(/datum/entity/battlepass_reward)

/datum/entity_meta/battlepass_reward
	entity_type = /datum/entity/battlepass_reward
	table_name = "battlepass_rewards"
	field_types = list(
		"unique_name" = DB_FIELDTYPE_STRING_LARGE,
	)
	key_field = "unique_name"

/datum/entity/battlepass_reward/proc/get_ui_data()
	.["tier"]
	.["name"]
	.["icon_state"]
	.["lifeform_type"]


/datum/view_record/battlepass_reward
	var/unique_name

/datum/entity_view_meta/battlepass_reward
	root_record_type = /datum/entity/battlepass_reward
	destination_entity = /datum/view_record/battlepass_reward
	fields = list(
		"unique_name",
	)
