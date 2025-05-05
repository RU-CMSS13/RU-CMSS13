/**
 * RUCM Feline "Огнемётный ранец 2.0"
 *
 * Заменяет стандартный бак для топлива огнемёта на профелированную станцию с возможнотью переключения режимов огня, другой системой заправки,
 * 3-мя баллонами для топлива в том числе кастомного, позволяет заправлять сварочники и огнетушители, усиливает огнемёт и его насадки. Огнемёт
 * связан с баком посредством физического шланга.
 *
 * Затронутые файлы:
 * code\modules\projectiles\guns\flamer\flamer.dm
 * code\modules\projectiles\gun_attachables.dm
 * code\game\objects\items\tools\extinguisher.dm
 * code\game\machinery\vending\vendor_types\squad_prep\squad_leader.dm
 * code\game\machinery\vending\vendor_types\requisitions.dm
 * code\game\machinery\vending\vendor_types\prep_upp\requisitions_upp.dm
 * code\datums\tutorial\marine\reqs_line.dm
 * code\datums\supply_packs\weapons.dm
 * code\modules\gear_presets\cbrn.dm
 * code\modules\gear_presets\dutch.dm
 * code\modules\cm_marines\equipment\kit_boxes.dm
 */

/////////////////////////////

/////////////
// Огнемёт //
/obj/item/weapon/gun/flamer
	name = "Огнемёт M240A1 \"Испепелитель\""
	desc = "Огнемёт M240A1 зарекомендовал себя как одно из самых эффективных средств уничтожения органических целей. \
		Пусть он довольно громоздкий и устаревший, однако его всё ещё следует бояться и уважать - огонь пощады не знает. \
		Можно подключить к огнемётному ранцу F7-3 \"Буратино\""

	var/obj/item/storage/backpack/marine/feline_flamer_backpack/fuel_backpack // линк на рюкзак
	var/spec_item = FALSE				// для спека

	var/datum/effects/tethering/tether_effect		// Переменная привязи
	var/zlevel_transfer = FALSE
	var/zlevel_transfer_timer = TIMER_ID_NULL
	var/zlevel_transfer_timeout = 5 SECONDS

/obj/item/weapon/gun/flamer/m240
	name = "Огнемёт M240A1 \"Испепелитель\""
	desc = "Огнемёт M240A1 зарекомендовал себя как одно из самых эффективных средств уничтожения органических целей. \
		Пусть он довольно громоздкий и устаревший, однако его всё ещё следует бояться и уважать - огонь пощады не знает. \
		Можно подключить к огнемётному ранцу F7-3 \"Буратино\""

/////////////////////
// Топливный Ранец //
/obj/item/storage/backpack/marine/feline_flamer_backpack
	name = "Огнемётный ранец ЮСКМ F7-3 \"Буратино\""
	desc = "Военный огнемётный ранец хранящий в себе до трех типов топлива и воду. Подача к огнемёту осуществляется посредством топливного \
		рукава через управляемый редуктор. Повышенное давление усиливает эффективность огнемёта и навесного оборудования."
	desc_lore = "Продвинутая версия базового огнемётного ранца ЮСКМ. Главным отличием являются изолированные друг от друга топливные баллоны, \
		что позволяет переключаться между разными типами огнесмеси через встроенный редуктор. Первые два баллона специализированы \
		для заправки стандартным напалмом UT-N и B-Gel соответственно. Третий предназначен для заправки кастомным топливом или же \
		в качестве альтернативы сварочным топливом, что позволит заряжать сварочный аппарат. Для подключения третьего баллона к \
		редуктору сначала необходимо переключить клапан скрытый за панелью <b>ПКМ</b>. Повышенное давление, выдаваемое редуктором, немного \
		повышает скорость подачи огнесмеси как через стандартную форсунку, так и метательную форсунку, увеличивая у последней дальность \
		стрельбы. При подключении подствольного огнетушителя, вода забирается напрямую из встроенного пожарного бака, так же способного \
		заряжать стандартные огнетушители. Для подключения к огнемёту воспользуйтесь топливным рукавом в <b>верхней консоли</b> ранца."
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
	can_hold = list(/obj/item/ammo_magazine/flamer_tank, /obj/item/tool/extinguisher, /obj/item/storage/toolkit)
	storage_flags = STORAGE_FLAGS_POUCH


	var/obj/item/ammo_magazine/flamer_tank/internal/standart/fuel_standart		// Стандарт
	var/obj/item/ammo_magazine/flamer_tank/internal/green/fuel_green			// Зеленка
	var/obj/item/ammo_magazine/flamer_tank/internal/custom/fuel_custom			// Кастом
	var/obj/item/ammo_magazine/flamer_tank/internal/active_fuel					// Текущее топливо
	var/custom_tank_active = FALSE

	var/spec_item = FALSE								// Для спека

	var/max_water = 200									// Ёмкость для воды - хранится прямо в src реагентах

	var/empty = FALSE

	var/obj/item/weapon/gun/flamer/linked_flamer		// Линк на Огнемёт

	var/image/flamer_overlay

	actions_types = list(
		/datum/action/item_action/specialist/toggle_fuel_backpack,		// Кнопка переключения топлива
		/datum/action/item_action/specialist/create_flamer_hose)		// Кнопка создания рукава

	var/atom/tether_holder					// объект привязки
	var/range = 2							// дистанция привязи

/obj/item/storage/backpack/marine/feline_flamer_backpack/empty
	empty = TRUE

///////////////
// PYRO SPEC //
/obj/item/weapon/gun/flamer/pyro_spec
	name = "Огнемёт M250Т \"Пекло\""
	desc = "Продвинутая версия базового огнемёта M240. Конструкция рассчитана на использование более смертоносных огнесмесей, на рейлинги \
		предустановлен продвинутый обвес, совмещающий одновременно и мощный огнетушитель, и метательную форсунку.\
		Можно подключить к огнемётному ранцу F7-3 \"Папа Карло\". Разрешен к использованию только авторизованными лицами. \
		Для подключения к огнемёту воспользуйтесь топливным рукавом в верхней консоли ранца."

	icon = 'core_ru/Feline/icons/flamer_backpack.dmi'
	icon_state = "m240_pyrospec"

	unacidable = TRUE
	explo_proof = TRUE
	current_mag = null

	spec_item = TRUE

	starting_attachment_types = list(/obj/item/attachable/attached_gun/extinguisher/pyro, /obj/item/attachable/attached_gun/flamer_nozzle/pyro)

	flags_gun_features = GUN_UNUSUAL_DESIGN|GUN_WIELDED_FIRING_ONLY
	flags_item = TWOHANDED|NO_CRYO_STORE

// Ранец
/obj/item/storage/backpack/marine/feline_flamer_backpack/pyro_spec
	name = "Огнемётный ранец ЮСКМ F8-5 \"Папа Карло\""
	desc = "Элитная версия базового огнемётного ранца ЮСКМ. Адаптирован для питания через увеличенные топливные баллоны и заправлен лучшими \
		огнесмесями из отдела РнД. Разрешен к использованию только авторизованными лицами."

	icon = 'icons/obj/items/clothing/backpack/backpacks_by_map/jungle.dmi'
	item_icons = list(
		WEAR_BACK = 'icons/mob/humans/onmob/clothing/back/backpacks_by_map/jungle.dmi',
		WEAR_L_HAND = 'icons/mob/humans/onmob/inhands/items_by_map/jungle_lefthand.dmi',
		WEAR_R_HAND = 'icons/mob/humans/onmob/inhands/items_by_map/jungle_righthand.dmi'
		)

	icon_state = "flamethrower_broiler"
	item_state = "flamethrower_broiler"

	can_hold = list(/obj/item/weapon/gun/flamer/pyro_spec, /obj/item/ammo_magazine/flamer_tank, /obj/item/tool/extinguisher, /obj/item/storage/toolkit)
	storage_flags = STORAGE_FLAGS_POUCH|STORAGE_ALLOW_QUICKDRAW

	max_w_class = SIZE_LARGE
	max_storage_space = 30
	storage_slots = 3

	custom_tank_active = TRUE

	unacidable = TRUE
	explo_proof = TRUE
	spec_item = TRUE

////////////////////////
// Инициатор привязки //
/obj/item/flamer_hose
	name = "Топливный рукав"
	desc = "Гибкий топливный рукав для передачи огнесмеси из ранца в огнемёт. Внутри него несколько прочных термостойких шлангов для горючей смеси и воды."
	icon = 'core_ru/Feline/icons/flamer_backpack.dmi'
	icon_state = "m240_backpack_hose"

/obj/item/flamer_hose/on_enter_storage(obj/item/storage/S)
	. = ..()
	playsound(src, 'sound/weapons/flipblade.ogg', 25, TRUE)
	if(!QDELETED(src))
		QDEL_NULL(src)

/obj/item/flamer_hose/dropped()
	. = ..()
	playsound(src, 'sound/weapons/flipblade.ogg', 25, TRUE)
	if(!QDELETED(src))
		QDEL_NULL(src)

////////////////////////
// Связанные предметы //
/obj/item/ammo_magazine/flamer_tank/internal
	name = "Внутренний баллон огнемёта"
	desc = "Что-то сломалось. Ты не должен это видеть."
	icon_state = "flametank_large_custom"
	item_state = "flametank_large"
	max_rounds = 200
	gun_type = /obj/item/weapon/gun/flamer

	max_intensity = 40
	max_range = 5
	max_duration = 30

// Стандарт
/obj/item/ammo_magazine/flamer_tank/internal/standart
	name = "Баллон UT-N"

/obj/item/ammo_magazine/flamer_tank/internal/standart/empty
	flamer_chem = null

/obj/item/ammo_magazine/flamer_tank/internal/standart/pyro_spec
	max_rounds = 250
	max_range = 6

// Зеленка
/obj/item/ammo_magazine/flamer_tank/internal/green
	name = "Баллон B-gel"
	caliber = "Napalm Gel"
	flamer_chem = "napalmgel"
	max_range = 7
	max_duration = 50

/obj/item/ammo_magazine/flamer_tank/internal/green/empty
	flamer_chem = null

/obj/item/ammo_magazine/flamer_tank/internal/green/pyro_spec
	name = "Баллон Napalm B"
	caliber = "Napalm B"
	flamer_chem = "napalmb"
	max_rounds = 250

// Кастом
/obj/item/ammo_magazine/flamer_tank/internal/custom
	name = "Кастомный баллон"
	flamer_chem = null
	caliber = null
	custom = TRUE
	max_range = 7
	max_duration = 50

/obj/item/ammo_magazine/flamer_tank/internal/custom/pyro_spec
	name = "Баллон Napalm X"
	max_rounds = 250
	caliber = "Napalm X"
	flamer_chem = "napalmx"
	max_range = 6

// Снаряд пулялки
/datum/ammo/flamethrower/feline_flamer_backpack
	max_range = 7

/datum/ammo/flamethrower
	flags_ammo_behavior = AMMO_IGNORE_ARMOR|AMMO_HITS_TARGET_TURF|AMMO_IGNORE_COVER

// Перезапись параметров
/obj/item/tool/extinguisher
	max_water = 100
	power = 14

/obj/item/tool/extinguisher/mini
	power = 7

// Коробка карго
/obj/item/storage/box/guncase/feline_flamer
	name = "Огнемётный ранец \"Буратино\""
	desc = "Оружейный кейс огнемётчика. Содержит Огнемётный ранец \"Буратино\" (пустой), 2 баллона напалма UT-Napthal и 1 баллон Napalm B-Gel."
	storage_slots = 4
	can_hold = list(
		/obj/item/storage/backpack/marine/feline_flamer_backpack,
		/obj/item/weapon/gun/flamer,
		/obj/item/ammo_magazine/flamer_tank,
		/obj/item/attachable/attached_gun,
		/obj/item/tool
		)

/obj/item/storage/box/guncase/feline_flamer/fill_preset_inventory()
	new /obj/item/storage/backpack/marine/feline_flamer_backpack/empty(src)
	new /obj/item/ammo_magazine/flamer_tank(src)
	new /obj/item/ammo_magazine/flamer_tank(src)
	new /obj/item/ammo_magazine/flamer_tank/gellied(src)

// Коробка СЛа
/obj/item/storage/box/guncase/feline_flamer_sl_pyro
	name = "Комплект поддержки взвода \"Буратино\""
	desc = "Оружейный кейс огнемётчика. Содержит Огнемётный ранец \"Буратино\" (полный), 2 баллона напалма UT-Napthal и 1 баллон Napalm B-Gel."
	storage_slots = 8
	can_hold = list(
		/obj/item/storage/backpack/marine/feline_flamer_backpack,
		/obj/item/weapon/gun/flamer,
		/obj/item/ammo_magazine/flamer_tank,
		/obj/item/attachable/attached_gun,
		/obj/item/tool
		)

/obj/item/storage/box/guncase/feline_flamer_sl_pyro/fill_preset_inventory()
	new /obj/item/storage/backpack/marine/feline_flamer_backpack(src)
	new /obj/item/weapon/gun/flamer/m240(src)
	new /obj/item/ammo_magazine/flamer_tank(src)
	new /obj/item/ammo_magazine/flamer_tank(src)
	new /obj/item/ammo_magazine/flamer_tank/gellied(src)
	new /obj/item/attachable/attached_gun/flamer_nozzle(src)
	new /obj/item/attachable/attached_gun/extinguisher(src)
	new /obj/item/tool/extinguisher(src)

/datum/supply_packs/flamethrower
	name = "M240 Комплект огнемётчика (M240 x2, \"Буратино\" x2)"
	contains = list(
		/obj/item/storage/box/guncase/flamer,
		/obj/item/storage/box/guncase/flamer,
		/obj/item/storage/box/guncase/feline_flamer,
		/obj/item/storage/box/guncase/feline_flamer,
	)
	cost = 40
	containertype = /obj/structure/closet/crate/ammo/alt/flame
	containername = "M240 Incinerator crate"
	group = "Weapons"

///////////////
// Пиро Спек //
/obj/item/attachable/attached_gun/flamer_nozzle/pyro
	slot = "muzzle"
	flags_attach_features = ATTACH_ACTIVATION|ATTACH_WEAPON|ATTACH_MELEE|ATTACH_IGNORE_EMPTY
	projectile_type = /datum/ammo/flamethrower/feline_flamer_backpack
	pixel_shift_x = -17
	pixel_shift_y = 0

// Включение Носа
/obj/item/attachable/attached_gun/flamer_nozzle/pyro/activate_attachment(obj/item/weapon/gun/G, mob/living/user, turn_off)
	if(G.active_attachable && G.active_attachable != src)
		G.active_attachable.activate_attachment(G, user)
	if(G.active_attachable && G.active_attachable == src)
		if(user)
			to_chat(user, SPAN_NOTICE("Отключаю метательную форсунку."))
			playsound(user, gun_deactivate_sound, 30, 1)
		G.active_attachable = null
		icon_state = initial(icon_state)
		UnregisterSignal(G, COMSIG_GUN_RECALCULATE_ATTACHMENT_BONUSES)
		G.recalculate_attachment_bonuses()
	else
		if(user)
			to_chat(user, SPAN_NOTICE("Подключаю метательную форсунку."))
			playsound(user, 'core_ru/Feline/sound/Flamer_nozzle.ogg', 30, 1)
		G.active_attachable = src
		G.damage_mult = 1
		RegisterSignal(G, COMSIG_GUN_RECALCULATE_ATTACHMENT_BONUSES, PROC_REF(reset_damage_mult))
		icon_state = initial(icon_state)
		icon_state += "-on"

	attach_icon = "flamer_nozzle_a_[G.active_attachable == src ? 0 : 1]"
	G.update_icon()

	SEND_SIGNAL(G, COMSIG_GUN_INTERRUPT_FIRE)

	for(var/X in G.actions)
		var/datum/action/A = X
		A.update_button_icon()
	return 1

// Включение Огнетушителя
/obj/item/attachable/attached_gun/extinguisher/activate_attachment(obj/item/weapon/gun/G, mob/living/user, turn_off)
	. = ..()
	if(G.active_attachable)
		if(user)
			playsound(user, 'core_ru/Feline/sound/Flamer_ext.ogg', 30, 1)


/obj/item/attachable/attached_gun/extinguisher/pyro/activate_attachment(obj/item/weapon/gun/G, mob/living/user, turn_off)
	if(G.active_attachable && G.active_attachable != src)
		G.active_attachable.activate_attachment(G, user)

	if(G.active_attachable && G.active_attachable == src)
		if(user)
			to_chat(user, SPAN_NOTICE("Отключаю огнетушитель."))
			playsound(user, gun_deactivate_sound, 30, 1)
		G.active_attachable = null
		icon_state = initial(icon_state)
		UnregisterSignal(G, COMSIG_GUN_RECALCULATE_ATTACHMENT_BONUSES)
		G.recalculate_attachment_bonuses()
	else
		if(user)
			to_chat(user, SPAN_NOTICE("Подключаю огнетушитель."))
			playsound(user, 'core_ru/Feline/sound/Flamer_ext.ogg', 20, 1)
		G.active_attachable = src
		G.damage_mult = 1
		RegisterSignal(G, COMSIG_GUN_RECALCULATE_ATTACHMENT_BONUSES, PROC_REF(reset_damage_mult))
		icon_state = initial(icon_state)
		icon_state += "-on"

	SEND_SIGNAL(G, COMSIG_GUN_INTERRUPT_FIRE)

	for(var/X in G.actions)
		var/datum/action/A = X
		A.update_button_icon()
	return 1

// Бинд Носа
/obj/item/weapon/gun/flamer/pyro_spec/use_toggle_burst()
	var/obj/item/attachable/attached_gun/flamer_nozzle/pyro/nozzle = locate() in contents
	if(nozzle)
		nozzle.activate_attachment(src, gun_user, FALSE)

/obj/item/weapon/gun/flamer/pyro_spec/able_to_fire(mob/user)
	. = ..()
	if(.)
		if(!current_mag || !current_mag.current_rounds)
			return FALSE

		if(!skillcheck(user, SKILL_SPEC_WEAPONS,  SKILL_SPEC_ALL) && user.skills.get_skill_level(SKILL_SPEC_WEAPONS) != SKILL_SPEC_PYRO)
			to_chat(user, SPAN_WARNING("Я не знаю как этим пользоваться..."))
			return FALSE

// Магнитка
/obj/item/weapon/gun/flamer/pyro_spec/retrieval_check(mob/living/carbon/human/user, retrieval_slot)
	if(retrieval_slot == WEAR_IN_BACK)
		var/obj/item/storage/backpack/marine/feline_flamer_backpack/pyro_spec/FP = user.back
		if(FP && istype(FP))
			return TRUE
		return FALSE
	return ..()

/obj/item/weapon/gun/flamer/pyro_spec/retrieve_to_slot(mob/living/carbon/human/user, retrieval_slot)
	if(retrieval_slot == WEAR_J_STORE)
		if(..(user, WEAR_IN_BACK))
			return TRUE
	return ..()

// Экипировка в ранец
/obj/item/weapon/gun/flamer/pyro_spec/equipped(mob/user, slot, silent)
	. = ..()
	if(slot == WEAR_J_STORE)
		if(fuel_backpack)
			user.equip_to_slot_if_possible(src, WEAR_IN_BACK, disable_warning = TRUE)
			playsound(src, 'sound/weapons/gun_rifle_draw.ogg', 15, TRUE)
	update_icon()

/obj/item/storage/backpack/marine/feline_flamer_backpack/pyro_spec/update_icon()
	. = ..()
	overlays -= flamer_overlay
	if(locate(/obj/item/weapon/gun/flamer/pyro_spec) in contents)
		overlays += flamer_overlay

/obj/item/storage/backpack/marine/feline_flamer_backpack/pyro_spec/attack_hand(mob/user, mods)
	if(locate(/obj/item/weapon/gun/flamer/pyro_spec) in contents)
		var/obj/item/weapon/gun/flamer/pyro_spec/F = locate(/obj/item/weapon/gun/flamer/pyro_spec) in contents
		F.attack_hand(user)
	else
		..()

///////////////////
// Инициализация //
/obj/item/storage/backpack/marine/feline_flamer_backpack/Initialize()
	. = ..()
	if(empty)
		fuel_standart = new /obj/item/ammo_magazine/flamer_tank/internal/standart/empty()
		fuel_green = new /obj/item/ammo_magazine/flamer_tank/internal/green/empty()
	else
		fuel_standart = new /obj/item/ammo_magazine/flamer_tank/internal/standart()
		fuel_green = new /obj/item/ammo_magazine/flamer_tank/internal/green()
	fuel_custom = new /obj/item/ammo_magazine/flamer_tank/internal/custom()
	active_fuel = fuel_standart

	create_reagents(max_water)
	reagents.add_reagent("water", max_water)

/obj/item/storage/backpack/marine/feline_flamer_backpack/pyro_spec/Initialize()
	. = ..()
	fuel_standart = new /obj/item/ammo_magazine/flamer_tank/internal/standart/pyro_spec()
	fuel_green = new /obj/item/ammo_magazine/flamer_tank/internal/green/pyro_spec()
	fuel_custom = new /obj/item/ammo_magazine/flamer_tank/internal/custom/pyro_spec()
	active_fuel = fuel_standart
	flamer_overlay = overlay_image('icons/obj/items/clothing/backpack/backpacks_by_map/jungle.dmi', "+m240t")

/////////////////////////
// Обновления спрайтов //
/obj/item/weapon/gun/flamer/dropped()
	if(fuel_backpack)
		update_icon()
	. = ..()

/obj/item/weapon/gun/flamer/pickup()
	if(fuel_backpack)
		update_icon()
	. = ..()

/obj/item/weapon/gun/flamer/on_exit_storage()
	if(fuel_backpack)
		update_icon()
	. = ..()

/obj/item/weapon/gun/flamer/equipped(mob/user, slot, silent)
	. = ..()
	update_icon()

////////////////
// Линк ранца //
/obj/item/weapon/gun/flamer/attackby(obj/item/A as obj, mob/user as mob)
	var/obj/item/flamer_hose/FH = A
	if(istype(FH) && !fuel_backpack && !(istype(src, /obj/item/weapon/gun/flamer/m240/spec)))
		if(istype(user.back, /obj/item/storage/backpack/marine/feline_flamer_backpack))
			if(user.get_inactive_hand() != src)
				to_chat(user, SPAN_WARNING("Для подключения топливного рукава к огнемёту необходимо держать его в руках!"))
				return
			var/obj/item/storage/backpack/marine/feline_flamer_backpack/FP = user.back
			if(FP && (FP.spec_item && src.spec_item) || (!FP.spec_item && !src.spec_item) && !(istype(src, /obj/item/weapon/gun/flamer/flammenwerfer3)) && !(istype(src, /obj/item/weapon/gun/flamer/survivor)))
				link_fuelpack(user)
				if(!QDELETED(FH))
					QDEL_NULL(FH)
				to_chat(user, SPAN_NOTICE("Подключаю топливный рукав к огнемёту!"))
				if(current_mag && !(current_mag in list(FP.fuel_standart, FP.fuel_green, FP.fuel_custom)))
					to_chat(user, SPAN_WARNING("Отсоединяю [current_mag] и подключаю взамен [FP.active_fuel]!"))
					unload(user, drop_override = TRUE)
				current_mag = FP.active_fuel
				update_icon()
			else
				to_chat(user, SPAN_WARNING("Эти модели не совместимы!"))
				return
	. = ..()

/obj/item/weapon/gun/flamer/proc/link_fuelpack(mob/user)
	if(fuel_backpack)							// релинк
		fuel_backpack.linked_flamer = null
		fuel_backpack = null

	if(istype(user.back, /obj/item/storage/backpack/marine/feline_flamer_backpack))
		var/obj/item/storage/backpack/marine/feline_flamer_backpack/FP = user.back
		if(FP.linked_flamer)
			FP.linked_flamer.fuel_backpack = null
		FP.linked_flamer = src
		fuel_backpack = FP

		// Стартовый инициатор выбора топлива
		fuel_backpack.active_fuel = fuel_backpack.fuel_standart
		for(var/datum/action/action_added as anything in actions)
			action_added.update_button_icon()
		playsound(src, 'sound/weapons/handling/flamer_reload.ogg', 25, TRUE)

		// Улучшить обвес
		set_fire_delay(25)
		var/obj/item/attachable/attached_gun/flamer_nozzle/nozzle = locate() in contents
		if(nozzle)
			nozzle.projectile_type = /datum/ammo/flamethrower/feline_flamer_backpack
			nozzle.delay_mod = -10

		var/obj/item/attachable/attached_gun/extinguisher/ext = locate() in contents
		if(ext)
			if(spec_item)
				ext.internal_extinguisher.power = 48
			else
				ext.internal_extinguisher.power = 14
				ext.delay_mod = -10

		return TRUE
	return FALSE

///////////////////////////////////////////
// Сброс линка || снятие рюкзака со спины //
/obj/item/storage/backpack/marine/feline_flamer_backpack/dropped()
	drop_link()
	..()

/obj/item/storage/backpack/marine/feline_flamer_backpack/proc/drop_link()
	if(linked_flamer)
		playsound(linked_flamer, 'sound/weapons/handling/flamer_unload.ogg', 25, 1)
		linked_flamer.fuel_backpack = null
		if(linked_flamer.current_mag in list(fuel_standart, fuel_green, fuel_custom))
			linked_flamer.current_mag = null

		// Сброс бонусов
		linked_flamer.set_fire_delay(35)
		var/obj/item/attachable/attached_gun/flamer_nozzle/nozzle = locate() in linked_flamer.contents
		if(nozzle)
			nozzle.projectile_type = /datum/ammo/flamethrower
			nozzle.delay_mod = 0

		var/obj/item/attachable/attached_gun/extinguisher/ext = locate() in linked_flamer.contents
		if(ext)
			ext.internal_extinguisher.power = 7
			ext.delay_mod = 0

		linked_flamer.reset_tether() // сброс привязки

		linked_flamer.update_icon()
		linked_flamer = null

//////////////////////////////////////////
//  Сброс прибавок || при снятии обвеса //
/obj/item/weapon/gun/flamer/on_detach(mob/user, obj/item/attachable/A)
	if(istype(A, /obj/item/attachable/attached_gun/flamer_nozzle))
		var/obj/item/attachable/attached_gun/flamer_nozzle/nozzle = A
		nozzle.projectile_type = /datum/ammo/flamethrower
		nozzle.delay_mod = 0
	if(istype(A, /obj/item/attachable/attached_gun/extinguisher))
		var/obj/item/attachable/attached_gun/extinguisher/ext = A
		ext.internal_extinguisher.power = 7
		ext.delay_mod = 0
	. = ..()


/obj/item/attachable/attached_gun/flamer_nozzle/Attach(obj/item/weapon/gun/G)
	if(istype(G, /obj/item/weapon/gun/flamer))
		var/obj/item/weapon/gun/flamer/F = G
		if(F.fuel_backpack)
			projectile_type = /datum/ammo/flamethrower/feline_flamer_backpack
			delay_mod = -10
	. = ..()

/obj/item/attachable/attached_gun/extinguisher/Attach(obj/item/weapon/gun/G)
	if(istype(G, /obj/item/weapon/gun/flamer))
		var/obj/item/weapon/gun/flamer/F = G
		if(F.fuel_backpack)
			if(F.spec_item)
				internal_extinguisher.power = 48
			else
				internal_extinguisher.power = 14
				delay_mod = -10
	. = ..()

/////////////////
// Уничтожение //
/obj/item/storage/backpack/marine/feline_flamer_backpack/Destroy()
	if(linked_flamer)
		drop_link()
	QDEL_NULL(active_fuel)
	QDEL_NULL(fuel_standart)
	QDEL_NULL(fuel_green)
	QDEL_NULL(fuel_custom)
	QDEL_NULL(flamer_overlay)
	. = ..()

/obj/item/weapon/gun/flamer/Destroy()
	if(fuel_backpack)
		fuel_backpack.drop_link()
	. = ..()

///////////////////////////////
// Регистрация Атаки по себе //
/obj/item/storage/backpack/marine/feline_flamer_backpack/attackby(obj/item/A as obj, mob/user as mob)
	if(istype(A, /obj/item/ammo_magazine/flamer_tank))		// Зарядка от баллонов
		refill_fuel(A, user)

	if(iswelder(A))											// Заправка сварочника если в третьем баллоне сварочное топливо
		if(fuel_custom.reagents.has_reagent("fuel"))
			var/obj/item/tool/weldingtool/T = A
			if(T.welding)
				to_chat(user, SPAN_WARNING("Это было близко! Однако я вовремя заметил, что сварочный аппарат зажжён и смог предотврать катастрофу."))
				return
			if(!(T.get_fuel()==T.max_fuel) && fuel_custom.reagents.total_volume)
				fuel_custom.reagents.trans_to(A, T.max_fuel)
				to_chat(user, SPAN_NOTICE("Сварочный аппарат заправлен!"))
				playsound(loc, 'sound/effects/refill.ogg', 25, TRUE, 3)
				return
		else
			to_chat(user, SPAN_NOTICE("В данный момент кастомный бак не содержит сварочного топлива!"))

	if(istype(A, /obj/item/tool/extinguisher))				// Заправка ручного огнетушителя
		var/obj/item/tool/extinguisher/ext = A
		if(reagents.has_reagent("water"))
			reagents.trans_to(ext, ext.max_water)
			to_chat(user, SPAN_NOTICE("Огнетушитель заправлен!"))
			playsound(loc, 'sound/effects/refill.ogg', 25, TRUE, 3)

	. = ..()
/*
// Альтернативный способ подключения - оставлю на всякий случай
	var/obj/item/weapon/gun/flamer/F = A
	if(istype(F) && !(F.fuel_backpack))
		F.link_fuelpack(user)
		to_chat(user, SPAN_NOTICE("Подключаю топливный рукав к огнемёту!"))
		if(F.current_mag && !(F.current_mag in list(fuel_standart, fuel_green, fuel_custom)))
			to_chat(user, SPAN_WARNING("Отсоединяю [F.current_mag] и подключаю взамен [active_fuel]!"))
			F.unload(user, drop_override = TRUE)
		F.current_mag = active_fuel
		F.update_icon()
*/

/////////////////////////////////
// Перезарядка топливных баков //
/obj/item/storage/backpack/marine/feline_flamer_backpack/proc/refill_fuel(obj/item/W, mob/living/user)
	if (istype(W, /obj/item/ammo_magazine/flamer_tank))
		var/obj/item/ammo_magazine/flamer_tank/donor = W
		var/missing_standart_fuel = fuel_standart.max_rounds - fuel_standart.reagents.total_volume	// сколько не хватает топлива
		var/missing_green_fuel = fuel_green.max_rounds - fuel_green.reagents.total_volume
		var/missing_custom_fuel = fuel_custom.max_rounds - fuel_custom.reagents.total_volume

		// Если это СТАНДАРТ напалм, если баллон-донор не пуст, если бак не полон
		if((donor.caliber == "UT-Napthal Fuel") && donor.current_rounds && missing_standart_fuel)
			var/transfer_volume = missing_standart_fuel >= donor.reagents.total_volume  ? donor.reagents.total_volume  : missing_standart_fuel
			donor.reagents.trans_to(fuel_standart, transfer_volume)
			playsound(loc, 'sound/effects/refill.ogg', 25, TRUE, 3)
			fuel_standart.caliber = "UT-Napthal Fuel"
			user.visible_message(
					SPAN_NOTICE("[user] заправляет огнемётный ранец напалмом из баллона UT-Napthal."),
					SPAN_NOTICE("Заправляю огнемётный ранец [transfer_volume] единицами напалма из баллона UT-Napthal. В баллоне осталось [donor.reagents.total_volume] единиц."))
			to_chat(user, SPAN_NOTICE("Текущий уровень топлива UT-Napthal <b>[floor(fuel_standart.get_ammo_percent())]%</b>"))
			donor.update_icon()

		// Если это ЗЕЛЕНЫЙ напалм, если баллон-донор не пуст, если бак не полон
		else if((donor.caliber == "Napalm Gel") && donor.reagents.total_volume && missing_green_fuel)
			var/transfer_volume = missing_green_fuel >= donor.reagents.total_volume ? donor.reagents.total_volume : missing_green_fuel
			donor.reagents.trans_to(fuel_green, transfer_volume)
			playsound(loc, 'sound/effects/refill.ogg', 25, TRUE, 3)
			fuel_green.caliber = "Napalm Gel"
			user.visible_message(
					SPAN_NOTICE("[user] заправляет огнемётный ранец напалмом из баллона Napalm B-Gel."),
					SPAN_NOTICE("Заправляю огнемётный ранец [transfer_volume] единицами напалма из баллона Napalm B-Gel. В баллоне осталось [donor.reagents.total_volume] единиц."))
			to_chat(user, SPAN_NOTICE("Текущий уровень топлива Napalm B-Gel <b>[floor(fuel_green.get_ammo_percent())]%</b>"))
			donor.update_icon()

		// Если это ПИРО СПЕК, если это ЗЕЛЕНЫЙ напалм, если баллон-донор не пуст, если бак не полон
		else if((istype(src, /obj/item/storage/backpack/marine/feline_flamer_backpack/pyro_spec)) && (donor.caliber == "Napalm B") && donor.reagents.total_volume && missing_green_fuel)
			var/transfer_volume = missing_green_fuel >= donor.reagents.total_volume ? donor.reagents.total_volume : missing_green_fuel
			donor.reagents.trans_to(fuel_green, transfer_volume)
			playsound(loc, 'sound/effects/refill.ogg', 25, TRUE, 3)
			fuel_green.caliber = "Napalm B"
			user.visible_message(
					SPAN_NOTICE("[user] заправляет огнемётный ранец напалмом из баллона Napalm B."),
					SPAN_NOTICE("Заправляю огнемётный ранец [transfer_volume] единицами напалма из баллона Napalm B. В баллоне осталось [donor.reagents.total_volume] единиц."))
			to_chat(user, SPAN_NOTICE("Текущий уровень топлива Napalm B <b>[floor(fuel_green.get_ammo_percent())]%</b>"))
			donor.update_icon()

		// Если это ПИРО СПЕК, если это СИНИЙ напалм, если баллон-донор не пуст, если бак не полон
		else if((istype(src, /obj/item/storage/backpack/marine/feline_flamer_backpack/pyro_spec)) && (donor.caliber == "Napalm X") && donor.reagents.total_volume && missing_custom_fuel)
			var/transfer_volume = missing_custom_fuel >= donor.reagents.total_volume ? donor.reagents.total_volume : missing_custom_fuel
			donor.reagents.trans_to(fuel_custom, transfer_volume)
			playsound(loc, 'sound/effects/refill.ogg', 25, TRUE, 3)
			fuel_custom.caliber = "Napalm X"
			user.visible_message(
					SPAN_NOTICE("[user] заправляет огнемётный ранец напалмом из баллона Napalm X."),
					SPAN_NOTICE("Заправляю огнемётный ранец [transfer_volume] единицами напалма из баллона Napalm X. В баллоне осталось [donor.reagents.total_volume] единиц."))
			to_chat(user, SPAN_NOTICE("Текущий уровень топлива Napalm X <b>[floor(fuel_custom.get_ammo_percent())]%</b>"))
			donor.update_icon()

		// Если реагент у баллона-донора и бака одинаковый или же если бак пуст. И при всём этом баллон-донор не пуст, бак не полон, это не большой баллон и это не стандартное или зеленое топливо.
		else if(((donor.reagents.get_master_reagent_name() == fuel_custom.reagents.get_master_reagent_name()) || (fuel_custom.caliber == null)) && donor.reagents.total_volume && missing_custom_fuel && !(istype(donor, /obj/item/ammo_magazine/flamer_tank/large)) && (donor.caliber != "Napalm Gel") && (donor.caliber != "UT-Napthal Fuel"))
			var/transfer_volume = missing_custom_fuel >= donor.reagents.total_volume ? donor.reagents.total_volume : missing_custom_fuel
			donor.reagents.trans_to(fuel_custom, transfer_volume)
			playsound(loc, 'sound/effects/refill.ogg', 25, TRUE, 3)
			fuel_custom.caliber = donor.caliber
			user.visible_message(
					SPAN_NOTICE("[user] заправляет огнемётный ранец напалмом из кастомного баллона."),
					SPAN_NOTICE("Заправляю огнемётный ранец [transfer_volume] единицами напалма из кастомного баллона. В баллоне осталось [donor.reagents.total_volume] единиц."))
			to_chat(user, SPAN_NOTICE("Текущий уровень кастомного топлива <b>[floor(fuel_custom.get_ammo_percent())]%</b>"))
			donor.update_icon()
		else
			to_chat(user, SPAN_WARNING("Этот баллон не подходит или все ёмкости уже заполнены!"))

///////////////////////////
// Регистрация АвтоАтаки //
/obj/item/storage/backpack/marine/feline_flamer_backpack/afterattack(obj/target, mob/living/user, proximity)
	if(!proximity)
		return

	// Заправка от реагентного бака
	if(istype(target, /obj/structure/reagent_dispensers/fueltank))
		var/obj/structure/reagent_dispensers/fueltank/ft = target

		var/fueltank_reagent = ft.reagents.get_master_reagent_name()
		var/backpack_reagent = fuel_custom.reagents.get_master_reagent_name()

		// Реагент одинаковый или калибро не прописан
		if((fueltank_reagent == backpack_reagent) || (fuel_custom.caliber == null))
			if (fuel_custom.reagents.total_volume >= fuel_custom.max_rounds)
				to_chat(user, SPAN_NOTICE("Кастомный бак уже заполнен!"))
				return
			else
				ft.reagents.trans_to(fuel_custom, fuel_custom.max_rounds)
				fuel_custom.caliber = fueltank_reagent
				to_chat(user, SPAN_NOTICE("Заправляю кастомный баллон огнемётного ранца из бака."))
				playsound(loc, 'sound/effects/refill.ogg', 25, TRUE, 3)
				return
		else
			to_chat(user, SPAN_NOTICE("Кастомный бак должен быть пуст или быть заполненным тем же реагентом!"))
			return

	// Заправка от инженерных рюкзаков
	if((istype(target, /obj/item/tool/weldpack)) || (istype(target, /obj/item/storage/backpack/marine/engineerpack)))
		var/obj/item/wp = target

		var/fueltank_reagent = wp.reagents.get_master_reagent_name()
		var/backpack_reagent = fuel_custom.reagents.get_master_reagent_name()

		// Реагент одинаковый или калибро не прописан
		if((fueltank_reagent == backpack_reagent) || (fuel_custom.caliber == null))
			if (fuel_custom.reagents.total_volume >= fuel_custom.max_rounds)
				to_chat(user, SPAN_NOTICE("Кастомный бак уже заполнен!"))
				return
			else
				wp.reagents.trans_to(fuel_custom, fuel_custom.max_rounds)
				fuel_custom.caliber = fueltank_reagent
				to_chat(user, SPAN_NOTICE("Заправляю кастомный баллон огнемётного ранца из [wp]."))
				playsound(loc, 'sound/effects/refill.ogg', 25, TRUE, 3)
				user.animation_attack_on(wp)
				return
		else
			to_chat(user, SPAN_NOTICE("Кастомный бак должен быть пуст или быть заполненным тем же реагентом!"))
			return

	// Заправка от водного бака
	if(istype(target, /obj/structure/reagent_dispensers/watertank))
		var/obj/structure/reagent_dispensers/watertank/wt = target
		if(reagents.total_volume >= max_water)
			to_chat(user, SPAN_NOTICE("Баллон с водой полон!"))
			return
		else
			wt.reagents.trans_to(src, max_water)
			to_chat(user, SPAN_NOTICE("Заправляю пожарный баллон топливного ранца из бака."))
			playsound(loc, 'sound/effects/refill.ogg', 25, TRUE, 3)
			return

///////////////////////////
// Переключатель топлива //
/obj/item/weapon/gun/flamer/unique_action(mob/user)		// Огнемёт
	if(fuel_backpack)
		fuel_backpack.do_toggle_fuel(user)
	else
		toggle_gun_safety()

/obj/item/attachable/attached_gun/flamer_nozzle/unique_action(mob/user)	// Насадка
	var/obj/item/storage/backpack/marine/feline_flamer_backpack/flamer_backpack = user.back
	if(istype(flamer_backpack))
		if(flamer_backpack.linked_flamer)
			flamer_backpack.do_toggle_fuel(user)

///////////////////////////
// Переключатель режимов //
/obj/item/storage/backpack/marine/feline_flamer_backpack/proc/do_toggle_fuel(mob/user)
	if(!ishuman(user) || user.is_mob_incapacitated())
		return FALSE

	if(user.back != src)
		to_chat(user, SPAN_WARNING("Перед тем как переключить тип топлива необходимо надеть ранец на спину!"))
		return

	if(!linked_flamer)
		to_chat(user, SPAN_WARNING("Переключать тип топлива можно только после подключения огнемёта!"))
		return

	if(user.get_active_hand() != linked_flamer)
		to_chat(user, SPAN_WARNING("Для переключения типа топлива необходимо держать огнемёт в руках!"))
		return

	if(!active_fuel)
		return

	if(istype(active_fuel, /obj/item/ammo_magazine/flamer_tank/internal/standart))		// Если Стандарт ==> Зеленое
		active_fuel = fuel_green
	else if(istype(active_fuel, /obj/item/ammo_magazine/flamer_tank/internal/green))	// Если зеленое и
		if(custom_tank_active)															// 		активирован 3 баллон ==> Кастом
			active_fuel = fuel_custom
		else																			// 		не активирован 3 баллон ==> Стандарт
			active_fuel = fuel_standart
	else																				// Если кастомное ==> Стандарт
		active_fuel = fuel_standart

	for(var/datum/action/action_added as anything in actions)
		action_added.update_button_icon()

	to_chat(user, "Переключаю редуктор на [active_fuel.caliber ? "<b>[active_fuel.caliber]</b>." : "кастомный баллон, но он пуст!"]")
	playsound(src, 'sound/machines/click.ogg', 25, TRUE)
	linked_flamer.current_mag = active_fuel
	linked_flamer.update_icon()

	return TRUE

// Кнопка создания рукава
/datum/action/item_action/specialist/create_flamer_hose
	ability_primacy = SPEC_PRIMARY_ACTION_2

/datum/action/item_action/specialist/create_flamer_hose/New(mob/living/user, obj/item/holder)
	..()
	name = "Подключить топливный рукав"
	button.name = name
	button.overlays.Cut()
	var/image/IMG = image('core_ru/Feline/icons/flamer_backpack.dmi', button, "m240_backpack_hose")
	button.overlays += IMG

/datum/action/item_action/specialist/create_flamer_hose/can_use_action()
	var/mob/living/carbon/human/H = owner
	if(istype(H) && !H.is_mob_incapacitated() && H.body_position == STANDING_UP && holder_item == H.back)
		var/obj/item/storage/backpack/marine/feline_flamer_backpack/FP = holder_item
		if(!FP.linked_flamer)
			return TRUE

/datum/action/item_action/specialist/create_flamer_hose/action_activate()
	. = ..()
	var/obj/item/flamer_hose/I = new()
	owner.put_in_hands(I)
	playsound(owner, 'sound/weapons/gun_pistol_sheathe.ogg', 25, TRUE)

// Кнопка переключения топлива
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

	var/icon = 'core_ru/Feline/icons/flamer_backpack.dmi'
	var/icon_state
	var/image/IMG
	var/image/strips

	button.overlays.Cut()
	if(istype(FP.active_fuel, /obj/item/ammo_magazine/flamer_tank/internal/standart))
		icon_state = "flametank_standart"
		IMG = image(icon, button, icon_state)
		button.overlays += IMG
	if(istype(FP.active_fuel, /obj/item/ammo_magazine/flamer_tank/internal/green))
		icon_state = "flametank_green"
		IMG = image(icon, button, icon_state)
		button.overlays += IMG
	if(istype(FP.active_fuel, /obj/item/ammo_magazine/flamer_tank/internal/custom))
		var/obj/item/ammo_magazine/flamer_tank/internal/custom/cf = FP.active_fuel
		icon_state = "flametank_custom"
		if(cf.reagents)								// накладка и покраска полосок
			IMG = image(icon, button, icon_state)
			strips = image(icon, button, icon_state="[icon_state]_strip")
			strips.color = mix_color_from_reagents(cf.reagents.reagent_list)
			button.overlays += IMG
			button.overlays += strips
		else
			IMG = image(icon, button, icon_state)
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

/obj/item/storage/backpack/marine/feline_flamer_backpack/attack_self(mob/user)
	..()
	do_toggle_fuel(user)

// Меню переключения топлива
/obj/item/storage/backpack/marine/feline_flamer_backpack/verb/toggle_fuel()
	set name = "Переключить тип топлива"
	set desc = "Цикличное переключение редуктора между различными видами топлива."
	set category = "Object"
	set src in usr
	do_toggle_fuel(usr)

// Меню опустошения кастома
/obj/item/storage/backpack/marine/feline_flamer_backpack/verb/remove_reagents()
	set name = "Опустошить бак кастомного топлива"
	set category = "Object"

	set src in usr

	if(alert(usr, "Вы хотите опустошить бак кастомного топлива?", "Опустошить бак", "Да", "Нет") != "Да")
		return

	fuel_custom.reagents.clear_reagents()
	fuel_custom.caliber = null

	playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
	to_chat(usr, SPAN_NOTICE("Опустошаю бак кастомного топлива."))
	update_icon()

//  Меню включения кастома
/obj/item/storage/backpack/marine/feline_flamer_backpack/verb/toggle_custom()
	set name = "Переключатель кастомного топлива"
	set category = "Object"

	set src in usr

	if(alert(usr, "Вы хотите [custom_tank_active ? "отключить кастомное топливо от редуктора" : "подключить кастомное топливо к редуктору"]?", "Подключить?", "Да", "Нет") != "Да")
		return

	custom_tank_active = !custom_tank_active

	playsound(src, 'sound/machines/click.ogg', 25, TRUE)
	to_chat(usr, SPAN_NOTICE("[custom_tank_active ? "Подключаю кастомное топливо к редуктора" : "Отключаю кастомное топливо от редуктора"]."))
	update_icon()

///////////////////////
// Осмотр - описание //
/obj/item/storage/backpack/marine/feline_flamer_backpack/get_examine_text(mob/user)
	. = ..()
	if (get_dist(user, src) <= 1)
		if(fuel_standart)
			. += "Уровень топлива UT-Napthal: <b>[floor(fuel_standart.get_ammo_percent())]%</b>."
		if(fuel_green)
			. += "Уровень топлива Napalm B-Gel: <b>[floor(fuel_green.get_ammo_percent())]%</b>."
		if(fuel_custom)
			. += "[fuel_custom.caliber ? "Уровень топлива [fuel_custom.caliber]: <b>[floor(fuel_custom.get_ammo_percent())]%</b>" : "Кастомный бак пуст"]."
		. += "Уровень воды: <b>[floor(reagents.total_volume) / max_water * 100]%</b>."

///////////////////
// Эффект шланга //
/obj/item/storage/backpack/marine/feline_flamer_backpack/forceMove(atom/dest)				// перепроверка при перемещении (волочение)
	. = ..()
	if(isturf(dest))
		set_tether_holder(src)
	else
		set_tether_holder(loc)

/obj/item/storage/backpack/marine/feline_flamer_backpack/proc/set_tether_holder(atom/A)		// привязка к рюкзаку
	tether_holder = A

	if(linked_flamer)
		linked_flamer.reset_tether()

/obj/item/weapon/gun/flamer/proc/reset_tether()												// перепривязка
	SIGNAL_HANDLER
	if (tether_effect)
		UnregisterSignal(tether_effect, COMSIG_PARENT_QDELETING)
		if(!QDESTROYING(tether_effect))
			qdel(tether_effect)
		tether_effect = null
	if(!do_zlevel_check())
		on_beam_removed()

/obj/item/weapon/gun/flamer/proc/on_beam_removed()											// эффект луча
	if(!fuel_backpack)
		return

	if(loc == fuel_backpack)
		return

	if(get_dist(fuel_backpack, src) > fuel_backpack.range)
		fuel_backpack.drop_link()
		return

	var/atom/tether_to = src

	if(loc != get_turf(src))
		tether_to = loc
		if(tether_to.loc != get_turf(tether_to))
			fuel_backpack.drop_link()
			return

	var/atom/tether_from = fuel_backpack

	if(fuel_backpack && fuel_backpack.tether_holder)
		tether_from = fuel_backpack.tether_holder

	if(tether_from == tether_to)
		return

	var/list/tether_effects = apply_tether(tether_from, tether_to, range = fuel_backpack.range, icon = "wire", always_face = FALSE)
	tether_effect = tether_effects["tetherer_tether"]
	RegisterSignal(tether_effect, COMSIG_PARENT_QDELETING, PROC_REF(reset_tether))

/obj/item/weapon/gun/flamer/forceMove(atom/dest)									// перепроверка при перемещении (остановка)
	. = ..()
	if(.)
		reset_tether()

/obj/item/weapon/gun/flamer/proc/do_zlevel_check()									// проверка Z уровней
	if(!fuel_backpack || !loc.z || !fuel_backpack.z)
		return FALSE

	if(zlevel_transfer)
		if(loc.z == fuel_backpack.z)
			zlevel_transfer = FALSE
			if(zlevel_transfer_timer)
				deltimer(zlevel_transfer_timer)
			UnregisterSignal(fuel_backpack, COMSIG_MOVABLE_MOVED)
			return FALSE
		return TRUE

	if(fuel_backpack && loc.z != fuel_backpack.z)
		zlevel_transfer = TRUE
		zlevel_transfer_timer = addtimer(CALLBACK(src, PROC_REF(try_doing_tether)), zlevel_transfer_timeout, TIMER_UNIQUE|TIMER_STOPPABLE)
		RegisterSignal(fuel_backpack, COMSIG_MOVABLE_MOVED, PROC_REF(transmitter_move_handler))
		return TRUE
	return FALSE

/obj/item/weapon/gun/flamer/proc/transmitter_move_handler(datum/source)				// обработка перемещения
	SIGNAL_HANDLER
	zlevel_transfer = FALSE
	if(zlevel_transfer_timer)
		deltimer(zlevel_transfer_timer)
	UnregisterSignal(fuel_backpack, COMSIG_MOVABLE_MOVED)
	reset_tether()

/obj/item/weapon/gun/flamer/proc/try_doing_tether()									// проверка циклирования
	zlevel_transfer_timer = TIMER_ID_NULL
	zlevel_transfer = FALSE
	UnregisterSignal(fuel_backpack, COMSIG_MOVABLE_MOVED)
	reset_tether()
