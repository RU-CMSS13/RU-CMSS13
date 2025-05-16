/**
 * RUCM Feline "Фоботы"
 * Делает полевое развертывание ФОБа намного комфортнее без траты личных ресурсов инженеров и при необходимости даже возводимое без самих инженеров
 * В комплект входят припасы, строительные материалы, турель
 * Затронутые файлы:
 * code\game\gamemodes\colonialmarines\colonialmarines.dm
 * code\modules\mapping\mapping_helpers.dm
 * map_config\maps.txt
 */

/obj/item/quikdeploy
	name = "К.У.Р.С.К"
	desc = "Компактный Универсальный Рубежный Саморазвертывающийся Комплекс. Незаменим для быстрой постройки укреплений."
	icon = 'core_ru/Feline/icons/kursk.dmi'
	icon_state = "metal"
	item_icons = list(
		WEAR_L_HAND = 'icons/mob/humans/onmob/inhands/equipment/toolboxes_lefthand.dmi',
		WEAR_R_HAND = 'icons/mob/humans/onmob/inhands/equipment/toolboxes_righthand.dmi',
		)
	item_state = "toolbox_syndi"
	w_class = SIZE_MASSIVE
	var/deploy_desc = "Я сломалси!"
	var/delay = 0
	var/atom/movable/thing_to_deploy = null
	var/atom/movable/side_thing_to_deploy = null
	var/turf/step_left = null
	var/turf/step_right = null

/obj/item/quikdeploy/Initialize()
	. = ..()
	desc += "<br><br> Этот К.У.Р.С.К подготовлен для развертывания <b>[deploy_desc]</b>."

/obj/item/quikdeploy/attack_self(mob/user)
	to_chat(user, "<span class='warning'>Начинаю развертывание комплекса перед собой...")
	if(!do_after(user, delay * user.get_skill_duration_multiplier(SKILL_ENGINEER), INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD))
		to_chat(user, "<span class='warning'>Сейчас не время.")
		return
	if(can_place(user))
//  Размещение центра
		var/obj/O = new thing_to_deploy(get_turf(user))
		O.setDir(user.dir)
//  Определение направления
		if(user.dir == NORTH)
			step_left = get_step(loc, WEST)
			step_right = get_step(loc, EAST)
		if(user.dir == EAST)
			step_left = get_step(loc, NORTH)
			step_right = get_step(loc, SOUTH)
		if(user.dir == SOUTH)
			step_left = get_step(loc, EAST)
			step_right = get_step(loc, WEST)
		if(user.dir == WEST)
			step_left = get_step(loc, SOUTH)
			step_right = get_step(loc, NORTH)
//  Размещение боковых
		if(!isclosedturf(step_left) && (!locate(/obj/structure/window) in step_left.contents) && (!locate(/obj/structure/machinery/door/airlock) in step_left.contents))
			if(place_sides(user, step_left))
				var/obj/step_left_cade = new side_thing_to_deploy(step_left)
				step_left_cade.setDir(user.dir)

		if(!isclosedturf(step_right) && (!locate(/obj/structure/window) in step_right.contents) && (!locate(/obj/structure/machinery/door/airlock) in step_right.contents))
			if(place_sides(user, step_right))
				var/obj/step_right_cade = new side_thing_to_deploy(step_right)
				step_right_cade.setDir(user.dir)

		playsound(loc, 'sound/items/ratchet.ogg', 25, TRUE)
		qdel(src)

/obj/item/quikdeploy/proc/place_sides(mob/user, turf/side_turf)
	for(var/obj/structure/barricade/B in side_turf.contents)
		if(B.dir == user.dir)
			return FALSE
	return TRUE

/obj/item/quikdeploy/proc/can_place(mob/user)
	if((isnull(thing_to_deploy)) || (isnull(side_thing_to_deploy)))
		to_chat(user, "<span class='warning'>Ничего не произошло, кажеться эта модель бракованная.")
		return FALSE
	return TRUE

/obj/item/quikdeploy/cade/can_place(mob/user)
	. = ..()
	if(!.)
		return FALSE

	var/turf/mystery_turf = user.loc
	if(!istype(mystery_turf, /turf/open))
		to_chat(user, SPAN_WARNING("Невозможно начать развертывание в данном месте!"))
		return FALSE

	var/turf/open/placement_loc = mystery_turf
	if(placement_loc.density)
		to_chat(user, SPAN_WARNING("Невозможно начать развертывание в данном месте!"))
		return FALSE

	for(var/obj/structure/barricade/B in user.loc)
		if(B.dir == user.dir)
			to_chat(user, SPAN_WARNING("Тут нет места для баррикады."))
			return FALSE

	to_chat(user, "<span class='notice'>Завершаю развертывание комплекса на позиции.")
	return TRUE

///////////////
// Баррикады //
/obj/structure/barricade/plasteel/prelinked
	linked = TRUE

/obj/item/quikdeploy/cade					// Монолитная стена
	deploy_desc = "монолитной стены"
	thing_to_deploy = /obj/structure/barricade/metal/plasteel
	side_thing_to_deploy = /obj/structure/barricade/metal/plasteel
	icon_state = "metal"
	delay = 5 SECONDS

/obj/item/quikdeploy/cade/plasteel_door		// Стена с дверкой посердине
	deploy_desc = "стены с проходом"
	thing_to_deploy = /obj/structure/barricade/plasteel
	side_thing_to_deploy = /obj/structure/barricade/metal/plasteel
	icon_state = "plasteel"

/obj/item/quikdeploy/cade/plasteel_gate		// Ворота шириной 3 клетки
	deploy_desc = "транспортных ворот"
	thing_to_deploy = /obj/structure/barricade/plasteel/prelinked
	side_thing_to_deploy = /obj/structure/barricade/plasteel/prelinked
	icon_state = "plasteel_gate"

/obj/item/device/flashlight/lamp/tripod/off
	on = 0

/obj/item/storage/box/light_tripod
	name = "Осветительный инвентарь"
	desc = "Содержит в себе комплект светодиодных ламп для полевого освещения."
	icon = 'icons/obj/items/storage/kits.dmi'
	icon_state = "kit_case_old"
	storage_flags = STORAGE_FLAGS_DEFAULT
	storage_slots = 10
	max_storage_space = 30
	can_hold = list(/obj/item/device/flashlight/lamp/tripod)

/obj/item/storage/box/light_tripod/fill_preset_inventory()
	new /obj/item/device/flashlight/lamp/tripod/off(src)
	new /obj/item/device/flashlight/lamp/tripod/off(src)
	new /obj/item/device/flashlight/lamp/tripod/off(src)
	new /obj/item/device/flashlight/lamp/tripod/off(src)
	new /obj/item/device/flashlight/lamp/tripod/off(src)
	new /obj/item/device/flashlight/lamp/tripod/off(src)
	new /obj/item/device/flashlight/lamp/tripod/off(src)
	new /obj/item/device/flashlight/lamp/tripod/off(src)

// Фортификационный ящик
/obj/structure/closet/crate/fobots_crate_fort
	name = "Ящик с материалами"
	desc = "Ящик содержащий строительные материалы для полевого развертывания ФОБа."
	icon = 'core_ru/Feline/icons/fobots.dmi'
	icon_state = "crate_fob_mats"
	icon_closed = "crate_fob_mats"
	icon_opened = "crate_fob_open"

/obj/structure/closet/crate/fobots_crate_fort/Initialize()
	. = ..()
	new /obj/item/stack/sheet/metal(src, 50)
	new /obj/item/stack/sheet/plasteel(src, 50)
	new /obj/item/stack/sandbags_empty(src, 50)
	new /obj/item/stack/sandbags_empty(src, 50)
	new /obj/item/stack/sandbags_empty(src, 50)
	new /obj/item/stack/sandbags_empty(src, 50)
	new /obj/item/stack/barbed_wire/full_stack(src)
	new /obj/item/stack/barbed_wire/full_stack(src)

	new /obj/item/storage/box/light_tripod(src)
	new /obj/item/storage/toolbox/mechanical(src)
	new /obj/item/storage/toolkit/rmc(src)
	new /obj/item/clothing/glasses/welding(src)
	new /obj/item/tool/shovel(src)
	new /obj/item/tool/shovel(src)

	new /obj/item/quikdeploy/cade(src)
	new /obj/item/quikdeploy/cade(src)
	new /obj/item/quikdeploy/cade/plasteel_door(src)
	new /obj/item/quikdeploy/cade/plasteel_door(src)
	new /obj/item/quikdeploy/cade/plasteel_gate(src)

/obj/structure/closet/crate/fobots_crate_supplies
	name = "Ящик с припасами"
	desc = "Ящик содержащий припасы для полевого развертывания ФОБа."
	icon = 'core_ru/Feline/icons/fobots.dmi'
	icon_state = "crate_fob_ammo"
	icon_closed = "crate_fob_ammo"
	icon_opened = "crate_fob_open"

/obj/structure/closet/crate/fobots_crate_supplies/Initialize()
	. = ..()
	new /obj/item/ammo_box/magazine(src)
	new /obj/item/ammo_box/magazine(src)
	new /obj/item/ammo_box/rounds(src)
	new /obj/item/ammo_box/rounds(src)

	new /obj/item/ammo_box/magazine/ap(src)
	new /obj/item/ammo_box/magazine/m39(src)
	new /obj/item/ammo_box/magazine/m4ra(src)
	new /obj/item/ammo_box/rounds/ap(src)

	new /obj/item/ammo_box/magazine/shotgun(src)
	new /obj/item/ammo_box/magazine/shotgun/buckshot(src)
	new /obj/item/ammo_box/magazine/shotgun/flechette(src)
	new /obj/item/ammo_box/magazine/shotgun/light/breaching(src)

	new /obj/item/ammo_box/magazine/misc/mre(src)
	new /obj/item/ammo_box/magazine/misc/mre(src)
	new /obj/item/ammo_box/magazine/misc/flares(src)
	new /obj/item/ammo_box/magazine/misc/flares(src)

// Турельный ящик
/obj/structure/closet/crate/fobots_crate_turret
	name = "Ящик с турелью"
	desc = "Ящик содержащий модифицированную турель для полевого развертывания ФОБа."
	icon = 'core_ru/Feline/icons/fobots.dmi'
	icon_state = "crate_fob_turret"
	icon_closed = "crate_fob_turret"
	icon_opened = "crate_fob_open"

/obj/structure/closet/crate/fobots_crate_turret/Initialize()
	. = ..()
	new /obj/structure/machinery/defenses/sentry/fob_static(src)

/obj/structure/machinery/defenses
	var/not_collapsible = FALSE // Нельзя сложить мультитулом

/obj/structure/machinery/defenses/sentry/fob_static
	name = "UA-672F Стационарная Оборонительная Турель"
	desc = "Полуавтоматическая турель с возможностью наведения на цель с помощью искусственного интеллекта. Оснащена автопушкой M30 \
		и барабанным магазином на 500 патронов. Эта модификация отличается более монументальной станиной, что с одной стороны увеличивает \
		дальность стрельбы и прочность конструкции, однако не позволяет свернуть турель для переноски."
	sentry_range = 5
	health = 300
	health_max = 300
	omni_directional = TRUE
	fire_delay = 0.4 SECONDS
	ammo = new /obj/item/ammo_magazine/sentry
	immobile = FALSE
	static = TRUE
	turned_on = FALSE
	not_collapsible = TRUE
	faction_group = list(FACTION_MARINE, FACTION_COLONIST, FACTION_SURVIVOR, FACTION_NSPA)

/obj/structure/machinery/defenses/sentry/fob_static/set_range()
	range_bounds = SQUARE(x, y, 10)
	return

//	ДОБАВИТЬ ЭТО В ФОБОТА
/*
	new /obj/item/storage/belt/utility/full(src)
	new /obj/item/storage/pouch/tools(src)
	new /obj/item/clothing/gloves/yellow(src)
	new /obj/item/clothing/glasses/welding(src)

*/
