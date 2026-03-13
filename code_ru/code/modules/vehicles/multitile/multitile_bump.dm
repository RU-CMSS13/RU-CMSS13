/obj/structure/machinery/mounted_defence/handle_vehicle_bump(obj/vehicle/multitile/bumped_by)
	var/mob/driver = bumped_by.seats[VEHICLE_DRIVER]
	if(!driver)
		return FALSE
	var/last_moved = bumped_by.l_move_time	//in case VC moves before answering
	if(alert(driver, "Are you sure you want to crush \the [name]?", "Ramming confirmation", "Yes", "No") == "Yes")
		if(last_moved != bumped_by.l_move_time)
			return FALSE
		visible_message(SPAN_DANGER("\The [bumped_by] crushes \the [src]!"))
		playsound(bumped_by, 'sound/effects/metal_crash.ogg', 20)
		log_attack("[src] was crushed by [key_name(driver)] with [bumped_by].")
		message_admins("[src] was crushed by [key_name(driver)] with [bumped_by].")
		update_health(health + 1)
		return TRUE
	return FALSE
