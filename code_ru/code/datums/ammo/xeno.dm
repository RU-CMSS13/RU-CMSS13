/datum/ammo/xeno/oppressor_tail/on_hit_obj(obj/vehicle/walker/vessel, obj/projectile/proj_hit)
	if(!istype(vessel))
		return

	var/obj/item/hardpoint/walker/attacked_hardpoint = vessel.hardpoints_by_slot[WALKER_HARDPOIN_HEAD]
	if(attacked_hardpoint?.can_take_damage() || !vessel.seats[VEHICLE_DRIVER])
		return

	var/mob/target = vessel.seats[VEHICLE_DRIVER]
	vessel.seats[VEHICLE_DRIVER].unset_interaction()
	on_hit_mob(target, proj_hit)
