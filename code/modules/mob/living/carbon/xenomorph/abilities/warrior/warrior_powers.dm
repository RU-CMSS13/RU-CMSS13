/datum/action/xeno_action/activable/lunge/use_ability(atom/affected_atom)
	var/mob/living/carbon/xenomorph/lunge_user = owner

	if (!action_cooldown_check())
		if(twitch_message_cooldown < world.time )
			lunge_user.visible_message(SPAN_XENOWARNING("[lunge_user]'s claws twitch."), SPAN_XENOWARNING("Our claws twitch as we try to lunge but lack the strength. Wait a moment to try again."))
			twitch_message_cooldown = world.time + 5 SECONDS
		return //this gives a little feedback on why your lunge didn't hit other than the lunge button going grey. Plus, it might spook marines that almost got lunged if they know why the message appeared, and extra spookiness is always good.

	if (!affected_atom)
		return

	if (!isturf(lunge_user.loc))
		to_chat(lunge_user, SPAN_XENOWARNING("We can't lunge from here!"))
		return

	if (!lunge_user.check_state() || lunge_user.agility)
		return

	if(lunge_user.can_not_harm(affected_atom) || !ismob(affected_atom))
		apply_cooldown_override(click_miss_cooldown)
		return

	var/mob/living/carbon/carbon = affected_atom
	if(carbon.stat == DEAD)
		return

	if (!check_and_use_plasma_owner())
		return

	apply_cooldown()
	..()

	lunge_user.visible_message(SPAN_XENOWARNING("[lunge_user] lunges towards [carbon]!"), SPAN_XENOWARNING("We lunge at [carbon]!"))

	lunge_user.throw_atom(get_step_towards(affected_atom, lunge_user), grab_range, SPEED_FAST, lunge_user)

	if (lunge_user.Adjacent(carbon))
		lunge_user.start_pulling(carbon,1)
		if(ishuman(carbon))
			INVOKE_ASYNC(carbon, TYPE_PROC_REF(/mob, emote), "scream")
	else
		lunge_user.visible_message(SPAN_XENOWARNING("[lunge_user]'s claws twitch."), SPAN_XENOWARNING("Our claws twitch as we lunge but are unable to grab onto our target. Wait a moment to try again."))

	return TRUE

/datum/action/xeno_action/activable/fling/use_ability(atom/affected_atom)
	var/mob/living/carbon/xenomorph/fling_user = owner

	if (!action_cooldown_check())
		return

	if (!isxeno_human(affected_atom) || fling_user.can_not_harm(affected_atom))
		return

	if (!fling_user.check_state() || fling_user.agility)
		return

	if (!fling_user.Adjacent(affected_atom))
		return

	var/mob/living/carbon/carbon = affected_atom
	if(carbon.stat == DEAD)
		return

	if(HAS_TRAIT(carbon, TRAIT_NESTED))
		return

	if(carbon == fling_user.pulling)
		fling_user.stop_pulling()

	if(carbon.mob_size >= MOB_SIZE_BIG)
		to_chat(fling_user, SPAN_XENOWARNING("[carbon] is too big for us to fling!"))
		return

	if (!check_and_use_plasma_owner())
		return

	fling_user.visible_message(SPAN_XENOWARNING("[fling_user] effortlessly flings [carbon] to the side!"), SPAN_XENOWARNING("We effortlessly fling [carbon] to the side!"))
	playsound(carbon,'sound/weapons/alien_claw_block.ogg', 75, 1)
	if(stun_power)
		carbon.Stun(get_xeno_stun_duration(carbon, stun_power))
	if(weaken_power)
		carbon.KnockDown(get_xeno_stun_duration(carbon, weaken_power))
	if(slowdown)
		if(carbon.slowed < slowdown)
			carbon.apply_effect(slowdown, SLOW)
	carbon.last_damage_data = create_cause_data(initial(fling_user.caste_type), fling_user)

	var/facing = get_dir(fling_user, carbon)

	// Hmm today I will kill a marine while looking away from them
	fling_user.face_atom(carbon)
	fling_user.animation_attack_on(carbon)
	fling_user.flick_attack_overlay(carbon, "disarm")
	fling_user.throw_carbon(carbon, facing, fling_distance, SPEED_VERY_FAST, shake_camera = TRUE, immobilize = TRUE)

	apply_cooldown()
	return ..()

/datum/action/xeno_action/activable/warrior_punch/use_ability(atom/affected_atom)
	var/mob/living/carbon/xenomorph/punch_user = owner

	if (!action_cooldown_check())
		return

	if (!isxeno_human(affected_atom) || punch_user.can_not_harm(affected_atom))
		return

	if (!punch_user.check_state() || punch_user.agility)
		return

	var/distance = get_dist(punch_user, affected_atom)

	if (distance > 2)
		return

	var/mob/living/carbon/carbon = affected_atom

	if (distance > 1 && istype(punch_user.strain, /datum/xeno_strain/boxer))
		step_towards(punch_user, carbon, 1)

	if (!punch_user.Adjacent(carbon))
		return

	if(carbon.stat == DEAD)
		return
	if(HAS_TRAIT(carbon, TRAIT_NESTED))
		return

	var/obj/limb/target_limb = carbon.get_limb(check_zone(punch_user.zone_selected))

	if (ishuman(carbon) && (!target_limb || (target_limb.status & LIMB_DESTROYED)))
		target_limb = carbon.get_limb("chest")

	if (!check_and_use_plasma_owner())
		return

	carbon.last_damage_data = create_cause_data(initial(punch_user.caste_type), punch_user)

	punch_user.visible_message(SPAN_XENOWARNING("[punch_user] hits [carbon] in the [target_limb ? target_limb.display_name : "chest"] with a devastatingly powerful punch!"), \
	SPAN_XENOWARNING("We hit [carbon] in the [target_limb ? target_limb.display_name : "chest"] with a devastatingly powerful punch!"))
	var/sound = pick('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg')
	playsound(carbon, sound, 50, 1)
	if(istype(punch_user.strain, /datum/xeno_strain/boxer))
		do_boxer_punch(carbon, target_limb)
	else
		do_base_warrior_punch(carbon, target_limb)
	apply_cooldown()
	return ..()

/datum/action/xeno_action/activable/warrior_punch/proc/do_base_warrior_punch(mob/living/carbon/carbon, obj/limb/target_limb)
	var/mob/living/carbon/xenomorph/warrior = owner
	var/damage = rand(base_damage, base_damage + damage_variance)

	if(ishuman(carbon))
		if((target_limb.status & LIMB_SPLINTED) && !(target_limb.status & LIMB_SPLINTED_INDESTRUCTIBLE)) //If they have it splinted, the splint won't hold.
			target_limb.status &= ~LIMB_SPLINTED
			playsound(get_turf(carbon), 'sound/items/splintbreaks.ogg', 20)
			to_chat(carbon, SPAN_DANGER("The splint on your [target_limb.display_name] comes apart!"))
			carbon.pain.apply_pain(PAIN_BONE_BREAK_SPLINTED)

		if(ishuman_strict(carbon))
			carbon.apply_effect(3, SLOW)

		if(isyautja(carbon))
			damage = rand(base_punch_damage_pred, base_punch_damage_pred + damage_variance)
		else if(target_limb.status & (LIMB_ROBOT|LIMB_SYNTHSKIN))
			damage = rand(base_punch_damage_synth, base_punch_damage_synth + damage_variance)


	carbon.apply_armoured_damage(get_xeno_damage_slash(carbon, damage), ARMOR_MELEE, BRUTE, target_limb ? target_limb.name : "chest")

	// Hmm today I will kill a marine while looking away from them
	warrior.face_atom(carbon)
	warrior.animation_attack_on(carbon)
	warrior.flick_attack_overlay(carbon, "punch")
	shake_camera(carbon, 2, 1)
	step_away(carbon, warrior, 2)

/datum/action/xeno_action/activable/warrior_punch/proc/do_boxer_punch(mob/living/carbon/carbon, obj/limb/target_limb)
	var/mob/living/carbon/xenomorph/warrior = owner
	var/damage = rand(base_damage, base_damage + damage_variance)
	if(ishuman(carbon))
		if(isyautja(carbon))
			damage = rand(base_punch_damage_pred, base_punch_damage_pred + damage_variance)
		else if(target_limb.status & (LIMB_ROBOT|LIMB_SYNTHSKIN))
			damage = rand(base_punch_damage_synth, base_punch_damage_synth + damage_variance)

	carbon.apply_armoured_damage(get_xeno_damage_slash(carbon, damage), ARMOR_MELEE, BRUTE, target_limb? target_limb.name : "chest")
	step_away(carbon, warrior)
	if(prob(25)) // 25% chance to fly 2 tiles
		step_away(carbon, warrior)

	var/datum/behavior_delegate/boxer/boxer_behaivor = warrior.behavior_delegate
	if(istype(boxer_behaivor))
		boxer_behaivor.melee_attack_additional_effects_target(carbon, 1)

	var/datum/action/xeno_action/activable/jab/ability_jab = get_action(warrior, /datum/action/xeno_action/activable/jab)
	if(istype(ability_jab) && !ability_jab.action_cooldown_check())
		if(isxeno(carbon))
			ability_jab.reduce_cooldown(ability_jab.xeno_cooldown / 2)
		else
			ability_jab.end_cooldown()

/datum/action/xeno_action/activable/jab/use_ability(atom/affected_atom)
	var/mob/living/carbon/xenomorph/warrior = owner
	if(!isxeno_human(affected_atom) || warrior.can_not_harm(affected_atom))
		return

	if(!action_cooldown_check())
		return

	if(!warrior.check_state())
		return

	var/distance = get_dist(warrior, affected_atom)
	if(distance > 3)
		return

	var/mob/living/carbon/carbon = affected_atom
	if(carbon.stat == DEAD)
		return

	if(HAS_TRAIT(carbon, TRAIT_NESTED))
		return

	if(!check_and_use_plasma_owner())
		return

	if(distance > 2)
		step_towards(warrior, carbon, 1)

	if(distance > 1)
		step_towards(warrior, carbon, 1)

	if(!warrior.Adjacent(carbon))
		return

	carbon.last_damage_data = create_cause_data(initial(warrior.caste_type), warrior)
	warrior.visible_message(SPAN_XENOWARNING("\The [warrior] hits [carbon] with a powerful jab!"), \
	SPAN_XENOWARNING("You hit [carbon] with a powerful jab!"))
	var/S = pick('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg')
	playsound(carbon,S, 50, 1)
	// Check actions list for a warrior punch and reset it's cooldown if it's there
	var/datum/action/xeno_action/activable/warrior_punch/punch_action = null
	for (var/datum/action/xeno_action/activable/warrior_punch/P in warrior.actions)
		punch_action = P
		break

	if(punch_action && !punch_action.action_cooldown_check())
		if(isxeno(carbon))
			punch_action.reduce_cooldown(punch_action.xeno_cooldown / 2)
		else
			punch_action.end_cooldown()

	carbon.Daze(3)
	carbon.Slow(5)
	var/datum/behavior_delegate/boxer/boxer_behaivor = warrior.behavior_delegate
	if(istype(boxer_behaivor))
		boxer_behaivor.melee_attack_additional_effects_target(carbon, 1)
	apply_cooldown()
	..()

/datum/action/xeno_action/activable/uppercut/use_ability(atom/affected_atom)
	var/mob/living/carbon/xenomorph/warrior = owner
	if(!isxeno_human(affected_atom) || warrior.can_not_harm(affected_atom))
		return

	if(!action_cooldown_check())
		return

	if(!warrior.check_state())
		return

	var/datum/behavior_delegate/boxer/boxer_behaivor = warrior.behavior_delegate
	if(!istype(boxer_behaivor))
		return

	if(!boxer_behaivor.punching_bag)
		return

	if(boxer_behaivor.punching_bag != affected_atom)
		return

	var/mob/living/carbon/carbon = boxer_behaivor.punching_bag
	if(carbon.stat == DEAD)
		return

	if(HAS_TRAIT(carbon, TRAIT_NESTED))
		return

	if(!check_and_use_plasma_owner())
		return

	if(!warrior.Adjacent(carbon))
		return

	if(carbon.mob_size >= MOB_SIZE_BIG)
		to_chat(warrior, SPAN_XENOWARNING("[carbon] is too big for you to uppercut!"))
		return

	var/datum/action/xeno_action/activable/jab/ability_jab = get_action(warrior, /datum/action/xeno_action/activable/jab)
	if(istype(ability_jab))
		ability_jab.apply_cooldown_override(ability_jab.xeno_cooldown)
	var/datum/action/xeno_action/activable/warrior_punch/punch = get_action(warrior, /datum/action/xeno_action/activable/warrior_punch)
	if(istype(punch))
		punch.apply_cooldown_override(punch.xeno_cooldown)

	carbon.last_damage_data = create_cause_data(initial(warrior.caste_type), warrior)
	var/ko_counter = boxer_behaivor.ko_counter
	var/damage = ko_counter >= 1
	var/knockback = ko_counter >= 3
	var/knockdown = ko_counter >= 6
	var/knockout = ko_counter >= 9
	var/message = (!damage) ? "weak" : (!knockback) ? "good" : (!knockdown) ? "powerful" : (!knockout) ? "gigantic" : "titanic"
	warrior.visible_message(SPAN_XENOWARNING("\The [warrior] hits [carbon] with a [message] uppercut!"), \
	SPAN_XENOWARNING("You hit [carbon] with a [message] uppercut!"))
	var/S = pick('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg')
	playsound(carbon,S, 50, 1)
	if(boxer_behaivor.ko_reset_timer != TIMER_ID_NULL)
		deltimer(boxer_behaivor.ko_reset_timer)

	boxer_behaivor.remove_ko()
	var/obj/limb/target_limb = carbon.get_limb(check_zone(warrior.zone_selected))
	if(damage)
		carbon.apply_armoured_damage(get_xeno_damage_slash(carbon, base_damage * ko_counter), ARMOR_MELEE, BRUTE, target_limb? target_limb.name : "chest")
	if(knockout)
		carbon.KnockOut(knockout_power)
		boxer_behaivor.display_ko_message(carbon)
		playsound(carbon,'sound/effects/dingding.ogg', 75, 1)

	if(knockback)
		carbon.explosion_throw(base_knockback * ko_counter, get_dir(warrior, carbon))
	if(knockdown)
		carbon.KnockDown(base_knockdown * ko_counter)
	var/mob_multiplier = 1
	if(isxeno(carbon))
		mob_multiplier = XVX_WARRIOR_HEALMULT
	if(ko_counter > 0)
		warrior.gain_health(mob_multiplier * ko_counter * base_healthgain * warrior.maxHealth / 100)
	apply_cooldown()
	..()
