//Case//

/obj/item/storage/secure/briefcase/corpsec
	name = "Corporate Security Equipment"
	desc = "Contains single set of a corporate security equipment."
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "corporates"
	item_state = "sec-case"
	max_storage_space = 4

/obj/item/storage/secure/briefcase/corpsec/fill_preset_inventory()
	new /obj/item/device/radio/headset/distress/WY(src)
	new /obj/item/clothing/under/marine/veteran/pmc/corporate(src)
	new /obj/item/inflatable/door(src)
	new /obj/item/clothing/suit/storage/marine/veteran/pmc/light/corporate(src)
	new /obj/item/clothing/gloves/marine/veteran(src)
	new /obj/item/clothing/head/helmet/marine/veteran/pmc/corporate(src)
	new /obj/item/clothing/shoes/marine/corporate(src)
	new /obj/item/storage/backpack/lightpack(src)
	new /obj/item/weapon/baton(src)
	new /obj/item/handcuffs/zip(src)
	new /obj/item/handcuffs/zip(src)
	new /obj/item/handcuffs/zip(src)
	new /obj/item/tool/crowbar(src)
	new /obj/item/storage/belt/gun/m4a3/mod88(src)
	new /obj/item/storage/pouch/firstaid/full(src)
	new /obj/item/weapon/gun/rifle/m41a/corporate(src)
	new /obj/item/storage/pouch/magazine/pulse_rifle(src)
	new /obj/item/ammo_magazine/rifle/ap(src)
	new /obj/item/ammo_magazine/rifle/ap(src)

//Button//
/*
/obj/structure/machinery/computer/corporate/button//TODO:SANITY
	name = "Employment Records"
	desc = "Used to view personnel's employment records"
	icon = 'icons/obj/structures/props/stationobjs.dmi'
	icon_state = "corporateb"
	req_one_access = list(ACCESS_MARINE_DATABASE)
	circuit = /obj/item/circuitboard/computer/skills
	var/obj/item/card/id/scan = null
	var/authenticated = null
	var/rank = null
	var/screen = null
	var/datum/data/record/active1 = null
	var/a_id = null
	var/temp = null
	var/printing = null
	var/can_change_id = 0
	var/list/Perp
	var/tempname = null
	//Sorting Variables
	var/sortBy = "name"
	var/order = 1 // -1 = Descending - 1 = Ascending

/obj/structure/machinery/computer/corporate/button/proc/request_cs(user)
	if(!user)
		return FALSE
	message_admins("[key_name(user)] запросил группу корпоративных охранников! (<A HREF='?_src_=admin_holder;[HrefToken(forceGlobal = TRUE)];cssend=\ref[user]'>SEND</A>) (<A HREF='?_src_=admin_holder;[HrefToken(forceGlobal = TRUE)];csdeny=\ref[user]'>DENY</A>)")
	return TRUE

/datum/admins/Topic(href, href_list)
	..()
	if(href_list["cddeny"]) // CentComm-deny. The distress call is denied, without any further conditions
		var/mob/ref_person = locate(href_list["ccdeny"])
		log_game("[key_name_admin(usr)] отклонил вызов корпоративной охраны, запрошенный [key_name_admin(ref_person)]")
		message_admins("[key_name_admin(usr)] отклонил вызов корпоративной охраны, запрошенный [key_name_admin(ref_person)]", 1)

	if(href_list["cssend"]) // CentComm-deny. The distress call is denied, without any further conditions
		message_admins("[key_name_admin(usr)] одобрил вызов корпоративной охраны! Высылаем через 10 секунд...")
		addtimer(CALLBACK(src, PROC_REF(accept_ert), usr, locate(href_list["distress"])), 10 SECONDS)
		marine_announcement("Вызов корпоративной охраны одобрен.", "Corporate Security beacon", logging = ARES_LOG_SECURITY)

/datum/admins/proc/accept_cs_ert(mob/approver, mob/ref_person)
	SSticker.mode.get_specific_call(goon, FALSE, TRUE, FALSE)
	log_game("[key_name_admin(approver)] has sent a PMC distress beacon, requested by [key_name_admin(ref_person)]")
	message_admins("[key_name_admin(approver)] has sent a PMC distress beacon, requested by [key_name_admin(ref_person)]")


/obj/structure/machinery/computer/computer/corporate/button/attack_hand
	. = ..()
	var/message = tgui_input_text(user, "Причина?", "Request Corporate Security", multiline = TRUE)
	if(!message)
		return
	// we know user is a human now, so adjust user for this check
	var/mob/living/carbon/human/humanoid = user

*/
