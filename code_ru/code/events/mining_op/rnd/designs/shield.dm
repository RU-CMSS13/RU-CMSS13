/obj/structure/mineop/rnd/energy_shield
	name = "Энерго-щит"
	desc = "Капсуль, создающий временное силовое поле при детонации. Позволяет стрелять изнутри."

	buycost = 30
	tech_id = "shield"

/obj/structure/mineop/design/energy_shield
	name = "Энерго-щит"
	desc = "Капсуль, создающий временное силовое поле при детонации. Позволяет стрелять изнутри."

	icon_state = "shield"

	buycost = 40
	buildtime = 5 SECONDS

	type_to_create = /obj/item/explosive/grenade/mineop/shield
	design_id = "shield"

/obj/item/explosive/grenade/mineop/shield
	name = "shield generator"
	desc = "Used as a support Tool for the Gunner. It is a hand-held, disc shaped projector device that creates a forcefield."
	icon = 'icons/obj/items/weapons/grenade.dmi'
	icon_state = "delivery"
	item_state = "delivery"
	antigrief_protection = FALSE
	explo_proof = TRUE
	unacidable = TRUE
	dangerous = TRUE
	harmful = FALSE
	det_time = 40

	light_color = "#74e696"
	light_power = 3

	var/obj/effect/mineop/shield/VSX
	var/blocker_type = /obj/structure/blocker/mineop/shield
	var/field_duration = 30 SECONDS
	var/field_radius = 3

/obj/item/explosive/grenade/mineop/shield/prime(force)
	overlays.Cut()
	if(isliving(loc))
		var/mob/living/L = loc
		L.drop_inv_item_on_ground(src)

	playsound(loc, 'sound/mecha/powerup.ogg', 50)
	anchored = TRUE

	var/list/box = RANGE_TURFS(field_radius, src)
	for(var/turf/T as anything in box)
		if(get_dist(T, src) < field_radius)
			continue

		var/angle = Get_Angle(loc, T)
		var/relative_direction = get_dir_p_cardinals(angle)

		var/additional_dir
		switch(relative_direction)
			if (NORTHEAST)
				additional_dir = NORTH
				relative_direction = EAST
			if (SOUTHEAST)
				additional_dir = SOUTH
				relative_direction = EAST
			if (SOUTHWEST)
				additional_dir = SOUTH
				relative_direction = WEST
			if (NORTHWEST)
				additional_dir = NORTH
				relative_direction = WEST

		new blocker_type(T, src, relative_direction)

		if(!additional_dir)
			continue

		new blocker_type(T, src, additional_dir)

	spawn(field_radius * 2)
		set_light_range(field_radius+2)
		set_light_on(TRUE)

	VSX = new /obj/effect/mineop/shield(loc, field_radius, SINE_EASING|EASE_OUT, pixel_y, pixel_x)

	addtimer(CALLBACK(src, PROC_REF(remove_shield)), field_duration)

/obj/item/explosive/grenade/mineop/shield/proc/remove_shield()
	playsound(loc, 'sound/effects/corsat_teleporter.ogg', 150)
	icon_state = initial(icon_state)
	spawn(4.5 SECONDS)
		QDEL_IN(src, field_radius * 2 - 1)
		VSX.disappear(field_radius)

/obj/structure/blocker/mineop/shield
	name = "shield"
	icon = 'icons/obj/structures/barricades.dmi'
	icon_state = "folding_0" // for map editing only
	flags_atom = ON_BORDER
	invisibility = INVISIBILITY_MAXIMUM
	throwpass = TRUE
	density = TRUE
	var/obj/item/explosive/grenade/mineop/shield/linked_shield

/obj/structure/blocker/mineop/shield/Initialize(mapload, atom/generator, set_dir)
	. = ..()
	RegisterSignal(generator, COMSIG_PARENT_QDELETING, PROC_REF(collapse))
	linked_shield = generator
	icon_state = null
	dir = set_dir

/obj/structure/blocker/mineop/shield/Destroy(force)
	. = ..()
	linked_shield = null

/obj/structure/blocker/mineop/shield/proc/collapse()
	SIGNAL_HANDLER
	qdel(src)

/obj/structure/blocker/mineop/shield/initialize_pass_flags(datum/pass_flags_container/PF)
	..()
	if (PF)
		PF.flags_can_pass_front = PASS_MOB_IS_HUMAN
		PF.flags_can_pass_behind = PASS_ALL

/obj/structure/blocker/mineop/shield/get_projectile_hit_boolean(obj/projectile/P)
	var/is_reversed = (dir in reverse_nearby_direction(P.dir))
	if(!is_reversed)
		return FALSE

	loc.bullet_ping(P)
	return TRUE

/obj/structure/blocker/mineop/shield/get_explosion_resistance()
	return 9999

/*
/obj/structure/blocker/shield/xeno_ai_obstacle()
	return 0
*/

/obj/effect/mineop/shield
	icon = 'icons/effects/light_overlays/shockwave.dmi'
	icon_state = "shockwave"
	plane = DISPLACEMENT_PLATE_RENDER_LAYER
	pixel_x = -496
	pixel_y = -496

/obj/effect/mineop/shield/Initialize(mapload, radius = 3, easing_type = SINE_EASING|EASE_OUT, y_offset, x_offset)
	. = ..()
	if(y_offset)
		pixel_y += y_offset
	if(x_offset)
		pixel_x += x_offset
	transform = matrix().Scale(32 / 1024, 32 / 1024)
	animate(src, time = radius * 2, transform=matrix().Scale((32 / 1024) * (radius + 3.5)), easing = easing_type)

/obj/effect/mineop/shield/proc/disappear(radius = 3, easing_type = SINE_EASING|EASE_OUT)
	animate(src, time = radius * 2, transform=matrix().Scale((32 / 1024) * 0.3), easing = easing_type)
	QDEL_IN(src, radius * 2)
	set_light_on(FALSE)

/proc/get_dir_p_cardinals(angle)
	switch(angle)
		if (45)
			return NORTHEAST
		if (135)
			return SOUTHEAST
		if (225)
			return SOUTHWEST
		if (315)
			return NORTHWEST
		if (0 to 44)
			return NORTH
		if (46 to 134)
			return EAST
		if (136 to 224)
			return SOUTH
		if (226 to 314)
			return WEST
		else
			return NORTH
