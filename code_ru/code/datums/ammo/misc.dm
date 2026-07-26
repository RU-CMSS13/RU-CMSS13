/datum/ammo/bullet/doorgun/holotarget/on_hit_mob(mob/hit_mob, obj/projectile/bullet)
	. = ..()
	hit_mob.AddComponent(/datum/component/bonus_damage_stack, holo_stacks, world.time, bonus_damage_cap_increase, stack_loss_multiplier)

/datum/ammo/bullet/doorgun/holotarget
	name = "holotarget round"
	headshot_state = HEADSHOT_OVERLAY_MEDIUM
	icon_state = "bullet_large"
	flags_ammo_behavior = AMMO_BALLISTIC
	damage_falloff = 0

	accuracy = HIT_ACCURACY_TIER_7
	scatter = 0
	damage = 25
	penetration = ARMOR_PENETRATION_TIER_3
	accurate_range = 10
	max_range = 12
	shell_speed = AMMO_SPEED_TIER_6

	var/holo_stacks = 10
	var/bonus_damage_cap_increase = 0
	var/stack_loss_multiplier = 1

/datum/ammo/rocket/wp/chimera
	name = "chimera sticky white phosphorous rocket"
	icon = 'code_ru/icons/obj/items/weapons/projectiles.dmi'
	icon_state = "chimera_missile"
	flags_ammo_behavior = AMMO_ROCKET|AMMO_EXPLOSIVE|AMMO_STRIKES_SURFACE
	damage_type = BURN

	accuracy_var_low = PROJECTILE_VARIANCE_TIER_6
	accurate_range = 8
	damage = 120
	max_range = 8

/datum/ammo/rocket/wp/chimera/set_bullet_traits()
	. = ..()
	LAZYADD(traits_to_give, list(
		BULLET_TRAIT_ENTRY(/datum/element/bullet_trait_incendiary)
	))

/datum/ammo/rocket/wp/chimera/drop_flame(turf/turf, datum/cause_data/cause_data)
	playsound(turf, 'sound/weapons/gun_flamethrower3.ogg', 75, 1, 7)
	if(!istype(turf))
		return
	do_smoke(loca = turf)
	var/datum/reagent/napalm/blue/reagent = new()
	new /obj/flamer_fire(turf, cause_data, reagent, 3)

	var/datum/effect_system/smoke_spread/phosphorus/landingSmoke = new /datum/effect_system/smoke_spread/phosphorus
	landingSmoke.set_up(3, 0, turf, null, 6, cause_data)
	landingSmoke.start()

/datum/ammo/rocket/wp/chimera/on_hit_mob(mob/mob, obj/projectile/projectile)
	drop_flame(get_turf(mob), projectile.weapon_cause_data)

/datum/ammo/rocket/wp/chimera/on_hit_obj(obj/object, obj/projectile/projectile)
	drop_flame(get_turf(object), projectile.weapon_cause_data)

/datum/ammo/rocket/wp/chimera/on_hit_turf(turf/turf, obj/projectile/projectile)
	drop_flame(turf, projectile.weapon_cause_data)

/datum/ammo/rocket/wp/chimera/do_at_max_range(obj/projectile/projectile)
	drop_flame(get_turf(projectile), projectile.weapon_cause_data)
