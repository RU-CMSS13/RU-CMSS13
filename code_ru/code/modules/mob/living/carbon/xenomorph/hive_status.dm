/datum/hive_status/proc/setup_blueprint_announcements()
	addtimer(CALLBACK(src, PROC_REF(xeno_blueprint_disable)), 20 MINUTES)

/datum/hive_status/proc/xeno_blueprint_disable(list/datum/caste_datum/available_castes)
	for(var/datum/resin_construction/constr as anything in GLOB.resin_build_order_ovipositor)
		if(constr.delete_after)
			GLOB.resin_build_order_ovipositor.Remove(constr)

	GLOB.xeno_blueprint_available = FALSE
	xeno_maptext("Accelerated construction is no longer available", "Growing up of the Hive")
	evo_screech()
