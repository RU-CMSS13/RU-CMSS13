
//Procedures in this file: larva removal surgery
//////////////////////////////////////////////////////////////////
// LARVA SURGERY // Добавлен цикл для мультибурстов. Примитивно и надежно.
//////////////////////////////////////////////////////////////////

/datum/surgery_step/remove_larva/success(mob/living/carbon/user, mob/living/carbon/target, target_zone, obj/item/tool, tool_type, datum/surgery/surgery)
	for(var/W in target.contents)
		if(W)
			if(istype(W, /obj/item/alien_embryo))
				var/obj/item/alien_embryo/A = W
				if(tool)
					user.affected_message(target,
						SPAN_WARNING("You pull a wriggling parasite out of [target]'s ribcage!"),
						SPAN_WARNING("[user] pulls a wriggling parasite out of [target]'s ribcage!"),
						SPAN_WARNING("[user] pulls a wriggling parasite out of [target]'s ribcage!"))
				else
					user.affected_message(target,
						SPAN_WARNING("Your hands are burned by acid as you pull a wriggling parasite out of [target]'s ribcage!"),
						SPAN_WARNING("[user]'s hands are burned by acid as \he pulls a wriggling parasite out of your ribcage!"),
						SPAN_WARNING("[user]'s hands are burned by acid as \he pulls a wriggling parasite out of [target]'s ribcage!"))

					user.emote("pain")

					if(user.hand)
						user.apply_damage(15, BURN, "l_hand")
					else
						user.apply_damage(15, BURN, "r_hand")

				user.count_niche_stat(STATISTICS_NICHE_SURGERY_LARVA)
				var/mob/living/carbon/xenomorph/larva/L = locate() in target //the larva was fully grown, ready to burst.
				if(L)
					L.forceMove(target.loc)
					qdel(A)
				else
					A.forceMove(target.loc)
					target.status_flags &= ~XENO_HOST

				log_interact(user, target, "[key_name(user)] removed an embryo from [key_name(target)]'s ribcage with [tool ? "\the [tool]" : "their hands"], ending [surgery].")
