/datum/resin_construction/resin_obj/sunken_colony
	name = "Sunken Colony"
	desc = "Big and tanky living structure made to protect the hive. Fiercely territorial."
	construction_name = "acid pillar"
	cost = XENO_RESIN_ACID_GRENADE_COST
	max_per_xeno = 2

	build_overlay_icon = /obj/effect/warning/alien/weak

	build_path = /obj/structure/alien/sunken
	build_time = 24 SECONDS

	range_between_constructions = 14

/datum/resin_construction/resin_obj/sunken_colony/can_build_here(turf/T, mob/living/carbon/xenomorph/X)
	if (!..())
		return FALSE

	var/obj/effect/alien/weeds/alien_weeds = locate() in T

	if(istype(get_area(T), /area/shuttle))
		to_chat(X, SPAN_WARNING("How do you plan to make roots here?!"))
		return FALSE

	if (alien_weeds.weed_strength < WEED_LEVEL_HIVE)
		to_chat(X, SPAN_WARNING("You can only shape it on hive weeds. Find some resin before you start building!"))
		return FALSE

	return TRUE

/datum/resin_construction/resin_obj/wither_flower
	name = "Wither Flower"
	desc = "A hideous plant-like structure, that emits eerie glow. Something is attracted to it..."
	construction_name = "acid pillar"
	cost = XENO_RESIN_ACID_GRENADE_COST
	max_per_xeno = 5

	build_overlay_icon = /obj/effect/warning/alien/weak

	build_path = /obj/structure/alien/wither_flower
	build_time = 12 SECONDS

	range_between_constructions = 5
