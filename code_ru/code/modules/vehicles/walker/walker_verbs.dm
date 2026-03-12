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
	set name = "Lights on/off"
	set category = "Vehicle"

	var/mob/user = usr
	if(!istype(user))
		return
	src = user.interactee
	if(!istype(src, /obj/vehicle/walker))
		return
	if(seats[VEHICLE_DRIVER] != user)
		return

	if(lighting_holder)
		if(lighting_holder.light_on)
			lighting_holder.set_light_on(FALSE)
		else
			lighting_holder.set_light_on(TRUE)
	else
		if(light_on)
			set_light_on(FALSE)
		else
			set_light_on(TRUE)
	playsound(src, 'sound/machines/click.ogg', 50)


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
	for(var/obj/item/hardpoint/walker/hand/selected in hardpoints)
		if(!selected.mounted_gun)
			continue
		if(!selected.mounted_gun.current_mag)
			continue
		acceptible_modules[selected.mounted_gun.name] = selected.mounted_gun
	if(!length(acceptible_modules))
		to_chat(user, "Not found ammo mags to eject")
		return

	var/selected_module = tgui_input_list(user, "Select a gun to eject magazine.", "Eject Magazine", acceptible_modules)
	if(!selected_module)
		return
	var/obj/item/weapon/gun/mounted_gun = acceptible_modules[selected_module]
	if(!mounted_gun || mounted_gun.gun_holder != src || !mounted_gun.current_mag)
		return FALSE
	mounted_gun.unload(user, TRUE)
	to_chat(user, SPAN_WARNING("WARNING! [mounted_gun] ammo magazine deployed."))
	visible_message("[name]'s systems ejected used magazine.","")


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
	set name = "Zoom on/off"
	set category = "Vehicle"

	var/mob/user = usr
	if(!istype(user))
		return
	src = user.interactee
	if(!istype(src, /obj/vehicle/walker))
		return
	if(seats[VEHICLE_DRIVER] != user)
		return

	zoom = !zoom
	update_pixels(user, zoom)


//////////////////////////////////////////////////////////////


/obj/vehicle/walker/proc/toggle_motion_detector()
	set name = "Motion Detector on/off"
	set category = "Vehicle"

	var/mob/user = usr
	if(!istype(user))
		return
	src = user.interactee
	if(!istype(src, /obj/vehicle/walker))
		return
	if(seats[VEHICLE_DRIVER] != user)
		return

	var/obj/item/hardpoint/walker/spinal/artilery/provider = locate() in hardpoints
	if(!provider)
		return
	provider.motion_detector.toggle_active(user, provider.motion_detector.active)


//////////////////////////////////////////////////////////////


/obj/vehicle/walker/proc/toggle_reactor()
	set name = "Reactor on/off"
	set category = "Vehicle"

	var/mob/user = usr
	if(!istype(user))
		return
	src = user.interactee
	if(!istype(src, /obj/vehicle/walker))
		return
	if(seats[VEHICLE_DRIVER] != user)
		return

	if(!power_supply)
		return
	if(power_supply.rebooting)
		to_chat(user, SPAN_DANGER("Reactor already rebooting!"))
		return
	if(tgui_alert(user, "Are you sure about turning it [power_supply.turned_on ? "Off" : "On"]?", "Reactor Control", list("Yes", "No")) == "No")
		return

	power_supply.switch_reactor_operational_state()
