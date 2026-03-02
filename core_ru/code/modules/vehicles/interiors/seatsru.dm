//RU ARC seat with 2 intel and 1 vehicle skillchecks
/obj/structure/bed/chair/comfy/vehicle/arc
	name = "ARC driver's seat"
	desc = "Military-grade seat for armored vehicle driver with some controls, switches and indicators."
	var/image/over_image = null
	seat = VEHICLE_DRIVER

/obj/structure/bed/chair/comfy/vehicle/arc/Initialize(mapload)
	over_image = image(icon, "armor_chair_buckled")
	over_image.layer = ABOVE_MOB_LAYER

	return ..()

/obj/structure/bed/chair/comfy/vehicle/arc/update_icon()
	overlays.Cut()
	..()

	if(buckled_mob)
		overlays += over_image

/obj/structure/bed/chair/comfy/vehicle/arc/do_buckle(mob/target, mob/user)

	required_skill = 0
	if(!skillcheck(target, SKILL_INTEL, 2))
		if(!skillcheck(target, SKILL_VEHICLE, 1))
			if(target == user)
				to_chat(user, SPAN_WARNING("You have no idea how to drive this thing!"))
			return FALSE

	if(vehicle)
		vehicle.vehicle_faction = target.faction
	update_icon()
	return ..()
