//////////////////////////////////////////////////////////////
// AMMO MAGAZINES


/obj/item/ammo_magazine/walker
	w_class = SIZE_LARGE
	icon = 'code_ru/icons/obj/vehicles/mech_guns.dmi'


/obj/item/ammo_magazine/walker/smartgun
	name = "M56 Double-Barrel Magazine (Standard)"
	desc = "A armament MG magazine"
	caliber = "10x28mm"
	icon_state = "mech_smartgun_ammo"
	default_ammo = /datum/ammo/bullet/walker/smartgun
	max_rounds = 700
	gun_type = /obj/item/weapon/gun/mounted/mecha_smartgun


/obj/item/ammo_magazine/walker/hmg
	name = "M30 Machine Gun Magazine"
	desc = "A armament M30 magazine"
	icon_state = "mech_minigun_ammo"
	max_rounds = 400
	default_ammo = /datum/ammo/bullet/walker/machinegun
	gun_type = /obj/item/weapon/gun/mounted/mecha_hmg


/obj/item/ammo_magazine/walker/shotgun8g
	name = "M32 Mounted Shotgun Magazine"
	desc = "A armament M32 magazine"
	icon_state = "mech_shotgun8g_ammo"
	max_rounds = 60
	default_ammo = /datum/ammo/bullet/walker/shotgun8g
	gun_type = /obj/item/weapon/gun/mounted/mecha_shotgun8g


/obj/item/ammo_magazine/flamer_tank/walker
	name = "F40 UT-Napthal Canister"
	desc = "Canister for mounted flamethower"

	icon = 'code_ru/icons/obj/vehicles/mech_guns.dmi'
	icon_state = "mech_flamer_s_ammo"

	w_class = SIZE_LARGE

	max_rounds = 300
	gun_type = /obj/item/weapon/gun/flamer/mounted/mecha_flamer
	stripe_icon = FALSE

	max_intensity = 40
	max_range = 5
	max_duration = 30

	fuel_pressure = 1
	max_pressure = 10

/obj/item/ammo_magazine/flamer_tank/walker/btype
	name = "F40 UT-Napthal B-type Canister"
	desc = "Canister for mounted flamethower"

	icon_state = "mech_flamer_b_ammo"

	flamer_chem = "napalmb"


/obj/item/ammo_magazine/walker/wm88
	name = "M88 Mounted AMR Magazine"
	desc = "A armament M88 magazine"
	icon_state = "mech_wm88_ammo"
	max_rounds = 80
	default_ammo = /datum/ammo/bullet/walker/wm88
	gun_type = /obj/item/weapon/gun/mounted/mecha_wm88


/obj/item/ammo_magazine/rocket/walker
	name = "M2558 Tactical Laser-Guided Rocket"
	gun_type = /obj/item/weapon/gun/launcher/rocket/mounted/mecha_tactical_missile
	default_ammo = /datum/ammo/rocket

/obj/item/ammo_magazine/rocket/walker/ap
	name = "M2558 Tactical AP Laser-Guided Rocket"
	desc = "The M2558 rockets are high-explosive anti-structure munitions designed to rapidly accelerate to nearly 1,000 miles per hour in any atmospheric conditions. Capable of piercing heavily armored targets. Deals very little to no splash damage. Inflicts guaranteed stun to most targets."
	default_ammo = /datum/ammo/rocket/ap/tactical

/obj/item/ammo_magazine/rocket/walker/brute
	name = "M2558 Tactical Bunker Buster Laser-Guided Rocket"
	desc = "The M2558 rockets are high-explosive anti-structure munitions designed to rapidly accelerate to nearly 1,000 miles per hour in any atmospheric conditions. The warhead itself uses an inflection stabilized shaped-charge to generate a low-frequency pressure wave that can flatten nearly any fortification in an ellipical radius of several meters. These rockets are known to have reduced lethality to personnel, but will put just about any ol' backwater mud-hut right into orbit."
	default_ammo = /datum/ammo/rocket/brute/tactical




//////////////////////////////////////////////////////////////
// AMMO DATUMS


/datum/ammo/bullet/walker/smartgun
	name = "smartgun bullet"
	icon_state = "redbullet"
	flags_ammo_behavior = AMMO_BALLISTIC

	damage_falloff = DAMAGE_FALLOFF_TIER_10
	accurate_range = 7
	max_range = 24
	accuracy = -HIT_ACCURACY_TIER_2
	damage = 25
	penetration = ARMOR_PENETRATION_TIER_3
	effective_range_max = 7


/datum/ammo/bullet/walker/machinegun
	name = "machinegun bullet"
	icon_state = "bullet"

	accurate_range = 1
	max_range = 12
	damage = 40
	penetration = ARMOR_PENETRATION_TIER_5
	accuracy = -HIT_ACCURACY_TIER_4


/datum/ammo/bullet/walker/shotgun8g
	name = "8 gauge buckshot shell"
	icon_state = "buckshot"

	max_range = 6
	damage = 40
	damage_var_low = PROJECTILE_VARIANCE_TIER_5
	damage_var_high = PROJECTILE_VARIANCE_TIER_5
	penetration = ARMOR_PENETRATION_TIER_3
	scatter = 15
	accuracy = -HIT_ACCURACY_TIER_3

	bonus_projectiles_type = /datum/ammo/bullet/walker/shotgun8g/spread
	bonus_projectiles_amount = EXTRA_PROJECTILES_TIER_6

/datum/ammo/bullet/walker/shotgun8g/spread
	name = "additional 8 gauge buckshot"
	bonus_projectiles_amount = 0
	scatter = 30


/datum/ammo/bullet/walker/shotgun8g/on_hit_mob(mob/M,obj/projectile/P)
	knockback(M,P, 3)

/datum/ammo/bullet/walker/shotgun8g/knockback_effects(mob/living/living_mob)
	if(iscarbonsizexeno(living_mob))
		var/mob/living/carbon/xenomorph/target = living_mob
		to_chat(target, SPAN_XENODANGER("You are shaken and slowed by the sudden impact!"))
		target.KnockDown(0.5)// If you ask me the KD should be left out, but players like their visual cues
		target.Stun(0.5)
		target.apply_effect(1, SUPERSLOW)
		target.apply_effect(2, SLOW)
	else
		if(!isyautja(living_mob))
			living_mob.apply_effect(1, SUPERSLOW)
			living_mob.apply_effect(2, SLOW)
			to_chat(living_mob, SPAN_HIGHDANGER("The impact knocks you off-balance!"))


/datum/ammo/bullet/walker/wm88
	name = ".458 SOCOM round"

	damage = 80
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


/datum/ammo/rocket/tactical
	damage = 100
	accurate_range = 14
	max_range = 20

/datum/ammo/rocket/ap/tactical
	damage = 200
	accurate_range = 16
	max_range = 20

/datum/ammo/rocket/brute/tactical
	max_range = 20
	max_distance = 14


/datum/ammo/energy/walker
	name = "Laser Beam"
	icon_state = "laser_new"
	flags_ammo_behavior = AMMO_ENERGY|AMMO_IGNORE_ARMOR

/datum/ammo/energy/walker/plasma
	name = "Hi-Power Plasma Beam"

	accurate_range = 8
	max_range = 21

/datum/ammo/energy/walker/plasma/on_hit_mob(mob/living/target_mob, obj/projectile/proj)
	do_flame_spread(get_turf(target_mob), proj)

/datum/ammo/energy/walker/plasma/on_hit_turf(turf/target_turf, obj/projectile/proj)
	do_flame_spread(target_turf, proj)

/datum/ammo/energy/walker/plasma/on_hit_obj(obj/target_object, obj/projectile/proj)
	do_flame_spread(get_turf(target_object), proj)

/datum/ammo/energy/walker/plasma/do_at_max_range(obj/projectile/proj)
	do_flame_spread(get_turf(proj), proj)

/datum/ammo/energy/walker/plasma/proc/do_flame_spread(turf/impact, obj/projectile/proj)
	cell_explosion(impact, 50, 50, explosion_cause_data = proj.weapon_cause_data)
	fire_spread(impact, proj.weapon_cause_data, 2, 15, 50, "#3c82a5")




//////////////////////////////////////////////////////////////
// AMMO SUPPLY PACKS


/datum/supply_packs/ammo_m56_walker
	name = "M56 Double-Barrel magazines (x2)"
	contains = list(
		/obj/item/ammo_magazine/walker/smartgun,
		/obj/item/ammo_magazine/walker/smartgun,
	)
	cost = 20
	containertype = /obj/structure/closet/crate/ammo
	containername = "M56 Double-Barrel ammo crate"
	group = "Vehicle Ammo"

/datum/supply_packs/ammo_M32_walker
	name = "M32 Mounted Shotgun magazines crate"
	contains = list(
		/obj/item/ammo_magazine/walker/shotgun8g,
		/obj/item/ammo_magazine/walker/shotgun8g,
	)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "M32 Mounted Shotgun ammo crate"
	group = "Vehicle Ammo"

/datum/supply_packs/ammo_M30_walker
	name = "M30 Machine Gun magazines (x2)"
	contains = list(
		/obj/item/ammo_magazine/walker/hmg,
		/obj/item/ammo_magazine/walker/hmg,
	)
	cost = 20
	containertype = /obj/structure/closet/crate/ammo
	containername = "M30 Machine Gun ammo crate"
	group = "Vehicle Ammo"

/datum/supply_packs/ammo_F40_walker
	name = "F40 Flamethower Mixed magazines (UT-Napthal x1, B-Type x1)"
	contains = list(
		/obj/item/ammo_magazine/flamer_tank/walker,
		/obj/item/ammo_magazine/flamer_tank/walker/btype,
	)
	cost = 20
	containertype = /obj/structure/closet/crate/ammo
	containername = "F40 Flamethower ammo crate"
	group = "Vehicle Ammo"

/datum/supply_packs/ammo_wm88_walker
	name = "M88 Mounted AMR Magazine (x2)"
	contains = list(
		/obj/item/ammo_magazine/walker/wm88,
		/obj/item/ammo_magazine/walker/wm88,
	)
	cost = 40
	containertype = /obj/structure/closet/crate/ammo
	containername = "M88 Mounted AMR Magazine crate"
	group = "Vehicle Ammo"

/datum/supply_packs/ammo_m1488_tactical_rocket
	name = "M2558 Tactical Laser-Guided Rocket (x4)"
	contains = list(
		/obj/item/ammo_magazine/rocket/walker,
		/obj/item/ammo_magazine/rocket/walker,
		/obj/item/ammo_magazine/rocket/walker,
		/obj/item/ammo_magazine/rocket/walker,
	)
	cost = 10
	containertype = /obj/structure/closet/crate/ammo
	containername = "M2558 Tactical Laser-Guided Rocket crate"
	group = "Vehicle Ammo"

/datum/supply_packs/ammo_m1488_tactical_rocket_ap
	name = "M2558 Tactical AP Laser-Guided Rocket (x4)"
	contains = list(
		/obj/item/ammo_magazine/rocket/walker/ap,
		/obj/item/ammo_magazine/rocket/walker/ap,
		/obj/item/ammo_magazine/rocket/walker/ap,
		/obj/item/ammo_magazine/rocket/walker/ap,
	)
	cost = 20
	containertype = /obj/structure/closet/crate/ammo
	containername = "M2558 Tactical AP Laser-Guided Rocket crate"
	group = "Vehicle Ammo"

/datum/supply_packs/ammo_m1488_tactical_rocket_brute
	name = "M2558 Tactical Bunker Buster Laser-Guided Rocket (x2)"
	contains = list(
		/obj/item/ammo_magazine/rocket/walker/brute,
		/obj/item/ammo_magazine/rocket/walker/brute,
	)
	cost = 20
	containertype = /obj/structure/closet/crate/ammo
	containername = "M2558 Tactical Bunker Buster Laser-Guided Rocket crate"
	group = "Vehicle Ammo"
