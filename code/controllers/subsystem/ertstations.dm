SUBSYSTEM_DEF(ertstations)
	name   = "ERTStations"
	init_order = SS_INIT_ERTSTATIONS
	flags  = SS_NO_FIRE

	var/datum/map_template/ship_templateWY // Current ship template in use
	var/datum/map_template/ship_templateUPP // Current ship template in use
	var/datum/map_template/ship_templateTWE // Current ship template in use
	var/datum/map_template/ship_templateCLF // Current ship template in use
	var/list/list/managed_z1   // Maps initating clan id to list(datum/space_level, list/turf(spawns))
	var/list/list/managed_z2   // Maps initating clan id to list(datum/space_level, list/turf(spawns))
	var/list/list/managed_z3   // Maps initating clan id to list(datum/space_level, list/turf(spawns))
	var/list/list/managed_z4   // Maps initating clan id to list(datum/space_level, list/turf(spawns))
	var/list/turf/spawnpoints // List of all spawn landmark locations
	/* Note we map clan_id as string due to legacy code using them internally */

/datum/controller/subsystem/ertstations/Initialize(timeofday)
	if(!ship_templateWY)
		ship_templateWY = new /datum/map_template("maps/templates/upp_ert_station.dmm", cache = TRUE)
		LAZYINITLIST(managed_z1)
		load_new(5)
	if(!ship_templateUPP)
		ship_templateUPP = new /datum/map_template("maps/templates/weyland_ert_station.dmm", cache = TRUE)
		LAZYINITLIST(managed_z2)
		load_new(6)
	if(!ship_templateTWE)
		ship_templateTWE = new /datum/map_template("maps/templates/twe_ert_station.dmm", cache = TRUE)
		LAZYINITLIST(managed_z3)
		load_new(7)
	if(!ship_templateCLF)
		ship_templateCLF = new /datum/map_template("maps/templates/clf_ert_station.dmm", cache = TRUE)
		LAZYINITLIST(managed_z4)
		load_new(8)
	return SS_INIT_SUCCESS

/datum/controller/subsystem/ertstations/proc/load_new(initiating_ert_id)
	RETURN_TYPE(/list)
	if(isnum(initiating_ert_id))
		initiating_ert_id = "[initiating_ert_id]"
	if(!initiating_ert_id)
		return NONE
	if(initiating_ert_id in managed_z1)
		return managed_z1[initiating_ert_id]
	if(initiating_ert_id in managed_z2)
		return managed_z2[initiating_ert_id]
	if(initiating_ert_id in managed_z3)
		return managed_z3[initiating_ert_id]
	if(initiating_ert_id in managed_z4)
		return managed_z4[initiating_ert_id]
	if(ship_templateWY)
		var/datum/space_level/level1 = ship_templateWY.load_new_z()
		if(level1)
			var/list/turf/new_spawns = list()
			if(managed_z1)
				managed_z1[initiating_ert_id] = list(level1, new_spawns)
			return managed_z1[initiating_ert_id]
	if(ship_templateUPP)
		var/datum/space_level/level2 = ship_templateUPP.load_new_z()
		if(level2)
			var/list/turf/new_spawns = list()
			if(managed_z2)
				managed_z2[initiating_ert_id] = list(level2, new_spawns)
			return managed_z2[initiating_ert_id]
	if(ship_templateTWE)
		var/datum/space_level/level3 = ship_templateTWE.load_new_z()
		if(level3)
			var/list/turf/new_spawns = list()
			if(managed_z3)
				managed_z3[initiating_ert_id] = list(level3, new_spawns)
			return managed_z3[initiating_ert_id]
	if(ship_templateCLF)
		var/datum/space_level/level4 = ship_templateCLF.load_new_z()
		if(level4)
			var/list/turf/new_spawns = list()
			if(managed_z4)
				managed_z4[initiating_ert_id] = list(level4, new_spawns)
			return managed_z4[initiating_ert_id]
