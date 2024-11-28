#define FLOATING_PENETRATION_TIER_0 0
#define FLOATING_PENETRATION_TIER_1 1
#define FLOATING_PENETRATION_TIER_2 2
#define FLOATING_PENETRATION_TIER_3 3
#define FLOATING_PENETRATION_TIER_4 4

/obj/item/walker_gun/wm88
	var/overheat_reset_cooldown = 3 SECONDS
	var/overheat_stacks_from_hit = 2
	var/overheat = 0
	var/overheat_upper_limit = 8
	var/overheat_self_destruction_rate = 10 //each overheat stack will damage mech for each shot
	var/floating_penetration = FLOATING_PENETRATION_TIER_0
	var/floating_penetration_upper_limit = FLOATING_PENETRATION_TIER_4
	var/cloud_effect = /obj/effect/particle_effect/smoke/bad/wm88
	var/direct_hit_sound = 'sound/weapons/gun_xm88_directhit_low.ogg'

/obj/item/walker_gun/wm88/apply_hit_buff()
	last_fired = world.time - overheat //to shoot the next round faster

	if(floating_penetration < floating_penetration_upper_limit)
		floating_penetration++

/obj/item/walker_gun/wm88/Fire(atom/target, mob/living/user, params, reflex, dual_wield)
	if(!able_to_fire(user) || !target) //checks here since we don't want to fuck up applying the increase
		return NONE
	if(floating_penetration && in_chamber) //has to go before actual firing
		var/obj/projectile/P = in_chamber
		switch(floating_penetration)
			if(FLOATING_PENETRATION_TIER_1)
			/*	P.ammo = GLOB.ammo_list[/datum/ammo/bullet/lever_action/xm88/pen20]
				direct_hit_sound = "sound/weapons/gun_xm88_directhit_low.ogg"
			if(FLOATING_PENETRATION_TIER_2)
				P.ammo = GLOB.ammo_list[/datum/ammo/bullet/lever_action/xm88/pen30]
				direct_hit_sound = "sound/weapons/gun_xm88_directhit_medium.ogg"
			if(FLOATING_PENETRATION_TIER_3)
				P.ammo = GLOB.ammo_list[/datum/ammo/bullet/lever_action/xm88/pen40]
				direct_hit_sound = "sound/weapons/gun_xm88_directhit_medium.ogg"
			if(FLOATING_PENETRATION_TIER_4)
				P.ammo = GLOB.ammo_list[/datum/ammo/bullet/lever_action/xm88/pen50]
				direct_hit_sound = "sound/weapons/gun_xm88_directhit_high.ogg" */
			var/damage = overheat_self_destruction_rate * overheat
			src.owner.take_damage_type(damage, "slash", src)
	return ..()

/obj/item/walker_gun/wm88/reset_hit_buff(mob/user, one_hand_lever)
	if(!(flags_gun_lever_action & USES_STREAKS))
		return
	SIGNAL_HANDLER
	if(streak > 0)
		to_chat(user, SPAN_WARNING("[src] beeps as it loses its targeting data, and returns to normal firing procedures."))
	streak = 0
	lever_sound = initial(lever_sound)
	lever_message = initial(lever_message)
	wield_delay = initial(wield_delay)
	cur_onehand_chance = initial(cur_onehand_chance)
	direct_hit_sound = "sound/weapons/gun_xm88_directhit_low.ogg"
	/* if(in_chamber)
		var/obj/projectile/P = in_chamber
		P.ammo = GLOB.ammo_list[/datum/ammo/bullet/lever_action/xm88] */
	floating_penetration = FLOATING_PENETRATION_TIER_0
	//these are init configs and so cannot be initial()
	//lever_delay = FIRE_DELAY_TIER_3

/obj/effect/particle_effect/smoke/bad/wm88/affect(mob/living/carbon/affected_mob)
	. = ..()
	if(!.)
		return FALSE
	if(affected_mob.internal != null && affected_mob.wear_mask && (affected_mob.wear_mask.flags_inventory & ALLOWINTERNALS))
		return FALSE
	if(issynth(affected_mob))
		return FALSE

	if(prob(20))
		affected_mob.drop_held_item()
	affected_mob.apply_damage(1, OXY)

	if(affected_mob.coughedtime < world.time && !affected_mob.stat)
		affected_mob.coughedtime = world.time + 2 SECONDS
		if(ishuman(affected_mob)) //Humans only to avoid issues
			affected_mob.emote("cough")
	return TRUE

#undef FLOATING_PENETRATION_TIER_0
#undef FLOATING_PENETRATION_TIER_1
#undef FLOATING_PENETRATION_TIER_2
#undef FLOATING_PENETRATION_TIER_3
#undef FLOATING_PENETRATION_TIER_4
