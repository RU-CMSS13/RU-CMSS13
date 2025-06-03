//Megaphone gaming
/obj/vehicle/multitile/proc/use_megaphone()
	set name = "Use Megaphone"
	set desc = "Let's you shout a message to peoples around the vehicle."
	set category = "Vehicle"

	var/mob/living/user = usr
	if(user.client)
		if(user.client?.prefs?.muted & MUTE_IC)
			to_chat(src, SPAN_DANGER("You cannot speak in IC (muted)."))
			return
	if(!ishumansynth_strict(user))
		to_chat(user, SPAN_DANGER("You don't know how to use this!"))
		return
	if(user.silent)
		return

	var/obj/vehicle/multitile/V = user.interactee
	if(!istype(V))
		return

	var/seat
	for(var/vehicle_seat in V.seats)
		if(V.seats[vehicle_seat] == user)
			seat = vehicle_seat
			break
	if(!seat)
		return

	if(world.time < V.next_shout)
		to_chat(user, SPAN_WARNING("You need to wait [(V.next_shout - world.time) / 10] seconds."))
		return

	var/message = tgui_input_text(user, "Shout a message?", "Megaphone", multiline = TRUE)
	if(!message)
		return
	// we know user is a human now, so adjust user for this check
	var/mob/living/carbon/human/humanoid = user
	var/list/new_message = humanoid.handle_speech_problems(message)
	message = new_message[1]
	message = capitalize(message)
	log_admin("[key_name(user)] used a vehicle megaphone to say: >[message]<")

	if(!user.is_mob_incapacitated())
		var/list/mob/listeners = get_mobs_in_view(9,V)
		var/list/mob/langchat_long_listeners = list()
		//RUCM START
		var/list/tts_heard_list = list(list(), list(), list())
		INVOKE_ASYNC(SStts, TYPE_PROC_REF(/datum/controller/subsystem/tts, queue_tts_message), src, html_decode(message), user.tts_voice, user.tts_voice_filter, tts_heard_list, FALSE, 50, user.tts_voice_pitch, "", user.speaking_noise)
		//RUCM END
		for(var/mob/listener in listeners)
			if(!ishumansynth_strict(listener) && !isobserver(listener))
				listener.show_message("[V] broadcasts something, but you can't understand it.")
				continue
			listener.show_message("<B>[V]</B> broadcasts, [FONT_SIZE_LARGE("\"[message]\"")]", SHOW_MESSAGE_AUDIBLE) // 2 stands for hearable message
			langchat_long_listeners += listener
		V.langchat_long_speech(message, langchat_long_listeners, user.get_default_language(), tts_heard_list)

		V.next_shout = world.time + 10 SECONDS

/obj/vehicle/multitile/arc_ru/proc/toggle_antenna(mob/toggler)
	set name = "Toggle Sensor Antenna"
	set desc = "Raises or lowers the external sensor antenna. While raised, the ARC cannot move."
	set category = "Vehicle"

	var/mob/user = toggler || usr
	if(!user || !istype(user))
		return

	var/obj/vehicle/multitile/arc_ru/vehicle = user.interactee
	if(!istype(vehicle))
		return

	var/seat
	for(var/vehicle_seat in vehicle.seats)
		if(vehicle.seats[vehicle_seat] == user)
			seat = vehicle_seat
			break

	if(!seat)
		return

	if(vehicle.health < initial(vehicle.health) * 0.5)
		to_chat(user, SPAN_WARNING("[vehicle]'s hull is too damaged to operate!"))
		return

	var/obj/item/hardpoint/support/arc_antenna/ru/antenna = locate() in vehicle.hardpoints
	if(!antenna)
		to_chat(user, SPAN_WARNING("[vehicle] has no antenna mounted!"))
		return

	if(antenna.deploying)
		return

	if(antenna.health <= 0)
		to_chat(user, SPAN_WARNING("[antenna] is broken!"))
		return

	if(vehicle.antenna_deployed)
		to_chat(user, SPAN_NOTICE("You begin to retract [antenna]..."))
		antenna.deploying = TRUE
		if(!do_after(user, max(vehicle.antenna_toggle_time - antenna.deploy_animation_time, 1 SECONDS), target = vehicle))
			to_chat(user, SPAN_NOTICE("You stop retracting [antenna]."))
			antenna.deploying = FALSE
			return

		antenna.retract_antenna()
		addtimer(CALLBACK(vehicle, PROC_REF(finish_antenna_retract), user), antenna.deploy_animation_time)

	else
		to_chat(user, SPAN_NOTICE("You begin to extend [antenna]..."))
		antenna.deploying = TRUE
		if(!do_after(user, max(vehicle.antenna_toggle_time - antenna.deploy_animation_time, 1 SECONDS), target = vehicle))
			to_chat(user, SPAN_NOTICE("You stop extending [antenna]."))
			antenna.deploying = FALSE
			return

		antenna.deploy_antenna()
		addtimer(CALLBACK(vehicle, PROC_REF(finish_antenna_deploy), user), antenna.deploy_animation_time)

/obj/vehicle/multitile/arc_ru/proc/finish_antenna_retract(mob/user)
	var/obj/item/hardpoint/support/arc_antenna/ru/antenna = locate() in hardpoints
	if(!antenna)
		antenna.deploying = FALSE
		return

	if(user)
		to_chat(user, SPAN_NOTICE("You retract [antenna], enabling the ARC to move again."))
		playsound(user, 'sound/machines/hydraulics_2.ogg', 80, TRUE)
	antenna_deployed = !antenna_deployed
	antenna.deploying = FALSE
	update_icon()
	SEND_SIGNAL(src, COMSIG_ARC_ANTENNA_TOGGLED)

/obj/vehicle/multitile/arc_ru/proc/finish_antenna_deploy(mob/user)
	var/obj/item/hardpoint/support/arc_antenna/ru/antenna = locate() in hardpoints
	if(!antenna)
		antenna.deploying = FALSE
		return

	if(user)
		to_chat(user, SPAN_NOTICE("You extend [antenna], locking the ARC in place."))
		playsound(user, 'sound/machines/hydraulics_2.ogg', 80, TRUE)
	antenna_deployed = !antenna_deployed
	antenna.deploying = FALSE
	update_icon()
	SEND_SIGNAL(src, COMSIG_ARC_ANTENNA_TOGGLED)

/obj/vehicle/multitile/arc_ru/proc/open_arc_controls_guide()
	set name = "Vehicle Controls Guide"
	set desc = "MANDATORY FOR FIRST PLAY AS VEHICLE CREWMAN OR AFTER UPDATES."
	set category = "Vehicle"

	var/mob/user = usr
	if(!istype(user))
		return

	var/obj/vehicle/multitile/arc_ru/vehicle = user.interactee
	if(!istype(vehicle))
		return

	var/seat
	for(var/vehicle_seat in vehicle.seats)
		if(vehicle.seats[vehicle_seat] == user)
			seat = vehicle_seat
			break

	if(!seat)
		return

	var/dat = "<b><i>Common verbs:</i></b><br>\
	1. <b>\"G: Name Vehicle\"</b> - used to add a custom name to the vehicle. Single use. 26 characters maximum.<br> \
	2. <b>\"I: Get Status Info\"</b> - brings up \"Vehicle Status Info\" window with all available information about your vehicle.<br> \
	3. <b>\"G: Toggle Sensor Antenna\"</b> - extend or retract the ARC's sensor antenna. While extended, all unknown lifeforms within a large range can be seen by all on the tacmap, but the ARC cannot move. Additionally enables the automated RE700 cannon.<br> \
	<font color='#cd6500'><b><i>Driver verbs:</i></b></font><br> 1. <b>\"G: Activate Horn\"</b> - activates vehicle horn. Keep in mind, that vehicle horn is very loud and can be heard from afar by both allies and foes.<br> \
	2. <b>\"G: Toggle Door Locks\"</b> - toggles vehicle's access restrictions. Crewman, Brig and Command accesses bypass these restrictions.<br> \
	<font color='#cd6500'><b><i>Driver shortcuts:</i></b></font><br> 1. <b>\"CTRL + Click\"</b> - activates vehicle horn.<br>"

	show_browser(user, dat, "Vehicle Controls Guide", "vehicle_help", width = 900, height = 500)
	onclose(user, "vehicle_help")
	return
