/mob/living/carbon/human
	var/alone_for = 0

/obj/effect/mineop/controller
	name = "Костыль для контроля происходящего"
	icon = 'icons/landmarks.dmi'
	icon_state = "x2"

	invisibility = INVISIBILITY_OBSERVER
	var/list/area/tunnel_regions = list()
	var/list/ground_levels = list()
	var/current_drilling_progress = 0
	var/drifters_wave_coming_in = 300
	var/drifters_frequency = 300

/obj/effect/mineop/controller/Initialize(mapload, ...)
	. = ..()
	ground_levels = SSmapping.levels_by_trait(ZTRAIT_GROUND)
	START_PROCESSING(SSobj, src)

/obj/effect/mineop/controller/process()
	if(drifters_wave_coming_in <= 0)
		drifters_wave_coming_in = drifters_frequency
		start_drifters_wave()

	if(current_drilling_progress > 0)
		if(drifters_wave_coming_in > 0)
			drifters_wave_coming_in -= 1

		for(var/ground_z in ground_levels)
			for(var/turf/open/turf in Z_TURFS(ground_z))
				for(var/mob/living/carbon/human/H in turf)
					if(!H.client || H.stat != CONSCIOUS || H.alone_for >= 100)
						continue
					loneliness_check(H)

/obj/effect/mineop/controller/proc/loneliness_check(mob/living/carbon/human/H)
	var/list/people_count = list()
	for(var/mob/living/carbon/human/L in orange(14, H))
		if(L.stat != CONSCIOUS)
			continue

		people_count += L

	if(!length(people_count))
		H.alone_for += 5

	if(length(people_count) < 6)
		H.alone_for += 5

	if(length(people_count) > 6 && H.alone_for != 0)
		H.alone_for -= 5

/obj/effect/mineop/controller/proc/start_drifters_wave()

	var/list/possible_targets = list()

	for(var/ground_z in ground_levels)
		for(var/turf/open/turf in Z_TURFS(ground_z))
			for(var/mob/living/carbon/human/H in turf)
				if(H.alone_for >= 100)
					possible_targets += H

	var/atom/starting_point = pick(possible_targets)
	var/list/turf/available_turfs = list()
	for(var/turf/open/turf in view(starting_point))
		available_turfs += turf

	var/tunnels_amount = rand(1,2)
	tunnels_amount += current_drilling_progress

	var/tunnel_type = text2path("/obj/structure/tunnel/mineop/stage_[current_drilling_progress]")

	for(var/i=1; i <= tunnels_amount; i++)
		var/turf/spawnpick = pick(available_turfs)
		available_turfs -= spawnpick

		new tunnel_type(get_turf(spawnpick))
