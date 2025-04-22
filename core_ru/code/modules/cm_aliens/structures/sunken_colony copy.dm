/*
/datum/construction_template/xenomorph/blueprint_1
	name = "Застройка крест"
	description = "Делает красивый крест."
	build_type = /obj/effect/alien/resin/special/blueprint_1
	build_icon_state = "blueprint_1"
	pixel_x = 0
	pixel_y = -64
	block_range = 0

/datum/construction_template/xenomorph/blueprint_1/set_structure_image()
	build_icon = 'core_ru/icons/obj/structures/alien/96x96_blueprints.dmi'

/////////////////////////////////////////////////////////////////

//turf/closed/wall/resin/blueprint/cross
/obj/effect/alien/resin/special/blueprint_1
	name = "строительный блок"
	desc = "аааааааааааааааааааа."

//turf/closed/wall/resin/blueprint/cross/Initialize()
/obj/effect/alien/resin/special/blueprint_1/Initialize()
	message_admins("I")
	. = ..()
	message_admins("I1")
//	if(!istype(T, /turf/open))
//		return FALSE


	var/turf/X1_Y1 = get_turf(loc)
	message_admins("I2")

	var/turf/X2_Y1 = get_step(X1_Y1, EAST)
	var/turf/X3_Y1 = get_step(X2_Y1, EAST)

	var/turf/X1_Y2 = get_step(X1_Y1, SOUTH)
	var/turf/X2_Y2 = get_step(X2_Y1, SOUTH)
	var/turf/X3_Y2 = get_step(X3_Y1, SOUTH)

//	var/turf/X1_Y3 = get_step(X1_Y2, SOUTH)
	var/turf/X2_Y3 = get_step(X2_Y2, SOUTH)
//	var/turf/X3_Y3 = get_step(X3_Y2, SOUTH)
	message_admins("I3")


	if(istype(X2_Y1, /turf/open))
		new /turf/closed/wall/resin(X2_Y1)

	if(istype(X1_Y2, /turf/open))
		new /turf/closed/wall/resin(X1_Y2)

	if(istype(X2_Y2, /turf/open))
		new /turf/closed/wall/resin(X2_Y2)

	if(istype(X3_Y2, /turf/open))
		new /turf/closed/wall/resin(X3_Y2)

	if(istype(X2_Y3, /turf/open))
		new /turf/closed/wall/resin(X2_Y3)

	message_admins("I4")

	qdel(src)


/obj/effect/alien/resin/special/blueprint_3
	name = "строительный блок"
	desc = "аааааааааааааааааааа."

//turf/closed/wall/resin/blueprint/cross/Initialize()
/obj/effect/alien/resin/special/blueprint_3/Initialize()
	message_admins("I")
	. = ..()
	message_admins("I1")
//	if(!istype(T, /turf/open))
//		return FALSE


	var/turf/X1_Y1 = get_turf(loc)
	message_admins("I2")
	new /turf/closed/wall/resin(X1_Y1)

	message_admins("I3")

	qdel(src)


*/

#define XENO_BLUEPRINT_WALL 1
#define XENO_BLUEPRINT_WINDOW 2
#define XENO_BLUEPRINT_DOOR 3

/obj/effect/alien/resin/blueprint
	name = "смоляной узел"
	desc = "Причудливо искаженная смола, еще не обретшая форму, от неё исходит сильный запах феромонов королевы."
	icon = 'icons/mob/xenos/structures.dmi'
	icon_state = "resin"
	density = FALSE
	anchored = TRUE
//	layer = RESIN_STRUCTURE_LAYER
//	plane = FLOOR_PLANE
	health = 10
	block_range = 0
	alpha = 122
	var/plasma_required = 100
	var/building_evolve = XENO_BLUEPRINT_WALL

/obj/effect/alien/resin/blueprint/wall
	icon_state = "resin"
	plasma_required = 110

/obj/effect/alien/resin/blueprint/window
	icon_state = "membrane"
	plasma_required = 70
	building_evolve = XENO_BLUEPRINT_WINDOW

/obj/effect/alien/resin/blueprint/door
	icon = 'icons/mob/xenos/effects.dmi'
	icon_state = "resin"
	plasma_required = 90
	building_evolve = XENO_BLUEPRINT_DOOR

/obj/effect/alien/resin/blueprint/proc/fill_plasma(mob/living/carbon/xenomorph/xeno)
	if(!istype(xeno))
		return
	if(!xeno.plasma_max)
		return
	if(xeno.plasma_stored < plasma_required)
		to_chat(xeno, SPAN_WARNING("Нам не хватает плазмы."))
		return
	to_chat(xeno, SPAN_NOTICE("Мы начинаем наполнять смоляной узел плазмой."))
	xeno_attack_delay(xeno)
	if(!do_after(xeno, 20, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD))
		return
	if(xeno.plasma_stored < plasma_required)
		to_chat(xeno, SPAN_WARNING("Нам не хватает плазмы."))
		return

	xeno.plasma_stored -= plasma_required

	message_admins("F1")

	var/turf/new_turf = get_turf(loc)

	switch(building_evolve)
		if(XENO_BLUEPRINT_WALL)
			new_turf.PlaceOnTop(/turf/closed/wall/resin)
			var/turf/closed/wall/resin/new_wall = new_turf
			new_wall.hivenumber = xeno.hivenumber
			set_hive_data(new_wall, xeno.hivenumber)
			new_wall.add_fingerprint(xeno)
		if(XENO_BLUEPRINT_WINDOW)
			new_turf.PlaceOnTop(/turf/closed/wall/resin/membrane)
			var/turf/closed/wall/resin/membrane/new_wall = new_turf
			new_wall.hivenumber = xeno.hivenumber
			set_hive_data(new_wall, xeno.hivenumber)
			new_wall.add_fingerprint(xeno)
		if(XENO_BLUEPRINT_DOOR)
			var/obj/structure/mineral_door/resin/new_door = new (new_turf)
			new_door.hivenumber = xeno.hivenumber
			set_hive_data(new_door, xeno.hivenumber)
			new_door.add_fingerprint(xeno)
	qdel(src)

/obj/effect/alien/resin/blueprint/attack_alien(mob/living/carbon/xenomorph/M)
	if(M.a_intent == INTENT_HARM)
		return ..()
	fill_plasma(M)
	return XENO_NO_DELAY_ACTION

//////////////////////////////////

/datum/resin_construction/resin_turf/wall/blueprint
	name = "Узел стены"
	desc = "Смоляной узел, что преобразуется в стену при наполнении плазмой."
	cost = 10	// 120-110
	build_path = /obj/effect/alien/resin/blueprint/wall
	build_animation_effect = /obj/effect/resin_construct/weak
	build_time = 0.1 SECONDS

/datum/resin_construction/resin_turf/membrane/blueprint
	name = "Узел мембраны"
	desc = "Смоляной узел, что преобразуется в мембрану при наполнении плазмой."
	cost = 10	// 80-70
	build_path = /obj/effect/alien/resin/blueprint/window
	build_animation_effect = /obj/effect/resin_construct/transparent/weak
	build_time = 0.1 SECONDS

/datum/resin_construction/resin_obj/door/blueprint
	name = "Узел двери"
	desc = "Смоляной узел, что преобразуется в дверь при наполнении плазмой."
	cost = 10	// 100-90
	build_path = /obj/effect/alien/resin/blueprint/door
	build_animation_effect = /obj/effect/resin_construct/door
	build_time = 0.1 SECONDS

/datum/resin_construction/resin_obj/membrane/blueprint/door
	name = "Узел двери"
	desc = "Смоляной узел, что преобразуется в дверь при наполнении плазмой."
	cost = 10	// 100-90
	build_path = /obj/effect/alien/resin/blueprint/door
	build_animation_effect = /obj/effect/resin_construct/door
	build_time = 0.1 SECONDS

#undef XENO_BLUEPRINT_WALL
#undef XENO_BLUEPRINT_WINDOW
#undef XENO_BLUEPRINT_DOOR
