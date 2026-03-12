//README: Be aware, what add_verb from vehicle makes src be client, so ensure src is mech and user is mech-operator,if you're making new verbs

/obj/vehicle/walker/proc/exit_walker()
	set name = "Eject"
	set category = "Vehicle"

	var/mob/user = usr
	if(!istype(user))
		return

	src = user.interactee
	if(!istype(src, /obj/vehicle/walker))
		return

	if(seats[VEHICLE_DRIVER] != usr)
		return

	user.unset_interaction()


/obj/vehicle/walker/proc/toggle_lights()
	set name = "Lights on/off"
	set category = "Vehicle"

	if(!istype(src, /obj/vehicle/walker))
		src = usr.interactee

	var/mob/user = usr
	if(!mech_link_check(src, user))
		log_debug("Wrong Mech Parameters detected, user[user] or src[src]")
		return FALSE

	if(lights)
		lights = FALSE
		set_light(-lights_power)
	else
		lights = TRUE
		set_light(lights_power)

	playsound(src, 'sound/machines/click.ogg', 50)
	return TRUE


/obj/vehicle/walker/proc/eject_magazine()
	set name = "Eject Magazine"
	set category = "Vehicle"

	if(!istype(src, /obj/vehicle/walker))
		src = usr.interactee

	var/mob/user = usr
	if(!mech_link_check(src, user))
		log_debug("Wrong Mech Parameters detected, user[user] or src[src]")
		return FALSE

	var/list/acceptible_modules = list()
	if(module_map[WALKER_HARDPOIN_LEFT_HAND]?.ammo)
		acceptible_modules += module_map[WALKER_HARDPOIN_LEFT_HAND]
	if(module_map[WALKER_HARDPOIN_RIGHT_HAND]?.ammo)
		acceptible_modules += module_map[WALKER_HARDPOIN_RIGHT_HAND]

	if(!length(acceptible_modules))
		to_chat(user, "Not found magazines to eject")
		return FALSE

	var/obj/item/walker_gun/hardpoint = tgui_input_list(usr, "Select a hardpoint to eject magazine.", "Eject Magazine", acceptible_modules)
	if(!hardpoint || !hardpoint.ammo)
		return FALSE

	hardpoint.ammo.forceMove(get_turf(src))
	hardpoint.ammo = null
	to_chat(user, SPAN_WARNING("WARNING! [hardpoint.name] ammo magazine deployed."))
	visible_message("[name]'s systems ejected used magazine.","")
	return TRUE


/obj/vehicle/walker/proc/get_stats()
	set name = "Status Display"
	set category = "Vehicle"

	if(!istype(src, /obj/vehicle/walker))
		src = usr.interactee

	var/mob/user = usr
	if(!mech_link_check(src, user))
		log_debug("Wrong Mech Parameters detected, user[user] or src[src]")
		return FALSE

	tgui_interact(user)
	return TRUE

/obj/vehicle/walker/proc/toggle_zoom()
	set name = "Zoom on/off"
	set category = "Vehicle"

	if(!istype(src, /obj/vehicle/walker))
		src = usr.interactee

	var/mob/user = usr
	if(!mech_link_check(src, user))
		log_debug("Wrong Mech Parameters detected, user[user] or src[src]")
		return FALSE

	if(zoom)
		unzoom()
	else
		do_zoom()
	return TRUE
