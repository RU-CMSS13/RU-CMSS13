/datum/keybinding/human/walker
	category = CATEGORY_HUMAN_WALKER


/datum/action/walker
	icon_file = null
	button_icon_state = null
	///Owner of action or action holder, holds ref for user in it
	var/obj/vehicle/walker/vessel
	///If any hardpoint related
	var/obj/item/hardpoint/walker/hardpoint

/datum/action/walker/New(Target, override_icon_state, real_owner, related_hardpoint)
	. = ..()
	vessel = real_owner
	hardpoint = related_hardpoint

/datum/action/walker/remove_from(mob/user)
	vessel = null
	hardpoint = null
	. = ..()


//////////////////////////////////////////////////////////////


/datum/action/walker/lights
	name = "Toggle Light"
	listen_signal = COMSIG_KB_HUMAN_INTERACT_WALKER_LIGHTS

/datum/action/walker/lights/action_activate()
	. = ..()
	vessel.switch_light_state(!vessel.light_state)

/obj/vehicle/walker/switch_light_state(new_state, override)
	if(!can_consume_energy(consume_energy_light) && !override)
		return

	visible_message("[src]'s system switchs lights state.")
	. = ..()


/datum/keybinding/human/walker/turn_lights
	hotkey_keys = list("Unbound")
	classic_keys = list("Unbound")
	name = "walker_turn_lights"
	full_name = "Turn Lights"
	description = "Turn on or off lights"
	keybind_signal = COMSIG_KB_HUMAN_INTERACT_WALKER_LIGHTS


//////////////////////////////////////////////////////////////


/datum/action/walker/eject_magazine
	name = "Eject Magazine"
	listen_signal = COMSIG_KB_HUMAN_INTERACT_WALKER_EJECT_MAGAZINE

/datum/action/walker/eject_magazine/action_activate()
	. = ..()
	vessel.eject_magazine(owner)


/datum/keybinding/human/walker/eject_magazine
	hotkey_keys = list("Unbound")
	classic_keys = list("Unbound")
	name = "walker_eject_magazine"
	full_name = "Eject Magazine"
	description = "Eject magazine from gun"
	keybind_signal = COMSIG_KB_HUMAN_INTERACT_WALKER_EJECT_MAGAZINE


//////////////////////////////////////////////////////////////


/datum/action/walker/get_stats
	name = "Show Stats"
	listen_signal = COMSIG_KB_HUMAN_INTERACT_WALKER_STATUS

/datum/action/walker/get_stats/action_activate()
	. = ..()
	vessel.tgui_interact(owner)


/datum/keybinding/human/walker/status_display
	hotkey_keys = list("Unbound")
	classic_keys = list("Unbound")
	name = "walker_status_display"
	full_name = "Show Status"
	description = "Shows walker status menu"
	keybind_signal = COMSIG_KB_HUMAN_INTERACT_WALKER_STATUS


//////////////////////////////////////////////////////////////


/datum/action/walker/dir_look_lock
	name = "Toggle Dir Lock"
	listen_signal = COMSIG_KB_HUMAN_INTERACT_WALKER_DIR_LOCK

/datum/action/walker/dir_look_lock/action_activate()
	. = ..()
	vessel.dir_look_lock = !vessel.dir_look_lock


/datum/keybinding/human/walker/dir_lock
	hotkey_keys = list("Unbound")
	classic_keys = list("Unbound")
	name = "walker_dir_lock"
	full_name = "Dir Lock"
	description = "Lock walker direction for movement"
	keybind_signal = COMSIG_KB_HUMAN_INTERACT_WALKER_DIR_LOCK


//////////////////////////////////////////////////////////////


/datum/action/walker/switch_weapons
	name = "Switch Weapons"
	listen_signal = COMSIG_KB_HUMAN_INTERACT_WALKER_SWITCH_WEAPONS

/datum/action/walker/switch_weapons/action_activate()
	. = ..()
	vessel.handle_weapon_groups(owner)


/datum/keybinding/human/walker/switch_weapons
	hotkey_keys = list("Unbound")
	classic_keys = list("Unbound")
	name = "walker_weapon_group"
	full_name = "Switch Weapon Group"
	description = "Switch weapons for normal or special"
	keybind_signal = COMSIG_KB_HUMAN_INTERACT_WALKER_SWITCH_WEAPONS


//////////////////////////////////////////////////////////////


/datum/action/walker/jetpack
	name = "Toggle Jetpack"
	listen_signal = COMSIG_KB_HUMAN_INTERACT_WALKER_JETPACK

/datum/action/walker/jetpack/action_activate()
	. = ..()
	var/obj/item/hardpoint/walker/spinal/jetpack/action_holder = hardpoint
	if(action_holder.performing_action)
		return FALSE

	if(!action_holder.flying && action_holder.fuel < action_holder.fuel_consumption_rate)
		return FALSE

	action_holder.change_flying_state()

/datum/action/walker/jetpack_evac
	name = "Jetpack Evac"
	listen_signal = COMSIG_KB_HUMAN_INTERACT_WALKER_JETPACK_EVAC

/datum/action/walker/jetpack_evac/action_activate()
	. = ..()
	var/obj/item/hardpoint/walker/spinal/jetpack/action_holder = hardpoint
	if(action_holder.performing_action || !action_holder.flying)
		return FALSE
	action_holder.prepare_titan_raise(owner, action_holder.owner)


/datum/keybinding/human/walker/jetpack
	hotkey_keys = list("Unbound")
	classic_keys = list("Unbound")
	name = "walker_jetpack"
	full_name = "Jetpack"
	description = "Allows to toggle jetpack"
	keybind_signal = COMSIG_KB_HUMAN_INTERACT_WALKER_JETPACK

/datum/keybinding/human/walker/jetpack_evac
	hotkey_keys = list("Unbound")
	classic_keys = list("Unbound")
	name = "walker_jetpack_evac"
	full_name = "Jetpack Evac"
	description = "Allows to use special jetpack ability"
	keybind_signal = COMSIG_KB_HUMAN_INTERACT_WALKER_JETPACK_EVAC


//////////////////////////////////////////////////////////////


/datum/action/walker/move_z_up
	name = "Move UP"
	listen_signal = COMSIG_KB_HUMAN_INTERACT_WALKER_Z_UP

/datum/action/walker/move_z_up/action_activate()
	. = ..()
	vessel.move_z_up(owner)

/datum/action/walker/move_z_down
	name = "Move DOWN"
	listen_signal = COMSIG_KB_HUMAN_INTERACT_WALKER_Z_DOWN

/datum/action/walker/move_z_down/action_activate()
	. = ..()
	vessel.move_z_down(owner)


/datum/keybinding/human/walker/move_z_up
	hotkey_keys = list("Unbound")
	classic_keys = list("Unbound")
	name = "walker_z_up"
	full_name = "Move Up"
	description = "Move walker thru zlevels"
	keybind_signal = COMSIG_KB_HUMAN_INTERACT_WALKER_Z_UP

/datum/keybinding/human/walker/move_z_down
	hotkey_keys = list("Unbound")
	classic_keys = list("Unbound")
	name = "walker_z_down"
	full_name = "Move Down"
	description = "Move walker thru zlevels"
	keybind_signal = COMSIG_KB_HUMAN_INTERACT_WALKER_Z_DOWN


//////////////////////////////////////////////////////////////


/datum/action/walker/reactor
	name = "Toggle Reactor"
	listen_signal = COMSIG_KB_HUMAN_INTERACT_WALKER_REACTOR

/datum/action/walker/reactor/action_activate()
	. = ..()
	var/obj/item/hardpoint/walker/reactor/action_holder = hardpoint
	action_holder.switch_reactor_state(owner)


/datum/keybinding/human/walker/reactor
	hotkey_keys = list("Unbound")
	classic_keys = list("Unbound")
	name = "walker_reactor"
	full_name = "Reactor"
	description = "Allows to toggle reactor"
	keybind_signal = COMSIG_KB_HUMAN_INTERACT_WALKER_REACTOR


//////////////////////////////////////////////////////////////


/datum/action/walker/art_zoom
	name = "Zoom"
	listen_signal = COMSIG_KB_HUMAN_INTERACT_WALKER_ZOOM

/datum/action/walker/art_zoom/action_activate()
	. = ..()
	var/consumption = ceil(hardpoint.zoom_size * 0.5)
	if(!vessel.can_consume_energy(consumption))
		return
	hardpoint.zoom = !hardpoint.zoom
	vessel.update_zoom_pixels(TRUE)

/datum/action/walker/motion_detector
	name = "Motion Detector"
	listen_signal = COMSIG_KB_HUMAN_INTERACT_WALKER_MOTION_DETECTOR

/datum/action/walker/motion_detector/action_activate()
	. = ..()
	if(!vessel.can_consume_energy(hardpoint.motion_detector.detector_range))
		return FALSE
	hardpoint.motion_detector.toggle_active(owner, hardpoint.motion_detector.active)


/datum/keybinding/human/walker/zoom
	hotkey_keys = list("Unbound")
	classic_keys = list("Unbound")
	name = "walker_zoom"
	full_name = "Zoom"
	description = "Allows use zoom"
	keybind_signal = COMSIG_KB_HUMAN_INTERACT_WALKER_ZOOM

/datum/keybinding/human/walker/motion_detector
	hotkey_keys = list("Unbound")
	classic_keys = list("Unbound")
	name = "walker_motion_detector"
	full_name = "Motion Detector"
	description = "Allows to use motion detector"
	keybind_signal = COMSIG_KB_HUMAN_INTERACT_WALKER_MOTION_DETECTOR


//////////////////////////////////////////////////////////////
