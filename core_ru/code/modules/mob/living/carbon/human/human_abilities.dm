/datum/action/human_action/m40/action_cooldown_check()
	var/mob/living/carbon/human/H = owner
	if(istype(H.wear_suit, /obj/item/clothing/suit/storage/marine/m40))
		var/obj/item/clothing/suit/storage/marine/m40/M = H.wear_suit
		return cooldown_check(M)
	else
		return FALSE

/datum/action/human_action/m40/action_activate()
	if(!istype(owner, /mob/living/carbon/human))
		return
	var/mob/living/carbon/human/H = owner
	if(istype(H.wear_suit, /obj/item/clothing/suit/storage/marine/m40))
		var/obj/item/clothing/suit/storage/marine/m40/M = H.wear_suit
		form_call(M, H)

/datum/action/human_action/m40/give_to(mob/living/L)
	..()
	if(!ishuman(L))
		return
	var/mob/living/carbon/human/H = L
	if(istype(H.wear_suit, /obj/item/clothing/suit/storage/marine/m40))
		var/obj/item/clothing/suit/storage/marine/m40/M = H.wear_suit
		cooldown = set_cooldown(M)
	else
		return

/datum/action/human_action/m40/proc/form_call(obj/item/clothing/suit/storage/marine/m40/M, mob/living/carbon/human/H)
	return

/datum/action/human_action/m40/proc/set_cooldown(obj/item/clothing/suit/storage/marine/m40/M)
	return

/datum/action/human_action/m40/proc/cooldown_check(obj/item/clothing/suit/storage/marine/m40/M)
	return M.st_activated_form

/datum/action/human_action/m40/enrage_form
	name = "Enrage Form"
	action_icon_state = "smartpack_protect"

/datum/action/human_action/m40/enrage_form/set_cooldown(obj/item/clothing/suit/storage/marine/m40/M)
	return M.enrage_form_cooldown

/datum/action/human_action/m40/enrage_form/form_call(obj/item/clothing/suit/storage/marine/m40/M, mob/living/carbon/human/H)
	M.enrage_form(H)
