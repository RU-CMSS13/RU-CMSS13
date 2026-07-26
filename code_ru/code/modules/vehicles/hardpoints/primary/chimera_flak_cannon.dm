/obj/item/hardpoint/primary/chimera_launchers/autocannon
	name = "\improper AC3-E Autocannon"
	desc = "A primary autocannon for VTOL that shoots explosive flak rounds."

	icon = 'icons/obj/vehicles/hardpoints/blackfoot.dmi'
	icon_state = "chimera_autocannon"
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
	fire_delay = 0.7 SECONDS

/obj/item/hardpoint/primary/chimera_launchers/autocannon/chimera/get_icon_image(x_offset, y_offset, new_dir)
	var/obj/vehicle/multitile/blackfoot/blackfoot_owner = owner

	if(!blackfoot_owner)
		return

	var/image/I = image(icon = disp_icon, icon_state = "[disp_icon_state]_[blackfoot_owner.get_sprite_state()]", pixel_x = x_offset, pixel_y = y_offset, dir = new_dir)

	return I


/obj/item/hardpoint/primary/chimera_launchers/autocannon/try_fire(atom/target, mob/living/user, params)
	if(safety)
		to_chat(user, SPAN_WARNING("Targeting mode is not enabled, unable to fire."))
		return

	if(ammo && ammo.current_rounds <= 0)
		reload(user)
		return

	return ..()

// Just removes the sleep because it sucks
/obj/item/hardpoint/primary/chimera_launchers/autocannon/chimera/reload(mob/user)
	if(!LAZYLEN(backup_clips))
		to_chat(usr, SPAN_WARNING("\The [name] has no remaining backup clips."))
		return

	var/obj/item/ammo_magazine/A = LAZYACCESS(backup_clips, 1)
	if(!A)
		to_chat(user, SPAN_DANGER("Something went wrong! Ahelp and ask for a developer! Code: HP_RLDHP_C"))
		return

	ammo.forceMove(get_turf(src))
	ammo.update_icon()
	ammo = A
	LAZYREMOVE(backup_clips, A)

	to_chat(user, SPAN_NOTICE("You reload \the [name]."))
