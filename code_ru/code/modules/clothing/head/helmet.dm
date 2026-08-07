/obj/item/clothing/head/helmet/marine/m40
	name = "\improper M40 breacher helmet"
	desc = "A helmet designed for USCM breacher. Contains heavy insulation, covered in nomex weave."
	icon = 'code_ru/icons/obj/items/clothing/hats/hats_by_map/jungle.dmi'
	icon_state = "breach_helmet"
	item_icons = list(
		WEAR_HEAD = 'code_ru/icons/mob/humans/onmob/clothing/head/hats_by_map/jungle.dmi'
	)
	armor_melee = CLOTHING_ARMOR_HIGH
	armor_bullet = CLOTHING_ARMOR_MEDIUM
	armor_laser = CLOTHING_ARMOR_MEDIUMLOW
	armor_energy = CLOTHING_ARMOR_LOW
	armor_bio = CLOTHING_ARMOR_MEDIUM
	armor_rad = CLOTHING_ARMOR_MEDIUMLOW
	light_system = DIRECTIONAL_LIGHT
	health = 5
	force = 15
	throwforce = 15
	attack_verb = list("whacked", "hit", "smacked", "beaten", "battered")
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROT
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROT
	unacidable = TRUE
	anti_hug = 6
	specialty = "M40 breacher"
	flags_item = MOB_LOCK_ON_EQUIP|NO_CRYO_STORE

/obj/item/clothing/head/helmet/marine/m40/select_gamemode_skin(expected_type, list/override_icon_state, list/override_protection)
	. = ..()
	switch(SSmapping.configs[GROUND_MAP].camouflage_type)
		if("jungle")
			icon = 'code_ru/icons/obj/items/clothing/hats/hats_by_map/jungle.dmi'
			item_icons[WEAR_HEAD] = 'code_ru/icons/mob/humans/onmob/clothing/head/hats_by_map/jungle.dmi'
		if("classic")
			icon = 'code_ru/icons/obj/items/clothing/hats/hats_by_map/classic.dmi'
			item_icons[WEAR_HEAD] = 'code_ru/icons/mob/humans/onmob/clothing/head/hats_by_map/classic.dmi'
		if("desert")
			icon = 'code_ru/icons/obj/items/clothing/hats/hats_by_map/desert.dmi'
			item_icons[WEAR_HEAD] = 'code_ru/icons/mob/humans/onmob/clothing/head/hats_by_map/desert.dmi'
		if("snow")
			icon = 'code_ru/icons/obj/items/clothing/hats/hats_by_map/snow.dmi'
			item_icons[WEAR_HEAD] = 'code_ru/icons/mob/humans/onmob/clothing/head/hats_by_map/snow.dmi'
		if("urban")
			icon = 'code_ru/icons/obj/items/clothing/hats/hats_by_map/urban.dmi'
			item_icons[WEAR_HEAD] = 'code_ru/icons/mob/humans/onmob/clothing/head/hats_by_map/urban.dmi'

/obj/item/clothing/head/helmet/marine/radio_helmet/vsl
	name = "\improper M11-R pattern helmet"
	desc = "A variant of the M11 pattern, the 'R' platform features new external-style comms module with integrated medical hud and leather banding. This module allow you to use radio and keep yourself informed about your marines health."
	icon = 'code_ru/icons/obj/items/clothing/hats/hats_by_map/jungle.dmi'
	icon_state = "vsl_helmet"
	item_icons = list(
		WEAR_HEAD = 'code_ru/icons/mob/humans/onmob/clothing/head/hats_by_map/jungle.dmi'
	)
	armor_bio = CLOTHING_ARMOR_MEDIUMHIGH
	armor_melee = CLOTHING_ARMOR_MEDIUM
	armor_bullet = CLOTHING_ARMOR_MEDIUMHIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMLOW
	armor_energy = CLOTHING_ARMOR_LOW
	armor_bomb = CLOTHING_ARMOR_LOW
	armor_bio = CLOTHING_ARMOR_MEDIUMHIGH
	armor_rad = CLOTHING_ARMOR_LOW
	armor_internaldamage = CLOTHING_ARMOR_MEDIUM
	light_system = DIRECTIONAL_LIGHT
	health = 5
	force = 15
	throwforce = 15
	attack_verb = list("whacked", "hit", "smacked", "beaten", "battered")
	built_in_visors = list(new /obj/item/device/helmet_visor, new /obj/item/device/helmet_visor/medical)
	start_down_visor_type = /obj/item/device/helmet_visor/medical

	phone_category = PHONE_MARINE

/obj/item/clothing/head/helmet/marine/radio_helmet/vsl/select_gamemode_skin(expected_type, list/override_icon_state, list/override_protection)
	. = ..()
	switch(SSmapping.configs[GROUND_MAP].camouflage_type)
		if("jungle")
			icon = 'code_ru/icons/obj/items/clothing/hats/hats_by_map/jungle.dmi'
			item_icons[WEAR_HEAD] = 'code_ru/icons/mob/humans/onmob/clothing/head/hats_by_map/jungle.dmi'
		if("classic")
			icon = 'code_ru/icons/obj/items/clothing/hats/hats_by_map/classic.dmi'
			item_icons[WEAR_HEAD] = 'code_ru/icons/mob/humans/onmob/clothing/head/hats_by_map/classic.dmi'
		if("desert")
			icon = 'code_ru/icons/obj/items/clothing/hats/hats_by_map/desert.dmi'
			item_icons[WEAR_HEAD] = 'code_ru/icons/mob/humans/onmob/clothing/head/hats_by_map/desert.dmi'
		if("snow")
			icon = 'code_ru/icons/obj/items/clothing/hats/hats_by_map/snow.dmi'
			item_icons[WEAR_HEAD] = 'code_ru/icons/mob/humans/onmob/clothing/head/hats_by_map/snow.dmi'
		if("urban")
			icon = 'code_ru/icons/obj/items/clothing/hats/hats_by_map/urban.dmi'
			item_icons[WEAR_HEAD] = 'code_ru/icons/mob/humans/onmob/clothing/head/hats_by_map/urban.dmi'
