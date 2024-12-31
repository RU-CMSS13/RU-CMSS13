/datum/action/xeno_action/activable/warrior_punch/use_ability(atom/affected_atom)
	var/mob/living/carbon/xenomorph/punch_user = owner
	var/obj/vehicle/walker/walker

	if (!action_cooldown_check())
		return

	if (!isxeno_human(affected_atom) || punch_user.can_not_harm(affected_atom))
		return

	if (!punch_user.check_state() || punch_user.agility)
		return

	var/distance = get_dist(punch_user, affected_atom)

	if (distance > 2)
		return

	if(istype(affected_atom, walker))
		punch_user.visible_message(SPAN_XENOWARNING("[punch_user] hits [affected_atom] with a devastatingly powerful punch!"), \
		SPAN_XENOWARNING("We hit [affected_atom] with a devastatingly powerful punch!"))
		var/sound = pick('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg')
		playsound(walker?.seats[DRIVER], sound, 50, 1)
		do_base_warrior_punch(0, 0, affected_atom)
		apply_cooldown()
		return ..()

	var/mob/living/carbon/carbon = affected_atom

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
	do_base_warrior_punch(carbon, target_limb)
	apply_cooldown()
	return ..()

/datum/action/xeno_action/activable/warrior_punch/proc/do_base_warrior_punch(mob/living/carbon/carbon, obj/limb/target_limb , obj/vehicle/walker/walker)
	var/mob/living/carbon/xenomorph/warrior = owner
	var/damage = rand(base_damage, base_damage + damage_variance)

	if(istype(walker))
		damage*=4
		walker.health = max(0, walker.health - damage)
		walker.healthcheck()
		warrior.face_atom(walker)
		warrior.animation_attack_on(walker)
		warrior.flick_attack_overlay(walker, "punch")

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
