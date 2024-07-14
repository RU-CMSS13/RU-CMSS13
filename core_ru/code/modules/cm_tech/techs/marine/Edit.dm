/datum/action/xeno_action/onclick/techtree
	name = "Древо технологий"
	icon_file = 'icons/effects/techtree/tech.dmi'
	action_icon_state = "upgrade"
	ability_name = "techtree"
	macro_path = /datum/action/xeno_action/verb/verb_techtree
	action_type = XENO_ACTION_CLICK


/datum/action/xeno_action/verb/verb_techtree()
	set category = "Alien"
	set name = "Древо технологий"
	set hidden = TRUE
	var/action_name = "Древо технологий"
	handle_xeno_macro(src, action_name)

/datum/action/xeno_action/onclick/techtree/use_ability()
	var/datum/techtree/T = GET_TREE(TREE_XENO)
	T.enter_mob(owner)

/datum/tech/nuke
	icon = 'core_ru/icons/effects/techtree/tech.dmi'
	icon_state = "nuke"

/datum/tech/repeatable/ob/he
	icon = 'core_ru/icons/effects/techtree/tech.dmi'
	icon_state = "ob_he"

/datum/tech/repeatable/ob/cluster
	icon = 'core_ru/icons/effects/techtree/tech.dmi'
	icon_state = "ob_cluster"

/datum/tech/repeatable/ob/incend
	icon = 'core_ru/icons/effects/techtree/tech.dmi'
	icon_state = "ob_incend"
