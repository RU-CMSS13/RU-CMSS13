//////////////////////////////////////////////////////////////
// NORMAL GUNS


/obj/item/weapon/gun/mounted
	name = "placeholder"
	desc = "placeholder."

	icon = 'code_ru/icons/obj/vehicles/mech_guns.dmi'
	icon_state = "holder"
	item_state = "holder"

	item_icons = list()

	current_mag = null

	w_class = SIZE_HUGE
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_WIELDED_FIRING_ONLY
	flags_mounted_gun_features = GUN_MOUNTING|GUN_ONLY_MOUNTING
	gun_category = GUN_CATEGORY_MOUNTED

	lineart_ru = TRUE

	var/build_in_zoom = 0

/obj/item/weapon/gun/mounted/update_icon()
	return


//////////////////////////////////////////////////////////////


/obj/item/weapon/gun/mounted/mecha_smartgun
	name = "M56 High-Caliber Mounted Smartgun"
	desc = "Modified version of standart USCM Smartgun System, mounted on military walkers"

	icon_state = "mech_smartgun_parts"
	item_state = "redy_smartgun"

	current_mag = /obj/item/ammo_magazine/walker/smartgun
	fire_sound = list('sound/weapons/gun_smartgun1.ogg', 'sound/weapons/gun_smartgun2.ogg', 'sound/weapons/gun_smartgun3.ogg')

	start_automatic = TRUE
	start_semiauto = FALSE

	mount_class = GUN_MOUNT_MECHA

	charge_cost = 6

/obj/item/weapon/gun/mounted/mecha_smartgun/set_gun_config_values()
	. = ..()

	set_fire_delay(FIRE_DELAY_TIER_SG)

	fa_scatter_peak = 1
	fa_max_scatter = 0
	scatter = SCATTER_AMOUNT_TIER_1

	damage_mult = BASE_BULLET_DAMAGE_MULT

/obj/item/weapon/gun/mounted/mecha_smartgun/set_bullet_traits()
	LAZYADD(traits_to_give, list(
		BULLET_TRAIT_ENTRY_ID("iff", /datum/element/bullet_trait_iff)
	))


//////////////////////////////////////////////////////////////


/obj/item/weapon/gun/mounted/mecha_hmg
	name = "M30 Machine Gun"
	desc = "High-caliber machine gun firing small bursts of AP bullets, tearing into shreds unfortunate fellas on its way."

	icon_state = "mech_minigun_parts"
	item_state = "redy_minigun"

	current_mag = /obj/item/ammo_magazine/walker/hmg
	fire_sound = list('sound/weapons/gun_minigun.ogg')

	start_automatic = TRUE
	start_semiauto = FALSE

	mount_class = GUN_MOUNT_MECHA

	charge_cost = 2

/obj/item/weapon/gun/mounted/mecha_hmg/set_gun_config_values()
	. = ..()

	set_fire_delay(FIRE_DELAY_TIER_8)

	fa_scatter_peak = 1
	fa_max_scatter = 0
	scatter = SCATTER_AMOUNT_TIER_1 + SCATTER_AMOUNT_TIER_2

	damage_mult = BASE_BULLET_DAMAGE_MULT


//////////////////////////////////////////////////////////////


/obj/item/weapon/gun/mounted/mecha_wm88
	name = "M88 Mounted Automated Anti-Material rifle"
	desc = "Anti-material rifle mounted on walker for counter-fire against enemy vehicles, each successfull hit will increase firerate and armor penetration"

	icon_state = "mech_wm88_parts"
	item_state = "redy_wm88"

	current_mag = /obj/item/ammo_magazine/walker/wm88

	start_automatic = TRUE
	start_semiauto = FALSE

	mount_class = GUN_MOUNT_MECHA

	charge_cost = 40
	var/basic_charge_cost = 40
	var/basic_fire_delay = 1.6 SECONDS

	var/overheat = 0
	var/overheat_rate = 1
	var/overheat_limit = 8
	var/overheat_rate_to_fire_delay = 1
	var/overheat_self_destruction_rate = 2// при финальном перегреве начнет получать урон при стрельбе умноженный на перегрев
	var/overheat_reset_cooldown = 3 SECONDS

	var/list/ammo_overheat_map = list()

	var/steam_effect = /obj/effect/particle_effect/smoke/bad/wm88

/obj/item/weapon/gun/mounted/mecha_wm88/Initialize(mapload)
	. = ..()

	update_overheat_ammo_map()

/obj/item/weapon/gun/mounted/mecha_wm88/set_gun_config_values()
	. = ..()

	set_fire_delay(basic_fire_delay)

	fa_scatter_peak = 1
	fa_max_scatter = 0
	scatter = SCATTER_AMOUNT_TIER_2

	damage_mult = BASE_BULLET_DAMAGE_MULT

/obj/item/weapon/gun/mounted/mecha_wm88/Destroy()
	for(var/value in ammo_overheat_map)
		ammo_overheat_map[value] = null

	. = ..()

/obj/item/weapon/gun/mounted/mecha_wm88/set_gun_user(mob/to_set)
	var/mob/cached_gun_user = gun_user

	. = ..()

	if(to_set == cached_gun_user)
		if(!(comp_lookup[COMSIG_MOB_FIRED_GUN]) && to_set)
			RegisterSignal(cached_gun_user, COMSIG_MOB_FIRED_GUN, PROC_REF(after_fire_effect))
		return
	if(cached_gun_user)
		UnregisterSignal(cached_gun_user, list(COMSIG_MOB_FIRED_GUN))

	if(gun_user)
		RegisterSignal(gun_user, COMSIG_MOB_FIRED_GUN, PROC_REF(after_fire_effect))

/obj/item/weapon/gun/mounted/mecha_wm88/set_bullet_traits()
	LAZYADD(traits_to_give, list(
		BULLET_TRAIT_ENTRY_ID("iff", /datum/element/bullet_trait_iff)
	))

/obj/item/weapon/gun/mounted/mecha_wm88/proc/update_overheat_ammo_map()
	var/static/list/options = list(// We have only five options, so just stick with it
		/datum/ammo/bullet/walker/wm88,
		/datum/ammo/bullet/walker/wm88/a20,
		/datum/ammo/bullet/walker/wm88/a30,
		/datum/ammo/bullet/walker/wm88/a40,
		/datum/ammo/bullet/walker/wm88/a50,
	)
	for(var/current_pos = 0 to overheat_limit)
		ammo_overheat_map["[current_pos]"] = options[ceil(current_pos / overheat_limit * options.len)]

/obj/item/weapon/gun/mounted/mecha_wm88/proc/after_fire_effect(mob/living/user, obj/item/weapon/gun/used)
	if(src != used)
		return

	overheat = min(overheat + overheat_rate, overheat_limit)
	current_mag.default_ammo = ammo_overheat_map["[overheat]"]
	charge_cost = basic_charge_cost * overheat
	set_fire_delay(basic_fire_delay - overheat * overheat_rate_to_fire_delay)
	if(overheat == overheat_limit)
		new steam_effect(get_turf(src))
		var/obj/item/hardpoint/walker/hand = gun_holder
		hand.owner.take_damage_type(overheat_self_destruction_rate * overheat, "abstract", null, hand)

	addtimer(CALLBACK(src, PROC_REF(reset_overheat_buff), user), overheat_reset_cooldown, TIMER_OVERRIDE|TIMER_UNIQUE|TIMER_DELETE_ME)

/obj/item/weapon/gun/mounted/mecha_wm88/proc/reset_overheat_buff(mob/user)
	SIGNAL_HANDLER

	overheat = 0
	current_mag.default_ammo = ammo_overheat_map["[overheat]"]
	set_fire_delay(basic_fire_delay)

	to_chat(user, SPAN_WARNING("[src] beeps as it's extinguish."))

/obj/effect/particle_effect/smoke/bad/wm88
	smokeranking = SMOKE_RANK_MED
	time_to_live = 8

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


//////////////////////////////////////////////////////////////


/obj/item/weapon/gun/mounted/mecha_shotgun8g
	name = "M32 Mounted Shotgun"
	desc = "8 Gauge shotgun firing wave of AP bullets ineffective at distance, mounted on military walkers for devastation pacify"

	icon_state = "mech_shotgun8g_parts"
	item_state = "redy_shotgun8g"

	current_mag = /obj/item/ammo_magazine/walker/shotgun8g
	fire_sound = list('sound/weapons/gun_type23.ogg')

	mount_class = GUN_MOUNT_MECHA

	charge_cost = 4

/obj/item/weapon/gun/mounted/mecha_shotgun8g/set_gun_config_values()
	. = ..()

	set_fire_delay(FIRE_DELAY_TIER_SHOTGUN_BASE)


//////////////////////////////////////////////////////////////


/obj/item/weapon/gun/mounted/mecha_laser
	name = "L55 \"Lazarus\" Heavy Pulse Lazer"
	desc = "This is for sure abomination of mobile ground unit weapons. This gun consume a lot of energy and can have literally deadly recoil. Only heavy platforms can use it. Very limited edition, result can vary due to low production scale."

	icon_state = "mech_shotgun8g_parts"
	item_state = "redy_shotgun8g"

	ammo = /datum/ammo/energy/walker/laser
	fire_sound = list('sound/effects/phasein.ogg')

	mount_class = GUN_MOUNT_MECHA

	charge_cost = 2000

/obj/item/weapon/gun/mounted/mecha_laser/set_gun_config_values()
	. = ..()

	set_fire_delay(15 SECONDS)

/obj/item/weapon/gun/mounted/mecha_laser/load_into_chamber()
	in_chamber = create_bullet(ammo, initial(name))
	return in_chamber

/obj/item/weapon/gun/mounted/mecha_laser/has_ammunition()
	return TRUE

/obj/item/weapon/gun/mounted/mecha_laser/reload_into_chamber()
	return TRUE



//////////////////////////////////////////////////////////////
// GRENADE LAUNCHERS


/obj/item/weapon/gun/launcher/grenade/mounted
	name = "placeholder"
	desc = "placeholder."

	icon = 'code_ru/icons/obj/vehicles/mech_guns.dmi'
	icon_state = "holder"
	item_state = "holder"

	item_icons = list()

	preload = null

	w_class = SIZE_HUGE
	flags_gun_features = GUN_UNUSUAL_DESIGN|GUN_AUTO_EJECTOR|GUN_WIELDED_FIRING_ONLY|GUN_RECOIL_BUILDUP
	flags_mounted_gun_features = GUN_MOUNTING|GUN_ONLY_MOUNTING
	gun_category = GUN_CATEGORY_MOUNTED

	lineart_ru = TRUE

// Official CMs shitcoded something, so yea, they work not the same like supposed, SHITCODE
/obj/item/weapon/gun/launcher/grenade/mounted/handle_fire(atom/target, mob/living/user, params)
	. = NONE
	afterattack(target, user, params, TRUE)

/obj/item/weapon/gun/launcher/grenade/mounted/afterattack(atom/target, mob/user, proximity_flag, force = FALSE)
	if(!force)
		return
	. = ..()
// FUCK them ALIVE to DEATH

/obj/item/weapon/gun/launcher/grenade/mounted/update_icon()
	return


//////////////////////////////////////////////////////////////


/obj/item/weapon/gun/launcher/grenade/mounted/mecha_grenade_launcher
	name = "G67 \"Demoman\" Grenade Launcher"
	desc = "Developed for long range air support and cutting off reinforcements, do very well with wiping out enemy fortifications. Do you know why is there only good demomans? Because all bad is dead already."

	icon_state = "mech_smartgun_parts"
	item_state = "redy_smartgun"

	preload = /obj/item/explosive/grenade/incendiary/airburst

	mount_class = GUN_MOUNT_MECHA

	is_lobbing = TRUE
	direct_draw = FALSE
	internal_slots = 24

	charge_cost = 2

/obj/item/weapon/gun/launcher/grenade/mounted/mecha_grenade_launcher/set_gun_config_values()
	. = ..()

	set_fire_delay(FIRE_DELAY_TIER_6)




//////////////////////////////////////////////////////////////
// ROCKET LAUNCHERS


/obj/item/weapon/gun/launcher/rocket/mounted
	name = "placeholder"
	desc = "placeholder."

	icon = 'code_ru/icons/obj/vehicles/mech_guns.dmi'
	icon_state = "holder"
	item_state = "holder"

	item_icons = list()

	current_mag = null

	w_class = SIZE_HUGE
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_WIELDED_FIRING_ONLY
	flags_mounted_gun_features = GUN_MOUNTING|GUN_ONLY_MOUNTING
	gun_category = GUN_CATEGORY_MOUNTED

	skill_locked = FALSE

	lineart_ru = TRUE

/obj/item/weapon/gun/launcher/rocket/mounted/update_icon()
	return


//////////////////////////////////////////////////////////////


/obj/item/weapon/gun/launcher/rocket/mounted/mecha_tactical_missile
	name = "Tactical Missile Launcher"
	desc = "Tactical missile launcher."

	icon_state = "mech_smartgun_parts"
	item_state = "redy_smartgun"

	current_mag = /obj/item/ammo_magazine/rocket/walker/brute
	mount_class = GUN_MOUNT_MECHA

	charge_cost = 150

	var/f_aiming_time = 2 SECONDS
	var/aiming = FALSE

/obj/item/weapon/gun/launcher/rocket/mounted/mecha_tactical_missile/handle_fire(atom/target, mob/living/user, params, reflex = FALSE, dual_wield, check_for_attachment_fire, akimbo, fired_by_akimbo)
	if(aiming)
		return

	var/start_turf = get_turf(user)
	if(!(istype(target, /obj/structure) || istype(target, /turf/closed/wall)))
		to_chat(user, SPAN_WARNING("Invalid target!"))
		return

	if(!current_mag?.current_rounds)
		return

	var/list/turf/path = get_line(start_turf, target, include_start_atom = FALSE)
	for(var/turf/turf_path in path)
		if(turf_path.opacity && turf_path != target)
			to_chat(user, SPAN_WARNING("Target obscured!"))
			return

	aiming = TRUE
	var/beam = "laser_beam_guided"
	var/lockon = "sniper_lockon_guided"
	var/image/lockon_icon = image(icon = 'icons/effects/Targeted.dmi', icon_state = lockon)
	target.overlays += lockon_icon

	var/image/lockon_direction_icon
	lockon_direction_icon = image(icon = 'icons/effects/Targeted.dmi', icon_state = "[lockon]_direction", dir = get_cardinal_dir(target, user))
	target.overlays += lockon_direction_icon
	var/datum/beam/laser_beam
	laser_beam = target.beam(start_turf, beam, 'icons/effects/beam.dmi', (f_aiming_time + 1 SECONDS), beam_type = /obj/effect/ebeam/laser/intense)
	laser_beam.visuals.alpha = 0
	animate(laser_beam.visuals, alpha = initial(laser_beam.visuals.alpha), f_aiming_time, easing = SINE_EASING|EASE_OUT)

	if(do_after(user, f_aiming_time, INTERRUPT_ALL, BUSY_ICON_HOSTILE))
		if(!QDELETED(target))
			. = ..()

	target.overlays -= lockon_icon
	target.overlays -= lockon_direction_icon
	qdel(laser_beam)
	aiming = FALSE

/obj/item/weapon/gun/launcher/rocket/mounted/mecha_tactical_missile/make_rocket(mob/user, drop_override = 0, empty = TRUE)
	if(empty)
		return

	. = ..()




//////////////////////////////////////////////////////////////
// SHOTGUNS


/obj/item/weapon/gun/shotgun/mounted
	name = "placeholder"
	desc = "placeholder."

	icon = 'code_ru/icons/obj/vehicles/mech_guns.dmi'
	icon_state = "holder"
	item_state = "holder"

	item_icons = list()

	current_mag = null

	w_class = SIZE_HUGE
	flags_gun_features = GUN_UNUSUAL_DESIGN|GUN_WIELDED_FIRING_ONLY
	flags_mounted_gun_features = GUN_MOUNTING|GUN_ONLY_MOUNTING
	gun_category = GUN_CATEGORY_MOUNTED

	lineart_ru = TRUE

/obj/item/weapon/gun/shotgun/mounted/update_icon()
	return




//////////////////////////////////////////////////////////////
// FLAMETHROWERS


/obj/item/weapon/gun/flamer/mounted
	name = "placeholder"
	desc = "placeholder."

	icon = 'code_ru/icons/obj/vehicles/mech_guns.dmi'
	icon_state = "holder"
	item_state = "holder"

	item_icons = list()

	current_mag = null

	w_class = SIZE_HUGE
	flags_gun_features = GUN_UNUSUAL_DESIGN|GUN_WIELDED_FIRING_ONLY
	flags_mounted_gun_features = GUN_MOUNTING|GUN_ONLY_MOUNTING
	gun_category = GUN_CATEGORY_MOUNTED

	lineart_ru = TRUE

/obj/item/weapon/gun/flamer/mounted/update_icon()
	return


//////////////////////////////////////////////////////////////


/obj/item/weapon/gun/flamer/mounted/mecha_flamer
	name = "F40 \"Hellfire\" Flamethower"
	desc = "Powerful flamethower, that can send any unprotected target straight to hell."

	icon_state = "mech_flamer_parts"
	item_state = "redy_flamer"

	current_mag = /obj/item/ammo_magazine/flamer_tank/walker
	fire_sound = list('sound/weapons/gun_flamethrower2.ogg')

	mount_class = GUN_MOUNT_MECHA

	charge_cost = 1
