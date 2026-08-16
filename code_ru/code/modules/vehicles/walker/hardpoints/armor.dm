/obj/item/hardpoint/walker/armor
	name = "Armor Hardpoint"
	desc = "Primary armor source."

	icon = 'code_ru/icons/obj/vehicles/mech_armor.dmi'

	slot = WALKER_HARDPOIN_ARMOR
	hdpt_layer = HDPT_LAYER_ARMOR

	damage_multiplier = 0.85

	health = 500
	max_health = 500

	weight = 2.5

/obj/item/hardpoint/walker/armor/paladin
	name = "Paladin Armor"
	desc = "Protects the vehicle from large incoming explosive projectiles."

	icon_state = "paladin_armor"
	disp_icon_state = "paladin_armor"

	type_multipliers = list(
		"all" = 0.8,
		"explosive" = 0.6,
	)

/obj/item/hardpoint/walker/armor/concussive
	name = "Concussive Armor"
	desc = "Protects the vehicle from high-impact weapons."

	icon_state = "concussive_armor"
	disp_icon_state = "concussive_armor"

	type_multipliers = list(
		"all" = 0.8,
		"blunt" = 0.6,
	)

/obj/item/hardpoint/walker/armor/caustic
	name = "Caustic Armor"
	desc = "Protects vehicles from most types of acid."

	icon_state = "caustic_armor"
	disp_icon_state = "caustic_armor"

	type_multipliers = list(
		"all" = 0.8,
		"acid" = 0.6,
	)

/obj/item/hardpoint/walker/armor/fire
	name = "Fire Fighter Armor"
	desc = "Protects vehicles from fire."

	icon_state = "concussive_armor"
	disp_icon_state = "concussive_armor"

	type_multipliers = list(
		"all" = 0.8,
		"fire" = 0,
	)

/obj/item/hardpoint/walker/armor/ballistic
	name = "Ballistic Armor"
	desc = "Protects the vehicle from high-penetration weapons."

	icon_state = "ballistic_armor"
	disp_icon_state = "ballistic_armor"

	type_multipliers = list(
		"all" = 0.8,
		"bullet" = 0.6,
		"slash" = 0.6,
	)
