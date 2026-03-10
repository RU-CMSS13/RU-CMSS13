#define MOUNTED_DEFENSE_SECURED 0
#define MOUNTED_DEFENSE_UNSECURED 1
#define MOUNTED_DEFENSE_MOVABLE 2

//////////////////////////////////////////////////////////////
//MOUNTED DEFENCE											//
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

	projectile_coverage = PROJECTILE_COVERAGE_LOW

	health = 600
	var/max_health = 600

	var/parrent_type_gun = null
	var/obj/item/weapon/gun/mounted/mounted_gun = null
	var/repair_materials = list()
	var/mount_class = 0
	var/build_stage = 0

	var/hitsound = 'sound/effects/metalhit.ogg'

	var/list/obj/structure/blocker/anti_cade/mounted/cadeblockers = list()
	var/cadeblockers_range = 0

	var/user_old_x = 0
	var/user_old_y = 0
	var/tiles_zoom = 5

/obj/structure/machinery/mounted_defence/Initialize()
	. = ..()

	for(var/turf/in_range in range(cadeblockers_range, src))
		var/obj/structure/blocker/anti_cade/mounted/cade_blocker = new(in_range)
		cade_blocker.to_block = src

		cadeblockers.Add(cade_blocker)

	if(parrent_type_gun)
		mounted_gun = new parrent_type_gun(src)
		mounted_gun.owner = src
		mounted_gun.flags_mounted_gun_features |= GUN_MOUNTED
		update_icon()

/obj/structure/machinery/mounted_defence/Destroy()
	if(operator)
		operator.unset_interaction()
	if(mounted_gun)
		mounted_gun.owner = null
		QDEL_NULL(mounted_gun)
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


//////////////////////////////////////////////////////////////
//MOUNTED DEFENCE ATTACK INTERACTIONS

/obj/structure/machinery/mounted_defence/attackby(obj/item/attacking_item, mob/user)
	if(try_repair(attacking_item, user))
		return

	if(try_nailgun_usage(attacking_item, user))
		return

	for(var/obj/effect/xenomorph/acid/splatter in loc)
		if(splatter.acid_t == src)
			to_chat(user, "You can't get near that, it's melting!")
			return

	if(mounted_gun && try_reload_mounts(attacking_item, user))
		return

	if(!build_stage && try_insert_weapon(attacking_item, user))
		return

	handle_building_stages(attacking_item, user)
	return ..()

/obj/structure/machinery/mounted_defence/proc/handle_building_stages(obj/item/attacking_item, mob/user)
	return

/obj/structure/machinery/mounted_defence/proc/try_repair(obj/item/attacking_item, mob/user)
	return

/obj/structure/machinery/mounted_defence/proc/try_nailgun_usage(obj/item/attacking_item, mob/user)
	if(!length(repair_materials) || health >= max_health || !istype(attacking_item, /obj/item/weapon/gun/smg/nailgun))
		return FALSE

	var/obj/item/weapon/gun/smg/nailgun/nailgun = attacking_item

	var/nails_required = 4
	if(!nailgun.in_chamber || !nailgun.current_mag || nailgun.current_mag.current_rounds < nails_required)
		to_chat(user, SPAN_WARNING("You require at least [nails_required] nails to complete this task!"))
		return FALSE

	// Check if either hand has a metal stack by checking the weapon offhand
	// Presume the material is a sheet until proven otherwise.
	var/obj/item/stack/sheet/material = null
	if(user.l_hand == nailgun)
		material = user.r_hand
	else
		material = user.l_hand

	if(!istype(material, /obj/item/stack/sheet))
		to_chat(user, SPAN_WARNING("You'll need some adequate repair material in your other hand to patch up [src]!"))
		return FALSE

	if(material.amount < nailgun.material_per_repair)
		to_chat(user, SPAN_WARNING("You'll need more adequate repair material in your other hand to patch up [src]!"))
		return FALSE

	var/repair_value = 0
	for(var/validSheetType in repair_materials)
		if(validSheetType == material.sheettype)
			repair_value = repair_materials[validSheetType]
			break

	if(repair_value == 0)
		to_chat(user, SPAN_WARNING("You'll need some adequate repair material in your other hand to patch up [src]!"))
		return FALSE

	var/soundchannel = playsound(src, nailgun.repair_sound, 25, 1)
	if(!do_after(user, nailgun.nailing_speed, INTERRUPT_ALL, BUSY_ICON_FRIENDLY, src))
		playsound(src, null, channel = soundchannel)
		return FALSE

	if(!material || (material != user.l_hand && material != user.r_hand) || material.amount <= 0)
		to_chat(user, SPAN_WARNING("You seem to have misplaced the repair material!"))
		return FALSE

	if(!nailgun.in_chamber || !nailgun.current_mag || nailgun.current_mag.current_rounds < nails_required)
		to_chat(user, SPAN_WARNING("You require at least [nails_required] nails to complete this task!"))
		return FALSE

	update_health(-repair_value * max_health)
	to_chat(user, SPAN_WARNING("You nail [material] to [src], restoring some of its integrity!"))
	material.use(nailgun.material_per_repair)
	nailgun.current_mag.current_rounds -= nails_required - 1
	nailgun.in_chamber = null
	nailgun.load_into_chamber()
	return TRUE

/obj/structure/machinery/mounted_defence/proc/try_insert_weapon(obj/item/attacking_item, mob/user)
	return FALSE

/obj/structure/machinery/mounted_defence/proc/try_remove_weapon(obj/item/attacking_item, mob/user)
	return FALSE

/obj/structure/machinery/mounted_defence/proc/try_reload_mounts(obj/item/attacking_item, mob/user)
	if(istype(attacking_item, /obj/item/ammo_magazine))
		mounted_gun.reload(user, attacking_item)
		update_icon()
		return TRUE

	if(istype(attacking_item, /obj/item/explosive/grenade))
		mounted_gun.on_pocket_attackby(attacking_item, user)
		update_icon()
		return TRUE

	return FALSE


//////////////////////////////////////////////////////////////
//MOUNTED DEFENCE DAMAGE RELATED

/obj/structure/machinery/mounted_defence/handle_charge_collision(mob/living/carbon/xenomorph/xeno, datum/action/xeno_action/onclick/charger_charge/charger_ability)
	if(charger_ability.momentum)
		CrusherImpact(xeno, charger_ability.momentum * 22)

	charger_ability.stop_momentum()

/obj/structure/machinery/mounted_defence/proc/CrusherImpact(mob/living/carbon/xenomorph/xeno, damage)
	xeno.visible_message(
		SPAN_DANGER("[xeno] rams into \the [src] and skids to a halt!"),
		SPAN_XENOWARNING("You ram into \the [src] and skid to a halt!")
	)
	if(operator)
		to_chat(operator, SPAN_HIGHDANGER("You are knocked off the gun by the sheer force of the ram!"))
		operator.unset_interaction()
		operator.apply_effect(3, WEAKEN)
		operator.emote("pain")

	playsound(src, hitsound, 25, TRUE)
	update_health(damage)

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

/obj/structure/machinery/mounted_defence/bullet_act(obj/projectile/bullet)
	bullet_ping(bullet)

	if(bullet.ammo.damage_type == BURN)
		bullet.damage = bullet.damage
	else
		bullet.damage = bullet.damage
		playsound(src, hitsound, 35, 1)

	if(istype(bullet.ammo, /datum/ammo/xeno/boiler_gas))
		update_health(50)

	else if(bullet.ammo.flags_ammo_behavior & AMMO_ANTISTRUCT)
		update_health(bullet.damage * ANTISTRUCT_DMG_MULT_BARRICADES)

	update_health(bullet.damage)
	return TRUE

/obj/structure/machinery/mounted_defence/update_health(damage)
	health = clamp(health - damage, 0, max_health)
	if(!health)
		playsound(src, 'sound/effects/metal_crash.ogg', 25, 1)
		deconstruct()
		return

	update_damage_state(floor(health/max_health * 100))
	update_icon()

/obj/structure/machinery/mounted_defence/proc/update_damage_state()
	return


//////////////////////////////////////////////////////////////
//MOUNTED DEFENCE INTERACTIONS

/obj/structure/machinery/mounted_defence/proc/exit_interaction()
	SIGNAL_HANDLER

	operator.unset_interaction()

/obj/structure/machinery/mounted_defence/on_set_interaction(mob/living/user)
	ADD_TRAIT(user, TRAIT_IMMOBILIZED, INTERACTION_TRAIT)
	give_action(user, /datum/action/human_action/mg_exit)
	user.forceMove(loc)
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
	user.Move(get_step(src, reverse_direction(dir)))
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

/obj/structure/machinery/mounted_defence/MouseDrop(over_object, src_location, over_location)
	if(!ishuman(usr))
		return FALSE

	if(usr.action_busy)
		return FALSE

	if(!Adjacent(usr))
		return FALSE

	if(over_object != usr)
		return FALSE

	return TRUE
// End of horros beyond official cm devs comprehension!!!

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

/obj/structure/machinery/mounted_defence/tier_one/deconstruct(disassemble, mob/living/user)
	if(disassemble)
		var/obj/item/device/mounted_defence/tripod/mount = new(loc)
		transfer_label_component(mount)
		if(user)
			user.put_in_hands(mount)

		if(mounted_gun)
			mounted_gun.update_icon()
			mounted_gun.owner = null
			if(user)
				user.put_in_hands(mounted_gun)
			else
				mounted_gun.forceMove(loc)
			mounted_gun = null

	qdel(src)

/obj/structure/machinery/mounted_defence/tier_one/MouseDrop(over_object, src_location, over_location)
	. = ..()
	if(!.)
		return

	var/mob/living/user = usr
	if(mounted_gun)
		if(build_stage != MOUNTED_DEFENSE_SECURED)
			return

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
		return
	else
		if(build_stage != MOUNTED_DEFENSE_MOVABLE)
			to_chat(user, SPAN_WARNING("You are need to lose [src] first."))
			return

		if(!do_after(user, 20, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD, src))
			return

		user.visible_message(SPAN_NOTICE("[user] takes [src]."),
		SPAN_NOTICE("You take [src]."))
		playsound(loc, 'sound/items/Deconstruct.ogg', 25, 1)

		deconstruct(TRUE, user)

/obj/structure/machinery/mounted_defence/tier_one/handle_building_stages(obj/item/attacking_item, mob/user)
	switch(build_stage)
		if(MOUNTED_DEFENSE_SECURED) //Fully constructed step. Use screwdriver to remove the protection panels to reveal the bolts
			if(HAS_TRAIT(attacking_item, TRAIT_TOOL_SCREWDRIVER))
				if(!skillcheck(user, SKILL_CONSTRUCTION, SKILL_CONSTRUCTION_TRAINED))
					to_chat(user, SPAN_WARNING("You are not trained to touch [src]..."))
					return
				if(user.action_busy)
					return
				playsound(loc, 'sound/items/Screwdriver.ogg', 25, 1)
				if(!do_after(user, 10, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD, src))
					return
				user.visible_message(SPAN_NOTICE("[user] removes [src]'s protection panel."),
				SPAN_NOTICE("You remove [src]'s protection panels, exposing the anchor bolts."))
				build_stage = MOUNTED_DEFENSE_UNSECURED
				return

		if(MOUNTED_DEFENSE_UNSECURED) //Protection panel removed step. Screwdriver to put the panel back, wrench to unsecure the anchor bolts
			if(HAS_TRAIT(attacking_item, TRAIT_TOOL_SCREWDRIVER))
				if(user.action_busy)
					return
				if(!skillcheck(user, SKILL_CONSTRUCTION, SKILL_CONSTRUCTION_TRAINED))
					to_chat(user, SPAN_WARNING("You are not trained to assemble [src]..."))
					return
				playsound(loc, 'sound/items/Screwdriver.ogg', 25, 1)
				if(!do_after(user, 10, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD, src))
					return
				user.visible_message(SPAN_NOTICE("[user] set [src]'s protection panel back."),
				SPAN_NOTICE("You set [src]'s protection panel back."))
				build_stage = MOUNTED_DEFENSE_SECURED
				return

			if(HAS_TRAIT(attacking_item, TRAIT_TOOL_WRENCH))
				if(user.action_busy)
					return
				if(!skillcheck(user, SKILL_CONSTRUCTION, SKILL_CONSTRUCTION_TRAINED))
					to_chat(user, SPAN_WARNING("You are not trained to disassemble [src]..."))
					return
				playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
				if(!do_after(user, 10, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD, src))
					return
				user.visible_message(SPAN_NOTICE("[user] loosens [src]'s anchor bolts."),
				SPAN_NOTICE("You loosen [src]'s anchor bolts."))
				anchored = FALSE
				build_stage = MOUNTED_DEFENSE_MOVABLE
				update_icon() //unanchored changes layer
				return

		if(MOUNTED_DEFENSE_MOVABLE) //Anchor bolts loosened step. Apply crowbar to unseat the panel and take apart the whole thing. Apply wrench to resecure anchor bolts
			if(HAS_TRAIT(attacking_item, TRAIT_TOOL_WRENCH))
				if(user.action_busy)
					return
				if(!skillcheck(user, SKILL_CONSTRUCTION, SKILL_CONSTRUCTION_TRAINED))
					to_chat(user, SPAN_WARNING("You are not trained to assemble [src]..."))
					return
				for(var/obj/structure/barricade/B in loc)
					if(B != src && B.dir == dir)
						to_chat(user, SPAN_WARNING("There's already a barricade here."))
						return
				playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
				if(!do_after(user, 10, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD, src))
					return
				user.visible_message(SPAN_NOTICE("[user] secures [src]'s anchor bolts."),
				SPAN_NOTICE("You secure [src]'s anchor bolts."))
				build_stage = MOUNTED_DEFENSE_UNSECURED
				anchored = TRUE
				update_icon() //unanchored changes layer
				return

/obj/structure/machinery/mounted_defence/tier_one/try_insert_weapon(obj/item/attacking_item, mob/user)
	if(!isgun(attacking_item) || user.action_busy || mounted_gun)
		return FALSE

	if(!skillcheck(user, SKILL_CONSTRUCTION, SKILL_CONSTRUCTION_TRAINED))
		to_chat(user, SPAN_WARNING("You are not trained to touch [src]..."))
		return FALSE

	var/obj/item/weapon/gun/attacking_gun = attacking_item
	if(attacking_gun.mounted_class > mount_class)
		to_chat(user, SPAN_WARNING("[mounted_gun] too big for [src]."))
		return FALSE

	playsound(loc, 'sound/items/Crowbar.ogg', 25, 1)
	if(!do_after(user, 200, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD, src) || !mounted_gun)
		return FALSE

	mounted_gun = attacking_gun
	mounted_gun.owner = src
	mounted_gun.flags_mounted_gun_features |= GUN_MOUNTED
	update_icon()

	user.visible_message(SPAN_NOTICE("[user] places [mounted_gun] in [src]."),
	SPAN_NOTICE("You place [mounted_gun] in [src]."))
	return TRUE

/obj/structure/machinery/mounted_defence/tier_one/try_remove_weapon(obj/item/attacking_item, mob/user)
	if(!HAS_TRAIT(attacking_item, TRAIT_TOOL_CROWBAR) || !mounted_gun)
		return FALSE

	if(!skillcheck(user, SKILL_CONSTRUCTION, SKILL_CONSTRUCTION_TRAINED))
		to_chat(user, SPAN_WARNING("You are not trained to touch [src]..."))
		return FALSE

	playsound(loc, 'sound/items/Crowbar.ogg', 25, 1)
	if(user.action_busy || !do_after(user, 200, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD, src) || mounted_gun)
		return FALSE

	user.visible_message(SPAN_NOTICE("[user] removes [mounted_gun] from [src]."),
	SPAN_NOTICE("You remove [mounted_gun] from [src]."))

	mounted_gun.update_icon()
	mounted_gun.owner = null
	user.put_in_hands(mounted_gun)
	mounted_gun = null
	update_icon()
	return TRUE


/obj/structure/machinery/mounted_defence/tier_one/tripod
	name = "Tripod"
	desc = "Tripod for light weight stationary weapons."

	icon_state = "tripod"
	anchored = FALSE
	density = TRUE

	repair_materials = list("metal" = 0.20, "plasteel" = 0.10)

	hitsound = 'sound/effects/metalhit.ogg'

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
	transfer_label_component(mount)
	mount.setDir(user.dir)
	qdel(src)


/obj/structure/machinery/mounted_defence/tier_one/metal_barricade
	repair_materials = list("metal" = 0.3, "plasteel" = 0.15)

/obj/structure/machinery/mounted_defence/tier_one/plasteel_barricade
	repair_materials = list("metal" = 0.6, "plasteel" = 0.3)





//////////////////////////////////////////////////////////////
//TIER 2													//
//////////////////////////////////////////////////////////////


/obj/structure/machinery/mounted_defence/tier_two
	name = "Medium Fortification"
	desc = "Stationary fortifications for medium stationary weapons."
	mount_class = GUN_MOUNT_MEDIUM
	projectile_coverage = PROJECTILE_COVERAGE_MEDIUM

/obj/structure/machinery/mounted_defence/tier_two/plasteel_position

//simply position for artilery of different types, or anti air gun (all manual)
/obj/structure/machinery/mounted_defence/tier_two/beton_position

//some exagurated weapons, but not so cool
/obj/structure/machinery/mounted_defence/tier_two/beton_dot





//////////////////////////////////////////////////////////////
//TIER 3													//
//////////////////////////////////////////////////////////////


/obj/structure/machinery/mounted_defence/tier_three
	name = "Dot Fortification"
	desc = "Special firing postion for big stationary weapons."
	mount_class = GUN_MOUNT_BIG
	projectile_coverage = PROJECTILE_COVERAGE_HIGH

//can auto load artilery, making it shot very fast, can have special types like missile or shell, even rail and possibility for anti air gun and even rocket turret
/obj/structure/machinery/mounted_defence/tier_three/reinforced_beton_position

//as example ltb or direct artilery, can hold up to 2 big automatic turrest
/obj/structure/machinery/mounted_defence/tier_three/reinforced_beton_dot





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
	new /obj/item/storage/belt/marine/mounted(src)

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
	new /obj/item/storage/belt/marine/mounted(src)


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
	new /obj/item/storage/belt/marine/mounted(src)

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
	new /obj/item/storage/belt/marine/mounted(src)

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


//////////////////////////////////////////////////////////////

/obj/item/storage/belt/marine/mounted
	name = "\improper M1000 heavygunner storage rig"
	desc = "The M1000 heavygunner storage rig is an M276 pattern toolbelt rig modified to carry ammunition for heavy stationary systems, and engineering tools for the gunner."

	icon_state = "m2c_ammo_rig"
	item_state = "m2c_ammo_rig"
	icon = 'icons/obj/items/clothing/belts/belts.dmi'
	item_icons = list(
		WEAR_WAIST = 'icons/mob/humans/onmob/clothing/belts/belts.dmi',
		WEAR_L_HAND = 'icons/mob/humans/onmob/inhands/items_by_map/snow_lefthand.dmi',
		WEAR_R_HAND = 'icons/mob/humans/onmob/inhands/items_by_map/snow_righthand.dmi'
	)
	item_state_slots = list(
		WEAR_L_HAND = "marinebelt",
		WEAR_R_HAND = "marinebelt"
	)

	storage_slots = 14
	max_w_class = SIZE_LARGE
	max_storage_space = 30

	can_hold = list(
		/obj/item/tool/weldingtool,
		/obj/item/tool/wrench,
		/obj/item/tool/screwdriver,
		/obj/item/tool/crowbar,
		/obj/item/tool/extinguisher/mini,
		/obj/item/explosive/plastic,
		/obj/item/explosive/mine,
		/obj/item/ammo_magazine/m56d2,
		/obj/item/explosive/grenade,
		/obj/item/storage/box/nade_box,
		/obj/item/ammo_magazine/rocket/stationary,
		/obj/item/ammo_magazine/rocket/ap/stationary,
		/obj/item/ammo_magazine/rocket/wp/stationary,
		/obj/item/ammo_magazine/flamer_tank/large/stationary,
		/obj/item/ammo_magazine/flamer_tank/large/EX/stationary,
	)
	flags_atom = FPRINT|NO_GAMEMODE_SKIN
