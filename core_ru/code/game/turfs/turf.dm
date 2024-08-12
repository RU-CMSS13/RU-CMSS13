/turf
	var/turf_flags = TURF_WEATHER_PROOF|TURF_EFFECT_AFFECTABLE
	var/ceiling_status = NO_FLAGS

	var/base_icon = null

	///Blending
	var/list/wall_connections = list("0", "0", "0", "0")
	var/neighbors_list = 0
	var/special_icon = TRUE
	var/list/blend_turfs = list()
	var/list/noblend_turfs = list() //Turfs to avoid blending with
	var/list/blend_objects = list() // Objects which to blend with
	var/list/noblend_objects = list() //Objects to avoid blending with (such as children of listed blend objects.

