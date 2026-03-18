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
	if(!can_consume_energy(consume_energy_light) && !override)
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


/obj/vehicle/walker/proc/special_module_action()
	set name = "Special Module Actions"
	set category = "Vehicle"

	var/mob/user = usr
	if(!istype(user))
		return
	src = user.interactee
	if(!istype(src, /obj/vehicle/walker))
		return
	if(seats[VEHICLE_DRIVER] != user)
		return

	var/selected = tgui_input_list(user, "Select action to perform", "Special Abilities", hardpoint_actions)
	if(!selected)
		return

	hardpoint_actions[selected].custom_action(user, selected)


//////////////////////////////////////////////////////////////


/obj/vehicle/walker/proc/move_z_up()
	set name = "Move UP"
	set category = "Vehicle"

	var/mob/user = usr
	if(!istype(user))
		return
	src = user.interactee
	if(!istype(src, /obj/vehicle/walker))
		return
	if(seats[VEHICLE_DRIVER] != user)
		return

	if(flags_atom & NO_ZFALL)
		var/obj/item/hardpoint/walker/spinal/jetpack/flying_support = hardpoints_by_slot[WALKER_HARDPOIN_SPINAL]
		if(istype(flying_support))
			flying_support.handle_move_z_up(user, src)

/obj/vehicle/walker/proc/move_z_down()
	set name = "Move Down"
	set category = "Vehicle"

	var/mob/user = usr
	if(!istype(user))
		return
	src = user.interactee
	if(!istype(src, /obj/vehicle/walker))
		return
	if(seats[VEHICLE_DRIVER] != user)
		return

	if(flags_atom & NO_ZFALL)
		var/obj/item/hardpoint/walker/spinal/jetpack/flying_support = hardpoints_by_slot[WALKER_HARDPOIN_SPINAL]
		if(istype(flying_support))
			flying_support.handle_move_z_down(user, src)


//////////////////////////////////////////////////////////////


/obj/vehicle/walker/proc/dir_look_lock()
	set name = "Togle Dir Lock"
	set category = "Vehicle"

	var/mob/user = usr
	if(!istype(user))
		return
	src = user.interactee
	if(!istype(src, /obj/vehicle/walker))
		return
	if(seats[VEHICLE_DRIVER] != user)
		return

	dir_look_lock = !dir_look_lock


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
	var/selected_group_cache = selected_group
	var/obj/item/hardpoint/walker/spinal/tactical_missile/launcer = hardpoints_by_slot[WALKER_HARDPOIN_SPINAL]
	if(istype(launcer))
		if(selected_group == SELECTED_GROUP_HANDS && launcer.mounted_gun.current_mag?.current_rounds)
			selected_group = SELECTED_GROUP_SPINAL
			launcer.zoom = TRUE
			update_zoom_pixels()
		else
			selected_group = SELECTED_GROUP_HANDS
			launcer.zoom = FALSE
			update_zoom_pixels()
	else
		selected_group = SELECTED_GROUP_HANDS

	if(selected_group_cache == selected_group)
		return

	// Simple re-register of signals, I still don't want to do it clean way ~upd 2 days later
	// I was tired at this moment, sorry for shitcode, for now I see it this way, without coding threehundred shortcuts and mechanics for this one action
	for(var/obj/item/hardpoint/walker/selected as anything in hardpoints)
		selected.pilot_ejected(user)
		selected.pilot_entered(user)

	to_chat(user, SPAN_WARNING("New selected group is [selected_group == SELECTED_GROUP_SPINAL ? "spinal" : "hands"] weapons"))
