GLOBAL_LIST_INIT_TYPED(admin_ranks, /datum/view_record/admin_rank, load_ranks())
GLOBAL_PROTECT(admin_ranks)

GLOBAL_LIST_INIT_TYPED(db_admin_datums, /datum/view_record/admin_holder, load_admins())
GLOBAL_PROTECT(db_admin_datums)

/proc/load_ranks()
	WAIT_DB_READY
	var/list/named_ranks = list()
	var/list/datum/view_record/admin_rank/ranks = DB_VIEW(/datum/view_record/admin_rank)
	for(var/datum/view_record/admin_rank/rank as anything in ranks)
		named_ranks[rank.rank] = rank
	return named_ranks

/proc/load_admins()
	WAIT_DB_READY
	var/list/ckeyed_admins = list()
	var/list/datum/view_record/admin_holder/admins = DB_VIEW(/datum/view_record/admin_holder)
	for(var/datum/view_record/admin_holder/admin as anything in admins)
		ckeyed_admins[admin.ckey] = admin
	return ckeyed_admins

/datum/entity/admin_rank
	var/rank
	var/text_rights
	var/rights = NO_FLAGS

BSQL_PROTECT_DATUM(/datum/entity/admin_rank)

/datum/entity_meta/admin_rank
	entity_type = /datum/entity/admin_rank
	table_name = "admin_ranks"
	field_types = list(
		"rank" = DB_FIELDTYPE_STRING_MEDIUM,
		"text_rights" = DB_FIELDTYPE_STRING_MAX,
	)

/datum/entity_meta/admin_rank/map(datum/entity/admin_rank/rank, list/values)
	..()
	if(values["text_rights"])
		rank.rights = rights2flags(values["text_rights"])

/datum/entity_meta/admin_rank/unmap(datum/entity/admin_rank/rank)
	. = ..()
	if(length(rank.rights))
		.["text_rights"] = flags2rights(rank.rights)

/datum/view_record/admin_rank
	var/rank
	var/text_rights
	var/rights = NO_FLAGS

/datum/entity_view_meta/admin_rank
	root_record_type = /datum/entity/admin_rank
	destination_entity = /datum/view_record/admin_rank
	fields = list(
		"rank",
		"text_rights",
	)

/datum/entity_view_meta/admin_rank/map(datum/view_record/admin_rank/rank, list/values)
	..()
	if(values["text_rights"])
		rank.rights = rights2flags(values["text_rights"])

/datum/entity/admin_holder
	var/ckey
	var/rank
	var/extra_titles_encoded
	var/list/extra_titles = list()

BSQL_PROTECT_DATUM(/datum/entity/admin_holder)

/datum/entity_meta/admin_holder
	entity_type = /datum/entity/admin_holder
	table_name = "admins"
	field_types = list(
		"ckey" = DB_FIELDTYPE_STRING_MEDIUM,
		"rank" = DB_FIELDTYPE_STRING_MEDIUM,
		"extra_titles_encoded" = DB_FIELDTYPE_STRING_MAX,
	)

/datum/entity_meta/admin_holder/map(datum/entity/admin_holder/admin, list/values)
	..()
	if(values["extra_titles_encoded"])
		admin.extra_titles = json_decode(values["extra_titles_encoded"])

/datum/entity_meta/admin_holder/unmap(datum/entity/admin_holder/admin)
	. = ..()
	if(length(admin.extra_titles))
		.["extra_titles_encoded"] = json_encode(admin.extra_titles)

/datum/view_record/admin_holder
	var/admin_id
	var/ckey
	var/rank
	var/extra_titles_encoded
	var/list/extra_titles = list()

	var/datum/view_record/admin_rank/admin_rank
	var/list/ref_vars

/datum/entity_view_meta/admin_holder
	root_record_type = /datum/entity/admin_holder
	destination_entity = /datum/view_record/admin_holder
	fields = list(
		"admin_id",
		"ckey",
		"rank",
		"extra_titles_encoded",
	)

/datum/entity_view_meta/admin_holder/map(datum/view_record/admin_holder/admin, list/values)
	..()
	admin.admin_rank = GLOB.admin_ranks[admin.rank]
	if(values["extra_titles_encoded"])
		for(var/srank in json_decode(values["extra_titles_encoded"]))
			admin.extra_titles += srank

	if(admin.ref_vars)
		admin.ref_vars["rank"] = admin.rank
		admin.ref_vars["rights"] = admin.admin_rank.text_rights

/datum/entity_view_meta/admin_holder/vv_edit_var(var_name, var_value)
	return FALSE

/proc/rights2flags(text_rights)
	var/rights = NO_FLAGS
	var/list/list_rights = splittext(text_rights, "|")
	for(var/right in list_rights)
		switch(right)
			if("buildmode")
				rights |= R_BUILDMODE
			if("admin")
				rights |= R_ADMIN
			if("ban")
				rights |= R_BAN
			if("server")
				rights |= R_SERVER
			if("debug")
				rights |= R_DEBUG
			if("permissions")
				rights |= R_PERMISSIONS
			if("possess")
				rights |= R_POSSESS
			if("stealth")
				rights |= R_STEALTH
			if("color")
				rights |= R_COLOR
			if("varedit")
				rights |= R_VAREDIT
			if("event")
				rights |= R_EVENT
			if("sounds")
				rights |= R_SOUNDS
			if("nolock")
				rights |= R_NOLOCK
			if("spawn")
				rights |= R_SPAWN
			if("mod")
				rights |= R_MOD
			if("mentor")
				rights |= R_MENTOR
			if("profiler")
				rights |= R_PROFILER
			if("host")
				rights |= RL_HOST
			if("everything")
				rights |= RL_EVERYTHING
	return rights

/proc/flags2rights(rights)
	var/text_rights = ""
	if(rights & R_BUILDMODE)
		text_rights += "build|"
	if(rights & R_ADMIN)
		text_rights += "admin|"
	if(rights & R_BAN)
		text_rights += "ban|"
	if(rights & R_SERVER)
		text_rights += "server|"
	if(rights & R_DEBUG)
		text_rights += "debug|"
	if(rights & R_PERMISSIONS)
		text_rights += "permissions|"
	if(rights & R_POSSESS)
		text_rights += "possess|"
	if(rights & R_STEALTH)
		text_rights += "stealth|"
	if(rights & R_COLOR)
		text_rights += "color|"
	if(rights & R_VAREDIT)
		text_rights += "varedit|"
	if(rights & R_EVENT)
		text_rights += "event|"
	if(rights & R_SOUNDS)
		text_rights += "sounds|"
	if(rights & R_NOLOCK)
		text_rights += "nolock|"
	if(rights & R_SPAWN)
		text_rights += "spawn|"
	if(rights & R_MOD)
		text_rights += "mod|"
	if(rights & R_MENTOR)
		text_rights += "mentor|"
	if(rights & R_PROFILER)
		text_rights += "profiler|"
	if(rights & RL_HOST)
		text_rights += "host|"
	if(rights & RL_EVERYTHING)
		text_rights += "everything|"
	return text_rights

/proc/localhost_rank_check(client/admin_client, list/datum/entity/admin_rank/ranks)
	var/datum/entity/admin_rank/rank
	if(!length(ranks))
		rank = DB_ENTITY(/datum/entity/admin_rank)
		rank.rank = "!localhost!"
		rank.rights = RL_HOST
		rank.text_rights = "host"
		rank.save()
	else
		rank = ranks[length(ranks)]

	DB_FILTER(/datum/entity/admin_holder, DB_COMP("ckey", DB_EQUALS, admin_client.ckey), CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(localhost_entity_check), admin_client, rank))

/proc/localhost_entity_check(client/admin_client, datum/entity/admin_rank/rank, list/datum/entity/admin_holder/admins)
	var/datum/entity/admin_holder/admin
	if(!length(admins))
		admin = DB_ENTITY(/datum/entity/admin_holder)
		admin.ckey = admin_client.ckey
		admin.rank = rank.rank
		admin.save()
	else
		admin = admins[length(admins)]

	if(!admin_client.admin_holder)
		GLOB.admin_ranks = load_ranks()
		GLOB.db_admin_datums = load_admins()
		admin_client.admin_holder = GLOB.admin_datums[admin_client.ckey]
		admin_client.admin_holder.associate(admin_client)

/datum/admins/New(ckey)
	if(!ckey)
		error("Admin datum created without a ckey argument. Datum has been deleted")
		qdel(src)
		return

	var/datum/view_record/admin_holder/db_holder = GLOB.db_admin_datums[ckey]
	db_holder.ref_vars = vars
	rank = db_holder.rank
	rights = db_holder.admin_rank.text_rights
	extra_titles = db_holder.extra_titles

	href_token = GenerateToken()
	GLOB.admin_datums[ckey] = src
