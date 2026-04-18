// спавн з-уровня для ресёрча и создания ивентовых предметов, появляется при первом взаимодействии с одной из двух консолей

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

// зоны

/area/mineop/rnd_level
	name = "RND Tree"
	icon_state = "unknown"

	ceiling = CEILING_METAL
	requires_power = FALSE
	statistic_exempt = TRUE
	base_lighting_alpha = 255

/area/mineop/fabric_level
	name = "Fabrication Center"
	icon_state = "unknown"

	ceiling = CEILING_METAL
	requires_power = FALSE
	statistic_exempt = TRUE
	base_lighting_alpha = 255

// камера для взаимодействия с новым з-уровнем

/obj/structure/mineop/camera
	name = "CAMERA"
	desc = "..."
	mouse_opacity = FALSE
	var/connected_to_level = "rnd"
	var/obj/structure/mineop/fob/resource_managing_tm/connected_terminal
	var/obj/structure/mineop/fob/fabricator/connected_fabricator
	var/mob/connected_mob

/obj/structure/mineop/camera/Initialize()
	. = ..()

	if(connected_to_level == "rnd")
		for(var/obj/structure/mineop/fob/resource_managing_tm/TM in world)
			TM.camera = src
			connected_terminal = TM

	if(connected_to_level == "fab")
		for(var/obj/structure/mineop/fob/fabricator/F in world)
			F.camera = src
			connected_fabricator = F

/obj/structure/mineop/camera/fab
	connected_to_level = "fab"

// кнопка выхода с з-лвла

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

			if(client_holder.connected_to_level == "rnd")
				client_holder.connected_terminal.busy = FALSE
			if(client_holder.connected_to_level == "fab")
				client_holder.connected_fabricator.busy = FALSE

			var/area/A = get_area(src)
			if(client_holder.connected_to_level == "rnd")
				for(var/obj/structure/mineop/rnd/R in A)
					if(R.shown_desc)
						R.hide_more(client_holder.connected_mob)
						R.shown_desc = FALSE
					if(R.hovering)
						R.remove_filter("hover_outline")
						R.hovering = FALSE

			if(client_holder.connected_to_level == "fab")
				for(var/obj/structure/mineop/design/D in A)
					if(D.hovering)
						D.remove_filter("hover_outline")
						D.hide_name_and_cost(client_holder.connected_mob)
						D.hovering = FALSE

			client_holder.connected_mob = null
			return TRUE

	return TRUE

// маптекст для данных по техам

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

// визуализация техов

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
	var/tech_id = "none"

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
					hide_more(user)
					shown_desc = FALSE

				if(hovering)
					remove_filter("hover_outline")
					hovering = FALSE

				for(var/obj/structure/mineop/rnd/R in rnd)
					if(type in R.tech_needed_list)
						R.tech_needed_list -= type

				var/remove_that_much = buycost
				for(var/obj/structure/mineop/minerarls_drop/marine_gold/G in goldlist)
					if(remove_that_much > 0)
						remove_that_much -= 1
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

// визуализация дизайнов

/obj/structure/mineop/design
	name = "DESIGN"
	desc = "DESIGN."

	icon = 'code_ru/code/events/mining_op/ui.dmi'
	icon_state = "back"

	anchored = TRUE
	var/obj/structure/mineop/fob/resource_managing_tm/connected_terminal
	var/obj/structure/mineop/fob/fabricator/connected_fabricator
	var/buycost = 999
	var/buildtime = 3 SECONDS

	var/type_to_create

	var/hovering = FALSE

	layer = 5
	plane = HUD_PLANE
	var/atom/movable/screen/fullscreen/maptext_description/des_desc
	var/design_id = "none"
	var/already_researched = FALSE

/obj/structure/mineop/design/Initialize(mapload, ...)
	. = ..()

	for(var/obj/structure/mineop/fob/resource_managing_tm/TM in world)
		connected_terminal = TM

	for(var/obj/structure/mineop/fob/fabricator/F in world)
		connected_fabricator = F

/obj/structure/mineop/design/MouseEntered(location, control, params)
	. = ..()

	if(ishuman(usr))
		if(!hovering)
			var/outline_color = COLOR_GREEN
			var/researched = FALSE
			var/obj/structure/mineop/fob/fabricator_hatch/free_hatch

			for(var/obj/structure/mineop/fob/fabricator_hatch/H in connected_fabricator.hatches)
				if(H.busy)
					continue
				free_hatch = H

			var/list/obj/structure/mineop/minerarls_drop/marine_mat/matlist = list()
			var/area/fab = get_area(connected_fabricator)
			for(var/obj/structure/mineop/minerarls_drop/marine_mat/T in fab)
				matlist += T
			for(var/obj/structure/mineop/minecart/M in fab)
				for(var/obj/structure/mineop/minerarls_drop/marine_mat/T in M.minerals_inside)
					matlist += T

			for(var/obj/structure/mineop/rnd/R in connected_terminal.researched_tech_list)
				if(R.tech_id == design_id)
					researched = TRUE

			if(already_researched)
				researched = TRUE

			if(length(matlist) < buycost)
				outline_color = COLOR_YELLOW
			if(!free_hatch)
				outline_color = COLOR_YELLOW
			if(!researched)
				outline_color = COLOR_RED

			add_filter("hover_outline", 1, list("type" = "outline", "color" = outline_color, "size" = 1))
			reveal_name_and_cost(usr)
			hovering = TRUE

/obj/structure/mineop/design/MouseExited(location, control, params)
	. = ..()

	if(ishuman(usr))
		if(hovering)
			remove_filter("hover_outline")
			hide_name_and_cost(usr)
			hovering = FALSE

/obj/structure/mineop/design/proc/reveal_name_and_cost(mob/user)
	des_desc = new(null, src)
	var/des_name = "<span class='langchat langchat_yell'>[name]</span><br>"
	var/des_info = "<span class='langchat' style='font-size: 7px;'>ЦЕНА: [buycost] ВРЕМЯ ПРОИЗВОДСТВА: [buildtime]</span>"

	des_desc.maptext = des_name + des_info
	user.client.screen += des_desc

/obj/structure/mineop/design/proc/hide_name_and_cost(mob/user)
	des_desc.maptext = ""
	user.client.screen -= des_desc
	qdel(des_desc)

/obj/structure/mineop/design/clicked(mob/user, list/mods)
	if(ishuman(usr))
		if(mods[LEFT_CLICK])
			var/list/obj/structure/mineop/minerarls_drop/marine_mat/matlist = list()
			var/area/fab = get_area(connected_fabricator)
			var/researched = FALSE
			var/obj/structure/mineop/fob/fabricator_hatch/free_hatch

			for(var/obj/structure/mineop/minerarls_drop/marine_mat/T in fab)
				matlist += T
			for(var/obj/structure/mineop/minecart/M in fab)
				for(var/obj/structure/mineop/minerarls_drop/marine_mat/T in M.minerals_inside)
					matlist += T

			if(length(matlist) < buycost)
				animation_flash_color(src, COLOR_RED)
				return FALSE

			for(var/obj/structure/mineop/rnd/R in connected_terminal.researched_tech_list)
				if(R.tech_id == design_id)
					researched = TRUE

			if(already_researched)
				researched = TRUE

			if(!researched)
				animation_flash_color(src, COLOR_RED)
				return FALSE

			for(var/obj/structure/mineop/fob/fabricator_hatch/H in connected_fabricator.hatches)
				if(H.busy)
					continue
				free_hatch = H

			if(!free_hatch)
				animation_flash_color(src, COLOR_RED)
				return FALSE

			animation_flash_color(src, COLOR_GREEN)
			animate(src, transform = matrix(0.7, MATRIX_SCALE), time = 0.2 SECONDS, easing = SINE_EASING | EASE_IN)
			animate(transform = matrix(1, MATRIX_SCALE), time = 0.2 SECONDS, easing = SINE_EASING | EASE_OUT)

			if(hovering)
				remove_filter("hover_outline")
				hide_name_and_cost(usr)
				hovering = FALSE

			var/remove_that_much = buycost
			for(var/obj/structure/mineop/minerarls_drop/marine_mat/T in matlist)
				if(remove_that_much > 0)
					remove_that_much -= 1
					qdel(T)

			for(var/obj/structure/mineop/minecart/M in fab)
				M.recalculate_resources()

			free_hatch.start_production(type_to_create, buildtime)
			return TRUE

	return ..()
