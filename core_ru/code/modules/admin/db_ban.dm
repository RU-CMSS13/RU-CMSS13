
/client/proc/DB_ban_panel()
	set category = "Admin.Panels"
	set name = "Banning Panel"
	set desc = "Data Ban Panel"

	if(admin_holder)
		var/ckey = ckey(input("Enter ACCURATE Ckey for future manipulations","Enter ACCURATE CKEY", null) as null|text)
		var/datum/view_record/players/player = locate() in DB_VIEW(/datum/view_record/players, DB_COMP("ckey", DB_EQUALS, ckey))
		if(!player)
			to_chat(usr, "Database lookup failed.No file was found.")
			return
		if(ckey in GLOB.admin_datums)
			to_chat(usr, "Ckey belong to server staff. Aborting search.")
			return
		admin_holder.DB_ban_panel(ckey)
	return

/datum/admins/proc/DB_ban_panel(key as text)

	if (!istype(src,/datum/admins))
		src = usr.client.admin_holder
	if (!istype(src,/datum/admins) || !(src.rights & R_BAN))
		to_chat(usr, "Error: you are not an admin!")
		return

	var/datum/entity/player/P = get_player_from_key(key)

	var/dat = {"<meta charset="UTF-8"><div align='center'><table width='90%'><tr>"}

	dat += "<div align='center'><width='90%'> <h1>Banning panel</h1></div><tr>"

	dat += "Checked key:[key]<br>"
	dat += "Is banned temporal:[P.is_time_banned == 1?"Yes":"No"]<br>"
	dat += "Is banned permanent:[P.is_permabanned == 1?"Yes":"No"]<br>"
	dat += "<A href='byond://?src=\ref[src];[HrefToken()];CheckPlaytimesRu=1;ckey=[P.ckey]'>Check Playtimes</A><br>"
	dat += "<A href='byond://?src=\ref[src];[HrefToken()];add_player_info=[P.ckey]'>Add Note</A><br>"
	dat += "<A href='byond://?src=\ref[src];[HrefToken()];add_player_info_confidential=[P.ckey]'>Add Confidential Note</A><br>"
	dat += "<A href='byond://?src=\ref[src];[HrefToken()];player_notes_all=[P.ckey]'>Show Complete Record</A><br>"
	dat += "<A href='byond://?src=\ref[src];[HrefToken()];check_ckey=[P.ckey];ckey=[P.ckey]'>Check Ckey</A><br>"
	dat += "<a href='byond://?src=\ref[src];[HrefToken()];sticky_ru=1;new_sticky=1;ckey=[P.ckey]'>Add Sticky Ban</a>"
	dat += "<a href='byond://?src=\ref[src];[HrefToken()];sticky_ru=1;find_sticky=1;ckey=[P.ckey]'>Find Sticky Ban</a><br>"
	dat += "<A href='byond://?src=\ref[src];[HrefToken()];BanRu=1;ckey=[P.ckey]'>Temporal Ban</A><br>"
	dat += "<A href='byond://?src=\ref[src];[HrefToken()];BanPermaRu=1;ckey=[P.ckey]'>Permanent Ban</A><br>"
	dat += "<A href='byond://?src=\ref[src];[HrefToken()];JobBanRu=1;ckey=[P.ckey]'>Job ban</A><br>"
	show_browser(usr, dat, "Ban Panel", "adminplayerinfo", "size=480x480")

/datum/admins/proc/job_ban_ru(ckey)
	if(!check_rights(R_BAN))  return

	var/datum/view_record/players/player = locate() in DB_VIEW(/datum/view_record/players, DB_COMP("ckey", DB_EQUALS, ckey))
	if(!player)
		to_chat(usr, "Database lookup failed.No file was found.")
		return

	var/datum/entity/player/P = get_player_from_key(ckey)
	if(!GLOB.RoleAuthority)
		to_chat(usr, "The Role Authority is not set up!")
		return

	var/dat = ""
	var/body
	var/jobs = ""

/* WARNING!
					The jobban stuff looks mangled and disgusting
							But it looks beautiful in-game
									-Nodrak
WARNING!*/
//Regular jobs
//Command (Blue)
	jobs += generate_job_ban_list_ru(ckey, P, GLOB.ROLES_CIC, "CIC", "ddddff")
	jobs += "<br>"
// SUPPORT
	jobs += generate_job_ban_list_ru(ckey, P, GLOB.ROLES_AUXIL_SUPPORT, "Support", "ccccff")
	jobs += "<br>"
// MPs
	jobs += generate_job_ban_list_ru(ckey, P, GLOB.ROLES_POLICE, "Police", "ffdddd")
	jobs += "<br>"
//Engineering (Yellow)
	jobs += generate_job_ban_list_ru(ckey, P, GLOB.ROLES_ENGINEERING, "Engineering", "fff5cc")
	jobs += "<br>"
//Cargo (Yellow) //Copy paste, yada, yada. Hopefully Snail can rework this in the future.
	jobs += generate_job_ban_list_ru(ckey, P, GLOB.ROLES_REQUISITION, "Requisition", "fff5cc")
	jobs += "<br>"
//Medical (White)
	jobs += generate_job_ban_list_ru(ckey, P, GLOB.ROLES_MEDICAL, "Medical", "ffeef0")
	jobs += "<br>"
//Marines
	jobs += generate_job_ban_list_ru(ckey, P, GLOB.ROLES_MARINES, "Marines", "ffeeee")
	jobs += "<br>"
// MISC
	jobs += generate_job_ban_list_ru(ckey, P, GLOB.ROLES_MISC, "Misc", "aaee55")
	jobs += "<br>"
// Xenos (Orange)
	jobs += generate_job_ban_list_ru(ckey, P, GLOB.ROLES_XENO, "Xenos", "a268b1")
	jobs += "<br>"
//Extra (Orange)
	var/isbanned_dept = jobban_isbanned_ru(ckey, "Syndicate", P)
	jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
	jobs += "<tr bgcolor='ffeeaa'><th colspan='10'><a href='byond://?src=\ref[src];[HrefToken(forceGlobal = TRUE)];JobBanRu3=Syndicate'>Extras</a></th></tr><tr align='center'>"

	//ERT
	if(jobban_isbanned_ru(ckey, "Emergency Response Team", P) || isbanned_dept)
		jobs += "<td width='20%'><a href='byond://?src=\ref[src];[HrefToken(forceGlobal = TRUE)];JobBanRu3=Emergency Response Team;ckey=[ckey]'><font color=red>Emergency Response Team</font></a></td>"
	else
		jobs += "<td width='20%'><a href='byond://?src=\ref[src];[HrefToken(forceGlobal = TRUE)];JobBanRu3=Emergency Response Team;ckey=[ckey]'>Emergency Response Team</a></td>"

	//Survivor
	if(jobban_isbanned_ru(ckey, "Survivor", P) || isbanned_dept)
		jobs += "<td width='20%'><a href='byond://?src=\ref[src];[HrefToken(forceGlobal = TRUE)];JobBanRu3=Survivor;ckey=[ckey]'><font color=red>Survivor</font></a></td>"
	else
		jobs += "<td width='20%'><a href='byond://?src=\ref[src];[HrefToken(forceGlobal = TRUE)];JobBanRu3=Survivor;ckey=[ckey]'>Survivor</a></td>"

	if(jobban_isbanned_ru(ckey, "Agent", P) || isbanned_dept)
		jobs += "<td width='20%'><a href='byond://?src=\ref[src];[HrefToken(forceGlobal = TRUE)];JobBanRu3=Agent;ckey=[ckey]'><font color=red>Agent</font></a></td>"
	else
		jobs += "<td width='20%'><a href='byond://?src=\ref[src];[HrefToken(forceGlobal = TRUE)];JobBanRu3=Agent;ckey=[ckey]'>Agent</a></td>"

	if(jobban_isbanned_ru(ckey, "Urgent Adminhelp", P))
		jobs += "<td width='20%'><a href='byond://?src=\ref[src];[HrefToken(forceGlobal = TRUE)];JobBanRu3=Urgent Adminhelp;ckey=[ckey]'><font color=red>Urgent Adminhelp</font></a></td>"
	else
		jobs += "<td width='20%'><a href='byond://?src=\ref[src];[HrefToken(forceGlobal = TRUE)];JobBanRu3=Urgent Adminhelp;ckey=[ckey]'>Urgent Adminhelp</a></td>"


	body = "<body>[jobs]</body>"
	dat = "<tt>[body]</tt>"
	show_browser(owner, dat, "Job-Ban Panel: [ckey]", "jobban2", "size=800x490")
	return

/proc/jobban_isbanned_ru(ckey, rank, datum/entity/player/P = null)
	if(!P)
		P = get_player_from_key(ckey)
	if(!rank)
		return "Non-existant job"
	rank = ckey(rank)
	if(P)
		// asking for a friend
		if(!P.jobbans_loaded)
			return "Not yet loaded"
		var/datum/entity/player_job_ban/PJB = P.job_bans[rank]
		return PJB ? PJB.text : null

/datum/admins/proc/generate_job_ban_list_ru(ckey, datum/entity/player/P, list/roles, department, color = "ccccff")
	if(!check_rights(R_BAN))  return

	var/datum/view_record/players/player = locate() in DB_VIEW(/datum/view_record/players, DB_COMP("ckey", DB_EQUALS, ckey))
	if(!player)
		to_chat(usr, "Database lookup failed.No file was found.")
		return

	var/counter = 0

	var/dat = ""
	dat += "<table cellpadding='1' cellspacing='0' width='100%'>"
	dat += "<tr align='center' bgcolor='[color]'><th colspan='[length(roles)]'><a href='byond://?src=\ref[src];[HrefToken(forceGlobal = TRUE)];JobBanRu3=[department]dept;ckey=[ckey]'>[department]</a></th></tr><tr align='center'>"
	for(var/jobPos in roles)
		if(!jobPos)
			continue
		var/datum/job/job = GLOB.RoleAuthority.roles_by_name[jobPos]
		if(!job)
			continue

		if(jobban_isbanned_ru(ckey, job.title, P))
			dat += "<td width='20%'><a href='byond://?src=\ref[src];[HrefToken(forceGlobal = TRUE)];JobBanRu3=[job.title];ckey=[ckey]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
			counter++
		else
			dat += "<td width='20%'><a href='byond://?src=\ref[src];[HrefToken(forceGlobal = TRUE)];JobBanRu3=[job.title];ckey=[ckey]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
			counter++

		if(counter >= 5) //So things dont get squiiiiished!
			dat += "</tr><tr>"
			counter = 0
	dat += "</tr></table>"
	return dat

/datum/admins/proc/ban_temp_ru(ckey)
	if(!check_rights(R_BAN))  return

	var/datum/view_record/players/player = locate() in DB_VIEW(/datum/view_record/players, DB_COMP("ckey", DB_EQUALS, ckey))
	if(!player)
		to_chat(usr, "Database lookup failed.No file was found.")
		return

	var/mins = tgui_input_number(usr,"How long (in minutes)? \n 180 = 3 hours \n 1440 = 1 day \n 4320 = 3 days \n 10080 = 7 days \n 43800 = 1 Month","Ban time", 1440, 262800, 1)
	if(!mins)
		return
	if(mins >= 525600) mins = 525599
	var/reason = input(usr,"Reason? \n\nPress 'OK' to finalize the ban.","reason","Griefer") as message|null
	if(!reason)
		return
	var/datum/entity/player/P = get_player_from_key(ckey)
	if(!P)
		return
	if(P.is_time_banned && alert(usr, "Ban already exists. Proceed?", "Confirmation", "Yes", "No") != "Yes")
		return
	P.add_timed_ban(reason, mins)

/datum/admins/proc/ban_perma_ru(ckey)
	if(!check_rights(R_BAN))  return

	var/datum/view_record/players/player = locate() in DB_VIEW(/datum/view_record/players, DB_COMP("ckey", DB_EQUALS, ckey))
	if(!player)
		to_chat(usr, "Database lookup failed.No file was found.")
		return

	var/reason = tgui_input_text(owner, "What message should be given to the permabanned user?", "Permanent Ban", encode = FALSE)
	if(!reason)
		return

	var/internal_reason = tgui_input_text(owner, "What's the reason for the ban? This is shown internally, and not displayed in public notes and ban messages. Include as much detail as necessary.", "Permanent Ban", multiline = TRUE, encode = FALSE)
	if(!internal_reason)
		return

	var/datum/entity/player/target_entity = get_player_from_key(ckey)

	if(!target_entity)
		return

	if(!target_entity.add_perma_ban(reason, internal_reason, owner.player_data))
		to_chat(owner, SPAN_ADMIN("The user is already permabanned! If necessary, you can remove the permaban, and place a new one."))

/datum/admins/proc/job_ban_ru_2(ban_job, key)
	if(!check_rights(R_BAN))  return

	var/datum/view_record/players/player = locate() in DB_VIEW(/datum/view_record/players, DB_COMP("ckey", DB_EQUALS, key))
	if(!player)
		to_chat(usr, "Database lookup failed. No file was found.")
		return
	var/datum/entity/player/P1 = get_player_from_key(key)
	var/ckey = P1.ckey

			/*
			if(M.client && M.client.admin_holder && (M.client.admin_holder.rights & R_BAN)) //they can ban too. So we can't ban them
				alert("You cannot perform this action. You must be of a higher administrative rank!")
				return
			*/

	if(!GLOB.RoleAuthority)
		to_chat(usr, "Role Authority has not been set up!")
		return

		//get jobs for department if specified, otherwise just returnt he one job in a list.
	var/list/joblist = list()
	switch(ban_job)
		if("CICdept")
			joblist += get_job_titles_from_list(GLOB.ROLES_COMMAND)
		if("Supportdept")
			joblist += get_job_titles_from_list(GLOB.ROLES_AUXIL_SUPPORT)
		if("Policedept")
			joblist += get_job_titles_from_list(GLOB.ROLES_POLICE)
		if("Engineeringdept")
			joblist += get_job_titles_from_list(GLOB.ROLES_ENGINEERING)
		if("Requisitiondept")
			joblist += get_job_titles_from_list(GLOB.ROLES_REQUISITION)
		if("Medicaldept")
			joblist += get_job_titles_from_list(GLOB.ROLES_MEDICAL)
		if("Marinesdept")
			joblist += get_job_titles_from_list(GLOB.ROLES_MARINES)
		if("Miscdept")
			joblist += get_job_titles_from_list(GLOB.ROLES_MISC)
		if("Xenosdept")
			joblist += get_job_titles_from_list(GLOB.ROLES_XENO)
		else
			joblist += ban_job

	var/list/notbannedlist = list()
	for(var/job in joblist)
		if(!jobban_isbanned_ru(ckey, job, P1))
			notbannedlist += job

		//Banning comes first
	if(length(notbannedlist))
		if(!check_rights(R_BAN))  return
		var/reason = input(usr,"Reason?","Please State Reason","") as text|null
		if(reason)
			P1.add_job_ban(reason, notbannedlist)

			//href_list["jobban2"] = 1 // lets it fall through and refresh
			return 1

		//Unbanning joblist
		//all jobs in joblist are banned already OR we didn't give a reason (implying they shouldn't be banned)
	if(length(joblist)) //at least 1 banned job exists in joblist so we have stuff to unban.
		for(var/job in joblist)
			var/reason = jobban_isbanned_ru(ckey, job, P1)
			if(!reason) continue //skip if it isn't jobbanned anyway
			switch(alert("Job: '[job]' Reason: '[reason]' Un-jobban?","Please Confirm","Yes","No"))
				if("Yes")
					P1.remove_job_ban(job)
				else
					continue
		//href_list["jobban2"] = 1 // lets it fall through and refresh

		return 1
	return 0 //we didn't do anything!

/datum/admins/proc/do_stickyban_search_ru(key)
	var/datum/view_record/players/player = locate() in DB_VIEW(/datum/view_record/players, DB_COMP("ckey", DB_EQUALS, key))
	if(!player)
		to_chat(usr, "Database lookup failed. No file was found.")
		return

	var/list/datum/view_record/stickyban/stickies = SSstickyban.check_for_sticky_ban(key)
	if(!stickies)
		to_chat(owner, SPAN_ADMIN("Could not locate any stickbans impacting [key]."))
		return

	var/list/impacting_stickies = list()

	for(var/datum/view_record/stickyban/sticky as anything in stickies)
		impacting_stickies += sticky.identifier

	to_chat(owner, SPAN_ADMIN("Found the following stickybans for [key]: [english_list(impacting_stickies)]"))

/datum/admins/proc/do_stickyban_ru(key, reason, message, list/impacted_ckeys, list/impacted_cids, list/impacted_ips)
	if(!check_rights(R_BAN))  return
	if(!key)
		return

	if(!message)
		message = tgui_input_text(usr, "What message should be given to the impacted users?", "BuildABan", encode = FALSE)
	if(!message)
		return

	if(!reason)
		reason = tgui_input_text(usr, "What's the reason for the ban? This is shown internally, and not displayed in public notes and ban messages. Include as much detail as necessary.", "BuildABan", multiline = TRUE, encode = FALSE)
	if(!reason)
		return

	if(!length(impacted_ckeys))
		impacted_ckeys = splittext(tgui_input_text(usr, "Which CKEYs should be impacted by this ban? Include the primary ckey, separated by semicolons.", "BuildABan", "player1;player2;player3"), ";")

	if(!length(impacted_cids))
		impacted_cids = splittext(tgui_input_text(usr, "Which CIDs should be impacted by this ban? Separate with semicolons.", "BuildABan", "12345678;87654321"), ";")

	if(!length(impacted_ips))
		impacted_ips = splittext(tgui_input_text(src, "Which IPs should be impacted by this ban? Separate with semicolons.", "BuildABan", "1.1.1.1;8.8.8.8"), ";")

	var/datum/entity/stickyban/new_sticky = SSstickyban.add_stickyban(key, reason, message, owner.player_data)

	if(!new_sticky)
		to_chat(src, SPAN_ADMIN("Failed to apply stickyban."))
		return

	for(var/ckey in impacted_ckeys)
		SSstickyban.add_matched_ckey(new_sticky.id, ckey)

	for(var/cid in impacted_cids)
		SSstickyban.add_matched_cid(new_sticky.id, cid)

	for(var/ip in impacted_ips)
		SSstickyban.add_matched_ip(new_sticky.id, ip)

	log_admin("STICKYBAN: Identifier: [key] Reason: [reason] Message: [message] CKEYs: [english_list(impacted_ckeys)] IPs: [english_list(impacted_ips)] CIDs: [english_list(impacted_cids)]")
	message_admins("[key_name_admin(src)] has added a new stickyban with the identifier '[key]'.")
	var/datum/tgs_chat_embed/field/reason_embed = new("Stickyban Reason", reason)
	important_message_external("[src] has added a new stickyban with the identifier '[key]'.", "Stickyban Placed", list(reason_embed))
