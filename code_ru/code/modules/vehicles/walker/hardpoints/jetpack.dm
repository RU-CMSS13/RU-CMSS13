/obj/item/hardpoint/walker/spinal/jetpack
	name = "\"B-2 Spirit\" Jetpack"
	desc = "Special \"B-2 Spirit\" modification, spread democracy where nobody can reach! Jump in and even faster move out of combat zone after delivering payload."

	verbs_list = list(/obj/item/hardpoint/walker/spinal/jetpack/proc/jetpack, /obj/item/hardpoint/walker/spinal/jetpack/proc/jetpack_evac, /obj/vehicle/walker/proc/z_up, /obj/vehicle/walker/proc/z_down)
	actions_list = list(/datum/action/walker/jetpack, /datum/action/walker/jetpack_evac)

	move_delay = 4
	move_max_momentum = 8
	move_turn_momentum_loss_factor = 1
	move_momentum_build_factor = 1

	var/fuel = 200
	var/fuel_max = 200
	var/fuel_recover_rate = 2

	var/flying = FALSE
	var/fuel_consumption_rate = 6

	var/list/move_sounds = null
	var/list/turn_sounds = null
	var/list/cache_move_sounds = null
	var/list/cache_turn_sounds = null

	var/performing_action = FALSE

/obj/item/hardpoint/walker/spinal/jetpack/deactivate(obj/vehicle/walker/vessel)
	. = ..()

	stop_flying(vessel)

/obj/item/hardpoint/walker/spinal/jetpack/tgui_additional_data()
	. = ..()

	var/list/data = list()
	.["hardpoint_data_additional"] += list(data)
	data["value_name"] = "Fuel"
	data["current_value"] = fuel
	data["max_value"] = fuel_max

/obj/item/hardpoint/walker/spinal/jetpack/on_source_process(delta_time)
	. = ..()
	if(!.)
		return

	var/obj/vehicle/walker/vessel = owner
	var/turf/under = get_turf(vessel)
	if(flying)
		if(!istype(under, /turf/open_space))
			return
		if(!use_fuel(fuel_consumption_rate * delta_time))
			flying = FALSE
			stop_flying(vessel)
			under.on_throw_end(vessel)
			vessel.visible_message(SPAN_WARNING("Nozzles of [src] stops burning fuel, something very bad about to happen!"))
		return

	var/fuel_to_recover = min(fuel_recover_rate * delta_time, fuel_max - fuel)
	if(!fuel_to_recover || !vessel.can_consume_energy(fuel_to_recover * 2))
		return
	vessel.consume_energy(fuel_to_recover * 2)

	fuel = min(fuel + fuel_to_recover * vessel.misc_multipliers["reactor_buff"], fuel_max)

/obj/item/hardpoint/walker/spinal/jetpack/proc/use_fuel(amount)
	if(fuel < amount)
		return FALSE
	fuel -= amount
	return TRUE

/obj/item/hardpoint/walker/spinal/jetpack/proc/start_flying(obj/vehicle/walker/vessel)
	vessel.flags_atom |= NO_ZFALL
	cache_move_sounds = vessel.move_sounds
	cache_turn_sounds = vessel.turn_sounds
	vessel.move_sounds = move_sounds
	vessel.turn_sounds = turn_sounds
	vessel.update_shadow(src)
	vessel.recalculate_hardpoints()

/obj/item/hardpoint/walker/spinal/jetpack/proc/stop_flying(obj/vehicle/walker/vessel)
	vessel.flags_atom &= ~NO_ZFALL
	vessel.move_sounds = cache_move_sounds// initial() don't work on list? Since when?
	vessel.turn_sounds = cache_turn_sounds
	vessel.shadow_holder.forceMove(vessel)
	vessel.recalculate_hardpoints()

/obj/item/hardpoint/walker/spinal/jetpack/proc/prepare_titan_raise(mob/user, obj/vehicle/walker/vessel)
	var/obj/structure/dropship_equipment/equipment
	for(var/shuttle_tag in list(DROPSHIP_ALAMO, DROPSHIP_NORMANDY))
		var/obj/docking_port/mobile/marine_dropship/dropship = SSshuttle.getShuttle(shuttle_tag)
		if(!dropship.in_flyby)
			continue
		for(equipment as anything in dropship.equipments)
			if(!istype(equipment, /obj/structure/dropship_equipment/medevac_system) &&\
			!istype(equipment, /obj/structure/dropship_equipment/fulton_system) &&\
			!istype(equipment, /obj/structure/dropship_equipment/paradrop_system))
				equipment = null
				continue
			break
	if(!equipment)
		to_chat(user, SPAN_WARNING("Shuttle need to have recovery equipment!"))
		return
	var/area/vessel_area = get_area(get_turf(src))
	if(!vessel_area.ceiling > CEILING_GLASS)
		to_chat(user, SPAN_WARNING("Ceiling stops mech from flying."))
		return
	if(!use_fuel(fuel_max))
		to_chat(user, SPAN_WARNING("There not enough fuel!"))
		return
	vessel.titan_raise(src, get_turf(equipment), 4 SECONDS)

/obj/item/hardpoint/walker/spinal/jetpack/proc/change_flying_state()
	flying = !flying
	owner.visible_message(SPAN_WARNING("[owner] [flying ? "ignites" : "extinguish"] [src] nozzles."))
	if(flying)
		start_flying(owner)
	else
		stop_flying(owner)
		var/turf/under = get_turf(owner)
		if(istype(under, /turf/open_space))
			under.on_throw_end(owner)
	owner.update_icon()

/obj/item/hardpoint/walker/spinal/jetpack/proc/handle_move_z_up(mob/user, obj/vehicle/walker/vessel)
	var/turf/above = SSmapping.get_turf_above(get_turf(src))
	if(istype(above, /turf/open_space))
		visible_message(SPAN_WARNING("Nozzles of [src] burns hard to lift [vessel]."))
		var/turf/current = get_turf(src)
		if(!istype(current, /turf/open_space))
			vessel.flight_start(src, above, 2 SECONDS)
		else
			vessel.forceMove(above)
	else
		to_chat(user, SPAN_WARNING("Seems there no free space above us!"))

/obj/item/hardpoint/walker/spinal/jetpack/proc/handle_move_z_down(mob/user, obj/vehicle/walker/vessel)
	if(istype(get_turf(src), /turf/open_space))
		var/turf/below = SSmapping.get_turf_below(get_turf(src))
		visible_message(SPAN_WARNING("Nozzles of [src] burns less to descend [vessel]."))
		if(!istype(below, /turf/open_space))
			vessel.flight_end(src, below, 2 SECONDS)
		else
			vessel.forceMove(below)
	else
		to_chat(user, SPAN_WARNING("Seems there no free space below us!"))

/obj/item/hardpoint/walker/spinal/jetpack/proc/perform_action(time)
	performing_action = TRUE
	addtimer(VARSET_CALLBACK(src, performing_action, FALSE), time, TIMER_OVERRIDE|TIMER_UNIQUE|TIMER_DELETE_ME)
