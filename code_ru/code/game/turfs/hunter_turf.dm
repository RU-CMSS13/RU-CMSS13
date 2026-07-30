//Turf for LV624 Lazarus Landing - by Arom-beep
// Waterfall

/turf/open/auto_turf/waterfall
	icon = 'code_ru/icons/turf/waterfall_test.dmi'
	icon_state = "waterfall_top"
	can_bloody = FALSE
	fishing_allowed = FALSE
	supports_surgery = FALSE
	minimap_color = MINIMAP_WATER
	is_groundmap_turf = TRUE

/turf/open/auto_turf/waterfall/insert_self_into_baseturfs()
	baseturfs += /turf/open/auto_turf/waterfall/top

/turf/open/auto_turf/waterfall/top
	icon_state = "waterfall_top"

/turf/open/auto_turf/waterfall/top/one
	icon_state = "waterfall_top_1"

/turf/open/auto_turf/waterfall/top/two
	icon_state = "waterfall_top_2"

/turf/open/auto_turf/waterfall/center
	icon_state = "waterfall_center"

/turf/open/auto_turf/waterfall/center/one
	icon_state = "waterfall_center_1"

/turf/open/auto_turf/waterfall/center/two
	icon_state = "waterfall_center_2"

/turf/open/auto_turf/waterfall/bottom
	icon_state = "waterfall_bottom"

/turf/open/auto_turf/waterfall/bottom/one
	icon_state = "waterfall_bottom_1"

/turf/open/auto_turf/waterfall/bottom/two
	icon_state = "waterfall_bottom_2"

/turf/open/auto_turf/waterfall/under_bottom
	icon_state = "waterfall_underbottom"

/turf/open/auto_turf/waterfall/under_bottom/one
	icon_state = "waterfall_underbottom_1"

/turf/open/auto_turf/waterfall/under_bottom/two
	icon_state = "waterfall_underbottom_2"

// Ancient Temple Walls

/turf/closed/wall/ancient_temple
	name = "ancient temple wall"
	desc = "A heavy wall of sandstone with sandstone plating."
	icon = 'code_ru/icons/turf/walls/hunter/hunter_temple.dmi'
	icon_state = "ancient_stone"
	walltype = WALL_ANCIENT_BASE
	baseturfs = /turf/open/gm/dirt
	blend_objects = list(/obj/structure/prop/hunter/ancient_temple/collapsed_wall, /obj/structure/machinery/door, /obj/structure/window_frame, /obj/structure/window/framed)
	debris = list(/obj/item/stack/sheet/mineral/sandstone, /obj/effect/hunter/ancient_temple/rubble/rubble)

/turf/closed/wall/ancient_temple/sandstone

/turf/closed/wall/ancient_temple/sandstone/attack_alien(mob/living/carbon/xenomorph/user)
	visible_message("[user] scrapes uselessly against [src] with their claws.")
	return

/turf/closed/wall/ancient_temple/sandstone/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/turf/closed/wall/ancient_temple/sandstone/LateInitialize()
	. = ..()
	if(prob(80))
		decoration_type = rand(0,3)
	update_icon()

/turf/closed/wall/ancient_temple/sandstone/update_icon()
	if(decoration_type == null)
		return ..()
	if(neighbors_bitfield in list(EAST|WEST))
		special_icon = TRUE
		icon_state = "ancient_stone_deco_wall[decoration_type]"
		return
	else // Wall connection was broken, return to normality
		special_icon = FALSE
	return ..()

/turf/closed/wall/ancient_temple/sandstone/runed
	desc = "A heavy wall of sandstone, with elegant carvings and runes inscribed upon its face."
	icon = 'code_ru/icons/turf/walls/hunter/hunter_temple_deco_3.dmi'

/turf/closed/wall/ancient_temple/sandstone/runed/decor
	icon = 'code_ru/icons/turf/walls/hunter/hunter_temple_deco_3.dmi'

/turf/closed/wall/ancient_temple/sandstone/runed/deco_1
	icon = 'code_ru/icons/turf/walls/hunter/hunter_temple_deco_1.dmi'

/turf/closed/wall/ancient_temple/sandstone/runed/deco_2
	icon = 'code_ru/icons/turf/walls/hunter/hunter_temple_deco_2.dmi'

