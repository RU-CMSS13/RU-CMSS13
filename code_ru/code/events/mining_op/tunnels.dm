#define TUNNELFALL_TRAIT "tunnelfall"

/area/
	var/list/obj/structure/tunnel/mineop/tunnels = list()

/mob/living/carbon/xenomorph
	var/point_worth = 1

/mob/living/carbon/xenomorph/drone
	point_worth = 1
/mob/living/carbon/xenomorph/sentinel
	point_worth = 1
/mob/living/carbon/xenomorph/runner
	point_worth = 4
/mob/living/carbon/xenomorph/defender
	point_worth = 4
/mob/living/carbon/xenomorph/lurker
	point_worth = 8
/mob/living/carbon/xenomorph/spitter
	point_worth = 8
/mob/living/carbon/xenomorph/warrior
	point_worth = 8
/mob/living/carbon/xenomorph/burrower
	point_worth = 8
/mob/living/carbon/xenomorph/despoiler
	point_worth = 8
/mob/living/carbon/xenomorph/ravager
	point_worth = 10
/mob/living/carbon/xenomorph/crusher
	point_worth = 10

/obj/effect/mineop/xeno_join
	name = "Ксеноджоин"
	icon = 'icons/landmarks.dmi'
	icon_state = "xeno_spawn"

	anchored = TRUE
	invisibility = INVISIBILITY_OBSERVER
	var/obj/structure/tunnel/mineop/connected_tunnel

	alpha = 0

/obj/effect/mineop/xeno_join/Initialize(mapload, ...)
	. = ..()
	animate(src, alpha = 255, pixel_y = 32, time = 3, easing = SINE_EASING | EASE_IN)

/obj/effect/mineop/xeno_join/attack_ghost(mob/dead/observer/user)
	connected_tunnel.try_spawning_xeno(user)

/obj/structure/tunnel/mineop
	health = 9000

	var/list/mob/living/carbon/xenomorph/basic_xeno_types = list(/mob/living/carbon/xenomorph/drone)
	var/list/mob/living/carbon/xenomorph/special_xeno_types = list()
	var/difficulty_category = 1
	var/unused_points = 0
	var/points_max = 0
	var/replenish_points_for = 0
	var/replenish_timeframe = 0
	var/restocking = FALSE
	var/crumbles = FALSE

	var/special_type_chance = 5

	var/obj/effect/mineop/xeno_join/button

/obj/structure/tunnel/mineop/Initialize(mapload, h_number)
	. = ..()

	var/area/A = get_area(src)
	A.tunnels += src

	var/list/ground_levels = SSmapping.levels_by_trait(ZTRAIT_GROUND)
	for(var/ground_z in ground_levels)
		for(var/turf/open/turf in Z_TURFS(ground_z))
			for(var/obj/effect/mineop/controller/C in turf)
				LAZYDISTINCTADD(C.tunnel_regions, A)

	button = new /obj/effect/mineop/xeno_join(get_turf(src))
	button.connected_tunnel = src

	animate(src, transform = matrix(rand(-3,3), rand(-3,3), MATRIX_TRANSLATE), time = 0.5, easing = EASE_IN)
	for(var/i in 0 to 10)
		animate(transform = matrix(rand(-4,4), rand(-4,4), MATRIX_TRANSLATE), time = 1)
	animate(transform = matrix(0, 0, MATRIX_TRANSLATE), time = 0.5, easing = EASE_OUT)

	var/turf/T = get_turf(src)
	for(var/mob/living/carbon/human/H in T)
		swallowed_by_the_pit(H)

	START_PROCESSING(SSobj, src)

/obj/structure/tunnel/mineop/process()
	if(unused_points <= 0 && !crumbles)
		if(replenish_points_for > 0 && !restocking)
			restocking = TRUE
			animate(button, alpha = 0, pixel_y = 0, time = 3, easing = SINE_EASING | EASE_OUT)
			addtimer(CALLBACK(src, PROC_REF(replenish_points)), replenish_timeframe)
		if(replenish_points_for <= 0)
			crumbles = TRUE
			destroy_the_tunnel()

/obj/structure/tunnel/mineop/proc/destroy_the_tunnel()
	animate(button, alpha = 0, pixel_y = 0, time = 3, easing = SINE_EASING | EASE_OUT)
	animate(src, transform = matrix(rand(-3,3), rand(-3,3), MATRIX_TRANSLATE), time = 0.5, easing = EASE_IN)
	for(var/i in 0 to 10)
		animate(transform = matrix(rand(-4,4), rand(-4,4), MATRIX_TRANSLATE), time = 1)
	animate(transform = matrix(0, 0, MATRIX_TRANSLATE), time = 0.5, easing = EASE_OUT)

	spawn(1 SECONDS)
		qdel(button)
		qdel(src)

/obj/structure/tunnel/mineop/proc/replenish_points()
	qdel(button)

	replenish_points_for -= 1
	unused_points = points_max
	restocking = FALSE

	button = new /obj/effect/mineop/xeno_join(get_turf(src))
	button.connected_tunnel = src

/obj/structure/tunnel/mineop/proc/swallowed_by_the_pit(mob/living/L)
	L.Stun(10)
	animate(L, transform = matrix(0.01, MATRIX_SCALE), time = 1 SECONDS, easing = BOUNCE_EASING)

	ADD_TRAIT(L, TRAIT_IMMOBILIZED, TUNNELFALL_TRAIT)
	ADD_TRAIT(L, TRAIT_UNDENSE, TUNNELFALL_TRAIT)
	addtimer(CALLBACK(src, PROC_REF(spit_out), L), 3 SECONDS)

/obj/structure/tunnel/mineop/proc/spit_out(mob/living/M)
	M.apply_damage(30, BRUTE)

	animate(M, transform = matrix(1, MATRIX_SCALE), time = 1 SECONDS, easing = SINE_EASING)
	M.throw_atom(get_step(src, pick(GLOB.cardinals)), 3, 3, src, TRUE)

	REMOVE_TRAIT(M, TRAIT_IMMOBILIZED, TUNNELFALL_TRAIT)
	REMOVE_TRAIT(M, TRAIT_UNDENSE, TUNNELFALL_TRAIT)

/obj/structure/tunnel/mineop/proc/try_spawning_xeno(mob/dead/observer/candidate)
	if(unused_points <= 0)
		return FALSE

	var/special_one = FALSE
	var/list/pool = list()
	for(var/mob/living/carbon/xenomorph/X as anything in basic_xeno_types)
		if(X.point_worth <= unused_points)
			pool += X.caste_type

	if(prob(special_type_chance) && length(special_xeno_types)) // гарант того, что кликнувшему выпадет какой-то жирнич
		pool.Cut()
		for(var/mob/living/carbon/xenomorph/X as anything in special_xeno_types)
			pool += X.caste_type
		special_type_chance = initial(special_type_chance)
		special_one = TRUE

	var/randomspawn = pick(pool)
	var/xeno_type = GLOB.RoleAuthority.get_caste_by_text(randomspawn)

	var/mob/living/carbon/xenomorph/X = new xeno_type(get_turf(src))
	candidate.mind.transfer_to(X, TRUE)
	unused_points -= X.point_worth
	if(!special_one)
		special_type_chance += 5
	X.generate_name()

	msg_admin_niche("[key_name(X)] has joined as a lesser drone at ([x],[y],[z]).")

/obj/structure/tunnel/mineop/testing
	basic_xeno_types = list(/mob/living/carbon/xenomorph/drone, /mob/living/carbon/xenomorph/runner, /mob/living/carbon/xenomorph/sentinel)
	special_xeno_types = list(/mob/living/carbon/xenomorph/warrior, /mob/living/carbon/xenomorph/lurker)
	unused_points = 50
	points_max = 50
	replenish_points_for = 2
	replenish_timeframe = 5 SECONDS

/obj/structure/tunnel/mineop/stage_1

	basic_xeno_types = list(/mob/living/carbon/xenomorph/drone,
							/mob/living/carbon/xenomorph/drone,
							/mob/living/carbon/xenomorph/drone,
							/mob/living/carbon/xenomorph/drone,
							/mob/living/carbon/xenomorph/runner,
							/mob/living/carbon/xenomorph/sentinel)
	special_xeno_types = list(/mob/living/carbon/xenomorph/lurker, /mob/living/carbon/xenomorph/spitter, /mob/living/carbon/xenomorph/spitter)

	points_max = 35
	unused_points = 35

/obj/structure/tunnel/mineop/stage_2

	basic_xeno_types = list(/mob/living/carbon/xenomorph/drone,
							/mob/living/carbon/xenomorph/drone,
							/mob/living/carbon/xenomorph/defender,
							/mob/living/carbon/xenomorph/defender,
							/mob/living/carbon/xenomorph/runner,
							/mob/living/carbon/xenomorph/spitter)
	special_xeno_types = list(/mob/living/carbon/xenomorph/lurker, /mob/living/carbon/xenomorph/burrower, /mob/living/carbon/xenomorph/burrower, /mob/living/carbon/xenomorph/warrior)

	special_type_chance = 15

/obj/structure/tunnel/mineop/stage_2/Initialize(mapload, h_number)
	. = ..()
	points_max = rand(20,30)
	unused_points = points_max

	replenish_points_for = rand(0,1)
	if(replenish_points_for > 0)
		replenish_timeframe = 10 SECONDS

/obj/structure/tunnel/mineop/stage_3

	basic_xeno_types = list(/mob/living/carbon/xenomorph/drone,
							/mob/living/carbon/xenomorph/drone,
							/mob/living/carbon/xenomorph/spitter,
							/mob/living/carbon/xenomorph/spitter,
							/mob/living/carbon/xenomorph/defender,
							/mob/living/carbon/xenomorph/defender,
							/mob/living/carbon/xenomorph/lurker,
							/mob/living/carbon/xenomorph/burrower,
							/mob/living/carbon/xenomorph/warrior)
	special_xeno_types = list(/mob/living/carbon/xenomorph/ravager, /mob/living/carbon/xenomorph/ravager, /mob/living/carbon/xenomorph/crusher)

	special_type_chance = 15

/obj/structure/tunnel/mineop/stage_3/Initialize(mapload, h_number)
	. = ..()
	points_max = points_max = rand(20,30)
	unused_points = points_max

	replenish_points_for = rand(0,1)
	if(replenish_points_for > 0)
		replenish_timeframe = 30 SECONDS

/obj/structure/tunnel/mineop/stage_4

	basic_xeno_types = list(/mob/living/carbon/xenomorph/drone,
							/mob/living/carbon/xenomorph/spitter,
							/mob/living/carbon/xenomorph/spitter,
							/mob/living/carbon/xenomorph/defender,
							/mob/living/carbon/xenomorph/defender,
							/mob/living/carbon/xenomorph/warrior,
							/mob/living/carbon/xenomorph/warrior,
							/mob/living/carbon/xenomorph/ravager)
	special_xeno_types = list(/mob/living/carbon/xenomorph/crusher, /mob/living/carbon/xenomorph/despoiler, /mob/living/carbon/xenomorph/despoiler)

	special_type_chance = 30
	points_max = 20
	unused_points = 20
	replenish_timeframe = 30 SECONDS

/obj/structure/tunnel/mineop/stage_4/Initialize(mapload, h_number)
	. = ..()

	replenish_points_for = rand(1,3)
