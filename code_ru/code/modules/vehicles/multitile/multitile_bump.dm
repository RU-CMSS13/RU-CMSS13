//Object for LV624 Lazarus Landing - by Arom-beep

/obj/structure/reagent_dispensers/fueltank/handle_vehicle_bump(obj/vehicle/multitile/V)
	reagents.source_mob = V.seats[VEHICLE_DRIVER]
	if(reagents.handle_volatiles())
		if(V.seats[VEHICLE_DRIVER])
			log_game("[key_name(V.seats[VEHICLE_DRIVER])] exploded [name] by ramming it with [V] in [get_area(src)] ([loc.x],[loc.y],[loc.z]).")
		visible_message(SPAN_DANGER("\The [V] crushes \the [src], causing explosion!"))
	else
		visible_message(SPAN_DANGER("\The [V] crushes \the [src]!"))
	playsound(V, 'sound/effects/metal_crash.ogg', 20)
	qdel(src)
	return FALSE

