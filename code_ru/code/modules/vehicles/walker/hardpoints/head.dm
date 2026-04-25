/obj/item/hardpoint/walker/head
	name = "Mecha Cockpit Glass"
	desc = "This reinforced high quality glass protects operator from potential danger outside of mech."

	icon = 'code_ru/icons/obj/vehicles/mech_armor.dmi'
	icon_state = "cockpit_glass"
	disp_icon_state = "mech_cockpit"

	slot = WALKER_HARDPOIN_HEAD
	hdpt_layer = HDPT_LAYER_SUPPORT
	destruction_on_zero = FALSE

/obj/item/hardpoint/walker/head/get_icon_image(x_offset, y_offset, new_dir, type_slot)
	if(owner?.seats[VEHICLE_DRIVER])
		type_slot = "_closed"
	else
		type_slot = "_open"

	. = ..(x_offset, y_offset, new_dir, type_slot)
