/obj/vehicle
	light_system = MOVABLE_LIGHT
	light_range = 0
	var/atom/movable/vehicle_light_holder/lighting_holder

	var/vehicle_light_range = 5
	var/vehicle_light_power = 2

	// List of all hardpoints attached to the vehicle
	var/list/hardpoints = list()
	//List of all hardpoints you can attach to this vehicle
	var/list/hardpoints_allowed = list()

	var/list/misc_multipliers = list(
		"move" = 1.0,
		"accuracy" = 1.0,
		"cooldown" = 1
	)

	//Changes how much damage the vehicle takes
	var/list/dmg_multipliers = list(
		"all" = 1.0, //for when you want to make it invincible
		"acid" = 1.0,
		"slash" = 1.0,
		"bullet" = 1.0,
		"explosive" = 1.0,
		"blunt" = 1.0,
		"abstract" = 1.0) //abstract for when you just want to hurt it

	// References to the active/chosen hardpoint for each seat
	var/active_hp = list(
		VEHICLE_DRIVER = null
	)

	// The next world.time when the vehicle can move
	var/next_move = 0
	// How much momentum the vehicle has. Increases by 1 each move
	var/move_momentum = 0
	// How much momentum the vehicle can achieve
	var/move_max_momentum = 5
	// How much momentum is lost when turning/rotating the vehicle
	var/move_turn_momentum_loss_factor = 0.5
	// Determines how much slower the vehicle is when it lacks its full momentum
	// When the vehicle has 0 momentum, it's movement delay will be move_delay * momentum_build_factor
	// The movement delay gradually reduces up to move_delay when momentum increases
	var/move_momentum_build_factor = 1.3

	var/list/move_sounds = list()
	//Cooldown for next sound to play
	var/move_next_sound_play = 0
	var/list/turn_sounds = list()

	var/move_on_turn = FALSE


//////////////////////////////////////////////////////////////


/obj/vehicle/Initialize()
	. = ..()

	if(bound_width > world.icon_size || bound_height > world.icon_size)
		lighting_holder = new(src)
		lighting_holder.set_light_range(vehicle_light_range)
		lighting_holder.set_light_power(vehicle_light_power)
		lighting_holder.set_light_on(vehicle_light_range || vehicle_light_power)
	else if(light_range)
		set_light_on(TRUE)

	light_pixel_x = -bound_x
	light_pixel_y = -bound_y

	return INITIALIZE_HINT_LATELOAD

// Add/remove verbs that should be given when a mob sits down or unbuckles here
/obj/vehicle/proc/add_seated_verbs(mob/living/M, seat)
	return

/obj/vehicle/proc/remove_seated_verbs(mob/living/M, seat)
	return

/// Get crewmember of seat.
/obj/vehicle/proc/get_seat_mob(seat)
	return seats[seat]

/// Get seat of crewmember.
/obj/vehicle/proc/get_mob_seat(mob/M)
	for(var/seat in seats)
		if(seats[seat] == M)
			return seat
	return null

/// Get active hardpoint of crewmember.
/obj/vehicle/proc/get_mob_hp(mob/crew)
	var/seat = get_mob_seat(crew)
	if(seat)
		return active_hp[seat]
	return null

/obj/vehicle/get_examine_text(mob/user)
	. = ..()

	for(var/obj/item/hardpoint/selected in hardpoints)
		. += "There [selected.p_are()] \a [selected] module[selected.p_s()] installed."
		selected.examine(user, TRUE)


/obj/vehicle/Destroy(force)
	QDEL_NULL_LIST(hardpoints)

	. = ..()

	if(!QDELETED(cell))
		QDEL_NULL(cell)


//////////////////////////////////////////////////////////////
//HARDPOINTS

//Putting on hardpoints
//Similar to repairing stuff, down to the time delay
/obj/vehicle/proc/install_hardpoint(obj/item/attacked_item, mob/user)
	if(!skillcheck(user, SKILL_ENGINEER, SKILL_ENGINEER_TRAINED))
		to_chat(user, SPAN_WARNING("You don't know what to do with [attacked_item] on \the [src]."))
		return

	var/obj/item/hardpoint/HP = attacked_item
	if(ispowerclamp(attacked_item))
		var/obj/item/powerloader_clamp/PC = attacked_item
		HP = PC.loaded

	for(var/obj/item/hardpoint/holder/H in hardpoints)
		// Attempt to install on holder hardpoints first
		if(H.can_install(HP))
			H.install(HP, user)
			update_icon()
			return

	if(health < initial(health) * 0.75)
		to_chat(user, SPAN_WARNING("All the mounting points on \the [src] are broken!"))
		return

	if(LAZYLEN(hardpoints))
		for(var/obj/item/hardpoint/H in hardpoints)
			if(HP.slot == H.slot)
				to_chat(user, SPAN_WARNING("There is already something installed there!"))
				return

	if(!(HP.type in hardpoints_allowed))
		to_chat(user, SPAN_WARNING("You don't know what to do with [HP] on \the [src]."))
		return

	user.visible_message(SPAN_NOTICE("[user] begins installing \the [HP] on the [HP.slot] hardpoint slot of \the [src]."),
		SPAN_NOTICE("You begin installing \the [HP] on the [HP.slot] hardpoint slot of \the [src]."))

	var/num_delays = 1

	switch(HP.slot)
		if(HDPT_PRIMARY)
			num_delays = 5
		if(HDPT_SECONDARY)
			num_delays = 3
		if(HDPT_SUPPORT)
			num_delays = 2
		if(HDPT_ARMOR)
			num_delays = 10
		if(HDPT_TREADS, HDPT_WHEELS)
			num_delays = 7

	if(!do_after(user, 30*num_delays * user.get_skill_duration_multiplier(SKILL_ENGINEER), INTERRUPT_ALL, BUSY_ICON_FRIENDLY, numticks = num_delays))
		user.visible_message(SPAN_WARNING("[user] stops installing \the [HP] on \the [src]."), SPAN_WARNING("You stop installing \the [HP] on \the [src]."))
		return

	//check to prevent putting two modules on same slot
	for(var/obj/item/hardpoint/H in hardpoints)
		if(HP.slot == H.slot)
			to_chat(user, SPAN_WARNING("There is already something installed there!"))
			return

	user.visible_message(SPAN_NOTICE("[user] installs \the [HP] on \the [src]."), SPAN_NOTICE("You install \the [HP] on \the [src]."))

	if(ispowerclamp(attacked_item))
		var/obj/item/powerloader_clamp/PC = attacked_item
		PC.loaded.forceMove(src)
		to_chat(user, SPAN_NOTICE("You install \the [PC.loaded] on \the [src] with \the [PC]."))
		PC.loaded = null
		playsound(loc, 'sound/machines/hydraulics_2.ogg', 40, 1)
		PC.update_icon()
	else
		user.temp_drop_inv_item(HP, 0)

	add_hardpoint(HP, user)

//User-orientated proc for taking of hardpoints
//Again, similar to the above ones
/obj/vehicle/proc/uninstall_hardpoint(obj/item/attacked_item, mob/user)
	if(!skillcheck(user, SKILL_ENGINEER, SKILL_ENGINEER_TRAINED))
		to_chat(user, SPAN_WARNING("You don't know what to do with \the [attacked_item] on \the [src]."))
		return

	if(ispowerclamp(attacked_item))
		var/obj/item/powerloader_clamp/clamp_used = attacked_item
		if(!clamp_used.linked_powerloader || clamp_used.loaded)
			return

	var/list/hps = list()
	for(var/obj/item/hardpoint/H in get_hardpoints_copy())
		// Only allow uninstalls of massive hardpoints when using powerloaders
		if(H.w_class == SIZE_MASSIVE && !ispowerclamp(attacked_item) || H.w_class <= SIZE_HUGE && ispowerclamp(attacked_item) || istype(H, /obj/item/hardpoint/special))
			continue
		hps += H

	var/chosen_hp = tgui_input_list(usr, "Select a hardpoint to remove", "Hardpoint Removal", (hps + "Cancel"))
	if(chosen_hp == "Cancel" || !chosen_hp || (get_dist(src, user) > 2)) //get_dist uses 2 because the vehicle is 3x3
		return

	var/obj/item/hardpoint/old = chosen_hp

	if(!old)
		to_chat(user, SPAN_WARNING("There is nothing installed there."))
		return

	if(!old.can_be_removed(user))
		return
	// It's in a holder
	if(!(old in hardpoints))
		for(var/obj/item/hardpoint/holder/H in hardpoints)
			if(old in H.hardpoints)
				H.uninstall(old, user)
				update_icon()
				return

	user.visible_message(SPAN_NOTICE("[user] begins removing [old] on the [old.slot] hardpoint slot on \the [src]."),
		SPAN_NOTICE("You begin removing [old] on the [old.slot] hardpoint slot on \the [src]."))

	var/num_delays = 1

	switch(old.slot)
		if(HDPT_PRIMARY)
			num_delays = 5
		if(HDPT_SECONDARY)
			num_delays = 3
		if(HDPT_SUPPORT)
			num_delays = 2
		if(HDPT_ARMOR)
			num_delays = 10
		if(HDPT_TREADS)
			num_delays = 7

	if(!do_after(user, 30*num_delays * user.get_skill_duration_multiplier(SKILL_ENGINEER), INTERRUPT_ALL, BUSY_ICON_FRIENDLY, numticks = num_delays, target_flags = INTERRUPT_DIFF_LOC, target = old))
		user.visible_message(SPAN_WARNING("[user] stops removing \the [old] on \the [src]."), SPAN_WARNING("You stop removing \the [old] on \the [src]."))
		return

	user.visible_message(SPAN_NOTICE("[user] removes \the [old] on \the [src]."), SPAN_NOTICE("You remove \the [old] on \the [src]."))

	remove_hardpoint(old, user)

	if(QDELETED(old))
		return

	if(ispowerclamp(attacked_item))
		var/obj/item/powerloader_clamp/PC = attacked_item
		PC.grab_object(user, old, "vehicle_module")
		PC.loaded.update_icon()

//General proc for putting on hardpoints
//ALWAYS CALL THIS WHEN ATTACHING HARDPOINTS
/obj/vehicle/proc/add_hardpoint(obj/item/hardpoint/HP, mob/user)
	HP.owner = src
	HP.forceMove(src)
	hardpoints += HP

	HP.on_install(src)
	HP.rotate(turning_angle(HP.dir, dir))

	update_minimap_icon()
	update_icon()
	return TRUE

//General proc for taking off hardpoints
//ALWAYS CALL THIS WHEN REMOVING HARDPOINTS
/obj/vehicle/proc/remove_hardpoint(obj/item/hardpoint/old, mob/user)
	if(!(old in hardpoints))
		return FALSE

	if(user)
		old.forceMove(get_turf(user))
	else
		old.forceMove(get_turf(src))

	old.on_uninstall(src)
	old.reset_rotation()
	hardpoints -= old
	old.owner = null

	if(!old.health && old.destruction_on_zero && !QDELETED(old)) // Make sure it's not already being deleted.
		visible_message(SPAN_WARNING("\The [src] disintegrates into useless pile of scrap under the damage it suffered."))
		qdel(old)

	update_icon()
	return TRUE

/obj/vehicle/multitile/remove_hardpoint(obj/item/hardpoint/old, mob/user)
	if(old.slot == HDPT_TREADS && clamped)
		detach_clamp(user)

// Returns all hardpoints that are attached to the vehicle, including ones held by holder hardpoints (e.g. turrets)
/obj/vehicle/proc/get_hardpoints_copy()
	var/list/all_hardpoints = hardpoints.Copy()
	for(var/obj/item/hardpoint/holder/H in all_hardpoints)
		if(!H.hardpoints)
			continue
		all_hardpoints += H.hardpoints.Copy()

	return all_hardpoints

//Returns all activatable hardpoints
/obj/vehicle/proc/get_activatable_hardpoints(seat)
	var/list/hps = list()
	for(var/obj/item/hardpoint/H in hardpoints)
		if(istype(H, /obj/item/hardpoint/holder))
			var/obj/item/hardpoint/holder/HP = H
			if(HP.hardpoints)
				hps += HP.get_activatable_hardpoints(seat)
		if(!H.is_activatable() || seat && seat != H.allowed_seat)
			continue
		hps += H
	return hps

//Returns hardpoints that use ammunition
/obj/vehicle/proc/get_hardpoints_with_ammo(seat)
	var/list/hps = list()
	for(var/obj/item/hardpoint/H in hardpoints)
		if(istype(H, /obj/item/hardpoint/holder))
			var/obj/item/hardpoint/holder/HP = H
			if(HP.hardpoints)
				hps += HP.get_hardpoints_with_ammo(seat)
		if(!H.ammo || seat && seat != H.allowed_seat)
			continue
		hps += H
	return hps

// Returns a hardpoint by its name
/obj/vehicle/proc/find_hardpoint(name)
	for(var/obj/item/hardpoint/H in hardpoints)
		if(istype(H, /obj/item/hardpoint/holder))
			var/obj/item/hardpoint/holder/HP = H

			var/obj/item/hardpoint/nested_hp = HP.find_hardpoint(name)
			if(nested_hp)
				return nested_hp

		if(H.name == name)
			return H
	return null

//What to do if all ofthe installed modules have been broken
/obj/vehicle/proc/handle_all_modules_broken()
	return

/obj/vehicle/proc/deactivate_all_hardpoints()
	var/list/hps = get_activatable_hardpoints()
	for(var/obj/item/hardpoint/H in hps)
		H.deactivate()


//////////////////////////////////////////////////////////////
//MOVEMENT

/obj/vehicle/relaymove(mob/user, direction)
	if(user != seats[VEHICLE_DRIVER])
		return FALSE

	// Won't even consider moves when the vehicle is broken
	if(!health)
		return FALSE

	return pre_movement(direction)

// This determines what type of movement to execute
/obj/vehicle/proc/pre_movement(direction)
	. = FALSE

	if(world.time < next_move)
		return

	if(dir == turn(direction, 180) || dir == direction)
		. = try_move(direction)
	// Rotation/turning
	else
		. = try_rotate(turning_angle(dir, direction))
		if(move_on_turn)
			. = try_move(direction)

// Attempts to execute the given movement input
/obj/vehicle/proc/try_move(direction, force=FALSE)
	. = FALSE

	if(!can_move(direction))
		return

	. = step(src, direction)
	if(!.)
		return

	if(move_sounds && world.time > move_next_sound_play)
		playsound(src, pick(move_sounds), vol = 20, sound_range = 30)
		move_next_sound_play = world.time + 10

	last_move_dir = direction

// Rotates the vehicle by deg degrees if possible
/obj/vehicle/proc/try_rotate(deg)
	. = FALSE

	if(!can_rotate(deg))
		return

	move_momentum = move_momentum * move_turn_momentum_loss_factor
	if(abs(move_momentum) < 0.5)
		if(move_momentum < 0)
			move_momentum = -0.5
		else
			move_momentum = 0.5
	update_next_move()

	. = setDir(turn(dir, deg), TRUE)
	if(!.)
		return

	last_move_dir = dir

	if(length(turn_sounds))
		playsound(src, pick(turn_sounds), vol = 20, sound_range = 30)

	update_icon()

/obj/vehicle/setDir(newdir, real_rotate = FALSE)
	if(!real_rotate)
		return FALSE

	. = ..()

// Increases/decreases the vehicle's momentum according to whether or not the user is steppin' on the gas or not
/obj/vehicle/proc/update_momentum(direction)
	// If we've stood still for long enough we go back to 0 momentum
	if(world.time > next_move + move_delay*move_momentum_build_factor)
		move_momentum = 0

	if(direction == dir)
		move_momentum = min(move_momentum + 1, move_max_momentum)
	else
		move_momentum = max(move_momentum - 1, -move_max_momentum)

	// Attempt to move in the opposite direction to our momentum
	if(direction == dir && move_momentum < 0 || direction != dir && move_momentum > 0)
		// Brakes or something
		move_momentum = 0
		return FALSE

	return TRUE

/obj/vehicle/proc/update_next_move()
	// 1/((m/M)*b) where m is momentum, M is max momentum and b is the build factor
	var/anti_build_factor = 1/((max(abs(move_momentum), 1)/move_max_momentum) * move_momentum_build_factor)

	if(move_delay == initial(move_delay))
		next_move = INFINITY
	else
		next_move = world.time + move_delay * move_momentum_build_factor * anti_build_factor * misc_multipliers["move"]

	l_move_time = world.time

// This just checks if the vehicle can physically move in the given direction
/obj/vehicle/proc/can_move(direction)
	return TRUE

/obj/vehicle/proc/can_rotate(deg)
	return TRUE


//////////////////////////////////////////////////////////////


/obj/vehicle/proc/update_minimap_icon()
	return

/obj/vehicle/proc/toggle_cameras_status()
	return

/obj/vehicle/proc/get_dmg_multi()
	return

/obj/item/hardpoint
	var/destruction_on_zero = TRUE
