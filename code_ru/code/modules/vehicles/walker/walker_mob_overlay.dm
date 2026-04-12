/obj/vehicle/walker
	var/atom/movable/vis_obj/walker_mob_adder/mob_overplay


/atom/movable/vis_obj/walker_mob_adder
	pixel_x = 16
	pixel_y = 22

	var/pixel_x_side_offset = 12
	var/pixel_x_offset = 16

	vis_flags = VIS_INHERIT_DIR|VIS_INHERIT_PLANE|VIS_INHERIT_LAYER|VIS_INHERIT_ID
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	var/atom/movable/vis_obj/walker_mob_cutter/mob_overplay_cutter

/atom/movable/vis_obj/walker_mob_adder/Initialize(mapload, ...)
	. = ..()

	mob_overplay_cutter = new

/atom/movable/vis_obj/walker_mob_adder/proc/on_dir_change(new_dir)
	pixel_x = pixel_x_offset
	switch(new_dir)
		if(WEST)
			pixel_x -= pixel_x_side_offset
		if(EAST)
			pixel_x += pixel_x_side_offset
	mob_overplay_cutter.dir = new_dir

/atom/movable/vis_obj/walker_mob_adder/proc/update_mob(mob/affected_mob, action)
	if(action)
		affected_mob.add_filter("walker_mob_render", 1, alpha_mask_filter(render_source = mob_overplay_cutter.render_target))
		affected_mob.vis_flags |= VIS_INHERIT_DIR|VIS_INHERIT_LAYER|VIS_INHERIT_ID
		vis_contents += mob_overplay_cutter
		vis_contents += affected_mob
	else
		vis_contents -= affected_mob
		vis_contents -= mob_overplay_cutter
		affected_mob.vis_flags &= ~(VIS_INHERIT_DIR|VIS_INHERIT_LAYER|VIS_INHERIT_ID)
		affected_mob.remove_filter("walker_mob_render")


/atom/movable/vis_obj/walker_mob_cutter
	icon = 'code_ru/icons/obj/vehicles/overlay_cutter.dmi'
	icon_state = "icon_cutter"

/atom/movable/vis_obj/walker_mob_cutter/Initialize(mapload, ...)
	. = ..()

	render_target = "*[ref(src)]"
