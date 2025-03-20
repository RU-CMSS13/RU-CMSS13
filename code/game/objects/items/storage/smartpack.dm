#define BACKPACK_LIGHT_LEVEL 6

/obj/item/storage/backpack/marine/smartpack
	name = "\improper S-V42  backpack"
	desc = "A joint project between the USCM and Weyland-Yutani. It is said to be top-class engineering and state of the art technology with a built in shoulder-lamp."
	item_state = "smartpack"
	icon_state = "smartpack"
	icon = 'icons/obj/items/clothing/backpack/smartpack.dmi'
	item_icons = list(
		WEAR_BACK = 'icons/mob/humans/onmob/clothing/back/smartpack.dmi'
	)
	flags_atom = FPRINT|NO_GAMEMODE_SKIN // same sprite for all gamemodes
	max_storage_space = 14
	worn_accessible = TRUE
	actions_types = list(/datum/action/item_action/toggle)
	xeno_types = null

/obj/item/storage/backpack/marine/smartpack/Initialize()
	. = ..()
	update_icon()

/obj/item/storage/backpack/marine/smartpack/update_icon(mob/user)
	overlays.Cut()

	if(light_on)
		overlays += "+lamp_on"
	else
		overlays += "+lamp_off"

	if(user)
		user.update_inv_back()

	for(var/datum/action/backpack_actions in actions)
		backpack_actions.update_button_icon()

	if(issynth(user))
		var/mob/living/living_mob = user
		for(var/datum/action/living_mob_actions in living_mob.actions)
			living_mob_actions.update_button_icon()

	if(content_watchers) //If someone's looking inside it, don't close the flap.
		return

	var/sum_storage_cost = 0
	for(var/obj/item/items_in_bag in contents)
		sum_storage_cost += items_in_bag.get_storage_cost()
	if(!sum_storage_cost)
		return
	else if(sum_storage_cost <= max_storage_space * 0.5)
		overlays += "+[icon_state]_half"
	else
		overlays += "+[icon_state]_full"

/obj/item/storage/backpack/marine/smartpack/get_mob_overlay(mob/user_mob, slot, default_bodytype = "Default")
	var/image/ret = ..()

	var/light = "+lamp_on"
	if(!light_on)
		light = "+lamp_off"

	var/image/lamp = overlay_image('icons/mob/humans/onmob/clothing/back/smartpack.dmi', light, color, RESET_COLOR)
	ret.overlays += lamp

	return ret

/obj/item/storage/backpack/marine/smartpack/attack_self(mob/user)
	..()

	if(!isturf(user.loc) || !ishuman(user))
		return

	var/mob/living/carbon/human/H = user
	if(H.back != src)
		return

	turn_light(user, toggle_on = !light_on)
	return TRUE

/obj/item/storage/backpack/marine/smartpack/turn_light(mob/user, toggle_on, cooldown, sparks, forced, light_again)
	. = ..()
	if(. != CHECKS_PASSED)
		return

	if(toggle_on)
		set_light_range(BACKPACK_LIGHT_LEVEL)
		set_light_on(TRUE)
	else
		set_light_on(FALSE)
		playsound(src, 'sound/handling/click_2.ogg', 50, TRUE)

	playsound(src, 'sound/handling/light_on_1.ogg', 50, TRUE)
	update_icon(user)

/obj/item/storage/backpack/marine/smartpack/dropped(mob/living/synthetic)

	if(battery_charge < PROTECTIVE_COST)
		to_chat(user, SPAN_DANGER("There is a lack of charge for that action. Charge: [battery_charge]/[PROTECTIVE_COST]"))
		return

	activated_form = TRUE
	flags_item |= NODROP
	flags_inventory |= CANTSTRIP
	LAZYSET(user.brute_mod_override, src, 0.2)
	LAZYSET(user.burn_mod_override, src, 0.2)
	saved_melee_allowed = user.melee_allowed
	saved_gun_allowed = user.allow_gun_usage
	saved_throw_allowed = user.throw_allowed
	user.melee_allowed = FALSE
	user.allow_gun_usage = FALSE
	user.throw_allowed = FALSE
	to_chat(user, SPAN_DANGER("[name] beeps, \"You are now protected, but unable to attack.\""))
	battery_charge -= PROTECTIVE_COST
	playsound(loc, 'sound/mecha/mechmove04.ogg', 25, TRUE)
	to_chat(user, SPAN_INFO("The current charge reads [battery_charge]/[SMARTPACK_MAX_POWER_STORED]"))
	update_icon(user)

	var/filter_color = PROTECTIVE_FORM_COLOR
	var/filter_size = EXOSKELETON_OFF_FILTER_SIZE
	if(show_exoskeleton)
		filter_size = EXOSKELETON_ON_FILTER_SIZE
	user.add_filter("synth_protective_form", priority = 1, params = list("type" = "outline", "color" = filter_color, "size" = filter_size))

	addtimer(CALLBACK(src, PROC_REF(protective_form_cooldown), user), protective_form_cooldown)

/obj/item/storage/backpack/marine/smartpack/proc/protective_form_cooldown(mob/living/carbon/human/user)
	activated_form = FALSE
	flags_item &= ~NODROP
	flags_inventory &= ~CANTSTRIP
	user.melee_allowed = saved_melee_allowed
	user.throw_allowed = saved_throw_allowed
	user.allow_gun_usage = saved_gun_allowed
	LAZYREMOVE(user.brute_mod_override, src)
	LAZYREMOVE(user.burn_mod_override, src)
	to_chat(user, SPAN_DANGER("[name] beeps, \"The protection wears off.\""))
	playsound(loc, 'sound/mecha/mechmove04.ogg', 25, TRUE)
	update_icon(user)
	user.remove_filter("synth_protective_form")


/obj/item/storage/backpack/marine/smartpack/proc/immobile_form(mob/living/user)
	if(activated_form)
		return

	if(battery_charge < IMMOBILE_COST && !immobile_form)
		to_chat(user, SPAN_DANGER("There is a lack of charge for that action. Charge: [battery_charge]/[IMMOBILE_COST]"))
		return

	immobile_form = !immobile_form
	if(immobile_form)
		battery_charge -= IMMOBILE_COST
		user.status_flags &= ~CANPUSH
		user.anchored = TRUE
		ADD_TRAIT(user, TRAIT_IMMOBILIZED, TRAIT_SOURCE_EQUIPMENT(WEAR_BACK))
		to_chat(user, SPAN_DANGER("[name] beeps, \"You are anchored in place and cannot be moved.\""))
		to_chat(user, SPAN_INFO("The current charge reads [battery_charge]/[SMARTPACK_MAX_POWER_STORED]"))

		var/filter_color = IMMOBILE_FORM_COLOR
		var/filter_size = EXOSKELETON_OFF_FILTER_SIZE
		if(show_exoskeleton)
			filter_size = EXOSKELETON_ON_FILTER_SIZE
		user.add_filter("synth_immobile_form", priority = 1, params = list("type" = "outline", "color" = filter_color, "size" = filter_size))
	else
		user.status_flags |= CANPUSH
		user.anchored = FALSE
		REMOVE_TRAIT(user, TRAIT_IMMOBILIZED, TRAIT_SOURCE_EQUIPMENT(WEAR_BACK))
		to_chat(user, SPAN_DANGER("[name] beeps, \"You can now move again.\""))
		user.remove_filter("synth_immobile_form")

	playsound(loc, 'sound/mecha/mechmove04.ogg', 25, TRUE)
	update_icon(user)
	activated_form = TRUE

	addtimer(CALLBACK(src, PROC_REF(immobile_form_cooldown), user), immobile_form_cooldown)

/obj/item/storage/backpack/marine/smartpack/proc/immobile_form_cooldown(mob/user)
	activated_form = FALSE


/obj/item/storage/backpack/marine/smartpack/proc/repair_form(mob/user)
	if(!ishuman(user) || activated_form || repairing)
		return

	if(battery_charge < REPAIR_COST)
		to_chat(user, SPAN_DANGER("There is a lack of charge for that action. Charge: [battery_charge]/[REPAIR_COST]"))
		return

	var/mob/living/carbon/human/H = user

	if(H.getBruteLoss() <= 0 && H.getFireLoss() <= 0)
		to_chat(user, SPAN_DANGER("[name] beeps, \"No noticeable damage. Procedure cancelled.\""))
		return

	repair_form = TRUE
	repairing = TRUE
	update_icon(user)

	H.visible_message(SPAN_WARNING("[name] beeps, \"Engaging the repairing process.\""), \
		SPAN_WARNING("[name] beeps, \"Beginning to carefully examine your sustained damage.\""))
	playsound(loc, 'sound/mecha/mechmove04.ogg', 25, TRUE)
	if(!do_after(H, 100, INTERRUPT_ALL, BUSY_ICON_FRIENDLY))
		repair_form = FALSE
		repairing = FALSE
		update_icon(user)
		to_chat(user, SPAN_DANGER("[name] beeps, \"Repair process was cancelled.\""))
		return

	playsound(loc, 'sound/items/Welder2.ogg', 25, TRUE)
	battery_charge -= REPAIR_COST
	H.heal_overall_damage(50, 50, TRUE)
	H.pain.recalculate_pain()
	repair_form = FALSE
	update_icon(user)
	to_chat(user, SPAN_INFO("The current charge reads [battery_charge]/[SMARTPACK_MAX_POWER_STORED]"))
	H.visible_message(SPAN_DANGER("[name] beeps, \"Completed the repairing process. Charge now reads [battery_charge]/[SMARTPACK_MAX_POWER_STORED].\""))

	addtimer(CALLBACK(src, PROC_REF(repair_form_cooldown), user), repair_form_cooldown)

/obj/item/storage/backpack/marine/smartpack/proc/repair_form_cooldown(mob/user)
	repairing = FALSE
	update_icon(user)


/obj/item/storage/backpack/marine/smartpack/green
	item_state = "g_smartpack"
	icon_state = "g_smartpack"

/obj/item/storage/backpack/marine/smartpack/tan
	item_state = "t_smartpack"
	icon_state = "t_smartpack"

/obj/item/storage/backpack/marine/smartpack/black
	item_state = "b_smartpack"
	icon_state = "b_smartpack"

/obj/item/storage/backpack/marine/smartpack/white
	item_state = "w_smartpack"
	icon_state = "w_smartpack"

/obj/item/storage/backpack/marine/smartpack/a1
	name = "\improper S-V42A1  backpack"
	desc = "A revised joint project between the USCM and Weyland-Yutani. It is said to be top-class engineering and state of the art technology with a built in shoulder-lamp."
	item_state = "smartpack_a1"
	icon_state = "smartpack_a1"

/obj/item/storage/backpack/marine/smartpack/a1/green
	item_state = "g_smartpack_a1"
	icon_state = "g_smartpack_a1"

/obj/item/storage/backpack/marine/smartpack/a1/tan
	item_state = "t_smartpack_a1"
	icon_state = "t_smartpack_a1"

/obj/item/storage/backpack/marine/smartpack/a1/black
	item_state = "b_smartpack_a1"
	icon_state = "b_smartpack_a1"

/obj/item/storage/backpack/marine/smartpack/a1/white
	item_state = "w_smartpack_a1"
	icon_state = "w_smartpack_a1"

#undef BACKPACK_LIGHT_LEVEL

