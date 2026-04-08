/obj/structure/mineop/design/drill
	name = "Ручной бур"
	desc = "Компактный ручной бур для быстрого создания путей-проходов."

	icon_state = "drill"

	buycost = 40
	buildtime = 2 SECONDS

	type_to_create = /obj/item/tool/pickaxe/mineop/drill
	design_id = "drill"
	already_researched = TRUE

/obj/item/tool/pickaxe/mineop/drill
	digging_speed = 1 SECONDS
	digging_power = 20

	icon_state = "diamonddrill"
	item_state = "jackhammer"

	var/current_temperature = 0
	var/maximum_temperature = 50

	var/overcharged = FALSE
	var/currently_in_use = FALSE

	maptext_height = 16
	maptext_width = 96
	maptext_x = 4
	maptext_y = 2

	hitsound = 'sound/effects/drill.ogg'
	drill_sound = 'sound/effects/drill.ogg'

/obj/item/tool/pickaxe/mineop/drill/Initialize(mapload, ...)
	. = ..()

	maptext = SPAN_LANGCHAT("[current_temperature]/[maximum_temperature]")
	START_PROCESSING(SSobj, src)

/obj/item/tool/pickaxe/mineop/drill/proc/update_maptext()
	maptext = SPAN_LANGCHAT("[current_temperature]/[maximum_temperature]")
	if(overcharged)
		maptext = "<span class='langchat' style='color:#ff0000'>OVERCHARGED</span>"

/obj/item/tool/pickaxe/mineop/drill/process()
	if(current_temperature > 0 && !overcharged && !currently_in_use)
		current_temperature -= 1
		update_maptext()

	if(current_temperature >= maximum_temperature && !overcharged)
		overcharged = TRUE
		digging_tool = FALSE

		update_maptext()

		playsound(loc, 'sound/effects/acid_sizzle4.ogg', 100, TRUE)
		add_filter("overcharged_outline", 1, list("type" = "outline", "color" = COLOR_RED, "size" = 1))
		addtimer(CALLBACK(src, PROC_REF(chill_out)), 20 SECONDS)

/obj/item/tool/pickaxe/mineop/drill/proc/chill_out()
	overcharged = FALSE
	digging_tool = TRUE
	current_temperature = 0

	remove_filter("overcharged_outline")
	update_maptext()

/mob/living/carbon/human/Bump(atom/obstacle)
	var/obj/item/tool/pickaxe/mineop/drill/D = get_active_hand()
	if(istype(D) && !D.overcharged)
		if(istype(obstacle, /turf/closed/wall/mineop/destructable_rock))
			var/turf/closed/wall/mineop/destructable_rock/R = obstacle
			if(!R.cannot_be_destructed_normally)
				playsound(get_turf(src), 'sound/effects/drill.ogg', 100, 1)
				D.currently_in_use = TRUE

				animation_flash_color(R, "#ffbb00")

				animate(src, transform = matrix(rand(-3,3), rand(-3,3), MATRIX_TRANSLATE), time = 0.5, easing = EASE_IN)
				for(var/i in 0 to 5)
					animate(transform = matrix(rand(-4,4), rand(-4,4), MATRIX_TRANSLATE), time = 1)
				animate(transform = matrix(0, 0, MATRIX_TRANSLATE), time = 0.5, easing = EASE_OUT)

				sleep(0.5 SECONDS)
				R.dismantle_wall()

				D.current_temperature += 5
				D.currently_in_use = FALSE
				D.update_maptext()

		if(istype(obstacle, /obj/structure/mineop/minerals))
			var/obj/structure/mineop/minerals/M = obstacle
			playsound(get_turf(src), 'sound/effects/drill.ogg', 100, 1)
			D.currently_in_use = TRUE

			animation_flash_color(M, "#ffbb00")

			animate(src, transform = matrix(rand(-3,3), rand(-3,3), MATRIX_TRANSLATE), time = 0.5, easing = EASE_IN)
			for(var/i in 0 to 5)
				animate(transform = matrix(rand(-4,4), rand(-4,4), MATRIX_TRANSLATE), time = 1)
			animate(transform = matrix(0, 0, MATRIX_TRANSLATE), time = 0.5, easing = EASE_OUT)

			sleep(0.5 SECONDS)

			M.current_minerals--
			if(M.mineral_drop)
				var/obj/mineral = new M.mineral_drop(get_turf(M))
				var/choose_dir = pick(SOUTH,NORTH,WEST,EAST)

				animate(mineral, transform = matrix(0.01, MATRIX_SCALE), time = 0)
				animate(mineral, pixel_y = 16, transform = matrix(1, MATRIX_SCALE), time = 5, easing = SINE_EASING | EASE_IN)

				switch(choose_dir)
					if(SOUTH)
						animate(mineral, pixel_y = -16, time = 3, easing = BOUNCE_EASING | EASE_OUT)
					if(NORTH)
						animate(mineral, pixel_y = 24, time = 3, easing = BOUNCE_EASING | EASE_OUT)
					if(WEST)
						animate(mineral, pixel_x = -16, pixel_y = 0, time = 3, easing = BOUNCE_EASING | EASE_OUT)
					if(EAST)
						animate(mineral, pixel_x = 16, pixel_y = 0, time = 3, easing = BOUNCE_EASING | EASE_OUT)

				spawn(10)
					mineral.throw_atom(get_step(M, choose_dir), 1, 3, M, TRUE)
					mineral.pixel_x = 0
					mineral.pixel_y = 0

			if(!M.current_minerals)
				M.balloon_alert_to_viewers("*[M] crumbles to dust*")
				QDEL_NULL(M)
				return TRUE

			M.update_icon()

			D.current_temperature += 1
			D.currently_in_use = FALSE
			D.update_maptext()

		if(isxeno(obstacle))
			var/mob/living/carbon/xenomorph/xeno = obstacle
			playsound(get_turf(src), 'sound/effects/drill.ogg', 100, 1)
			D.currently_in_use = TRUE

			animation_flash_color(xeno, "#ff0000")
			xeno.apply_damage(60, BRUTE)
			xeno.last_damage_data = create_cause_data("drilled to death", src)

			animate(src, transform = matrix(rand(-3,3), rand(-3,3), MATRIX_TRANSLATE), time = 0.5, easing = EASE_IN)
			for(var/i in 0 to 5)
				animate(transform = matrix(rand(-4,4), rand(-4,4), MATRIX_TRANSLATE), time = 1)
			animate(transform = matrix(0, 0, MATRIX_TRANSLATE), time = 0.5, easing = EASE_OUT)

			D.current_temperature += 1
			D.currently_in_use = FALSE
			D.update_maptext()

	. = ..()
