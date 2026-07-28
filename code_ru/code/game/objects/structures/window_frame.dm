//Objects for LV624 Lazarus Landing - by Arom-beep

/obj/structure/window_frame
	name = "window frame"
	desc = "A big hole in the wall that used to sport a large window. Can be vaulted through"
	icon = 'code_ru/icons/turf/walls/window_frames.dmi'
	icon_state = "window0_frame"
	layer = WINDOW_FRAME_LAYER
	density = TRUE
	throwpass = TRUE
	climbable = 1 //Small enough to vault over, but you do need to vault over it
	health = 600
	projectile_coverage = PROJECTILE_COVERAGE_MEDIUM
	surgery_duration_multiplier = SURGERY_SURFACE_MULT_UNSUITED

/obj/structure/window_frame/wood
	icon_state = "wood_window0_frame"
	basestate = "wood_window"

/obj/structure/window_frame/wood/plain
	icon_state = "wood_plain_window0_frame"
	basestate = "wood_plain_window"

/obj/structure/window_frame/wood/blue
	icon_state = "wood_blue_window0_frame"
	basestate = "wood_blue_window"

/obj/structure/window_frame/wood/green
	icon_state = "wood_green_window0_frame"
	basestate = "wood_green_window"

/obj/structure/window_frame/wood/purple
	icon_state = "wood_purple_window0_frame"
	basestate = "wood_purple_window"

/obj/structure/window_frame/wood/teal
	icon_state = "wood_teal_window0_frame"
	basestate = "wood_teal_window"

/obj/structure/window_frame/lv_colony/reinforced
	reinforced = TRUE

