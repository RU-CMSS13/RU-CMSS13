/mob/living/carbon/xenomorph
	// AI stuff
	var/atom/movable/current_target

	var/next_path_generation = 0
	var/list/current_path
	var/turf/current_target_turf

	var/ai_move_delay = 0
	var/path_update_period = (0.5 SECONDS)
	var/ai_range = 16
	var/max_travel_distance = 24

	var/ai_timeout_time = 0
	var/ai_timeout_period = 2 SECONDS

	var/list/datum/action/xeno_action/registered_ai_abilities = list()

	var/datum/xeno_ai_movement/ai_movement_handler

	/// The time interval before this xeno should forcefully get a new target
	var/forced_retarget_time = (10 SECONDS)

	/// The actual cooldown declaration for forceful retargeting, reference forced_retarget_time for time in between checks
	COOLDOWN_DECLARE(forced_retarget_cooldown)

	/// The time interval between calculating new paths if we cannot find a path
	var/no_path_found_period = (2.5 SECONDS)

	/// Cooldown declaration for delaying finding a new path if no path was found
	COOLDOWN_DECLARE(no_path_found_cooldown)

	var/ai_active_intent = INTENT_HARM
	var/target_unconscious = FALSE

/mob/living/carbon/xenomorph/proc/init_movement_handler()
	return new /datum/xeno_ai_movement(src)

/mob/living/carbon/xenomorph/proc/handle_ai_shot(obj/projectile/P)
	SEND_SIGNAL(src, COMSIG_XENO_HANDLE_AI_SHOT, P)

	if(current_target || !P.firer)
		return

	var/distance = get_dist(src, P.firer)
	if(distance > max_travel_distance)
		return

	SSpathfinding.calculate_path(src, P.firer, distance, src, CALLBACK(src, PROC_REF(set_path)), list(src, P.firer))

/mob/living/carbon/xenomorph/proc/register_ai_action(datum/action/xeno_action/XA)
	if(XA.owner != src)
		XA.give_to(src)
	registered_ai_abilities |= XA
	XA.ai_registered(src)

/mob/living/carbon/xenomorph/proc/unregister_ai_action(datum/action/xeno_action/XA)
	registered_ai_abilities -= XA
	XA.ai_unregistered(src)

/mob/living/carbon/xenomorph/proc/process_ai(delta_time)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(TRUE)
	if(!hive || !get_turf(src))
		return TRUE

	var/datum/component/ai_behavior_override/behavior_override = check_overrides()

	if(is_mob_incapacitated(TRUE)) ///If they are incapacitated, the rest doesn't matter.
		current_path = null
		return TRUE

	if(behavior_override?.process_override_behavior(src, delta_time))
		return TRUE

	if(QDELETED(current_target) || !current_target.ai_check_stat(src) || get_dist(current_target, src) > ai_range || COOLDOWN_FINISHED(src, forced_retarget_cooldown))
		current_target = get_target(ai_range)
		COOLDOWN_START(src, forced_retarget_cooldown, forced_retarget_time)
		if(QDELETED(src))
			return TRUE

		if(current_target)
			set_resting(FALSE, FALSE, TRUE)
			if(prob(5))
				emote("hiss")

	a_intent = ai_active_intent

	if(!current_target)
		ai_move_idle(delta_time)
		return TRUE

	if(ai_move_target(delta_time))
		return TRUE

	for(var/x in registered_ai_abilities)
		var/datum/action/xeno_action/XA = x
		if(QDELETED(XA) || XA.owner != src)
			unregister_ai_action(XA)
			continue

		if(XA.hidden)
			continue

		if(XA.process_ai(src, delta_time) == PROCESS_KILL)
			unregister_ai_action(XA)

	if(!current_target || !DT_PROB(XENO_SLASH, delta_time))
		return

	var/list/turf/turfs_to_dist_check = list(get_turf(current_target))

	if(istype(current_target, /atom/movable) && length(current_target.locs) > 1)
		turfs_to_dist_check = get_multitile_turfs_to_check()

	for(var/turf/checked_turf as anything in turfs_to_dist_check)
		if(get_dist(src, checked_turf) > 1)
			continue
		INVOKE_ASYNC(src, PROC_REF(do_click), current_target, "", list())
		return

/** Controls movement when idle. Called by process_ai */
/mob/living/carbon/xenomorph/proc/ai_move_idle(delta_time)
	if(!ai_movement_handler)
		CRASH("No valid movement handler for [src]!")
	ai_movement_handler.ai_move_idle(delta_time)

/** Controls movement towards target. Called by process_ai */
/mob/living/carbon/xenomorph/proc/ai_move_target(delta_time)
	if(!ai_movement_handler)
		CRASH("No valid movement handler for [src]!")
	return ai_movement_handler.ai_move_target(delta_time)

/atom/proc/xeno_ai_obstacle(mob/living/carbon/xenomorph/X, direction, turf/target)
	if(get_turf(src) == target)
		return 0
	return INFINITY

/atom/proc/ai_check_stat(mob/living/carbon/xenomorph/X)
	return TRUE // So we aren't trying to find a new target on attack override

// Called whenever an obstacle is encountered but xeno_ai_obstacle returned something else than infinite
// and now it is considered a valid path.
/atom/proc/xeno_ai_act(mob/living/carbon/xenomorph/X)
	X.do_click(src, "", list())
	return TRUE

/mob/living/carbon/xenomorph/proc/can_move_and_apply_move_delay()
	// Unable to move, try next time.
	if(ai_move_delay > world.time || !(mobility_flags & MOBILITY_MOVE) || is_mob_incapacitated(TRUE) || (body_position != STANDING_UP && !can_crawl) || anchored)
		return FALSE

	ai_move_delay = world.time + move_delay
	if(recalculate_move_delay)
		ai_move_delay = world.time + movement_delay()
	if(next_move_slowdown)
		ai_move_delay += next_move_slowdown
		next_move_slowdown = 0
	return TRUE

/mob/living/carbon/xenomorph/proc/set_path(list/path)
	current_path = path
	if(!path)
		COOLDOWN_START(src, no_path_found_cooldown, no_path_found_period)

/mob/living/carbon/xenomorph/proc/move_to_next_turf(turf/T, max_range = ai_range)
	if(!T)
		return FALSE

	if((!current_path || (next_path_generation < world.time && current_target_turf != T)) && COOLDOWN_FINISHED(src, no_path_found_cooldown))
		if(!CALCULATING_PATH(src) || current_target_turf != T)
			SSpathfinding.calculate_path(src, T, max_range, src, CALLBACK(src, PROC_REF(set_path)), list(src, current_target))
			current_target_turf = T
		next_path_generation = world.time + path_update_period

	if(CALCULATING_PATH(src))
		return TRUE

	// No possible path to target.
	if(!current_path && get_dist(T, src) > 0)
		return FALSE

	// We've reached our destination
	if(!length(current_path) || get_dist(T, src) <= 0)
		current_path = null
		return TRUE

	// We've somehow deviated from our current path. Generate next path whenever possible.
	if(get_dist(current_path[current_path.len], src) > 1)
		current_path = null
		return TRUE

	// Unable to move, try next time.
	if(!can_move_and_apply_move_delay())
		return TRUE

	var/turf/next_turf = current_path[current_path.len]
	var/list/L = LinkBlockedLISTFUCKU(src, loc, next_turf, list(src), TRUE)
	L += SSpathfinding.check_special_blockers(src, next_turf)
	for(var/a in L)
		var/atom/A = a
		if(A.xeno_ai_obstacle(src, get_dir(loc, next_turf)) == INFINITY)
			return FALSE
		INVOKE_ASYNC(A, TYPE_PROC_REF(/atom, xeno_ai_act), src)
	var/successful_move = Move(next_turf, get_dir(src, next_turf))
	if(successful_move)
		ai_timeout_time = world.time
		current_path.len--

	if(ai_timeout_time < world.time - ai_timeout_period)
		return FALSE

	return TRUE

/// Checks and returns the nearest override for behavior
/mob/living/carbon/xenomorph/proc/check_overrides()
	var/shortest_distance = INFINITY
	var/datum/component/ai_behavior_override/closest_valid_override
	for(var/datum/component/ai_behavior_override/cycled_override in GLOB.all_ai_behavior_overrides)
		var/distance = get_dist(src, cycled_override.parent)
		var/validity = cycled_override.check_behavior_validity(src, distance)

		if(!validity)
			continue

		if(distance >= shortest_distance)
			continue

		shortest_distance = distance
		closest_valid_override = cycled_override

	return closest_valid_override

#define EXTRA_CHECK_DISTANCE_MULTIPLIER 0.20

/mob/living/carbon/xenomorph/proc/get_target(range)
	var/list/viable_targets = list()
	var/atom/movable/closest_target
	var/smallest_distance = INFINITY

	var/list/valid_targets = SSxeno_ai.get_valid_targets(src)

	for(var/atom/movable/potential_target as anything in valid_targets)
		if(z != potential_target.z)
			continue

		var/distance = get_dist(src, potential_target)

		if(distance > ai_range)
			continue

		viable_targets += potential_target

		if(smallest_distance <= distance)
			continue

		closest_target = potential_target
		smallest_distance = distance

	var/extra_check_distance = round(smallest_distance * EXTRA_CHECK_DISTANCE_MULTIPLIER)

	if(extra_check_distance < 1)
		return closest_target

	var/list/extra_checked = orange(extra_check_distance, closest_target)

	var/list/final_targets = extra_checked & viable_targets

	return length(final_targets) ? pick(final_targets) : closest_target

#undef EXTRA_CHECK_DISTANCE_MULTIPLIER

/mob/living/carbon/xenomorph/proc/make_ai()
	SHOULD_CALL_PARENT(TRUE)
	create_hud()
	if(!client)
		SSxeno_ai.add_ai(src)

	if(!ai_movement_handler)
		set_movement_handler(init_movement_handler())

/mob/living/carbon/xenomorph/proc/set_movement_handler(datum/xeno_ai_movement/XAM)
	if(!XAM)
		CRASH("Passed null value to set_movement_handler on [type].")

	if(ai_movement_handler)
		qdel(ai_movement_handler)
	ai_movement_handler = XAM

/mob/living/carbon/xenomorph/proc/remove_ai()
	SHOULD_CALL_PARENT(TRUE)
	SSxeno_ai.remove_ai(src)

/mob/living/carbon/xenomorph/proc/get_multitile_turfs_to_check()
	var/angle = Get_Angle(current_target, src)
	var/turf/base_turf = current_target.locs[1]

	switch(angle)
		if(315 to 360, 0 to 45) //northerly
			var/max_y_value = base_turf.y + (round(current_target.bound_height / 32) - 1)
			var/list/turf/max_y_turfs = list()
			for(var/turf/cycled_turf as anything in current_target.locs)
				if(cycled_turf.y == max_y_value)
					max_y_turfs += cycled_turf
			return max_y_turfs
		if(45 to 135) //easterly
			var/max_x_value = base_turf.x + (round(current_target.bound_width / 32) - 1)
			var/list/turf/max_x_turfs = list()
			for(var/turf/cycled_turf as anything in current_target.locs)
				if(cycled_turf.x == max_x_value)
					max_x_turfs += cycled_turf
			return max_x_turfs
		if(135 to 225) //southerly
			var/min_y_value = base_turf.y
			var/list/turf/min_y_turfs = list()
			for(var/turf/cycled_turf as anything in current_target.locs)
				if(cycled_turf.y == min_y_value)
					min_y_turfs += cycled_turf
			return min_y_turfs
		if(225 to 315) //westerly
			var/min_x_value = base_turf.x
			var/list/turf/min_x_turfs = list()
			for(var/turf/cycled_turf as anything in current_target.locs)
				if(cycled_turf.x == min_x_value)
					min_x_turfs += cycled_turf
			return min_x_turfs

/// Override as necessary to check for more specific triggers for an ability activation.
/mob/living/carbon/xenomorph/proc/check_additional_ai_activation()
	return TRUE


/datum/action/xeno_action/proc/process_ai(mob/living/carbon/xenomorph/processing_xeno, delta_time)
	SHOULD_NOT_SLEEP(TRUE)
	return PROCESS_KILL

/datum/action/xeno_action/proc/ai_registered(mob/living/carbon/xenomorph/X)
	SHOULD_CALL_PARENT(TRUE)
	return

/datum/action/xeno_action/proc/ai_unregistered(mob/living/carbon/xenomorph/X)
	SHOULD_CALL_PARENT(TRUE)
	return


/datum/action/xeno_action
	/// Whether this action gets added to AI xenos
	var/default_ai_action = FALSE
	/// Chance of use per tick applicable tick
	var/ai_prob_chance = 80

/datum/action/xeno_action/activable/fling/charger
	default_ai_action = TRUE
	ai_prob_chance = 60

/datum/action/xeno_action/onclick/charger_charge
	default_ai_action = TRUE
	ai_prob_chance = 80


#define MIN_TARGETS_TO_CHARGE 2
#define FLOCK_SCAN_RADIUS 3
#define MINIMUM_CHARGE_DISTANCE 3
#define MAXIMUM_TARGET_DISTANCE 12
/datum/action/xeno_action/onclick/charger_charge/process_ai(mob/living/carbon/xenomorph/processing_xeno, delta_time)
	if(!DT_PROB(ai_prob_chance, delta_time) || !isnull(charge_dir) || processing_xeno.action_busy)
		return

	var/turf/xeno_turf = get_turf(processing_xeno)

	if(!xeno_turf)
		return

	var/list/possible_charge_dirs = list()

	for(var/mob/living/carbon/base_checked_carbon as anything in GLOB.alive_mob_list)
		var/distance_between_base_carbon_and_xeno = get_dist(processing_xeno, base_checked_carbon)

		if(distance_between_base_carbon_and_xeno > MAXIMUM_TARGET_DISTANCE)
			continue

		if(distance_between_base_carbon_and_xeno < MINIMUM_CHARGE_DISTANCE)
			continue

		if(!base_checked_carbon.ai_can_target(processing_xeno))
			continue

		var/secondary_count = 0
		var/secondary_x_sum = 0
		var/secondary_y_sum = 0

		for(var/mob/living/carbon/secondary_checked_carbon in range(FLOCK_SCAN_RADIUS, base_checked_carbon))
			if(!secondary_checked_carbon.ai_can_target(processing_xeno))
				continue

			secondary_count++
			secondary_x_sum += secondary_checked_carbon.x
			secondary_y_sum += secondary_checked_carbon.y

		if(secondary_count < MIN_TARGETS_TO_CHARGE)
			continue

		var/x_middle = round(secondary_x_sum / secondary_count)
		var/y_middle = round(secondary_y_sum / secondary_count)

		if((abs(x_middle - processing_xeno.x) > 1) && (abs(y_middle - processing_xeno.y) > 1))
			continue

		var/turf/potential_charge_turf = locate(x_middle, y_middle, processing_xeno.z)

		var/distance_between_potential_charge_turf_and_xeno = get_dist(potential_charge_turf, processing_xeno)

		if(distance_between_potential_charge_turf_and_xeno < MINIMUM_CHARGE_DISTANCE)
			continue

		var/cardinal_dir_to_potential_charge_turf = get_cardinal_dir(processing_xeno, potential_charge_turf)

		var/list/turf/turfs_to_check = get_line(xeno_turf, get_angle_target_turf(xeno_turf, cardinal_dir_to_potential_charge_turf, MINIMUM_CHARGE_DISTANCE), FALSE)

		var/blocked = FALSE
		var/turf/previous_turf = xeno_turf

		for(var/turf/checked_turf in turfs_to_check)
			var/list/ignore = list()

			for(var/mob/mob_blocker in checked_turf)
				ignore += mob_blocker

			if(LinkBlockedLISTFUCKU(processing_xeno, previous_turf, checked_turf, ignore))
				blocked = TRUE
				break

			previous_turf = checked_turf

		if(blocked)
			continue

		possible_charge_dirs += cardinal_dir_to_potential_charge_turf

	if(!length(possible_charge_dirs))
		return

	charge_dir = pick(possible_charge_dirs)

	last_charge_move = world.time
	use_ability_async()

#undef MIN_TARGETS_TO_CHARGE
#undef FLOCK_SCAN_RADIUS
#undef MINIMUM_CHARGE_DISTANCE
#undef MAXIMUM_TARGET_DISTANCE

/datum/action/xeno_action/activable/pounce
	default_ai_action = TRUE

/datum/action/xeno_action/activable/pounce/facehugger
	ai_prob_chance = 45

/datum/action/xeno_action/onclick/rend
	var/list/humans_near = list()
	default_ai_action = TRUE
	ai_prob_chance = 100

/datum/action/xeno_action/onclick/doom
	var/list/humans_near = list()
	default_ai_action = TRUE
	ai_prob_chance = 80

/datum/action/xeno_action/onclick/destroy
	default_ai_action = TRUE
	ai_prob_chance = 60

/datum/action/xeno_action/onclick/king_shield
	var/list/xenos_near = list()
	default_ai_action = TRUE
	ai_prob_chance = 80

/datum/action/xeno_action/onclick/king_frenzy
	default_ai_action = TRUE
	ai_prob_chance = 80

/datum/action/xeno_action/activable/throw_hugger
	default_ai_action = TRUE

/datum/action/xeno_action/activable/pounce/crusher_charge
	default_ai_action = FALSE

/datum/action/xeno_action/onclick/crusher_stomp
	default_ai_action = TRUE

/datum/action/xeno_action/onclick/lurker_assassinate
	default_ai_action = TRUE


/// Used for AI xenos to prevent them from sleeping
/datum/action/xeno_action/proc/use_ability_async(atom/A)
	set waitfor = FALSE
	use_ability(A)


/datum/action/xeno_action/activable/pounce/process_ai(mob/living/carbon/xenomorph/pouncing_xeno, delta_time)
	. = ..()

	if(get_dist(pouncing_xeno, pouncing_xeno.current_target) > distance)
		return FALSE

	if(!DT_PROB(ai_prob_chance, delta_time))
		return FALSE

	var/turf/last_turf = pouncing_xeno.loc
	var/clear = TRUE

	pouncing_xeno.add_temp_pass_flags(PASS_OVER_THROW_MOB)

	for(var/i in get_line(pouncing_xeno, pouncing_xeno.current_target, FALSE))
		var/turf/new_turf = i
		if(LinkBlockedLISTFUCKU(pouncing_xeno, last_turf, new_turf, list(pouncing_xeno.current_target, pouncing_xeno)))
			clear = FALSE
			break

	pouncing_xeno.remove_temp_pass_flags(PASS_OVER_THROW_MOB)

	if(!clear)
		return FALSE

	use_ability_async(pouncing_xeno.current_target)
	return TRUE

/datum/action/xeno_action/activable/throw_hugger/process_ai(mob/living/carbon/xenomorph/X, delta_time)
	var/distance = get_dist(X, X.current_target)
	if(!DT_PROB(ai_prob_chance, delta_time) || distance < 3 || distance > 8)
		return

	use_ability_async(X.current_target)

/datum/action/xeno_action/onclick/crusher_stomp/process_ai(mob/living/carbon/xenomorph/X, delta_time)
	if(!DT_PROB(ai_prob_chance, delta_time) || get_dist(X, X.current_target) >= distance - 1 || HAS_TRAIT(X, TRAIT_CHARGING) || X.action_busy)
		return

	use_ability_async()

/datum/action/xeno_action/activable/fling/charger/process_ai(mob/living/carbon/xenomorph/X, delta_time)
	if(!DT_PROB(ai_prob_chance, delta_time) || get_dist(X, X.current_target) > 1 || HAS_TRAIT(X, TRAIT_CHARGING) || X.action_busy)
		return

	use_ability_async(X.current_target)



/datum/action/xeno_action/onclick/rend/process_ai(mob/living/carbon/xenomorph/X, delta_time)
	for(var/mob/living/carbon/human/inrange in view(X))
		var/distance_check = get_dist(X, inrange)

		if(distance_check < 3)
			humans_near |= inrange
			continue

		if(!DT_PROB(ai_prob_chance, delta_time) || length(humans_near) < 2 || get_dist(X, X.current_target) < 3 || X.action_busy)
			humans_near.RemoveAll()
			return

		use_ability_async()
		humans_near.RemoveAll()

/datum/action/xeno_action/onclick/doom/process_ai(mob/living/carbon/xenomorph/X, delta_time)
	for(var/mob/living/carbon/human/inrange in view(X))
		var/distance_check = get_dist(X, inrange)

		if(distance_check < 5)
			humans_near |= inrange
			continue

		if(!DT_PROB(ai_prob_chance, delta_time) || length(humans_near) < 3 || get_dist(X, X.current_target) > 3 || X.action_busy)
			humans_near.RemoveAll()
			return

		use_ability_async()
		humans_near.RemoveAll()

/datum/action/xeno_action/onclick/destroy/process_ai(mob/living/carbon/xenomorph/X, delta_time)
	var/distance_check = get_dist(X, X.current_target)

	if(distance_check > 7)
		return

	if(!DT_PROB(ai_prob_chance, delta_time) || get_dist(X, X.current_target) < 2 || X.action_busy)
		return

	use_ability_async()

/datum/action/xeno_action/onclick/king_shield/process_ai(mob/living/carbon/xenomorph/X, delta_time)
	for(var/mob/living/carbon/xenomorph/inrange in view(X))
		var/distance_check = get_dist(X, inrange)

		if(distance_check < 5)
			xenos_near |= inrange
			continue

		if(!DT_PROB(ai_prob_chance, delta_time) || length(xenos_near) < 4 || X.action_busy)
			xenos_near.RemoveAll()
			return

		use_ability_async()
		xenos_near.RemoveAll()

/datum/action/xeno_action/onclick/king_frenzy/process_ai(mob/living/carbon/xenomorph/X, delta_time)

	if(!DT_PROB(ai_prob_chance, delta_time) || get_dist(X, X.current_target) < 2 || X.action_busy)
		return

	use_ability_async()

/datum/action/xeno_action/onclick/lurker_assassinate/process_ai(mob/living/carbon/xenomorph/using_xeno, delta_time)
	. = ..()

	if(using_xeno.next_move <= world.time)
		return FALSE

	if(get_dist(using_xeno, using_xeno.current_target) > 1)
		return FALSE

	if(!DT_PROB(ai_prob_chance, delta_time))
		return FALSE

	use_ability_async(using_xeno.current_target)

	return TRUE

/mob/living/carbon/xenomorph/lurker/ai_move_target(delta_time)
	if(throwing)
		return

	if(pulling)
		if(!current_target || get_dist(src, current_target) > 10)
			INVOKE_ASYNC(src, PROC_REF(stop_pulling_warapper))
			return ..()
		if(can_move_and_apply_move_delay())
			if(!Move(get_step(loc, pull_direction), pull_direction))
				pull_direction = turn(pull_direction, pick(45, -45))
		current_path = null
		return

	..()

	if(get_dist(current_target, src) > 1)
		return

	if(!istype(current_target, /mob))
		return

	var/mob/current_target_mob = current_target

	if(!current_target_mob.is_mob_incapacitated())
		return

	if(isxeno(current_target.pulledby))
		return

	if(!DT_PROB(RUNNER_GRAB, delta_time))
		return

	INVOKE_ASYNC(src, PROC_REF(start_pulling), current_target)
	swap_hand()

/mob/living/carbon/xenomorph/lurker/process_ai(delta_time)
	if(get_active_hand())
		swap_hand()
	return ..()

/mob/living/carbon/xenomorph/runner/ai_move_target(delta_time)
	if(throwing)
		return

	if(pulling)
		if(!current_target || get_dist(src, current_target) > 10)
			INVOKE_ASYNC(src, PROC_REF(stop_pulling_warapper))
			return ..()
		if(can_move_and_apply_move_delay())
			if(!Move(get_step(loc, pull_direction), pull_direction))
				pull_direction = turn(pull_direction, pick(45, -45))
		current_path = null
		return

	..()

	if(get_dist(current_target, src) > 1)
		return

	if(!istype(current_target, /mob))
		return

	var/mob/current_target_mob = current_target

	if(!current_target_mob.is_mob_incapacitated())
		return

	if(isxeno(current_target.pulledby))
		return

	if(!DT_PROB(RUNNER_GRAB, delta_time))
		return

	INVOKE_ASYNC(src, PROC_REF(start_pulling), current_target)
	swap_hand()

/mob/living/carbon/xenomorph/runner/process_ai(delta_time)
	if(get_active_hand())
		swap_hand()
	return ..()

/datum/action/xeno_action/activable/tail_stab/process_ai(mob/living/carbon/xenomorph/parent, delta_time)
	/// Short-circuit. Will return the last thing checked or FALSE if it fails at any step.
	/// We do not need to check for distance here as the tailstab itself will do that; that distance being 2.
	return DT_PROB(ai_prob_chance, delta_time) && use_ability_async(parent.current_target)


/datum/action/xeno_action/activable/fling/process_ai(mob/living/carbon/xenomorph/parent, delta_time)
	/// We have a home turf to fling to.
	if(DT_PROB(ai_prob_chance, delta_time))
		parent.dir = parent.ai_movement_handler.home_turf ? get_dir(parent, parent.ai_movement_handler.home_turf) : pick(NORTH, SOUTH, EAST, WEST) /// Pick at random if there is no valid direction.
		use_ability_async(parent.current_target)


/datum/action/xeno_action/activable/lunge/process_ai(mob/living/carbon/xenomorph/parent, delta_time)
	/// Want to make sure no obstacles are in the way so that the alien is not lunging for no reason, or bonking into barricades like an idiot.
	/// Maybe in the future the actual lunge can be stripped down for the AI only?
	if(DT_PROB(ai_prob_chance, delta_time) && get_dist(parent, parent.current_target) == grab_range)
		/// get_step_to() should return the turf nearest the target if successful, with no obstacles to block movement there with the lunge.
		var/turf/T = get_step_to(parent, parent.current_target)
		return T?.AdjacentQuick(parent.current_target.loc) && use_ability_async(parent.current_target)


/mob/living/carbon/xenomorph/lurker
	var/pull_direction

/mob/living/carbon/xenomorph/lurker/launch_towards(datum/launch_metadata/LM)
	if(!current_target)
		return ..()

	pull_direction = turn(get_dir(src, current_target), 180)

	if(!(pull_direction in GLOB.cardinals))
		if(abs(x - current_target.x) < abs(y - current_target.y))
			pull_direction &= (NORTH|SOUTH)
		else
			pull_direction &= (EAST|WEST)
	return ..()

/mob/living/carbon/xenomorph/runner
	var/linger_range = 5
	var/linger_deviation = 1
	var/pull_direction

/mob/living/carbon/xenomorph/runner/launch_towards(datum/launch_metadata/LM)
	if(!current_target)
		return ..()

	pull_direction = turn(get_dir(src, current_target), 180)

	if(!(pull_direction in GLOB.cardinals))
		if(abs(x - current_target.x) < abs(y - current_target.y))
			pull_direction &= (NORTH|SOUTH)
		else
			pull_direction &= (EAST|WEST)
	return ..()


/mob/living/carbon/xenomorph/crusher/init_movement_handler()
	return new /datum/xeno_ai_movement/crusher(src)

/mob/living/carbon/xenomorph/drone/init_movement_handler()
	return new /datum/xeno_ai_movement/drone(src)

/mob/living/carbon/xenomorph/facehugger/init_movement_handler()
	return new /datum/xeno_ai_movement/linger/facehugger(src)

/mob/living/carbon/xenomorph/lurker/init_movement_handler()
	return new /datum/xeno_ai_movement/linger/lurking(src)

/mob/living/carbon/xenomorph/runner/init_movement_handler()
	var/datum/xeno_ai_movement/linger/linger_movement = new(src)
	linger_movement.linger_range = linger_range
	linger_movement.linger_deviation = linger_deviation
	return linger_movement

/mob/living/carbon/xenomorph/runner/acider/init_movement_handler()
	return new /datum/xeno_ai_movement(src)
