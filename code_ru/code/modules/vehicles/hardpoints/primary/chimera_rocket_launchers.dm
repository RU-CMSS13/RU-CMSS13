/obj/item/hardpoint/primary/chimera_launchers/rocket
	name = "\improper AG-66/L Chimera Rocket Launcher System"
	desc = "The Chimera Rocket Launcher System, commonly referred two as just 'chimeras', is a variable payload dump-salvo type disposable munitions deployer, designed for short-range, quick-arming explosives to be fired in volleys from the quad-barrel launch tubes."

	icon = 'icons/obj/vehicles/hardpoints/blackfoot.dmi'
	icon_state = "rocket_launchers"
	disp_icon = "blackfoot"
	disp_icon_state = "rocket_launchers"

	activation_sounds = list('sound/vehicles/vtol/launcher.ogg')

	health = 500
	firing_arc = 180

	ammo = new /obj/item/ammo_magazine/hardpoint/chimera_launchers_ammo/rocket
	max_clips = 2

	gun_firemode = GUN_FIREMODE_SEMIAUTO
	gun_firemode_list = list(
		GUN_FIREMODE_SEMIAUTO,
	)
	fire_delay = 5 SECONDS

	allowed_seat = VEHICLE_DRIVER
