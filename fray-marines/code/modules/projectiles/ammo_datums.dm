/datum/ammo/flamethrower/tank_flamer/buffed/drop_flame(turf/T, datum/cause_data/cause_data)
	if(!istype(T)) return
	var/datum/reagent/napalm/blue/B = new()
	new /obj/flamer_fire(T, cause_data, B, 1)

/*
//======
					Xeno Spits
//======
*/

/datum/ammo/xeno/sticky/strong
	name = "sticky resin spatter"
	effect_time = 5 SECONDS
	resin_type = /obj/effect/alien/resin/sticky
	max_range = 6

/datum/ammo/xeno/sticky/strong/on_hit_mob(mob/M,obj/projectile/P)
	. =	..()

	if(!isxeno(M))
		M.AdjustStun(1)

/datum/ammo/xeno/sticky/heal
	name = "living resin spit"
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_IGNORE_XENO_IFF
	added_spit_delay = 0
	spit_cost = 40

	effect_time = 1 SECONDS
	resin_type = null

	var/heal_range = 0
	var/heal_amount = 30
	var/shield_decay = 5
	var/shield_duration = 15 SECONDS

/datum/ammo/xeno/sticky/heal/on_hit_mob(mob/M,obj/projectile/P)
	heal_xeno_range(get_turf(M), P)
	..()

/datum/ammo/xeno/sticky/heal/on_hit_obj(obj/O,obj/projectile/P)
	heal_xeno_range(get_turf(O), P)

/datum/ammo/xeno/sticky/heal/on_hit_turf(turf/T,obj/projectile/P)
	var/turf/center = T.density && heal_range ? get_step(T,reverse_dir[P.dir]) : T
	heal_xeno_range(center, P)

/datum/ammo/xeno/sticky/heal/do_at_max_range(obj/projectile/P)
	heal_xeno_range(get_turf(P), P)

/datum/ammo/xeno/sticky/heal/proc/heal_xeno_range(turf/center, obj/projectile/P)
	for(var/mob/living/carbon/xenomorph/buddy in range(heal_range,center))
		if(buddy == P.firer)
			continue

		to_chat(buddy, SPAN_XENOHIGHDANGER("You are healed by [P.firer]!"))
		buddy.visible_message(SPAN_BOLDNOTICE("[P] quickly wraps around [buddy], sealing some of its wounds!"))
		buddy.add_xeno_shield(heal_amount/2, XENO_SHIELD_SOURCE_SPITTER_SUPRESSOR, duration = shield_duration, decay_amount_per_second = shield_decay)
		buddy.gain_health(heal_amount)
		buddy.xeno_jitter(1 SECONDS)
		buddy.flick_heal_overlay(2 SECONDS, "#FFA800") //D9F500

/datum/ammo/xeno/sticky/heal/strong
	name = "living resin spatter"
	effect_time = 1.5 SECONDS
	heal_amount = 120
	heal_range = 1
	max_range = 6
