/**
 * RUCM Feline "Фоботы"
 * Палатка полевого хирурга стала больше, вендомат палатки и солдатов стал богаче, добавлена коробка с протезами
 * Затронутые файлы:
 * code\game\machinery\vending\vendor_types\medical.dm
 */

///////////////////////
// Полевой госпиталь //
/obj/item/folded_tent/bigmed
	name = "Сложенная большая санитарная палатка ЮСКМ"
	icon_state = "bigmed"
	desc = "Большая санитарная палатка ЮСКМ. Позволяет проводить операции в условиях чуть меньшей антисанитарии чем на голой земле. \
		Можно разобрать при помощи сапёрной лопатки."
	template_preset = "tent_bigmed"

/datum/map_template/tent/bigmed
	name = "BIGMED Tent"
	map_id = "tent_bigmed"

/obj/structure/tent/big/med
	name = "Полевой Госпиталь"
	desc = "Большая санитарная палатка ЮСКМ. Позволяет проводить операции в условиях чуть меньшей антисанитарии чем на голой земле. \
		Можно разобрать при помощи сапёрной лопатки."
	icon_state = "bigmed_interior"
	roof_state = "bigmed_top"
	var/surgery_speed_mult = 0.75
	var/surgery_pain_reduction = 10

/obj/structure/tent/big/med/movable_entering_tent(turf/hooked, atom/movable/subject)
	. = ..()
	if(ishuman(subject))
		RegisterSignal(subject, COMSIG_HUMAN_SURGERY_APPLY_MODIFIERS, PROC_REF(apply_surgery_modifiers), override = TRUE)

/obj/structure/tent/big/med/mob_exited_tent(mob/subject)
	. = ..()
	UnregisterSignal(subject, COMSIG_HUMAN_SURGERY_APPLY_MODIFIERS)

/obj/structure/tent/big/med/proc/apply_surgery_modifiers(mob/living/carbon/human/source, list/surgery_data)
	SIGNAL_HANDLER
	surgery_data["surgery_speed"] *= surgery_speed_mult
	surgery_data["pain_reduction"] += surgery_pain_reduction

// Оборудование госпиталя
/obj/structure/machinery/optable/tent
	needs_power = FALSE

/obj/structure/machinery/optable/tent/Initialize()
	AddComponent(/datum/component/tent_supported_object)
	return ..()

/obj/structure/machinery/cm_vending/sorted/medical
	var/no_unstock = FALSE

/obj/structure/machinery/cm_vending/sorted/medical/wall_med/tent/plus
	name = "НаноМед+"
	desc = "Полевой раздатчик медикаментов."
	chem_refill_volume = 300
	chem_refill_volume_max = 300
	no_unstock = TRUE
	chem_refill = list(
		/obj/item/reagent_container/hypospray/autoinjector/skillless,
		/obj/item/reagent_container/hypospray/autoinjector/bicaridine,
		/obj/item/reagent_container/hypospray/autoinjector/kelotane,
		/obj/item/reagent_container/hypospray/autoinjector/dexalinp,
		/obj/item/reagent_container/hypospray/autoinjector/tricord,
		/obj/item/reagent_container/hypospray/autoinjector/tramadol,
		/obj/item/reagent_container/hypospray/autoinjector/oxycodone,
		/obj/item/reagent_container/hypospray/autoinjector/inaprovaline,
		/obj/item/reagent_container/hypospray/autoinjector/adrenaline,
	)

/obj/structure/machinery/cm_vending/sorted/medical/wall_med/tent/plus/populate_product_list()
	listed_products = list(
		list("Первая помощь", -1, null, null),
		list("Травматологический набор", 4, /obj/item/stack/medical/advanced/bruise_pack, VENDOR_ITEM_REGULAR),
		list("Ожоговый набор", 4, /obj/item/stack/medical/advanced/ointment, VENDOR_ITEM_REGULAR),
		list("Противовоспалительная мазь", 4, /obj/item/stack/medical/ointment, VENDOR_ITEM_REGULAR),
		list("Бинты", 4, /obj/item/stack/medical/bruise_pack, VENDOR_ITEM_REGULAR),
		list("Шины", 4, /obj/item/stack/medical/splint, VENDOR_ITEM_REGULAR),

		list("Медикаменты", -1, null, null),
		list("Автоинжектор (Бикаридин)", 2, /obj/item/reagent_container/hypospray/autoinjector/bicaridine, VENDOR_ITEM_REGULAR),
		list("Автоинжектор (Келотан)", 2, /obj/item/reagent_container/hypospray/autoinjector/kelotane, VENDOR_ITEM_REGULAR),
		list("Автоинжектор (Дексалин+)", 2, /obj/item/reagent_container/hypospray/autoinjector/dexalinp, VENDOR_ITEM_REGULAR),
		list("Автоинжектор (Трикордразин)", 2, /obj/item/reagent_container/hypospray/autoinjector/tricord, VENDOR_ITEM_REGULAR),
		list("Автоинжектор (Трамадол)", 2, /obj/item/reagent_container/hypospray/autoinjector/tramadol, VENDOR_ITEM_REGULAR),
		list("Автоинжектор (Оксикодон)", 2, /obj/item/reagent_container/hypospray/autoinjector/oxycodone, VENDOR_ITEM_REGULAR),
		list("Автоинжектор (Инапровалин)", 2, /obj/item/reagent_container/hypospray/autoinjector/inaprovaline, VENDOR_ITEM_REGULAR),
		list("Автоинжектор (Адреналин)", 2, /obj/item/reagent_container/hypospray/autoinjector/adrenaline, VENDOR_ITEM_REGULAR),

		list("Припасы", -1, null, null),
		list("Анализатор здоровья", 2, /obj/item/device/healthanalyzer, VENDOR_ITEM_REGULAR),
		list("Универсальная донорская кровь", 2, /obj/item/reagent_container/blood/OMinus, VENDOR_ITEM_REGULAR),
		list("Костный гель", 1, /obj/item/tool/surgery/bonegel, VENDOR_ITEM_REGULAR),
		list("Баллон анастезии", 1, /obj/item/tank/anesthetic, VENDOR_ITEM_REGULAR),
		list("Операционный набор", 1, /obj/item/storage/surgical_tray, VENDOR_ITEM_REGULAR),
		list("Каталка", 2, /obj/structure/bed/roller, VENDOR_ITEM_REGULAR),
		list("Портативный хирургический стол", 1, /obj/item/roller/surgical, VENDOR_ITEM_REGULAR),
		list("Мешки для тел", 1, /obj/item/storage/box/bodybags, VENDOR_ITEM_REGULAR),
	)

/obj/structure/machinery/cm_vending/sorted/medical/marinemed/plus
	name = "МаринМед+"
	desc = "Фармацевтический раздатчик базовых медицинских принадлежностей для морской пехоты."

/obj/structure/machinery/cm_vending/sorted/medical/marinemed/plus/populate_product_list(scale)
	listed_products = list(
		list("Медикаменты", -1, null, null),
		list("Автоинъектор (Трикордразин)", floor(scale * 5), /obj/item/reagent_container/hypospray/autoinjector/skillless, VENDOR_ITEM_REGULAR),
		list("Автоинъектор (Трамадол)", floor(scale * 5), /obj/item/reagent_container/hypospray/autoinjector/skillless/tramadol, VENDOR_ITEM_REGULAR),
		list("Блистер (Бикаридин)", floor(scale * 5), /obj/item/storage/pill_bottle/packet/bicaridine, VENDOR_ITEM_REGULAR),
		list("Блистер (Келотан)", floor(scale * 5), /obj/item/storage/pill_bottle/packet/kelotane, VENDOR_ITEM_REGULAR),
		list("Блистер (Трикордразин)", floor(scale * 5), /obj/item/storage/pill_bottle/packet/tricordrazine, VENDOR_ITEM_REGULAR),
		list("Блистер (Трамадол)", floor(scale * 5), /obj/item/storage/pill_bottle/packet/tramadol, VENDOR_ITEM_REGULAR),

		list("Медицинские Припасы", -1, null, null),
		list("Бинты", floor(scale * 8), /obj/item/stack/medical/bruise_pack, VENDOR_ITEM_REGULAR),
		list("Шины", floor(scale * 8), /obj/item/stack/medical/splint, VENDOR_ITEM_REGULAR),
		list("Противовоспалительная мазь", floor(scale * 8), /obj/item/stack/medical/ointment, VENDOR_ITEM_REGULAR),
		list("Анализатор здоровья", floor(scale * 3), /obj/item/device/healthanalyzer, VENDOR_ITEM_REGULAR),

		list("Припасы Общего Назначения", -1, null, null),
		list("Огнетушитель (компактный)", 5, /obj/item/tool/extinguisher/mini, VENDOR_ITEM_REGULAR),
		list("Фляжка (пустая)", 10, /obj/item/reagent_container/food/drinks/flask, VENDOR_ITEM_REGULAR),
		list("Баночка для таблеток (пустая)", 10, /obj/item/storage/pill_bottle/mini, VENDOR_ITEM_REGULAR),
	)

/obj/item/storage/firstaid/limbs
	name = "Комплект протезирования"
	desc = "Содержит два комплекта конечностей для полевого протезирования."
	icon = 'icons/obj/items/storage/kits.dmi'
	icon_state = "medicbox"
	empty_icon = "medicbox_e"
	item_icons = list(
		WEAR_L_HAND = 'icons/mob/humans/onmob/inhands/equipment/medical_lefthand.dmi',
		WEAR_R_HAND = 'icons/mob/humans/onmob/inhands/equipment/medical_righthand.dmi',
	)
	max_storage_space = 24
	storage_slots = 8
	max_w_class = SIZE_LARGE
	w_class = SIZE_SMALL
	can_hold = list(
		/obj/item/robot_parts/arm/l_arm,
		/obj/item/robot_parts/arm/r_arm,
		/obj/item/robot_parts/leg/r_leg,
		/obj/item/robot_parts/leg/l_leg,
	)

/obj/item/storage/firstaid/limbs/fill_preset_inventory()
	new /obj/item/robot_parts/arm/l_arm(src)
	new /obj/item/robot_parts/arm/r_arm(src)
	new /obj/item/robot_parts/leg/r_leg(src)
	new /obj/item/robot_parts/leg/l_leg(src)
	new /obj/item/robot_parts/arm/l_arm(src)
	new /obj/item/robot_parts/arm/r_arm(src)
	new /obj/item/robot_parts/leg/r_leg(src)
	new /obj/item/robot_parts/leg/l_leg(src)

/obj/item/storage/pill_bottle/mini
	name = "Баночка для таблеток"
	desc = "Простая баночка из пластика. Пусть она и выглядит так как будто её изготовили в прошлом столетии, но зато без блокировки!"
	storage_slots = 8
	max_storage_space = 8
	skilllock = SKILL_MEDICAL_DEFAULT
	storage_flags = STORAGE_FLAGS_BOX|STORAGE_DISABLE_USE_EMPTY
