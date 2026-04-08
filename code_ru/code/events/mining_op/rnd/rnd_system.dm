/datum/map_template/mineop
	name = "Whatever Template"
	var/prefix = "code_ru/code/events/mining_op/rnd/"
	var/level_id = "SHOULD NEVER EXIST"

/datum/map_template/mineop/New()
	if(level_id == "SHOULD NEVER EXIST")
		stack_trace("invalid level datum")
	mappath = "[prefix][level_id].dmm"
	return ..()

/datum/map_template/mineop/basic
	name = "RND LEVEL"
	level_id = "rnd_level"

/proc/load_rnd_level()
	var/datum/map_template/mineop/template = new /datum/map_template/mineop/basic

	// Extra debug in case of in-load crashes
	log_debug("Attempting load of template [template.name] as new event Z-Level")

	var/datum/space_level/loaded = template.load_new_z()
	if(!loaded?.z_value)
		log_debug("Failed to load the template to a Z-Level! Sorry!")
		return

	var/center_x = floor(loaded.bounds[MAP_MAXX] / 2) // Technically off by 0.5 due to above +1. Whatever
	var/center_y = floor(loaded.bounds[MAP_MAXY] / 2)

	// Now notify the staff of the load - this goes in addition to the generic template load game log
	message_admins("Successfully loaded template as new Z-Level, template name: [template.name]", center_x, center_y, loaded.z_value)

/area/mineop/rnd_level
	name = "RND Tree"
	icon_state = "unknown"

	ceiling = CEILING_METAL
	requires_power = FALSE
	statistic_exempt = TRUE
	base_lighting_alpha = 255

/obj/structure/mineop/camera
	name = "CAMERA"
	desc = "..."
	mouse_opacity = FALSE
	var/obj/structure/mineop/fob/resource_managing_tm/connected_terminal
	var/mob/connected_mob

/obj/structure/mineop/camera/Initialize()
	. = ..()

	for(var/obj/structure/mineop/fob/resource_managing_tm/TM in world)
		TM.camera = src
		connected_terminal = TM

/obj/structure/mineop/rnd_exit
	name = "EXIT"
	desc = "PRESS IT TO LEAVE"

	icon = 'code_ru/code/events/mining_op/ui.dmi'
	icon_state = "move_back"
	var/obj/structure/mineop/camera/client_holder

	layer = 5
	plane = HUD_PLANE

/obj/structure/mineop/rnd_exit/Initialize()
	. = ..()

	var/area/A = get_area(src)

	for(var/obj/structure/mineop/camera/CAM in A)
		client_holder = CAM

/obj/structure/mineop/rnd_exit/clicked(mob/user, list/mods)
	. = ..()
	if(ishuman(usr))

		if(mods[LEFT_CLICK])
			client_holder.connected_mob.client.perspective = MOB_PERSPECTIVE
			client_holder.connected_mob.client.set_eye(client_holder.connected_mob)

			REMOVE_TRAIT(client_holder.connected_mob, TRAIT_IMMOBILIZED, CAMERA_TRAIT)

			client_holder.connected_terminal.busy = FALSE
			var/area/A = get_area(src)
			for(var/obj/structure/mineop/rnd/R in A)
				if(R.shown_desc)
					R.hide_more(client_holder.connected_mob)
					R.shown_desc = FALSE
				if(R.hovering)
					R.remove_filter("hover_outline")
					R.hovering = FALSE

			client_holder.connected_mob = null
			return TRUE

	return TRUE

/atom/movable/screen/fullscreen/maptext_description
	icon = null
	icon_state = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "TOP,LEFT"
	maptext_height = 480
	maptext_width = 480
	maptext = ""

	maptext_x = 8
	maptext_y = -45

/obj/structure/mineop/rnd
	name = "RESEARCH"
	desc = "RESEARCH."

	icon = 'code_ru/code/events/mining_op/ui.dmi'
	icon_state = "techtree_rnd"

	anchored = TRUE
	var/obj/structure/mineop/fob/resource_managing_tm/connected_terminal // терминал, с которого мы смотрим на древо прокачки
	var/list/obj/structure/mineop/rnd/tech_needed_list = list() // необходимые для прокачки техи

	var/buycost = 999
	var/tech_needed = "Ничего"

	var/hovering = FALSE
	var/shown_desc = FALSE

	layer = 5
	plane = HUD_PLANE
	var/atom/movable/screen/fullscreen/maptext_description/tech_desc

/obj/structure/mineop/rnd/Initialize(mapload, ...)
	. = ..()

	for(var/obj/structure/mineop/fob/resource_managing_tm/TM in world)
		connected_terminal = TM

/obj/structure/mineop/rnd/MouseEntered(location, control, params)
	. = ..()

	if(ishuman(usr))

		if(!hovering && !(src in connected_terminal.researched_tech_list))
			var/outline_color = COLOR_GREEN

			var/list/obj/structure/mineop/minerarls_drop/marine_gold/goldlist = list()
			var/area/terminal = get_area(connected_terminal)
			for(var/obj/structure/mineop/minerarls_drop/marine_gold/G in terminal)
				goldlist += G
			for(var/obj/structure/mineop/minecart/M in terminal)
				for(var/obj/structure/mineop/minerarls_drop/marine_gold/G in M.minerals_inside)
					goldlist += G


			if(length(goldlist) < buycost)
				outline_color = COLOR_YELLOW
			if(length(tech_needed_list))
				outline_color = COLOR_RED

			add_filter("hover_outline", 1, list("type" = "outline", "color" = outline_color, "size" = 1))
			hovering = TRUE

/obj/structure/mineop/rnd/MouseExited(location, control, params)
	. = ..()

	if(ishuman(usr))

		if(hovering && !(src in connected_terminal.researched_tech_list))
			remove_filter("hover_outline")
			hovering = FALSE

/obj/structure/mineop/rnd/proc/show_more(mob/user)
	animate(src, transform = matrix(2.5, MATRIX_SCALE), time = 1 SECONDS, easing = SINE_EASING | EASE_OUT)
	tech_desc = new(null, src)

	var/tech_name = "<span class='langchat langchat_yell'>[name]</span><br>"
	var/tech_info = "<span class='langchat' style='font-size: 7px;'>[desc]</span><br>"
	var/cost_and_unlockables = "<span class='langchat' style='font-size: 6px;'>ЦЕНА: [buycost], НЕОБХОДИМО: [tech_needed]</span>"

	tech_desc.maptext = tech_name + tech_info + cost_and_unlockables
	user.client.screen += tech_desc

/obj/structure/mineop/rnd/proc/hide_more(mob/user)
	animate(src, transform = matrix(1, MATRIX_SCALE), time = 1 SECONDS, easing = SINE_EASING | EASE_IN)

	tech_desc.maptext = ""
	user.client.screen -= tech_desc
	qdel(tech_desc)

/obj/structure/mineop/rnd/clicked(mob/user, list/mods)
	if(ishuman(usr))
		if(mods[LEFT_CLICK])
			if(!(src in connected_terminal.researched_tech_list))

				var/list/obj/structure/mineop/minerarls_drop/marine_gold/goldlist = list()
				var/area/terminal = get_area(connected_terminal)
				var/area/rnd = get_area(src)
				for(var/obj/structure/mineop/minerarls_drop/marine_gold/G in terminal)
					goldlist += G
				for(var/obj/structure/mineop/minecart/M in terminal)
					for(var/obj/structure/mineop/minerarls_drop/marine_gold/G in M.minerals_inside)
						goldlist += G

				if(length(goldlist) < buycost)
					animation_flash_color(src, COLOR_RED)
					return FALSE

				if(length(tech_needed_list))
					animation_flash_color(src, COLOR_RED)
					return FALSE

				animation_flash_color(src, COLOR_GREEN)

				if(shown_desc)
					hide_more()
					shown_desc = FALSE

				if(hovering)
					remove_filter("hover_outline")
					hovering = FALSE

				for(var/obj/structure/mineop/rnd/R in rnd)
					if(type in R.tech_needed_list)
						R.tech_needed_list -= type

				for(var/obj/structure/mineop/minerarls_drop/marine_gold/G in goldlist)
					qdel(G)

				for(var/obj/structure/mineop/minecart/M in terminal)
					M.recalculate_resources()

				connected_terminal.researched_tech_list += src
				add_filter("bought_outline", 1, list("type" = "outline", "color" = COLOR_GREEN, "size" = 1))
				return TRUE

		if(mods[MIDDLE_CLICK])
			if(!(src in connected_terminal.researched_tech_list))
				if(!shown_desc)
					show_more(user)
					shown_desc = TRUE
					return TRUE

				if(shown_desc)
					hide_more(user)
					shown_desc = FALSE
					return TRUE

	return ..()

/obj/structure/mineop/rnd/energy_shield
	name = "Энерго-щит"
	desc = "Капсуль, создающий временное силовое поле при детонации. Позволяет стрелять изнутри."

	buycost = 30
