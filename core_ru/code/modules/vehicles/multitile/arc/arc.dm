/obj/vehicle/multitile/arc_ru
	name = "\improper M540-B Armored Recon Carrier"
	desc = "An M540-B Armored Recon Carrier. A lightly armored reconnaissance and intelligence vehicle. Entrances on the sides."

	icon = 'icons/obj/vehicles/arc.dmi'
	icon_state = "arc_base"
	pixel_x = -48
	pixel_y = -48

	bound_width = 96
	bound_height = 96

	bound_x = -32
	bound_y = -32

	health = 800

	interior_map = /datum/map_template/interior/arcru

	passengers_slots = 2 // 5 total. Reserved slots are added to passenger slots.
	xenos_slots = 4

	entrances = list(
		"right" = list(-2, 0),
	)

	entrance_speed = 0.5 SECONDS

	required_skill = SKILL_VEHICLE_LARGE

	movement_sound = 'sound/vehicles/tank_driving.ogg'

	luminosity = 7

	hardpoints_allowed = list(
		/obj/item/hardpoint/locomotion/arc_wheels,
		/obj/item/hardpoint/primary/arc_sentry,
		/obj/item/hardpoint/support/arc_antenna,
	)

	seats = list(
		VEHICLE_DRIVER = null,
	)

	active_hp = list(
		VEHICLE_DRIVER = null,
	)

	vehicle_flags = VEHICLE_CLASS_LIGHT

	mob_size_required_to_hit = MOB_SIZE_XENO

	dmg_multipliers = list(
		"all" = 1,
		"acid" = 1.8,
		"slash" = 1.1,
		"bullet" = 0.6,
		"explosive" = 0.8,
		"blunt" = 0.8,
		"abstract" = 1,
	)

	move_max_momentum = 2.2
	move_momentum_build_factor = 1.5
	move_turn_momentum_loss_factor = 0.8

	vehicle_ram_multiplier = VEHICLE_TRAMPLE_DAMAGE_APC_REDUCTION

	/// If the ARC has its antenna up, making it unable to move but enabling the turret and sensor wallhack
	var/antenna_deployed = FALSE
	/// How long it takes to deploy or retract the antenna
	var/antenna_toggle_time = 10 SECONDS
	/// Range of the ARC's xenomorph wallhacks
	var/sensor_radius = 45
	/// weakrefs of xenos temporarily added to the marine minimap
	var/list/minimap_added = list()

/obj/vehicle/multitile/arc_ru/Initialize()
	. = ..()

	var/turf/gotten_turf = get_turf(src)
	if(gotten_turf?.z)
		SSminimaps.add_marker(src, gotten_turf.z, MINIMAP_FLAG_USCM, "arc", 'icons/ui_icons/map_blips_large.dmi')

	RegisterSignal(src, COMSIG_ARC_ANTENNA_TOGGLED, PROC_REF(on_antenna_toggle))

/obj/vehicle/multitile/arc_ru/crew_mousedown(datum/source, atom/object, turf/location, control, params)
	var/list/modifiers = params2list(params)
	if(modifiers[SHIFT_CLICK] || modifiers[MIDDLE_CLICK] || modifiers[RIGHT_CLICK] || modifiers[BUTTON4] || modifiers[BUTTON5]) //don't step on examine, point, etc
		return

	switch(get_mob_seat(source))
		if(VEHICLE_DRIVER)
			if(modifiers[LEFT_CLICK] && modifiers[CTRL_CLICK])
				activate_horn()

/obj/vehicle/multitile/arc_ru/get_examine_text(mob/user)
	. = ..()
	if(!isxeno(user))
		return

	if(health > 0)
		. += SPAN_XENO("[src] can be crawled under once destroyed.")
	else
		. += SPAN_XENO("[src] can be crawled under by <b>dragging our sprite</b> to it.")

/obj/vehicle/multitile/arc_ru/proc/on_antenna_toggle(datum/source)
	SIGNAL_HANDLER

	if(antenna_deployed)
		START_PROCESSING(SSslowobj, src)

	else
		STOP_PROCESSING(SSslowobj, src)

/obj/vehicle/multitile/arc_ru/process()
	var/turf/arc_turf = get_turf(src)
	if((health <= 0) || !visible_in_tacmap || !is_ground_level(arc_turf.z))
		return

	var/obj/item/hardpoint/support/arc_antenna/antenna = locate() in hardpoints
	if(!antenna || (antenna.health <= 0))
		for(var/datum/weakref/xeno as anything in minimap_added)
			SSminimaps.remove_marker(xeno.resolve())
			minimap_added.Remove(xeno)
		return

	for(var/mob/living/carbon/xenomorph/current_xeno as anything in GLOB.living_xeno_list)
		var/turf/xeno_turf = get_turf(current_xeno)
		if(!is_ground_level(xeno_turf.z))
			continue

		var/datum/weakref/xeno_weakref = WEAKREF(current_xeno)

		if(get_dist(src, current_xeno) <= sensor_radius)
			if(xeno_weakref in minimap_added)
				continue

			SSminimaps.remove_marker(current_xeno)
			current_xeno.add_minimap_marker(MINIMAP_FLAG_USCM|MINIMAP_FLAG_XENO)
			minimap_added += xeno_weakref
		else if(xeno_weakref in minimap_added)
			SSminimaps.remove_marker(current_xeno)
			current_xeno.add_minimap_marker()
			minimap_added -= xeno_weakref

/obj/vehicle/multitile/arc_ru/relaymove(mob/user, direction)
	if(antenna_deployed)
		return FALSE

	return ..()

/obj/vehicle/multitile/arc_ru/load_role_reserved_slots()
	var/datum/role_reserved_slots/RRS = new
	RRS.category_name = "CIC Officer"
	RRS.roles = list(JOB_SO, JOB_SEA, JOB_XO, JOB_CO, JOB_GENERAL)
	RRS.total = 2
	role_reserved_slots += RRS

	RRS = new
	RRS.category_name = "Intelligence Officer"
	RRS.roles = list(JOB_INTEL)
	RRS.total = 1
	role_reserved_slots += RRS

/obj/vehicle/multitile/arc_ru/set_seated_mob(seat, mob/living/M)
	. = ..()
	if(!.)
		return

	give_action(M, /datum/action/human_action/toggle_arc_antenna_ru)

/obj/vehicle/multitile/arc_ru/add_seated_verbs(mob/living/M, seat)
	if(!M.client)
		return
	add_verb(M.client, list(
		/obj/vehicle/multitile/proc/get_status_info,
		/obj/vehicle/multitile/arc_ru/proc/open_arc_controls_guide,
		/obj/vehicle/multitile/proc/toggle_door_lock,
		/obj/vehicle/multitile/proc/activate_horn,
		/obj/vehicle/multitile/proc/name_vehicle,
		/obj/vehicle/multitile/arc_ru/proc/toggle_antenna,
	))

/obj/vehicle/multitile/arc_ru/remove_seated_verbs(mob/living/M, seat)
	if(!M.client)
		return
	remove_verb(M.client, list(
		/obj/vehicle/multitile/proc/get_status_info,
		/obj/vehicle/multitile/arc_ru/proc/open_arc_controls_guide,
		/obj/vehicle/multitile/proc/toggle_door_lock,
		/obj/vehicle/multitile/proc/activate_horn,
		/obj/vehicle/multitile/proc/name_vehicle,
		/obj/vehicle/multitile/arc_ru/proc/toggle_antenna,
	))
	SStgui.close_user_uis(M, src)

/obj/vehicle/multitile/arc_ru/initialize_cameras(change_tag = FALSE)
	if(!camera)
		camera = new /obj/structure/machinery/camera/vehicle(src)
	if(change_tag)
		camera.c_tag = "#[rand(1,100)] M540-B \"[nickname]\" ARC"
		if(camera_int)
			camera_int.c_tag = camera.c_tag + " interior"
	else
		camera.c_tag = "#[rand(1,100)] M540-B ARC"
		if(camera_int)
			camera_int.c_tag = camera.c_tag + " interior"

/obj/vehicle/multitile/arc_ru/MouseDrop_T(mob/M, mob/user)
	. = ..()
	if((M != user) || !isxeno(user))
		return

	if(health > 0)
		to_chat(user, SPAN_XENO("We can't go under [src] until it is destroyed!"))
		return

	var/turf/current_turf = get_turf(user)
	var/dir_to_go = get_dir(current_turf, src)
	for(var/i in 1 to 3)
		current_turf = get_step(current_turf, dir_to_go)
		if(!(current_turf in locs))
			break

		if(current_turf.density)
			to_chat(user, SPAN_XENO("The path under [src] is obstructed!"))
			return

	// Now we check to make sure the turf on the other side of the ARC isn't dense too
	current_turf = get_step(current_turf, dir_to_go)
	if(current_turf.density)
		to_chat(user, SPAN_XENO("The path under [src] is obstructed!"))
		return

	to_chat(user, SPAN_XENO("We begin to crawl under [src]..."))
	if(!do_after(user, 3 SECONDS, INTERRUPT_ALL, BUSY_ICON_HOSTILE))
		to_chat(user, SPAN_XENO("We stop crawling under [src]."))
		return

	user.forceMove(current_turf)
	to_chat(user, SPAN_XENO("We crawl to the other side of [src]."))

/*
** PRESETS SPAWNERS
*/
/obj/effect/vehicle_spawner/arc_ru
	name = "ARC Transport Spawner"
	icon = 'icons/obj/vehicles/apc.dmi'
	icon_state = "apc_base"
	pixel_x = -48
	pixel_y = -48

/obj/effect/vehicle_spawner/arc_ru/Initialize()
	. = ..()
	spawn_vehicle()
	return INITIALIZE_HINT_QDEL

/obj/effect/vehicle_spawner/arc_ru/spawn_vehicle()
	var/obj/vehicle/multitile/arc_ru/ARC = new (loc)

	load_misc(ARC)
	load_hardpoints(ARC)
	handle_direction(ARC)
	ARC.update_icon()

/obj/effect/vehicle_spawner/arc_ru/load_hardpoints(obj/vehicle/multitile/arc/vehicle)
	vehicle.add_hardpoint(new /obj/item/hardpoint/locomotion/arc_wheels)
	vehicle.add_hardpoint(new /obj/item/hardpoint/primary/arc_sentry)
	vehicle.add_hardpoint(new /obj/item/hardpoint/support/arc_antenna/ru)

/obj/item/hardpoint/support/arc_antenna/ru

/obj/item/hardpoint/support/arc_antenna/ru/deploy_antenna()
	set waitfor = FALSE

	disp_icon_state = ""
	if(owner)
		owner.update_icon()
		var/obj/dummy_obj = new()
		dummy_obj.icon = 'icons/obj/vehicles/arc.dmi'
		dummy_obj.icon_state = "antenna_cover_0"
		dummy_obj.dir = owner.dir
		dummy_obj.vis_flags = VIS_INHERIT_ID | VIS_INHERIT_LAYER | VIS_INHERIT_PLANE
		owner.vis_contents += dummy_obj
		flick("antenna_extending", dummy_obj)
		sleep(deploy_animation_time)
		qdel(dummy_obj)
	disp_icon_state = initial(disp_icon_state)

/obj/item/hardpoint/support/arc_antenna/ru/retract_antenna()
	set waitfor = FALSE

	disp_icon_state = ""
	if(owner)
		owner.update_icon()
		var/obj/dummy_obj = new()
		dummy_obj.icon = 'icons/obj/vehicles/arc.dmi'
		dummy_obj.icon_state = "antenna_cover_0"
		dummy_obj.dir = owner.dir
		dummy_obj.vis_flags = VIS_INHERIT_ID | VIS_INHERIT_LAYER | VIS_INHERIT_PLANE
		owner.vis_contents += dummy_obj
		flick("antenna_retracting", dummy_obj)
		sleep(deploy_animation_time)
		qdel(dummy_obj)
	disp_icon_state = initial(disp_icon_state)

/obj/item/hardpoint/support/arc_antenna/ru/get_icon_image(x_offset, y_offset, new_dir)
	var/is_broken = health <= 0
	var/antenna_extended = FALSE
	if(istype(owner, /obj/vehicle/multitile/arc_ru))
		var/obj/vehicle/multitile/arc_ru/arc_owner = owner
		antenna_extended = arc_owner.antenna_deployed

	var/image/antenna_img = image(icon = disp_icon, icon_state = "[disp_icon_state]_[antenna_extended ? "extended" : "cover"]_[is_broken ? "1" : "0"]", pixel_x = x_offset, pixel_y = y_offset, dir = new_dir)
	switch(floor((health / initial(health)) * 100))
		if(0)
			antenna_img.color = "#888888"
		if(1 to 20)
			antenna_img.color = "#4e4e4e"
		if(21 to 40)
			antenna_img.color = "#6e6e6e"
		if(41 to 60)
			antenna_img.color = "#8b8b8b"
		if(61 to 80)
			antenna_img.color = "#bebebe"
		else
			antenna_img.color = null
	return antenna_img

/obj/item/hardpoint/support/arc_antenna/ru/can_be_removed(mob/remover)
	var/obj/vehicle/multitile/arc_ru/arc_owner = owner
	if(!istype(arc_owner))
		return TRUE

	if(arc_owner.antenna_deployed)
		to_chat(remover, SPAN_WARNING("[src] cannot be removed from [owner] while it is deployed."))
		return FALSE

	return ..()

/obj/item/hardpoint/support/arc_antenna/ru/on_destroy()
	var/obj/vehicle/multitile/arc_ru/arc_owner = owner
	if(!istype(arc_owner))
		return

	if(arc_owner.antenna_deployed)
		retract_antenna()
		addtimer(CALLBACK(arc_owner, TYPE_PROC_REF(/obj/vehicle/multitile/arc, finish_antenna_retract)), deploy_animation_time)


/datum/action/human_action/toggle_arc_antenna_ru
	name = "Toggle Sensor Antenna"
	action_icon_state = "recoil_compensation"

/datum/action/human_action/toggle_arc_antenna_ru/give_to(mob/user)
	. = ..()
	RegisterSignal(user, COMSIG_MOB_RESET_VIEW, PROC_REF(remove_from))

/datum/action/human_action/toggle_arc_antenna_ru/remove_from(mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_MOB_RESET_VIEW)

/datum/action/human_action/toggle_arc_antenna_ru/action_activate()
	. = ..()
	if(!can_use_action())
		return

	var/mob/living/carbon/human/human_user = owner
	if(istype(human_user.buckled, /obj/structure/bed/chair/comfy/vehicle))
		var/obj/structure/bed/chair/comfy/vehicle/vehicle_chair = human_user.buckled
		if(istype(vehicle_chair.vehicle, /obj/vehicle/multitile/arc_ru))
			var/obj/vehicle/multitile/arc_ru/vehicle = vehicle_chair.vehicle
			vehicle.toggle_antenna(human_user)


