


/obj/item/attachable/upc
	name = "upgraded barrel charger"
	desc = "A hyper threaded barrel extender that fits to the muzzle of most firearms. Increases bullet speed and velocity.\nGreatly increases projectile damage at the cost of accuracy and firing speed."
	slot = "muzzle"
	icon = 'fray-marines/icons/obj/items/weapons/guns/attachments/barrel.dmi'
	icon_state = "upc"
	attach_icon = "upc_a"
	hud_offset_mod = -3

/obj/item/attachable/upc/New()
	..()
	accuracy_mod = -HIT_ACCURACY_MULT_TIER_3
	damage_mod = BULLET_DAMAGE_MULT_TIER_7
	delay_mod = FIRE_DELAY_TIER_LMG

	accuracy_unwielded_mod = -HIT_ACCURACY_MULT_TIER_7

/obj/item/attachable/upc/Attach(obj/item/weapon/gun/G)
	if(G.gun_category == GUN_CATEGORY_SHOTGUN)
		damage_mod = BULLET_DAMAGE_MULT_TIER_2
	else
		damage_mod = BULLET_DAMAGE_MULT_TIER_7
	..()
