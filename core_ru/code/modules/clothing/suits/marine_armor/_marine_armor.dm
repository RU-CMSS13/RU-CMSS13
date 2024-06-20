#define ENRAGE_FORM_COLOR "#be020265"

/obj/item/clothing/suit/storage/marine/m40
	name = "\improper M40 armor"
	desc = "A custom set of M40 armor designed for use by USCM stormtrooper. Contains thick kevlar shielding."
	item_icons = list(WEAR_JACKET = 'core_ru/icons/mob/human/onmob/suit_1.dmi')
	icon = 'core_ru/icons/obj/items/clothing/cm_suits.dmi'
	icon_state = "st_armor"
	armor_melee = CLOTHING_ARMOR_HIGH
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROT
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS|BODY_FLAG_FEET
	flags_cold_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS|BODY_FLAG_FEET
	flags_heat_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS|BODY_FLAG_FEET
	flags_item = MOB_LOCK_ON_EQUIP|NO_CRYO_STORE
	specialty = "M40 stormtrooper"
	actions_types = list(/datum/action/item_action/toggle)
	unacidable = TRUE

	var/enrage_form_cooldown = 1200
	var/enrage_form_duration = 160
	var/st_activated_form = FALSE

/obj/item/clothing/suit/storage/marine/m40/Initialize()
	. = ..()
	update_icon()

/obj/item/clothing/suit/storage/marine/m40/pickup(mob/living/H)
	for(var/action_type in subtypesof(/datum/action/human_action/m40))
		if(locate(action_type) in H.actions)
			continue

		give_action(H, action_type)

	..()

/obj/item/clothing/suit/storage/marine/m40/dropped(mob/living/H)
	for(var/datum/action/human_action/m40/M in H.actions)
		M.remove_from(H)

	..()

/obj/item/clothing/suit/storage/marine/m40/proc/enrage_form(mob/living/carbon/human/user)

	st_activated_form = TRUE
	flags_item |= NODROP
	flags_inventory |= CANTSTRIP
	LAZYSET(user.brute_mod_override, src, 0.6)
	user.speed = 0.55
	user.status_flags &= ~CANPUSH
	user.status_flags &= ~CANKNOCKOUT
	user.pain.feels_pain = FALSE
	user.pain.current_pain = 0
	to_chat(user, SPAN_DANGER("[name] beeps, \"You feel adrenaline rush in your blood.\""))
	playsound(loc, 'sound/items/hypospray.ogg', 25, TRUE)
	addtimer(CALLBACK(src, PROC_REF(enrage_form_duration), user), enrage_form_duration)
	addtimer(CALLBACK(src, PROC_REF(enrage_form_cooldown), user), enrage_form_cooldown)
	user.add_filter("enrage_form", priority = 1, params = list("type" = "outline", "color" = ENRAGE_FORM_COLOR, "size" = 0.5))

/obj/item/clothing/suit/storage/marine/m40/proc/enrage_form_duration(mob/living/carbon/human/user)

	flags_item &= ~NODROP
	flags_inventory &= ~CANTSTRIP
	user.speed = 0
	user.status_flags |= CANPUSH
	user.status_flags |= CANKNOCKOUT
	user.pain.feels_pain = TRUE
	LAZYREMOVE(user.brute_mod_override, src)
	to_chat(user, SPAN_DANGER("[name] beeps, \"Protective dialysis has been activated.\""))
	playsound(loc, 'core_ru/sound/effects/hearth_attack.ogg', 25, TRUE)
	user.remove_filter("enrage_form")

/obj/item/clothing/suit/storage/marine/m40/proc/enrage_form_cooldown(mob/living/carbon/human/user)
	st_activated_form = FALSE

#undef ENRAGE_FORM_COLOR
