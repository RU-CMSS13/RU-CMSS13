GLOBAL_LIST_EMPTY(discord_ranks)
GLOBAL_LIST_EMPTY_TYPED(donators_info, /datum/donator_info)

/datum/entity/player
	var/datum/donator_info/donator_info

/datum/entity/discord_rank
	var/rank
	var/rank_name
	var/functions
	var/list/buns = list()

BSQL_PROTECT_DATUM(/datum/entity/discord_rank)

/datum/entity_meta/discord_rank
	entity_type = /datum/entity/discord_rank
	table_name = "discord_ranks"
	field_types = list(
		"rank" = DB_FIELDTYPE_INT,
		"rank_name" = DB_FIELDTYPE_STRING_LARGE,
		"functions" = DB_FIELDTYPE_STRING_MAX,
	)

/datum/entity_meta/discord_rank/map(datum/entity/discord_rank/ET, list/values)
	..()
	if(values["functions"])
		ET.buns = json_decode(values["functions"])

/datum/entity_meta/discord_rank/unmap(datum/entity/discord_rank/ET)
	. = ..()
	if(length(ET.buns))
		.["functions"] = json_encode(ET.buns)

/datum/view_record/discord_rank
	var/rank
	var/rank_name
	var/functions
	var/list/buns = list()

/datum/entity_view_meta/discord_rank
	root_record_type = /datum/entity/discord_rank
	destination_entity = /datum/view_record/discord_rank
	fields = list(
		"rank",
		"rank_name",
		"functions",
	)
	order_by = list("rank" = DB_ORDER_BY_ASC)

/datum/entity_view_meta/discord_rank/map(datum/view_record/discord_rank/ET, list/values)
	..()
	if(values["functions"])
		ET.buns = json_decode(values["functions"])

/datum/entity/skin
	var/player_id
	var/skin_name
	var/skins_db
	var/list/skin = list()

BSQL_PROTECT_DATUM(/datum/entity/skin)

/datum/entity_meta/skin
	entity_type = /datum/entity/skin
	table_name = "players_skins"
	field_types = list(
		"player_id" = DB_FIELDTYPE_BIGINT,
		"skin_name" = DB_FIELDTYPE_STRING_LARGE,
		"skins_db" = DB_FIELDTYPE_STRING_MAX,
	)

/datum/entity_meta/skin/map(datum/entity/skin/ET, list/values)
	..()
	if(values["skins_db"])
		ET.skin = json_decode(values["skins_db"])

/datum/entity_meta/skin/unmap(datum/entity/skin/ET)
	. = ..()
	if(length(ET.skin))
		.["skins_db"] = json_encode(ET.skin)

/datum/donator_info
	var/datum/entity/player/player_datum
	var/list/skins = list()
	var/list/skins_used = list()

/datum/donator_info/New(datum/entity/player/owner_datum)
	player_datum = owner_datum
	load_info()

/datum/donator_info/proc/load_info()
	DB_FILTER(/datum/entity/skin, DB_COMP("player_id", DB_EQUALS, player_datum.id), CALLBACK(src, TYPE_PROC_REF(/datum/donator_info, load_skins)))
	if(patreon_function_available("ooc_color"))
		GLOB.donaters |= player_datum.owning_client
		add_verb(player_datum.owning_client, /client/proc/set_ooc_color_self)

/datum/donator_info/proc/load_skins(list/datum/entity/skin/entity_skins)
	for(var/datum/entity/skin/skin in entity_skins)
		skins[skin.skin_name] = skin

/datum/donator_info/proc/patreon_function_available(required)
	if(player_datum?.discord_link)
		var/datum/view_record/discord_rank/discord_rank = GLOB.discord_ranks["[player_datum.discord_link.role_rank]"]
		if(discord_rank)
			return discord_rank.buns[required]
	return FALSE
