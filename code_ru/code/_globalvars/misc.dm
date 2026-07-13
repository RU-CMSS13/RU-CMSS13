GLOBAL_VAR_INIT(xeno_blueprint_available, TRUE)

GLOBAL_LIST_EMPTY_TYPED(all_active_defenses, /obj/structure/machinery/defenses)


/proc/get_random_turf_in_range_unblocked(atom/origin, outer_range, inner_range)
	origin = get_turf(origin)
	if(!origin)
		return
	var/list/turfs = list()
	for(var/turf/T in RANGE_TURFS(outer_range, origin))
		if(inner_range && get_dist(origin, T) < inner_range)
			continue

		if(T.density)
			continue

		var/failed = FALSE
		for(var/i in T)
			var/atom/A = i
			if(A.density)
				failed = TRUE
				break

		if(failed)
			continue

		turfs += T
	if(turfs.len)
		return pick(turfs)
