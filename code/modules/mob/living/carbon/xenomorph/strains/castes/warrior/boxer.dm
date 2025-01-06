/datum/xeno_strain/boxer
	name = WARRIOR_BOXER
	description = "In exchange for your ability to fling and shield yourself with slashes, you gain KO meter and the ability to resist stuns. Your punches will reset the cooldown of your Jab. Jab lets you close in and confuse your opponents while resetting Punch cooldown. Your slashes and abilities build up KO meter that later lets you deal damage, knockback, heal, and restore your stun resistance depending on how much KO meter you gained with a titanic Uppercut strike."
	flavor_description = "You will play box around."
	icon_state_prefix = "Boxer"

	actions_to_remove = list(
		/datum/action/xeno_action/activable/fling,
		/datum/action/xeno_action/activable/lunge,
	)
	actions_to_add = list(
		/datum/action/xeno_action/activable/jab,
		/datum/action/xeno_action/activable/uppercut,
	)
	behavior_delegate_type = /datum/behavior_delegate/boxer

/datum/xeno_strain/boxer/apply_strain(mob/living/carbon/xenomorph/warrior/warrior)
	warrior.health_modifier += XENO_HEALTH_MOD_MED
	warrior.armor_modifier += XENO_ARMOR_MOD_VERY_SMALL
	warrior.agility = FALSE
	warrior.recalculate_everything()
