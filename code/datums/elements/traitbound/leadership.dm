/datum/element/traitbound/leadership
	associated_trait = TRAIT_LEADERSHIP
	compatible_types = list(/mob/living/carbon/human)

/* CM Original
/datum/element/traitbound/leadership/Attach(datum/target)
	. = ..()
	if(. & ELEMENT_INCOMPATIBLE)
		return
	for(var/action_type in subtypesof(/datum/action/human_action/issue_order))
		give_action(target, action_type)

/datum/element/traitbound/leadership/Detach(datum/target)
	var/mob/living/carbon/human/H = target
	for(var/datum/action/human_action/issue_order/O in H.actions)
		O.remove_from(H)
	return ..()
*/

// RUCM Start (Feline "Бегающие флаги")
/datum/element/traitbound/leadership/Attach(datum/target)
	. = ..()
	if(. & ELEMENT_INCOMPATIBLE)
		return
	give_action(target, /datum/action/human_action/issue_order_feline)

/datum/element/traitbound/leadership/Detach(datum/target)
	var/mob/living/carbon/human/H = target
	for(var/datum/action/human_action/issue_order_feline/O in H.actions)
		O.remove_from(H)
	return ..()
// RUCM End (Feline "Бегающие флаги")
