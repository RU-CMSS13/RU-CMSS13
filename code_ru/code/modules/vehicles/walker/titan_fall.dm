/obj/vehicle/walker
	var/obj/walker_shadow/shadow_holder

/obj/vehicle/walker/proc/update_shadow(obj/item/hardpoint/walker/spinal/jetpack/module)
	if(!module.flying)
		return

	var/turf/current = get_turf(src)
	if(!istype(current, /turf/open_space))
		shadow_holder.forceMove(current)
		return

	var/turf/below = SSmapping.get_turf_below(current)
	if(!below)
		return
	if(below.density)
		shadow_holder.forceMove(src)
		return

	var/turf/below_us = below
	while(below_us)
		below_us = SSmapping.get_turf_below(below)
		if(!below_us || below_us.density)
			break
		below = below_us
	shadow_holder.forceMove(below)


//////////////////////////////////////////////////////////////


/obj/vehicle/walker/proc/titan_raise(obj/item/hardpoint/walker/spinal/jetpack/module, turf/raise_target, raise_time)
	module.perform_action(raise_time)

	var/obj/landing_dust_effect/effect = new /obj/landing_dust_effect(get_turf(src))
	animate(shadow_holder, alpha = 0, time = raise_time, easing = LINEAR_EASING)
	layer = ABOVE_FLY_LAYER
	animate(src, pixel_y = 32 * 15, time = raise_time, easing = LINEAR_EASING)

	addtimer(CALLBACK(src, PROC_REF(reset_titan_raise), raise_target, effect), raise_time, TIMER_UNIQUE|TIMER_DELETE_ME)

/obj/vehicle/walker/proc/reset_titan_raise(turf/raise_target, obj/landing_dust_effect/effect)
	qdel(effect)
	shadow_holder.alpha = 255
	layer = initial(layer)
	pixel_y = get_pixels_y()
	forceMove(raise_target)


//////////////////////////////////////////////////////////////


// TITAN HAS FALLEN
/obj/vehicle/walker/proc/prepare_titan_fall(obj/docking_port/mobile/marine_dropship/our_dropship)
	var/mob/user = seats[VEHICLE_DRIVER]
	if(!user)
		return

	var/obj/item/hardpoint/walker/spinal/jetpack/module = hardpoints_by_slot[WALKER_HARDPOIN_SPINAL]
	if(!istype(module))
		return

	if(!module.flying)
		return

	var/atom/movable/screen/minimap/targeting = SSminimaps.fetch_minimap_object(GLOB.railgun_eye_location.z_pos, MINIMAP_FLAG_USCM, live = TRUE, popup = FALSE, drawing = FALSE, for_client = user.client)
	user.client.add_to_screen(targeting)
	// We should see ceiling always
	targeting.update_ceiling_overlay(user.client)
	var/list/polled_coords = targeting.get_coords_from_click(user)
	// It sleeps
	if(user?.client)
		user.client.remove_from_screen(targeting)
	if(!polled_coords)
		return

	var/turf/fall_target = locate(polled_coords[1], polled_coords[2], GLOB.railgun_eye_location.z_pos)
	var/area/targ_area = get_area(fall_target)
	if(!fall_target || fall_target.density || targ_area.ceiling > CEILING_GLASS || !our_dropship.in_flyby)
		to_chat(user, SPAN_WARNING("Seems there nowhere to fall."))
		return

	if(!module.use_fuel(module.fuel_max))
		to_chat(user, SPAN_WARNING("Not enough fuel."))
		return

	titan_fall(module, fall_target, 6 SECONDS)

/obj/vehicle/walker/proc/titan_fall(obj/item/hardpoint/walker/spinal/jetpack/module, turf/fall_target, fall_time)
	module.perform_action(fall_time)
	forceMove(fall_target)

	var/obj/landing_dust_effect/effect = new /obj/landing_dust_effect(get_turf(src))
	addtimer(CALLBACK(effect, GLOBAL_PROC_REF(qdel), effect), fall_time, TIMER_UNIQUE|TIMER_DELETE_ME)

	layer = ABOVE_FLY_LAYER
	pixel_y = 32 * 15
	addtimer(VARSET_CALLBACK(src, layer, initial(layer)), fall_time, TIMER_UNIQUE|TIMER_DELETE_ME)
	animate(src, pixel_y = get_pixels_y(), time = fall_time, easing = LINEAR_EASING)

	shadow_holder.alpha = 0
	shadow_holder.forceMove(fall_target)
	animate(shadow_holder, alpha = 255, time = fall_time, easing = LINEAR_EASING)

	FOR_DVIEW(var/mob/mob, 7, fall_target, HIDE_INVISIBLE_OBSERVER)
		shake_camera(mob, 4, 5)
	FOR_DVIEW_END


//////////////////////////////////////////////////////////////


/obj/vehicle/walker/proc/flight_start(obj/item/hardpoint/walker/spinal/jetpack/module, turf/raise_target, raise_time)
	module.perform_action(raise_time)
	var/turf/current = get_turf(src)

	var/obj/landing_dust_effect/effect = new /obj/landing_dust_effect(current)
	addtimer(CALLBACK(effect, GLOBAL_PROC_REF(qdel), effect), raise_time)
	shadow_holder.forceMove(current)

	animate(src, pixel_y = 32, time = raise_time, easing = LINEAR_EASING)
	addtimer(VARSET_CALLBACK(src, pixel_y, get_pixels_y()), raise_time, TIMER_UNIQUE|TIMER_DELETE_ME)

	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom/movable, forceMove), raise_target), raise_time, TIMER_UNIQUE|TIMER_DELETE_ME)


/obj/vehicle/walker/proc/flight_end(obj/item/hardpoint/walker/spinal/jetpack/module, turf/fall_target, fall_time)
	module.perform_action(fall_time)
	forceMove(fall_target)

	pixel_y = 32
	animate(src, pixel_y = 0, time = fall_time, easing = LINEAR_EASING)
	addtimer(VARSET_CALLBACK(src, pixel_y, get_pixels_y()), fall_time, TIMER_UNIQUE|TIMER_DELETE_ME)

	FOR_DVIEW(var/mob/mob, 7, fall_target, HIDE_INVISIBLE_OBSERVER)
		shake_camera(mob, 4, 5)
	FOR_DVIEW_END


//////////////////////////////////////////////////////////////


/obj/walker_shadow
	icon = 'code_ru/icons/obj/vehicles/mech_effects.dmi'
	icon_state = "mech_shadow"
	pixel_x = -17
	pixel_y = 0
	layer = ABOVE_MOB_LAYER
	flags_atom = NO_ZFALL
	anchored = TRUE

/obj/landing_dust_effect
	icon = 'code_ru/icons/obj/vehicles/mech_big_effects.dmi'
	icon_state = "landing_dust"
	pixel_x = -64
	pixel_y = -32
	anchored = TRUE
