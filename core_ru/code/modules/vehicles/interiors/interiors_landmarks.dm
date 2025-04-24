// Telephone on TOC console in APCru
/obj/effect/landmark/interior/spawn/telephone/toc
	icon = 'core_ru/icons/obj/vehicles/interiors/general.dmi'
	icon_state = "wall_phone"
	color = "yellow"
	// For the love of god, why i can't do this via mapping?
	var/phone_id

// Override to set proper vehicle name
/obj/effect/landmark/interior/spawn/telephone/toc/on_load(datum/interior/I)
	var/obj/structure/transmitter/Phone = new(loc)

	Phone.icon = icon
	Phone.icon_state = icon_state
	Phone.layer = layer
	Phone.setDir(dir)
	Phone.alpha = alpha
	Phone.update_icon()
	Phone.pixel_x = pixel_x
	Phone.pixel_y = pixel_y
	Phone.phone_category = "Vehicles"
	Phone.phone_id = phone_id ? phone_id : "Interior Telephone"

	if (!phone_id && I.exterior != null && istype(I.exterior, /obj/vehicle/multitile))
		var/obj/vehicle/multitile/apc_max/exterior = I.exterior
		// I am to lazy to figure out what comes first - cameras initialization or landmark spawn
		// This for case if cameras first. Nicknaming will set an proper ID
		Phone.phone_id = exterior.nickname ? exterior.nickname : exterior.name

		// Only apc_max has interior phone var
		if (istype(exterior))
			exterior.interior_phone = Phone

	qdel(src)
