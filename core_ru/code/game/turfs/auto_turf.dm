/turf/open/auto_turf/snow/Initialize()
	. = ..()
//Silent fix
	if(!snow)
		new /obj/structure/snow(src, bleed_layer)
	bleed_layer = 0
