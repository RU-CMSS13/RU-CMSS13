/turf/open/floor/almayer/empty
	turf_flags = TURF_WEATHER_PROOF


//Roofs

/turf/open/floor/roof
	icon = 'core_ru/icons/turf/roofs/roof_asphalt.dmi'
	icon_state = "roof"
	base_icon = "roof"
	name = "roof"

	blend_turfs = list(/turf/closed/wall)
	noblend_turfs = list(/turf/closed/wall/mineral, /turf/closed/wall/almayer/research/containment)
	blend_objects = list(/obj/structure/machinery/door, /obj/structure/window_frame, /obj/structure/window/framed)
	noblend_objects = list(/obj/structure/machinery/door/window)

	special_icon = FALSE

/turf/open/floor/roof/ship_hull
	icon = 'core_ru/icons/turf/roofs/roof_ship.dmi'
	name = "hull"
	turf_flags = TURF_WEATHER_PROOF|TURF_EFFECT_AFFECTABLE
	hull_floor = TRUE

/turf/open/floor/roof/ship_hull/lab
	icon = 'core_ru/icons/turf/roofs/roof_lab_ship.dmi'
	name = "ship lab roof"

/turf/open/floor/roof/lab
	icon = 'core_ru/icons/turf/roofs/roof_lab.dmi'
	name = "lab roof"

/turf/open/floor/roof/metal
	icon = 'core_ru/icons/turf/roofs/roof_metal.dmi'
	name = "metal roof"

/turf/open/floor/roof/metal/rusty
	icon = 'core_ru/icons/turf/roofs/roof_rusty.dmi'
	name = "rusty metal roof"

/turf/open/floor/roof/sheet
	icon = 'core_ru/icons/turf/roofs/roof_sheet.dmi'
	name = "sheet roof"

/turf/open/floor/roof/sheet/noborder
	icon = 'core_ru/icons/turf/roofs/roof_sheet_noborder.dmi'

	special_icon = TRUE

/turf/open/floor/roof/asphalt
	icon = 'core_ru/icons/turf/roofs/roof_asphalt.dmi'
	name = "asphalt roof"

/turf/open/floor/roof/asphalt/noborder
	icon = 'core_ru/icons/turf/roofs/roof_asphalt_noborder.dmi'

/turf/open/floor/roof/wood
	icon = 'core_ru/icons/turf/roofs/roof_wood.dmi'
	name = "wood roof"
