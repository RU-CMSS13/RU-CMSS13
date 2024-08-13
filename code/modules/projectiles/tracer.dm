/atom/movable/hitscan_projectile_effect
	name = "pew"
	icon = 'icons/obj/items/weapons/projectiles.dmi'
	icon_state = "redtracer"
	layer = ABOVE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = NONE
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 0.2
	alpha = 125

/atom/movable/hitscan_projectile_effect/Initialize(mapload, angle_override, p_x, p_y, scaling = 1, effect_icon, laser_color)
	. = ..()
	set_light_color(laser_color)
	set_light_on(TRUE)
	if(effect_icon)
		icon_state = effect_icon
	pixel_x = p_x
	pixel_y = p_y
	var/matrix/M = transform
	M.Turn(angle_override)
	M.Scale(1, scaling)
	transform = M

/atom/movable/hitscan_projectile_effect/ex_act()
	return FALSE

/atom/movable/hitscan_projectile_effect/throw_atom()
	return FALSE

///Signal handler to delete this effect
/atom/movable/hitscan_projectile_effect/proc/remove_effect()
	SIGNAL_HANDLER
	animate(src, alpha = 0, time = 4 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(qdel), src), 4 SECONDS)
