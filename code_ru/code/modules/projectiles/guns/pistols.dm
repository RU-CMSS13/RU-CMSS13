/obj/item/weapon/gun/pistol/vp78m6
	name = "\improper VP78M6 pistol"
	desc = "The VP78M6, often called the 'Mod Six', are enhanced variant of the VP78 combat pistol. Smoother trigger, formed grip, longer shrouded barrel. This M6 have been modified to have special counterweight in the receiver and under the barrel to resist muzzle climb, allowing for much better handling. Heavy and powerful."
	icon = 'code_ru/icons/obj/items/weapons/guns/guns_by_faction/uscm.dmi'
	icon_state = "vp78m6"
	item_state = "vp78m6"
	gun_slot_icon = 'code_ru/icons/obj/items/clothing/belts/holstered_guns.dmi'
	lineart_ru = TRUE
	item_icons = list(
	WEAR_WAIST = 'code_ru/icons/obj/items/clothing/belts.dmi',
	WEAR_J_STORE = 'code_ru/icons/obj/items/weapons/guns/guns_by_map/urban/suit_slot.dmi',
	WEAR_L_HAND = 'code_ru/icons/mob/humans/onmob/items_lefthand_1.dmi',
	WEAR_R_HAND = 'code_ru/icons/mob/humans/onmob/items_righthand_1.dmi'
	)
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_ONE_HAND_WIELDED|GUN_AMMO_COUNTER
	fire_sound = 'sound/weapons/gun_vp78m6_fire.ogg' // yes we are normalized bro -8db :D
	reload_sound = 'sound/weapons/gun_vp78_reload.ogg'
	unload_sound = 'sound/weapons/gun_vp78_unload.ogg'
	current_mag = /obj/item/ammo_magazine/pistol/vp78
	force = 8

/obj/item/weapon/gun/pistol/vp78m6/Initialize()
	. = ..()
	AddElement(/datum/element/corp_label/wy)

	attachable_allowed = list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/suppressor/sleek,
		/obj/item/attachable/reddot,
		/obj/item/attachable/reddot/small,
		/obj/item/attachable/reflex,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/lasersight/vp,
		/obj/item/attachable/compensator,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
	)

/obj/item/weapon/gun/pistol/vp78m6/handle_starting_attachment()
	..()
	var/obj/item/attachable/lasersight/vp/attachment = new(src)
	attachment.flags_attach_features &= ~ATTACH_REMOVABLE
	attachment.hidden = FALSE
	attachment.Attach(src)
	update_attachable(attachment.slot)

/obj/item/weapon/gun/pistol/vp78m6/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 29, "muzzle_y" = 20,"rail_x" = 10, "rail_y" = 23, "under_x" = 21, "under_y" = 13, "stock_x" = 18, "stock_y" = 14)

/obj/item/weapon/gun/pistol/vp78m6/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_8)
	set_burst_amount(BURST_AMOUNT_TIER_3)
	set_burst_delay(FIRE_DELAY_TIER_11)
	accuracy_mult = BASE_ACCURACY_MULT
	accuracy_mult_unwielded = BASE_ACCURACY_MULT
	scatter = SCATTER_AMOUNT_TIER_7
	burst_scatter_mult = SCATTER_AMOUNT_TIER_7
	scatter_unwielded = SCATTER_AMOUNT_TIER_7
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil = RECOIL_AMOUNT_TIER_5
	recoil_unwielded = RECOIL_AMOUNT_TIER_5
