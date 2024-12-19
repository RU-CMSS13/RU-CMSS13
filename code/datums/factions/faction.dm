/datum/faction
	var/name = "Neutral Faction"
	var/faction_tag = FACTION_NEUTRAL
	var/hud_type = FACTION_HUD
	var/faction_victory_points = 0
	var/homes_sector_occupation = TRUE
	var/latejoin_enabled = TRUE

	var/datum/faction_task_ui/task_interface

	var/desc = "Neutral Faction"
	var/orders = "Остаться в живых"
	var/ui_color = "#22888a"

/datum/faction/New()
	task_interface = new(src)

/datum/faction/proc/modify_hud_holder(image/holder, mob/living/carbon/human/H)
	return

/datum/faction/proc/get_antag_guns_snowflake_equipment()
	return list()

/datum/faction/proc/get_antag_guns_sorted_equipment()
	return list()


//FACTION INFO PANEL
/datum/faction/ui_state(mob/user)
	return GLOB.not_incapacitated_state

/datum/faction/ui_status(mob/user, datum/ui_state/state)
	. = ..()
	if(isobserver(user))
		return UI_INTERACTIVE

/datum/faction/ui_data(mob/user)
	. = list()
	.["faction_orders"] = orders

/datum/faction/ui_static_data(mob/user)
	. = list()
	.["faction_color"] = ui_color
	.["faction_name"] = name
	.["faction_desc"] = desc
	.["actions"] = get_faction_actions()

/datum/faction/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FactionStatus", "[name] Статус")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/faction/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
//		if("relations")
//			relations_datum.tgui_interact(usr)
		if("tasks")
			task_interface.tgui_interact(usr)
		if("clues")
			if(!skillcheck(usr, SKILL_INTEL, SKILL_INTEL_TRAINED))
				to_chat(usr, SPAN_WARNING("You have no access to the [name] intel network."))
				return
//			objective_interface.tgui_interact(usr)
		if("researchs")
			if(!skillcheck(usr, SKILL_RESEARCH, SKILL_RESEARCH_TRAINED))
				to_chat(usr, SPAN_WARNING("You have no access to the [name] research network."))
				return
//			research_objective_interface.tgui_interact(usr)
		if("status")
			get_faction_info(usr)

/datum/faction/proc/get_faction_actions(mob/user)
	. = list()
	. += list(list("name" = "Faction Relations", "action" = "relations"))
	. += list(list("name" = "Faction Tasks", "action" = "tasks"))
	. += list(list("name" = "Faction Clues", "action" = "clues"))
	. += list(list("name" = "Faction Researchs", "action" = "researchs"))
	. += list(list("name" = "Faction Status", "action" = "status"))
	return .

/datum/faction/proc/get_faction_info(mob/user)
	var/dat = GLOB.data_core.get_manifest(FALSE, src)
	if(!dat)
		return FALSE
	show_browser(user, dat, "Список Экипажа [name]", "manifest", "size=450x750")
	return TRUE

/mob/living/carbon/verb/view_faction()
	set name = "View Your Faction"
	set category = "IC"

	if(!GLOB.faction_datums[faction])
		return

	GLOB.faction_datums[faction].tgui_interact(src)
