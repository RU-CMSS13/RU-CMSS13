/obj/item/weapon/twohanded/breacher_hammer
	name = "\improper N45 battle hammer"
	desc = "Heavy hammer with an ergonomic handle and reinforced striking surface."
	icon = 'code_ru/icons/obj/items/weapons/weapons.dmi'
	icon_state = "breacher_hammer"
	item_state = "breacher_hammer"
	item_icons = list(
		WEAR_J_STORE = 'code_ru/icons/mob/humans/onmob/suit_slot.dmi',
		WEAR_WAIST = 'code_ru/icons/mob/humans/onmob/belt.dmi',
		WEAR_L_HAND = 'code_ru/icons/mob/humans/onmob/items_lefthand_0.dmi',
		WEAR_R_HAND = 'code_ru/icons/mob/humans/onmob/items_righthand_0.dmi'
	)
	pickup_sound = "gunequip"
	hitsound = "code_ru/sound/weapon/hammer_swing.ogg"
	force = MELEE_FORCE_STRONG
	flags_item = TWOHANDED
	force_wielded = MELEE_FORCE_TIER_8
	throwforce = MELEE_FORCE_NORMAL
	w_class = SIZE_LARGE
	sharp = IS_SHARP_ITEM_BIG
	flags_equip_slot = SLOT_SUIT_STORE|SLOT_WAIST
	unacidable = TRUE
	explo_proof = TRUE

	throw_range = 3
	attack_speed = 12

	var/speed_penalty = 0.85 // 15%

/obj/item/weapon/twohanded/breacher_hammer/attack(mob/target, mob/user)
	if(!skillcheck(user, SKILL_SPEC_WEAPONS, SKILL_SPEC_ALL) && user.skills.get_skill_level(SKILL_SPEC_WEAPONS) != SKILL_SPEC_BREACHER)
		to_chat(user, SPAN_HIGHDANGER("[src] is too heavy for you to use!"))
		return

	. = ..()

	if(!isxeno(target))
		return

	if(flags_item & WIELDED)
		var/datum/effects/hammer_stacks/hammer_effect = locate() in target.effects_list
		if(!hammer_effect)
			hammer_effect = new /datum/effects/hammer_stacks(target)

		hammer_effect.increment_stack_count(1, user)
		if(target.stat != CONSCIOUS) // haha xeno-cricket
			hammer_effect.increment_stack_count(4, user)

/obj/item/weapon/twohanded/breacher_hammer/pickup(mob/user)
	RegisterSignal(user, COMSIG_HUMAN_POST_MOVE_DELAY, PROC_REF(handle_movedelay))
	. = ..()

/obj/item/weapon/twohanded/breacher_hammer/proc/handle_movedelay(mob/user, list/movedata)
	SIGNAL_HANDLER
	movedata["move_delay"] += speed_penalty

/obj/item/weapon/twohanded/breacher_hammer/dropped(mob/user, silent)
	. = ..()
	UnregisterSignal(user, COMSIG_HUMAN_POST_MOVE_DELAY)

/obj/item/weapon/shield/montage
	name = "N30 montage shield"
	desc = "A shield adept at blocking blunt objects from connecting with the torso of the shield wielder."
	icon = 'code_ru/icons/obj/items/breacher_spec.dmi'
	icon_state = "metal_st"
	item_icons = list(
		WEAR_L_HAND = 'code_ru/icons/mob/humans/onmob/items_lefthand_1.dmi',
		WEAR_R_HAND = 'code_ru/icons/mob/humans/onmob/items_righthand_1.dmi',
		WEAR_BACK = 'code_ru/icons/mob/humans/onmob/back.dmi'
		)
	attack_verb = list("shoved", "bashed")
	pickup_sound = "gunequip"
	passive_block = 70
	readied_block = 100
	throw_range = 4
	flags_equip_slot = SLOT_BACK
	force = MELEE_FORCE_TIER_1
	throwforce = MELEE_FORCE_TIER_1
	w_class = SIZE_LARGE
	unacidable = TRUE
	explo_proof = TRUE
	blocks_on_back = TRUE
	var/auto_retrieval_slot = WEAR_BACK
	var/cooldown = 0	//shield bash cooldown. based on world.time

	shield_type = SHIELD_DIRECTIONAL
	shield_chance = SHIELD_CHANCE_VHIGH

/obj/item/weapon/shield/montage/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon))
		if(cooldown < world.time - 25)
			user.visible_message("<span class='warning'>[user] bashes [src] with [W]!</span>")
			playsound(user.loc, 'code_ru/sound/effects/bang-bang.ogg', 25, FALSE)
			cooldown = world.time
		return

	. = ..()

/obj/item/weapon/shield/montage/marine
	name = "N30-2 standard defensive shield"
	desc = "A heavy shield adept at blocking blunt or sharp objects from connecting with the shield wielder."
	icon_state = "marine_shield"
	passive_block = 45
	readied_block = 80
