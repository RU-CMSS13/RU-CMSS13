/obj/effect/human_killer_zone
	name = "human_killer_zone_alien_effect"
	desc = "you should not see that"
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	invisibility = INVISIBILITY_MAXIMUM
	layer = ABOVE_LYING_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	unacidable = TRUE
	explo_proof = TRUE

/obj/effect/human_killer_zone/Crossed(mob/M)
	if(!ishuman(M))
		return
	if(ismonkey(M))
		return
	var/mob/living/carbon/human/H = M
	to_chat(H, SPAN_HIGHDANGER("You better switch your direction, you coming towards your doom"))
	if(issynth(H))
		H.apply_damage(15, BURN)
	else
		H.apply_damage(6, TOX)

/obj/effect/human_killer_zone/alien
	name = "human_killer_zone_alien_effect"

/obj/effect/human_killer_zone/alien/Crossed(mob/M)
	if(!ishuman(M))
		return
	if(ismonkey(M))
		return
	var/mob/living/carbon/human/H = M
	if(H.hauling_xeno)
		return
	if(locate(/obj/item/alien_embryo) in H.contents)
		return
	if(H.pulledby && isxeno(H.pulledby))
		return
	to_chat(H, SPAN_HIGHDANGER("You better switch your direction, you coming towards your doom"))
	if(issynth(H))
		H.apply_damage(15, BURN)
	else
		H.apply_damage(6, TOX)

/obj/effect/human_killer_zone/proc/destroy() //case-sensetive CALL_PROC issue
	src.Destroy(1)
