
/datum/admins/proc/DB_ban_panel(key as text)

	if (!istype(src,/datum/admins))
		src = usr.client.admin_holder
	if (!istype(src,/datum/admins) || !(src.rights & R_MOD))
		to_chat(usr, "Error: you are not an admin!")
		return

	var/datum/entity/player/P = get_player_from_key(key)

	var/dat = {"<meta charset="UTF-8"><div align='center'><table width='90%'><tr>"}

	dat += "<div align='center'><width='90%'> <h1>Banning panel</h1></div><tr>"

	dat += "Checked key:[key]<br>"
	dat += "<A href='byond://?src=\ref[src];[HrefToken()];CheckPlaytimesRu=1;ckey=[P.ckey]'>Check Playtimes</A><br>"
	dat += "<A href='byond://?src=\ref[src];[HrefToken()];add_player_info=[P.ckey]'>Add Note</A><br>"
	dat += "<A href='byond://?src=\ref[src];[HrefToken()];add_player_info_confidential=[P.ckey]'>Add Confidential Note</A><br>"
	dat += "<A href='byond://?src=\ref[src];[HrefToken()];player_notes_all=[P.ckey]'>Show Complete Record</A><br>"
	dat += "<A href='byond://?src=\ref[src];[HrefToken()];check_ckey=[P.ckey];ckey=[P.ckey]'>Check Ckey</A><br>"
	dat += "<a href='byond://?src=\ref[src];[HrefToken()];sticky=1;new_sticky=1'>Add Sticky Ban</a>"
	dat += "<a href='byond://?src=\ref[src];[HrefToken()];sticky=1;find_sticky=1'>Find Sticky Ban</a><br>"
	dat += "<A href='byond://?src=\ref[src];[HrefToken()];BanRu=1;ckey=[P.ckey]'>Temporal Ban</A><br>"
	dat += "<A href='byond://?src=\ref[src];[HrefToken()];BanPermaRu=1;ckey=[P.ckey]'>Permanent Ban</A><br>"
	dat += "<A href='byond://?src=\ref[src];[HrefToken()];JobBanRu=1;ckey=[P.ckey]'>Job ban</A><br>"
	show_browser(usr, dat, "Ban Panel", "adminplayerinfo", "size=480x480")

/client/proc/DB_ban_panel()
	set category = "Admin.Panels"
	set name = "Banning Panel"
	set desc = "Data Ban Panel"

	if(admin_holder)
		var/ckey = input("Enter ACCURATE Ckey for future manipulations","Enter ACCURATE CKEY", null) as null|text
		var/datum/view_record/players/player = locate() in DB_VIEW(/datum/view_record/players, DB_COMP("ckey", DB_EQUALS, ckey))
		if(!player)
			to_chat(usr, "Database lookup failed.No file was found.")
			return
		if(ckey in GLOB.db_admin_datums)
			to_chat(usr, "Ckey belong to admin.Aborting search.")
			return
		admin_holder.DB_ban_panel(ckey)
	return

/datum/admins/proc/job_ban_ru(ckey)

	var/datum/entity/player/P = get_player_from_key(ckey)
	if(!GLOB.RoleAuthority)
		to_chat(usr, "The Role Authority is not set up!")
		return

	if(!P)
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
