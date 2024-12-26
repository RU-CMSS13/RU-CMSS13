
/mob/living/carbon/xenomorph/proc/check_blood_splash(damage = 0, damtype = BRUTE, chancemod = 0, radius = 1)
	if(!damage || !acid_blood_damage || world.time < acid_splash_last + acid_splash_cooldown || SSticker?.mode?.hardcore)
		return FALSE
	var/chance = 20 //base chance
	if(damtype == BRUTE) chance += 5
	chance += chancemod + (damage * 0.33)
	var/turf/T = loc
	if(!T || !istype(T))
		return

	if(radius > 1 || prob(chance))
		var/decal_chance = 50
		if(prob(decal_chance))
			var/obj/effect/decal/cleanable/blood/xeno/decal = locate(/obj/effect/decal/cleanable/blood/xeno) in T
			if(!decal) //Let's not stack blood, it just makes lagggggs.
				add_splatter_floor(T) //Drop some on the ground first.
			else
				if(decal.random_icon_states && length(decal.random_icon_states) > 0) //If there's already one, just randomize it so it changes.
					decal.icon_state = pick(decal.random_icon_states)

		var/splash_chance = 40 //Base chance of getting splashed. Decreases with # of victims.
		var/i = 0 //Tally up our victims.

		for(var/mob/living/carbon/human/victim in orange(radius, src)) //Loop through all nearby victims, including the tile.
			splash_chance = 65 - (i * 5)
			if(victim.loc == loc)
				splash_chance += 30 //Same tile? BURN
			if(victim.species?.acid_blood_dodge_chance)
				splash_chance -= victim.species.acid_blood_dodge_chance

			if(splash_chance > 0 && prob(splash_chance)) //Success!
				var/dmg = list("damage" = acid_blood_damage)
				if(SEND_SIGNAL(src, COMSIG_XENO_DEAL_ACID_DAMAGE, victim, dmg) & COMPONENT_BLOCK_DAMAGE)
					continue
				i++
				victim.visible_message(SPAN_DANGER("\The [victim] is scalded with hissing green blood!"), \
				SPAN_DANGER("You are splattered with sizzling blood! IT BURNS!"))
				if(prob(60) && !victim.stat && victim.pain.feels_pain)
					INVOKE_ASYNC(victim, TYPE_PROC_REF(/mob, emote), "scream") //Topkek
				if(victim.wear_suit == /obj/item/clothing/suit/storage/marine/m40)
					damage *= 0.20
				victim.apply_armoured_damage(dmg["damage"], ARMOR_BIO, BURN) //Sizzledam! This automagically burns a random existing body part.
				victim.add_blood(get_blood_color(), BLOOD_BODY)
				acid_splash_last = world.time
				handle_blood_splatter(get_dir(src, victim), 1 SECONDS)
				playsound(victim, "acid_sizzle", 25, TRUE)
				animation_flash_color(victim, "#FF0000") //pain hit flicker
