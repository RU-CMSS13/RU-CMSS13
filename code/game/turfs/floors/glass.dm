/turf/open/floor/glass
	name = "glass floor"
	desc = "Don't jump on it, or do, I'm not your mom."
	icon = 'icons/turf/floors/glass.dmi'
	icon_state = "glass-0"
	base_icon = "glass-0"
	special_icon = TRUE
	antipierce = 1
	baseturfs = /turf/open/openspace
	plating_type = null
	var/health = 100

/turf/open/floor/glass/Initialize(mapload)
	turf_flags |= TURF_TRANSPARENT
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/turf/open/floor/glass/LateInitialize()
	. = ..()
	handle_transpare_turf()

/turf/open/floor/glass/make_plating()
	playsound(src, "windowshatter", 50, 1)
	var/turf/below_turf = SSmapping.get_turf_below(src)
	if(!below_turf)
		below_turf = src
	var/obj/item/shard = new /obj/item/shard(below_turf)
	shard.explosion_throw(5, pick(GLOB.cardinals))
	shard = new /obj/item/shard(below_turf)
	shard.explosion_throw(5, pick(GLOB.cardinals))
	shard = new /obj/item/shard(below_turf)
	shard.explosion_throw(5, pick(GLOB.cardinals))
	shard = new /obj/item/stack/rods(below_turf)
	shard.explosion_throw(5, pick(GLOB.cardinals))
	ScrapeAway()

/turf/open/floor/glass/break_tile()
	make_plating()

/turf/open/floor/glass/on_turf_bullet_pass(obj/projectile/P)
	if(health < P.damage)
		make_plating()
	else
		health -= P.damage
	return

/turf/open/floor/glass/reinforced
	name = "reinforced glass floor"
	desc = "Do jump on it, it can take it."
	icon = 'icons/turf/floors/reinf_glass.dmi'
	icon_state = "reinf_glass-0"
	base_icon = "reinf_glass-0"
	health = 500
