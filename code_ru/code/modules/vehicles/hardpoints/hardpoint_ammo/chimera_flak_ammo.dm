/obj/item/ammo_magazine/hardpoint/chimera_launchers_ammo/autocannon
	name = "AC3-E Autocannon Magazine"
	desc = "A 30 round magazine holding 20mm shells for the AC3-E autocannon."
	caliber = "20mm"
	icon = 'icons/obj/items/weapons/guns/ammo_by_faction/USCM/vehicles.dmi'
	icon_state = "ace_autocannon"
	w_class = SIZE_LARGE
	default_ammo = /datum/ammo/bullet/chimera/flak
	max_rounds = 30
	gun_type = /obj/item/hardpoint/primary/chimera_launchers/autocannon

/obj/item/ammo_magazine/hardpoint/chimera_launchers_ammo/autocannon/update_icon()
	if(current_rounds > 0)
		icon_state = "ace_autocannon"
	else
		icon_state = "ace_autocannon_empty"
