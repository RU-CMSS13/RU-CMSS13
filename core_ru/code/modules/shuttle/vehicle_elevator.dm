// Animating Vehicle Elevator
/obj/docking_port/stationary/vehicle_elevator/almayer
	//Used to mirrors the turfs (and their contents) on the elevator when raising/lowering, so they don't instantly teleport or vanish.
	var/obj/effect/elevator/animation_overlay/elevator_animation

/obj/docking_port/mobile/vehicle_elevator/Initialize(mapload)
	. = ..()

	for (var/area/elevator in shuttle_areas)
		for (var/turf/open/floor/plating/plating_catwalk/wrong_catwalk in elevator)
			wrong_catwalk.ChangeTurf(/turf/open/floor/plating/bare_catwalk)

/obj/docking_port/stationary/vehicle_elevator/almayer/Initialize(mapload)
	. = ..()
	elevator_animation = new()
	SW.layer = UNDER_TURF_LAYER - 0.01
	SE.layer = UNDER_TURF_LAYER - 0.01
	NW.layer = UNDER_TURF_LAYER - 0.01
	NE.layer = UNDER_TURF_LAYER - 0.01
	SW.vis_contents += elevator_animation
	SE.vis_contents += elevator_animation
	NW.vis_contents += elevator_animation
	NE.vis_contents += elevator_animation

// Elevator leaves (stuff already moved)
/obj/docking_port/stationary/vehicle_elevator/almayer/on_departure(obj/docking_port/mobile/departing_shuttle)
	..()
	var/list/obj/effect/abstract/shit_hack_list = list()
	for (var/area/away_area in departing_shuttle.shuttle_areas)
		for(var/turf/T in away_area)
			var/obj/effect/abstract/why_should_i_do_this = new (T)
			T.layer = UNDER_TURF_LAYER - 0.01
			why_should_i_do_this.icon = T.icon
			why_should_i_do_this.icon_state = T.icon_state
			why_should_i_do_this.layer = UNDER_TURF_LAYER
			shit_hack_list += why_should_i_do_this
			elevator_animation.vis_contents += T

	for(var/turf/vis_turf in elevator_animation.vis_contents)
		for(var/atom/movable/vis_content in vis_turf.contents)
			if (istype(vis_content, /atom/movable/vehicle_light_holder))
				vis_content.vis_flags = VIS_HIDE
			vis_content.blocks_emissive = FALSE
			vis_content.update_emissive_block()

	animate(elevator_animation, pixel_x = 0, pixel_y = -160, time = 3 SECONDS)
	sleep(3 SECONDS)

	for(var/turf/vis_turf in elevator_animation.vis_contents)
		vis_turf.layer = initial(vis_turf.layer)
		for(var/atom/movable/vis_content in vis_turf.contents)
			if (istype(vis_content, /atom/movable/vehicle_light_holder))
				vis_content.vis_flags = initial(vis_content.vis_flags)
			vis_content.blocks_emissive = initial(vis_content.blocks_emissive)
			vis_content.update_emissive_block()

	elevator_animation.vis_contents.Cut()
	QDEL_LIST(shit_hack_list)

// Elevator arrives (/obj/docking_port/mobile/vehicle_elevator::ignition_time -> 5 SECONDS)
/obj/docking_port/stationary/vehicle_elevator/almayer/on_prearrival(obj/docking_port/mobile/arriving_shuttle)
	..()
	var/list/obj/effect/abstract/shit_hack_list = list()
	for (var/area/away_area in arriving_shuttle.shuttle_areas)
		for(var/turf/T in away_area)
			var/obj/effect/abstract/why_should_i_do_this = new (T)
			T.layer = UNDER_TURF_LAYER - 0.01
			why_should_i_do_this.icon = T.icon
			why_should_i_do_this.icon_state = T.icon_state
			why_should_i_do_this.layer = UNDER_TURF_LAYER
			shit_hack_list += why_should_i_do_this
			elevator_animation.vis_contents += T

	for(var/turf/vis_turf in elevator_animation.vis_contents)
		for(var/atom/movable/vis_content in vis_turf.contents)
			if (istype(vis_content, /atom/movable/vehicle_light_holder))
				vis_content.vis_flags = VIS_HIDE
			vis_content.blocks_emissive = FALSE
			vis_content.update_emissive_block()

	animate(elevator_animation, pixel_x = 0, pixel_y = 0, time = 3 SECONDS)
	sleep(3 SECONDS)

	for(var/turf/vis_turf in elevator_animation.vis_contents)
		vis_turf.layer = initial(vis_turf.layer)
		for(var/atom/movable/vis_content in vis_turf.contents)
			if (istype(vis_content, /atom/movable/vehicle_light_holder))
				vis_content.vis_flags = initial(vis_content.vis_flags)
			vis_content.blocks_emissive = initial(vis_content.blocks_emissive)
			vis_content.update_emissive_block()

	elevator_animation.vis_contents.Cut()
	QDEL_LIST(shit_hack_list)
