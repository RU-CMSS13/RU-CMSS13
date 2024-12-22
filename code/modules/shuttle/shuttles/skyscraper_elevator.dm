// -- Docks
/obj/docking_port/stationary/sselevator
	name = "Sky Scraper Elevator Floor"
	id = MOBILE_SHUTTLE_SKY_SCRAPER_ELEVATOR
	width = 7
	height = 7

/obj/docking_port/stationary/sselevator/register()
	id = "[id]_[src.z]"
	. = ..()
	GLOB.ss_elevator_floors["[id]"] = src

/obj/docking_port/stationary/sselevator/load_roundstart()
	. = ..()
	var/obj/docking_port/mobile/sselevator/elevator = get_docked()
	if(elevator)
		elevator.handle_initial_data(src)


/obj/docking_port/stationary/sselevator/one
	id = MOBILE_SHUTTLE_SKY_SCRAPER_ELEVATOR_ONE


/obj/docking_port/stationary/sselevator/two
	id = MOBILE_SHUTTLE_SKY_SCRAPER_ELEVATOR_TWO

// -- Shuttles

/obj/docking_port/mobile/sselevator
	name = "sky scraper elevator"
	id = MOBILE_SHUTTLE_SKY_SCRAPER_ELEVATOR
	width = 7
	height = 7

	landing_sound = null
	ignition_sound = null
	ambience_flight = 'sound/ambience/elevator_music.ogg'
	ambience_idle = 'sound/ambience/elevator_music.ogg'
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)

	custom_ceiling = /turf/open/floor/roof/ship_hull/lab

	var/disabled_elevator = TRUE // Fix of auto mode, when shuttle got in troubles or loading
	var/total_floors = 39 // Number or relative floors we can go
	var/visual_floors_offset = 0 // Cool effect of underground floors? Yeah... useles, but cool.
	var/floor_offset = 0 // For relative coordinates in z dimension, aka we only count or current map, where elevator having fun
	var/offseted_z = 0 // Already calculated coordinate, so it's totaly relative z coord, not real one
	var/obj/docking_port/stationary/initial_dock = null // Home of elevator
	var/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator/door
	var/obj/structure/machinery/computer/shuttle/shuttle_control/sselevator/control_button
	var/list/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator/doors = list()
	var/list/obj/structure/machinery/gear/gears = list()
	var/list/obj/structure/machinery/computer/shuttle/shuttle_control/sselevator/buttons = list()
	var/list/disabled_floors // Relative list of z coords for elevator where can't go
	var/list/called_floors // Relative list of z coords for elevator where ordered
	var/target_floor = 0 // Where currently we heading (final relative z coord)
	var/next_moving = 0// Where we need to head after (final relative z coord)
	var/moving = FALSE // Direction we following right now
	var/cooldown = FALSE // Make sure we don't break shuttles system by multiple moving orders
	var/move_delay = 3 SECONDS
	var/max_move_delay = 10 SECONDS
	var/min_move_delay = 1 SECONDS

/obj/docking_port/mobile/sselevator/Destroy()
	initial_dock = null
	door = null
	control_button = null

	for(var/i in gears)
		gears -= i
	for(var/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator/i in doors)
		doors -= i
	for(var/obj/structure/machinery/computer/shuttle/shuttle_control/sselevator/i in buttons)
		buttons -= i

	. = ..()

	SSshuttle.scraper_elevators[id] = null

/obj/docking_port/mobile/sselevator/register()
	. = ..()
	SSshuttle.scraper_elevators[id] = src

/obj/docking_port/mobile/sselevator/request(obj/docking_port/stationary/S) //No transit, no ignition, just a simple up/down platform
	initiate_docking(S, force = TRUE)

/obj/docking_port/mobile/sselevator/afterShuttleMove()
	set background = TRUE

	offseted_z = z - floor_offset
	if(disabled_elevator || cooldown)
		return

	if(offseted_z == target_floor)
		cooldown = TRUE
		sleep(move_delay)
		on_stop_actions()
		moving = FALSE
		sleep(max_move_delay)
		cooldown = FALSE
		if(next_moving)
			target_floor = next_moving
			next_moving = 0
			moving = offseted_z > target_floor ? "DOWN" : "UP"
			on_move_actions()
			move_elevator()
		else
			// Soft fix, I have no idea, maybe my attempts to fix some mess around caused it, or it has been... but now we don't leave some floors in black list if you for some reason it clicked wrong time.
			for(var/i = 1 to total_floors)
				if(called_floors[i])
					calc_elevator_order(i)
					break

	else if(called_floors[offseted_z])
		cooldown = TRUE
		sleep(move_delay)
		on_stop_actions()
		sleep(max_move_delay)
		cooldown = FALSE
		on_move_actions()
		move_elevator()
	else
		move_elevator(FALSE)

/obj/docking_port/mobile/sselevator/proc/on_move_actions()
	control_button.update_icon("_animated")
	INVOKE_ASYNC(doors["[z]"], TYPE_PROC_REF(/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator, close_and_lock))
	INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator, close_and_lock))
	for(var/obj/structure/machinery/gear/gear as anything in gears)
		gear.start_moving()

/obj/docking_port/mobile/sselevator/proc/on_stop_actions()
	playsound(return_center_turf(), 'sound/machines/asrs_raising.ogg', 60, 0, falloff=4)
	var/obj/structure/machinery/computer/shuttle/shuttle_control/sselevator/button = buttons["[z]"]
	if(button)
		button.update_icon()
	control_button.update_icon()
	called_floors[offseted_z] = FALSE
	INVOKE_ASYNC(doors["[z]"], TYPE_PROC_REF(/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator, unlock_and_open))
	INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator, unlock_and_open))
	for(var/obj/structure/machinery/gear/gear as anything in gears)
		gear.stop_moving()

/obj/docking_port/mobile/sselevator/proc/move_elevator(message = TRUE)
	var/floor_to_move = offseted_z > target_floor ? offseted_z - 1 : offseted_z + 1
	if(message)
		control_button.visible_message(SPAN_NOTICE("Лифт отправляется и прибудет на этаж [floor_to_move]. Пожалуйста стойте в стороне от дверей."))
	sleep(move_delay * 2)
	calculate_move_delay(floor_to_move)
	SSshuttle.moveShuttleToDock(src, GLOB.ss_elevator_floors["[id]_[floor_to_move + floor_offset]"], move_delay, FALSE)

/obj/docking_port/mobile/sselevator/proc/calculate_move_delay(floor_calc)
	if(offseted_z > target_floor ? offseted_z - floor_calc > 4 : floor_calc - offseted_z > 4)
		move_delay--
	else
		move_delay += 0.2 SECONDS
	move_delay = clamp(move_delay, max_move_delay, min_move_delay)

/obj/docking_port/mobile/sselevator/proc/calc_elevator_order(floor_calc)
	var/obj/structure/machinery/computer/shuttle/shuttle_control/sselevator/button = buttons["[floor_calc + floor_offset]"]
	if(button)
		button.update_icon("_animated")
	called_floors[floor_calc] = TRUE

	// Simply logic make it think where it need to go... and then... we have two directions, so it's easy
	offseted_z = z - floor_offset
	switch(moving)
		if("DOWN")
			if(floor_calc > next_moving)
				next_moving = floor_calc
			else if(floor_calc < target_floor)
				target_floor = floor_calc
		if("UP")
			if(floor_calc > target_floor)
				target_floor = floor_calc
			else if(floor_calc < next_moving)
				next_moving = floor_calc
		else
			if((floor_calc > next_moving > offseted_z) || (floor_calc < next_moving < offseted_z))
				next_moving = floor_calc
			if((floor_calc > target_floor > offseted_z) || (floor_calc < target_floor < offseted_z))
				target_floor = floor_calc

	if(!moving && !cooldown)
		if(next_moving == target_floor)
			next_moving = 0
		moving = offseted_z > target_floor ? "DOWN" : "UP"
		on_move_actions()
		move_elevator()

// Reseting elevator if something messed up, because this system is not hard coded, so we can fuck up it easy
/obj/docking_port/mobile/sselevator/proc/handle_initial_data(obj/docking_port/stationary/target_dock, force_opened = FALSE)
	disabled_elevator = TRUE
	moving = TRUE
	cooldown = TRUE
	if(target_dock)
		initial_dock = target_dock

	if(initial_dock != get_docked())
		SSshuttle.moveShuttleToDock(src, initial_dock, move_delay, FALSE)

	floor_offset = z - total_floors
	offseted_z = z - floor_offset
	target_floor = offseted_z
	next_moving = 0

	disabled_floors = list()
	disabled_floors.len = total_floors
	called_floors = list()
	called_floors.len = total_floors
	for(var/i = 1 to total_floors)
		disabled_floors[i] = !force_opened
		called_floors[i] = FALSE

	disabled_floors[total_floors] = FALSE
	move_delay = 3 SECONDS
	max_move_delay = 10 SECONDS
	min_move_delay = 1 SECONDS

	var/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator/blastdoor = doors["[z]"]
	INVOKE_ASYNC(blastdoor, TYPE_PROC_REF(/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator, unlock_and_open))
	INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator, unlock_and_open))

	disabled_elevator = FALSE
	moving = FALSE
	cooldown = FALSE

/obj/docking_port/mobile/sselevator/one
	id = MOBILE_SHUTTLE_SKY_SCRAPER_ELEVATOR_ONE


/obj/docking_port/mobile/sselevator/two
	id = MOBILE_SHUTTLE_SKY_SCRAPER_ELEVATOR_TWO


/obj/docking_port/stationary/sselevator/floor_roof
	roundstart_template = /datum/map_template/shuttle/sky_scraper_elevator

/obj/docking_port/stationary/sselevator/one/floor_roof
	roundstart_template = /datum/map_template/shuttle/sky_scraper_elevator/one

/obj/docking_port/stationary/sselevator/two/floor_roof
	roundstart_template = /datum/map_template/shuttle/sky_scraper_elevator/two

//Console

/obj/structure/machinery/computer/shuttle/shuttle_control/sselevator
	name = "'S95 v2' elevator console"
	desc = "Controls for the 'S95 v2' elevator."
	icon = 'icons/obj/structures/machinery/computer.dmi'
	icon_state = "elevator_screen"

	var/elevator_id = "normal_elevator"
	var/floor

/obj/structure/machinery/computer/shuttle/shuttle_control/sselevator/Initialize(mapload, ...)
	. = ..()
	#if !defined(UNIT_TESTS)
	if(floor != "control")
		return INITIALIZE_HINT_ROUNDSTART
	#endif

/obj/structure/machinery/computer/shuttle/shuttle_control/sselevator/LateInitialize()
	var/obj/docking_port/mobile/sselevator/elevator = SSshuttle.scraper_elevators[elevator_id]
	if(!elevator)
		return

	floor = z
	elevator.buttons["[floor]"] = src

/obj/structure/machinery/computer/shuttle/shuttle_control/sselevator/Destroy()
	var/obj/docking_port/mobile/sselevator/elevator = SSshuttle.scraper_elevators[elevator_id]
	if(elevator)
		if(floor != "control")
			elevator.buttons["[floor]"] -= src
		else
			elevator.control_button = null

	. = ..()

/obj/structure/machinery/computer/shuttle/shuttle_control/sselevator/update_icon(icon_update = "")
	icon_state = initial(icon_state) + icon_update

/obj/structure/machinery/computer/shuttle/shuttle_control/sselevator/attack_hand(mob/user)
	if(!allowed(user))
		to_chat(user, SPAN_WARNING("Доступ Запрещен!"))
		return
	if(!isRemoteControlling(user))
		user.set_interaction(src)
	tgui_interact(user)

/obj/structure/machinery/computer/shuttle/shuttle_control/sselevator/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Elevator", name)
		ui.open()

/obj/structure/machinery/computer/shuttle/shuttle_control/sselevator/ui_data(mob/user)
	var/obj/docking_port/mobile/sselevator/elevator = SSshuttle.scraper_elevators[elevator_id]
	. = list("buttons" = list(), "current_floor" = elevator.offseted_z)
	if(!elevator)
		return
	for(var/i = 1 to elevator.total_floors)
		.["buttons"] += list(list(
			id = i, title = "Floor [i - elevator.visual_floors_offset]", disabled = elevator.disabled_floors[i], called = elevator.called_floors[i],
		))

/obj/structure/machinery/computer/shuttle/shuttle_control/sselevator/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	if(action == "click")
		var/target_floor = params["id"]
		var/obj/docking_port/mobile/sselevator/elevator = SSshuttle.scraper_elevators[elevator_id]
		if(elevator.offseted_z == target_floor || elevator.called_floors[target_floor])
			return
		playsound(src, 'sound/machines/click.ogg', 15, 1)
		elevator.calc_elevator_order(target_floor)
		return
	return

/obj/structure/machinery/computer/shuttle/shuttle_control/sselevator/connect_to_shuttle(mapload, obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	. = ..()
	if(istype(port, /obj/docking_port/mobile/sselevator))
		var/obj/docking_port/mobile/sselevator/elevator_port = port
		elevator_port.control_button = src

/obj/structure/machinery/computer/shuttle/shuttle_control/sselevator/button
	desc = "The remote controls for the 'S95 v2' elevator."

/obj/structure/machinery/computer/shuttle/shuttle_control/sselevator/button/attack_hand(mob/user)
	var/obj/docking_port/mobile/sselevator/elevator = SSshuttle.scraper_elevators[elevator_id]
	if(!allowed(user) || !elevator)
		to_chat(user, SPAN_WARNING("Доступ Запрещен!"))
		return
	if(elevator.z == floor)
		return
	if(elevator.disabled_floors[floor - elevator.floor_offset])
		visible_message(SPAN_WARNING("Лифт не может отправится на этот этаж, обратитесь на ближайший пост службы безопасности!"))
		return
	if(elevator.called_floors[floor - elevator.floor_offset])
		visible_message(SPAN_NOTICE("Лифт уже едет на этот этаж, ожидайте."))
		return
	call_elevator(user, elevator)

/obj/structure/machinery/computer/shuttle/shuttle_control/sselevator/button/proc/call_elevator(mob/user, obj/docking_port/mobile/sselevator/elevator)
	playsound(src, 'sound/machines/click.ogg', 15, 1)
	visible_message(SPAN_NOTICE("Лифт вызван, ожидайте."))
	elevator.calc_elevator_order(floor - elevator.floor_offset)


/obj/structure/machinery/computer/security_blocker
	name = "Security Controller"
	desc = "Used to control floors of sky scraper."
	icon_state = "terminal1"

	density = TRUE
	unacidable = TRUE
	anchored = TRUE

	var/time_required_to_unlock = 1.5 MINUTES
	var/time_in = 0
	var/started_time = 0
	var/total_segments = 10
	var/working = FALSE
	var/security_protocol = TRUE
	var/list/messages_in_total = list(
		"Запуск терминала",
		"Подключение к сети",
		"Ожидание ответа от корабля",
		"Ошибка, поиск в реестре кодов",
		"Обход основного блока синхронизации системы",
		"Подключение выполнено",
		"Подключаемся к главному серверу W-Y",
		"Скачиваем протоколы обхода защиты",
		"Получение рут прав",
		"Протоколы скачаны, запустите их для снятия блокировки, хорошего дня (C) W-Y General Security Systems"
	)

	var/last_action_time = 0
	var/list/obj/structure/machinery/door/poddoor/shutters/almayer/containment/skyscraper/stairs_doors = list()
	var/list/obj/structure/machinery/door/poddoor/shutters/almayer/containment/skyscraper/elevator_doors = list()
	var/list/obj/structure/machinery/door/poddoor/shutters/almayer/containment/skyscraper/move_lock_doors = list()
	var/list/obj/structure/machinery/light/double/almenia/lights = list()
	var/list/locked = list("stairs" = FALSE, "elevator" = FALSE)
	var/current_scraper_link

/obj/structure/machinery/computer/security_blocker/Initialize()
	. = ..()
	var/area/current = get_area(src)
	if(istype(current, /area/skyscraper/almenia))
		current_scraper_link = "almea"
	else if(istype(current, /area/skyscraper/ashwin))
		current_scraper_link = "ashwin"
	if(!current_scraper_link)
		return INITIALIZE_HINT_QDEL

	GLOB.skyscrapers_sec_comps[current_scraper_link]["[z]"] = src
	return INITIALIZE_HINT_ROUNDSTART

/obj/structure/machinery/computer/security_blocker/LateInitialize()
	for(var/obj/structure/machinery/siren/S as anything in GLOB.siren_objects["sky_scraper_[current_scraper_link]_[z]"])
		S.siren_warning_start("ВНИМАНИЕ, КРИТИЧЕСКАЯ СИТУАЦИЯ, ЗАПУЩЕН РЕЖИМ МАКСИМАЛЬНОЙ БЕЗОПАСНОСТИ, ВНИМАНИЕ, ОСТАВАЙТЕСЬ НА МЕСТАХ И ДОЖИДАЙТЕСЬ СЛУЖБУ БЕЗОПАСНОСТИ")
	for(var/obj/structure/machinery/light/double/almenia/L as anything in lights)
		L.change_almenia_state(1)

/obj/structure/machinery/computer/security_blocker/Destroy()
	for(var/i in stairs_doors)
		stairs_doors -= i
	for(var/i in elevator_doors)
		elevator_doors -= i
	for(var/i in move_lock_doors)
		move_lock_doors -= i
	for(var/i in lights)
		lights -= i

	if(current_scraper_link)
		GLOB.skyscrapers_sec_comps[current_scraper_link]["[z]"] = null

	. = ..()

/obj/structure/machinery/computer/security_blocker/ex_act(severity)
	return

/obj/structure/machinery/computer/security_blocker/attack_hand(mob/user)
	if(!allowed(user))
		to_chat(user, SPAN_WARNING("Доступ Запрещен!"))
		return
	if(!isRemoteControlling(user))
		user.set_interaction(src)
	tgui_interact(user)

/obj/structure/machinery/computer/security_blocker/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SkyScraperSecurity", "Security System")
		ui.open()

/obj/structure/machinery/computer/security_blocker/ui_data(mob/user)
	. = list()
	if(security_protocol)
		.["security_protocol"] = list()
		.["security_protocol"]["running"] = working
		.["security_protocol"]["messages"] = list()
		if(started_time)
			.["security_protocol"]["current_progress"] = clamp((world.time - started_time) / time_required_to_unlock * 100, 0, 100)
			for(var/i = 1 to floor((world.time - started_time) / (time_required_to_unlock / total_segments)))
				.["security_protocol"]["messages"] += list(list(messages_in_total[i]))
		else
			.["security_protocol"]["current_progress"] = time_in ? clamp(time_in / time_required_to_unlock * 100, 0, 100) : 0
			for(var/i = 1 to floor(time_in / (time_required_to_unlock / total_segments)))
				.["security_protocol"]["messages"] += list(list(messages_in_total[i]))
	.["interaction_time_lock"] = last_action_time > world.time

/obj/structure/machinery/computer/security_blocker/ui_static_data(mob/user)
	. = list()
	.["current_scraper_link"] = capitalize_first_letters(current_scraper_link)
	var/obj/docking_port/mobile/sselevator/elevator = SSshuttle.scraper_elevators[current_scraper_link == "almea" ? "sky_scraper_elevator_one" : "sky_scraper_elevator_two"]
	.["security_floor"] = elevator ? elevator.offseted_z : "NO LINK"

/obj/structure/machinery/computer/security_blocker/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(last_action_time > world.time)
		return

	last_action_time = world.time + 1 MINUTES
	switch(action)
		if("stairs")
			if(security_protocol)
				return

			if(!locked["elevator"])
				for(var/obj/structure/machinery/door/poddoor/shutters/almayer/containment/skyscraper/B as anything  in stairs_doors)
					if(locked["stairs"])
						INVOKE_ASYNC(B, TYPE_PROC_REF(/obj/structure/machinery/door, open))
					else
						INVOKE_ASYNC(B, TYPE_PROC_REF(/obj/structure/machinery/door, close))

				locked["stairs"] = !locked["stairs"]
				to_chat(usr, SPAN_WARNING("Лестница [locked["elevator"] ? "раз" : "за"]блокирована."))
			else
				to_chat(usr, SPAN_WARNING("Блокировка лифта не допускает блокировку лестницы!"))
				return
		if("elevator")
			if(security_protocol)
				return

			if(!locked["stairs"])
				for(var/obj/structure/machinery/door/poddoor/shutters/almayer/containment/skyscraper/B as anything in elevator_doors)
					if(locked["elevator"])
						INVOKE_ASYNC(B, TYPE_PROC_REF(/obj/structure/machinery/door, open))
					else
						INVOKE_ASYNC(B, TYPE_PROC_REF(/obj/structure/machinery/door, close))

				locked["elevator"] = !locked["elevator"]
				to_chat(usr, SPAN_WARNING("Лифт [locked["elevator"] ? "раз" : "за"]блокирован."))
			else
				to_chat(usr, SPAN_WARNING("Блокировка лестницы не допускает блокировку лифта!"))
				return
		if("unlock")
			if(security_protocol)
				return

			for(var/obj/structure/machinery/door/poddoor/shutters/almayer/containment/skyscraper/B as anything in stairs_doors + elevator_doors + move_lock_doors)
				if(B.density)
					INVOKE_ASYNC(B, TYPE_PROC_REF(/obj/structure/machinery/door, open))
				locked["stairs"] = FALSE
				locked["elevator"] = FALSE

		if("security")
			if(working || !security_protocol)
				return

			working = TRUE
			usr.visible_message("[usr] начал заниматься разблокировкой консоли.", "Вы начали разблокировать консоль.")
			started_time = world.time
			var/time_percent = do_after(usr, time_required_to_unlock - time_in, INTERRUPT_ALL, BUSY_ICON_BUILD, src, show_remaining_time = TRUE)
			if(!working)
				return

			if(!time_percent)
				unlock_floor()

			time_in = time_percent ? time_required_to_unlock - time_percent * time_required_to_unlock : time_required_to_unlock
			started_time = 0
			working = FALSE
	return

/obj/structure/machinery/computer/security_blocker/power_change()
	. = ..()
	if(inoperable() && working)
		time_in = world.time - started_time
		if(time_in >= time_required_to_unlock)// Edge case, lets be it here
			unlock_floor()
		started_time = 0
		working = FALSE
		playsound(src, 'sound/machines/ping.ogg', 25, 1)
		visible_message(SPAN_NOTICE("[src] beeps as it loses power."))

/obj/structure/machinery/computer/security_blocker/proc/unlock_floor()
	var/obj/docking_port/mobile/sselevator/elevator = SSshuttle.scraper_elevators[current_scraper_link == "almea" ? "sky_scraper_elevator_one" : "sky_scraper_elevator_two"]
	if(!elevator)
		visible_message(SPAN_NOTICE("[src] beeps as seems something went wrong."))
		return
	elevator.disabled_floors[z - elevator.floor_offset] = FALSE
	security_protocol = FALSE
	for(var/obj/structure/machinery/siren/S as anything in GLOB.siren_objects["sky_scraper_[current_scraper_link]_[z]"])
		S.siren_warning_stop()
	for(var/obj/structure/machinery/light/double/almenia/L as anything in lights)
		L.change_almenia_state(0)
	for(var/obj/structure/machinery/door/poddoor/shutters/almayer/containment/skyscraper/B as anything in move_lock_doors)
		if(B.density)
			INVOKE_ASYNC(B, TYPE_PROC_REF(/obj/structure/machinery/door, open))
	var/obj/structure/machinery/computer/security_blocker/parrent_blocker
	if((z - elevator.floor_offset) % 2 == 1)
		parrent_blocker = GLOB.skyscrapers_sec_comps[current_scraper_link]["[z-1]"]
	else
		parrent_blocker = GLOB.skyscrapers_sec_comps[current_scraper_link]["[z+1]"]
	for(var/obj/structure/machinery/door/poddoor/shutters/almayer/containment/skyscraper/B as anything in parrent_blocker.move_lock_doors)
		if(B.density)
			INVOKE_ASYNC(B, TYPE_PROC_REF(/obj/structure/machinery/door, open))


/turf/closed/wall/vents
	name = "Vents"
	desc = "Wall with big vents"
	icon = 'icons/turf/vent.dmi'
	icon_state = "vent"
// 0 open, 1 closed, 2 welded, 3 broken
	var/state = 0
	var/welding_stage = 0
	var/pressure = 0
	var/max_pressure = 10000

/turf/closed/wall/vents/update_icon()
	return FALSE

/turf/closed/wall/vents/can_be_dissolved()
	return FALSE

/turf/closed/wall/vents/thermitemelt()
	return FALSE

/turf/closed/wall/vents/dismantle_wall()
	state = 3
	icon_state = "vent_broken"

/turf/closed/wall/vents/attackby(obj/item/attacking_item, mob/user)
	if(!ishuman(user))
		to_chat(user, SPAN_WARNING("You don't have the dexterity to do this!"))
		return

	if(state > 1)
		return
	else if(HAS_TRAIT(attacking_item, TRAIT_TOOL_CROWBAR))
		to_chat(user, SPAN_WARNING("You start [state ? "opening" : "closing"] vents with your [attacking_item]."))
		if(!do_after(user, 10 SECONDS, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD, numticks = 3) || state > 1)
			to_chat(user, SPAN_WARNING("You stop [state ? "opening" : "closing"] vents with your [attacking_item]."))
			return FALSE
		to_chat(user, SPAN_WARNING("You [state ? "opened" : "closed"] vents."))
		state = !state
	else if(istype(attacking_item, /obj/item/stack/sheet/metal) && welding_stage == 0)
		if(!skillcheck(user, SKILL_ENGINEER, SKILL_ENGINEER_ENGI))
			to_chat(user, SPAN_WARNING("You do not understand how to do it [src]."))
			return FALSE
		var/obj/item/stack/sheet/metal/metal = attacking_item
		to_chat(user, SPAN_NOTICE("You start to reinforce \the [src]."))
		if(!do_after(user, 3 SECONDS, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD, numticks = 3))
			to_chat(user, SPAN_WARNING("You stop reinforcing \the [src]."))
			return FALSE
		if(!metal || !metal.use(40))
			to_chat(user, SPAN_WARNING("You need a 40 sheets of metal to reinforce."))
			return FALSE
		to_chat(user, SPAN_NOTICE("You reinforced \the [src]."))
		welding_stage++
		return TRUE
	else if(istype(attacking_item, /obj/item/stack/sheet/plasteel) && welding_stage == 1)
		if(!skillcheck(user, SKILL_ENGINEER, SKILL_ENGINEER_ENGI))
			to_chat(user, SPAN_WARNING("You do not understand how to do it [src]."))
			return FALSE
		var/obj/item/stack/sheet/plasteel/plasteel = attacking_item
		to_chat(user, SPAN_NOTICE("You start to reinforce \the [src]."))
		if(!do_after(user, 3 SECONDS, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD, numticks = 3))
			to_chat(user, SPAN_WARNING("You stop reinforcing \the [src]."))
			return FALSE
		if(!plasteel || !plasteel.use(10))
			to_chat(user, SPAN_WARNING("You need a 10 sheets of plasteel to reinforce."))
			return FALSE
		to_chat(user, SPAN_NOTICE("You reinforced \the [src]."))
		welding_stage++
		return TRUE
	else if(iswelder(attacking_item) && welding_stage == 2)
		if(!HAS_TRAIT(attacking_item, TRAIT_TOOL_BLOWTORCH))
			to_chat(user, SPAN_WARNING("You need a stronger blowtorch!"))
			return
		var/obj/item/tool/weldingtool/weldingtool = attacking_item
		if(!weldingtool.isOn())
			to_chat(user, SPAN_WARNING("\The [weldingtool] needs to be on!"))
			return
		playsound(src, 'sound/items/Welder.ogg', 25, 1)
		if(!do_after(user, 10 SECONDS, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD, numticks = 3) || state > 1)
			to_chat(user, SPAN_WARNING("You stop welding \the [src]."))
			return FALSE
		if(!weldingtool || !weldingtool.isOn())
			return
		to_chat(user, SPAN_NOTICE("You welded vent."))
		welding_stage++
		state = 2

/turf/closed/wall/vents/proc/spread_smoke(transfer_pressure, datum/cause_data/cause_data)
	var/turf/closed/wall/vents/above = SSmapping.get_turf_above(src)
	if(state == 1)
		if(istype(above) && max_pressure - pressure + above.max_pressure - above.pressure > transfer_pressure)
			pressure += transfer_pressure
			if(pressure > max_pressure)
				above.spread_smoke(pressure - max_pressure, cause_data)
				pressure = max_pressure
			return
		pressure += transfer_pressure
		playsound(src, 'sound/items/Welder.ogg', 25, 1)
		state = 0
		icon_state = "vent"

	var/obj/effect/particle_effect/smoke/chlor/foundsmoke = locate() in get_turf(src)
	if(!foundsmoke)
		foundsmoke = new(src, transfer_pressure, cause_data)
		foundsmoke.setDir(pick(GLOB.cardinals))
		foundsmoke.spread_smoke()
	else
		foundsmoke.amount = foundsmoke.amount + transfer_pressure
		foundsmoke.spread_smoke()
		pressure = foundsmoke.amount
		if(pressure > max_pressure)
			if(istype(above))
				above.spread_smoke(pressure*0.5, cause_data)
				foundsmoke.smoke_action_in(above)

/////////////////////////////////////////
// CHLOR SMOKE
/////////////////////////////////////////

/obj/effect/particle_effect/smoke/chlor
	color = "#c6d89e"
	opacity = FALSE
	spread_speed = 5
	smokeranking = SMOKE_RANK_MAX

/obj/effect/particle_effect/smoke/chlor/process()
	amount -= 0.1
	if(amount <= 0)
		qdel(src)
		return

	apply_smoke_effect(get_turf(src))

/obj/effect/particle_effect/smoke/chlor/spread_smoke(direction)
	set waitfor = FALSE
	sleep(spread_speed)
	if(QDELETED(src))
		return
	var/turf/own_turf = get_turf(src)
	if(!own_turf)
		return
	for(var/next_direction in GLOB.cardinals)
		if(direction && next_direction != direction)
			continue
		if(amount < 6)
			return
		var/turf/acting_turf = get_step(own_turf, next_direction)
		if(check_airblock(own_turf, acting_turf)) //smoke can't spread that way
			continue
		smoke_action_in(acting_turf)

/obj/effect/particle_effect/smoke/chlor/proc/smoke_action_in(turf/acting_turf)
	var/obj/effect/particle_effect/smoke/foundsmoke = locate() in acting_turf
	if(foundsmoke)
		if(foundsmoke.smokeranking <= smokeranking)
			qdel(foundsmoke)
		else if(foundsmoke.smokeranking == smokeranking && foundsmoke.amount < amount)
			var/amount_to_transfer = amount - foundsmoke.amount
			foundsmoke.amount += amount_to_transfer / 2
			amount += amount_to_transfer / 2
			if(foundsmoke.amount > 0)
				foundsmoke.spread_smoke()
			return

	var/obj/effect/particle_effect/smoke/S = new type(acting_turf, amount / 2, cause_data)
	amount /= 2
	S.setDir(pick(GLOB.cardinals))
	S.spread_smoke()

/obj/effect/particle_effect/smoke/chlor/Crossed(mob/living/carbon/target as mob)
	return

/obj/effect/particle_effect/smoke/chlor/affect(mob/living/carbon/target)
	..()

	if(target.stat == DEAD)
		return

	if(istype(target.wear_mask, /obj/item/clothing/mask/gas))
		if(prob(20))
			to_chat(target, SPAN_DANGER("You're having trouble breathing, but you're breathing in fresh air"))
		return

	target.last_damage_data = cause_data
	target.apply_damage(5, OXY) //Basic oxyloss from "can't breathe"
	if(target.coughedtime != 1 && !target.stat && ishuman(target)) //Coughing/gasping
		target.coughedtime = 1
		if(prob(50))
			target.emote("cough")
		else
			target.emote("gasp")
		addtimer(VARSET_CALLBACK(target, coughedtime, 0), 1.5 SECONDS)

	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.apply_armoured_damage(amount * (rand(1, 100) * 0.01), ARMOR_BIO, BURN) //Burn damage, randomizes between various parts //Amount corresponds to upgrade level, 1 to 2.5
	else
		target.burn_skin(5) //Failsafe for non-humans

	target.updatehealth()


/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator
	name = "'S95 v2' Elevator Door"
	desc = "A heavyset bulkhead for a elevator."
	icon = 'icons/obj/structures/doors/scielevatorblastdoor.dmi'
	safe = FALSE
	autoclose = FALSE
	locked = TRUE
	opacity = FALSE
	glass = TRUE

	var/throw_dir = SOUTH

	var/elevator_id = "normal_elevator"
	var/floor

/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator/Initialize(mapload, ...)
	. = ..()
	#if !defined(UNIT_TESTS)
	if(floor != "control")
		return INITIALIZE_HINT_ROUNDSTART
	#endif

/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator/LateInitialize()
	var/obj/docking_port/mobile/sselevator/elevator = SSshuttle.scraper_elevators[elevator_id]
	if(!elevator)
		return

	floor = z
	elevator.doors["[floor]"] = src

/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator/Destroy()
	var/obj/docking_port/mobile/sselevator/elevator = SSshuttle.scraper_elevators[elevator_id]
	if(elevator)
		if(floor != "control")
			elevator.doors["[floor]"] = null
		else
			elevator.door = null

	. = ..()

/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator/try_to_activate_door(mob/user)
	return

/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator/bumpopen(mob/user as mob)
	return

/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator/proc/close_and_lock()
	unlock()
	close()
	lock(TRUE)

/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator/proc/unlock_and_open()
	unlock()
	open()
	lock(TRUE)

/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator/close()
	. = ..()
	for(var/turf/self_turf as anything in locs)
		var/turf/projected = get_ranged_target_turf(self_turf, throw_dir, 1)
		for(var/atom/movable/atom_movable in self_turf)
			if(isliving(atom_movable) && !isobserver(atom_movable))
				var/mob/living/creature = atom_movable
				creature.KnockDown(5)
				to_chat(creature, SPAN_HIGHDANGER("\The [src] shoves you out!"))
			else if(isobj(atom_movable))
				var/obj/item = atom_movable
				if(item.anchored)
					continue
			else
				continue
			INVOKE_ASYNC(atom_movable, TYPE_PROC_REF(/atom/movable, throw_atom), projected, 1, SPEED_FAST, null, FALSE)

/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator/connect_to_shuttle(mapload, obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	. = ..()
	if(istype(port, /obj/docking_port/mobile/sselevator))
		var/obj/docking_port/mobile/sselevator/elevator_port = port
		elevator_port.door = src


/datum/map_template/shuttle/sky_scraper_elevator
	shuttle_id = MOBILE_SHUTTLE_SKY_SCRAPER_ELEVATOR
	name = "S95 v2 Elevator"

/datum/map_template/shuttle/sky_scraper_elevator/one
	shuttle_id = MOBILE_SHUTTLE_SKY_SCRAPER_ELEVATOR_ONE

/datum/map_template/shuttle/sky_scraper_elevator/two
	shuttle_id = MOBILE_SHUTTLE_SKY_SCRAPER_ELEVATOR_TWO


/obj/structure/machinery/siren
	name = "Siren"
	desc = "A siren used to play warnings for the colony."
	icon = 'icons/obj/structures/machinery/loudspeaker.dmi'
	icon_state = "loudspeaker"
	density = 0
	anchored = 1
	unacidable = 1
	unslashable = 1
	use_power = 0
	health = 0
	var/message = "ТРЕВОГА, ЧЕРЕЗВУЧАЙНАЯ СИТУАЦИЯ, ВСЕМ ВЫПОЛНЯТЬ АВАРИЙНЫЙ ПРОТОКОЛ"
	var/sound = 'sound/effects/weather_warning.ogg'
	var/siren_lt = "sky_scraper"

/obj/structure/machinery/siren/Initialize()
	. = ..()
	if(siren_lt == "sky_scraper")
		var/area/current = get_area(src)
		var/current_scraper_link
		if(istype(current, /area/skyscraper/almenia))
			current_scraper_link = "almea"
		else if(istype(current, /area/skyscraper/ashwin))
			current_scraper_link = "ashwin"

		if(!current_scraper_link)
			return INITIALIZE_HINT_QDEL

		siren_lt = "[siren_lt]_[current_scraper_link]_[z]"

	GLOB.siren_objects["[siren_lt]"] += list(src)

/obj/structure/machinery/siren/Destroy()
	GLOB.siren_objects["[siren_lt]"] -= src

	. = ..()

/obj/structure/machinery/siren/power_change()
	return

/obj/structure/machinery/siren/proc/siren_warning(msg = "ТРЕВОГА, критическая ситуация, всем выполнять базовые протоколы безопасности.", sound_ch = 'sound/effects/weather_warning.ogg')
	playsound(loc, sound_ch, 80, 0)
	visible_message(SPAN_DANGER("[src] издает сигнал. [msg]."))

/obj/structure/machinery/siren/start_processing()
	if(!machine_processing)
		machine_processing = TRUE
		addToListNoDupe(GLOB.power_machines, src)

/obj/structure/machinery/siren/stop_processing()
	if(machine_processing)
		machine_processing = FALSE
		GLOB.processing_machines -= src

/obj/structure/machinery/siren/proc/siren_warning_start(msg, sound_ch = 'sound/effects/weather_warning.ogg')
	if(!msg)
		return
	message = msg
	sound = sound_ch
	start_processing()

/obj/structure/machinery/siren/proc/siren_warning_stop()
	stop_processing()

/obj/structure/machinery/siren/process()
	if(prob(1))
		playsound(loc, sound, 80, 0)
		visible_message(SPAN_DANGER("[src] издает сигнал. [message]."))


/obj/structure/machinery/light/double/almenia
	icon_state = "bptube1"
	base_state = "bptube"
	bulb_colour = COLOR_SOFT_BLUE
	var/current_scraper_link

/obj/structure/machinery/light/double/almenia/Initialize()
	. = ..()
	var/area/current = get_area(src)
	if(istype(current, /area/skyscraper/almenia))
		current_scraper_link = "almea"
	else if(istype(current, /area/skyscraper/ashwin))
		current_scraper_link = "ashwin"
	if(current_scraper_link)
		return INITIALIZE_HINT_LATELOAD

/obj/structure/machinery/light/double/almenia/LateInitialize()
	. = ..()
	var/obj/structure/machinery/computer/security_blocker/blocker = GLOB.skyscrapers_sec_comps[current_scraper_link]["[z]"]
	if(blocker)
		blocker.lights += src

/obj/structure/machinery/light/double/almenia/Destroy()
	var/obj/structure/machinery/computer/security_blocker/blocker = current_scraper_link ? GLOB.skyscrapers_sec_comps[current_scraper_link]["[z]"] : null
	if(blocker)
		blocker.lights -= src

	. = ..()

/obj/structure/machinery/light/double/almenia/proc/change_almenia_state(alert)
	switch(alert)
		if(0)
			base_state = "bptube"
			bulb_colour = COLOR_SOFT_BLUE
			stop_processing()
		if(1)
			base_state = "ptube"
			bulb_colour = COLOR_SOFT_RED
			start_processing()
	update()
	update_icon()

/obj/structure/machinery/light/double/almenia/process()
	if(prob(25) && status == LIGHT_OK)
		flik_light()


/obj/structure/machinery/door/poddoor/shutters/almayer/containment/skyscraper
	name = "Floor Lockdown"
	desc = "Safety shutters to prevent on lockdown any movements"
	var/lock_type = "stairs"
	density = FALSE
	xeno_overridable = FALSE
	var/current_scraper_link

/obj/structure/machinery/door/poddoor/shutters/almayer/containment/skyscraper/Initialize()
	. = ..()
	var/area/current = get_area(src)
	if(istype(current, /area/skyscraper/almenia))
		current_scraper_link = "almea"
	else if(istype(current, /area/skyscraper/ashwin))
		current_scraper_link = "ashwin"
	if(current_scraper_link)
		return INITIALIZE_HINT_LATELOAD

/obj/structure/machinery/door/poddoor/shutters/almayer/containment/skyscraper/LateInitialize()
	. = ..()
	var/obj/structure/machinery/computer/security_blocker/blocker = GLOB.skyscrapers_sec_comps[current_scraper_link]["[z]"]
	if(!blocker)
		return
	if(lock_type == "stairs")
		blocker.stairs_doors += src
	else if(lock_type == "elevator")
		blocker.elevator_doors += src
	else if(lock_type == "move_lock")
		blocker.move_lock_doors += src

/obj/structure/machinery/door/poddoor/shutters/almayer/containment/skyscraper/Destroy()
	var/obj/structure/machinery/computer/security_blocker/blocker = current_scraper_link ? GLOB.skyscrapers_sec_comps[current_scraper_link]["[z]"] : null
	if(blocker)
		if(lock_type == "stairs")
			blocker.stairs_doors -= src
		else if(lock_type == "elevator")
			blocker.elevator_doors -= src
		else if(lock_type == "move_lock")
			blocker.move_lock_doors -= src

	. = ..()

/turf/open/shuttle/elevator/skyscraper
	icon = 'icons/turf/skyscraper_elevator.dmi'
	icon_state = "floor_w"

/turf/open/shuttle/elevator/skyscraper/grating
	icon_state = "floor_grating_w"

/turf/open/shuttle/elevator/skyscraper/wv
	icon_state = "floor_w_v"

/turf/open/shuttle/elevator/skyscraper/wg
	icon_state = "floor_w_g"

/turf/open/auto_turf/sand_white/layer0/skyscraper
	name = "Distant Planet Cover"
	desc = "Далекая поверхность планеты покрытая ядовитым туманом, кажется тут очень высоко, лучше стоять подальше от обрыва"

/turf/closed/shuttle/elevator/scraper
	icon = 'icons/turf/skyscraper_elevator.dmi'
	icon_state = "wall_w"

/turf/closed/shuttle/elevator/scraper/north
	dir = NORTH

/turf/closed/shuttle/elevator/scraper/east
	dir = EAST

/turf/closed/shuttle/elevator/scraper/west
	dir = WEST

/turf/closed/shuttle/elevator/window
	icon = 'icons/turf/skyscraper_elevator.dmi'
	icon_state = "wall_window_w"
	opacity = FALSE

/turf/closed/shuttle/elevator/window/a_closing
	icon_state = "wall_windowa_w"

/turf/closed/shuttle/elevator/window/a_closing/one
	dir = 1

/turf/closed/shuttle/elevator/window/north
	dir = NORTH

/turf/closed/shuttle/elevator/window/east
	dir = EAST

/turf/closed/shuttle/elevator/window/west
	dir = WEST

/turf/closed/shuttle/elevator/window/northeast
	dir = NORTHEAST

/turf/closed/shuttle/elevator/window/southeast
	dir = SOUTHEAST

/turf/closed/shuttle/elevator/window/northwest
	dir = NORTHWEST

/turf/closed/shuttle/elevator/window/southwest
	dir = SOUTHWEST

/turf/closed/shuttle/elevator/gears/sci
	icon = 'icons/turf/skyscraper_elevator.dmi'
	icon_state = "wall_w_gear"

/turf/closed/shuttle/elevator/gears/sci/west
	dir = WEST

/obj/structure/machinery/gear/sky_scraper
	icon = 'icons/turf/skyscraper_elevator.dmi'
	icon_state = "w_gear"

/obj/structure/machinery/gear/sky_scraper/start_moving(direction = NORTH)
	icon_state = "w_gear_animated"
	setDir(direction)

/obj/structure/machinery/gear/sky_scraper/connect_to_shuttle(mapload, obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	. = ..()
	if(istype(port, /obj/docking_port/mobile/sselevator))
		var/obj/docking_port/mobile/sselevator/elevator_port = port
		elevator_port.gears += src

/area/shuttle/sky_scraper_elevator
	name = "'S95 v2' Elevator"
	ambience_exterior = 'sound/ambience/elevator_music.ogg'
	lightswitch = TRUE
	unlimited_power = TRUE

/obj/structure/machinery/computer/shuttle/dropship/flight/lz1/sky_scraper/linked_lz()
	var/obj/docking_port/mobile/sselevator/elevator = SSshuttle.scraper_elevators["sky_scraper_elevator_one"]
	if(!elevator)
		return
	elevator.handle_initial_data(null, TRUE)

/obj/structure/machinery/computer/shuttle/dropship/flight/lz2/sky_scraper/linked_lz()
	var/obj/docking_port/mobile/sselevator/elevator = SSshuttle.scraper_elevators["sky_scraper_elevator_two"]
	if(!elevator)
		return
	elevator.handle_initial_data(null, TRUE)
