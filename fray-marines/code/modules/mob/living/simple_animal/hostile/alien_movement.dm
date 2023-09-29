/mob/living/simple_animal/hostile/alien/spawnable/Move(NewLoc, direct)
	if (direct && locate(/obj/flamer_fire) in get_step(src.loc, direct))
		return FALSE
	return ..()
