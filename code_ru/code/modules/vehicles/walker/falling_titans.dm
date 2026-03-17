/obj/vehicle/walker
	var/obj/walker_shadow/shadow_holder

//TITAN HAS FALLEN
/obj/vehicle/walker/proc/prepare_titan_fall()
	var/mob/user = seats[VEHICLE_DRIVER]
	if(!user)
		return

	var/obj/item/hardpoint/walker/spinal/jetpack/module = hardpoints_by_slot[WALKER_HARDPOIN_SPINAL]
	if(!istype(module))
		return

	//Selecting the fucking real cord of map, WIP. Supposed to be via MAP overlay.
	var/x_coord = tgui_input_real_number(user, "Input real longitude", "Longitude")
	var/y_coord = tgui_input_real_number(user, "Input real latitude", "Latitude")
	if(!x_coord || !y_coord)
		return

	var/turf/fall_target = locate(x_coord, y_coord, GLOB.railgun_eye_location.z_pos)
	if(!fall_target || fall_target.density)
		to_chat(user, SPAN_WARNING("Seems there nowhere to fall."))
		return

	if(!module.use_fuel(module.fuel_max))
		to_chat(user, SPAN_WARNING("Not enough fuel."))
		return

	titan_fall(module, fall_target, 6 SECONDS)

/obj/vehicle/walker/proc/titan_fall(obj/item/hardpoint/walker/spinal/jetpack/module, turf/fall_target, fall_time)
	module.perform_action(fall_time)

	pixel_y = 32 * 15
	forceMove(fall_target)
	shadow_holder.pixel_y = initial(shadow_holder.pixel_y) * 14
	shadow_holder.forceMove(fall_target)

	var/obj/landing_dust_effect/effect = new /obj/landing_dust_effect(get_turf(src))
	addtimer(CALLBACK(effect, GLOBAL_PROC_REF(qdel), effect), fall_time)

	//Effect of sprite coming down
	layer = ABOVE_FLY_LAYER
	addtimer(VARSET_CALLBACK(src, layer, initial(layer)), fall_time)
	animate(src, pixel_y = 0, time = fall_time, easing = LINEAR_EASING)
	animate(shadow_holder, pixel_y = initial(shadow_holder.pixel_y), time = fall_time, easing = LINEAR_EASING)

	FOR_DVIEW(var/mob/mob, 7, fall_target, HIDE_INVISIBLE_OBSERVER)
		shake_camera(mob, 4, 5)
	FOR_DVIEW_END


//////////////////////////////////////////////////////////////


/obj/vehicle/walker/proc/titan_raise(obj/item/hardpoint/walker/spinal/jetpack/module, turf/raise_target, raise_time)
	module.perform_action(raise_time)

	var/obj/landing_dust_effect/effect = new /obj/landing_dust_effect(get_turf(src))
	addtimer(CALLBACK(effect, GLOBAL_PROC_REF(qdel), effect), raise_time)

	//Effect of sprite flying up
	layer = ABOVE_FLY_LAYER
	addtimer(VARSET_CALLBACK(src, layer, initial(layer)), raise_time)
	animate(src, pixel_y = 32 * 15, time = raise_time, easing = LINEAR_EASING)
	animate(shadow_holder, pixel_y = initial(shadow_holder.pixel_y) * 14, time = raise_time, easing = LINEAR_EASING)

	addtimer(VARSET_CALLBACK(src, pixel_y, 0), raise_time, TIMER_UNIQUE|TIMER_DELETE_ME)
	addtimer(VARSET_CALLBACK(shadow_holder, pixel_y, 0), raise_time, TIMER_UNIQUE|TIMER_DELETE_ME)


//////////////////////////////////////////////////////////////


/obj/vehicle/walker/proc/update_shadow(obj/item/hardpoint/walker/spinal/jetpack/module)
	if(!module.flying)
		return

	var/turf/below = SSmapping.get_turf_below(get_turf(src))
	if(!below)
		if(shadow_holder.loc != src && !module.performing_action)
			module.perform_action(3 SECONDS)
			animate(shadow_holder, pixel_y = 0, time = 2 SECONDS, easing = LINEAR_EASING)
			addtimer(CALLBACK(shadow_holder, TYPE_PROC_REF(/atom/movable, forceMove), src), 2 SECONDS, TIMER_UNIQUE|TIMER_DELETE_ME)
		return
	if(below.density)
		return

	var/heigh = 1
	var/turf/below_us = below
	while(below_us)
		below_us = SSmapping.get_turf_below(below)
		if(!below_us || below_us.density)
			break
		below = below_us
		heigh++
	shadow_holder.forceMove(below)
	animate(shadow_holder, pixel_y = heigh * initial(shadow_holder.pixel_y), time = 2 SECONDS, easing = LINEAR_EASING)


//////////////////////////////////////////////////////////////


/obj/walker_shadow
	icon = 'code_ru/icons/obj/vehicles/mech_effects.dmi'
	icon_state = "mech_shadow"
	pixel_x = -17
	pixel_y = -32
	layer = ABOVE_MOB_LAYER
	flags_atom = NO_ZFALL
	anchored = TRUE

/obj/landing_dust_effect
	icon = 'code_ru/icons/obj/vehicles/mech_big_effects.dmi'
	icon_state = "landing_dust"
	pixel_x = -64
	pixel_y = -32
	anchored = TRUE
