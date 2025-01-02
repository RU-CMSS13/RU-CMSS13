/datum/action/xeno_action/activable/scissor_cut/use_ability(atom/target_atom)
	var/mob/living/carbon/xenomorph/ravager_user = owner

	if (!action_cooldown_check())
		return

	if (!ravager_user.check_state())
		return

	// Determine whether or not we should daze here
	var/should_sslow = FALSE
	var/datum/behavior_delegate/ravager_base/ravager_delegate = ravager_user.behavior_delegate
	if(ravager_delegate.empower_targets >= ravager_delegate.super_empower_threshold)
		should_sslow = TRUE

	// Get line of turfs
	var/list/turf/target_turfs = list()

	var/facing = Get_Compass_Dir(ravager_user, target_atom)
	var/turf/turf = ravager_user.loc
	var/turf/temp = ravager_user.loc
	var/list/telegraph_atom_list = list()

	for (var/step in 0 to 3)
		temp = get_step(turf, facing)
		if(facing in GLOB.diagonals) // check if it goes through corners
			var/reverse_face = GLOB.reverse_dir[facing]

			var/turf/back_left = get_step(temp, turn(reverse_face, 45))
			var/turf/back_right = get_step(temp, turn(reverse_face, -45))
			if((!back_left || back_left.density) && (!back_right || back_right.density))
				break
		if(!temp || temp.density || temp.opacity)
			break

		var/blocked = FALSE
		for(var/obj/structure/structure_blocker in temp)
			if(istype(structure_blocker, /obj/structure/window/framed))
				var/obj/structure/window/framed/framed_window = structure_blocker
				if(!framed_window.unslashable)
					framed_window.deconstruct(disassembled = FALSE)
			if(istype(structure_blocker, /obj/structure/fence))
				var/obj/structure/fence/fence = structure_blocker
				if(!fence.unslashable)
					fence.health -= 50
					fence.healthcheck()

			if(structure_blocker.opacity)
				blocked = TRUE
				break
		if(blocked)
			break

		turf = temp
		target_turfs += turf
		telegraph_atom_list += new /obj/effect/xenomorph/xeno_telegraph/red(turf, 0.25 SECONDS)

	// Extract our 'optimal' turf, if it exists
	if (length(target_turfs) >= 2)
		ravager_user.animation_attack_on(target_turfs[length(target_turfs)], 15)

	// Hmm today I will kill a marine while looking away from them
	ravager_user.face_atom(target_atom)
	ravager_user.emote("roar")
	ravager_user.visible_message(SPAN_XENODANGER("[ravager_user] sweeps its claws through the area in front of it!"), SPAN_XENODANGER("We sweep our claws through the area in front of us!"))

	// Loop through our turfs, finding any humans there and dealing damage to them
	for (var/turf/target_turf in target_turfs)
		for (var/mob/living/carbon/carbon_target in target_turf)
			if (carbon_target.stat == DEAD)
				continue

			if(ravager_user.can_not_harm(carbon_target))
				continue
			ravager_user.flick_attack_overlay(carbon_target, "slash")
			carbon_target.apply_armoured_damage(damage, ARMOR_MELEE, BRUTE)
			playsound(get_turf(carbon_target), "alien_claw_flesh", 30, TRUE)

			if(should_sslow)
				new /datum/effects/xeno_slow/superslow(carbon_target, ravager_user, ttl = superslow_duration)
		for(var/obj/vehicle/walker/walker in target_turf)
			walker.health = max(0, walker.health - (damage * 3))
			walker.healthcheck()
			ravager_user.visible_message(SPAN_XENOWARNING("[ravager_user] hits [walker] with a devastatingly powerful swing!"), \
			SPAN_XENOWARNING("We hit [walker] with a devastatingly powerful swing!"))

	apply_cooldown()
	return ..()
