/mob/living/carbon/xenomorph/queen/pull_response(mob/puller)
	if(stat == DEAD)
		return TRUE
	if(legcuffed)
		return TRUE
	if(has_species(puller,"Human")) // If the Xeno is alive, fight back against a grab/pull
		playsound(puller.loc, 'sound/weapons/pierce.ogg', 25, 1)
		puller.visible_message(SPAN_WARNING("[puller] tried to pull [src] but instead gets a tail swipe to the head!"))
		puller.apply_effect(rand(caste.tacklestrength_min,caste.tacklestrength_max), WEAKEN)
		return FALSE
	if((!ckey) && (!aghosted)) // Should be triggered by xeno or animal species
		return TRUE
	if(health > 0) // Should be triggered by xeno or animal species
		puller.visible_message(SPAN_WARNING("[puller] tried to pull [src] but was rejected!"))
		return FALSE
	return TRUE
