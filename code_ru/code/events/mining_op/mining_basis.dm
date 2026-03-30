// моб релейтед стафф //

/obj/effect/temp_visual/digging_swing
	duration = 0.6 SECONDS
	icon = 'code_ru/code/events/mining_op/hit_effect.dmi'
	icon_state = "slash"
	layer = 4.5

/obj/effect/temp_visual/digging_spark
	duration = 0.6 SECONDS
	icon = 'code_ru/code/events/mining_op/hit_effect.dmi'
	icon_state = "block"
	layer = 4.5

/mob/living/proc/cool_attack_on(atom/A, pixel_offset = 8)
	animation_flash_color(A, "#ffbb00")
	SEND_SIGNAL(src, COMSIG_MOB_ANIMATING)

	var/obj/effect/temp_visual/digging_swing/D = new /obj/effect/temp_visual/digging_swing(get_turf(src))
	D.dir = dir

	if(A.clone)
		if(src.Adjacent(A.clone))
			A = A.clone
	if(buckled || anchored || HAS_TRAIT(src, TRAIT_HAULED)) //it would look silly.
		return
	var/pixel_x_diff = 0
	var/pixel_y_diff = 0
	var/angle_diff = 0
	var/direction = get_dir(src, get_turf(A))
	pixel_offset = floor(pixel_offset) // Just to be safe

	if(QDELETED(A))
		direction = dir

	switch(direction)
		if(NORTH)
			pixel_y_diff = pixel_offset
			angle_diff = 30

			D.pixel_y = 25

		if(SOUTH)
			pixel_y_diff = -pixel_offset
			angle_diff = -30

			D.pixel_y = -25

		if(EAST)
			pixel_x_diff = pixel_offset
			angle_diff = 30

			D.pixel_x = 25

		if(WEST)
			pixel_x_diff = -pixel_offset
			angle_diff = -30

			D.pixel_x = -25

		if(NORTHEAST)
			pixel_x_diff = pixel_offset
			pixel_y_diff = pixel_offset
			angle_diff = 30

			D.pixel_y = 25
			D.pixel_x = 25

		if(NORTHWEST)
			pixel_x_diff = -pixel_offset
			pixel_y_diff = pixel_offset
			angle_diff = -30

			D.pixel_y = 25
			D.pixel_x = -25

		if(SOUTHEAST)
			pixel_x_diff = pixel_offset
			pixel_y_diff = -pixel_offset
			angle_diff = 30

			D.pixel_y = -25
			D.pixel_x = 25

		if(SOUTHWEST)
			pixel_x_diff = -pixel_offset
			pixel_y_diff = -pixel_offset
			angle_diff = -30

			D.pixel_y = -25
			D.pixel_x = -25

	animate(src, transform = matrix(angle_diff, MATRIX_ROTATE), pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff, time = 0.2 SECONDS, easing = SINE_EASING)
	animate(transform = matrix(0, MATRIX_ROTATE), pixel_x = initial(pixel_x), pixel_y = initial(pixel_y), time = 0.1 SECONDS)

// порода //
#define HEALTH_ROCK 600
#define HEALTH_SOFT_ROCK 200

/turf/closed/wall/mineop/destructable_rock
	name = "hard surface"
	desc = "Dense rock, which can only be cleared by special tools or heavy fireforce."
	icon = 'code_ru/code/events/mining_op/rocks.dmi'
	icon_state = "rocktable"
	special_icon = TRUE
	var/icon_prefix = "rock"

	color = "#a78772"
	damage_cap = HEALTH_ROCK
	repair_materials = list()

	var/dig_health = 50 // как быстро он сломается НОРМАЛЬНЫМ путём
	var/mineral_drop = null // что выпадет из него если в принципе должно

	var/mining_sound = 'sound/soundscape/rocksfalling2.ogg'

	var/floor_types = list(/turf/open/auto_turf/sand_white/layer0, /turf/open/auto_turf/sand_white/layer1)

/turf/closed/wall/mineop/destructable_rock/dismantle_wall(devastated, explode)
	if(mining_sound)
		playsound(get_turf(src), mining_sound, 100, 1)

	if(mineral_drop)
		new mineral_drop(get_turf(src))

	ChangeTurf(pick(floor_types))
	. = ..()

/turf/closed/wall/mineop/destructable_rock/Destroy(force)
	. = ..()

	var/list/turfs_around = orange(src, 1)
	for(var/turf/closed/wall/W in turfs_around)
		if(!can_join_with(W))
			continue
		addtimer(CALLBACK(W, PROC_REF(update_icon)), rand(1,3))

/turf/closed/wall/mineop/destructable_rock/attackby(obj/item/W, mob/living/user)
	if(isxeno(user) && istype(W, /obj/item/grab))
		var/obj/item/grab/attacker_grab = W
		var/mob/living/carbon/xenomorph/user_as_xenomorph = user
		user_as_xenomorph.do_nesting_host(attacker_grab.grabbed_thing, src)
		return

	if(W.digging_tool)
		if(W.not_ready_for_digging)
			W.balloon_alert(W, "*on cooldown*", "#ffbb00")
			return

		var/list/random_sound = list('code_ru/code/events/mining_op/drg/standart_pickaxe_1.ogg', 'code_ru/code/events/mining_op/drg/standart_pickaxe_2.ogg')

		W.not_ready_for_digging = TRUE
		addtimer(CALLBACK(W, TYPE_PROC_REF(/obj/item, reset_mining_delay)), W.digging_speed, TIMER_UNIQUE)

		playsound(src, pick(random_sound), 25, 1)
		var/obj/effect/temp_visual/digging_spark/D = new /obj/effect/temp_visual/digging_spark(get_turf(src))
		D.pixel_x = rand(-10, 10)
		D.pixel_y = rand(-10, 10)

		dig_health -= W.digging_power
		user.cool_attack_on(src)

		if(dig_health <= 0)
			dismantle_wall()

		return

	return attack_hand(user)

/turf/closed/wall/mineop/destructable_rock/attack_alien(mob/living/carbon/xenomorph/user)
	if(acided_hole && user.mob_size >= MOB_SIZE_BIG)
		acided_hole.expand_hole(user) //This proc applies the attack delay itself.
		return XENO_NO_DELAY_ACTION

	if(!(turf_flags & TURF_HULL) && user.claw_type >= CLAW_TYPE_NORMAL && !acided_hole && user.a_intent == INTENT_HARM)
		user.animation_attack_on(src)
		playsound(src, 'sound/effects/metalhit.ogg', 25, 1)
		take_damage(damage_cap / XENO_HITS_TO_DESTROY_WALL)

		dig_health -= 10

		if(dig_health <= 0)
			dismantle_wall()

		return XENO_ATTACK_ACTION

/turf/closed/wall/mineop/destructable_rock/take_damage(dam, mob/M)
	. = ..()
	animation_flash_color(src, "#ff0000")

/turf/closed/wall/mineop/destructable_rock/make_girder()
	return

// супердупер старый код, чтобы можно было спокойно юзать спрайты стен с тгмц и тг(фактически за основу взят код столов)
/turf/closed/wall/mineop/destructable_rock/update_icon()
	. = ..()

	var/dir_sum = 0
	for(var/direction in CARDINAL_ALL_DIRS)
		var/turf/closed/wall/W = get_step(src, direction)
		if(!istype(W))
			continue
		if(direction < 5)
			dir_sum += direction
		else
			if(direction == 5)
				dir_sum += 16
			if(direction == 6)
				dir_sum += 32
			if(direction == 8)
				dir_sum += 8
			if(direction == 10)
				dir_sum += 64
			if(direction == 9)
				dir_sum += 128

	var/table_type = 0
	if((dir_sum%16) in GLOB.cardinals)
		table_type = 1
		dir_sum %= 16
	if((dir_sum%16) in list(3, 12))
		table_type = 2
		if(dir_sum%16 == 3)
			dir_sum = 2
		if(dir_sum%16 == 12)
			dir_sum = 4
	if((dir_sum%16) in list(5, 6, 9, 10))
		if(istype(get_step(src, dir_sum%16), /turf/closed/wall))
			table_type = 3
		else
			table_type = 2
		dir_sum %= 16
	if((dir_sum%16) in list(13, 14, 7, 11))
		table_type = 5
		switch(dir_sum%16)
			if(7)
				if(dir_sum == 23)
					table_type = 6
					dir_sum = 8
				else if(dir_sum == 39)
					dir_sum = 4
					table_type = 6
				else if(dir_sum == 55 || dir_sum == 119 || dir_sum == 247 || dir_sum == 183)
					dir_sum = 4
					table_type = 3
				else
					dir_sum = 4
			if(11)
				if(dir_sum == 75)
					dir_sum = 5
					table_type = 6
				else if(dir_sum == 139)
					dir_sum = 9
					table_type = 6
				else if(dir_sum == 203 || dir_sum == 219 || dir_sum == 251 || dir_sum == 235)
					dir_sum = 8
					table_type = 3
				else
					dir_sum = 8
			if(13)
				if(dir_sum == 29)
					dir_sum = 10
					table_type = 6
				else if(dir_sum == 141)
					dir_sum = 6
					table_type = 6
				else if(dir_sum == 189 || dir_sum == 221 || dir_sum == 253 || dir_sum == 157)
					dir_sum = 1
					table_type = 3
				else
					dir_sum = 1
			if(14)
				if(dir_sum == 46)
					dir_sum = 1
					table_type = 6
				else if(dir_sum == 78)
					dir_sum = 2
					table_type = 6
				else if(dir_sum == 110 || dir_sum == 254 || dir_sum == 238 || dir_sum == 126)
					dir_sum = 2
					table_type = 3
				else
					dir_sum = 2
	if(dir_sum%16 == 15)
		table_type = 4

	switch(table_type)
		if(0)
			icon_state = "[icon_prefix]table"
		if(1)
			icon_state = "[icon_prefix]1tileendtable"
		if(2)
			icon_state = "[icon_prefix]1tilethick"
		if(3)
			icon_state = "[icon_prefix]tabledir"
		if(4)
			icon_state = "[icon_prefix]middle"
		if(5)
			icon_state = "[icon_prefix]tabledir2"
		if(6)
			icon_state = "[icon_prefix]tabledir3"

	if(dir_sum in CARDINAL_ALL_DIRS)
		dir = dir_sum
	else
		dir = SOUTH

/obj/structure/mineop/minerals
	name = "land ore"
	desc = "Crystal rocks, growing from the floor, walls, and even from cave roof."
	icon = 'code_ru/code/events/mining_op/gray_crystal.dmi'
	icon_state = "crystal_stage1"
	anchored = TRUE
	density = TRUE

	health = STRUCTURE_HEALTH_REINFORCED
	projectile_coverage = PROJECTILE_COVERAGE_LOW

	light_power = 4
	light_range = 1
	light_on = TRUE

	var/mineral_amount = 3
	var/current_minerals

	var/mineral_drop = null
	var/mining_sound

/obj/structure/mineop/minerals/Initialize()
	. = ..()
	current_minerals = rand(1, mineral_amount)
	update_icon()

/obj/structure/mineop/minerals/update_icon()
	. = ..()
	var/stage
	if(current_minerals > mineral_amount * 0.66)
		stage = 3
	else if(current_minerals > mineral_amount * 0.33)
		stage = 2
	else
		stage = 1

	icon_state = "crystal_stage[stage]"

/obj/structure/mineop/minerals/attackby(obj/item/W, mob/living/user, click_data)
	if(user.action_busy)
		return

	if(!W.digging_tool)
		return

	if(W.not_ready_for_digging)
		W.balloon_alert(W, "*on cooldown*", "#ffbb00")
		return

	var/list/random_sound = list('code_ru/code/events/mining_op/drg/standart_pickaxe_1.ogg', 'code_ru/code/events/mining_op/drg/standart_pickaxe_2.ogg')
	W.not_ready_for_digging = TRUE
	addtimer(CALLBACK(W, TYPE_PROC_REF(/obj/item, reset_mining_delay)), W.digging_speed, TIMER_UNIQUE)

	playsound(src, pick(random_sound), 25, 1)
	var/obj/effect/temp_visual/digging_spark/D = new /obj/effect/temp_visual/digging_spark(get_turf(src))
	D.pixel_x = rand(-10, 10)
	D.pixel_y = rand(-10, 10)

	user.cool_attack_on(src)

	if(mining_sound)
		playsound(loc, mining_sound, 25, 1)

	current_minerals--
	if(mineral_drop)
		new mineral_drop(get_turf(src))

	if(!current_minerals)
		balloon_alert_to_viewers("*[src] crumbles to dust*")
		QDEL_NULL(src)
		return TRUE

	update_icon()
	return TRUE

/obj/item
	var/digging_tool = FALSE // МОЖНО ЛИ ПРЕДМЕТОМ КОПАТЬ
	var/digging_power = 0 // СКОЛЬКО ОН СНОСИТ ХП КАМНЮ ЗА КЛИК
	var/digging_speed = 0.5 SECONDS // КАК БЫСТРО ПРЕДМЕТ МОЖЕТ КОПАТЬ (чем больше цифра - тем медленней)
	var/not_ready_for_digging = FALSE

/obj/item/proc/reset_mining_delay()
	not_ready_for_digging = FALSE

// подтипы //

/turf/closed/wall/mineop/destructable_rock/soft
	name = "soft soil"
	desc = "Much easier to dig."
	icon_state = "dirttable"
	icon_prefix = "dirt"

	damage_cap = HEALTH_SOFT_ROCK
	dig_health = 20
