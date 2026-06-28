/obj/structure/machinery/cm_vending/gear/vehicle_crew/proc/populate_products(datum/source, datum/vehicle_order/tank/plain/VO)

	SIGNAL_HANDLER
	UnregisterSignal(SSdcs, COMSIG_GLOB_VEHICLE_ORDERED)

	if(istype(VO, /obj/effect/vehicle_spawner/tank))
		selected_vehicle = "TANK"
		marine_announcement("Tank is being sent up to reinforce this operation. Good luck")
	else
		selected_vehicle = "APC"
		marine_announcement("APC is being sent up to reinforce this operation. Good luck")
