#define CAMERA_TRAIT "camera"

/obj/effect/temp_visual/do_after_fake
	duration = 4 SECONDS
	icon = 'icons/mob/do_afters.dmi'
	icon_state = "busy_build"
	layer = 5.1

/obj/effect/temp_visual/do_after_fake/New(loc, setted_duration, needed_icon)
	icon_state = needed_icon
	duration = setted_duration
	. = ..()

/obj/effect/temp_visual/do_after_fake/Initialize()
	. = ..()
	animate(src, pixel_y = 28, time = 0.3 SECONDS, easing = SINE_EASING|EASE_IN)

/obj/structure/mineop/minecart/proc/generate_oreicon(icon, icon_state)
	var/icon/T = new(icon)
	return image(T, icon_state, layer = HUD_PLANE)

/obj/structure/mineop/minecart/proc/setup_oreicon(image/counter, counter_amount, x_shift, y_shift)
	counter.alpha = 0
	counter.plane = HUD_PLANE
	counter.maptext = "[counter_amount]"

	counter.loc = get_turf(src)

	animate(counter, alpha = 255, pixel_x = x_shift, pixel_y = y_shift, time = 0.3 SECONDS, easing = SINE_EASING|EASE_OUT)

	counter.maptext_x = counter.pixel_x
	counter.maptext_y = counter.pixel_y

/obj/structure/mineop/minecart
	name = "ore box"
	desc = "Stores minerals."

	icon = 'code_ru/code/events/mining_op/minecart.dmi'
	icon_state = "minecart"

	density = TRUE
	anchored = FALSE

	var/list/obj/structure/mineop/minerarls_drop/minerals_inside = list()

	// for countshow
	var/gold = 0
	var/image/gold_counter

	var/mat = 0
	var/image/mat_counter

	var/revealed = FALSE

/obj/structure/mineop/minecart/Moved(atom/oldloc, direction, Forced)
	. = ..()
	if(revealed)
		hide_insides()

/obj/structure/mineop/minecart/attack_hand(mob/user)
	. = ..()

	if(!revealed)
		reveal_insides()
		return TRUE
	if(revealed)
		hide_insides()
		return TRUE

/obj/structure/mineop/minecart/proc/reveal_insides()
// материала всего два, так что не хочу выёбываться листами

	revealed = TRUE

	if(gold > 0)
		gold_counter = generate_oreicon('code_ru/code/events/mining_op/mining.dmi', "o_plasma")

		setup_oreicon(gold_counter, gold, 0, 18)
		usr.client.images += gold_counter

	if(mat > 0)
		mat_counter = generate_oreicon('code_ru/code/events/mining_op/mining.dmi', "o_uranium")

		setup_oreicon(mat_counter, mat, 0, -18)
		usr.client.images += mat_counter

/obj/structure/mineop/minecart/proc/hide_insides()

	revealed = FALSE
	animate(gold_counter, alpha = 0, pixel_x = 0, pixel_y = 0, time = 0.3 SECONDS, easing = SINE_EASING|EASE_IN)
	animate(mat_counter, alpha = 0, pixel_x = 0, pixel_y = 0, time = 0.3 SECONDS, easing = SINE_EASING|EASE_IN)

	spawn(0.3 SECONDS)
		usr.client.images -= gold_counter
		usr.client.images -= mat_counter
		qdel(gold_counter)
		qdel(mat_counter)

// Консоль и пад для отправки ресурсов

/area/mineop/transport_area
	name = "Supply Dock"
	icon_state = "shuttle3"
	requires_power = 0

/obj/structure/prop/vehicles/aircraft/vtol/mineop
	alpha = 0 //изначально невидим
	layer = 5

	mouse_opacity = FALSE
	pixel_x = -64
	pixel_y = -64

	var/area/landing_zone
	var/obj/structure/mineop/fob/resource_managing_tm/terminal

/obj/structure/prop/vehicles/aircraft/vtol/mineop/Initialize(mapload, ...)
	. = ..()

	landing_zone = get_area(src)
	for(var/obj/structure/mineop/fob/resource_managing_tm/TM in landing_zone)
		terminal = TM
		TM.transporter = src

/obj/structure/prop/vehicles/aircraft/vtol/mineop/proc/flycycle()
	var/total_worth = 0

	animate(src, transform = matrix(320, MATRIX_ROTATE), pixel_y = 160, pixel_x = -160, time = 0)
	flyin()

	sleep(10 SECONDS)
	for(var/obj/structure/mineop/minecart/M in landing_zone)
		var/x_offset = (x - M.x) * 32
		var/y_offset = (y - M.y) * 32

		new /obj/effect/temp_visual/do_after_fake(get_turf(src), 2 SECONDS, "status_bar")
		animate(M, pixel_x = x_offset, pixel_y = y_offset, time = 2 SECONDS, easing = SINE_EASING)

		sleep(2 SECONDS)
		M.forceMove(src)

	sleep(10 SECONDS)
	flyout()

	for(var/obj/structure/mineop/minecart/M in contents)
		for(var/obj/structure/mineop/minerarls_drop/marine_gold/G in M.minerals_inside)
			GLOB.supply_controller.points += 4
			total_worth += 4
			M.gold -= 1
			M.minerals_inside -= G

			qdel(G)

	sleep(10 SECONDS)

	flyby()
	sleep(4 SECONDS)

	var/list/turf/candidates_list = list()
	for(var/turf/open/T in landing_zone)
		if(!length(T.contents))
			candidates_list += T

	for(var/obj/structure/mineop/minecart/M in contents)
		animate(M, transform = matrix(2, MATRIX_SCALE), alpha = 0, pixel_y = 96, pixel_x = 0, time = 0)

		M.forceMove(pick(candidates_list))
		animate(M, transform = matrix(1, MATRIX_SCALE), alpha = 255, pixel_y = 0, time = 1 SECONDS, easing = BOUNCE_EASING | EASE_OUT)

	terminal.balloon_alert_to_viewers("Оценочная стоимость текущей поставки составила...", null, DEFAULT_MESSAGE_RANGE, null, "#ffbb00")
	new /obj/effect/temp_visual/do_after_fake(get_turf(terminal), 4 SECONDS, "busy_build")

	sleep(4 SECONDS)
	terminal.balloon_alert_to_viewers("[total_worth] реквизиционных очков", null, DEFAULT_MESSAGE_RANGE, null, "#ffbb00")
	terminal.busy = FALSE

	return TRUE

/obj/structure/prop/vehicles/aircraft/vtol/mineop/proc/flyin()
	animate(src, transform = matrix(0, MATRIX_ROTATE), alpha = 255, pixel_y = -32, pixel_x = -64, time = 5 SECONDS, easing = CUBIC_EASING | EASE_IN)
	animate(pixel_y = -64, time = 1 SECONDS, easing = SINE_EASING | EASE_IN)

/obj/structure/prop/vehicles/aircraft/vtol/mineop/proc/flyout()
	animate(src, pixel_y = -32, time = 1 SECONDS, easing = SINE_EASING | EASE_OUT)
	animate(transform = matrix(40, MATRIX_ROTATE), alpha = 0, pixel_y = -192, pixel_x = 192, time = 5 SECONDS, easing = CUBIC_EASING | EASE_IN)

/obj/structure/prop/vehicles/aircraft/vtol/mineop/proc/flyby()
	animate(src, transform = matrix(0, MATRIX_ROTATE), pixel_y = 192, pixel_x = -64, time = 0)

	animate(alpha = 255, pixel_y = -96, time = 2 SECONDS, easing = LINEAR_EASING)
	animate(alpha = 0, pixel_y = -192, time = 1 SECONDS, easing = LINEAR_EASING)

/obj/structure/mineop/fob/resource_managing_tm
	name = "resource managing terminal"
	icon = 'code_ru/code/events/mining_op/managing_terminal.dmi'
	icon_state = "terminal"

	anchored = TRUE
	density = TRUE
	var/obj/structure/prop/vehicles/aircraft/vtol/mineop/transporter
	var/obj/structure/mineop/camera/camera
	var/list/obj/structure/mineop/rnd/researched_tech_list = list()

	var/busy = FALSE
	var/first_time_accessing = TRUE

/obj/structure/mineop/fob/resource_managing_tm/attack_hand(mob/user)
	. = ..()

	if(first_time_accessing)
		load_rnd_level()
		first_time_accessing = FALSE

	if(busy)
		return FALSE

	busy = TRUE
	var/list/options = list("CALL TRANSPORT" = image(icon = 'code_ru/code/events/mining_op/ui.dmi', icon_state = "Req_Radial"),
							"OPEN RESEARCH TREE" = image(icon = 'code_ru/code/events/mining_op/ui.dmi', icon_state = "RnD_Radial"))
	var/answer = show_radial_menu(user, src, options, tooltips = TRUE, radius = 30)
	if(!answer)
		busy = FALSE
		return FALSE
	switch(answer)
		if("CALL TRANSPORT")
			transporter.flycycle()
			return TRUE
		if("OPEN RESEARCH TREE")
			user.client.perspective = EYE_PERSPECTIVE
			user.client.set_eye(camera)

			camera.connected_mob = user
			ADD_TRAIT(user, TRAIT_IMMOBILIZED, CAMERA_TRAIT)
			return TRUE
