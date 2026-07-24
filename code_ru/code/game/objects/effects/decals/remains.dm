/obj/effect/decal/ammo_casing
	name = "spent casing"
	desc = "Empty and useless now."
	icon = 'icons/obj/items/casings.dmi'
	icon_state = "casing"
	dir = NORTH //Always north when it spawns.
	var/current_casings = 1 //This is manipulated in the procs that use these.
	var/max_casings = 16
	var/current_icon = 0
	var/number_of_states = 10 //How many variations of this item there are.
	garbage = TRUE
	appearance_flags = PIXEL_SCALE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER //Puts them under most objects.


/obj/effect/decal/ammo_casing/Initialize()
	. = ..()
	pixel_x = rand(-2.0, 2) //Want to move them just a tad.
	pixel_y = rand(-2.0, 2)
	icon_state += "_[rand(1,number_of_states)]" //Set the icon to it.


/obj/effect/decal/ammo_casing/update_icon()
	if(max_casings >= current_casings)
		if(current_casings == 2) name += "s" //In case there is more than one.
		if(floor((current_casings-1)/8) > current_icon)
			current_icon++
			icon_state += "_[current_icon]"

		var/base_direction = current_casings - (current_icon * 8)
		setDir(base_direction + floor(base_direction)/3)



/obj/effect/decal/ammo_casing/bullet


/obj/effect/decal/ammo_casing/cartridge
	name = "spent cartridge"
	icon_state = "cartridge"


/obj/effect/decal/ammo_casing/greenshell
	name = "spent shell"
	icon_state = "greenshell"


/obj/effect/decal/ammo_casing/redshell
	name = "spent shell"
	icon_state = "redshell"


/obj/effect/decal/ammo_casing/blueshell
	name = "spent shell"
	icon_state = "blueshell"

