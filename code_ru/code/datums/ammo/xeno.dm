/datum/ammo/xeno/oppressor_tail/on_hit_obj(obj/vehicle/walker/mecha, obj/projectile/proj_hit)
	if(!istype(mecha))
		return

	var/obj/item/hardpoint/walker/attacked_hardpoint = mecha.hardpoints_by_slot[WALKER_HARDPOIN_HEAD]
	if(attacked_hardpoint?.can_take_damage() || !mecha.seats[VEHICLE_DRIVER])
		return

	var/mob/target = mecha.seats[VEHICLE_DRIVER]
	mecha.seats[VEHICLE_DRIVER].unset_interaction()
	on_hit_mob(target, proj_hit)
