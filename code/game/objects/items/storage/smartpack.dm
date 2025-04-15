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
	max_storage_space = 15
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

/obj/item/storage/backpack/marine/smartpack/pickup(var/mob/living/M)
	if(isSynth(M))
		for(var/action_type in subtypesof(/datum/action/human_action/smartpack))
			if(locate(action_type) in M.actions)
				continue

			give_action(M, action_type)
	else
		to_chat(M, SPAN_DANGER("[name] beeps, \"Unathorized user!\""))

	if(light_state && loc != M)
		M.SetLuminosity(BACKPACK_LIGHT_LEVEL, FALSE, src)
		SetLuminosity(0)
	..()

/obj/item/storage/backpack/marine/smartpack/equipped(mob/user, slot)
	. = ..()
	if(slot == WEAR_BACK)
		RegisterSignal(user, COMSIG_MOB_APC_ATTACK_HAND, .proc/handle_apc_charge)

/obj/item/storage/backpack/marine/smartpack/dropped(var/mob/living/M)
	UnregisterSignal(M, COMSIG_MOB_APC_ATTACK_HAND)

	for(var/datum/action/human_action/smartpack/S in M.actions)
		S.remove_from(M)

	if(light_state && loc != M)
		toggle_light(M)

	if(immobile_form)
		immobile_form = FALSE
		M.status_flags |= CANPUSH
		M.anchored = FALSE
		M.unfreeze()

	return ..()

/obj/item/storage/backpack/marine/smartpack/proc/handle_apc_charge(var/mob/living/carbon/human/user, var/obj/structure/machinery/power/apc/apc)
	SIGNAL_HANDLER

	if(!istype(user))
		return FALSE

	if(!(user.species.flags & IS_SYNTHETIC) || user.a_intent != INTENT_GRAB)
		return FALSE

	if(user.action_busy)
		return FALSE

	INVOKE_ASYNC(src, .proc/complete_apc_charge, user, apc)

	return COMPONENT_APC_HANDLED_HAND

/obj/item/storage/backpack/marine/smartpack/proc/complete_apc_charge(var/mob/living/carbon/human/user, var/obj/structure/machinery/power/apc/apc)
	if(!do_after(user, 2 SECONDS, INTERRUPT_ALL, BUSY_ICON_GENERIC))
		return

	playsound(apc.loc, 'sound/effects/sparks2.ogg', 25, 1)

	if(apc.stat & BROKEN)
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(3, 1, apc)
		s.start()
		to_chat(user, SPAN_DANGER("The APC's power currents surge eratically, damaging your chassis!"))
		user.apply_damage(10, 0, BURN)
	else if(apc.cell?.charge > 0)
		if(battery_charge < initial(battery_charge))
			var/charge_to_use = min(apc.cell.charge, initial(battery_charge) - battery_charge)
			if(!(apc.cell.use(charge_to_use)))
				return
			battery_charge += charge_to_use
			to_chat(user, SPAN_NOTICE("You slot your fingers into the APC interface and siphon off some of the stored charge. \The [src] now has <b>[battery_charge]/[initial(battery_charge)]</b>."))
			apc.charging = 1
		else
			to_chat(user, SPAN_WARNING("\The [src] is already fully charged."))
	else
		to_chat(user, SPAN_WARNING("There is no charge to draw from that APC."))

/obj/item/storage/backpack/marine/smartpack/Destroy()
	if(ismob(loc))
		loc.SetLuminosity(0, FALSE, src)
	else
		SetLuminosity(0)
	. = ..()

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

	if(light_on && loc != synthetic)
		turn_light(synthetic, toggle_on = FALSE)
	..()


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
