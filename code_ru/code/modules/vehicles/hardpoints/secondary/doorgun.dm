/obj/item/hardpoint/secondary/doorgun/minigun
	name = "\improper Doorgun-Minigun"
	desc = ""

	icon = 'icons/obj/vehicles/hardpoints/blackfoot.dmi'
	icon_state = "doorgun-mini-module"

	activation_sounds = list('sound/weapons/gun_minigun.ogg')

	health = 500
	firing_arc = 180

	ammo = new /obj/item/ammo_magazine/hardpoint/doorgun_ammo/holotarget
	max_clips = 2

	gun_firemode = GUN_FIREMODE_AUTOMATIC
	gun_firemode_list = list(
		GUN_FIREMODE_AUTOMATIC,
	)
	fire_delay = 0.2 SECONDS // default is 0.6

	allowed_seat = VEHICLE_GUNNER

	origins = list(0, 2)

	interior_type = /datum/map_template/interior/blackfoot_doorgun_minigun
