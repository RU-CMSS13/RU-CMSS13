/obj/structure/alien/wither_flower
	name = "Wither Flower"
	desc = "A hideous plant-like structure, that emits eerie glow. Something is attracted to it..."
	icon = 'fray-marines/icons/obj/structures/alien/Buildings.dmi'
	icon_state = "healer"
	density = TRUE
	pixel_x = -8

	// var/xeno_tag = null				//see misc.dm

	health = 250
	maxHealth = 250

	var/list/created_mobs = list()
	var/max_mobs = XENO_WITHER_FLOWER_MAX_MOBS

	var/last_spawned = 0
	var/spawn_delay = 5 SECONDS

/obj/structure/alien/wither_flower/Initialize()
	. = ..()

	set_light(2, 1, COLOUR_GREEN)

/obj/structure/alien/wither_flower/process()
	. = ..()
	if(!.)
		return .

	for(var/mob/M in created_mobs)
		if (M.stat || QDELETED(M))
			created_mobs -= M

	if (length(created_mobs) >= max_mobs || last_spawned + spawn_delay >= world.time)
		return 1

	var/list/turfs = list()
	// Поскольку в будущем у ботоксен появится босс, ботоксены будут выкапываться и на корабле. Игровая условность
	for (var/turf/open/T in range(4, src.loc))
		turfs += T

	var/turf/picked = SAFEPICK(turfs)

	if (!picked)
		return 1

	var/picked_mob = pick_a_mob()
	created_mobs += new picked_mob(picked)
	visible_message(SPAN_XENODANGER("A xenomorph rises from the ground!"))
	playsound(picked, 'sound/effects/burrowoff.ogg')
	last_spawned = world.time


	return 1

// TODO: Написать эту ебурину нормально, и обозначить весы как надо
/obj/structure/alien/wither_flower/proc/pick_a_mob()
	if(prob(10))
		return /mob/living/simple_animal/hostile/alien/spawnable/tearer
	return /mob/living/simple_animal/hostile/alien/spawnable/trooper
