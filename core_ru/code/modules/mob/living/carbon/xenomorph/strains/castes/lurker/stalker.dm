/datum/xeno_strain/stalker
	name = "Stalker"
	description = "You lose your ability to slowing hosts, but you gain ability to be invisible when you stalk."
	flavor_description = "I T   W A N T   E A T . . ."
	icon_state_prefix = "Stalker"

	actions_to_remove = list(
		/datum/action/xeno_action/activable/pounce/lurker,
		/datum/action/xeno_action/onclick/lurker_invisibility,
		/datum/action/xeno_action/onclick/lurker_assassinate,
	)
	actions_to_add = list(
		/datum/action/xeno_action/activable/pounce/lurker/stalker,
	)
	behavior_delegate_type = /datum/behavior_delegate/lurker_stalker

/datum/xeno_strain/stalker/apply_strain(mob/living/carbon/xenomorph/lurker/lurker)
	lurker.walk_speed = DEFAULT_WALK_SPEED - 2
	lurker.health_modifier += XENO_HEALTH_MOD_SMALL
	lurker.speed_modifier += XENO_SPEED_FASTMOD_TIER_1

	lurker.recalculate_everything()
	lurker.set_movement_intent(lurker.m_intent) // lazy but it works

/datum/behavior_delegate/lurker_stalker
	name = "Stalker Lurker Behavior Delegate"

/datum/behavior_delegate/lurker_stalker/handle_movement_change(new_movement_intent)
	. = ..()
	animate(bound_xeno, alpha = new_movement_intent > MOVE_INTENT_WALK ? initial(bound_xeno.alpha) : 25, time = 1 SECONDS, easing = QUAD_EASING)

/datum/action/xeno_action/activable/pounce/lurker/stalker/knockdown = TRUE

/datum/action/xeno_action/activable/pounce/lurker/stalker/knockdown_duration = 1.6

/mob/living/carbon/xenomorph/lurker
	icon_xeno = 'core_ru/icons/mob/xenos/lurker.dmi'
