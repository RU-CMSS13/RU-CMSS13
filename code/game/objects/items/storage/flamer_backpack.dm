/*
 * Backpack
 */

/////////////////////////////

// Внутренние баллоны
/obj/item/ammo_magazine/flamer_tank/internal
	name = "Внутренний баллон огнемета"
	desc = "Ты не должен это видеть."
	icon_state = "flametank_large_custom"
	item_state = "flametank_large"
	max_rounds = 200
	gun_type = /obj/item/weapon/gun/flamer

	max_intensity = 1000
	max_range = 5
	max_duration = 50

// Стандарт
/obj/item/ammo_magazine/flamer_tank/internal/standart
	name = "Баллон UT-N"

// Зеленка
/obj/item/ammo_magazine/flamer_tank/internal/green
	name = "Баллон B-gel"
	caliber = "Napalm B"
	flamer_chem = "napalmb"

	max_range = 6

// Кастом
/obj/item/ammo_magazine/flamer_tank/internal/custom
	name = "Кастомный баллон"
	flamer_chem = null
//	max_range = 5
//	fuel_pressure = 1
	custom = TRUE

//////////////////////////////////////////////////////////

/obj/item/weapon/gun/flamer
	name = "Огнемёт M240A1"
	desc = "Огнемёт M240A1 зарекомендовал себя как одно из самых эффективных средств уничтожения органических целей. \
		Пусть он довольно громоздкий и устаревший, однако его всё ещё следует бояться и уважать - огонь пощады не знает."
	var/obj/item/storage/backpack/marine/feline_flamer_backpack/fuel_backpack // линк на рюкзак

/obj/item/weapon/gun/flamer/proc/link_fuelpack(mob/user)	// Линк шланга
	message_admins("L")
	if (fuel_backpack)							// релинк
		message_admins("L1")
		fuel_backpack.linked_flamer = null
		fuel_backpack = null

	if(istype(user.back, /obj/item/storage/backpack/marine/feline_flamer_backpack))
		message_admins("L2")
		var/obj/item/storage/backpack/marine/feline_flamer_backpack/FP = user.back
		if(FP.linked_flamer)
			message_admins("L3")
			FP.linked_flamer.fuel_backpack = null
		FP.linked_flamer = src
		fuel_backpack = FP
		return TRUE
	return FALSE

/obj/item/weapon/gun/flamer/unique_action(mob/user)
	message_admins("T")
	if(fuel_backpack)
		message_admins("T1")
		fuel_backpack.do_toggle_fuel(user)
	else
		message_admins("T2")
		toggle_gun_safety()

////////////////////////////////////////////////////////////////////

/obj/item/storage/backpack/marine/feline_flamer_backpack
	name = "Огнеметный ранец ЮСКМ G7-3"
	desc = "Продвинутая версия огнеметного ранца ЮСКМ. Главным отличием являются изолированные друг от друга топливные баллоны, \
		что позволяет переключаться между разными типами огнесмеси через встроенный редуктор. Первые два баллона специализированы \
		для заправки стандартным напалмом UT-N и B-Gel соответственно. Третий предназначен для заправки кастомным топливом или же \
		в качестве альтернативы сварочным топливом, что позволит заряжать сварочный аппарат. Для подключения третьего баллона к \
		редуктору сначала необходимо переключить клапан скрытый за панелью ПКМ. Ранец так же оснащен небольшой емкостью для воды."
//	icon = 'icons/obj/items/clothing/backpack/backpacks_by_map/jungle.dmi'
//	icon_state = "flamethrower_broiler"
//	flags_atom = FPRINT|CONDUCT

	icon = 'icons/obj/items/clothing/backpack/backpacks_by_faction/UA.dmi'
	icon_state = "flamethrower_backpack"
	item_icons = list(
		WEAR_L_HAND = 'icons/mob/humans/onmob/inhands/clothing/backpacks_lefthand.dmi',
		WEAR_R_HAND = 'icons/mob/humans/onmob/inhands/clothing/backpacks_righthand.dmi',
		WEAR_BACK = 'icons/mob/humans/onmob/clothing/back/backpacks_by_faction/UA.dmi'
	)
	item_state = "flamethrower_backpack"

	flags_atom = FPRINT|NO_GAMEMODE_SKIN // same sprite for all gamemodes
	max_storage_space = 20
	storage_slots = 4
	worn_accessible = TRUE
	can_hold = list(/obj/item/ammo_magazine/flamer_tank, /obj/item/tool/extinguisher)
	storage_flags = STORAGE_FLAGS_POUCH


	var/obj/item/ammo_magazine/flamer_tank/internal/standart/fuel_standart		// Стандарт
	var/obj/item/ammo_magazine/flamer_tank/internal/green/fuel_green			// Зеленка
	var/obj/item/ammo_magazine/flamer_tank/internal/custom/fuel_custom			// Кастом
	var/obj/item/ammo_magazine/flamer_tank/internal/active_fuel					// Текущее топливо
	var/custom_tank_active = FALSE

	var/obj/item/weapon/gun/flamer/linked_flamer

	var/image/flamer_overlay
	var/toggling = FALSE

	actions_types = list(/datum/action/item_action/specialist/toggle_fuel_backpack)


/obj/item/storage/backpack/marine/feline_flamer_backpack/Initialize()
	. = ..()
	fuel_standart = new /obj/item/ammo_magazine/flamer_tank/internal/standart()
	fuel_green = new /obj/item/ammo_magazine/flamer_tank/internal/green()
	fuel_custom = new /obj/item/ammo_magazine/flamer_tank/internal/custom()
	active_fuel = fuel_standart
//	flamer_overlay = overlay_image('icons/obj/items/clothing/backpack/backpacks_by_map/jungle.dmi', "+m240t")

/*
/obj/item/storage/backpack/marine/feline_flamer_backpack/select_gamemode_skin(expected_type, list/override_icon_state, list/override_protection)
	. = ..()
	switch(SSmapping.configs[GROUND_MAP].camouflage_type)
		if("jungle")
			icon = 'icons/obj/items/clothing/backpack/backpacks_by_map/jungle.dmi'
			item_icons[WEAR_BACK] = 'icons/mob/humans/onmob/clothing/back/backpacks_by_map/jungle.dmi'
		if("classic")
			icon = 'icons/obj/items/clothing/backpack/backpacks_by_map/classic.dmi'
			item_icons[WEAR_BACK] = 'icons/mob/humans/onmob/clothing/back/backpacks_by_map/classic.dmi'
		if("desert")
			icon = 'icons/obj/items/clothing/backpack/backpacks_by_map/desert.dmi'
			item_icons[WEAR_BACK] = 'icons/mob/humans/onmob/clothing/back/backpacks_by_map/desert.dmi'
		if("snow")
			icon = 'icons/obj/items/clothing/backpack/backpacks_by_map/snow.dmi'
			item_icons[WEAR_BACK] = 'icons/mob/humans/onmob/clothing/back/backpacks_by_map/snow.dmi'
		if("urban")
			icon = 'icons/obj/items/clothing/backpack/backpacks_by_map/urban.dmi'
			item_icons[WEAR_BACK] = 'icons/mob/humans/onmob/clothing/back/backpacks_by_map/urban.dmi'
*/

/obj/item/storage/backpack/marine/feline_flamer_backpack/Destroy()
	QDEL_NULL(active_fuel)
	QDEL_NULL(fuel_standart)
	QDEL_NULL(fuel_green)
	QDEL_NULL(fuel_custom)
	if(linked_flamer)
		linked_flamer.fuel_backpack = null
		linked_flamer = null
	QDEL_NULL(flamer_overlay)
	. = ..()

/*
/obj/item/storage/backpack/marine/feline_flamer_backpack/update_icon()
	overlays -= flamer_overlay
	if(length(contents))
		overlays += flamer_overlay

	var/mob/living/carbon/human/user = loc
	if(istype(user))
		user.update_inv_back()
*/

/obj/item/storage/backpack/marine/feline_flamer_backpack/dropped(mob/user)
	if(linked_flamer)
		linked_flamer.fuel_backpack = null
		if(linked_flamer.current_mag in list(fuel_standart, fuel_green, fuel_custom))
			linked_flamer.current_mag = null
		linked_flamer.update_icon()
		linked_flamer = null
	..()

/*
// Get the right onmob icon when we have flamer holstered.
/obj/item/storage/backpack/marine/feline_flamer_backpack/get_mob_overlay(mob/user_mob, slot, default_bodytype = "Default")
	var/image/ret = ..()
	if(slot == WEAR_BACK)
		if(length(contents))
			var/image/weapon_holstered = overlay_image('icons/mob/humans/onmob/clothing/back/guns_by_type/flamers.dmi', "+m240t", color, RESET_COLOR)
			ret.overlays += weapon_holstered

	return ret
*/

/obj/item/storage/backpack/marine/feline_flamer_backpack/attack_self(mob/user)
	..()
	do_toggle_fuel(user)


/obj/item/storage/backpack/marine/feline_flamer_backpack/proc/do_toggle_fuel(mob/user)
	if(!ishuman(user) || user.is_mob_incapacitated())
		return FALSE

	if(user.back != src)																		// Переделать на шланг
		to_chat(user, SPAN_WARNING("Перед тем как переключить тип топлива необходимо надеть ранец на спину!"))
		return

	if(!linked_flamer)
		to_chat(user, SPAN_WARNING("An incinerator unit must be linked in order to switch fuel types."))
		return

	if(user.get_active_hand() != linked_flamer)
		to_chat(user, SPAN_WARNING("You must be holding [linked_flamer] to use [src]."))
		return

	if(!active_fuel)
		return

// Переключатель режимов
	if(istype(active_fuel, /obj/item/ammo_magazine/flamer_tank/internal/standart))		// Если стандарт ==> Зеленое
		active_fuel = fuel_green
	else if(istype(active_fuel, /obj/item/ammo_magazine/flamer_tank/internal/green))	// Если зеленое и
		if(custom_tank_active)															// 		активирован 3 баллон ==> Кастом
			active_fuel = fuel_custom
		else																			// 		не активирован 3 баллон ==> Стандарт
			active_fuel = fuel_standart

	for(var/datum/action/action_added as anything in actions)
		action_added.update_button_icon()

	to_chat(user, "Переключаю редуктор на <b>[active_fuel.caliber]</b>")
	playsound(src, 'sound/machines/click.ogg', 25, TRUE)
	linked_flamer.current_mag = active_fuel
	linked_flamer.update_icon()

	return TRUE

/obj/item/storage/backpack/marine/feline_flamer_backpack/verb/toggle_fuel()
	set name = "Переключать тип топлива"
	set desc = "Цикличное переключение редуктора между различными видами топлива."
	set category = "Pyro"																// куда это? в Object?
	set src in usr
	do_toggle_fuel(usr)

/obj/item/storage/backpack/marine/feline_flamer_backpack/verb/remove_reagents()
	set name = "Опустошить бак кастомного топлива"
	set category = "Object"

	set src in usr

/*
	if(usr.get_active_hand() != src)
		return
*/

	if(alert(usr, "Вы хотите опустошить бак кастомного топлива?", "Опустошить бак", "Да", "Нет") != "Да")
		return

	fuel_custom.reagents.clear_reagents()

	playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
	to_chat(usr, SPAN_NOTICE("Опустошаю бак кастомного топлива."))
	update_icon()

/obj/item/storage/backpack/marine/feline_flamer_backpack/verb/toggle_custom()
	set name = "Переключатель кастомного топлива"
	set category = "Object"

	set src in usr

	if(alert(usr, "Вы хотите [custom_tank_active ? "отключить кастомное топливо от редуктора" : "подключить кастомное топливо к редуктору"]?", "Подключить?", "Да", "Нет") != "Да")
		return

	custom_tank_active = !custom_tank_active

	playsound(src, 'sound/machines/click.ogg', 25, TRUE)
	to_chat(usr, SPAN_NOTICE("[custom_tank_active ? "Подключаю кастомное топливо к редуктора" : "Отключаю кастомное топливо от редуктору"]."))
	update_icon()

////////////////////////////////////////////////////////////////////////////////////////////////

/obj/item/storage/backpack/marine/feline_flamer_backpack/attackby(obj/item/A as obj, mob/user as mob)
	if(istype(A, /obj/item/ammo_magazine/flamer_tank))		// Зарядка от баллонов (доделать что не от пиро?)
		switch_fuel(A, user)
		return
															// Виды заправок: Баллоны, рюкзаки инженеров, баллоны сварки, топливные баки



	if(iswelder(A))											// Заправка сварочника если в третьем баллоне сварочное топливо
		if(fuel_custom.reagents.has_reagent("fuel"))
			var/obj/item/tool/weldingtool/T = A
			if(T.welding)
				to_chat(user, SPAN_WARNING("Это было близко! Однако я вовремя заметил, что сварочный аппарат зажжён и смог предотврать катастрофу."))
				return
			if(!(T.get_fuel()==T.max_fuel) && fuel_custom.reagents.total_volume)
				fuel_custom.reagents.trans_to(A, T.max_fuel)
				to_chat(user, SPAN_NOTICE("сварочный аппарат заправлен!"))
				playsound(loc, 'sound/effects/refill.ogg', 25, TRUE, 3)
				return
	. = ..()

/obj/item/storage/backpack/marine/feline_flamer_backpack/afterattack(obj/target, mob/user, proximity)
	if(!proximity)
		return
	if (istype(target, /obj/structure/reagent_dispensers/fueltank))		// Заправка от реагентного бака
		var/obj/structure/reagent_dispensers/fueltank/ft
		if(((ft.reagents.get_reagents() == fuel_custom.reagents.get_reagents())) || (fuel_custom.caliber = null))
			if (fuel_custom.reagents.total_volume >= fuel_custom.max_rounds)
				to_chat(user, SPAN_NOTICE("Кастомный бак уже заполнен!"))
				return
			if(reagents.total_volume < fuel_custom.max_rounds)
				target.reagents.trans_to(fuel_custom, fuel_custom.max_rounds)
				to_chat(user, SPAN_NOTICE("Заправляю кастомный баллон огнемётного ранца из бака."))
				playsound(loc, 'sound/effects/refill.ogg', 25, TRUE, 3)
				return

/*
	var/obj/item/weapon/gun/flamer/F = A
	if(istype(F) && !(F.fuel_backpack))
		F.link_fuelpack(user)
		if(F.current_mag && !(F.current_mag in list(fuel_standart, fuel_green, fuel_custom)))
			to_chat(user, SPAN_WARNING("\The [F.current_mag] is ejected by the Broiler-T back harness and replaced with \the [active_fuel]!"))
			F.unload(user, drop_override = TRUE)
			F.current_mag = active_fuel
			F.update_icon()
*/

/*
/obj/item/storage/backpack/marine/feline_flamer_backpack/proc/switch_fuel(obj/item/ammo_magazine/flamer_tank/large/new_fuel, mob/user)
	// Switch out the currently stored fuel and drop it
	if(istype(new_fuel, /obj/item/ammo_magazine/flamer_tank/internal/custom/))
		fuel_custom.forceMove(get_turf(user))
		fuel_custom = new_fuel
	else if(istype(new_fuel, /obj/item/ammo_magazine/flamer_tank/internal/green/))
		fuel_green.forceMove(get_turf(user))
		fuel_green = new_fuel
	else
		fuel_standart.forceMove(get_turf(user))
		fuel_standart = new_fuel
	visible_message("[user] swaps out the fuel tank in [src].","You swap out the fuel tank in [src] and drop the old one.")
	to_chat(user, "The newly inserted [new_fuel.caliber] contains: [floor(new_fuel.get_ammo_percent())]% fuel.")
	user.temp_drop_inv_item(new_fuel)
	new_fuel.moveToNullspace() //necessary to not confuse the storage system
	playsound(src, 'sound/machines/click.ogg', 25, TRUE)
	// If the fuel being switched is the active one, set it as new_fuel until it gets toggled
	if(istype(new_fuel, active_fuel))
		active_fuel = new_fuel
*/

/obj/item/storage/backpack/marine/feline_flamer_backpack/proc/switch_fuel(obj/item/W, mob/living/user)
	if (istype(W, /obj/item/ammo_magazine/flamer_tank))					// определил что это баллон
		var/obj/item/ammo_magazine/flamer_tank/donor = W				// обозначил его переменной donor
		var/missing_standart_fuel = fuel_standart.max_rounds - fuel_standart.current_rounds // сколько у меня не хватает топлива
		var/missing_green_fuel = fuel_green.max_rounds - fuel_green.current_rounds // сколько у меня не хватает топлива
		var/missing_custom_fuel = fuel_custom.max_rounds - fuel_custom.current_rounds // сколько у меня не хватает топлива
		// Если это стандарт напалм, если баллон не пуст, если бак не полон
		if((donor.caliber == "UT-Napthal Fuel") && donor.current_rounds && missing_standart_fuel)
			// Сколько мне надо топлива
			var/transfer_volume = missing_standart_fuel <= donor.current_rounds ? donor.current_rounds : missing_standart_fuel
			donor.current_rounds = donor.current_rounds - transfer_volume
			fuel_standart.current_rounds = fuel_standart.current_rounds + transfer_volume
			playsound(loc, 'sound/effects/refill.ogg', 25, TRUE, 3)
			fuel_standart.caliber = "UT-Napthal Fuel"
			visible_message(
				"[user] заправляет огнемётный ранец напалмом из баллона UT-N.",
				"Заправляю огнемётный ранец напалмом из баллона UT-N.")
			to_chat(user, SPAN_NOTICE("Текущий уровень топлива <b>[floor(fuel_standart.get_ammo_percent())]%</b>"))
			donor.update_icon()

		else if((donor.caliber == "Napalm B-Gel") && donor.current_rounds && missing_green_fuel)
			var/transfer_volume = missing_green_fuel <= donor.current_rounds ? donor.current_rounds : missing_green_fuel
			donor.current_rounds = donor.current_rounds - transfer_volume
			fuel_green.current_rounds = fuel_green.current_rounds + transfer_volume
			playsound(loc, 'sound/effects/refill.ogg', 25, TRUE, 3)
			fuel_green.caliber = "Napalm B-Gel"
			visible_message(
				"[user] заправляет огнемётный ранец напалмом из баллона B-Gel.",
				"Заправляю огнемётный ранец напалмом из баллона B-Gel.")
			to_chat(user, SPAN_NOTICE("Текущий уровень топлива <b>[floor(fuel_green.get_ammo_percent())]%</b>"))
			donor.update_icon()

			// Тип топлива совпадает или бак пуст
		else if(((donor.caliber == fuel_custom.caliber) || (fuel_custom.caliber = null)) && donor.current_rounds && missing_custom_fuel)
			var/transfer_volume = missing_custom_fuel <= donor.current_rounds ? donor.current_rounds : missing_custom_fuel
			donor.current_rounds = donor.current_rounds - transfer_volume
			fuel_custom.current_rounds = fuel_custom.current_rounds + transfer_volume
			playsound(loc, 'sound/effects/refill.ogg', 25, TRUE, 3)
			fuel_custom.caliber = donor.caliber
			visible_message(
				"[user] заправляет огнемётный ранец напалмом из кастомного баллона.",
				"Заправляю огнемётный ранец напалмом из кастомного баллона.")
			to_chat(user, SPAN_NOTICE("Текущий уровень топлива <b>[floor(fuel_green.get_ammo_percent())]%</b>"))
			donor.update_icon()


//			var/transfer_volume = fuel_standart.reagents.total_volume < fuel_available ? fuel_standart.reagents.total_volume : fuel_available
		//Топливо должно быть стандарт, или бак должен быть пустым. У нас должен быть неполный баллон, а в баке что-то есть
//		if (((donor.caliber == "UT-Napthal Fuel") || (!donor.current_rounds)) && fuel_available && reagents.total_volume)	//
//			var/missing_volume = reagents.total_volume < fuel_available ? reagents.total_volume : fuel_available		// сколько есть топлива

//			reagents.remove_reagent("fuel", missing_volume)							// забрать fuel_available топлива из бака
//			donor.current_rounds = donor.current_rounds + missing_volume			// добавить fuel_available топлива в баллон
//			playsound(loc, 'sound/effects/refill.ogg', 25, TRUE, 3)
//			donor.caliber = "UT-Napthal Fuel"										// обозначить каллибр
//			to_chat(user, SPAN_NOTICE("You refill [donor] with [donor.caliber]."))
//			donor.update_icon()
//	. = ..()

/*
/obj/item/storage/backpack/marine/engineerpack/flamethrower/attackby(obj/item/W, mob/living/user)
	if (istype(W, /obj/item/ammo_magazine/flamer_tank))				// определил что это баллон
		var/obj/item/ammo_magazine/flamer_tank/FTL = W				// обозначил его переменной FTL
		var/missing_volume = FTL.max_rounds - FTL.current_rounds	// вычислил сколько не хватает патронов

		//Топливо должно быть стандарт, или бак должен быть пустым. У нас должен быть неполный баллон, а в баке что-то есть
		if (((FTL.caliber == "UT-Napthal Fuel") || (!FTL.current_rounds)) && missing_volume && reagents.total_volume)	//
			var/fuel_available = reagents.total_volume < missing_volume ? reagents.total_volume : missing_volume		// сколько есть топлива
			reagents.remove_reagent("fuel", fuel_available)						// забрать fuel_available топлива из бака
			FTL.current_rounds = FTL.current_rounds + fuel_available			// добавить fuel_available топлива в баллон
			playsound(loc, 'sound/effects/refill.ogg', 25, TRUE, 3)
			FTL.caliber = "UT-Napthal Fuel"										// обозначить каллибр
			to_chat(user, SPAN_NOTICE("You refill [FTL] with [FTL.caliber]."))
			FTL.update_icon()
	. = ..()

/obj/item/storage/backpack/marine/feline_flamer_backpack/attackby(obj/item/A as obj, mob/user as mob)
	if(istype(A, /obj/item/ammo_magazine/flamer_tank/internal/standart/))
		switch_fuel(A, user)
		return

	var/obj/item/weapon/gun/flamer/F = A
	if(istype(F) && !(F.fuel_backpack))
		F.link_fuelpack(user)
		if(F.current_mag && !(F.current_mag in list(fuel_standart, fuel_green, fuel_custom)))
			to_chat(user, SPAN_WARNING("\The [F.current_mag] is ejected by the Broiler-T back harness and replaced with \the [active_fuel]!"))
			F.unload(user, drop_override = TRUE)
			F.current_mag = active_fuel
			F.update_icon()

	. = ..()

/obj/item/storage/backpack/marine/feline_flamer_backpack/proc/switch_fuel(obj/item/ammo_magazine/flamer_tank/large/new_fuel, mob/user)
	// Switch out the currently stored fuel and drop it
	if(istype(new_fuel, /obj/item/ammo_magazine/flamer_tank/internal/custom/))
		fuel_custom.forceMove(get_turf(user))
		fuel_custom = new_fuel
	else if(istype(new_fuel, /obj/item/ammo_magazine/flamer_tank/internal/green/))
		fuel_green.forceMove(get_turf(user))
		fuel_green = new_fuel
	else
		fuel_standart.forceMove(get_turf(user))
		fuel_standart = new_fuel
	visible_message("[user] swaps out the fuel tank in [src].","You swap out the fuel tank in [src] and drop the old one.")
	to_chat(user, "The newly inserted [new_fuel.caliber] contains: [floor(new_fuel.get_ammo_percent())]% fuel.")
	user.temp_drop_inv_item(new_fuel)
	new_fuel.moveToNullspace() //necessary to not confuse the storage system
	playsound(src, 'sound/machines/click.ogg', 25, TRUE)
	// If the fuel being switched is the active one, set it as new_fuel until it gets toggled
	if(istype(new_fuel, active_fuel))
		active_fuel = new_fuel

*/


/obj/item/storage/backpack/marine/feline_flamer_backpack/get_examine_text(mob/user)
	. = ..()
//	if(length(contents))
//		. += "It is storing a M240-T incinerator unit."
	if (get_dist(user, src) <= 1)
		if(fuel_standart)
			. += "Уровень топлива [fuel_standart.caliber]: <b>[floor(fuel_standart.get_ammo_percent())]%</b>."
		if(fuel_green)
			. += "Уровень топлива [fuel_green.caliber]: <b>[floor(fuel_green.get_ammo_percent())]%</b>."
		if(fuel_custom)
			. += "Уровень топлива [fuel_custom.caliber]: <b>[floor(fuel_custom.get_ammo_percent())]%</b>."

/datum/action/item_action/specialist/toggle_fuel_backpack
	ability_primacy = SPEC_PRIMARY_ACTION_1

/datum/action/item_action/specialist/toggle_fuel_backpack/New(mob/living/user, obj/item/holder)
	..()
	name = "Переключать тип топлива"
	button.name = name
	update_button_icon()

/datum/action/item_action/specialist/toggle_fuel_backpack/update_button_icon()
	var/obj/item/storage/backpack/marine/feline_flamer_backpack/FP = holder_item
	if (!istype(FP))
		return

	var/icon = 'icons/obj/items/weapons/guns/ammo_by_faction/USCM/flamers.dmi'
	var/icon_state
	if(istype(FP.active_fuel, /obj/item/ammo_magazine/flamer_tank/internal/custom))
		icon_state = "flametank_large_blue"
	else if(istype(FP.active_fuel, /obj/item/ammo_magazine/flamer_tank/internal/green))
		icon_state = "flametank_large_green"
	else
		icon_state = "flametank_large"

	button.overlays.Cut()
	var/image/IMG = image(icon, button, icon_state)
	button.overlays += IMG

/datum/action/item_action/specialist/toggle_fuel_backpack/can_use_action()
	var/mob/living/carbon/human/H = owner
	if(istype(H) && !H.is_mob_incapacitated() && H.body_position == STANDING_UP && holder_item == H.back)
		return TRUE

/datum/action/item_action/specialist/toggle_fuel_backpack/action_activate()
	. = ..()
	var/obj/item/storage/backpack/marine/feline_flamer_backpack/FP = holder_item
	if (!istype(FP))
		return
	FP.toggle_fuel()
