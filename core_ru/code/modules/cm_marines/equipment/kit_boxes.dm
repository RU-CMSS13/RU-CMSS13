/obj/item/storage/box/spec/stormtrooper
	name = "\improper Stormtrooper equipment case"
	desc = "A large case containing your experimental M40 full armor, heavy hammer and montage shield."
	icon = 'core_ru/icons/obj/items/storage.dmi'
	icon_state = "kit_case"
	kit_overlay = "stormtrooper"
//stormtrooper
/obj/item/storage/box/spec/stormtrooper/fill_preset_inventory()
	new /obj/item/clothing/suit/storage/marine/m40(src)
	new /obj/item/clothing/head/helmet/marine/m40(src)
	new /obj/item/weapon/gun/shotgun/combat(src)
	new /obj/item/attachable/stock/tactical(src)
	new /obj/item/clothing/accessory/storage/holster(src)
	new /obj/item/weapon/gun/pistol/vp78(src)
	new /obj/item/ammo_magazine/pistol/vp78(src)
	new /obj/item/ammo_magazine/pistol/vp78(src)
	new /obj/item/weapon/twohanded/st_hammer(src)
	new /obj/item/weapon/shield/montage(src)
