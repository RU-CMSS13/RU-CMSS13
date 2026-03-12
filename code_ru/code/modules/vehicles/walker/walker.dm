/////////////////
// Walker
/////////////////


/obj/vehicle/walker
	name = "CW13 \"Enforcer\" Assault Walker"
	desc = "Relatively new combat walker of \"Enforcer\"-series. Unlike its predecessor, \"Carharodon\"-series, slower, but relays on its tough armor and rapid-firing weapons."

	icon = 'code_ru/icons/obj/vehicles/mech.dmi'
	icon_state = "mech_body"

	layer = BIG_XENO_LAYER
	opacity = FALSE
	can_buckle = FALSE

	move_delay = 12
	move_max_momentum = 6
	move_turn_momentum_loss_factor = 0.25
	move_momentum_build_factor = 2.5

	hardpoints_allowed = list(
		/obj/item/hardpoint/walker/hand/left,
		/obj/item/hardpoint/walker/hand/right,
		/obj/item/hardpoint/walker/leg/left,
		/obj/item/hardpoint/walker/leg/right,
		/obj/item/hardpoint/walker/reactor,
		/obj/item/hardpoint/walker/head,
		/obj/item/hardpoint/walker/spinal/powerful_cooling,
		/obj/item/hardpoint/walker/spinal/artilery,
		/obj/item/hardpoint/walker/spinal/tactical_missile,
		/obj/item/hardpoint/walker/spinal/shield,
		/obj/item/hardpoint/walker/spinal/jetpack,
		/obj/item/hardpoint/walker/armor/paladin,
		/obj/item/hardpoint/walker/armor/concussive,
		/obj/item/hardpoint/walker/armor/caustic,
		/obj/item/hardpoint/walker/armor/fire,
		/obj/item/hardpoint/walker/armor/ballistic
	)

	req_access = list(ACCESS_MARINE_WALKER)
	unacidable = TRUE

	light_range = 8

	pixel_x = -18

	health = 500
	var/max_health = 500

	var/selected_group = SELECTED_GROUP_HANDS
	var/zoom = FALSE

	dmg_multipliers = list(
		"all" = 1,
		"acid" = 2.5,
		"slash" = 1,
		"bullet" = 0.5,
		"explosive" = 2.5,
		"blunt" = 0.8,
		"fire" = 0.5,
		"abstract" = 1
	)

	var/list/verb_list = list(
		/obj/vehicle/walker/proc/exit_walker,
		/obj/vehicle/walker/proc/toggle_lights,
		/obj/vehicle/walker/proc/toggle_zoom,
		/obj/vehicle/walker/proc/eject_magazine,
		/obj/vehicle/walker/proc/get_stats,
		/obj/vehicle/walker/proc/toggle_motion_detector,
		/obj/vehicle/walker/proc/toggle_reactor,
		/obj/vehicle/walker/proc/switch_weapons
	)

	move_sounds = list(
		'code_ru/sound/vehicle/walker/mecha_step1.ogg',
		'code_ru/sound/vehicle/walker/mecha_step2.ogg',
		'code_ru/sound/vehicle/walker/mecha_step3.ogg',
		'code_ru/sound/vehicle/walker/mecha_step4.ogg',
		'code_ru/sound/vehicle/walker/mecha_step5.ogg'
	)
	turn_sounds = list(
		'code_ru/sound/vehicle/walker/mecha_turn1.ogg',
		'code_ru/sound/vehicle/walker/mecha_turn2.ogg',
		'code_ru/sound/vehicle/walker/mecha_turn3.ogg',
		'code_ru/sound/vehicle/walker/mecha_turn4.ogg'
	)
	flags_atom = FPRINT|USES_HEARING

	//used for IFF stuff. Determined by driver. It will remember faction of a last driver. IFF-compatible rounds won't damage vehicle.
	var/vehicle_faction = ""

	var/obj/item/hardpoint/walker/reactor/power_supply = null


/obj/structure/walker_wreckage
	name = "CW13 wreckage"
	desc = "Remains of some unfortunate walker. Completely unrepairable."
	icon = 'code_ru/icons/obj/vehicles/mech.dmi'
	icon_state = "mech_broken"
	density = TRUE
	anchored = TRUE
	opacity = FALSE
	pixel_x = -18


//////////////////////////////////////////////////////////////
// INTERACTIONS

/obj/vehicle/walker/get_examine_text(mob/user)
	. = ..()

	if(!health)
		. += "It's busted!"
	else if(isobserver(user) || (ishuman(user) && (skillcheck(user, SKILL_ENGINEER, SKILL_ENGINEER_NOVICE) || skillcheck(user, SKILL_VEHICLE, SKILL_VEHICLE_CREWMAN))))
		. += "It's at [round(100 * health / max_health)]% integrity!"

/obj/vehicle/walker/proc/exit_interaction()
	SIGNAL_HANDLER

	seats[VEHICLE_DRIVER].unset_interaction()

/obj/vehicle/walker/on_set_interaction(mob/living/user)
	give_action(user, /datum/action/human_action/mg_exit)

	if(user.client)
		user.client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")

	seats[VEHICLE_DRIVER] = user
	vehicle_faction = user.faction
	user.forceMove(src)
	user.reset_view(src)
	if(zoom)
		update_pixels(TRUE)
	user.visible_message(SPAN_NOTICE("[user] jumps in [src]."), SPAN_NOTICE("You jump in [src]!"))
	playsound_client(user.client, 'code_ru/sound/vehicle/walker/mecha_start.ogg', null, 40)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound_client), user.client, 'code_ru/sound/vehicle/walker/mecha_online.ogg', null, 40), 2 SECONDS)

	to_chat(user, SPAN_HELPFUL("Press LMB/MMB for use left/right weapon."))

	if(user.client)
		add_verb(user.client, verb_list)
	RegisterSignal(user, list(COMSIG_MOB_MG_EXIT, COMSIG_MOB_RESISTED, COMSIG_MOB_DEATH, COMSIG_LIVING_SET_BODY_POSITION), PROC_REF(exit_interaction))
	RegisterSignal(user, COMSIG_MOB_LOGIN, PROC_REF(reset_interaction))

	for(var/obj/item/hardpoint/walker/selected as anything in hardpoints)
		selected.pilot_entered(user)
	update_icon()

/obj/vehicle/walker/proc/reset_interaction(mob/living/user)
	SIGNAL_HANDLER

	user.client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")
	add_verb(user.client, verb_list)

/obj/vehicle/walker/on_unset_interaction(mob/living/user)
	remove_action(user, /datum/action/human_action/mg_exit)

	if(user.client)
		user.client.mouse_pointer_icon = initial(user.client.mouse_pointer_icon)

	if(zoom)
		update_pixels(FALSE)
	user.reset_view(null)
	seats[VEHICLE_DRIVER] = null
	user.forceMove(get_turf(src))
	user.setDir(dir)
	user.visible_message(SPAN_NOTICE("[user] jumps out of [src]."), SPAN_NOTICE("You jump out of [src]."))

	if(user.client)
		remove_verb(user.client, verb_list)
	SEND_SIGNAL(src, COMSIG_GUN_INTERRUPT_FIRE)
	UnregisterSignal(user, list(COMSIG_MOB_MG_EXIT, COMSIG_MOB_RESISTED, COMSIG_MOB_DEATH, COMSIG_LIVING_SET_BODY_POSITION, COMSIG_MOB_LOGIN))

	for(var/obj/item/hardpoint/walker/selected as anything in hardpoints)
		selected.pilot_ejected(user)
	update_icon()

/obj/vehicle/walker/proc/update_pixels(selected_zoom, override_zoom)
	var/mob/user = seats[VEHICLE_DRIVER]
	if(!user.client)
		return

	if(selected_zoom)
		var/obj/item/hardpoint/walker/spinal/artilery/zoom_provider = locate() in hardpoints
		if(!zoom_provider && !override_zoom)
			return

		var/zoom_power = override_zoom ? override_zoom : zoom_provider.zoom_size
		user.client.change_view(zoom_power, src)
		var/tilesize = 32
		var/viewoffset = tilesize * zoom_power / 2
		switch(dir)
			if(NORTH)
				user.client.set_pixel_x(0)
				user.client.set_pixel_y(viewoffset)
			if(SOUTH)
				user.client.set_pixel_x(0)
				user.client.set_pixel_y(-viewoffset)
			if(EAST)
				user.client.set_pixel_x(viewoffset)
				user.client.set_pixel_y(0)
			if(WEST)
				user.client.set_pixel_x(-viewoffset)
				user.client.set_pixel_y(0)

	else
		user.client.change_view(GLOB.world_view_size, src)
		user.client.set_pixel_x(0)
		user.client.set_pixel_y(0)

/obj/vehicle/walker/check_eye(mob/living/user)
	if(user.body_position != STANDING_UP || get_dist(user,src) > 1 || user.is_mob_incapacitated())
		user.unset_interaction()

/obj/vehicle/walker/MouseDrop_T(mob/target, mob/living/carbon/human/user)
	. = ..()

	if(target != user || !istype(user))
		return

	if(user.skills.get_skill_level(SKILL_POWERLOADER) <= SKILL_POWERLOADER_DEFAULT)
		to_chat(user, "You dont know how to operate it")
		return

	if(seats[VEHICLE_DRIVER])
		to_chat(user, "There is someone occupying mecha right now.")
		return

	if(!check_access(user.wear_id))
		to_chat(user, SPAN_DANGER("Access denied!"))
		return

	if(!do_after(user, 5 SECONDS, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_GENERIC, src, INTERRUPT_MOVED) || seats[VEHICLE_DRIVER])
		return

	user.drop_held_items()
	user.set_interaction(src)


//////////////////////////////////////////////////////////////


/obj/vehicle/walker/remove_hardpoint(obj/item/hardpoint/old, mob/user)
	. = ..()
	if(!.)
		return

	recalculate_legs()

/obj/vehicle/walker/pre_movement(direction)
	if(!power_supply?.on_consume_enegry_action())
		return FALSE

	. = ..()

/obj/vehicle/walker/try_rotate(deg)
	. = ..()
	if(!.)
		return

	if(zoom && seats[VEHICLE_DRIVER])
		update_pixels(TRUE)

/obj/vehicle/walker/proc/recalculate_legs()
	move_delay = initial(move_delay)
	move_max_momentum = initial(move_max_momentum)
	move_momentum_build_factor = initial(move_momentum_build_factor)
	move_turn_momentum_loss_factor = initial(move_turn_momentum_loss_factor)

	for(var/obj/item/hardpoint/walker/leg/leggy in hardpoints)
		if(!health)
			continue

		move_delay -= leggy.move_delay
		move_max_momentum -= leggy.move_max_momentum
		move_momentum_build_factor -= leggy.move_momentum_build_factor
		move_turn_momentum_loss_factor += leggy.move_turn_momentum_loss_factor

	if(move_delay == initial(move_delay))
		next_move = INFINITY
	else
		next_move = world.time + move_delay

/obj/vehicle/walker/update_icon()
	overlays.Cut()

	for(var/obj/item/hardpoint/walker/hardpoint as anything in hardpoints)
		var/image/hardpoint_image = hardpoint.get_hardpoint_image()
		if(istype(hardpoint_image))
			hardpoint_image.layer = layer + hardpoint.hdpt_layer * 0.1
		else if(islist(hardpoint_image))
			var/list/image/hardpoint_image_list = hardpoint_image
			for(var/image/subimage as anything in hardpoint_image_list)
				subimage.layer = layer + hardpoint.hdpt_layer * 0.1
		overlays += hardpoint_image


/* In future | Future, there are some code left alone, so I just ignore it | [put here your next time update]
	if(health <= max_health)
		var/image/damage_overlay = image(icon, icon_state = "damaged_frame", layer = layer+0.1)
		damage_overlay.alpha = 255 * (1 - (health / max_health))
		overlays += damage_overlay*/


//////////////////////////////////////////////////////////////
// TGUI

/obj/vehicle/walker/ui_status(mob/user)
	. = ..()
	if(seats[VEHICLE_DRIVER] != user)
		return UI_CLOSE

/obj/vehicle/walker/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Walker")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/vehicle/walker/ui_data(mob/user)
	. = list()

	var/list/resist_name = list("Bio" = "acid", "Slash" = "slash", "Bullet" = "bullet", "Expl" = "explosive", "Blunt" = "blunt")
	var/list/resist_data_list = list()

	for(var/selected in resist_name)
		var/resist = 1 - dmg_multipliers[resist_name[selected]]
		resist_data_list += list(list(
			"name" = selected,
			"pct" = resist
		))

	.["resistance_data"] = resist_data_list
	.["integrity"] = floor(100 * health / max_health)
	.["hardpoint_data"] = list()

	for(var/obj/item/hardpoint/walker/hardpoint as anything in hardpoints)
		var/list/hardpoint_info = list()
		.["hardpoint_data"] += list(hardpoint_info)
		hardpoint_info["name"] = hardpoint.name
		hardpoint_info["postion"] = hardpoint.slot
		hardpoint.tgui_additional_data(hardpoint_info)


//////////////////////////////////////////////////////////////
// DAMAGE

/obj/vehicle/walker/take_damage_type(damage, type, atom/attacker, obj/item/hardpoint/walker/attacked_hardpoint, zone_selected)
	if(!damage)
		return

	var/list/damages_applied = list(0, damage)
	var/obj/item/hardpoint/walker/spinal/shield/projector = locate() in hardpoints
	if(projector?.take_hits(damages_applied))
		return

	damages_applied[2] *= get_dmg_multi(type)
	var/mob/living/user = seats[VEHICLE_DRIVER]
	if(zone_selected == "all")
		damage = damages_applied[2]
		user?.apply_armoured_damage(damage, ARMOR_MELEE, type == BURN ? BURN : BRUTE, null, 50)
		damages_applied[1] += damage
		for(attacked_hardpoint in hardpoints)
			if(!attacked_hardpoint.can_take_damage())
				continue
			attacked_hardpoint.take_damage_type(damages_applied, type, attacker)
			damages_applied[2] = damage
	else
		damage = handle_modules_take_damage(damages_applied, type, attacker, attacked_hardpoint, zone_selected)

	damages_applied[1] += damage
	health = max(0, health - damage)

	to_chat(user, SPAN_DANGER("ALERT! Hostile incursion detected. Chassis taking damage."))
	if(ismob(attacker))
		var/mob/M = attacker
		log_attack("[src] took [damage] [type] damage from [M] ([M.client ? M.client.ckey : "disconnected"]).")
	else
		log_attack("[src] took [damage] [type] damage from [attacker].")

	if(!health)
		if(user)
			to_chat(user, SPAN_DANGER("PRIORITY ALERT! Chassis integrity failing. Systems shutting down."))
			user.unset_interaction()
		new /obj/structure/walker_wreckage(src.loc)
		playsound(loc, 'code_ru/sound/vehicle/walker/mecha_dead.ogg', 75)
		qdel(src)
	else
		update_icon()

/obj/vehicle/walker/proc/handle_modules_take_damage(damages_applied, type, atom/attacker, obj/item/hardpoint/walker/attacked_hardpoint, zone_selected)
	var/obj/item/hardpoint/walker/hardpoint_armor = locate(/obj/item/hardpoint/walker/armor) in hardpoints
	if(hardpoint_armor?.can_take_damage())
		if(zone_selected == "chest")
			hardpoint_armor.take_damage_type(damages_applied, type, attacker, damages_applied[2], damages_applied[2])
			return
		else
			hardpoint_armor.take_damage_type(damages_applied, type, attacker)

	. = damages_applied[2]
	if(attacked_hardpoint?.can_take_damage())
		attacked_hardpoint.take_damage_type(damages_applied, type, attacker)
		return

	var/mob/living/user = seats[VEHICLE_DRIVER]
	if(zone_selected == "head" && user)
		user.apply_armoured_damage(., ARMOR_MELEE, type == BURN ? BURN : BRUTE, null, 20)
		damages_applied[1] += .
		return

	var/list/obj/item/hardpoint/walker/hardpoints_remaining = hardpoints.Copy() - attacked_hardpoint - hardpoint_armor
	for(var/length = 1 to length(hardpoints_remaining))
		attacked_hardpoint = pick(hardpoints_remaining)
		hardpoints_remaining -= attacked_hardpoint
		if(!attacked_hardpoint.can_take_damage())
			continue
		attacked_hardpoint.take_damage_type(damages_applied, type, attacker)
		break

/obj/vehicle/walker/get_dmg_multi(type)
	if(!dmg_multipliers.Find(type))
		return 1
	return dmg_multipliers[type] * dmg_multipliers["all"]

/obj/vehicle/walker/ex_act(severity)
	take_damage_type(severity, "explosive", "explosion")

/obj/vehicle/walker/flamer_fire_act(dam, datum/cause_data/flame_cause_data)
	take_damage_type(dam, "fire", flame_cause_data.resolve_mob(), null, "all")


//////////////////////////////////////////////////////////////
// ATTACKS

/obj/vehicle/walker/attackby(obj/item/attacking_item, mob/user)
	if(user.a_intent == INTENT_HARM)
		take_damage_type(attacking_item.force / 10, "blunt", user)
		return ..()

	if(istype(attacking_item, /obj/item/hardpoint/walker))
		install_hardpoint(attacking_item, user)
		return

	if(ispowerclamp(attacking_item))
		var/obj/item/powerloader_clamp/clampy = attacking_item
		if(clampy.linked_powerloader && clampy.loaded && istype(clampy.loaded, /obj/item/hardpoint/walker))
			install_hardpoint(clampy, user)
			return

	if(HAS_TRAIT(attacking_item, TRAIT_TOOL_CROWBAR) || ispowerclamp(attacking_item))
		uninstall_hardpoint(attacking_item, user)
		return

	if(iswelder(attacking_item) || HAS_TRAIT(attacking_item, TRAIT_TOOL_WRENCH))
		handle_repairs(attacking_item, user)
		return

	if(istype(attacking_item, /obj/item/fuel_cell/reactor))
		var/obj/item/hardpoint/walker/reactor/mecha_reactor = locate() in hardpoints
		mecha_reactor.replace_fuel(attacking_item, user)
		return

	var/list/mecha_hands = list()
	var/obj/item/hardpoint/walker/mecha_hardpoint
	for(mecha_hardpoint as anything in hardpoints)
		if(mecha_hardpoint.try_reload(attacking_item, user))
			return

		if(mecha_hardpoint.mount_class == GUN_MOUNT_MECHA)
			mecha_hands[mecha_hardpoint.name] = mecha_hardpoint

	var/selected_module = tgui_input_list(user, "With which hardpoint you want to interact?", "Hardpoints", mecha_hands)
	if(!selected_module)
		return

	mecha_hardpoint = mecha_hands[selected_module]

	if(mecha_hardpoint.mounted_gun)
		mecha_hardpoint.try_remove(attacking_item, user)
		return

	mecha_hardpoint.try_insert(attacking_item, user)
	return

/obj/vehicle/walker/attack_alien(mob/living/carbon/xenomorph/xeno)
	if(xeno.a_intent == INTENT_HELP && seats[VEHICLE_DRIVER])
		if(do_after(xeno, 5 SECONDS, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_GENERIC, src, INTERRUPT_MOVED) && seats[VEHICLE_DRIVER])
			seats[VEHICLE_DRIVER].unset_interaction()
			return XENO_NONCOMBAT_ACTION
		return XENO_NO_DELAY_ACTION

	var/damage = (xeno.melee_vehicle_damage + rand(-5,5)) * XENO_UNIVERSAL_VEHICLE_DAMAGEMULT
	var/damage_mult = 1
	if(xeno.caste == XENO_CASTE_RAVAGER || xeno.caste == XENO_CASTE_QUEEN)
		damage_mult = 2

	if(xeno.frenzy_aura > 0)
		damage += (xeno.frenzy_aura * FRENZY_DAMAGE_MULTIPLIER)

	xeno.animation_attack_on(src)
	if(!damage)
		playsound(xeno, 'sound/weapons/alien_claw_swipe.ogg', 25, 1)
		xeno.visible_message(SPAN_DANGER("\The [xeno] swipes at \the [src] to no effect!"),
		SPAN_DANGER("We swipe at \the [src] to no effect!"))
		return XENO_ATTACK_ACTION

	var/obj/item/hardpoint/walker/attacked_hardpoint
	switch(check_zone(xeno.zone_selected))
		if("head")
			attacked_hardpoint = locate(/obj/item/hardpoint/walker/head) in hardpoints
		if("groin")
			attacked_hardpoint = locate(/obj/item/hardpoint/walker/reactor) in hardpoints
		if("l_leg", "l_foot")
			attacked_hardpoint = locate(/obj/item/hardpoint/walker/leg/left) in hardpoints
		if("r_leg", "r_foot")
			attacked_hardpoint = locate(/obj/item/hardpoint/walker/leg/right) in hardpoints
		if("l_arm", "l_hand")
			attacked_hardpoint = locate(/obj/item/hardpoint/walker/hand/left) in hardpoints
		if("r_arm", "r_hand")
			attacked_hardpoint = locate(/obj/item/hardpoint/walker/hand/right) in hardpoints

	var/attack_msg = attacked_hardpoint ? "[attacked_hardpoint] installed on [src]" : src
	xeno.visible_message(SPAN_DANGER("\The [xeno] slashes \the [attack_msg]!"),
	SPAN_DANGER("We slash \the [attack_msg]!"))
	playsound(xeno, pick('sound/effects/metalhit.ogg', "alien_claw_metal"), 25, 1)

	take_damage_type(damage * damage_mult, "slash", xeno, attacked_hardpoint, check_zone(xeno.zone_selected))
	return XENO_ATTACK_ACTION


//////////////////////////////////////////////////////////////


/obj/item/fuel_cell/reactor
	name = "Enriched Uranium Rod"
	desc = "On this rod writen something like \"If you read this, DROP AND RUN\", seems like joke, unga never drop their toy!"

	icon = 'code_ru/icons/obj/items/fuel_rod.dmi'
	icon_state = "rod"

	w_class = SIZE_HUGE

	// ~40 minutes of work time under load
	fuel_amount = 24000
	max_fuel_amount = 24000

/obj/item/fuel_cell/reactor/update_icon()
	return

















// FOR SURE I DON'T WANT TO MESS AROUND WITH THAT FOR NOW

/obj/vehicle/walker/Bump(atom/obstacle)
	if(isxeno(obstacle))
		var/mob/living/carbon/xenomorph/xeno = obstacle

		if (xeno.mob_size >= MOB_SIZE_IMMOBILE)
			xeno.visible_message(SPAN_DANGER("\The [xeno] digs it's claws into the ground, anchoring itself in place and halting \the [src] in it's tracks!"),
				SPAN_DANGER("You dig your claws into the ground, stopping \the [src] in it's tracks!")
			)
			return

		switch(xeno.tier)
			if(1)
				xeno.visible_message(
					SPAN_DANGER("\The [src] smashes at [xeno], bringing him down!"),
					SPAN_DANGER("You got smashed by walking metal box!")
				)
				xeno.AdjustKnockDown(0.2 SECONDS)
				xeno.apply_damage(round((max_health / 100) * VEHICLE_TRAMPLE_DAMAGE_MIN), BRUTE)
				xeno.last_damage_data = create_cause_data("[initial(name)] roadkill", seats[VEHICLE_DRIVER])
				var/mob/living/driver = seats[VEHICLE_DRIVER]
				log_attack("[key_name(xeno)] was rammed by [key_name(driver)] with [src].")
			if(2)
				xeno.visible_message(
					SPAN_DANGER("\The [src] smashes at [xeno], shoving it away!"),
					SPAN_DANGER("You got smashed by walking metal box!")
				)
				var/direction_taken = pick(45, 0, -45)
				var/mob_moved = step(xeno, turn(last_move_dir, direction_taken))

				if(!mob_moved)
					mob_moved = step(xeno, turn(last_move_dir, -direction_taken))
			if(3)
				xeno.visible_message(SPAN_DANGER("\The [xeno] digs it's claws into the ground, anchoring itself in place and halting \the [src] in it's tracks!"),
					SPAN_DANGER("You dig your claws into the ground, stopping \the [src] in it's tracks!")
				)
		return
	if(istype(obstacle, /obj/structure/machinery/door))
		var/obj/structure/machinery/door/door = obstacle
		if(door.allowed(seats[VEHICLE_DRIVER]))
			door.open()
		else
			flick("door_deny", door)

	else if(ishuman(obstacle))
		step_away(obstacle, src, 0)
		return

	else if(istype(obstacle, /obj/structure/barricade))
		playsound(src.loc, pick(move_sounds), 60, 1)
		var/obj/structure/barricade/cade = obstacle
		var/new_dir = get_dir(src, cade) ? get_dir(src, cade) : cade.dir
		var/turf/new_loc = get_step(loc, new_dir)
		if(!new_loc.density) forceMove(new_loc)
		return

//Breaking stuff
	else if(istype(obstacle, /obj/structure/fence))
		var/obj/structure/fence/F = obstacle
		F.visible_message(SPAN_DANGER("[src.name] smashes through [F]!"))
		take_damage_type(5, "blunt", obstacle)
		F.health = 0
		F.healthcheck()
	else if(istype(obstacle, /obj/structure/surface/table))
		var/obj/structure/surface/table/T = obstacle
		T.visible_message(SPAN_DANGER("[src.name] crushes [T]!"))
		take_damage_type(5, "blunt", obstacle)
		T.deconstruct(TRUE)
	else if(istype(obstacle, /obj/structure/showcase))
		var/obj/structure/showcase/S = obstacle
		S.visible_message(SPAN_DANGER("[src.name] bulldozes over [S]!"))
		take_damage_type(15, "blunt", obstacle)
		S.deconstruct(TRUE)
	else if(istype(obstacle, /obj/structure/window/framed))
		var/obj/structure/window/framed/W = obstacle
		W.visible_message(SPAN_DANGER("[src.name] crashes through the [W]!"))
		take_damage_type(20, "blunt", obstacle)
		W.shatter_window(1)
	else if(istype(obstacle, /obj/structure/window_frame))
		var/obj/structure/window_frame/WF = obstacle
		WF.visible_message(SPAN_DANGER("[src.name] runs over the [WF]!"))
		take_damage_type(20, "blunt", obstacle)
		WF.deconstruct()
	else
		..()




//Differentiates between damage types from different bullets
//Applies a linear transformation to bullet damage that will generally decrease damage done
/obj/vehicle/walker/bullet_act(obj/projectile/P)
	var/dam_type = "bullet"
	var/damage = P.damage
	var/ammo_flags = P.ammo.flags_ammo_behavior | P.projectile_override_flags
	var/penetration = P.ammo.penetration
	var/firer = P.firer

	//IFF bullets magically stop themselves short of hitting friendly vehicles,
	//because both sentries and smartgun users keep trying to shoot through them
	if(P.runtime_iff_group && get_target_lock(P.runtime_iff_group))
		return

	if(ammo_flags & AMMO_ANTISTRUCT|AMMO_ANTIVEHICLE)
		// Multiplier based on tank railgun relationship, so might have to reconsider multiplier for AMMO_SIEGE in general
		damage = round(damage*ANTISTRUCT_DMG_MULT_TANK)
	if(ammo_flags & AMMO_ACIDIC)
		dam_type = "acid"

	bullet_ping(P)

	take_damage_type(damage * (0.33 + penetration/100), dam_type, firer)

	healthcheck()


/obj/vehicle/walker/Collided(atom/A)
	. = ..()

	var/mob/living/carbon/xenomorph/crusher/crusher = A
	if(istype(crusher))
		if(!crusher.throwing)
			return

		if(health > 0)
			take_damage_type(250, "blunt", crusher)
			visible_message(SPAN_DANGER("\The [crusher] rams \the [src]!"))
			Move(get_step(src, crusher.dir))
		playsound(loc, 'code_ru/sound/vehicle/walker/mecha_crusher.ogg', 35)

/obj/vehicle/walker/hear_talk(mob/living/sourcemob, message, verb = "says", datum/language/language, italics, list/tts_heard_list)
	var/mob/driver = seats[VEHICLE_DRIVER]
	if (driver == null)
		return
	else if (driver != sourcemob)
		driver.hear_say(message, verb, language, "", italics, sourcemob, tts_heard_list = tts_heard_list)
	else
		var/list/mob/listeners = get_mobs_in_view(9,src)

		var/list/mob/langchat_long_listeners = list()
		listeners += driver
		for(var/mob/listener in listeners)
			if(!ishumansynth_strict(listener) && !isobserver(listener))
				listener.show_message("[src] broadcasts something, but you can't understand it.")
				continue
			listener.show_message("<B>[src]</B> broadcasts, [FONT_SIZE_LARGE("\"[message]\"")]", SHOW_MESSAGE_AUDIBLE) // 2 stands for hearable message
			langchat_long_listeners += listener
		langchat_long_speech(message, langchat_long_listeners, driver.get_default_language())

//to handle IFF bullets
/obj/vehicle/walker/proc/get_target_lock(access_to_check)
	if(isnull(access_to_check) || !vehicle_faction)
		return FALSE

	if(!islist(access_to_check))
		return access_to_check == vehicle_faction

	return vehicle_faction in access_to_check
