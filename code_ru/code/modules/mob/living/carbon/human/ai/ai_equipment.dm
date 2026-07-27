/obj/item/proc/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain)
	return

/obj/item/proc/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain)
	return FALSE


/obj/item/explosive/grenade/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain)
	return TRUE

/obj/item/explosive/grenade/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, turf/target_turf)
	sleep(ai_brain.short_action_delay * ai_brain.action_delay_mult)
	attack_self(user)
	user.toggle_throw_mode(THROW_MODE_NORMAL)
	ai_brain.ensure_primary_hand(src)
	sleep(det_time * 0.4)
	if(QDELETED(src) || (loc != user))
		return

	ai_brain.say_grenade_thrown_line()
	sleep(det_time * 0.4)
	if(QDELETED(src) || (loc != user))
		return

	user.face_atom(target_turf)
	user.throw_item(target_turf)


/obj/item/reagent_container/hypospray/autoinjector/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	if(!uses_left || issynth(target))
		return FALSE

	var/datum/reagent/reagent_datum = GLOB.chemical_reagents_list[chemname]

	if((target.reagents.get_reagent_amount(chemname) + amount_per_transfer_from_this) > reagent_datum.overdose)
		return FALSE

	if(skilllock != SKILL_MEDICAL_TRAINED && !skillcheck(user, SKILL_MEDICAL, skilllock))
		return FALSE

	return TRUE

/obj/item/reagent_container/hypospray/autoinjector/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	attack(target, user)

/obj/item/reagent_container/hypospray/autoinjector/dexalinp/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	if(target.reagents.get_reagent_amount(chemname))
		return FALSE
	return ..()


// Medical purposes for synths
/obj/item/stack/cable_coil/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	if(!issynth(target))
		return FALSE

	for(var/obj/limb/limb as anything in target.limbs)
		for(var/datum/wound/wound in limb.wounds)
			if(wound.internal || (wound.damage_type == BRUTE))
				continue

			return TRUE

	return FALSE

/obj/item/stack/cable_coil/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	user.a_intent_change(INTENT_HELP)

	for(var/obj/limb/limb as anything in target.limbs)
		if(QDELETED(src))
			return

		for(var/datum/wound/wound in limb.wounds)
			if(wound.internal || (wound.damage_type == BRUTE))
				continue

			if(QDELETED(src))
				return

			user.zone_selected = limb.name
			attack(target, user)
			sleep(ai_brain.short_action_delay * ai_brain.action_delay_mult)


/obj/item/stack/medical/advanced/bruise_pack/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	if(issynth(target))
		return FALSE

	for(var/obj/limb/limb as anything in target.limbs)
		if(locate(/datum/effects/bleeding/external) in limb.bleeding_effects_list)
			return TRUE

		for(var/datum/wound/wound in limb.wounds)
			if(wound.internal || wound.damage_type == BURN)
				continue

			if(!(wound.bandaged & (WOUND_BANDAGED|WOUND_SUTURED)))
				return TRUE
	return FALSE

/obj/item/stack/medical/advanced/bruise_pack/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	for(var/obj/limb/limb as anything in target.limbs)
		if(QDELETED(src))
			return

		if(locate(/datum/effects/bleeding/external) in limb.bleeding_effects_list)
			user.zone_selected = limb.name
			attack(target, user)
			sleep(ai_brain.short_action_delay)
			continue

		for(var/datum/wound/wound in limb.wounds)
			if(wound.internal || wound.damage_type == BURN)
				continue

			if(QDELETED(src))
				return

			if(!(wound.bandaged & (WOUND_BANDAGED|WOUND_SUTURED)))
				user.zone_selected = limb.name
				attack(target, user)
				sleep(ai_brain.short_action_delay)


// Medical purposes for synths
/obj/item/tool/weldingtool/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	if(!issynth(target) || (get_fuel() <= 0))
		return FALSE

	for(var/obj/limb/limb as anything in target.limbs)
		for(var/datum/wound/wound in limb.wounds)
			if(wound.internal || (wound.damage_type == BURN))
				continue

			return TRUE

	return FALSE

/obj/item/tool/weldingtool/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	user.a_intent_change(INTENT_HELP)
	if(!welding)
		toggle(FALSE)

	for(var/obj/limb/limb as anything in target.limbs)
		if(QDELETED(src))
			return

		for(var/datum/wound/wound in limb.wounds)
			if(wound.internal || (wound.damage_type == BURN))
				continue

			if(QDELETED(src))
				return

			user.zone_selected = limb.name
			attack(target, user)
			sleep(ai_brain.short_action_delay * ai_brain.action_delay_mult)

	if(welding)
		toggle(FALSE)


/obj/item/storage/pill_bottle/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	if(issynth(target))
		return FALSE

	if(!length(contents) || !COOLDOWN_FINISHED(ai_brain, pill_use_cooldown))
		return FALSE

	var/obj/item/reagent_container/pill/pill = contents[1]
	var/datum/reagent/reagent_datum = GLOB.chemical_reagents_list[pill.pill_initial_reagents[1]]

	if((target.reagents.get_reagent_amount(reagent_datum.id) + pill.reagents.total_volume) > reagent_datum.overdose)
		return FALSE

	if(skilllock && !skillcheck(user, SKILL_MEDICAL, SKILL_MEDICAL_MEDIC))
		return FALSE

	return TRUE

/obj/item/storage/pill_bottle/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	var/obj/item/pill = contents[1]
	user.swap_hand()
	if(user.put_in_active_hand(pill))
		remove_from_storage(pill, user)
		pill.attack(target, user)
		COOLDOWN_START(ai_brain, pill_use_cooldown, 5 SECONDS)
		sleep(ai_brain.medium_action_delay * ai_brain.action_delay_mult)

	ai_brain.appraise_inventory() // For some reason it removes pill bottles from equipment_map after usage

/obj/item/stack/nanopaste/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	if(!issynth(target))
		return FALSE

	for(var/obj/limb/limb as anything in target.limbs)
		for(var/datum/wound/wound in limb.wounds)
			if(wound.internal)
				continue

			return TRUE

	return FALSE

/obj/item/stack/nanopaste/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	for(var/obj/limb/limb as anything in target.limbs)
		if(QDELETED(src))
			return

		for(var/datum/wound/wound in limb.wounds)
			if(wound.internal)
				continue

			if(QDELETED(src))
				return

			user.zone_selected = limb.name
			attack(target, user)
			sleep(ai_brain.short_action_delay * ai_brain.action_delay_mult)


/obj/item/stack/medical/splint/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	for(var/obj/limb/limb as anything in target.limbs)
		if(QDELETED(src))
			return

		if(limb.is_broken())
			user.zone_selected = limb.name
			attack(target, user)
			sleep(ai_brain.short_action_delay)
			continue

/obj/item/stack/medical/advanced/ointment/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	if(issynth(target))
		return FALSE

	for(var/obj/limb/limb as anything in target.limbs)
		for(var/datum/wound/wound in limb.wounds)
			if(wound.internal || wound.damage_type == BRUTE)
				continue

			if(!(wound.bandaged & (WOUND_BANDAGED|WOUND_SUTURED)))
				return TRUE
	return FALSE

/obj/item/stack/medical/advanced/ointment/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	for(var/obj/limb/limb as anything in target.limbs)
		for(var/datum/wound/wound in limb.wounds)
			if(wound.internal || wound.damage_type == BRUTE)
				continue

			if(QDELETED(src))
				return

			if(!(wound.bandaged & (WOUND_BANDAGED|WOUND_SUTURED)))
				user.zone_selected = limb.name
				attack(target, user)
				sleep(ai_brain.short_action_delay)

/obj/item/stack/medical/bruise_pack/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	for(var/obj/limb/limb as anything in target.limbs)
		if(QDELETED(src))
			return

		if(locate(/datum/effects/bleeding/external) in limb.bleeding_effects_list)
			user.zone_selected = limb.name
			attack(target, user)
			sleep(ai_brain.short_action_delay)
