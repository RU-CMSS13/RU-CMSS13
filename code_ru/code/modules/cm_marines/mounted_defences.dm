//////////////////////////////////////////////////////////////
//MOUNTED DEFENCE
//////////////////////////////////////////////////////////////

/obj/structure/machinery/mounted_defence
	name = "Стационарное Укрепление"
	var/base_name = "Стационарное Укрепление"
	desc = "Сюда нужно положить стационарное разобранное оружие, после чего его можно будет использовать."
	icon = 'icons/obj/structures/barricades.dmi'
	icon_state = "small_place"
	anchored = TRUE
	unslashable = TRUE
	unacidable = TRUE
	density = TRUE
	layer = ABOVE_MOB_LAYER
	use_power = FALSE

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
		mounted_gun.flags_mounted_gun_features |= GUN_MOUNTED
		name = "[mounted_gun] installed on [base_name]"
		update_icon()

/obj/structure/machinery/mounted_defence/Destroy()
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
				else if(istype(blocker, /obj/structure/window))
					fail = TRUE
					break
				else if(istype(blocker, /obj/structure/windoor_assembly))
					fail = TRUE
					break
				else if(istype(blocker, /obj/structure/machinery/door))
					fail = TRUE
					break

		if(fail)
			to_chat(user, SPAN_WARNING("You can't install [src] here, something is in the way."))
			return

		if(anchored)
			to_chat(user, "You begin unscrewing [src] from the ground...")
		else
			to_chat(user, "You begin screwing [src] into place...")

		var/old_anchored = anchored
		if(do_after(user, 30 * user.get_skill_duration_multiplier(SKILL_ENGINEER), INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD) && anchored == old_anchored)
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
			to_chat(user, SPAN_WARNING("[mounted_gun] слишком большой для [src]."))
			return

		if(!mount_class)
			to_chat(user, SPAN_WARNING("[mounted_gun] слишком большой для [src]."))
			return

		if(!anchored)
			to_chat(user, SPAN_WARNING("[mounted_gun] нельзя закрепить на [src]."))
			return

		else if(!mounted_gun)
			user.visible_message(SPAN_NOTICE("[user] начал вставлять [mounted_gun] в [src]."),
			SPAN_NOTICE("Вы начали вставлять [operator_gun] в [src]."))
			if(do_after(user, 100 * operator_gun.mounted_class * mount_class * user.get_skill_duration_multiplier(SKILL_ENGINEER), INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD))
				if(user.drop_inv_item_to_loc(operator_gun, src))
					mounted_gun = operator_gun
					user.visible_message(SPAN_NOTICE("[user] вставил [mounted_gun] в [src]."),
					SPAN_NOTICE("Вы вставляете [operator_gun] в [src]."))
					mounted_gun.flags_mounted_gun_features |= GUN_MOUNTED
					name = "[mounted_gun] installed on [base_name]"
					update_icon()
			return
		else
			to_chat(user, SPAN_WARNING("В [src] место занято, для замены надо в начале снять [mounted_gun]."))

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

	src.add_fingerprint(usr)
	if(anchored && (over_object == user && (in_range(src, user) || locate(src) in user)))
		if(user.interactee == src)
			user.unset_interaction()
			visible_message("[icon2html(src, viewers(src))] [SPAN_NOTICE("[user] решил дать кому-то другому попробывать.")]")
			to_chat(usr, SPAN_NOTICE("Вы решили дать кому-то другому пострелять."))
			return
		if(operator)
			if(operator.interactee == null)
				operator = null
			else
				to_chat(user, "Кто-то уже за пушкой.")
				return
		else
			if(user.interactee)
				to_chat(user, "Вы уже делаете что-то другое!")
				return
			if(user.get_active_hand() != null)
				to_chat(user, SPAN_WARNING("Вы должны быть с пустыми руками, чтобы управлять [src]."))
			else
				visible_message("[icon2html(src, viewers(src))] [SPAN_NOTICE("[user] mans the [mounted_gun]!")]")
				to_chat(user, SPAN_NOTICE("Вы за орудием!"))
				user.set_interaction(src)

	else if(over_object == user && in_range(src, user) && !prebuild)
		if(anchored)
			to_chat(user, SPAN_WARNING("[src] не может быть снят, пока прекручен."))
			return
		if(mounted_gun)
			to_chat(user, SPAN_WARNING("[src] не может быть снят, пока на нем закреплено орудие."))
			return
		to_chat(user, SPAN_NOTICE("Вы сняли [src]."))
		var/obj/item/device/mounted_defence/tripod/mount = new(loc)
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
	UnregisterSignal(user, list(COMSIG_MOB_MG_EXIT, COMSIG_MOB_RESISTED, COMSIG_MOB_DEATH, COMSIG_LIVING_SET_BODY_POSITION,
	))

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
		var/viewoffset = mounted_gun?.build_in_zoom ? tilesize * tiles_zoom : tilesize * 2
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


/obj/structure/machinery/mounted_defence/attack_alien(mob/living/carbon/xenomorph/xeno)
	if(islarva(xeno))
		return

	xeno.visible_message(SPAN_DANGER("[xeno] ударил [src]!"),
	SPAN_DANGER("Вы бьете [src]!"))
	xeno.animation_attack_on(src)
	xeno.flick_attack_overlay(src, "slash")
	playsound(loc, "alien_claw_metal", 25)
	update_health(rand(xeno.melee_damage_lower, xeno.melee_damage_upper))
	return XENO_ATTACK_ACTION

/obj/structure/machinery/mounted_defence/update_icon()
	if(overlays)
		overlays.Cut()
	else
		overlays = list()
	if(mounted_gun)
		overlays += mounted_gun.mounted_state

/obj/structure/machinery/mounted_defence/get_examine_text(mob/user)
	. = ..()
	if(mounted_gun)
		. += "Установлено [mounted_gun], [mounted_gun.desc].<br>"
	else if(!anchored)
		. += "Оно должно быть <B>прикручено</b>.<br>"
	else
		. += "Ничего не установлено.<br>"

/obj/structure/machinery/mounted_defence/proc/handle_outside_cone(mob/living/carbon/human/user)
	return FALSE

/obj/structure/machinery/mounted_defence/clicked(mob/user, list/mods)
	if(isobserver(user)) return

	if(mods["ctrl"])
		if(operator != user)
			return
		toggle_burst()
		return 1
	return ..()

/obj/structure/machinery/mounted_defence/proc/toggle_burst()
	if(!mounted_gun) return

	if(!(mounted_gun.gun_firemode_list & GUN_FIREMODE_AUTOMATIC))
		to_chat(usr, SPAN_WARNING("Это оружие не имеет режима стрельбы очередями!"))
		return

	if(mounted_gun.flags_gun_features & GUN_BURST_FIRING)//can't toggle mid burst
		return

	playsound(usr, 'sound/weapons/handling/gun_burst_toggle.ogg', 15, 1)

	mounted_gun.do_toggle_firemode(src, null, GUN_FIREMODE_BURSTFIRE)
	to_chat(usr, SPAN_NOTICE("[icon2html(src, usr)] Вы [mounted_gun.gun_firemode == GUN_FIREMODE_BURSTFIRE ? "<B>включили</b>" : "<B>выключили</b>"] [src] режим стрельбы очередями."))


//////////////////////////////////////////////////////////////
//TIER 1													//
//////////////////////////////////////////////////////////////
/obj/structure/machinery/mounted_defence/tier_one/tripod
	mount_class = GUN_MOUNT_SMALL

/obj/structure/machinery/mounted_defence/tier_one/tripod
	name = "Триног"
	base_name = "Триног"
	desc = "Триног на который можно установить стационарное легкое вооружение."
	icon_state = "tripod"
	anchored = FALSE
	density = TRUE

	health = 300
	max_health = 300
	projectile_coverage = PROJECTILE_COVERAGE_LOW


/obj/item/device/mounted_defence
	icon = 'icons/obj/structures/barricades.dmi'
	unacidable = TRUE
	w_class = SIZE_MEDIUM

/obj/item/device/mounted_defence/tripod_frame
	name = "Заготовка Тринога"
	desc = "Почти готовый триног, который надо <B>сварить</b>."
	icon_state = "folded_tripod_frame"

/obj/item/device/mounted_defence/tripod_frame/attackby(obj/item/attacking_item as obj, mob/user as mob)
	if(HAS_TRAIT(attacking_item, TRAIT_TOOL_BLOWTORCH))
		var/obj/item/tool/weldingtool/welder = attacking_item
		if(!welder.remove_fuel(1, user))
			return

		var/obj/item/device/mounted_defence/tripod/tripod = new(user.loc)
		to_chat(user, SPAN_NOTICE("You welded [src] in [tripod]."))
		qdel(src)
		user.put_in_hands(tripod)
		return

	return ..()

/obj/item/device/mounted_defence/tripod
	name = "Триног"
	desc = "Триног на который можно установить стационарное легкое вооружение."
	icon_state = "folded_tripod"

/obj/item/device/mounted_defence/tripod/attack_self(mob/user)
	. = ..()

	if(!ishuman(usr))
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
	name = "Нест"
	desc = "Нест на который можно установить стационарное легкое вооружение"
	icon_state = "small_place_sand"
	projectile_coverage = PROJECTILE_COVERAGE_HIGH
	parrent_type_gun = /obj/item/weapon/gun/mounted/m56d_gun


//////////////////////////////////////////////////////////////
//TIER 2													//
//////////////////////////////////////////////////////////////

/obj/structure/machinery/mounted_defence/tier_two
	name = "Среднее Укрепление"
	desc = "Используется для размещения среднего стационарного вооружения."
	icon_state = "medium_place"
	mount_class = GUN_MOUNT_MEDIUM
	projectile_coverage = PROJECTILE_COVERAGE_MEDIUM


//////////////////////////////////////////////////////////////
//TIER 3													//
//////////////////////////////////////////////////////////////

/obj/structure/machinery/mounted_defence/tier_three
	name = "Дот"
	desc = "Специальная огневая позиция для тяжелого стационарного вооружения."
	icon_state = "high_place"
	mount_class = GUN_MOUNT_BIG
	projectile_coverage = PROJECTILE_COVERAGE_HIGH


//////////////////////////////////////////////////////////////
// WEAPONS													//
//////////////////////////////////////////////////////////////

//First thing we need is the ammo drum for this thing.
/obj/item/ammo_magazine/m56d
	name = "M56D drum magazine (10x28mm Caseless)"
	desc = "A box of 700, 10x28mm caseless tungsten rounds for the M56D heavy machine gun system. Just click the M56D with this to reload it."
	w_class = SIZE_MEDIUM
	icon_state = "m56d_drum"
	flags_magazine = NO_FLAGS //can't be refilled or emptied by hand
	caliber = "10x28mm"
	max_rounds = 700
	default_ammo = /datum/ammo/bullet/smartgun
	gun_type = /obj/item/weapon/gun/mounted/m56d_gun

//Now we need a box for this.
/obj/item/storage/box/m56d_hmg
	name = "\improper M56D crate"
	desc = "A large metal case with Japanese writing on the top. However it also comes with English text to the side. This is a M56D heavy machine gun, it clearly has various labeled warnings. The most major one is that this does not have IFF features due to specialized ammo."
	icon = 'icons/obj/structures/barricades.dmi'
	icon_state = "M56D_case" // I guess a placeholder? Not actually going to show up ingame for now.
	w_class = SIZE_HUGE
	storage_slots = 5

/obj/item/storage/box/m56d_hmg/Initialize()
	. = ..()
	new /obj/item/weapon/gun/mounted/m56d_gun(src) //gun itself
	new /obj/item/device/mounted_defence/tripod_frame(src) //tripod
	new /obj/item/ammo_magazine/m56d(src) //ammo for the gun
	new /obj/item/ammo_magazine/m56d(src)
	new /obj/item/tool/wrench(src)
	new /obj/item/tool/screwdriver(src)


//////////////////////////////////////////////////////////////

/obj/item/storage/box/sgl2
	name = "\improper SGL2 Assembly-Supply Crate"
	desc = "A large case labelled 'SGL2, heavy grenade launcher', seems to be fairly heavy to hold. Contains a deadly SGL2 Heavy Grenade Launching System and its ammunition."
	icon = 'icons/obj/structures/barricades.dmi'
	icon_state = "SGL2_case"
	w_class = SIZE_HUGE
	storage_slots = 5

/obj/item/storage/box/sgl2/Initialize()
	..()

	new /obj/item/weapon/gun/launcher/grenade/mounted/sgl2_gun(src) //gun itself
	new /obj/item/device/mounted_defence/tripod_frame(src) //tripod
	new /obj/item/explosive/grenade/incendiary/airburst(src) //ammo for the gun
	new /obj/item/explosive/grenade/incendiary/airburst(src)
	new /obj/item/tool/wrench(src)
	new /obj/item/tool/screwdriver(src)


//////////////////////////////////////////////////////////////

//Now we need a box for this.
/obj/item/storage/box/rct
	name = "\improper RCT Assembly-Supply Crate"
	desc = "A large case labelled 'RCT, heavy grenade launcher', seems to be fairly heavy to hold. Contains stationary rocket launcher, can be used with all types rockets. likely to destroy enemy heavy machines."
	icon = 'icons/obj/structures/barricades.dmi'
	icon_state = "RCT_case" // I guess a placeholder? Not actually going to show up ingame for now.
	w_class = SIZE_HUGE
	storage_slots = 5

/obj/item/storage/box/rct/Initialize()
	. = ..()
	new /obj/item/weapon/gun/launcher/rocket/mounted/rct_gun(src) //gun itself
	new /obj/item/device/mounted_defence/tripod_frame(src) //tripod
	new /obj/item/ammo_magazine/rocket/ap(src) //ammo for the gun
	new /obj/item/ammo_magazine/rocket/ap(src)
	new /obj/item/tool/wrench(src)
	new /obj/item/tool/screwdriver(src)
