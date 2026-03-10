//////////////////////////////////////////////////////////////
//MOUNTED DEFENCE
//////////////////////////////////////////////////////////////

/obj/structure/machinery/mounted_defence
	name = "Stationary Fortification"
	desc = "Stationary fortifications can be used to set up fire positions with heavy weapons."

	icon = 'code_ru/icons/obj/structures/mounted_defenses.dmi'
	icon_state = null

	anchored = TRUE
	unslashable = TRUE
	unacidable = TRUE
	density = TRUE
	layer = ABOVE_MOB_LAYER
	use_power = FALSE

	var/base_name = "Stationary Fortification"

	var/prebuild = FALSE
	var/parrent_type_gun = null
	var/undestructible = FALSE

	var/list/obj/structure/blocker/anti_cade/mounted/cadeblockers = list()
	var/cadeblockers_range = 0

	var/mount_class = 0

	var/obj/item/weapon/gun/mounted/mounted_gun = null

	projectile_coverage = PROJECTILE_COVERAGE_LOW

	health = 600
	var/max_health = 600

	var/user_old_x = 0
	var/user_old_y = 0

	var/tiles_zoom = 5

/obj/structure/machinery/mounted_defence/Initialize()
	. = ..()
	for(var/turf/in_range in range(cadeblockers_range, src))
		var/obj/structure/blocker/anti_cade/mounted/cade_blocker = new(in_range)
		cade_blocker.to_block = src

		cadeblockers.Add(cade_blocker)

	if(parrent_type_gun && prebuild)
		mounted_gun = new parrent_type_gun(src)
		mounted_gun.owner = src
		mounted_gun.flags_mounted_gun_features |= GUN_MOUNTED
		name = "[mounted_gun] installed on [base_name]"
		update_icon()

/obj/structure/machinery/mounted_defence/Destroy()
	mounted_gun.owner = null
	mounted_gun = null
	QDEL_NULL_LIST(cadeblockers)
	return ..()

/obj/structure/machinery/mounted_defence/initialize_pass_flags(datum/pass_flags_container/PF)
	..()
	if(PF)
		PF.flags_can_pass_all = PASS_HIGH_OVER_ONLY|PASS_AROUND|PASS_OVER_THROW_ITEM

/obj/structure/machinery/mounted_defence/calculate_cover_hit_boolean(obj/projectile/proj, distance = 0, cade_direction_correct = FALSE)
	var/ammo_flags = proj.ammo.flags_ammo_behavior | proj.projectile_override_flags
	if(ammo_flags & AMMO_ROCKET)
		return FALSE
	..()

/obj/structure/machinery/mounted_defence/BlockedPassDirs(atom/movable/mover, target_turf)
	if(istype(mover, /obj/item) && mover.throwing)
		return FALSE
	else
		return ..()

/obj/structure/machinery/mounted_defence/proc/crusher_impact()
	update_health(max_health * 0.2)
	if(operator)
		to_chat(operator, SPAN_HIGHDANGER("You are knocked off the gun by the sheer force of the ram!"))
		operator.unset_interaction()
		operator.apply_effect(3, WEAKEN)
		operator.emote("pain")

/obj/structure/machinery/mounted_defence/attackby(obj/item/attacking_item as obj, mob/user, mob/living/E)
	if(!ishuman(user))
		return

	if(HAS_TRAIT(attacking_item, TRAIT_TOOL_SCREWDRIVER))
		if(undestructible)
			return

		if(anchored)
			to_chat(user, "You begin unscrewing [src] from the ground...")
		else
			to_chat(user, "You begin screwing [src] into place...")

		var/old_anchored = anchored
		if(do_after(user, 450 * user.get_skill_duration_multiplier(SKILL_ENGINEER), INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD) && anchored == old_anchored)
			anchored = !anchored
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 25, 1)
			if(anchored)
				user.visible_message(SPAN_NOTICE("[user] anchors [src] into place."),SPAN_NOTICE("You anchor [src] into place."))
			else
				user.visible_message(SPAN_NOTICE("[user] unanchors [src]."),SPAN_NOTICE("You unanchor [src]."))
		return

	else if(isgun(attacking_item))
		var/obj/item/weapon/gun/operator_gun = attacking_item
		if(operator_gun.mounted_class > mount_class)
			to_chat(user, SPAN_WARNING("[mounted_gun] too big for [src]."))
			return

		if(!anchored)
			to_chat(user, SPAN_WARNING("At first need to anchor [src]."))
			return

		if(!mounted_gun)
			user.visible_message(SPAN_NOTICE("[user] start putting [mounted_gun] in [src]."),
			SPAN_NOTICE("You start putting [operator_gun] in [src]."))
			if(do_after(user, 100 * operator_gun.mounted_class * mount_class * user.get_skill_duration_multiplier(SKILL_ENGINEER), INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD))
				if(mounted_gun || !anchored || !user.drop_inv_item_to_loc(operator_gun, src))
					return

				mounted_gun = operator_gun
				mounted_gun.owner = src
				user.visible_message(SPAN_NOTICE("[user] put [mounted_gun] in [src]."),
				SPAN_NOTICE("You put [operator_gun] in [src]."))
				mounted_gun.flags_mounted_gun_features |= GUN_MOUNTED
				name = "[mounted_gun] installed on [base_name]"
				update_icon()
		else
			to_chat(user, SPAN_WARNING("Place in [src] already taken."))
		return

	else if(HAS_TRAIT(attacking_item, TRAIT_TOOL_WRENCH))
		if(undestructible)
			return

		if(health < max_health * 0.2)
			to_chat(user, SPAN_WARNING("[mounted_gun] stuck to [src], repair it first."))
			return

		if(!mounted_gun)
			to_chat(user, SPAN_WARNING("There nothing to remove from [src]."))
			return

		playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
		user.visible_message(SPAN_NOTICE("[user] started removing [mounted_gun] from [src]."),
		SPAN_NOTICE("You start removing [mounted_gun] from [src]."))
		if(do_after(user, 200 * user.get_skill_duration_multiplier(SKILL_ENGINEER), INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD))
			user.visible_message(SPAN_NOTICE("[user] removed [mounted_gun] from [src]."),
			SPAN_NOTICE("You removed [mounted_gun] from [src]."))
			mounted_gun.flags_mounted_gun_features &= ~GUN_BURST_FIRING
			mounted_gun.update_icon()
			name = base_name
			user.put_in_hands(mounted_gun)
			mounted_gun.owner = null
			mounted_gun = null
			update_icon()
		return

	else if(HAS_TRAIT(attacking_item, TRAIT_TOOL_BLOWTORCH))
		var/obj/item/tool/weldingtool/welder = attacking_item
		if(welder.get_fuel() < 3)
			return

		if(!do_after(user, 60 * user.get_skill_duration_multiplier(SKILL_ENGINEER), INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD))
			return

		if(!welder.remove_fuel(3, user))
			return

		to_chat(user, SPAN_NOTICE("You repaired [src]."))
		update_health(-100)
		return

	else if(istype(attacking_item, /obj/item/ammo_magazine))
		mounted_gun.reload(user, attacking_item)
		update_icon()
		return

	else if(istype(attacking_item, /obj/item/explosive/grenade))
		mounted_gun.on_pocket_attackby(attacking_item, user)
		update_icon()
		return

	return ..()

/obj/structure/machinery/mounted_defence/bullet_act(obj/projectile/proj)
	bullet_ping(proj)
	visible_message(SPAN_WARNING("[src] is hit by the [proj]!"))
	update_health(round(proj.damage / 10))
	return TRUE

/obj/structure/machinery/mounted_defence/update_health(damage)
	health = clamp(health - damage, 0, max_health)
	if(health <= 0)
		playsound(src, 'sound/effects/metal_crash.ogg', 25, 1)
		qdel(src)

/obj/structure/machinery/mounted_defence/MouseDrop(over_object, src_location, over_location)
	if(!ishuman(usr))
		return

	var/mob/living/carbon/human/user = usr
	if(!Adjacent(user))
		return

	if(over_object != user)
		return

	if(anchored)
		if(user.interactee == src)
			user.unset_interaction()
			return

		if(operator)
			if(operator.interactee == null)
				operator = null
			else
				to_chat(user, "Somebody already taken control of it.")
				return
		else
			if(user.interactee)
				to_chat(user, "You already busy.")
				return

			if(user.get_active_hand() != null)
				to_chat(user, SPAN_WARNING("You need free hand to control [src]."))
				return

			user.set_interaction(src)

	else
		if(prebuild)
			return

		if(anchored)
			to_chat(user, SPAN_WARNING("[src] can't be taken while anchored."))
			return

		if(mounted_gun)
			to_chat(user, SPAN_WARNING("[src] can't be taken while holds [mounted_gun]."))
			return

		to_chat(user, SPAN_NOTICE("You taken [src]."))
		var/obj/item/device/mounted_defence/tripod/mount = new(loc)
		transfer_label_component(mount)
		user.put_in_hands(mount)
		qdel(src)


// INTERACTIONS SET AND UNSET
/obj/structure/machinery/mounted_defence/proc/exit_interaction()
	SIGNAL_HANDLER

	operator.unset_interaction()

/obj/structure/machinery/mounted_defence/on_set_interaction(mob/living/user)
	ADD_TRAIT(user, TRAIT_IMMOBILIZED, INTERACTION_TRAIT)
	give_action(user, /datum/action/human_action/mg_exit)
	user.forceMove(src.loc)
	user.setDir(dir)
	user.reset_view(src)
	user.status_flags |= IMMOBILE_ACTION
	user.visible_message(SPAN_NOTICE("[user] mans [src]."), SPAN_NOTICE("You man [src], locked and loaded!"))
	user_old_x = user.pixel_x
	user_old_y = user.pixel_y
	update_pixels(user)

	RegisterSignal(user, list(COMSIG_MOB_MG_EXIT, COMSIG_MOB_RESISTED, COMSIG_MOB_DEATH, COMSIG_LIVING_SET_BODY_POSITION), PROC_REF(exit_interaction))

	mounted_gun.set_gun_user(user)
	operator = user
	mounted_gun.update_mouse_pointer(user, TRUE)
	flags_atom |= RELAY_CLICK

/obj/structure/machinery/mounted_defence/on_unset_interaction(mob/living/user)
	REMOVE_TRAIT(user, TRAIT_IMMOBILIZED, INTERACTION_TRAIT)
	remove_action(user, /datum/action/human_action/mg_exit)
	user.Move(get_step(src, reverse_direction(src.dir)))
	user.setDir(dir)
	user.reset_view(null)
	user.status_flags &= ~IMMOBILE_ACTION
	user.visible_message(SPAN_NOTICE("[user] lets go of [src]."), SPAN_NOTICE("You let go of [src], letting the gun rest."))
	user_old_x = 0 //reset our x
	user_old_y = 0 //reset our y
	update_pixels(user, FALSE)
	user.remove_temp_pass_flags(PASS_MOB_THRU)

	SEND_SIGNAL(src, COMSIG_GUN_INTERRUPT_FIRE)
	UnregisterSignal(user, list(COMSIG_MOB_MG_EXIT, COMSIG_MOB_RESISTED, COMSIG_MOB_DEATH, COMSIG_LIVING_SET_BODY_POSITION))

	mounted_gun.update_mouse_pointer(operator, FALSE)
	if(operator == user)
		mounted_gun.set_gun_user(null)
		operator = null
	flags_atom &= ~RELAY_CLICK

/obj/structure/machinery/mounted_defence/proc/update_pixels(mob/user, mounting = TRUE)
	if(mounting)
		var/diff_x = 0
		var/diff_y = 0
		var/tilesize = 32
		var/viewoffset = tilesize * (mounted_gun?.build_in_zoom || 2)
		switch(dir)
			if(NORTH)
				diff_y = -16 + user_old_y
				if(user.client)
					user.client.set_pixel_x(0)
					user.client.set_pixel_y(viewoffset)
			if(SOUTH)
				diff_y = 16 + user_old_y
				if(user.client)
					user.client.set_pixel_x(0)
					user.client.set_pixel_y(-viewoffset)
			if(EAST)
				diff_x = -16 + user_old_x
				if(user.client)
					user.client.set_pixel_x(viewoffset)
					user.client.set_pixel_y(0)
			if(WEST)
				diff_x = 16 + user_old_x
				if(user.client)
					user.client.set_pixel_x(-viewoffset)
					user.client.set_pixel_y(0)

		animate(user, pixel_x=diff_x, pixel_y=diff_y, 0.4 SECONDS)
	else
		if(user.client)
			user.client.change_view(GLOB.world_view_size)
			user.client.set_pixel_x(0)
			user.client.set_pixel_y(0)
		animate(user, pixel_x=user_old_x, pixel_y=user_old_y, 4, 1)

/obj/structure/machinery/mounted_defence/check_eye(mob/living/user)
	if(user.body_position != STANDING_UP || get_dist(user,src) > 1 || user.is_mob_incapacitated() || !user.client)
		user.unset_interaction()
// End of horros beyond game official cm devs comprehension!!!

/obj/structure/machinery/mounted_defence/attack_alien(mob/living/carbon/xenomorph/xeno)
	if(islarva(xeno))
		return

	xeno.visible_message(SPAN_DANGER("[xeno] hits [src]!"),
	SPAN_DANGER("You hit [src]!"))
	xeno.animation_attack_on(src)
	xeno.flick_attack_overlay(src, "slash")
	playsound(loc, "alien_claw_metal", 25)
	update_health(rand(xeno.melee_damage_lower, xeno.melee_damage_upper))
	return XENO_ATTACK_ACTION

/obj/structure/machinery/mounted_defence/update_icon()
	overlays.Cut()
	if(mounted_gun)
		overlays += mounted_gun.mounted_state

/obj/structure/machinery/mounted_defence/get_examine_text(mob/user)
	. = ..()
	if(mounted_gun)
		. += "Installed [mounted_gun], [mounted_gun.desc].<br>"
	else if(!anchored)
		. += "Need to be <B>bolted</b>.<br>"
	else
		. += "Empty.<br>"

	if(mounted_gun)
		. += mounted_gun.get_examine_text(user)

/obj/structure/machinery/mounted_defence/proc/handle_outside_cone(mob/living/carbon/human/user)
	return FALSE

/obj/structure/machinery/mounted_defence/clicked(mob/user, list/mods)
	if(isobserver(user)) return

	if(mods[CTRL_CLICK])
		if(operator != user)
			return

		if(!mounted_gun)
			return

		mounted_gun.do_toggle_firemode(operator)
		return TRUE

	if(mods[ALT_CLICK])
		if(!mounted_gun)
			return

		mounted_gun.unload(user)
		return TRUE

	return ..()


//////////////////////////////////////////////////////////////
//TIER 1													//
//////////////////////////////////////////////////////////////
/obj/structure/machinery/mounted_defence/tier_one
	mount_class = GUN_MOUNT_SMALL

/obj/structure/machinery/mounted_defence/tier_one/tripod
	name = "Tripod"
	base_name = "Tripod"
	desc = "Tripod for light weight stationary weapons."
	icon_state = "tripod"
	anchored = FALSE
	density = TRUE

	health = 300
	max_health = 300
	projectile_coverage = PROJECTILE_COVERAGE_LOW


/obj/item/device/mounted_defence
	icon = 'code_ru/icons/obj/structures/mounted_defenses.dmi'
	unacidable = TRUE
	w_class = SIZE_MEDIUM

/obj/item/device/mounted_defence/tripod
	name = "Tripod"
	desc = "Tripod Tripod for light weight stationary weapons."
	icon_state = "folded_tripod"

/obj/item/device/mounted_defence/tripod/attack_self(mob/user)
	. = ..()

	if(!ishuman(usr))
		return

	var/turf/location = get_turf(src)
	var/fail = FALSE
	if(location.density)
		fail = TRUE
	else
		for(var/obj/blocker in location.contents - src)
			if(blocker.density && !(blocker.flags_atom & ON_BORDER))
				fail = TRUE
				break
			if(istype(blocker, /obj/structure/machinery/defenses))
				fail = TRUE
				break
			if(istype(blocker, /obj/structure/window))
				fail = TRUE
				break
			if(istype(blocker, /obj/structure/windoor_assembly))
				fail = TRUE
				break
			if(istype(blocker, /obj/structure/machinery/door))
				fail = TRUE
				break

	if(fail)
		to_chat(user, SPAN_WARNING("You can't install [src] here, something is in the way."))
		return

	to_chat(user, SPAN_NOTICE("You install [src]."))
	var/obj/structure/machinery/mounted_defence/tier_one/tripod/mount = new /obj/structure/machinery/mounted_defence/tier_one/tripod(user.loc)
	mount.name = src.name
	mount.setDir(user.dir)
	qdel(src)


/obj/structure/machinery/mounted_defence/tier_one/tripod/prebuild
	prebuild = TRUE
	density = TRUE
	anchored = TRUE

/obj/structure/machinery/mounted_defence/tier_one/tripod/prebuild/mg_turret
	name = "Nest"
	desc = "Nest for light weight stationary weapons."
	icon_state = "small_place_sand"
	projectile_coverage = PROJECTILE_COVERAGE_HIGH
	parrent_type_gun = /obj/item/weapon/gun/mounted/m56d2_gun


//////////////////////////////////////////////////////////////
//TIER 2													//
//////////////////////////////////////////////////////////////

/obj/structure/machinery/mounted_defence/tier_two
	name = "Medium Fortification"
	desc = "Stationary fortifications for medium stationary weapons."
	mount_class = GUN_MOUNT_MEDIUM
	projectile_coverage = PROJECTILE_COVERAGE_MEDIUM


//////////////////////////////////////////////////////////////
//TIER 3													//
//////////////////////////////////////////////////////////////

/obj/structure/machinery/mounted_defence/tier_three
	name = "Dot Fortification"
	desc = "Special firing postion for big stationary weapons."
	mount_class = GUN_MOUNT_BIG
	projectile_coverage = PROJECTILE_COVERAGE_HIGH


//////////////////////////////////////////////////////////////
// WEAPONS													//
//////////////////////////////////////////////////////////////

/obj/item/storage/box/stationary_m56d2_hmg
	name = "\improper M56D2 crate"
	desc = "A large metal case with Japanese writing on the top. However it also comes with English text to the side. This is a M56D2 heavy machine gun, it clearly has various labeled warnings. The most major one is that this does not have IFF features due to specialized ammo."
	icon = 'code_ru/icons/obj/structures/mounted_defenses.dmi'
	icon_state = "M56D2_case"
	w_class = SIZE_HUGE
	storage_slots = 5

/obj/item/storage/box/stationary_m56d2_hmg/Initialize()
	. = ..()
	new /obj/item/weapon/gun/mounted/m56d2_gun(src)
	new /obj/item/device/mounted_defence/tripod(src)
	new /obj/item/ammo_magazine/m56d2(src)
	new /obj/item/ammo_magazine/m56d2(src)

/obj/item/ammo_magazine/m56d2
	name = "M56D2 drum magazine (10x28mm Caseless)"
	desc = "A box of 700, 10x28mm caseless tungsten rounds for the M56D2 heavy machine gun system."

	icon = 'icons/obj/items/weapons/guns/ammo_by_faction/USCM/machineguns.dmi'
	icon_state = "m56d_drum"

	w_class = SIZE_MEDIUM
	flags_magazine = NO_FLAGS //can't be refilled or emptied by hand

	caliber = "10x28mm"
	max_rounds = 700
	default_ammo = /datum/ammo/bullet/smartgun/stationary
	gun_type = /obj/item/weapon/gun/mounted/m56d2_gun

/datum/ammo/bullet/smartgun/stationary
	name = "smartgun tracer bullet"
	icon_state = "bullet_iff"
	flags_ammo_behavior = AMMO_BALLISTIC

	damage_falloff = DAMAGE_FALLOFF_TIER_9
	max_range = 16
	accuracy = HIT_ACCURACY_TIER_4
	damage = 30
	penetration = 0
	effective_range_max = 4


//////////////////////////////////////////////////////////////

/obj/item/storage/box/sgl2
	name = "\improper SGL2 Assembly-Supply Crate"
	desc = "A large case labelled 'SGL2, heavy grenade launcher', seems to be fairly heavy to hold. Contains a deadly SGL2 Heavy Grenade Launching System and its ammunition."
	icon = 'code_ru/icons/obj/structures/mounted_defenses.dmi'
	icon_state = "SGL2_case"
	w_class = SIZE_HUGE
	storage_slots = 5

/obj/item/storage/box/sgl2/Initialize()
	. = ..()

	new /obj/item/weapon/gun/launcher/grenade/mounted/sgl2_gun(src)
	new /obj/item/device/mounted_defence/tripod(src)
	new /obj/item/storage/box/nade_box/airburstincen(src)


//////////////////////////////////////////////////////////////

/obj/item/storage/box/rct
	name = "\improper RCT Assembly-Supply Crate"
	desc = "A large case labelled 'RCT, heavy rocket launcher', seems to be fairly heavy to hold. Contains stationary rocket launcher, can be used with 100mm types rockets. likely to destroy enemy heavy machines."
	icon = 'code_ru/icons/obj/structures/mounted_defenses.dmi'
	icon_state = "RCT_case"
	w_class = SIZE_HUGE
	storage_slots = 5

/obj/item/storage/box/rct/Initialize()
	. = ..()
	new /obj/item/weapon/gun/launcher/rocket/mounted/rct_gun(src)
	new /obj/item/device/mounted_defence/tripod(src)
	new /obj/item/ammo_magazine/rocket/stationary(src)
	new /obj/item/ammo_magazine/rocket/stationary(src)
	new /obj/item/ammo_magazine/rocket/ap/stationary(src)
	new /obj/item/ammo_magazine/rocket/wp/stationary(src)

/obj/item/ammo_magazine/rocket/stationary
	name = "\improper 100mm high explosive rocket"
	desc = "A rocket tube loaded with a high-explosive warhead. Deals high damage to soft targets on direct hit and stuns most targets in a 5-meter-wide area for a short time. Has decreased effect on heavily armored targets."

	default_ammo = /datum/ammo/rocket/stationary
	gun_type = /obj/item/weapon/gun/launcher/rocket/mounted/rct_gun

/datum/ammo/rocket/stationary
	max_range = 12

/obj/item/ammo_magazine/rocket/ap/stationary
	name = "\improper 100mm anti-armor rocket"
	desc = "A rocket tube loaded with an armor-piercing warhead. Capable of piercing heavily armored targets. Deals very little to no splash damage. Inflicts guaranteed stun to most targets. Has high accuracy within 7 meters."

	default_ammo = /datum/ammo/rocket/ap/stationary
	gun_type = /obj/item/weapon/gun/launcher/rocket/mounted/rct_gun

/datum/ammo/rocket/ap/stationary
	max_range = 14

/obj/item/ammo_magazine/rocket/wp/stationary
	name = "\improper 100mm white-phosphorus rocket"
	desc = "A rocket tube loaded with a white phosphorus incendiary warhead. Has two damaging factors. On hit disperses X-Variant Napthal (blue flames) in a 4-meter radius circle, ignoring cover, while simultaneously bursting into highly heated shrapnel that ignites targets within slightly bigger area."

	default_ammo = /datum/ammo/rocket/wp/stationary
	gun_type = /obj/item/weapon/gun/launcher/rocket/mounted/rct_gun

/datum/ammo/rocket/wp/stationary
	max_range = 15

//////////////////////////////////////////////////////////////

/obj/item/storage/box/sagf
	name = "\improper SAGF Assembly-Supply Crate"
	desc = "A large case labelled 'SAGF, heavy flamer', seems to be fairly heavy to hold. Contains stationary flamethrower, can be used with special fuel."
	icon = 'code_ru/icons/obj/structures/mounted_defenses.dmi'
	icon_state = "SAGF_case"
	w_class = SIZE_HUGE
	storage_slots = 5

/obj/item/storage/box/sagf/Initialize()
	. = ..()
	new /obj/item/weapon/gun/flamer/mounted/sagf(src)
	new /obj/item/device/mounted_defence/tripod(src)
	new /obj/item/ammo_magazine/flamer_tank/large/stationary(src)
	new /obj/item/ammo_magazine/flamer_tank/large/stationary(src)
	new /obj/item/ammo_magazine/flamer_tank/large/EX/stationary(src)

/obj/item/ammo_magazine/flamer_tank/large/stationary
	name = "M255 large incinerator tank"

	stripe_icon = null
	gun_type = /obj/item/weapon/gun/flamer/mounted/sagf

	max_range = 10

/obj/item/ammo_magazine/flamer_tank/large/EX/stationary
	name = "M255 large incinerator tank (EX)"

	stripe_icon = null
	gun_type = /obj/item/weapon/gun/flamer/mounted/sagf

	max_range = 13
