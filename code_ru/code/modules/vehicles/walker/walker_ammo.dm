//////////////////////////////////////////////////////////////
// AMMO MAGAZINES


/obj/item/ammo_magazine/walker
	w_class = SIZE_LARGE
	icon = 'code_ru/icons/obj/vehicles/mech_guns.dmi'

/obj/item/ammo_magazine/walker/smartgun
	name = "M56 Double-Barrel Magazine (Standard)"
	desc = "A armament MG magazine"
	caliber = "10x28mm" //Correlates to smartguns
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

	max_intensity = 40
	max_range = 5
	max_duration = 30

	fuel_pressure = 1 //How much fuel is used per tile fired
	max_pressure = 10

/obj/item/ammo_magazine/flamer_tank/walker/btype
	name = "F40 UT-Napthal B-type Canister"
	desc = "Canister for mounted flamethower"

	icon_state = "mech_flamer_b_ammo"

	flamer_chem = "napalmb"

	max_intensity = 40
	max_range = 5
	max_duration = 30

	fuel_pressure = 1 //How much fuel is used per tile fired
	max_pressure = 10

/obj/item/ammo_magazine/walker/wm88
	name = "M88 Mounted AMR Magazine"
	desc = "A armament M88 magazine"
	icon_state = "mech_wm88_ammo"
	max_rounds = 80
	default_ammo = /datum/ammo/bullet/walker/wm88
	gun_type = /obj/item/weapon/gun/mounted/mecha_wm88

/obj/item/ammo_magazine/rocket/brute/tactical
	name = "M1488 Tactical Laser-Guided Rocket"
	icon_state = "brute_rocket"
	default_ammo = /datum/ammo/rocket/brute/tactical
	gun_type = /obj/item/weapon/gun/launcher/rocket/mounted/mecha_tactical_missile
	desc = "The M1488 rockets are high-explosive anti-structure munitions designed to rapidly accelerate to nearly 1,000 miles per hour in any atmospheric conditions. The warhead itself uses an inflection stabilized shaped-charge to generate a low-frequency pressure wave that can flatten nearly any fortification in an ellipical radius of several meters. These rockets are known to have reduced lethality to personnel, but will put just about any ol' backwater mud-hut right into orbit."




//////////////////////////////////////////////////////////////
// AMMO DATUMS


/datum/ammo/bullet/walker/smartgun
	name = "smartgun bullet"
	icon_state = "redbullet"
	flags_ammo_behavior = AMMO_BALLISTIC

	max_range = 24
	accurate_range = 12
	accuracy = HIT_ACCURACY_TIER_5
	damage = 20
	penetration = ARMOR_PENETRATION_TIER_1

/datum/ammo/bullet/walker/machinegun
	name = "machinegun bullet"
	icon_state = "bullet"

	accurate_range = 6
	max_range = 12
	damage = 45
	penetration= ARMOR_PENETRATION_TIER_5
	accuracy = -HIT_ACCURACY_TIER_2

/datum/ammo/bullet/walker/shotgun8g
	name = "8 gauge buckshot shell"
	icon_state = "buckshot"

	accurate_range = 2 //запрет на дальнюю стрельбу, нанесет только ~30 урона из-за промахов разброса, в дистанции два тайла спереди спокойно сносит 160 квине/раве
	max_range = 6 //Возможно, следует поднять макс дальность до 6; в тоже время оно вообще не должно стреляться в даль
	damage = 60 //вообще, у дроби 8g 75 урона, но мех не должен прям гнобить при попадании даже небронированные цели, шотган для самообороны
	damage_falloff = DAMAGE_FALLOFF_TIER_6 //5 фэлл офа,фиг, а не дальнее поражение с высоким уроном
	penetration= ARMOR_PENETRATION_TIER_2 //нулевое бронепробитие в оригинале
	bonus_projectiles_type = /datum/ammo/bullet/walker/shotgun8g/spread
	bonus_projectiles_amount = EXTRA_PROJECTILES_TIER_3 //у меха проблема с мелкими целями, больших в упор спокойно дамажит, дрон же получит 1 дробинку и оглушится, подставляя, но не нанося серьезного ущерба

/datum/ammo/bullet/walker/shotgun8g/spread
	name = "additional 8 gauge buckshot"
	scatter = SCATTER_AMOUNT_TIER_1
	bonus_projectiles_amount = 0


/datum/ammo/bullet/walker/shotgun8g/on_hit_mob(mob/M,obj/projectile/P)
	knockback(M,P, 3)

/datum/ammo/bullet/walker/shotgun8g/knockback_effects(mob/living/living_mob)
	if(iscarbonsizexeno(living_mob))
		var/mob/living/carbon/xenomorph/target = living_mob
		to_chat(target, SPAN_XENODANGER("You are shaken and slowed by the sudden impact!"))
		target.KnockDown(0.5) // If you ask me the KD should be left out, but players like their visual cues
		target.Stun(0.5)
		target.apply_effect(1, SUPERSLOW)
		target.apply_effect(2, SLOW)
	else
		if(!isyautja(living_mob)) //Not predators.
			living_mob.apply_effect(1, SUPERSLOW)
			living_mob.apply_effect(2, SLOW)
			to_chat(living_mob, SPAN_HIGHDANGER("The impact knocks you off-balance!"))

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

/datum/ammo/rocket/brute/tactical
	max_range = 18
	max_distance = 18




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
	name = "M1488 Tactical Laser-Guided Rocket (x1)"
	contains = list(
		/obj/item/ammo_magazine/rocket/brute/tactical,
	)
	cost = 100
	containertype = /obj/structure/closet/crate/ammo
	containername = "M1488 Tactical Laser-Guided Rocket crate"
	group = "Vehicle Ammo"
