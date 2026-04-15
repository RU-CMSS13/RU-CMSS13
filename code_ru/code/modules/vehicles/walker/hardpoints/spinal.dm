/obj/item/hardpoint/walker/spinal
	name = "Mecha Back Hardpoint"
	desc = "Allows special abilities."

	icon = 'code_ru/icons/obj/vehicles/mech_back.dmi'

	slot = WALKER_HARDPOIN_SPINAL
	hdpt_layer = HDPT_LAYER_SUPPORT

	weight = 1

/obj/item/hardpoint/walker/spinal/powerful_cooling
	name = "Active Cooling Circuit"
	desc = "This very powerful cooling can take twice as much heat out of system! Allows do actions much faster, however consume a lot of energy."

	var/consume_rate = 10

/obj/item/hardpoint/walker/spinal/powerful_cooling/on_source_process(delta_time)
	. = ..()
	if(!.)
		return

	var/obj/vehicle/walker/vessel = owner
	var/energy_required = consume_rate * delta_time
	if(!vessel.can_consume_energy(energy_required))
		remove_buff(vessel)
		return
	apply_buff(vessel)
	vessel.consume_energy(energy_required)

/obj/item/hardpoint/walker/spinal/powerful_cooling/apply_buff(obj/vehicle/walker/vessel)
	if(!health)
		return
	if(buff_applied)
		return

	vessel.misc_multipliers["scatter"] -= 0.6
	vessel.misc_multipliers["fire_delay"] -= 0.4
	buff_applied = TRUE
	SEND_SIGNAL(vessel, COMSIG_GUN_RECALCULATE_ATTACHMENT_BONUSES)

/obj/item/hardpoint/walker/spinal/powerful_cooling/remove_buff(obj/vehicle/walker/vessel)
	if(!buff_applied)
		return

	vessel.misc_multipliers["scatter"] += 0.6
	vessel.misc_multipliers["fire_delay"] += 0.4
	buff_applied = FALSE
	SEND_SIGNAL(vessel, COMSIG_GUN_RECALCULATE_ATTACHMENT_BONUSES)


/obj/item/hardpoint/walker/spinal/artillery
	name = "Detection Array \"Night Hawk\""
	desc = "Grant precision vision over entire battle field via special equipment of this hardpoint, additionaly grants very powerful motion detector at cost of faster reactor consumption."

	verbs_list = list(/obj/vehicle/walker/proc/art_zoom, /obj/vehicle/walker/proc/motion_detector)
	actions_list = list(/datum/action/walker/art_zoom, /datum/action/walker/motion_detector)

	zoom_size = 12

/obj/item/hardpoint/walker/spinal/artillery/Initialize()
	. = ..()

	motion_detector = new(src)
	motion_detector.hardpoint_holder = src

/obj/item/hardpoint/walker/spinal/artillery/pilot_entered(mob/user)
	. = ..()

	motion_detector.iff_signal = user.faction

/obj/item/device/motiondetector/walker
	detector_range = 24

	var/obj/item/hardpoint/walker/spinal/artillery/hardpoint_holder

/obj/item/device/motiondetector/walker/get_user()
	return hardpoint_holder?.owner?.seats[VEHICLE_DRIVER]

/obj/item/device/motiondetector/walker/scan()
	if(!hardpoint_holder?.owner)
		turn_off(null, TRUE)
		return FALSE

	var/obj/vehicle/walker/vessel = hardpoint_holder.owner
	if(!vessel.can_consume_energy(detector_range))
		turn_off(null, TRUE)
		return FALSE

	vessel.consume_energy(detector_range)
	. = ..()


/obj/item/hardpoint/walker/spinal/tactical_missile
	name = "M2558 \"Anti Tsiganskij Khutor\" Tactical Rocket Launcher"
	desc = "\"Special Package Deliver System\" includes a pair of heavy optics with laser guidance system, and bunker buster rockets. Developen in 2123 for assistance in destructing illigal establishments."

	weight = 1.5

	zoom_size = 10

/obj/item/hardpoint/walker/spinal/tactical_missile/Initialize()
	. = ..()

	insert_gun(new /obj/item/weapon/gun/launcher/rocket/mounted/mecha_tactical_missile)

/obj/item/hardpoint/walker/spinal/tactical_missile/tgui_additional_data()
	. = ..()

	if(!mounted_gun?.current_mag)
		return

	var/list/data = list()
	.["hardpoint_data_additional"] += list(data)
	data["value_name"] = "Rocket"
	data["current_value"] = mounted_gun.current_mag.current_rounds
	data["max_value"] = mounted_gun.current_mag.max_rounds

/obj/item/hardpoint/walker/spinal/tactical_missile/check_modifiers(modifiers, button = FALSE)
	if(!modifiers[MIDDLE_CLICK])
		return FALSE

	if(button && (modifiers[BUTTON] != MIDDLE_CLICK))
		return FALSE
	return TRUE

/obj/item/hardpoint/walker/spinal/tactical_missile/try_remove(obj/item/attacking_item, mob/user)
	return FALSE
