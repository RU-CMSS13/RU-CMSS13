/obj/item/hardpoint/primary/chimera_launchers/autocannon
	name = "\improper AC4-E Autocannon"
	desc = "A primary autocannon for VTOL that shoots explosive flak rounds."

	icon = 'icons/obj/vehicles/hardpoints/blackfoot.dmi'
	icon_state = "chimera-autocannon"
	disp_icon = "blackfoot"
	disp_icon_state = "chimera_autocannon"
	activation_sounds = list('sound/weapons/vehicles/autocannon_fire.ogg')

	health = 500
	firing_arc = 90
	allowed_seat = VEHICLE_DRIVER

	ammo = new /obj/item/ammo_magazine/hardpoint/chimera_launchers_ammo/autocannon
	max_clips = 2

	scatter = 1
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	gun_firemode_list = list(
		GUN_FIREMODE_AUTOMATIC,
	)
	fire_delay = 1 SECONDS
