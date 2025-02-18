#define MOBILE_SHUTTLE_MULTIZ_ELEVATOR_ONE "mz_elevator_one"
#define MOBILE_SHUTTLE_MULTIZ_ELEVATOR_TWO "mz_elevator_two"

// -- Docks
/obj/docking_port/stationary/sselevator
	name = "'S95 v2' Elevator Floor"
	id = MOBILE_SHUTTLE_MULTIZ_ELEVATOR_ONE
	width = 7
	height = 7

/obj/docking_port/stationary/sselevator/register()
	id = "[id]_[src.z]"
	. = ..()

/obj/docking_port/stationary/sselevator/load_roundstart()
	. = ..()
	var/obj/docking_port/mobile/sselevator/elevator = get_docked()
	if(elevator)
		elevator.handle_initial_data(src)

/obj/docking_port/stationary/sselevator/one
	id = MOBILE_SHUTTLE_MULTIZ_ELEVATOR_ONE

/obj/docking_port/stationary/sselevator/one/floor_roof
	roundstart_template = /datum/map_template/shuttle/multiz_elevator_one

/obj/docking_port/stationary/sselevator/two
	id = MOBILE_SHUTTLE_MULTIZ_ELEVATOR_TWO

/obj/docking_port/stationary/sselevator/two/floor_roof
	roundstart_template = /datum/map_template/shuttle/multiz_elevator_two

// -- Shuttles

/obj/docking_port/mobile/sselevator
	name = "'S95 v2' elevator"
	width = 7
	height = 7

	landing_sound = null
	ignition_sound = null
	ambience_flight = 'sound/ambience/elevator_music.ogg'
	ambience_idle = 'sound/ambience/elevator_music.ogg'
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)

	custom_ceiling = /turf/open/floor/roof/ship_hull/lab

	var/disabled_elevator = TRUE // Fix of auto mode, when shuttle got in troubles or loading
	var/total_floors = 29 // Number or relative floors we can go
	var/floor_offset = 0 // For relative coordinates in z dimension, aka we only count or current map, where elevator having fun
	var/offseted_z = 0 // Already calculated coordinate, so it's totaly relative z coord, not real one
	var/obj/docking_port/stationary/initial_dock = null // Home of elevator
	var/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator/door
	var/obj/structure/machinery/computer/shuttle/shuttle_control/sselevator/control_button
	var/list/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator/doors = list()
	var/list/obj/structure/machinery/gear/gears = list()
	var/list/obj/structure/machinery/computer/shuttle/shuttle_control/sselevator/buttons = list()
	var/list/called_floors // Relative list of z coords for elevator where ordered
	var/target_floor = 0 // Where currently we heading (final relative z coord)
	var/next_moving = 0// Where we need to head after (final relative z coord)
	var/moving = FALSE // Direction we following right now
	var/cooldown = FALSE // Make sure we don't break shuttles system by multiple moving orders
	var/move_delay = 4 SECONDS
	var/max_move_delay = 8 SECONDS
	var/min_move_delay = 2 SECONDS

/obj/docking_port/mobile/sselevator/one
	id = MOBILE_SHUTTLE_MULTIZ_ELEVATOR_ONE
	total_floors = 3

/obj/docking_port/mobile/sselevator/two
	id = MOBILE_SHUTTLE_MULTIZ_ELEVATOR_TWO
	total_floors = 2

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

/obj/docking_port/mobile/sselevator/request(obj/docking_port/stationary/S) //No transit, no ignition, just a simple up/down platform
	initiate_docking(S, force = TRUE)

/obj/docking_port/mobile/sselevator/afterShuttleMove()
	set background = TRUE

	offseted_z = z - floor_offset
	if(disabled_elevator || cooldown)
		return

	cooldown = TRUE
	if(offseted_z == target_floor)
		moving = FALSE
		if(next_moving)
			target_floor = next_moving
			next_moving = 0
			moving = offseted_z > target_floor ? "DOWN" : "UP"
			INVOKE_ASYNC(src, PROC_REF(move_elevator), TRUE)
		else
			cooldown = FALSE
			// Soft fix, I have no idea, maybe my attempts to fix some mess around caused it, or it has been... but now we don't leave some floors in black list if you for some reason it clicked wrong time.
			var/found = FALSE
			for(var/i = 1 to total_floors)
				if(called_floors[i])
					found = TRUE
					calc_elevator_order(i)
					break
			if(!found)
				on_stop_actions()

	else if(called_floors[offseted_z])
		INVOKE_ASYNC(src, PROC_REF(move_elevator), TRUE)
	else
		INVOKE_ASYNC(src, PROC_REF(move_elevator))

/obj/docking_port/mobile/sselevator/proc/on_move_actions()
	control_button.update_icon("_animated")
	var/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator/blastdoor = doors["[z]"]
	if(blastdoor && !blastdoor.density)
		INVOKE_ASYNC(blastdoor, TYPE_PROC_REF(/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator, close_and_lock))
	if(door && !door.density)
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
	var/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator/blastdoor = doors["[z]"]
	if(blastdoor && blastdoor.density)
		INVOKE_ASYNC(blastdoor, TYPE_PROC_REF(/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator, unlock_and_open))
	if(door && door.density)
		INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator, unlock_and_open))
	for(var/obj/structure/machinery/gear/gear as anything in gears)
		gear.stop_moving()

/obj/docking_port/mobile/sselevator/proc/move_elevator(stopped = FALSE)
	if(stopped)
		on_stop_actions()
		sleep(max_move_delay)
		control_button.visible_message(SPAN_NOTICE("Lift starting moving. Please stay away from doors."))

	var/floor_to_move = offseted_z > target_floor ? offseted_z - 1 : offseted_z + 1
	calculate_move_delay(floor_to_move)
	sleep(move_delay)
	on_move_actions()
	sleep(move_delay)
	cooldown = FALSE
	SSshuttle.moveShuttleToDock(src, SSshuttle.getDock("[id]_[floor_to_move + floor_offset]"), 0)

/obj/docking_port/mobile/sselevator/proc/calculate_move_delay(floor_calc)
	if(offseted_z > target_floor ? offseted_z - floor_calc > 4 : floor_calc - offseted_z > 4)
		move_delay -= 2
	else
		move_delay += 2
	move_delay = clamp(move_delay, min_move_delay, max_move_delay)

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
		cooldown = TRUE
		control_button.visible_message(SPAN_NOTICE("Lift starting moving. Please stay away from doors."))
		INVOKE_ASYNC(src, PROC_REF(move_elevator))

// Reseting elevator if something messed up, because this system is not hard coded, so we can fuck up it easy
/obj/docking_port/mobile/sselevator/proc/handle_initial_data(obj/docking_port/stationary/target_dock, force_opened = FALSE)
	disabled_elevator = TRUE
	moving = TRUE
	cooldown = TRUE
	if(target_dock)
		initial_dock = target_dock

		if(initial_dock != get_docked())
			var/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator/blastdoor = doors["[z]"]
			if(blastdoor && !blastdoor.density)
				INVOKE_ASYNC(blastdoor, TYPE_PROC_REF(/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator, close_and_lock))
			if(door && !door.density)
				INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator, close_and_lock))
			SSshuttle.moveShuttleToDock(src, initial_dock, 0)

	floor_offset = z - total_floors
	offseted_z = z - floor_offset
	target_floor = offseted_z
	next_moving = 0

	called_floors = list()
	called_floors.len = total_floors
	for(var/i = 1 to total_floors)
		called_floors[i] = FALSE

	move_delay = initial(move_delay)
	max_move_delay = initial(max_move_delay)
	min_move_delay = initial(min_move_delay)

	var/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator/blastdoor = doors["[z]"]
	if(blastdoor && blastdoor.density)
		INVOKE_ASYNC(blastdoor, TYPE_PROC_REF(/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator, unlock_and_open))
	if(door && door.density)
		INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator, unlock_and_open))

	disabled_elevator = FALSE
	moving = FALSE
	cooldown = FALSE

//Console

/obj/structure/machinery/computer/shuttle/shuttle_control/sselevator
	name = "'S95 v2' elevator console"
	desc = "Controls for the 'S95 v2' elevator."
	icon = 'icons/obj/structures/machinery/computer.dmi'
	icon_state = "elevator_screen"

	var/elevator_id
	var/floor = "control"

/obj/structure/machinery/computer/shuttle/shuttle_control/sselevator/Initialize(mapload, ...)
	. = ..()
	#if !defined(UNIT_TESTS)
	if(floor != "control")
		return INITIALIZE_HINT_ROUNDSTART
	#endif

/obj/structure/machinery/computer/shuttle/shuttle_control/sselevator/LateInitialize()
	var/obj/docking_port/mobile/sselevator/elevator = SSshuttle.getShuttle(elevator_id)
	if(!elevator)
		return

	floor = z
	elevator.buttons["[floor]"] = src

/obj/structure/machinery/computer/shuttle/shuttle_control/sselevator/Destroy()
	var/obj/docking_port/mobile/sselevator/elevator = SSshuttle.getShuttle(elevator_id)
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
	var/obj/docking_port/mobile/sselevator/elevator = SSshuttle.getShuttle(elevator_id)
	. = list("buttons" = list(), "current_floor" = elevator.offseted_z)
	if(!elevator)
		return
	for(var/i = 1 to elevator.total_floors)
		.["buttons"] += list(list(
			id = i, title = "Floor [i]", called = elevator.called_floors[i],
		))

/obj/structure/machinery/computer/shuttle/shuttle_control/sselevator/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	if(action == "click")
		var/target_floor = params["id"]
		var/obj/docking_port/mobile/sselevator/elevator = SSshuttle.getShuttle(elevator_id)
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

/obj/structure/machinery/computer/shuttle/shuttle_control/sselevator/one
	elevator_id = MOBILE_SHUTTLE_MULTIZ_ELEVATOR_ONE

/obj/structure/machinery/computer/shuttle/shuttle_control/sselevator/two
	elevator_id = MOBILE_SHUTTLE_MULTIZ_ELEVATOR_TWO


/obj/structure/machinery/computer/shuttle/shuttle_control/sselevator/button
	desc = "The remote controls for the 'S95 v2' elevator."
	floor = null

/obj/structure/machinery/computer/shuttle/shuttle_control/sselevator/button/attack_hand(mob/user)
	var/obj/docking_port/mobile/sselevator/elevator = SSshuttle.getShuttle(elevator_id)
	if(!allowed(user) || !elevator)
		to_chat(user, SPAN_WARNING("Acces denied!"))
		return
	if(elevator.z == floor)
		return
	if(elevator.called_floors[floor - elevator.floor_offset])
		visible_message(SPAN_NOTICE("Лифт уже едет на этот этаж, ожидайте."))
		return
	call_elevator(user, elevator)

/obj/structure/machinery/computer/shuttle/shuttle_control/sselevator/button/proc/call_elevator(mob/user, obj/docking_port/mobile/sselevator/elevator)
	playsound(src, 'sound/machines/click.ogg', 15, 1)
	visible_message(SPAN_NOTICE("Лифт вызван, ожидайте."))
	elevator.calc_elevator_order(floor - elevator.floor_offset)


/obj/structure/machinery/computer/shuttle/shuttle_control/sselevator/button/one
	elevator_id = MOBILE_SHUTTLE_MULTIZ_ELEVATOR_ONE

/obj/structure/machinery/computer/shuttle/shuttle_control/sselevator/button/two
	elevator_id = MOBILE_SHUTTLE_MULTIZ_ELEVATOR_TWO


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

	var/elevator_id
	var/floor

/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator/Initialize(mapload, ...)
	. = ..()
	#if !defined(UNIT_TESTS)
	if(floor != "control")
		return INITIALIZE_HINT_ROUNDSTART
	#endif

/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator/LateInitialize()
	var/obj/docking_port/mobile/sselevator/elevator = SSshuttle.getShuttle(elevator_id)
	if(!elevator)
		return

	floor = z
	elevator.doors["[floor]"] = src

/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator/Destroy()
	var/obj/docking_port/mobile/sselevator/elevator = SSshuttle.getShuttle(elevator_id)
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

/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator/one
	elevator_id = MOBILE_SHUTTLE_MULTIZ_ELEVATOR_ONE

/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator/one/control
	floor = "control"

/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator/two
	elevator_id = MOBILE_SHUTTLE_MULTIZ_ELEVATOR_TWO

/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/blastdoor/elevator/two/control
	floor = "control"


/datum/map_template/shuttle/multiz_elevator_one
	shuttle_id = MOBILE_SHUTTLE_MULTIZ_ELEVATOR_ONE
	name = "S95 v2 Elevator One"
	width = 7
	height = 7

/datum/map_template/shuttle/multiz_elevator_two
	shuttle_id = MOBILE_SHUTTLE_MULTIZ_ELEVATOR_TWO
	name = "S95 v2 Elevator Two"
	width = 7
	height = 7


/turf/open/shuttle/elevator/multiz
	icon = 'icons/turf/multiz_elevator.dmi'
	icon_state = "floor_w"

/turf/open/shuttle/elevator/multiz/grating
	icon_state = "floor_grating_w"

/turf/open/shuttle/elevator/multiz/wv
	icon_state = "floor_w_v"

/turf/open/shuttle/elevator/multiz/wg
	icon_state = "floor_w_g"

/turf/closed/shuttle/elevator/multiz
	icon = 'icons/turf/multiz_elevator.dmi'
	icon_state = "wall_w"

/turf/closed/shuttle/elevator/multiz/north
	dir = NORTH

/turf/closed/shuttle/elevator/multiz/east
	dir = EAST

/turf/closed/shuttle/elevator/multiz/west
	dir = WEST

/turf/closed/shuttle/elevator/window
	icon = 'icons/turf/multiz_elevator.dmi'
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
	icon = 'icons/turf/multiz_elevator.dmi'
	icon_state = "wall_w_gear"

/turf/closed/shuttle/elevator/gears/sci/west
	dir = WEST

/obj/structure/machinery/gear/elevator
	icon = 'icons/turf/multiz_elevator.dmi'
	icon_state = "w_gear"

/obj/structure/machinery/gear/elevator/start_moving()
	icon_state = "w_gear_animated"

/obj/structure/machinery/gear/elevator/stop_moving()
	icon_state = "w_gear"

/obj/structure/machinery/gear/elevator/connect_to_shuttle(mapload, obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	. = ..()
	if(istype(port, /obj/docking_port/mobile/sselevator))
		var/obj/docking_port/mobile/sselevator/elevator_port = port
		elevator_port.gears += src

/area/shuttle/multiz_elevator
	name = "'S95 v2' Elevator"
	ambience_exterior = 'sound/ambience/elevator_music.ogg'
	lightswitch = TRUE
	unlimited_power = TRUE
