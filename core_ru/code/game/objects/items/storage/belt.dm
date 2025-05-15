//	Добавлен механизм режима кобуры
/obj/item/storage/belt/gun
	var/holster_mode = TRUE	// Переключатель для выхватывания оружия

/obj/item/storage/belt/gun/verb/toggle_mode()	// Переключатель для выхватывания оружия
	set category = "Object"
	set name = "Переключить режим кобуры"
	set src in usr
	if(src && ishuman(usr))
		holster_mode = !holster_mode
		to_chat(usr, SPAN_NOTICE("Теперь при взаимодействии я буду [holster_mode ? "выхватывать оружие": "открывать пояс для осмотра"]."))

/obj/item/storage/belt/gun/get_examine_text()
	. = ..()
	. += SPAN_NOTICE("На данный момент при взаимодействии [holster_mode ? "оружие из пояса сразу берётся в руки": "пояс открывается для осмотра"].")

/obj/item/storage/belt/gun/attack_hand(mob/user, mods)
	if(holster_mode)
		if(length(holstered_guns) && ishuman(user) && loc == user)
			var/obj/item/I
			if(mods && mods["alt"] && length(contents) > length(holstered_guns)) //Withdraw the most recently inserted magazine, if possible.
				var/list/magazines = contents - holstered_guns
				I = magazines[length(magazines)]
			else //Otherwise find and draw the last-inserted gun.
				I = holstered_guns[length(holstered_guns)]
			I.attack_hand(user)
			return

	..()

//	Ремонтный пояс
//	Доступен за очки, хранит гвоздомет, его магазины и много материалов, за основу взята механика XM51

/obj/item/storage/belt/gun/repairbelt
	name = "M276 Repair belt"
	desc = "M276 является стандартной пехотной амуницией USCM, представляющую собой модульный ремнень с различными креплениями. Эта версия предназначена для инженерных войск, и имеет кобуру для промышленого гвоздомета, большой подсумок для материалов и пары магазинов."
	icon = 'core_ru/icons/obj/items/nailgun.dmi'
	icon_state = "nailgun_holster"
	item_icons = list(
		WEAR_WAIST = 'core_ru/icons/mob/humans/onmob/belt.dmi',
		WEAR_L_HAND = 'core_ru/icons/mob/humans/onmob/items_lefthand_1.dmi',
		WEAR_R_HAND = 'core_ru/icons/mob/humans/onmob/items_righthand_1.dmi'
		)
	item_state_slots = list(
		WEAR_L_HAND = "utility",
		WEAR_R_HAND = "utility"
		)
	flags_atom = FPRINT|NO_GAMEMODE_SKIN
	gun_has_gamemode_skin = FALSE
	holster_mode = FALSE
	storage_slots = 10
	max_w_class = 5
	can_hold = list(
		/obj/item/weapon/gun/smg/nailgun,
		/obj/item/ammo_magazine/smg/nailgun,
		/obj/item/ammo_magazine/handful,
		/obj/item/ammo_magazine/pistol,
		/obj/item/tool/weldingtool,
		/obj/item/tool/shovel/etool,
		/obj/item/device/lightreplacer,

		/obj/item/stack/barbed_wire,
		/obj/item/stack/sheet,
		/obj/item/stack/rods,
		/obj/item/stack/cable_coil,
		/obj/item/stack/tile,
		/obj/item/stack/sandbags_empty,
	)
	holster_slots = list(
		"1" = list(
			"icon_x" = 8,
			"icon_y" = 0))

	var/maxmats = 5
	var/mats = 0

/obj/item/storage/belt/gun/repairbelt/full/fill_preset_inventory()
	handle_item_insertion(new /obj/item/weapon/gun/smg/nailgun/compact())
	new /obj/item/ammo_magazine/smg/nailgun(src)
	new /obj/item/ammo_magazine/smg/nailgun(src)
	new /obj/item/tool/weldingtool/hugetank(src)
	new /obj/item/device/lightreplacer(src)
	new /obj/item/tool/shovel/etool(src)
	new /obj/item/stack/sheet/metal/large_stack(src)
	new /obj/item/stack/sheet/metal/medium_stack(src)
	new /obj/item/stack/sheet/plasteel/med_large_stack(src)

/obj/item/storage/belt/gun/repairbelt/can_be_inserted(obj/item/item, mob/user, stop_messages = FALSE) // проверка на добавление
	. = ..()
	if(mats >= maxmats && istype(item, /obj/item/stack))
		if(!stop_messages)
			to_chat(usr, SPAN_WARNING("[src] не может хранить больше материалов."))
		return FALSE

/obj/item/storage/belt/gun/repairbelt/handle_item_insertion(obj/item/item, prevent_warning = FALSE, mob/user) // добавление
	. = ..()
	if(istype(item, /obj/item/stack))
		mats++

/obj/item/storage/belt/gun/repairbelt/remove_from_storage(obj/item/item as obj, atom/new_location) // извлечение
	. = ..()
	if(istype(item, /obj/item/stack))
		mats--

/obj/item/storage/belt/gun/repairbelt/on_stored_atom_del(atom/movable/item) // удаление
	if(istype(item, /obj/item/stack))
		mats--

// Кейсы и заказы
/obj/item/storage/box/guncase/repairbelt
	name = "F1X Nailgun"
	desc = "Кейс, содержащий ремонтно-фортификационный набор. Поставляется с промышленным гвоздометом, магазинами к нему, сваркой, лопатой и комплектом материалов."
	storage_slots = 8
	can_hold = list()

/obj/item/storage/box/guncase/repairbelt/fill_preset_inventory()
	new /obj/item/weapon/gun/smg/nailgun(src)
	new /obj/item/ammo_magazine/smg/nailgun(src)
	new /obj/item/ammo_magazine/smg/nailgun(src)
	new /obj/item/tool/weldingtool/hugetank(src)
	new /obj/item/tool/shovel/etool(src)
	new /obj/item/stack/sheet/metal/med_small_stack(src)
	new /obj/item/stack/sandbags_empty/half(src)
	new /obj/item/storage/belt/gun/repairbelt(src)

/obj/item/storage/box/guncase/repairbelt/synth/fill_preset_inventory()
	new /obj/item/weapon/gun/smg/nailgun(src)
	new /obj/item/ammo_magazine/smg/nailgun(src)
	new /obj/item/ammo_magazine/smg/nailgun(src)
	new /obj/item/storage/belt/gun/repairbelt/full(src)

/datum/supply_packs/repairbelt
	name = "F1X Nailgun Create (х2)"
	contains = list(
		/obj/item/storage/box/guncase/repairbelt,
		/obj/item/storage/box/guncase/repairbelt,
	)
	cost = 30
	containertype = /obj/structure/closet/crate/weapon
	containername = "F1X Nailgun Create"
	group = "Weapons"

// XM52 Belt
/obj/item/storage/belt/gun/xm52
	name = "\improper M276 pattern XM52 holster rig"
	desc = "The M276 is the standard load-bearing equipment of the USCM. It consists of a modular belt with various clips. This version is for the XM52 breaching scattergun, allowing easier storage of the weapon. It features pouches for storing two magazines along with extra shells."
	icon = 'core_ru/icons/obj/items/clothing/belts.dmi'
	icon_state = "xm52_holster"
	flags_atom = FPRINT|NO_GAMEMODE_SKIN
	gun_has_gamemode_skin = FALSE
	storage_slots = 8
	max_w_class = 6
	can_hold = list(
		/obj/item/weapon/gun/rifle/xm52,
		/obj/item/ammo_magazine/rifle/xm52,
		/obj/item/ammo_magazine/handful,
	)
	holster_slots = list(
		"1" = list(
			"icon_x" = 10,
			"icon_y" = -1))

	//Keep a track of how many magazines are inside the belt.
	var/magazines = 0
	var/maxmag = 2
	var/obj/item/weapon/gun/rifle/xm52/magneted_xm
	var/magnetic_range = 2

/obj/item/storage/belt/gun/xm52/attackby(obj/item/item, mob/user)
	if(istype(item, /obj/item/ammo_magazine/shotgun/light/breaching/sparkshots))
/* TODO - fix handful sprites for dump_ammo_to
		var/obj/item/ammo_magazine/shotgun/light/breaching/sparkshots/ammo_box = item
		dump_ammo_to(ammo_box, user, ammo_box.transfer_handful_amount)
*/
		to_chat(user, SPAN_WARNING("You can't dump sparkshots in [src], sparkshots too explosive..."))
	else
		return ..()

/obj/item/storage/belt/gun/xm52/dump_ammo_to(obj/item/ammo_magazine/ammo_dumping, mob/user, amount_to_dump)
	if(user.action_busy)
		return

	if(ammo_dumping.flags_magazine & AMMUNITION_CANNOT_REMOVE_BULLETS)
		to_chat(user, SPAN_WARNING("You can't remove ammo from \the [ammo_dumping]!"))
		return

	if(ammo_dumping.flags_magazine & AMMUNITION_HANDFUL_BOX)
		var/handfuls = round(ammo_dumping.current_rounds / amount_to_dump, 1) //The number of handfuls, we round up because we still want the last one that isn't full
		if(ammo_dumping.current_rounds != 0)
			if(length(contents) < storage_slots - 1) //this is because it's a gunbelt and the final slot is reserved for the gun
				to_chat(user, SPAN_NOTICE("You start refilling [src] with [ammo_dumping]."))
				if(!do_after(user, 1.5 SECONDS, INTERRUPT_ALL, BUSY_ICON_GENERIC)) return
				for(var/i = 1 to handfuls)
					if(length(contents) < storage_slots - 1)
						var/obj/item/ammo_magazine/handful/new_handful = new /obj/item/ammo_magazine/handful
						var/transferred_handfuls = min(ammo_dumping.current_rounds, amount_to_dump)
						new_handful.generate_handful(ammo_dumping.default_ammo, ammo_dumping.caliber, amount_to_dump, transferred_handfuls, ammo_dumping.gun_type)
						new_handful.icon = 'core_ru/icons/obj/items/weapons/guns/handful.dmi' //основное что меняю
						ammo_dumping.current_rounds -= transferred_handfuls
						handle_item_insertion(new_handful, TRUE,user)
						update_icon(-transferred_handfuls)
					else
						break
				playsound(user.loc, "rustle", 15, TRUE, 6)
				ammo_dumping.update_icon()
			else
				to_chat(user, SPAN_WARNING("[src] is full."))

/obj/item/storage/belt/gun/xm52/can_be_inserted(obj/item/item, mob/user, stop_messages = FALSE)
	. = ..()
	if(magazines >= maxmag && istype(item, /obj/item/ammo_magazine/rifle/xm52))
		if(!stop_messages)
			to_chat(usr, SPAN_WARNING("[src] can't hold any more magazines."))
		return FALSE

/obj/item/storage/belt/gun/xm52/handle_item_insertion(obj/item/item, prevent_warning = FALSE, mob/user)
	. = ..()
	if(istype(item, /obj/item/ammo_magazine/rifle/xm52))
		magazines++

/obj/item/storage/belt/gun/xm52/remove_from_storage(obj/item/item as obj, atom/new_location)
	. = ..()
	if(istype(item, /obj/item/ammo_magazine/rifle/xm52))
		magazines--

//If a magazine disintegrates due to acid or something else while in the belt, remove it from the count.
/obj/item/storage/belt/gun/xm52/on_stored_atom_del(atom/movable/item)
	if(istype(item, /obj/item/ammo_magazine/rifle/xm52))
		magazines--

/obj/item/storage/belt/gun/xm52/_item_insertion(obj/item/I, prevent_warning = FALSE, mob/user)
	if(I.type == /obj/item/weapon/gun/rifle/xm52)
		if(!magneted_xm)
			magneted_xm = I
			magneted_xm.AddElement(/datum/element/drop_retrieval/xm52, src)
		if(!prevent_warning)
			to_chat(user, SPAN_NOTICE("You attach the sling to [I]."))
	..()

/obj/item/storage/belt/gun/xm52/attack_self(mob/user)
	if(magneted_xm)
		to_chat(user, SPAN_NOTICE("You retract the sling from [magneted_xm]."))
		unsling()
		return
	return ..()

/obj/item/storage/belt/gun/xm52/proc/unsling()
	if(!magneted_xm)
		return
	magneted_xm.RemoveElement(/datum/element/drop_retrieval/xm52, src)
	magneted_xm = null

/obj/item/storage/belt/gun/xm52/proc/sling_return(mob/living/carbon/human/user)
	if(!magneted_xm || !magneted_xm.loc)
		return FALSE
	if(magneted_xm.loc == user)
		return TRUE
	if(!isturf(magneted_xm.loc))
		return FALSE
	if(get_dist(magneted_xm, src) > magnetic_range)
		return FALSE
	if(handle_item_insertion(magneted_xm))
		if(user)
			to_chat(user, SPAN_NOTICE("[magneted_xm] snaps back into [src]."))
		return TRUE

/obj/item/storage/belt/gun/xm52/proc/attempt_retrieval(mob/living/carbon/human/user)
	if(sling_return(user))
		return
	unsling()
	if(user && src.loc == user)
		to_chat(user, SPAN_WARNING("The sling of your [src] snaps back empty!"))

/obj/item/storage/belt/gun/xm52/proc/handle_retrieval(mob/living/carbon/human/user)
	if(magneted_xm && magneted_xm.loc == src)
		return
	addtimer(CALLBACK(src, PROC_REF(attempt_retrieval), user), 0.3 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)

/datum/element/drop_retrieval/xm52
	compatible_types = list(/obj/item/weapon/gun)
	var/obj/item/storage/belt/gun/xm52/container

/datum/element/drop_retrieval/xm52/Attach(datum/target, obj/item/storage/belt/gun/xm52/new_container)
	. = ..()
	if(.)
		return
	container = new_container

/datum/element/drop_retrieval/xm52/dropped(obj/item/I, mob/user)
	container.handle_retrieval(user)

/obj/item/storage/belt/marine/smartgunner/m56c/fill_preset_inventory()
	new /obj/item/ammo_magazine/smartgun/m56c(src)
	new /obj/item/ammo_magazine/smartgun/m56c(src)
