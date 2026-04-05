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

	var/area/landing_zone
	var/obj/structure/mineop/fob/resource_managing_tm/terminal

/obj/structure/prop/vehicles/aircraft/vtol/mineop/Initialize(mapload, ...)
	. = ..()
	animate(src, pixel_y = 96, transform = matrix(4, MATRIX_SCALE), time = 0)

	landing_zone = get_area(src)
	for(var/obj/structure/mineop/fob/resource_managing_tm/TM in landing_zone)
		terminal = TM
		TM.transporter = src

/obj/structure/prop/vehicles/aircraft/vtol/mineop/proc/flycycle()
	flyin()

	sleep(10 SECONDS)
	for(var/obj/structure/mineop/minecart/M in landing_zone)
		M.forceMove(src)

	sleep(1 SECONDS)
	flyout()

	for(var/obj/structure/mineop/minecart/M in contents)
		for(var/obj/structure/mineop/minerarls_drop/marine_gold/G in M.minerals_inside)
			GLOB.supply_controller.points += 4
			M.gold -= 1
			M.minerals_inside -= G

			qdel(G)

	sleep(10 SECONDS)

	flyby()
	sleep(5 SECONDS)

	var/list/turf/candidates_list = list()
	for(var/turf/open/T in landing_zone)
		if(!length(T.contents))
			candidates_list += T

	for(var/obj/structure/mineop/minecart/M in contents)
		animate(M, alpha = 0, pixel_y = 64, transform = matrix(2, MATRIX_SCALE), time = 0)

		M.forceMove(pick(candidates_list))
		animate(src, alpha = 255, pixel_y = 0, transform = matrix(1, MATRIX_SCALE), time = 3 SECONDS, easing = SINE_EASING | EASE_IN)

	return TRUE

/obj/structure/prop/vehicles/aircraft/vtol/mineop/proc/flyin()
	animate(src, alpha = 255, pixel_y = 0, transform = matrix(1, MATRIX_SCALE), time = 10 SECONDS, easing = CUBIC_EASING | EASE_OUT)

/obj/structure/prop/vehicles/aircraft/vtol/mineop/proc/flyout()
	animate(src, alpha = 0, pixel_y = -96, transform = matrix(4, MATRIX_SCALE), time = 10 SECONDS, easing = CUBIC_EASING | EASE_IN)
	pixel_y = 96

/obj/structure/prop/vehicles/aircraft/vtol/mineop/proc/flyby()
	animate(src, alpha = 255, pixel_y = 0, transform = matrix(2, MATRIX_SCALE), time = 5 SECONDS, easing = CUBIC_EASING | EASE_OUT)
	animate(src, alpha = 0, pixel_y = -96, transform = matrix(4, MATRIX_SCALE), time = 5 SECONDS, easing = CUBIC_EASING | EASE_IN)

	pixel_y = 96

/obj/structure/mineop/fob/resource_managing_tm
	name = "resource managing terminal"
	icon = 'code_ru/code/events/mining_op/minecart.dmi'
	icon_state = "terminal"

	var/obj/structure/prop/vehicles/aircraft/vtol/mineop/transporter
