/mob/living/simple_animal/hostile/alien/spawnable/Move(NewLoc, direct)
	if (direct && locate(/obj/flamer_fire) in get_step(src.loc, direct))
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/alien/spawnable/proc/MoveAround(atom/object)
	if (!object)
		return

	var/target_dir = get_dir(src, object)
	var/move_dir = target_dir

	if(move_dir in cardinal)
		move_dir = pick(list(
			turn(target_dir, 90),
			turn(target_dir, -90)
		))
	else
		move_dir = pick(list(
			turn(target_dir, 45),
			turn(target_dir, -45)
		))

	var/atom/pos = get_step(src, move_dir)

	//Failsafe
	if(!object.Adjacent(pos))
		return FALSE

	return Move(pos, move_dir)
