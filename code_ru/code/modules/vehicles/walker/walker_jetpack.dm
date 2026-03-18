/obj/item/hardpoint/walker/spinal/jetpack
	name = "Mecha Jetpack"
	desc = "Special \"B-2 Spirit\" modification, spread democracy where nobody can reach! Jump in and even faster move out of combat zone after delivering payload."

	custom_actions = list("Fly", "Evac")

	var/fuel = 200
	var/fuel_max = 200
	var/fuel_recover_rate = 2

	var/flying = FALSE
	var/fuel_consumption_rate = 6

	var/list/move_sounds = null
	var/list/turn_sounds = null

	var/performing_action = FALSE

/obj/item/hardpoint/walker/spinal/jetpack/tgui_additional_data()
	. = ..()

	var/list/data = list()
	.["hardpoint_data_additional"] += list(data)
	data["value_name"] = "Fuel"
	data["current_value"] = fuel
	data["max_value"] = fuel_max

/obj/item/hardpoint/walker/spinal/jetpack/on_source_process(delta_time)
	var/obj/vehicle/walker/vessel = owner
	var/turf/under = get_turf(vessel)
	if(flying && istype(under, /turf/open_space))
		if(!use_fuel(fuel_consumption_rate * delta_time))
			flying = FALSE
			stop_flying(owner)
			under.on_throw_end(vessel)
			vessel.visible_message(SPAN_WARNING("Nozzles of [src] stops burning fuel, something very bad about to happen!"))
		return

	var/fuel_to_recover = min(fuel_recover_rate * delta_time, fuel_max - fuel)
	if(!fuel_to_recover || !vessel.can_consume_energy(fuel_to_recover * 2))
		return
	vessel.consume_energy(fuel_to_recover * 2)

	fuel += fuel_to_recover

/obj/item/hardpoint/walker/spinal/jetpack/proc/use_fuel(amount)
	if(fuel < amount)
		return FALSE
	fuel -= amount
	return TRUE

/obj/item/hardpoint/walker/spinal/jetpack/proc/start_flying(obj/vehicle/walker/vessel)
	owner.flags_atom |= NO_ZFALL
	owner.move_sounds = move_sounds
	owner.turn_sounds = turn_sounds
	vessel.update_shadow(src)

/obj/item/hardpoint/walker/spinal/jetpack/proc/stop_flying(obj/vehicle/walker/vessel)
	owner.flags_atom &= ~NO_ZFALL
	owner.move_sounds = initial(owner.move_sounds)
	owner.turn_sounds = initial(owner.turn_sounds)
	vessel.shadow_holder.forceMove(owner)

/obj/item/hardpoint/walker/spinal/jetpack/custom_action(mob/user, custom_action)
	if(performing_action)
		return

	if(custom_action == "Evac")
		prepare_titan_raise(user, owner)
		return

	if(!use_fuel(fuel_consumption_rate))
		return
	flying = !flying
	owner.visible_message(SPAN_WARNING("[owner] [flying ? "ignites" : "extinguish"] [src] nozzles."))
	if(flying)
		start_flying(owner)
	else
		stop_flying(owner)

/obj/item/hardpoint/walker/spinal/jetpack/proc/prepare_titan_raise(mob/user, obj/vehicle/walker/vessel)
	var/obj/structure/dropship_equipment/equipment
	for(var/shuttle_tag in list(DROPSHIP_ALAMO, DROPSHIP_NORMANDY))
		var/obj/docking_port/mobile/marine_dropship/dropship = SSshuttle.getShuttle(shuttle_tag)
		if(!dropship.in_flyby)
			continue
		for(equipment in dropship.equipments)
			if(!istype(equipment, /obj/structure/dropship_equipment/medevac_system) &&\
			!istype(equipment, /obj/structure/dropship_equipment/fulton_system) &&\
			!istype(equipment, /obj/structure/dropship_equipment/paradrop_system))
				equipment = null
				continue
			break
	if(!equipment)
		to_chat(user, SPAN_WARNING("Shuttle need to have recovery equipment!"))
		return
	if(!use_fuel(fuel_max))
		to_chat(user, SPAN_WARNING("There not enough fuel!"))
		return
	vessel.titan_raise(src, get_turf(equipment), 4 SECONDS)

/obj/item/hardpoint/walker/spinal/jetpack/proc/handle_move_z_up(mob/user, obj/vehicle/walker/vessel)
	var/turf/above = SSmapping.get_turf_above(get_turf(src))
	if(istype(above, /turf/open_space))
		visible_message(SPAN_WARNING("Nozzles of [src] burns hard to lift [owner]."))
		var/turf/current = get_turf(src)
		if(!istype(current, /turf/open_space))
			vessel.flight_start(src, above, 2 SECONDS)
		else
			owner.forceMove(above)
	else
		to_chat(user, SPAN_WARNING("Seems there no free space above us!"))

/obj/item/hardpoint/walker/spinal/jetpack/proc/handle_move_z_down(mob/user, obj/vehicle/walker/vessel)
	if(istype(get_turf(src), /turf/open_space))
		var/turf/below = SSmapping.get_turf_below(get_turf(src))
		visible_message(SPAN_WARNING("Nozzles of [src] burns less to descend [owner]."))
		if(!istype(below, /turf/open_space))
			vessel.flight_end(src, below, 2 SECONDS)
		else
			owner.forceMove(below)
	else
		to_chat(user, SPAN_WARNING("Seems there no free space below us!"))

/obj/item/hardpoint/walker/spinal/jetpack/proc/perform_action(time)
	performing_action = TRUE
	addtimer(VARSET_CALLBACK(src, performing_action, FALSE), time, TIMER_OVERRIDE|TIMER_UNIQUE|TIMER_DELETE_ME)
