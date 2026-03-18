/obj/item/clothing/head/helmet/marine/m40
	name = "\improper M40 breacher helmet"
	desc = "A helmet designed for USCM breacher. Contains heavy insulation, covered in nomex weave."
	icon = 'code_ru/icons/mob/humans/onmob/head_1.dmi'
	icon_state = "st_h" //Назвал "st_h" чтобы было короче. Камуфляжы находится в папке icons/obj/items/clothing/hats/hats_by_map
	item_icons = list(
		WEAR_HEAD = 'code_ru/icons/mob/humans/onmob/head_1.dmi'
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
	flags_atom = NO_GAMEMODE_SKIN
	flags_item = MOB_LOCK_ON_EQUIP|NO_CRYO_STORE
