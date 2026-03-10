//README: Be aware, what add_verb from vehicle makes src be client, so ensure src is mech and user is mech-operator,if you're making new verbs
/* To be fair, just put this code like at examples you have, also remove comments
	var/mob/user = usr// Internal byond shit
	if(!istype(user))// HUH? Not supposed to happen, however in this case, better to have this way
		return
	src = user.interactee// In mecha up to date of this comment we use set interactee, so here we can find ref to our mecha
	if(!istype(src, /obj/vehicle/walker))// There we make sure our chocolate fabric is MECH
		return
	if(seats[VEHICLE_DRIVER] != user)// Here we check if for real mech pilot called it
		return
AND YOULL BE FINE!*/

/obj/vehicle/walker/proc/exit_walker()
	set name = "Eject"
	set category = "Vehicle"

	var/mob/user = usr
	if(!istype(user))
		return
	src = user.interactee
	if(!istype(src, /obj/vehicle/walker))
		return
	if(seats[VEHICLE_DRIVER] != user)
		return

	user.unset_interaction()


//////////////////////////////////////////////////////////////


/obj/vehicle/walker/proc/toggle_lights()
	set name = "Lights On/Off"
	set category = "Vehicle"

	var/mob/user = usr
	if(!istype(user))
		return
	src = user.interactee
	if(!istype(src, /obj/vehicle/walker))
		return
	if(seats[VEHICLE_DRIVER] != user)
		return

	switch_light_state(!light_state)

/obj/vehicle/walker/switch_light_state(new_state, override)
	if(!can_consume_energy(4) && !override)
		return

	. = ..()


//////////////////////////////////////////////////////////////


/obj/vehicle/walker/proc/eject_magazine()
	set name = "Eject Magazine"
	set category = "Vehicle"

	var/mob/user = usr
	if(!istype(user))
		return
	src = user.interactee
	if(!istype(src, /obj/vehicle/walker))
		return
	if(seats[VEHICLE_DRIVER] != user)
		return

	var/list/acceptible_modules = list()
	for(var/obj/item/hardpoint/walker/selected in hardpoints)
		if(!selected.mounted_gun?.current_mag)
			continue
		acceptible_modules[selected.mounted_gun.name] = selected.mounted_gun
	if(!length(acceptible_modules))
		return

	var/selected_module = tgui_input_list(user, "Select a gun to eject magazine.", "Eject Magazine", acceptible_modules)
	if(!selected_module)
		return
	var/obj/item/weapon/gun/mounted_gun = acceptible_modules[selected_module]
	if(!mounted_gun || !mounted_gun.current_mag)
		return FALSE
	mounted_gun.unload(user, TRUE)
	to_chat(user, SPAN_WARNING("WARNING! [mounted_gun] ammo magazine deployed."))
	visible_message("[src]'s system ejected used magazine.","")


//////////////////////////////////////////////////////////////


/obj/vehicle/walker/proc/get_stats()
	set name = "Status Display"
	set category = "Vehicle"

	var/mob/user = usr
	if(!istype(user))
		return
	src = user.interactee
	if(!istype(src, /obj/vehicle/walker))
		return
	if(seats[VEHICLE_DRIVER] != user)
		return

	tgui_interact(user)


/obj/vehicle/walker/proc/toggle_zoom()
	set name = "Zoom On/Off"
	set category = "Vehicle"

	var/mob/user = usr
	if(!istype(user))
		return
	src = user.interactee
	if(!istype(src, /obj/vehicle/walker))
		return
	if(seats[VEHICLE_DRIVER] != user)
		return

	if(selected_group == SELECTED_GROUP_SPINAL || !can_consume_energy(2))
		return
	zoom = !zoom
	update_pixels(zoom)


//////////////////////////////////////////////////////////////


/obj/vehicle/walker/proc/toggle_motion_detector()
	set name = "Motion Detector On/Off"
	set category = "Vehicle"

	var/mob/user = usr
	if(!istype(user))
		return
	src = user.interactee
	if(!istype(src, /obj/vehicle/walker))
		return
	if(seats[VEHICLE_DRIVER] != user)
		return

	var/obj/item/hardpoint/walker/spinal/artilery/provider = hardpoints_by_slot[WALKER_HARDPOIN_SPINAL]
	if(!istype(provider))
		return
	provider.motion_detector.toggle_active(user, provider.motion_detector.active)


//////////////////////////////////////////////////////////////


/obj/vehicle/walker/proc/toggle_reactor()
	set name = "Reactor On/Off"
	set category = "Vehicle"

	var/mob/user = usr
	if(!istype(user))
		return
	src = user.interactee
	if(!istype(src, /obj/vehicle/walker))
		return
	if(seats[VEHICLE_DRIVER] != user)
		return

	var/obj/item/hardpoint/walker/reactor/energy_source = hardpoints_by_slot[WALKER_HARDPOIN_INTERNAL]
	if(!energy_source)
		return
	if(energy_source.rebooting)
		to_chat(user, SPAN_DANGER("Reactor already rebooting!"))
		return
	if(tgui_alert(user, "Are you sure about turning it [energy_source.turned_on ? "Off" : "On"]?", "Reactor Control", list("Yes", "No")) == "No")
		return
	energy_source.switch_reactor_operational_state()


//////////////////////////////////////////////////////////////


/obj/vehicle/walker/proc/switch_weapons()
	set name = "Switch Weapons Group"
	set category = "Vehicle"

	var/mob/user = usr
	if(!istype(user))
		return
	src = user.interactee
	if(!istype(src, /obj/vehicle/walker))
		return
	if(seats[VEHICLE_DRIVER] != user)
		return

	handle_weapon_groups(user)

// I forgot why I made this a proc and why did this way, however... ~upd 2 days later
/obj/vehicle/walker/proc/handle_weapon_groups(mob/user)
	var/obj/item/hardpoint/walker/spinal/tactical_missile/launcer = hardpoints_by_slot[WALKER_HARDPOIN_SPINAL]
	if(selected_group == SELECTED_GROUP_SPINAL || !istype(launcer) || !launcer.mounted_gun.current_mag?.current_rounds)
		selected_group = SELECTED_GROUP_HANDS
		update_pixels(zoom)
	else
		selected_group = SELECTED_GROUP_SPINAL
		update_pixels(TRUE)

	// Simple re-register of signals, I still don't want to do it clean way ~upd 2 days later
	// I was tired at this moment, sorry for shitcode, for now I see it this way, without coding threehundred shortcuts and mechanics for this one action
	for(var/obj/item/hardpoint/walker/selected as anything in hardpoints)
		selected.pilot_ejected(user)
		selected.pilot_entered(user)

	to_chat(user, SPAN_WARNING("New selected group is [selected_group == SELECTED_GROUP_SPINAL ? "spinal" : "hands"] weapons"))
