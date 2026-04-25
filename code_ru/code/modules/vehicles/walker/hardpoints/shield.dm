/obj/item/hardpoint/walker/spinal/shield
	name = "F35 Resonation Projecting System"
	desc = "This modification grants you unvulnereability, as long as you have unlimited source of energy."

	weight = 2.5

	var/damage_capacity = 300
	var/max_damage_capacity = 300
	var/capacity_recover_rate = 2
	var/shield_color = "#527eec"

	var/last_coldown_time = 0
	var/cooldown_timer_id = null
	var/delay_between_hits = 30 SECONDS

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
		data["max_value"] = last_coldown_time / 10

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

	if(cooldown_timer_id)
		return

	var/damage_to_recover = min(capacity_recover_rate * delta_time, max_damage_capacity - damage_capacity)
	if(!vessel.can_consume_energy(damage_to_recover * 2))
		return
	vessel.consume_energy(damage_to_recover * 2)

	damage_capacity = min(damage_capacity + damage_to_recover * vessel.misc_multipliers["reactor_buff"], max_damage_capacity)
	update_filter()

/obj/item/hardpoint/walker/spinal/shield/proc/take_hits(list/damages_applied)
	if(!damage_capacity)
		return FALSE

	stop_recovering(delay_between_hits)
	var/obj/vehicle/walker/vessel = owner
	if(!vessel.can_consume_energy(damages_applied[2]))
		return FALSE

	vessel.consume_energy(damages_applied[2])
	damage_capacity -= damages_applied[2]
	if(damage_capacity <= 0)
		damage_capacity = 0
		vessel.remove_filter("spinal_shield")
		stop_recovering(delay_between_hits * 4)

		vessel.visible_message(SPAN_WARNING("Arc of sparks coming out from [src] installed on [vessel]. Seems it got disabled for sufficient time!"))
		if(vessel.seats[VEHICLE_DRIVER])
			to_chat(vessel.seats[VEHICLE_DRIVER], SPAN_DANGER("SHIELD DISABLED, main system frame overloded. Rebooting, ETA: [last_coldown_time / 10] seconds"))
	else
		update_filter()
		vessel.visible_message(SPAN_WARNING("Arc of sparks coming out from aura around [vessel], seems like reflecting an attack."))
	return TRUE

/obj/item/hardpoint/walker/spinal/shield/proc/resume_recovering()
	if(!owner)
		return
	cooldown_timer_id = null
	var/obj/vehicle/walker/vessel = owner
	vessel.consume_energy(capacity_recover_rate * 4)

/obj/item/hardpoint/walker/spinal/shield/proc/stop_recovering(time_to_resume)
	last_coldown_time = time_to_resume
	cooldown_timer_id = addtimer(CALLBACK(src, PROC_REF(resume_recovering)), time_to_resume, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_NO_HASH_WAIT|TIMER_DELETE_ME|TIMER_STOPPABLE)

/obj/item/hardpoint/walker/spinal/shield/proc/update_filter()
	owner.add_filter("spinal_shield", 1, list("type" = "outline", "color" = shield_color, "size" = damage_capacity / max_damage_capacity * 2))
