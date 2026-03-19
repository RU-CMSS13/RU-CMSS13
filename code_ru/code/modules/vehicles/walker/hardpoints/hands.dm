/obj/item/hardpoint/walker/hand
	name = "Mecha Hand"
	desc = "Allows mecha to hold weapons. You can use a screwdriver to remove any equipment installed in this slot."

	hdpt_layer = HDPT_LAYER_SUPPORT
	firing_arc = 120
	destruction_on_zero = FALSE

	mount_class = GUN_MOUNT_MECHA

/obj/item/hardpoint/walker/hand/get_icon_image(x_offset, y_offset, new_dir, type_slot)
	type_slot = slot == WALKER_HARDPOIN_LEFT_HAND ? "_l_hand" : "_r_hand"

	. = ..(x_offset, y_offset, new_dir, type_slot)

	if(mounted_gun)
		var/image/gun = image(icon = disp_icon, icon_state = "[mounted_gun.item_state + type_slot]", pixel_x = x_offset, pixel_y = y_offset, dir = new_dir)
		var/image/self = .[1]
		gun.color = self.color
		. += gun

/obj/item/hardpoint/walker/hand/tgui_additional_data()
	. = ..()

	if(!mounted_gun?.current_mag || !(mounted_gun.current_mag.current_rounds || mounted_gun.current_mag.reagents))
		return

	var/list/data = list()
	.["hardpoint_data_additional"] += list(data)
	data["value_name"] = "Ammo"
	data["current_value"] = mounted_gun.current_mag.reagents?.total_volume || mounted_gun.current_mag.current_rounds
	data["max_value"] = mounted_gun.current_mag.max_rounds

/obj/item/hardpoint/walker/hand/check_modifiers(modifiers, button = FALSE)
	if(slot == WALKER_HARDPOIN_LEFT_HAND ? !modifiers[LEFT_CLICK] : !modifiers[MIDDLE_CLICK])
		return FALSE

	if(button && (slot == WALKER_HARDPOIN_LEFT_HAND ? modifiers[BUTTON] != LEFT_CLICK : modifiers[BUTTON] != MIDDLE_CLICK))
		return FALSE
	return TRUE


/obj/item/hardpoint/walker/hand/left
	name = "Left Mecha Hand"
	desc = "Allows mecha to hold weapons."

	slot = WALKER_HARDPOIN_LEFT_HAND

/obj/item/hardpoint/walker/hand/right
	name = "Right Mecha Hand"
	desc = "Allows mecha to hold weapons."

	slot = WALKER_HARDPOIN_RIGHT_HAND
