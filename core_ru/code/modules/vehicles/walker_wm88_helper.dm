/*
#define FLOATING_PENETRATION_TIER_0 0
#define FLOATING_PENETRATION_TIER_1 1
#define FLOATING_PENETRATION_TIER_2 2
#define FLOATING_PENETRATION_TIER_3 3
#define FLOATING_PENETRATION_TIER_4 4
*/

/obj/item/ammo_magazine/walker/wm88
	name = "M88 Mounted AMR Magazine"
	desc = "A armament M88 magazine"
	icon_state = "mech_wm88_ammo"
	max_rounds = 80
	default_ammo = /datum/ammo/bullet/walker/wm88
	gun_type = /obj/item/walker_gun/wm88

/obj/item/ammo_magazine/walker/wm88/a20
	default_ammo = /datum/ammo/bullet/walker/wm88/a20

/obj/item/ammo_magazine/walker/wm88/a30
	default_ammo = /datum/ammo/bullet/walker/wm88/a30

/obj/item/ammo_magazine/walker/wm88/a40
	default_ammo = /datum/ammo/bullet/walker/wm88/a40

/obj/item/ammo_magazine/walker/wm88/a50
	default_ammo = /datum/ammo/bullet/walker/wm88/a50

/datum/ammo/bullet/walker/wm88
	name = ".458 SOCOM round"

	damage = 80 //изначально 104
	penetration = ARMOR_PENETRATION_TIER_2
	accuracy = HIT_ACCURACY_TIER_1
	shell_speed = AMMO_SPEED_TIER_6
	accurate_range = 14
	handful_state = "boomslang_bullet"

/datum/ammo/bullet/walker/wm88/a20
	penetration = ARMOR_PENETRATION_TIER_4

/datum/ammo/bullet/walker/wm88/a30
	penetration = ARMOR_PENETRATION_TIER_6

/datum/ammo/bullet/walker/wm88/a40
	penetration = ARMOR_PENETRATION_TIER_8

/datum/ammo/bullet/walker/wm88/a50
	penetration = ARMOR_PENETRATION_TIER_10

/obj/item/walker_gun/wm88
	name = "M88 Mounted Automated Anti-Material rifle"
	desc = "Anti-material rifle mounted on walker for counter-fire against enemy vehicles,each successfull hit will increase firerate and armor penetration"
	icon_state = "mech_wm88_parts"
	equip_state = "redy_wm88"
	fire_sound = list('sound/weapons/gun_type23.ogg')
	magazine_type = /obj/item/ammo_magazine/walker/wm88
	var/basic_fire_delay = 13
	fire_delay = 13
	scatter_value = 0
	automatic = TRUE
	var/overheat_reset_cooldown = 3 SECONDS
	var/overheat_rate = 2
	var/overheat = 0
	var/overheat_upper_limit = 8
	var/overheat_self_destruction_rate = 10 //при финальном перегреве начнет получать урон при стрельбе
	//var/floating_penetration = FLOATING_PENETRATION_TIER_0
	//var/floating_penetration_upper_limit = FLOATING_PENETRATION_TIER_4
	var/steam_effect = /obj/effect/particle_effect/smoke/bad/wm88
	var/direct_hit_sound = 'sound/weapons/gun_xm88_directhit_low.ogg'

/*
/obj/item/walker_gun/wm88/register_signals(mob/user)
	RegisterSignal(user, COMSIG_BULLET_DIRECT_HIT, PROC_REF(direct_hit_buff))
	return ..()

/obj/item/walker_gun/wm88/unregister_signals(mob/user)
	UnregisterSignal(user, COMSIG_BULLET_DIRECT_HIT)
	return ..()

/obj/item/walker_gun/wm88/proc/direct_hit_buff(mob/user, mob/target)
	SIGNAL_HANDLER
	apply_hit_buff(user, target)
	addtimer(CALLBACK(src, PROC_REF(reset_hit_buff), user), overheat_reset_cooldown, TIMER_OVERRIDE|TIMER_UNIQUE)

/obj/item/walker_gun/wm88/proc/apply_hit_buff()
	fire_delay = basic_fire_delay - overheat //to shoot the next round faster

	if(floating_penetration < floating_penetration_upper_limit)
		floating_penetration++

*/

/obj/item/walker_gun/wm88/active_effect(atom/target, mob/living/user)
	if(!target) //checks here since we don't want to fuck up applying the increase
		return NONE
	if(overheat) //has to go before actual firing
		var/obj/item/ammo_magazine/walker/new_ammo
		var/old_ammo = ammo
		var/ammo_rounds_memory = ammo.current_rounds
		switch(overheat)
			if(2)
				new_ammo = new/obj/item/ammo_magazine/walker/wm88/a20
				direct_hit_sound = "sound/weapons/gun_xm88_directhit_low.ogg"
			if(4)
				new_ammo = new/obj/item/ammo_magazine/walker/wm88/a30
				direct_hit_sound = "sound/weapons/gun_xm88_directhit_medium.ogg"
			if(6)
				new_ammo = new/obj/item/ammo_magazine/walker/wm88/a40
				direct_hit_sound = "sound/weapons/gun_xm88_directhit_medium.ogg"
			if(8)
				new_ammo = new/obj/item/ammo_magazine/walker/wm88/a50
				direct_hit_sound = "sound/weapons/gun_xm88_directhit_high.ogg"
		new_ammo.current_rounds = ammo_rounds_memory
		ammo = new_ammo
		qdel(old_ammo)
		if(overheat == overheat_upper_limit)
			var/turf/T = get_turf(owner)
			new steam_effect(T)
			var/damage = overheat_self_destruction_rate * overheat
			src.owner.take_damage_type(damage, "blunt", src) //надо заменить на прямое взаимодействие со здоровьем чтобы не засорять чат и удобно высчитывать
	//SEND_SIGNAL(user, COMSIG_BULLET_DIRECT_HIT, target, src)
		fire_delay = basic_fire_delay - overheat
	if(overheat < overheat_upper_limit)
		overheat += overheat_rate
	addtimer(CALLBACK(src, PROC_REF(reset_hit_buff), user), overheat_reset_cooldown, TIMER_OVERRIDE|TIMER_UNIQUE)
	return ..()

/obj/item/walker_gun/wm88/proc/reset_hit_buff(mob/user)
	SIGNAL_HANDLER
	if(overheat > 0)
		to_chat(user, SPAN_WARNING("[src] beeps as it's extinguish."))
	overheat = 0
	direct_hit_sound = "sound/weapons/gun_xm88_directhit_low.ogg"
	var/ammo_memory = ammo.current_rounds
	var/obj/item/ammo_magazine/walker/new_ammo
	var/old_ammo = ammo
	new_ammo = new/obj/item/ammo_magazine/walker/wm88
	ammo = new_ammo
	qdel(old_ammo)
	ammo.current_rounds = ammo_memory
	//floating_penetration = FLOATING_PENETRATION_TIER_0
	fire_delay = basic_fire_delay

/obj/effect/particle_effect/smoke/bad/wm88
	smokeranking = SMOKE_RANK_HIGH
	time_to_live = 20

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

	affected_mob.apply_damage(15, BURN)
	to_chat(affected_mob, SPAN_WARNING("YOUR FLASH IS BURNED BY HOT STEAM"))

	if(affected_mob.coughedtime < world.time && !affected_mob.stat)
		affected_mob.coughedtime = world.time + 2 SECONDS
		if(ishuman(affected_mob)) //Humans only to avoid issues
			affected_mob.emote("scream")
	return TRUE

/datum/supply_packs/ammo_wm88_walker
	name = "M88 Mounted AMR Magazine (x2)"
	contains = list(
		/obj/item/ammo_magazine/walker/wm88,
		/obj/item/ammo_magazine/walker/wm88,
	)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "M88 Mounted AMR Magazine crate"
	group = "Vehicle Ammo"

/*
#undef FLOATING_PENETRATION_TIER_0
#undef FLOATING_PENETRATION_TIER_1
#undef FLOATING_PENETRATION_TIER_2
#undef FLOATING_PENETRATION_TIER_3
#undef FLOATING_PENETRATION_TIER_4
*/
