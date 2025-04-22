/**
 * RUCM Feline "Ксено-чертежи"
 * Добавляет возможность очень быстро размечать ксено-застройку в призрачном варианте с последующей заливкой всего этого плазмой.
 * Доступно только до определенного времени после чего чертежи блокируются, а оставшиеся призраки удаляются.
 *
 * Затронутые файлы:
 * code\_globalvars\global_lists.dm
 * code\modules\mob\living\carbon\xenomorph\resin_constructions.dm
 * code\modules\mob\living\carbon\xenomorph\hive_status.dm
 */

#define XENO_BLUEPRINT_WALL 1
#define XENO_BLUEPRINT_WINDOW 2
#define XENO_BLUEPRINT_DOOR 3

/////////////////////////
// Силуэтные постройки //
/obj/effect/alien/resin/blueprint
	name = "смоляной узел"
	desc = "Причудливо искаженная смола, еще не обретшая форму, от неё исходит сильный запах феромонов королевы."
	icon = 'icons/mob/xenos/structures.dmi'
	icon_state = "resin"
	density = FALSE
	anchored = TRUE
	health = 10
	block_range = 0
	alpha = 122
	var/plasma_required = 100
	var/building_evolve = XENO_BLUEPRINT_WALL
	var/time_to_dispel = 20 MINUTES

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

// Наполнение плазмой
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
	if(!do_after(xeno, 10, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD))
		return
	if(xeno.plasma_stored < plasma_required)
		to_chat(xeno, SPAN_WARNING("Нам не хватает плазмы."))
		return

	xeno.plasma_stored -= plasma_required

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
	playsound(src, "alien_resin_build", 25)
	qdel(src)

/obj/effect/alien/resin/blueprint/attack_alien(mob/living/carbon/xenomorph/M)
	if(M.a_intent == INTENT_HARM)
		return ..()
	fill_plasma(M)
	return XENO_NO_DELAY_ACTION

// Удаление чертежей по таймеру
/obj/effect/alien/resin/blueprint/Initialize()
	. = ..()
	if(!time_to_dispel)
		return
	var/delete_time = max(time_to_dispel - ROUND_TIME, 4)
	QDEL_IN(src, delete_time + rand(-3 SECONDS, 3 SECONDS))

//////////////////////////
// Датумы строительства //
/datum/resin_construction
	var/delete_after = FALSE

/datum/resin_construction/resin_obj/blueprint
	build_time = 0.1 SECONDS
	cost = 10
	delete_after = TRUE
	construction_name = "resin wall blueprint"

/datum/resin_construction/resin_obj/blueprint/wall
	name = "Узел стены"
	desc = "Смоляной узел, что преобразуется в стену при наполнении плазмой."
	build_path = /obj/effect/alien/resin/blueprint/wall
	build_animation_effect = /obj/effect/resin_construct/blueprint/wall
	construction_name = "resin wall blueprint"

/datum/resin_construction/resin_obj/blueprint/membrane
	name = "Узел мембраны"
	desc = "Смоляной узел, что преобразуется в мембрану при наполнении плазмой."
	build_path = /obj/effect/alien/resin/blueprint/window
	build_animation_effect = /obj/effect/resin_construct/blueprint/window
	construction_name = "resin membrane blueprint"

/datum/resin_construction/resin_obj/blueprint/door
	name = "Узел двери"
	desc = "Смоляной узел, что преобразуется в дверь при наполнении плазмой."
	build_path = /obj/effect/alien/resin/blueprint/door
	build_animation_effect = /obj/effect/resin_construct/blueprint/door
	construction_name = "resin door blueprint"

// Удалятель
/datum/resin_construction/resin_obj/blueprint/delete_blueprint
	name = "Удаление смоляного узла"
	desc = "Удаляет смоляной узел."
	build_path = /obj/effect/alien/resin/blueprint/door
	build_animation_effect = /obj/effect/resin_construct/blueprint/door
	construction_name = "delete"

// Блокировка по таймеру
/datum/resin_construction/resin_obj/blueprint/can_build_here(turf/T, mob/living/carbon/xenomorph/X)
	if(!GLOB.xeno_blueprint_available)
		to_chat(X, SPAN_WARNING("Улей уже достаточно окреп и мы более не можем пользоваться чертежами!"))
		return FALSE
	. = ..()

// Блокировка по удалятелю
/datum/resin_construction/resin_obj/blueprint/delete_blueprint/can_build_here(turf/T, mob/living/carbon/xenomorph/X)
	var/obj/effect/alien/resin/blueprint/alien_blueprint = locate() in T
	if(alien_blueprint)
		to_chat(X, SPAN_WARNING("Смоляной узел удалён!"))
		qdel(alien_blueprint)
	else
		to_chat(X, SPAN_WARNING("Не найдено объектов для удаления!"))
	return FALSE

// Флики строительства
/obj/effect/resin_construct/blueprint
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 122

/obj/effect/resin_construct/blueprint/wall
	icon_state = "WeakConstructUltraFast"

/obj/effect/resin_construct/blueprint/window
	icon_state = "WeakTransparentConstructUltraFast"

/obj/effect/resin_construct/blueprint/door
	icon_state = "DoorConstructUltraFast"

#undef XENO_BLUEPRINT_WALL
#undef XENO_BLUEPRINT_WINDOW
#undef XENO_BLUEPRINT_DOOR

/////////////////////////////////////////////////
