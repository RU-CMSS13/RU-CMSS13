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
	src = user.interactee
	if(!istype(src, /obj/vehicle/walker))
		return

	switch_light_state(!light_state)


//////////////////////////////////////////////////////////////


/obj/vehicle/walker/proc/action_eject_magazine()
	set name = "Eject Magazine"
	set category = "Vehicle"

	var/mob/user = usr
	src = user.interactee
	if(!istype(src, /obj/vehicle/walker))
		return

	eject_magazine(user)


//////////////////////////////////////////////////////////////


/obj/vehicle/walker/proc/get_stats()
	set name = "Status Display"
	set category = "Vehicle"

	var/mob/user = usr
	src = user.interactee
	if(!istype(src, /obj/vehicle/walker))
		return

	tgui_interact(user)


//////////////////////////////////////////////////////////////


/obj/vehicle/walker/proc/dir_look_lock()
	set name = "Toggle Dir Lock"
	set category = "Vehicle"

	var/mob/user = usr
	src = user.interactee
	if(!istype(src, /obj/vehicle/walker))
		return

	dir_look_lock = !dir_look_lock


//////////////////////////////////////////////////////////////


/obj/vehicle/walker/proc/switch_weapons()
	set name = "Switch Weapons Group"
	set category = "Vehicle"

	var/mob/user = usr
	src = user.interactee
	if(!istype(src, /obj/vehicle/walker))
		return

	handle_weapon_groups(user)


//////////////////////////////////////////////////////////////


/obj/vehicle/walker/proc/name_walker()
	set name = "Name Vehicle"
	set desc = "Allows you to add a custom name to your vehicle. Single use. 26 characters maximum."
	set category = "Vehicle"

	var/mob/user = usr
	src = user.interactee
	if(!istype(src, /obj/vehicle/walker))
		return

	if(nickname)
		to_chat(user, SPAN_WARNING("Vehicle already has a \"[nickname]\" nickname."))
		return

	var/new_nickname = stripped_input(user, "Enter a unique IC name or a callsign to add to your vehicle's name. [MAX_NAME_LEN] characters maximum. \n\nIMPORTANT! This is an IC nickname/callsign for your vehicle and you will be punished for putting in meme names.\nSINGLE USE ONLY.", "Name your vehicle", null, MAX_NAME_LEN)
	if(!new_nickname)
		return
	if(length(new_nickname) > MAX_NAME_LEN)
		alert(user, "Name [new_nickname] is over [MAX_NAME_LEN] characters limit. Try again.", "Naming vehicle failed", "Ok")
		return
	if(alert(user, "Vehicle's name will be CW13 \"[new_nickname]\" Assault Walker. Confirm?", "Confirmation?", "Yes", "No") != "Yes")
		return

	if(seats[VEHICLE_DRIVER] != user)
		return

	nickname = new_nickname
	name = "CW13 \"[nickname]\" Assault Walker"
	to_chat(user, SPAN_NOTICE("You've added \"[nickname]\" nickname to your vehicle."))

	message_admins(WRAP_STAFF_LOG(user, "added \"[nickname]\" nickname to their [initial(name)]. ([x],[y],[z])"), x, y, z)
