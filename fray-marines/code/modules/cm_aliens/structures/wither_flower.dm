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
	var/spawn_delay = 15 SECONDS

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

	if (length(created_mobs) >= max_mobs || locate(/mob/living/simple_animal/hostile/alien/spawnable) in get_turf(src))
		last_spawned = world.time
		return 1

	if (last_spawned + spawn_delay >= world.time)
		return 1

	var/picked_mob = SSxeno_ai.pick_a_xeno()
	created_mobs += new picked_mob(get_turf(src))
	visible_message(SPAN_XENODANGER("A xenomorph rises from the ground!"))
	playsound(src.loc, 'sound/effects/burrowoff.ogg')
	last_spawned = world.time

	return 1
