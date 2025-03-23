/client/proc/Rank_panel()
	set category = "Admin.Panels"
	set name = "Rank Management Panel"
	set desc = "Players Rank Management Panel"

	if(admin_holder)
		admin_holder.rank_modify_panel_ru(ckey)
	return

/datum/admins/proc/Rank_types_view_panel()

	if (!istype(src,/datum/admins))
		src = usr.client.admin_holder
	if (!istype(src,/datum/admins) || !(src.rights & R_PERMISSIONS))
		to_chat(usr, "Error: you are not a Staff Manager!")
		return

	var/list/named_ranks = list()
	var/list/datum/view_record/admin_rank/ranks = DB_VIEW(/datum/view_record/admin_rank)
	for(var/datum/view_record/admin_rank/rank as anything in ranks)
		named_ranks[rank.rank_name] = rank

	var/dat = {"<meta charset="UTF-8"><div align='center'><table width='90%'><tr>"}

	dat += "<div align='center'><width='90%'> <h1>Rank panel</h1></div><tr>"

	dat += "|-rank_id-----rank name--------rank_text_flag---------bit_flag---|<br>"
	for(var/datum/view_record/admin_rank/rank as anything in ranks)
		named_ranks[rank.rank_name] = rank
		dat += "|--|[rank.id]|----------|[rank.rank_name]|------------|[rank.text_rights]|-------------|[rights2flags(rank.text_rights)]|<br>"

	dat += "|-----------------------------------------------------------------------------|"
	show_browser(usr, dat, "Ranks Info Panel", "Ranksinfo", "size=480x480")

/datum/admins/proc/rank_modify_panel_ru()

	if(!istype(src,/datum/admins))
		src = usr.client.admin_holder
	if(!istype(src,/datum/admins) || !(src.rights & R_PERMISSIONS))
		to_chat(usr, "Error: you are not a Staff Manager!")
		return

	var/ckey = ckey(input("Enter ACCURATE Ckey for future manipulations","Enter ACCURATE CKEY", null) as null|text)
	var/datum/view_record/players/player = locate() in DB_VIEW(/datum/view_record/players, DB_COMP("ckey", DB_EQUALS, ckey))
	if(!player)
		to_chat(usr, "Database lookup failed.No file was found.")
		return
	var/datum/view_record/admin_holder/holder = locate() in DB_VIEW(/datum/view_record/admin_holder, DB_COMP("player_id", DB_EQUALS, player.id))
	if(!holder)
		to_chat(usr,"no holder found.")
		return
	var/dat = {"<meta charset="UTF-8"><div align='center'><table width='90%'><tr>"}
	dat += "Checked key:[ckey]<br>"
	dat += "[holder.rank_name?(holder.rank_name):"No Status"]<br>"
	dat += "<A href='byond://?src=\ref[src];[HrefToken()];modify_rank=1;holder=[holder]'>Modify rank</A><br>"
	dat += "<A href='byond://?src=\ref[src];[HrefToken()];rank_view=1'>Check Ranks</A><br>"
	dat += "<A href='byond://?src=\ref[src];[HrefToken()];admin_view=1'>Check Current Admins</A><br>"
	dat += "<br>"
	show_browser(usr, dat, "Rank Panel", "Rankplayerinfo", "size=480x480")

/datum/admins/proc/view_current_admins_ru()

	if (!istype(src, /datum/admins))
		src = usr.client.admin_holder
	if (!istype(src, /datum/admins) || !(src.rights & R_PERMISSIONS))
		to_chat(usr, "Error: you are not a Staff Manager!")
		return

	var/dat = {"<meta charset="UTF-8"><div align='center'><table width='90%'><tr>"}

	dat += "<div align='center'><width='90%'> <h1>Rank panel</h1></div><tr>"

	dat += "|-player_id-----rank_id--------ckey---------extra_titles---|<br>"
	var/list/datum/view_record/admin_holder/holder = DB_VIEW(/datum/view_record/admin_holder)
	for(var/datum/view_record/admin_holder/h as anything in holder)
		dat += "|--|[h?.player_id]|----------|[h?.rank_id]|------------|[h?.ckey]|-------------|[h?.extra_titles_encoded]|<br>"

	dat += "|-----------------------------------------------------------------------------|"
	show_browser(usr, dat, "Ranks Info Panel", "Ranksinfo", "size=480x480")

/datum/admins/proc/rank_modify_ru(var/datum/view_record/admin_holder/holder1)

	var/datum/view_record/admin_holder/holder = holder1
	if (!istype(src,/datum/admins))
		src = usr.client.admin_holder
	if (!istype(src,/datum/admins) || !(src.rights & R_PERMISSIONS))
		to_chat(usr, "Error: you are not a Staff Manager!")
		return

	var/new_rank_id = input("Enter ACCURATE Number for role for future manipulations","Enter ACCURATE NUMBER", null) as null|num
	if(!isnum(new_rank_id))
		to_chat(usr, "Error: Entered wrong value type!")
		return
	var/list/datum/view_record/admin_rank/ranks = DB_VIEW(/datum/view_record/admin_rank)
	for(var/datum/view_record/admin_rank/rank as anything in ranks)
		if(rank.id == new_rank_id)
			var/datum/entity/admin_holder/ent_holder = DB_ENTITY(/datum/entity/admin_holder)
			ent_holder.player_id = holder.player_id
			ent_holder.rank_id = rank.id
			ent_holder.extra_titles_encoded = holder.extra_titles_encoded
			ent_holder.save()
			message_admins("[usr.ckey] updated rank on [holder.ckey] ")
			//GLOB.db_admin_datums = load_admins()
			return
	to_chat(usr, "Error: Could not find rank!")
	return

//datum/admins/proc/rank_modify_titles_ru(/datum/view_record/admin_holder/holder)
