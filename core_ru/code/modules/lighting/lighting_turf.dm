// Used to get a scaled lumcount.
/turf/proc/get_lumcount(minlum = 0, maxlum = 1)
	var/totallums = 0
	var/totalGlobalLightFalloff = 0
	if(static_lighting_object)
		var/datum/static_lighting_corner/L
		L = lighting_corner_NE
		if(L)
			totallums += L.lum_r + L.lum_b + L.lum_g
			totalGlobalLightFalloff += L.global_light_falloff
		L = lighting_corner_SE
		if(L)
			totallums += L.lum_r + L.lum_b + L.lum_g
			totalGlobalLightFalloff += L.global_light_falloff
		L = lighting_corner_SW
		if(L)
			totallums += L.lum_r + L.lum_b + L.lum_g
			totalGlobalLightFalloff += L.global_light_falloff
		L = lighting_corner_NW
		if(L)
			totallums += L.lum_r + L.lum_b + L.lum_g
			totalGlobalLightFalloff += L.global_light_falloff
		if(outdoor_effect && outdoor_effect.state) /* SKY_BLOCKED is 0 */
			totalGlobalLightFalloff = 4
		/* global light / 4 corners */
		totallums += totalGlobalLightFalloff / 4

		totallums /= 12 // 4 corners, each with 3 channels, get the average.

		totallums = (totallums - minlum) / (maxlum - minlum)

		totallums = CLAMP01(totallums)
	else
		totallums = 1

	for(var/atom/movable/lighting_mask/mask as anything in hybrid_lights_affecting)
		if(mask.blend_mode == BLEND_ADD)
			totallums += LIGHT_POWER_ESTIMATION(mask.alpha, mask.radius, get_dist(src, get_turf(mask.attached_atom)))
		else
			totallums -= LIGHT_POWER_ESTIMATION(mask.alpha, mask.radius, get_dist(src, get_turf(mask.attached_atom)))
	return clamp(totallums, 0.0, 1.0)
