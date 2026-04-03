#define BASE_MECHA_MODULES list(\
	/obj/item/hardpoint/walker/hand/left,\
	/obj/item/hardpoint/walker/hand/right,\
	/obj/item/hardpoint/walker/leg/left,\
	/obj/item/hardpoint/walker/leg/right,\
	/obj/item/hardpoint/walker/reactor,\
	/obj/item/hardpoint/walker/reactor/enhanced,\
	/obj/item/hardpoint/walker/head,\
	/obj/item/hardpoint/walker/spinal/powerful_cooling,\
	/obj/item/hardpoint/walker/spinal/artillery,\
	/obj/item/hardpoint/walker/spinal/tactical_missile,\
	/obj/item/hardpoint/walker/spinal/shield,\
	/obj/item/hardpoint/walker/spinal/jetpack,\
	/obj/item/hardpoint/walker/armor/paladin,\
	/obj/item/hardpoint/walker/armor/concussive,\
	/obj/item/hardpoint/walker/armor/caustic,\
	/obj/item/hardpoint/walker/armor/fire,\
	/obj/item/hardpoint/walker/armor/ballistic,\
)
#define BASE_MECHA_GUNS list(/obj/item/weapon/gun/mounted/mecha_wm88, /obj/item/weapon/gun/mounted/mecha_smartgun, /obj/item/weapon/gun/mounted/mecha_shotgun8g, /obj/item/weapon/gun/mounted/mecha_hmg, /obj/item/weapon/gun/flamer/mounted/mecha_flamer, /obj/item/weapon/gun/launcher/grenade/mounted/mecha_grenade_launcher, /obj/item/weapon/gun/mounted/mecha_plasma)

/obj/vehicle/walker
	name = "CW13 \"Enforcer\" Assault Walker"
	desc = "Relatively new combat walker of \"Enforcer\"-series. Unlike its predecessor, \"Carharodon\"-series, slower, but relays on its tough armor and rapid-firing weapons."

	icon = 'code_ru/icons/obj/vehicles/mech.dmi'
	icon_state = "mech_body"

	layer = BIG_XENO_LAYER
	opacity = FALSE
	can_buckle = FALSE

	move_delay = 4
	move_max_momentum = 9
	move_turn_momentum_loss_factor = 0
	move_momentum_build_factor = 2

	hardpoints_allowed = BASE_MECHA_MODULES
	hardpoints_by_slot = list(
		WALKER_HARDPOIN_HEAD = null,
		WALKER_HARDPOIN_LEFT_HAND = null,
		WALKER_HARDPOIN_RIGHT_HAND = null,
		WALKER_HARDPOIN_LEFT_LEG = null,
		WALKER_HARDPOIN_RIGHT_LEG = null,
		WALKER_HARDPOIN_INTERNAL = null,
		WALKER_HARDPOIN_ARMOR = null,
		WALKER_HARDPOIN_SPINAL = null,
	)

	var/list/obj/item/hardpoint/walker/hardpoint_actions = list()

	req_access = list(ACCESS_MARINE_WALKER)
	unacidable = TRUE

	light_range = 8

	pixel_x = -17
	pixel_y = -22

	health = 750
	var/max_health = 750

	var/selected_group = SELECTED_GROUP_HANDS

	dmg_multipliers = list(
		"all" = 1,
		"acid" = 1.5,
		"slash" = 1,
		"bullet" = 0.5,
		"explosive" = 1.5,
		"blunt" = 0.8,
		"fire" = 0.5,
		"abstract" = 1,
	)

	misc_multipliers = list(
		"move" = 1,
		"reactor_buff" = 1,
		"scatter" = 1,
		"fire_delay" = 1,
		"same_guns_debuff" = 1,
	)

	var/list/verbs_list = list(
		/obj/vehicle/walker/proc/get_stats,
		/obj/vehicle/walker/proc/toggle_lights,
		/obj/vehicle/walker/proc/eject_magazine,
		/obj/vehicle/walker/proc/switch_weapons,
		/obj/vehicle/walker/proc/dir_look_lock,
		/obj/vehicle/walker/proc/name_walker,
	)
	var/list/actions_list = list(
		/datum/action/walker/lights,
		/datum/action/walker/eject_magazine,
		/datum/action/walker/get_stats,
		/datum/action/walker/dir_look_lock,
		/datum/action/walker/switch_weapons,
	)

	move_sounds = list(
		'code_ru/sound/vehicle/walker/mecha_step1.ogg',
		'code_ru/sound/vehicle/walker/mecha_step2.ogg',
		'code_ru/sound/vehicle/walker/mecha_step3.ogg',
		'code_ru/sound/vehicle/walker/mecha_step4.ogg',
		'code_ru/sound/vehicle/walker/mecha_step5.ogg',
	)
	turn_sounds = list(
		'code_ru/sound/vehicle/walker/mecha_turn1.ogg',
		'code_ru/sound/vehicle/walker/mecha_turn2.ogg',
		'code_ru/sound/vehicle/walker/mecha_turn3.ogg',
		'code_ru/sound/vehicle/walker/mecha_turn4.ogg',
	)
	flags_atom = FPRINT|USES_HEARING

	var/consume_energy_move = 1
	var/consume_energy_light = 2

	var/leg_pixel_y = 0
	var/legless_pixel_y = -22
	var/override_pixel_y = 0

	var/nickname


//////////////////////////////////////////////////////////////


/datum/admins/proc/spawn_mecha()
	set name = "Spawn Mecha"
	set category = "Admin.Events"

	if(!check_rights(R_ADMIN))
		return

	if(tgui_alert(src, "Are you sure you want start building mecha?", "Confirm", list("Yes", "No")) != "Yes")
		return

	var/obj/vehicle/walker/vessel = new
	for(var/slot in vessel.hardpoints_by_slot)
		var/list/hardpoints_options = list()
		for(var/obj/item/hardpoint/walker/hardpoint as anything in BASE_MECHA_MODULES)
			if(initial(hardpoint.slot) != slot)
				continue
			hardpoints_options += hardpoint

		var/obj/item/hardpoint/walker/selected_hardpoint = tgui_input_list(usr, "Select components for [slot] or skip by selecting nothing", "Mecha component", hardpoints_options)
		if(!selected_hardpoint)
			continue

		selected_hardpoint = new selected_hardpoint
		vessel.add_hardpoint(selected_hardpoint)
		if(selected_hardpoint.mount_class != GUN_MOUNT_MECHA)
			continue

		var/selected_gun = tgui_input_list(usr, "Select weapon for [slot] or skip by selecting nothing", "Mecha weapon", BASE_MECHA_GUNS)
		if(!selected_gun)
			continue

		selected_hardpoint.insert_gun(new selected_gun)

	if(tgui_alert(src, "Are you sure you want to spawn builded mecha?", "Confirm", list("Yes", "No")) != "Yes")
		qdel(vessel)// It didn't exist at this point in real world, however I want to make sure for clean removal
		return

	vessel.forceMove(get_turf(usr))
	message_admins("[key_name_admin(usr)] spawned mecha.")


//////////////////////////////////////////////////////////////


/obj/structure/walker_wreckage
	name = "CW13 wreckage"
	desc = "Remains of some unfortunate walker. Completely unrepairable."
	icon = 'code_ru/icons/obj/vehicles/mech.dmi'
	icon_state = "mech_broken"
	density = TRUE
	anchored = TRUE
	opacity = FALSE
	pixel_x = -17


//////////////////////////////////////////////////////////////


/obj/vehicle/walker/Initialize()
	. = ..()

	recalculate_hardpoints()
	START_PROCESSING(SSobj, src)

	shadow_holder = new (src)

/obj/vehicle/walker/Destroy(force)
	STOP_PROCESSING(SSobj, src)

	var/obj/item/hardpoint/walker/reactor/energy_source = hardpoints_by_slot[WALKER_HARDPOIN_INTERNAL]
	if(energy_source?.meltdown_timer_id)
		energy_source.meltdown()

	if(seats[VEHICLE_DRIVER])
		seats[VEHICLE_DRIVER].unset_interaction()

	QDEL_NULL(shadow_holder)

	. = ..()

/obj/vehicle/walker/process(delta_time)
	if(light_state)
		var/light_consuming = consume_energy_light * delta_time
		if(!can_consume_energy(light_consuming))
			light_state = FALSE
			switch_light_state(FALSE, TRUE)
		else
			consume_energy(light_consuming)

	for(var/obj/item/hardpoint/walker/selected as anything in hardpoints)
		selected.on_source_process(delta_time)

	if(seats[VEHICLE_DRIVER])
		var/mob/user = seats[VEHICLE_DRIVER]
		if(user.is_mob_incapacitated())
			visible_message(SPAN_WARNING("Warning, Pilot of [src] are incapacitated, required immediate medical assistance!"))
			return


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
	update_zoom_pixels(TRUE)
	user.visible_message(SPAN_NOTICE("[user] jumps in [src]."), SPAN_NOTICE("You jump in [src]!"))
	playsound_client(user.client, 'code_ru/sound/vehicle/walker/mecha_start.ogg', null, 20)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound_client), user.client, 'code_ru/sound/vehicle/walker/mecha_online.ogg', null, 20), 2 SECONDS)

	to_chat(user, SPAN_HELPFUL("Press LMB/MMB for use left/right weapon."))

	add_verb(user, verbs_list)
	if(user.client)
		add_verb(user.client, verbs_list)
	for(var/datum/action/action as anything in actions_list)
		give_action(user, action, null, null, src)

	RegisterSignal(user, list(COMSIG_MOB_MG_EXIT, COMSIG_MOB_RESISTED, COMSIG_MOB_DEATH), PROC_REF(exit_interaction))
	RegisterSignal(user, COMSIG_MOB_LOGIN, PROC_REF(client_login_interaction))

	for(var/obj/item/hardpoint/walker/selected as anything in hardpoints)
		selected.pilot_entered(user)
	update_icon()

/obj/vehicle/walker/proc/client_login_interaction(mob/living/user)
	SIGNAL_HANDLER

	user.client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")
	add_verb(user.client, verbs_list)

/obj/vehicle/walker/on_unset_interaction(mob/living/user)
	remove_action(user, /datum/action/human_action/mg_exit)

	if(user.client)
		user.client.mouse_pointer_icon = initial(user.client.mouse_pointer_icon)

	update_zoom_pixels(FALSE, FALSE)
	user.reset_view(null)
	seats[VEHICLE_DRIVER] = null
	user.forceMove(get_turf(src))
	user.setDir(dir)
	user.visible_message(SPAN_NOTICE("[user] jumps out of [src]."), SPAN_NOTICE("You jump out of [src]."))

	remove_verb(user, verbs_list)
	for(var/datum/action/action as anything in actions_list)
		remove_action(user, action)

	SEND_SIGNAL(src, COMSIG_GUN_INTERRUPT_FIRE)
	UnregisterSignal(user, list(COMSIG_MOB_MG_EXIT, COMSIG_MOB_RESISTED, COMSIG_MOB_DEATH, COMSIG_MOB_LOGIN))

	for(var/obj/item/hardpoint/walker/selected as anything in hardpoints)
		selected.pilot_ejected(user)
	update_icon()

/obj/vehicle/walker/proc/update_zoom_pixels(auto_provider, selected_zoom, selected_zoom_size)
	var/mob/user = seats[VEHICLE_DRIVER]
	if(!user?.client)
		return

	if(auto_provider)
		var/obj/item/hardpoint/walker/zoom_provider = hardpoints_by_slot[WALKER_HARDPOIN_SPINAL]
		if(zoom_provider)
			selected_zoom = zoom_provider.zoom
			selected_zoom_size = zoom_provider.zoom_size

	if(selected_zoom && selected_zoom_size)
		user.client.change_view(selected_zoom_size, src)
		var/tilesize = 32
		var/viewoffset = tilesize * selected_zoom_size / 2
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
	if(stat == DEAD || get_dist(user, src) > 1)
		user.unset_interaction()
		return

/obj/vehicle/walker/MouseDrop_T(mob/target, mob/living/carbon/human/user)
	. = ..()

	if(target != user || !istype(user))
		return

	if(!check_access(user.wear_id))
		to_chat(user, SPAN_DANGER("Access denied!"))
		return

	if(user.skills.get_skill_level(SKILL_POWERLOADER) <= SKILL_POWERLOADER_DEFAULT)
		to_chat(user, "You dont know how to operate it.")
		return

	if(seats[VEHICLE_DRIVER])
		to_chat(user, "There is someone occupying mecha right now.")
		return

	if(!do_after(user, 5 SECONDS, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_GENERIC, src, INTERRUPT_MOVED) || seats[VEHICLE_DRIVER])
		return

	user.drop_held_items()
	user.set_interaction(src)

/obj/vehicle/walker/hear_talk(mob/living/sourcemob, message, verb = "says", datum/language/language, italics, list/tts_heard_list)
	var/mob/driver = seats[VEHICLE_DRIVER]
	if(!driver)
		return

	if(driver != sourcemob)
		driver.hear_say(message, verb, language, "", italics, sourcemob, tts_heard_list = tts_heard_list)
		return

	var/list/mob/listeners = get_mobs_in_view(9, src)
	if(CONFIG_GET(string/tts_announce_voice))
		tts_heard_list = list(list(), list(), list())
		INVOKE_ASYNC(SStts, TYPE_PROC_REF(/datum/controller/subsystem/tts, queue_tts_message), src, message, CONFIG_GET(string/tts_announce_voice), tts_heard_list)
		listeners += driver

	var/list/mob/langchat_long_listeners = list()
	for(var/mob/listener as anything in listeners)
		if(!ishumansynth_strict(listener) && !isobserver(listener))
			listener.show_message("[src] broadcasts something, but you can't understand it.")
			continue
		tts_heard_list[1] += listener
		listener.show_message("<B>[src]</B> broadcasts, [FONT_SIZE_LARGE("\"[message]\"")]", SHOW_MESSAGE_AUDIBLE) // 2 stands for hearable message
		langchat_long_listeners += listener
	langchat_long_speech(message, langchat_long_listeners, driver.get_default_language())

/obj/vehicle/walker/proc/move_z_up(mob/user)
	if(flags_atom & NO_ZFALL)
		var/obj/item/hardpoint/walker/spinal/jetpack/flying_support = hardpoints_by_slot[WALKER_HARDPOIN_SPINAL]
		if(istype(flying_support))
			flying_support.handle_move_z_up(user, src)

/obj/vehicle/walker/proc/move_z_down(mob/user)
	if(flags_atom & NO_ZFALL)
		var/obj/item/hardpoint/walker/spinal/jetpack/flying_support = hardpoints_by_slot[WALKER_HARDPOIN_SPINAL]
		if(istype(flying_support))
			flying_support.handle_move_z_down(user, src)

/obj/vehicle/walker/proc/eject_magazine(mob/user)
	var/list/acceptible_modules = list()
	for(var/obj/item/hardpoint/walker/selected as anything in hardpoints)
		if(!selected.mounted_gun?.current_mag)
			continue
		acceptible_modules[selected.name] = selected.mounted_gun
	if(!length(acceptible_modules))
		return

	var/selected_module = tgui_input_list(user, "Select a gun to eject magazine.", "Eject Magazine", acceptible_modules)
	if(!selected_module)
		return
	var/obj/item/weapon/gun/mounted_gun = acceptible_modules[selected_module]
	if(!mounted_gun || !mounted_gun.current_mag)
		return FALSE
	mounted_gun.unload(user, TRUE)
	to_chat(user, SPAN_WARNING("WARNING! [mounted_gun] ammo magazine deployed."))
	visible_message("[src]'s system ejected used magazine.","")

// I forgot why I made this a proc and why did this way, however... ~upd 2 days later
/obj/vehicle/walker/proc/handle_weapon_groups(mob/user)
	var/selected_group_cache = selected_group
	var/obj/item/hardpoint/walker/spinal/tactical_missile/launcer = hardpoints_by_slot[WALKER_HARDPOIN_SPINAL]
	if(istype(launcer))
		if(selected_group == SELECTED_GROUP_HANDS && launcer.mounted_gun.current_mag?.current_rounds)
			selected_group = SELECTED_GROUP_SPINAL
			launcer.zoom = TRUE
			update_zoom_pixels(TRUE)
		else
			selected_group = SELECTED_GROUP_HANDS
			launcer.zoom = FALSE
			update_zoom_pixels(TRUE)
	else
		selected_group = SELECTED_GROUP_HANDS

	if(selected_group_cache == selected_group)
		return

	// Simple re-register of signals, I still don't want to do it clean way ~upd 2 days later
	// I was tired at this moment, sorry for shitcode, for now I see it this way, without coding threehundred shortcuts and mechanics for this one action
	for(var/obj/item/hardpoint/walker/selected as anything in hardpoints)
		selected.pilot_ejected(user)
		selected.pilot_entered(user)

	to_chat(user, SPAN_WARNING("New selected group is [selected_group == SELECTED_GROUP_SPINAL ? "spinal" : "hands"] weapons"))


//////////////////////////////////////////////////////////////


/obj/vehicle/walker/proc/consume_energy(amount)
	var/obj/item/hardpoint/walker/reactor/energy_source = hardpoints_by_slot[WALKER_HARDPOIN_INTERNAL]
	energy_source.fuel.fuel_amount = max(0, energy_source.fuel.fuel_amount - (amount * energy_source.conversion_rate))
	energy_source.on_consume_enegry()

/obj/vehicle/walker/proc/can_consume_energy(amount)
	var/obj/item/hardpoint/walker/reactor/energy_source = hardpoints_by_slot[WALKER_HARDPOIN_INTERNAL]
	if(!energy_source || !energy_source.turned_on || !energy_source.fuel)
		return FALSE
	if(energy_source.fuel.fuel_amount < (amount * energy_source.conversion_rate))
		return FALSE
	return TRUE

/obj/vehicle/walker/add_hardpoint(obj/item/hardpoint/added, mob/user)
	. = ..()
	if(!.)
		return
	recalculate_hardpoints()

/obj/vehicle/walker/remove_hardpoint(obj/item/hardpoint/old, mob/user)
	. = ..()
	if(!.)
		return
	recalculate_hardpoints()

/obj/vehicle/walker/pre_movement(direction)
	if(selected_group == SELECTED_GROUP_SPINAL)
		handle_weapon_groups(seats[VEHICLE_DRIVER])

	if(!can_consume_energy(consume_energy_move))
		return FALSE

	var/obj/item/hardpoint/walker/spinal/jetpack/flying_support = hardpoints_by_slot[WALKER_HARDPOIN_SPINAL]
	if(!istype(flying_support))
		flying_support = null
	if(flying_support?.performing_action)
		return FALSE

	. = ..()
	if(!.)
		return

	if(flying_support)
		update_shadow(flying_support)
	consume_energy(consume_energy_move)

/obj/vehicle/walker/try_rotate(deg)
	. = ..()
	if(!.)
		return
	shadow_holder.dir = dir
	update_zoom_pixels(TRUE)

/obj/vehicle/walker/proc/recalculate_hardpoints()
	move_delay = initial(move_delay)
	move_max_momentum = initial(move_max_momentum)
	move_momentum_build_factor = initial(move_momentum_build_factor)
	move_turn_momentum_loss_factor = initial(move_turn_momentum_loss_factor)

	var/cached_move_delay = 0
	for(var/obj/item/hardpoint/walker/selected as anything in hardpoints)
		cached_move_delay += selected.weight

	var/list/motion_realted_hardpoints = list()
	if(flags_atom & NO_ZFALL)
		motion_realted_hardpoints += hardpoints_by_slot[WALKER_HARDPOIN_SPINAL]
	else
		motion_realted_hardpoints += hardpoints_by_slot[WALKER_HARDPOIN_LEFT_LEG]
		motion_realted_hardpoints += hardpoints_by_slot[WALKER_HARDPOIN_RIGHT_LEG]

	for(var/obj/item/hardpoint/walker/motion_related as anything in motion_realted_hardpoints)
		if(!motion_related?.health)
			continue
		move_delay -= motion_related.move_delay
		move_max_momentum -= motion_related.move_max_momentum
		move_momentum_build_factor -= motion_related.move_momentum_build_factor
		move_turn_momentum_loss_factor -= motion_related.move_turn_momentum_loss_factor

	if(move_delay == initial(move_delay))
		next_move = INFINITY
	else
		if(flags_atom & NO_ZFALL)
			cached_move_delay /= 2
		move_delay += cached_move_delay
		next_move = world.time + move_delay

/obj/vehicle/walker/proc/get_pixels_y()
	. = override_pixel_y
	if(flags_atom & NO_ZFALL)
		overlays += image('code_ru/icons/obj/vehicles/mech_effects.dmi', "mech_nozzle_effect")
		. += 16
	if(hardpoints_by_slot[WALKER_HARDPOIN_LEFT_LEG] || hardpoints_by_slot[WALKER_HARDPOIN_RIGHT_LEG])
		. += leg_pixel_y
	else
		. += legless_pixel_y

/obj/vehicle/walker/update_icon()
	overlays.Cut()

	var/current_y = get_pixels_y()
	if(pixel_y != current_y)
		animate(src, pixel_y = current_y, time = UPDATE_TRANSFORM_ANIMATION_TIME)

	overlays += image(icon = icon, icon_state = "[icon_state]_effect", dir = dir)
	switch(floor((health / max_health) * 100))
		if(0)
			color = "#888888"
		if(1 to 20)
			color = "#4e4e4e"
		if(21 to 40)
			color = "#6e6e6e"
		if(41 to 60)
			color = "#8b8b8b"
		if(61 to 80)
			color = "#bebebe"
		else
			color = null

	for(var/obj/item/hardpoint/walker/hardpoint as anything in hardpoints)
		var/image/hardpoint_image = hardpoint.get_hardpoint_image()
		if(istype(hardpoint_image))
			hardpoint_image.layer = layer + hardpoint.hdpt_layer * 0.001// Lame source code, working bad above this values with objects on tiles upper
		else if(islist(hardpoint_image))
			var/list/image/hardpoint_image_list = hardpoint_image
			for(var/image/subimage as anything in hardpoint_image_list)
				subimage.layer = layer + hardpoint.hdpt_layer * 0.001
		overlays += hardpoint_image

/obj/vehicle/walker/proc/swith_visual_position(angle, pixel_shift)
	override_pixel_y = pixel_shift
	var/matrix/base = matrix()
	apply_transform(base.Turn(angle), UPDATE_TRANSFORM_ANIMATION_TIME)
	animate(src, pixel_y = get_pixels_y(), time = UPDATE_TRANSFORM_ANIMATION_TIME)
	if(flags_atom & NO_ZFALL)
		shadow_holder.apply_transform(base.Turn(angle), UPDATE_TRANSFORM_ANIMATION_TIME)
		animate(shadow_holder, pixel_y = pixel_shift, time = UPDATE_TRANSFORM_ANIMATION_TIME)


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

	var/list/resist_name = list("Bio" = "acid", "Slash" = "slash", "Bullet" = "bullet", "Explosive" = "explosive", "Fire" = "fire", "Blunt" = "blunt")
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
		hardpoint_info["hardpoint_data_additional"] = list()
		hardpoint.tgui_additional_data(hardpoint_info)


//////////////////////////////////////////////////////////////
// DAMAGE

/obj/vehicle/walker/take_damage_type(damage, type, atom/attacker, zone_selected, obj/item/hardpoint/walker/attacked_hardpoint)
	if(!damage)
		return FALSE

	// WALKER_DAMAGE_TOTAL, WALKER_DAMAGE_REMAINING
	var/list/damages_applied = list(0, damage)
	var/obj/item/hardpoint/walker/spinal/shield/projector = hardpoints_by_slot[WALKER_HARDPOIN_SPINAL]
	if(istype(projector) && projector.health && projector.take_hits(damages_applied))
		return FALSE

	damages_applied[WALKER_DAMAGE_REMAINING] *= get_dmg_multi(type)
	if(!damages_applied[WALKER_DAMAGE_REMAINING])
		return FALSE

	. = TRUE

	handle_modules_take_damage(damages_applied, type, attacker, zone_selected, attacked_hardpoint)
	if(damages_applied[WALKER_DAMAGE_REMAINING])
		damages_applied[WALKER_DAMAGE_TOTAL] += damages_applied[WALKER_DAMAGE_REMAINING]
		health = max(0, health - damages_applied[WALKER_DAMAGE_REMAINING])

	if(attacker)
		var/attacker_text = "[attacker]"
		if(ismob(attacker))
			var/mob/M = attacker
			attacker_text += " ([M.client ? M.client.ckey : "disconnected"])"
		log_attack("[src] took [damages_applied[WALKER_DAMAGE_TOTAL]] [type] damage from [attacker_text].")
	else
		log_attack("[src] took [damages_applied[WALKER_DAMAGE_TOTAL]] [type] damage.")

	if(health)
		update_icon()
	else
		var/mob/living/user = seats[VEHICLE_DRIVER]
		if(user)
			to_chat(user, SPAN_DANGER("PRIORITY ALERT! Chassis integrity failing. Systems shutting down."))
			user.unset_interaction()
		new /obj/structure/walker_wreckage(get_turf(src))
		playsound(src, 'code_ru/sound/vehicle/walker/mecha_dead.ogg', 30)
		qdel(src)

/obj/vehicle/walker/proc/handle_modules_take_damage(damages_applied, type, atom/attacker, zone_selected, obj/item/hardpoint/walker/attacked_hardpoint)
	if(!zone_selected && !attacked_hardpoint)
		var/damage_per_part = damages_applied[WALKER_DAMAGE_REMAINING] / max(length(hardpoints), 1)
		for(var/obj/item/hardpoint/walker/hardpoints_remaining as anything in hardpoints)
			if(!hardpoints_remaining.can_take_damage())
				continue
			hardpoints_remaining.take_damage_type(damages_applied, type, attacker, damage_per_part, damage_per_part)
		if(seats[VEHICLE_DRIVER])
			seated_take_damage(damages_applied[WALKER_DAMAGE_REMAINING], type, attacker, seats[VEHICLE_DRIVER])
		return

	var/obj/item/hardpoint/walker/hardpoint_armor = hardpoints_by_slot[WALKER_HARDPOIN_ARMOR]
	if(hardpoint_armor?.can_take_damage())
		hardpoint_armor.take_damage_type(damages_applied, type, attacker)

	if(!attacked_hardpoint)
		switch(zone_selected)
			if("head", "eyes", "mouth")
				attacked_hardpoint = hardpoints_by_slot[WALKER_HARDPOIN_HEAD]
			if("chest")
				attacked_hardpoint = hardpoints_by_slot[WALKER_HARDPOIN_ARMOR]
			if("groin")
				attacked_hardpoint = hardpoints_by_slot[WALKER_HARDPOIN_INTERNAL]
			if("l_leg", "l_foot")
				attacked_hardpoint = hardpoints_by_slot[WALKER_HARDPOIN_LEFT_LEG]
			if("r_leg", "r_foot")
				attacked_hardpoint = hardpoints_by_slot[WALKER_HARDPOIN_RIGHT_LEG]
			if("l_arm", "l_hand")
				attacked_hardpoint = hardpoints_by_slot[WALKER_HARDPOIN_LEFT_HAND]
			if("r_arm", "r_hand")
				attacked_hardpoint = hardpoints_by_slot[WALKER_HARDPOIN_RIGHT_HAND]
			else
				attacked_hardpoint = pick(hardpoints.Copy() - hardpoint_armor)

	if(attacked_hardpoint?.can_take_damage())
		attacked_hardpoint.take_damage_type(damages_applied, type, attacker)
		return

	if(seats[VEHICLE_DRIVER] && (zone_selected in list("head", "eyes", "mouth")))
		seated_take_damage(damages_applied[WALKER_DAMAGE_REMAINING], type, attacker, seats[VEHICLE_DRIVER])

/obj/vehicle/walker/proc/seated_take_damage(damage, type, atom/attacker, mob/living/user)
	if(isxeno(attacker))
		user.attack_alien(attacker)
	else
		user.apply_damage(damage, type == BURN ? BURN : BRUTE)

/obj/vehicle/walker/get_dmg_multi(type)
	if(!dmg_multipliers.Find(type))
		return 1
	return dmg_multipliers[type] * dmg_multipliers["all"]

/obj/vehicle/walker/ex_act(severity)
	take_damage_type(severity, "explosive")

/obj/vehicle/walker/flamer_fire_act(dam, datum/cause_data/flame_cause_data)
	take_damage_type(dam, "fire", flame_cause_data.resolve_mob())


//////////////////////////////////////////////////////////////
// ATTACKS

/obj/vehicle/walker/attackby(obj/item/attacking_item, mob/user)
	if(user.a_intent == INTENT_HARM)
		if(attacking_item.force > 40)
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
		if(!seats[VEHICLE_DRIVER])
			uninstall_hardpoint(attacking_item, user)
			return

		if(do_after(user, 5 SECONDS, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_GENERIC, src, INTERRUPT_MOVED) && seats[VEHICLE_DRIVER])
			seats[VEHICLE_DRIVER].unset_interaction()
		return

	if(iswelder(attacking_item) || HAS_TRAIT(attacking_item, TRAIT_TOOL_WRENCH))
		handle_repairs(attacking_item, user)
		return

	if(istype(attacking_item, /obj/item/fuel_cell/walker_reactor))
		var/obj/item/hardpoint/walker/reactor/walker_reactor = hardpoints_by_slot[WALKER_HARDPOIN_INTERNAL]
		walker_reactor.replace_fuel(attacking_item, user)
		return

	var/list/mecha_hands = list()
	var/obj/item/hardpoint/walker/mecha_hardpoint
	for(mecha_hardpoint as anything in hardpoints)
		if(mecha_hardpoint.mount_class == GUN_MOUNT_MECHA || mecha_hardpoint.mounted_gun)
			mecha_hands[mecha_hardpoint.name] = mecha_hardpoint
	if(!length(mecha_hands))
		return
	var/selected_module = tgui_input_list(user, "With which hardpoint you want to interact?", "Hardpoints", mecha_hands)
	if(!selected_module)
		return
	mecha_hardpoint = mecha_hands[selected_module]
	if(mecha_hardpoint.mounted_gun)
		mecha_hardpoint.try_reload(attacking_item, user)
		mecha_hardpoint.try_remove(attacking_item, user)
		return
	mecha_hardpoint.try_insert(attacking_item, user)
	return

/obj/vehicle/walker/attack_alien(mob/living/carbon/xenomorph/xeno)
	if(xeno.a_intent == INTENT_HELP && seats[VEHICLE_DRIVER])
		if(do_after(xeno, 5 SECONDS, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_GENERIC, src, INTERRUPT_MOVED) && seats[VEHICLE_DRIVER])
			seats[VEHICLE_DRIVER].unset_interaction()
		return XENO_NONCOMBAT_ACTION

	. = XENO_ATTACK_ACTION

	var/damage = xeno.melee_vehicle_damage + rand(-5,5)
	if(xeno.frenzy_aura > 0)
		damage += (xeno.frenzy_aura * FRENZY_DAMAGE_MULTIPLIER)
	if(xeno.caste == XENO_CASTE_RAVAGER || xeno.caste == XENO_CASTE_QUEEN)
		damage *= 2

	if(!damage)
		playsound(xeno, 'sound/weapons/alien_claw_swipe.ogg', 25, 1)
		xeno.visible_message(SPAN_DANGER("\The [xeno] swipes at \the [src] to no effect!"),
		SPAN_DANGER("We swipe at \the [src] to no effect!"))
		return

	xeno.animation_attack_on(src)

	if(take_damage_type(damage, "slash", xeno, check_zone(xeno.zone_selected)))
		playsound(xeno, pick('sound/effects/metalhit.ogg', "alien_claw_metal"), 25, 1)
		xeno.visible_message(SPAN_DANGER("\The [xeno] slashes \the [src]!"),
		SPAN_DANGER("We slash \the [src]!"))
		return

	playsound(xeno, 'sound/weapons/alien_claw_swipe.ogg', 25, 1)
	xeno.visible_message(SPAN_DANGER("\The [xeno] tries to slash \the [src], however their attack seems to be deflected by some sort of field!"),
	SPAN_DANGER("We try to slash \the [src], however our attack seems to be deflected by some sort of field!"))

/obj/vehicle/walker/bullet_act(obj/projectile/proj)
	var/dam_type = "bullet"
	var/damage = proj.damage
	var/ammo_flags = proj.ammo?.flags_ammo_behavior | proj.projectile_override_flags

	if(proj.runtime_iff_group && get_target_lock(proj.runtime_iff_group))
		return

	if(ammo_flags & AMMO_ANTISTRUCT|AMMO_ANTIVEHICLE)
		damage = round(damage*ANTISTRUCT_DMG_MULT_TANK)
	if(ammo_flags & AMMO_ACIDIC)
		dam_type = "acid"

	bullet_ping(proj)
	take_damage_type(damage * (0.33 + proj.ammo.penetration/100), dam_type, proj.firer)


//////////////////////////////////////////////////////////////


/obj/item/fuel_cell/walker_reactor
	name = "Enriched Uranium Rod"
	desc = "On this rod writen something like \"If you read this, DROP AND RUN\", seems like joke, unga never drop their toy! It's also rechargeable."

	icon = 'code_ru/icons/obj/items/fuel_rod.dmi'
	icon_state = "rod"

	w_class = SIZE_HUGE

	// ~30 minutes of work time under load
	fuel_amount = 24000
	max_fuel_amount = 24000

/obj/item/fuel_cell/walker_reactor/update_icon()
	return

/datum/supply_packs/walker_reactor_fuel
	name = "Enriched Uranium Fuel (x2)"
	contains = list(
		/obj/item/fuel_cell/walker_reactor,
		/obj/item/fuel_cell/walker_reactor,
	)
	cost = 20
	containertype = /obj/structure/closet/crate/ammo
	containername = "Enriched Uranium Fuel crate"
	group = "Vehicle Ammo"
















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
		playsound(src, pick(move_sounds), 60, 1)
		var/obj/structure/barricade/cade = obstacle
		var/new_dir = get_dir(src, cade) ? get_dir(src, cade) : cade.dir
		var/turf/new_loc = get_step(loc, new_dir)
		if(!new_loc.density) forceMove(new_loc)
		return

//Breaking stuff
	else if(istype(obstacle, /obj/structure/fence))
		var/obj/structure/fence/F = obstacle
		F.visible_message(SPAN_DANGER("[src.name] smashes through [F]!"))
		take_damage_type(5, "blunt")
		F.health = 0
		F.healthcheck()
	else if(istype(obstacle, /obj/structure/surface/table))
		var/obj/structure/surface/table/T = obstacle
		T.visible_message(SPAN_DANGER("[src.name] crushes [T]!"))
		take_damage_type(5, "blunt")
		T.deconstruct(TRUE)
	else if(istype(obstacle, /obj/structure/showcase))
		var/obj/structure/showcase/S = obstacle
		S.visible_message(SPAN_DANGER("[src.name] bulldozes over [S]!"))
		take_damage_type(15, "blunt")
		S.deconstruct(TRUE)
	else if(istype(obstacle, /obj/structure/window/framed))
		var/obj/structure/window/framed/W = obstacle
		W.visible_message(SPAN_DANGER("[src.name] crashes through the [W]!"))
		take_damage_type(20, "blunt")
		W.shatter_window(1)
	else if(istype(obstacle, /obj/structure/window_frame))
		var/obj/structure/window_frame/WF = obstacle
		WF.visible_message(SPAN_DANGER("[src.name] runs over the [WF]!"))
		take_damage_type(20, "blunt")
		WF.deconstruct()
	else
		..()
