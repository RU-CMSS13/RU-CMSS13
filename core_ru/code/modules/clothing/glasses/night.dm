/obj/item/clothing/glasses/night/m56_goggles
	actions_types = list(/datum/action/item_action/toggle, /datum/action/item_action/m56_goggles/far_sight)

/obj/item/clothing/glasses/night/m46c
	name = "\improper M46C Battle headset goggle"
	gender = NEUTER
	desc = "A headset and thermal-night vision goggles system for commanding officer. Allows highlighted imaging of surroundings, as well as the ability to view the suit sensor health status readouts of other marines. Click it to toggle."
	icon_state = "m4ra_goggles"
	deactive_state = "m4ra_goggles_0"
	vision_flags = SEE_TURFS
	hud_type = MOB_HUD_MEDICAL_ADVANCED
	toggleable = TRUE
	fullscreen_vision = null
	actions_types = list(/datum/action/item_action/toggle)
	flags_item = MOB_LOCK_ON_EQUIP|NO_CRYO_STORE
	req_skill = SKILL_EXECUTION
	req_skill_level = SKILL_EXECUTION_TRAINED

	var/far_sight = FALSE
	actions_types = list(/datum/action/item_action/toggle, /datum/action/item_action/m46c/far_sight)

/obj/item/clothing/glasses/night/m46c/Destroy()
	disable_far_sight()
	return ..()

/obj/item/clothing/glasses/night/m46c/equipped(mob/user, slot)
	if(slot != SLOT_EYES)
		disable_far_sight(user)
	return ..()

/obj/item/clothing/glasses/night/m46c/dropped(mob/living/carbon/human/user)
	disable_far_sight(user)
	return ..()

/obj/item/clothing/glasses/night/m46c/proc/set_far_sight(mob/living/carbon/human/user, set_to_state = TRUE)
	if(set_to_state)
		if(user.glasses != src)
			to_chat(user, SPAN_WARNING("You can't activate far sight without wearing \the [src]!"))
			return
		far_sight = TRUE
		if(user)
			if(user.client)
				user.client.change_view(9, src)
		START_PROCESSING(SSobj, src)
	else
		far_sight = FALSE
		if(user)
			if(user.client)
				user.client.change_view(GLOB.world_view_size, src)
		STOP_PROCESSING(SSobj, src)

	var/datum/action/item_action/m46c/far_sight/FT = locate(/datum/action/item_action/m46c/far_sight) in actions
	if(FT)
		FT.update_button_icon()

/obj/item/clothing/glasses/night/m46c/proc/disable_far_sight(mob/living/carbon/human/user)
	if(!istype(user))
		user = loc
		if(!istype(user))
			user = null
	set_far_sight(user, FALSE)

/datum/action/item_action/m46c/far_sight/New()
	. = ..()
	name = "Toggle Far Sight"
	action_icon_state = "far_sight"
	button.name = name
	button.overlays.Cut()
	button.overlays += image('icons/mob/hud/actions.dmi', button, action_icon_state)

/datum/action/item_action/m46c/far_sight/action_activate()
	. = ..()
	if(target)
		var/obj/item/clothing/glasses/night/m46c/G = target
		G.set_far_sight(owner, !G.far_sight)
		to_chat(owner, SPAN_NOTICE("You [G.far_sight ? "enable" : "disable"] \the [G]'s far sight system."))

/datum/action/item_action/m46c/far_sight/update_button_icon()
	if(!target)
		return
	var/obj/item/clothing/glasses/night/m46c/G = target
	if(G.far_sight)
		button.icon_state = "template_on"
	else
		button.icon_state = "template"
