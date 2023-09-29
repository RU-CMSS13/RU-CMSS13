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
		if (isturf(src.loc) && !resting && !buckled)
			turns_since_move++

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

	if(!client && !anchored)
		if(turns_since_move >= turns_per_move)
			if(!(stop_automated_movement_when_pulled && pulledby)) //Soma animals don't move when pulled
				var/move_dir = 0
				var/list/shuffled_cardinals = shuffle(cardinal.Copy())

				for (var/picked_dir in shuffled_cardinals)
					var/turf/step = get_step(src.loc, picked_dir)

					if (!(locate(/obj/flamer_fire) in get_turf(step)) && !step.density)
						move_dir = get_dir(src.loc, step)
						break

				if (move_dir != 0)
					Move(get_step(src, move_dir))
					setDir(move_dir)

/mob/living/simple_animal/hostile/alien/spawnable/proc/attack_stance()
	if(destroy_surroundings && can_attack)
		DestroySurroundings()
	MoveToTarget()

/mob/living/simple_animal/hostile/alien/spawnable/MoveToTarget()
	stop_automated_movement = 1
	if(!target_mob || SA_attackable(target_mob))
		stance = HOSTILE_STANCE_IDLE
	if(target_mob in ListTargets(10))
		if (Adjacent(target_mob))
			stance = HOSTILE_STANCE_ATTACKING
			return

		if (turns_since_move >= move_to_delay)
			var/move_dir = get_cardinal_dir(src, target_mob)
			Move(get_step(src, move_dir), move_dir)
	else
		stance = HOSTILE_STANCE_IDLE
		// Найти ещё жертву!
		target_mob = FindTarget()

/mob/living/simple_animal/hostile/alien/spawnable/proc/attacking_stance()
	if(!AttackTarget() && destroy_surroundings && can_attack)
		DestroySurroundings()

/mob/living/simple_animal/hostile/alien/spawnable/AttackTarget()
	stop_automated_movement = 1
	if(!target_mob || SA_attackable(target_mob) || target_mob.pulledby && isxeno(target_mob.pulledby) || target_mob.alpha < 50)
		LoseTarget()
		return 0
	if(!(target_mob in ListTargets(10)))
		LostTarget()
		return 0
	if(get_dist(src, target_mob) <= 1) //Attacking
		AttackingTarget()
		return 1
	else
		stance = HOSTILE_STANCE_ATTACK
		return 1

/mob/living/simple_animal/hostile/alien/spawnable/DestroySurroundings()
	can_attack = FALSE
	addtimer(CALLBACK(src, PROC_REF(allow_attack)), attack_cooldown)
	. = ..()
