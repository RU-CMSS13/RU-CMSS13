/datum/ammo/flamethrower/tank_flamer/buffed/drop_flame(turf/T, datum/cause_data/cause_data)
	if(!istype(T)) return
	var/datum/reagent/napalm/blue/B = new()
	new /obj/flamer_fire(T, cause_data, B, 1)

/datum/ammo/rocket/ap/tank
	accurate_range = 8
	max_range = 10

/datum/ammo/bullet/pistol/ap/cluster
	name = "cluster pistol bullet"
	shrapnel_chance = 0
	var/cluster_addon = 1.5

/datum/ammo/bullet/pistol/ap/cluster/on_hit_mob(mob/M, obj/projectile/P)
	. = ..()
	M.AddComponent(/datum/component/cluster_stack, cluster_addon, damage, world.time)

/datum/ammo/bullet/pistol/heavy/cluster
	name = "heavy cluster pistol bullet"
	var/cluster_addon = 1.5

/datum/ammo/bullet/pistol/heavy/cluster/on_hit_mob(mob/M, obj/projectile/P)
	. = ..()
	M.AddComponent(/datum/component/cluster_stack, cluster_addon, damage, world.time)

/datum/ammo/bullet/pistol/squash/cluster
	name = "cluster squash-head pistol bullet"
	shrapnel_chance = 0
	var/cluster_addon = 2

/datum/ammo/bullet/pistol/squash/cluster/on_hit_mob(mob/M, obj/projectile/P)
	. = ..()
	M.AddComponent(/datum/component/cluster_stack, cluster_addon, damage, world.time)

/datum/ammo/bullet/revolver/cluster
	name = "cluster revolver bullet"
	shrapnel_chance = 0
	var/cluster_addon = 4
	penetration = ARMOR_PENETRATION_TIER_8

/datum/ammo/bullet/revolver/cluster/on_hit_mob(mob/M, obj/projectile/P)
	. = ..()
	M.AddComponent(/datum/component/cluster_stack, cluster_addon, damage, world.time)

/datum/ammo/bullet/smg/ap/cluster
	name = "cluster submachinegun bullet"
	shrapnel_chance = 0
	penetration = ARMOR_PENETRATION_TIER_4
	var/cluster_addon = 0.8

/datum/ammo/bullet/smg/ap/cluster/on_hit_mob(mob/M, obj/projectile/P)
	. = ..()
	M.AddComponent(/datum/component/cluster_stack, cluster_addon, damage, world.time)

/datum/ammo/bullet/rifle/ap/cluster
	name = "cluster rifle bullet"
	shrapnel_chance = 0

	penetration = ARMOR_PENETRATION_TIER_6
	var/cluster_addon = 1

/datum/ammo/bullet/rifle/ap/cluster/on_hit_mob(mob/M, obj/projectile/P)
	. = ..()
	M.AddComponent(/datum/component/cluster_stack, cluster_addon, damage, world.time)

/datum/ammo/bullet/smg/nail/on_hit_mob(mob/living/L, obj/projectile/P)
    if(!L || L == P.firer || L.lying)
        return

    L.AdjustSlow(1) //Slow on hit.
    L.recalculate_move_delay = TRUE
    var/super_slowdown_duration = 3
    //If there's an obstacle on the far side, superslow and do extra damage.
    if(isxeno(L)) //Unless they're a strong xeno, in which case the slowdown is drastically reduced
        var/mob/living/carbon/xenomorph/X = L
        if(X.tier != 1) // 0 is queen!
            super_slowdown_duration = 0.5
    else if(HAS_TRAIT(L, TRAIT_SUPER_STRONG))
        super_slowdown_duration = 0.5

    var/atom/movable/thick_surface = LinkBlocked(L, get_turf(L), get_step(L, get_dir(P.loc ? P : P.firer, L)))
    if(!thick_surface || ismob(thick_surface) && !thick_surface.anchored)
        return

    L.apply_armoured_damage(damage*0.5, ARMOR_BULLET, BRUTE, null, penetration)
    L.AdjustSuperslow(super_slowdown_duration)
