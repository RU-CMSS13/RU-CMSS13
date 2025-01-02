/datum/action/xeno_action/activable/pounce/crusher_charge/additional_effects_always()
	var/mob/living/carbon/xenomorph/crusher/C = owner
	if (!istype(C))
		return

	for (var/mob/living/carbon/H in orange(1, get_turf(C)))
		if(C.can_not_harm(H))
			continue

		new /datum/effects/xeno_slow(H, C, null, null, 3.5 SECONDS)
		to_chat(H, SPAN_XENODANGER("You are slowed as the impact of [C] shakes the ground!"))

	C.rage_bonus()

/mob/living/carbon/xenomorph/crusher/proc/rage_bonus()
	if(!(LAZYISIN(modifier_sources, XENO_FRUIT_SPEED))) //Дабы не стакалось с цветком, иначе это выйдет просто фура
		new /datum/effects/xeno_speed(src,  ttl = 4 SECONDS, set_speed_modifier = 0.4, set_modifier_source = XENO_FRUIT_SPEED, set_end_message = SPAN_XENONOTICE("We feel ourselves exhausted..."))
	attack_speed_modifier = (initial(attack_speed_modifier) -= 4)
	addtimer(CALLBACK(src, PROC_REF(remove_rage_bonus)), 4 SECONDS)

/mob/living/carbon/xenomorph/crusher/proc/remove_rage_bonus()
	attack_speed_modifier = initial(attack_speed_modifier)
	return
