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



// Among other things, used by flamethrower and boiler spray to calculate if flame/spray can pass through.
// Returns an atom for specific effects (primarily flames and acid spray) that damage things upon contact
//
// This is a copy-and-paste of the Enter() proc for turfs with tweaks related to the applications
// of LinkBlocked
/proc/LinkBlockedLISTFUCKU(atom/movable/mover, turf/start_turf, turf/target_turf, list/atom/forget, return_list = FALSE)
	if (!mover)
		return null

	/// the actual dir between the start and target turf
	var/fdir = get_dir(start_turf, target_turf)
	if (!fdir)
		return null

	var/fd1 = fdir & (fdir-1)
	var/fd2 = fdir - fd1
	var/list/list_to_return = list()

	/// The direction that mover's path is being blocked by
	var/blocking_dir = 0

	var/obstacle
	var/turf/T
	var/atom/A

	blocking_dir |= start_turf.BlockedExitDirs(mover, fdir)
	for (obstacle in start_turf) //First, check objects to block exit
		if (mover == obstacle || (obstacle in forget))
			continue
		if (!isStructure(obstacle) && !ismob(obstacle) && !isVehicle(obstacle))
			continue
		A = obstacle
		blocking_dir |= A.BlockedExitDirs(mover, fdir)
		if ((!fd1 || blocking_dir & fd1) && (!fd2 || blocking_dir & fd2))
			if(!return_list)
				return A
			else
				list_to_return += A

	// Check for atoms in adjacent turf EAST/WEST
	if (fd1 && fd1 != fdir)
		T = get_step(start_turf, fd1)
		if (T.BlockedExitDirs(mover, fd2) || T.BlockedPassDirs(mover, fd1))
			blocking_dir |= fd1
			if ((!fd1 || blocking_dir & fd1) && (!fd2 || blocking_dir & fd2))
				if(!return_list)
					return T
				else
					list_to_return += T
		for (obstacle in T)
			if(obstacle in forget)
				continue
			if (!isStructure(obstacle) && !ismob(obstacle) && !isVehicle(obstacle))
				continue
			A = obstacle
			if (A.BlockedExitDirs(mover, fd2) || A.BlockedPassDirs(mover, fd1))
				blocking_dir |= fd1
				if ((!fd1 || blocking_dir & fd1) && (!fd2 || blocking_dir & fd2))
					if(!return_list)
						return A
					else
						list_to_return += A
				break

	// Check for atoms in adjacent turf NORTH/SOUTH
	if (fd2 && fd2 != fdir)
		T = get_step(start_turf, fd2)
		if (T.BlockedExitDirs(mover, fd1) || T.BlockedPassDirs(mover, fd2))
			blocking_dir |= fd2
			if ((!fd1 || blocking_dir & fd1) && (!fd2 || blocking_dir & fd2))
				if(!return_list)
					return T
				else
					list_to_return += T
		for (obstacle in T)
			if(obstacle in forget)
				continue
			if (!isStructure(obstacle) && !ismob(obstacle) && !isVehicle(obstacle))
				continue
			A = obstacle
			if (A.BlockedExitDirs(mover, fd1) || A.BlockedPassDirs(mover, fd2))
				blocking_dir |= fd2
				if ((!fd1 || blocking_dir & fd1) && (!fd2 || blocking_dir & fd2))
					if(!return_list)
						return A
					else
						list_to_return += A
				break

	// Check the turf itself
	blocking_dir |= target_turf.BlockedPassDirs(mover, fdir)
	if ((!fd1 || blocking_dir & fd1) && (!fd2 || blocking_dir & fd2))
		if(!return_list)
			return target_turf
		else
			list_to_return += target_turf
	for (obstacle in target_turf) // Finally, check atoms in the target turf
		if(obstacle in forget)
			continue
		if (!isStructure(obstacle) && !ismob(obstacle) && !isVehicle(obstacle))
			continue
		A = obstacle
		blocking_dir |= A.BlockedPassDirs(mover, fdir)
		if ((!fd1 || blocking_dir & fd1) && (!fd2 || blocking_dir & fd2))
			if(!return_list)
				return A
			else
				list_to_return += A

	if(return_list)
		return list_to_return
	return null // Nothing found to block the link of mover from start_turf to target_turf
