/obj/vehicle/walker/Collide(atom/A)
	if(A && !QDELETED(A))
		A.last_bumped = world.time
		A.Collided(src)
	return A.handle_vehicle_bump(src)

/obj/vehicle/walker/Collided(atom/A)
	. = ..()

	var/mob/living/carbon/xenomorph/crusher/crusher = A
	if(!istype(crusher))
		return
	if(!crusher.throwing)
		return
	collision_result(250, crusher)

/obj/vehicle/walker/handle_charge_collision(mob/living/carbon/xenomorph/xeno, datum/action/xeno_action/onclick/charger_charge/charger_ability)
	xeno.visible_message(SPAN_DANGER("[xeno] rams into [src] and skids to a halt!"), SPAN_XENOWARNING("We ram into [src] and skid to a halt!"))
	collision_result(charger_ability.momentum * 20, xeno)
	charger_ability.stop_momentum()

/obj/vehicle/walker/onZImpact(turf/impact_turf, height)
	collision_result(height * 100, src, "all")

// The fucking domino effect)))
/obj/vehicle/walker/proc/collision_result(damage, atom/collision_reason, zones)
	take_damage_type(damage, "blunt", collision_reason, null, zones)
	playsound(src, pick_weight(list('code_ru/sound/vehicle/walker/mecha_crusher.ogg' = 49, 'code_ru/sound/vehicle/walker/mecha_crusher_metal_pipe.ogg' = 1)), 35)
	var/turf/target = get_step(src, collision_reason.dir)
	var/list/cached_interactions = list()
	for(var/atom/movable/potential_atom in target)
		if(ismob(potential_atom))
			cached_interactions += potential_atom
			continue
		if(istype(potential_atom, /obj/vehicle/walker) && src != potential_atom)
			cached_interactions += potential_atom

	var/turn_angle = turning_angle(dir, collision_reason.dir)
	Move(target)
	rotate_hardpoints(turn_angle)
	if(flags_atom & NO_ZFALL)
		update_shadow(hardpoints_by_slot[WALKER_HARDPOIN_SPINAL])
		shadow_holder.dir = dir
	var/obj/item/hardpoint/walker/head_protection = hardpoints_by_slot[WALKER_HARDPOIN_HEAD]
	if(!head_protection && seats[VEHICLE_DRIVER])
		cached_interactions += seats[VEHICLE_DRIVER]
		seats[VEHICLE_DRIVER].unset_interaction()
	for(var/atom/movable/unlucky as anything in cached_interactions)
		if(ismob(unlucky))
			var/mob/living/unlucky_mob = unlucky
			unlucky_mob.apply_damage(damage * (unlucky_mob.mob_size + 0.5), BRUTE)
			unlucky_mob.SetKnockDown(2 SECONDS)
			continue
		if(istype(unlucky, /obj/vehicle/walker))
			var/obj/vehicle/walker/unlucky_vessel = unlucky
			unlucky_vessel.collision_result(damage, src)

	var/obj/item/hardpoint/walker/reactor/energy_source = hardpoints_by_slot[WALKER_HARDPOIN_INTERNAL]
	if(energy_source)
		energy_source.reboot_reactor(damage / 10)
	swith_visual_position(90, -20)
	addtimer(CALLBACK(src, PROC_REF(swith_visual_position), 0, 0), damage / 10 - 2, TIMER_OVERRIDE|TIMER_UNIQUE|TIMER_DELETE_ME)

/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/handle_vehicle_bump(obj/vehicle/some_vehicle)
	. = ..()

	if(!istype(some_vehicle, /obj/vehicle/walker))
		return
	if(!linked_dropship?.in_flyby)
		return

	var/obj/vehicle/walker/vessel = some_vehicle
	vessel.prepare_titan_fall(linked_dropship)
