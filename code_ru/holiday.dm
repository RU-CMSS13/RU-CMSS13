/obj/structure/prop/Holidaytree
	name = "Christmas tree"
	desc = "YO!!! Holiday tree!!! Presents is here!"
	icon = 'icons_ru/obj/flora/holiday.dmi'
	icon_state = "holiday_tree"
	unslashable = TRUE
	unacidable = TRUE
	density = TRUE
	layer = ABOVE_FLY_LAYER
	pixel_x = -16
	var/cooldown = 0

/obj/structure/prop/Holidaytree/attack_hand(mob/user)
	if(cooldown >= world.time)
		return
	else
		cooldown = world.time + 10 SECONDS
		to_chat(user, SPAN_NOTICE("You picked up one of presents below tree."))
		new /obj/item/a_gift(user.loc)
