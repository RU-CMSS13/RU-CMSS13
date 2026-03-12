/datum/ammo/xeno/oppressor_tail/on_hit_obj(obj/target_object, obj/projectile/proj_hit)
	if(!istype(target_object, /obj/vehicle/walker))
		return

	var/obj/vehicle/walker/vehicle = target_object
	var/obj/item/hardpoint/walker/attacked_hardpoint = locate(/obj/item/hardpoint/walker/head) in vehicle.hardpoints
	if(attacked_hardpoint?.can_take_damage() || !vehicle.seats[VEHICLE_DRIVER])
		return

	var/mob/target = vehicle.seats[VEHICLE_DRIVER]
	vehicle.seats[VEHICLE_DRIVER].unset_interaction()
	on_hit_mob(target, proj_hit)
