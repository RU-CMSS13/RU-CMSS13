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


/obj/item/hardpoint/walker/spinal/artilery
	name = "Detection Array \"Night Hawk\""
	desc = "Grant precision vision over entire battle field via special equipment of this hardpoint, additionaly grants very powerful motion detector at cost of faster reactor consumption."

	custom_actions = list("Zoom", "Motion Detector")

	zoom_size = 12

/obj/item/hardpoint/walker/spinal/artilery/Initialize()
	. = ..()

	motion_detector = new(src)
	motion_detector.hardpoint_holder = src

/obj/item/hardpoint/walker/spinal/artilery/pilot_entered(mob/user)
	motion_detector.iff_signal = user.faction

/obj/item/hardpoint/walker/spinal/artilery/pilot_ejected(mob/user)
	return

/obj/item/hardpoint/walker/spinal/artilery/custom_action(mob/user, custom_action)
	var/obj/vehicle/walker/vessel = owner
	if(custom_action == "Motion Detector")
		if(!vessel.can_consume_energy(motion_detector.detector_range))
			return
		motion_detector.toggle_active(user, motion_detector.active)
		return

	var/consumption = ceil(zoom_size * 0.5)
	if(!vessel.can_consume_energy(consumption))
		return
	zoom = !zoom
	vessel.update_zoom_pixels(TRUE)

/obj/item/device/motiondetector/walker
	detector_range = 24

	var/obj/item/hardpoint/walker/spinal/artilery/hardpoint_holder

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
	name = "M2558 Tactical Rocket Launcher \"Anti Tsiganskij Khutor\""
	desc = "\"Special Package Deliver System\" includes a pair of heavy optics with laser guidance system, and bunker buster rockets. Developen in 2123 for assistance in destructing illigal establishments."

	weight = 1.5

	zoom_size = 10

/obj/item/hardpoint/walker/spinal/tactical_missile/Initialize()
	. = ..()

	mounted_gun = new /obj/item/weapon/gun/launcher/rocket/mounted/mecha_tactical_missile(src)
	insert_gun()

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


/obj/item/hardpoint/walker/spinal/shield
	name = "F35 Resonation Projecting System"
	desc = "This modification grants you unvulnereability, as long as you have unlimited source of energy."

	weight = 2.5

	var/damage_capacity = 400
	var/max_damage_capacity = 400
	var/capacity_recover_rate = 5
	var/shield_color = "#527eec"

	var/cooldown_timer_id = null
	var/delay_between_hits = 10 SECONDS

/obj/item/hardpoint/walker/spinal/shield/deactivate(obj/vehicle/walker/vessel)
	. = ..()

	damage_capacity = 0

/obj/item/hardpoint/walker/spinal/shield/on_install(obj/vehicle/walker/vessel)
	update_filter()

	. = ..()

/obj/item/hardpoint/walker/spinal/shield/on_uninstall(obj/vehicle/walker/vessel)
	vessel.remove_filter("spinal_shield")

	. = ..()

/obj/item/hardpoint/walker/spinal/shield/tgui_additional_data()
	. = ..()

	var/list/data = list()
	.["hardpoint_data_additional"] += list(data)
	data["value_name"] = "Shield"
	data["current_value"] = damage_capacity
	data["max_value"] = max_damage_capacity

	if(cooldown_timer_id)
		data = list()
		.["hardpoint_data_additional"] += list(data)
		data["value_name"] = "Cooldown"
		data["current_value"] = timeleft(cooldown_timer_id) / 10
		data["max_value"] = delay_between_hits * 6 / 10

/obj/item/hardpoint/walker/spinal/shield/on_source_process(delta_time)
	. = ..()
	if(!.)
		return

	var/obj/vehicle/walker/vessel = owner
	if(damage_capacity == max_damage_capacity)
		return

	if(damage_capacity)
		var/energy_required = ceil(damage_capacity / (capacity_recover_rate * 10)) * delta_time
		if(!vessel.can_consume_energy(energy_required))
			damage_capacity = max(damage_capacity - capacity_recover_rate, 0)
			return
		vessel.consume_energy(energy_required)

	if(timeleft(cooldown_timer_id))
		return

	var/damage_to_recover = min(capacity_recover_rate * delta_time, max_damage_capacity - damage_capacity)
	if(!vessel.can_consume_energy(damage_to_recover * 2))
		return
	vessel.consume_energy(damage_to_recover * 2)

	damage_capacity += damage_to_recover * vessel.misc_multipliers["reactor_buff"]
	update_filter()

/obj/item/hardpoint/walker/spinal/shield/proc/take_hits(list/damages_applied)
	stop_recovering(world.time + delay_between_hits)
	if(!damage_capacity)
		return FALSE

	var/obj/vehicle/walker/vessel = owner
	if(!vessel.can_consume_energy(damages_applied[2]))
		return FALSE

	vessel.consume_energy(damages_applied[2])
	damage_capacity -= damages_applied[2]
	if(damage_capacity < 0)
		damage_capacity = 0
		vessel.remove_filter("spinal_shield")
		stop_recovering(world.time + delay_between_hits * 6)

		vessel.visible_message(SPAN_WARNING("Arc of sparks coming out from [src] installed on [vessel]. Seems it got disabled for sufficient time!"))
		if(vessel.seats[VEHICLE_DRIVER])
			to_chat(vessel.seats[VEHICLE_DRIVER], SPAN_DANGER("SHIELD DISABLED, main system frame overloded. Rebooting, ETA: [delay_between_hits / 10] seconds"))
	else
		update_filter()
		vessel.visible_message(SPAN_WARNING("Arc of sparks coming out from aura around [vessel], seems like reflecting an attack."))
	return TRUE

/obj/item/hardpoint/walker/spinal/shield/proc/resume_recovering()
	if(!owner)
		return
	var/obj/vehicle/walker/vessel = owner
	vessel.consume_energy(capacity_recover_rate * 4)

/obj/item/hardpoint/walker/spinal/shield/proc/stop_recovering(time_to_resume)
	cooldown_timer_id = addtimer(CALLBACK(src, PROC_REF(resume_recovering)), time_to_resume, TIMER_OVERRIDE|TIMER_UNIQUE|TIMER_DELETE_ME)

/obj/item/hardpoint/walker/spinal/shield/proc/update_filter()
	owner.add_filter("spinal_shield", 1, list("type" = "outline", "color" = shield_color, "size" = damage_capacity / max_damage_capacity * 2))
