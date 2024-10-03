/datum/static_lighting_corner/Destroy(force)
	if(!force)
		return QDEL_HINT_LETMELIVE

	for(var/datum/static_light_source/light_source as anything in affecting)
		light_source.effect_str -= src
	affecting = null

	for(var/atom/movable/outdoor_effect/effect as anything  in glob_affect)
		effect.affecting_corners -= src
	glob_affect = null

	if(master_NE)
		master_NE.lighting_corner_SW = null
		master_NE.lighting_corners_initialised = FALSE
	if(master_SE)
		master_SE.lighting_corner_NW = null
		master_SE.lighting_corners_initialised = FALSE
	if(master_SW)
		master_SW.lighting_corner_NE = null
		master_SW.lighting_corners_initialised = FALSE
	if(master_NW)
		master_NW.lighting_corner_SE = null
		master_NW.lighting_corners_initialised = FALSE
	if(needs_update)
		SSlighting.corners_queue -= src

	return ..()
