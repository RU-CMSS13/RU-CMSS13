/obj/item/hardpoint/walker/reactor
	name = "Shielded Mecha Reactor"
	desc = "Self sufficient reactor for power supply of basic mecha equipment, not recommended to be used in pair with laser or heavy on energy demand equipment."

	slot = WALKER_HARDPOIN_INTERNAL
	hdpt_layer = HDPT_LAYER_SUPPORT

	damage_multiplier = 0.1
	material_per_repair = 10

	weight = 2

	custom_actions = list("Reactor")

	var/turned_on = TRUE
	var/rebooting = FALSE
	var/count_down = FALSE

	var/reboot_time = 2 MINUTES
	var/meltdown_time = 1 MINUTES
	var/meltdown_timer_id = null

	var/reactor_state = VEHICLE_REACTOR_FINE
	var/chance_of_malf = 10

	var/list/reactor_sounds = list('code_ru/sound/effects/switch.ogg', 'code_ru/sound/effects/switch2.ogg', 'code_ru/sound/effects/switch3.ogg')
	var/obj/item/fuel_cell/walker_reactor/fuel

/obj/item/hardpoint/walker/reactor/Initialize()
	. = ..()

	fuel = new(src)

/obj/item/hardpoint/walker/reactor/Destroy()
	QDEL_NULL(fuel)

	. = ..()

/obj/item/hardpoint/walker/reactor/material_use(obj/item/tool/weldingtool/welder, mob/user, modificator = 4)
	if(reactor_state)
		modificator *= reactor_state / 2

	. = ..(welder, user, modificator)

/obj/item/hardpoint/walker/reactor/tgui_additional_data()
	. = ..()

	var/list/data
	if(fuel)
		data = list()
		.["hardpoint_data_additional"] += list(data)
		data["value_name"] = "Fuel"
		data["current_value"] = fuel.fuel_amount
		data["max_value"] = fuel.max_fuel_amount

	if(meltdown_timer_id)
		data = list()
		.["hardpoint_data_additional"] += list(data)
		data["value_name"] = "Meltdown"
		data["current_value"] = timeleft(meltdown_timer_id) / 10
		data["max_value"] = meltdown_time / 10

/obj/item/hardpoint/walker/reactor/take_damage_type(list/damages_applied, type, atom/attacker, damage_to_apply, real_damage)
	var/health_cache = health

	. = ..()

	if(!prob(health_cache - health / (chance_of_malf / 5)))
		return

	if(reactor_state == VEHICLE_REACTOR_CRITICAL)
		if(owner)
			short_circuit_reactor()
		return

	reactor_state++
	if(reactor_state != VEHICLE_REACTOR_CRITICAL)
		if(owner)
			owner.visible_message(SPAN_HIGHDANGER("[owner] burst with steam and smoke. That not good, need to look after [src]."))
		return

	if(owner)
		owner.visible_message(SPAN_HIGHDANGER("[owner] burst with steam and fire. That not good, seems like something VERY wrong with [src], it going critical."))
	count_down = TRUE
	meltdown_timer_id = addtimer(CALLBACK(src, PROC_REF(meltdown)), meltdown_time, TIMER_STOPPABLE|TIMER_UNIQUE|TIMER_DELETE_ME)

/obj/item/hardpoint/walker/reactor/proc/meltdown()
	var/datum/cause_data/cause = create_cause_data("Reactor meltdown")
	cell_explosion(get_turf(src), 1000, 300, EXPLOSION_FALLOFF_SHAPE_LINEAR, null, cause)

/obj/item/hardpoint/walker/reactor/repaired()
	deltimer(meltdown_timer_id)
	meltdown_timer_id = null
	reactor_state = VEHICLE_REACTOR_FINE

/obj/item/hardpoint/walker/reactor/custom_action(mob/user, custom_action)
	if(rebooting)
		to_chat(user, SPAN_DANGER("Reactor already rebooting!"))
		return

	if(tgui_alert(user, "Are you sure about turning it [turned_on ? "Off" : "On"]?", "Reactor Control", list("Yes", "No")) == "No")
		return

	if(turned_on)
		if(count_down)
			count_down = FALSE
			owner.visible_message(SPAN_WARNING("[owner] burst with steam as [src] turns off."))
		if(owner.light_state)
			owner.switch_light_state(FALSE, TRUE)
		to_chat(user, SPAN_DANGER("Reactor turned off, it might take up to [reboot_time / 10] seconds for reboot!"))
		playsound(get_turf(src), pick(reactor_sounds), 25, 1)
		turned_on = FALSE
		return

	if(reactor_state == VEHICLE_REACTOR_CRITICAL)
		to_chat(user, SPAN_DANGER("It was for sure bad idea to turn on [src] in this state."))
		return

	reboot_reactor(reboot_time)

	playsound(get_turf(src), pick(reactor_sounds), 25, 1)
	to_chat(user, SPAN_WARNING("Booting up reactor, it might take you to [reboot_time / 10] seconds."))

/obj/item/hardpoint/walker/reactor/proc/reboot_reactor(time_for_reboot)
	rebooting = TRUE
	addtimer(VARSET_CALLBACK(src, turned_on, TRUE), time_for_reboot, TIMER_OVERRIDE|TIMER_UNIQUE|TIMER_DELETE_ME)
	addtimer(VARSET_CALLBACK(src, rebooting, FALSE), time_for_reboot, TIMER_OVERRIDE|TIMER_UNIQUE|TIMER_DELETE_ME)

/obj/item/hardpoint/walker/reactor/proc/replace_fuel(obj/new_fuel, mob/user)
	if(user.skills.get_skill_level(SKILL_POWERLOADER) < SKILL_POWERLOADER_MASTER)
		to_chat(user, "You dont know how to operate it.")
		return

	if(!do_after(user, 10 SECONDS, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_GENERIC, owner, INTERRUPT_MOVED))
		return FALSE

	playsound(get_turf(src), pick(reactor_sounds), 25, 1)
	if(fuel)
		fuel.forceMove(get_turf(src))
	user.drop_inv_item_to_loc(new_fuel, src)
	fuel = new_fuel
	return TRUE

/obj/item/hardpoint/walker/reactor/proc/on_consume_enegry()
	if(!reactor_state)
		return

	switch(reactor_state)
		if(VEHICLE_REACTOR_DAMAGE)
			if(rand(1, 1000) < chance_of_malf / 10)
				short_circuit_reactor()
		if(VEHICLE_REACTOR_CRITICAL)
			if(rand(1, 1000) < chance_of_malf)
				short_circuit_reactor()

/obj/item/hardpoint/walker/reactor/proc/short_circuit_reactor()
	turned_on = FALSE
	var/time_till_reboot = rand(5, 10)
	reboot_reactor(time_till_reboot)

	owner.visible_message(SPAN_WARNING("[src] burst in smoke! [owner] turns off due to short circuit."))
	if(owner.seats[VEHICLE_DRIVER])
		to_chat(owner.seats[VEHICLE_DRIVER], SPAN_DANGER("Reactor core unstable, required [reactor_state == VEHICLE_REACTOR_CRITICAL ? "URGENT " : ""]repair. Network reboot in [time_till_reboot / 10] seconds!"))


/obj/item/hardpoint/walker/reactor/enhanced
	name = "Enhanced Mecha Reactor"
	desc = "Self sufficient reactor for power supply of mecha equipment."

	weight = 1
