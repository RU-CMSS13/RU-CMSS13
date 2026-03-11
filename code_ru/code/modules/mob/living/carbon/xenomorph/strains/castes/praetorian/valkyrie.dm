/datum/xeno_strain/valkyrie/apply_strain(mob/living/carbon/xenomorph/praetorian/prae)
	prae.speed_modifier += XENO_SPEED_SLOWMOD_TIER_5
	prae.claw_type = CLAW_TYPE_VERY_SHARP
	prae.recalculate_everything()
