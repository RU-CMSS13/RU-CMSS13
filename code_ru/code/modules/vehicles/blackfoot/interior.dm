// ==================MINIGUN========================

/obj/structure/blackfoot_doorgun/minigun
	name = "M866 Minigun"
	desc = "A belt-fed automatic minigun system, mounted directly to the aft end of the Blackfoot. The superstructure is hydraulically assisted so that the operator can adjust the gun with minimal force input. The gun fires 20mm caseless ammo rounds that useful for incapacitating a large group of soft targets."
	icon = 'icons/obj/vehicles/interiors/blackfoot_64x64.dmi'
	icon_state = "doorgun-mini"

/obj/structure/blackfoot_doorgun/minigun/update_icon()
	if(deployed)
		icon_state = "doorgun-mini-deployed"
	else
		icon_state = "doorgun-mini"

/obj/structure/blackfoot_doorgun/minigun/attackby(obj/item/item, mob/user)
	if(!deployed)
		return

	if(!istype(item, /obj/item/ammo_magazine/hardpoint/doorgun_ammo/holotarget))
		return

	var/obj/item/ammo_magazine/hardpoint/doorgun_ammo/holotarget/ammo = item
	var/obj/item/hardpoint/secondary/doorgun/minigun/doorgun = locate() in linked_blackfoot.hardpoints

	if(!doorgun)
		return

	doorgun.try_add_clip(ammo, user)

/obj/effect/landmark/interior/spawn/blackfoot_doorgun/minigun
	icon = 'icons/obj/vehicles/interiors/blackfoot_64x64.dmi'
	icon_state = "doorgun-mini"

/obj/effect/landmark/interior/spawn/blackfoot_doorgun/minigun/on_load(datum/interior/interior)
	var/obj/structure/blackfoot_doorgun/minigun/doorgun = new(get_turf(src))

	doorgun.setDir(dir)
	doorgun.alpha = alpha
	doorgun.update_icon()
	doorgun.pixel_x = pixel_x
	doorgun.pixel_y = pixel_y

	if(istype(interior.exterior, /obj/vehicle/multitile/blackfoot))
		var/obj/vehicle/multitile/blackfoot/linked_blackfoot = interior.exterior
		doorgun.linked_blackfoot = linked_blackfoot

	qdel(src)
