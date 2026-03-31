/obj/effect/mineop/controller
	name = "Костыль для контроля происходящего"
	icon = 'icons/landmarks.dmi'
	icon_state = "x2"

	invisibility = INVISIBILITY_OBSERVER
	var/list/area/tunnel_regions = list()
	var/current_drilling_progress = 1
	var/drifters_frequency = 5 MINUTES
