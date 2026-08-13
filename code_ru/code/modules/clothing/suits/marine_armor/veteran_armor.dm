/obj/item/clothing/suit/storage/marine/medium/leader/mod_a
	name = "\improper modified M3 pattern marine armor 'A'"
	desc = "A heavily altered suit of lightweight M3 pattern marine armor. The joints have been cut away to enhance mobility while additional pads have been fastened around the shoulders. It is incredibly beat-down."
	icon = 'code_ru/icons/obj/items/clothing/suits/suits_by_map/jungle.dmi'
	item_icons = list(
	WEAR_JACKET = 'code_ru/icons/mob/humans/onmob/clothing/suits/suits_by_map/jungle.dmi'
	)
	icon_state = "MA"
	flags_atom = FPRINT|CONDUCT
	flags_inventory = BLOCKSHARPOBJ
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS
	flags_cold_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS
	flags_heat_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS
	flags_bodypart_hidden = BODY_FLAG_CHEST
	min_cold_protection_temperature = HELMET_MIN_COLD_PROT
	max_heat_protection_temperature = HELMET_MAX_HEAT_PROT
	blood_overlay_type = "armor"
	armor_melee = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bullet = CLOTHING_ARMOR_MEDIUMHIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMLOW
	armor_energy = CLOTHING_ARMOR_MEDIUM
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_MEDIUMHIGH
	armor_rad = CLOTHING_ARMOR_MEDIUMHIGH
	armor_internaldamage = CLOTHING_ARMOR_MEDIUM
	specialty = "M3 pattern mod-'A' marine"
	lamp_icon = "lampr"

/obj/item/clothing/suit/storage/marine/medium/leader/mod_a/select_gamemode_skin(expected_type, list/override_icon_state, list/override_protection)
	. = ..()
	switch(SSmapping.configs[GROUND_MAP].camouflage_type)
		if("jungle")
			icon = 'code_ru/icons/obj/items/clothing/suits/suits_by_map/jungle.dmi'
			item_icons[WEAR_JACKET] = 'code_ru/icons/mob/humans/onmob/clothing/suits/suits_by_map/jungle.dmi'
		if("classic")
			icon = 'code_ru/icons/obj/items/clothing/suits/suits_by_map/classic.dmi'
			item_icons[WEAR_JACKET] = 'code_ru/icons/mob/humans/onmob/clothing/suits/suits_by_map/classic.dmi'
		if("desert")
			icon = 'code_ru/icons/obj/items/clothing/suits/suits_by_map/desert.dmi'
			item_icons[WEAR_JACKET] = 'code_ru/icons/mob/humans/onmob/clothing/suits/suits_by_map/desert.dmi'
		if("snow")
			icon = 'code_ru/icons/obj/items/clothing/suits/suits_by_map/snow.dmi'
			item_icons[WEAR_JACKET] = 'code_ru/icons/mob/humans/onmob/clothing/suits/suits_by_map/snow.dmi'
		if("urban")
			icon = 'code_ru/icons/obj/items/clothing/suits/suits_by_map/urban.dmi'
			item_icons[WEAR_JACKET] = 'code_ru/icons/mob/humans/onmob/clothing/suits/suits_by_map/urban.dmi'

/obj/item/clothing/suit/storage/marine/medium/leader/mod_b
	name = "\improper modified M3 pattern marine armor 'B'"
	desc = "A heavily altered suit of lightweight M3 pattern marine armor. The joints have been cut away to enhance mobility while additional pads have been fastened around the shoulders. It is incredibly beat-down."
	icon = 'code_ru/icons/obj/items/clothing/suits/suits_by_map/jungle.dmi'
	item_icons = list(
	WEAR_JACKET = 'code_ru/icons/mob/humans/onmob/clothing/suits/suits_by_map/jungle.dmi'
	)
	icon_state = "MB"
	flags_atom = FPRINT|CONDUCT
	flags_inventory = BLOCKSHARPOBJ
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS
	flags_cold_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS
	flags_heat_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS
	flags_bodypart_hidden = BODY_FLAG_CHEST
	min_cold_protection_temperature = HELMET_MIN_COLD_PROT
	max_heat_protection_temperature = HELMET_MAX_HEAT_PROT
	blood_overlay_type = "armor"
	armor_melee = CLOTHING_ARMOR_MEDIUM
	armor_bullet = CLOTHING_ARMOR_MEDIUMHIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMLOW
	armor_energy = CLOTHING_ARMOR_LOW
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_MEDIUMHIGH
	armor_rad = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_MEDIUM
	storage_slots = 4
	specialty = "M3 pattern mod-'B' marine"
	lamp_icon = "lampr"

/obj/item/clothing/suit/storage/marine/medium/leader/mod_b/select_gamemode_skin(expected_type, list/override_icon_state, list/override_protection)
	. = ..()
	switch(SSmapping.configs[GROUND_MAP].camouflage_type)
		if("jungle")
			icon = 'code_ru/icons/obj/items/clothing/suits/suits_by_map/jungle.dmi'
			item_icons[WEAR_JACKET] = 'code_ru/icons/mob/humans/onmob/clothing/suits/suits_by_map/jungle.dmi'
		if("classic")
			icon = 'code_ru/icons/obj/items/clothing/suits/suits_by_map/classic.dmi'
			item_icons[WEAR_JACKET] = 'code_ru/icons/mob/humans/onmob/clothing/suits/suits_by_map/classic.dmi'
		if("desert")
			icon = 'code_ru/icons/obj/items/clothing/suits/suits_by_map/desert.dmi'
			item_icons[WEAR_JACKET] = 'code_ru/icons/mob/humans/onmob/clothing/suits/suits_by_map/desert.dmi'
		if("snow")
			icon = 'code_ru/icons/obj/items/clothing/suits/suits_by_map/snow.dmi'
			item_icons[WEAR_JACKET] = 'code_ru/icons/mob/humans/onmob/clothing/suits/suits_by_map/snow.dmi'
		if("urban")
			icon = 'code_ru/icons/obj/items/clothing/suits/suits_by_map/urban.dmi'
			item_icons[WEAR_JACKET] = 'code_ru/icons/mob/humans/onmob/clothing/suits/suits_by_map/urban.dmi'

/obj/item/clothing/suit/storage/marine/medium/leader/mod_c
	name = "\improper modified M3 pattern marine armor 'C'"
	desc = "A heavily altered suit of lightweight M3 pattern marine armor. The joints have been cut away to enhance mobility while additional pads have been fastened around the shoulders. It is incredibly beat-down."
	icon = 'code_ru/icons/obj/items/clothing/suits/suits_by_map/jungle.dmi'
	item_icons = list(
	WEAR_JACKET = 'code_ru/icons/mob/humans/onmob/clothing/suits/suits_by_map/jungle.dmi'
	)
	icon_state = "MC"
	flags_atom = FPRINT|CONDUCT
	flags_inventory = BLOCKSHARPOBJ
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS
	flags_cold_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS
	flags_heat_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS
	flags_bodypart_hidden = BODY_FLAG_CHEST
	min_cold_protection_temperature = HELMET_MIN_COLD_PROT
	max_heat_protection_temperature = HELMET_MAX_HEAT_PROT
	blood_overlay_type = "armor"
	slowdown = SLOWDOWN_ARMOR_LIGHT
	armor_melee = CLOTHING_ARMOR_MEDIUMLOW
	armor_bullet = CLOTHING_ARMOR_MEDIUM
	armor_bomb = CLOTHING_ARMOR_MEDIUMLOW
	armor_bio = CLOTHING_ARMOR_MEDIUMLOW
	armor_rad = CLOTHING_ARMOR_MEDIUMHIGH
	armor_internaldamage = CLOTHING_ARMOR_LOW
	storage_slots = 2
	specialty = "M3 pattern mod-'C' marine"
	lamp_icon = "lampr"

/obj/item/clothing/suit/storage/marine/medium/leader/mod_c/select_gamemode_skin(expected_type, list/override_icon_state, list/override_protection)
	. = ..()
	switch(SSmapping.configs[GROUND_MAP].camouflage_type)
		if("jungle")
			icon = 'code_ru/icons/obj/items/clothing/suits/suits_by_map/jungle.dmi'
			item_icons[WEAR_JACKET] = 'code_ru/icons/mob/humans/onmob/clothing/suits/suits_by_map/jungle.dmi'
		if("classic")
			icon = 'code_ru/icons/obj/items/clothing/suits/suits_by_map/classic.dmi'
			item_icons[WEAR_JACKET] = 'code_ru/icons/mob/humans/onmob/clothing/suits/suits_by_map/classic.dmi'
		if("desert")
			icon = 'code_ru/icons/obj/items/clothing/suits/suits_by_map/desert.dmi'
			item_icons[WEAR_JACKET] = 'code_ru/icons/mob/humans/onmob/clothing/suits/suits_by_map/desert.dmi'
		if("snow")
			icon = 'code_ru/icons/obj/items/clothing/suits/suits_by_map/snow.dmi'
			item_icons[WEAR_JACKET] = 'code_ru/icons/mob/humans/onmob/clothing/suits/suits_by_map/snow.dmi'
		if("urban")
			icon = 'code_ru/icons/obj/items/clothing/suits/suits_by_map/urban.dmi'
			item_icons[WEAR_JACKET] = 'code_ru/icons/mob/humans/onmob/clothing/suits/suits_by_map/urban.dmi'
