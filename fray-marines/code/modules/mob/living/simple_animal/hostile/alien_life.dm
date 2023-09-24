/mob/living/simple_animal/hostile/alien/spawnable/Life(delta_time)
	//Health
	if(stat == DEAD)
		if(health > 0)
			icon_state = icon_living
			GLOB.dead_mob_list -= src
			GLOB.alive_mob_list += src
			set_stat(CONSCIOUS)
			lying = 0
			density = TRUE
			reload_fullscreens()
		return 0

	if(health < 1)
		death()

	if(health > maxHealth)
		health = maxHealth

	handle_stunned()
	handle_knocked_down(TRUE)
	handle_knocked_out(TRUE)
	update_canmove()

	return 1

/mob/living/simple_animal/hostile/alien/spawnable/proc/process_ai(wait, game_evaluation)
	SHOULD_NOT_SLEEP(TRUE)

	if(!stat && canmove)
		switch(stance)
			if(HOSTILE_STANCE_IDLE)
				idle_stance()

			if(HOSTILE_STANCE_ATTACK)
				attack_stance()

			if(HOSTILE_STANCE_ATTACKING)
				attacking_stance()

/mob/living/simple_animal/hostile/alien/spawnable/proc/idle_stance()
	target_mob = FindTarget()

	if (stance != HOSTILE_STANCE_IDLE)
		return

	if(!client && !stop_automated_movement && wander && !anchored)
		if(isturf(src.loc) && !resting && !buckled && canmove) //This is so it only moves if it's not inside a closet, gentics machine, etc.
			turns_since_move++
			if(turns_since_move >= turns_per_move)
				if(!(stop_automated_movement_when_pulled && pulledby)) //Soma animals don't move when pulled
					var/move_dir = 0

					for (var/picked_dir in cardinal)
						var/turf/step = get_step(src.loc, picked_dir)

						if (!(locate(/obj/flamer_fire) in get_turf(step)))
							move_dir = get_dir(src.loc, step)
							break

					if (move_dir != 0)
						move_dir = pick(cardinal)
						Move(get_step(src, move_dir ))
						setDir(move_dir)
						turns_since_move = 0

/mob/living/simple_animal/hostile/alien/spawnable/proc/attack_stance()
	if(destroy_surroundings && can_attack)
		can_attack = FALSE
		addtimer(CALLBACK(src, PROC_REF(allow_attack)), attack_cooldown)
		DestroySurroundings()
	MoveToTarget()

/mob/living/simple_animal/hostile/alien/spawnable/proc/attacking_stance()
	if(!AttackTarget() && destroy_surroundings && can_attack)
		can_attack = FALSE
		addtimer(CALLBACK(src, PROC_REF(allow_attack)), attack_cooldown)
		DestroySurroundings()
