/obj/item/weapon/gun/smg/fp9000/pmc/stripped
	random_spawn_rail = list()
	random_spawn_under = list()
	random_spawn_muzzle = list()

/obj/item/weapon/gun/smg/p90/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 31, "muzzle_y" = 16,"rail_x" = 22, "rail_y" = 24, "under_x" = 23, "under_y" = 15, "stock_x" = 28, "stock_y" = 17)

/obj/item/weapon/gun/smg/p90/pmc
	name = "\improper FN P90/2 submachinegun"
	desc = "A variation of the FN P90 submachine gun with improved internal parts, as well as integrated mini-laser. Used by corporate PMCs or some corporate bodyguards. This weapon only accepts 5.7x28mm rounds."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/WY/smgs.dmi'
	icon_state = "p90_pmc"
	item_state = "p90_pmc"
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AUTO_EJECTOR|GUN_AMMO_COUNTER
	attachable_allowed = list(
		/obj/item/attachable/suppressor, // Barrel
		/obj/item/attachable/suppressor/sleek,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/extended_barrel/vented,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/compensator,
		/obj/item/attachable/reddot, // Rail
		/obj/item/attachable/reddot/small,
		/obj/item/attachable/reflex,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/lasersight,
		)
	starting_attachment_types = list(/obj/item/attachable/lasersight)

/obj/item/weapon/gun/smg/p90/pmc/set_gun_config_values()
	..()
	fire_delay = FIRE_DELAY_TIER_12
	burst_delay = FIRE_DELAY_TIER_12
	burst_amount = BURST_AMOUNT_TIER_3
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_5
	accuracy_mult_unwielded = BASE_ACCURACY_MULT
	scatter = SCATTER_AMOUNT_TIER_8
	burst_scatter_mult = SCATTER_AMOUNT_TIER_9
	scatter_unwielded = SCATTER_AMOUNT_TIER_6
	damage_mult = BASE_BULLET_DAMAGE_MULT + BULLET_DAMAGE_MULT_TIER_7
	recoil_unwielded = RECOIL_AMOUNT_TIER_5
	fa_max_scatter = SCATTER_AMOUNT_TIER_10

/obj/item/weapon/gun/smg/p90
	icon_state = "p90_ru"
	item_state = "p90_ru"

/obj/item/weapon/gun/smg/p90/twe
	icon_state = "p90_ru_twe"
	item_state = "p90_ru_twe"

/obj/item/weapon/gun/smg/p90/twe/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 42, "muzzle_y" = 16,"rail_x" = 22, "rail_y" = 24, "under_x" = 23, "under_y" = 15, "stock_x" = 28, "stock_y" = 17)
