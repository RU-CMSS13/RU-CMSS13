
#define WALKER_HARDPOIN_HEAD "Head"
#define WALKER_HARDPOIN_LEFT_HAND "Left Hand"
#define WALKER_HARDPOIN_RIGHT_HAND "Right Hand"
#define WALKER_HARDPOIN_LEFT_LEG "Left Leg"
#define WALKER_HARDPOIN_RIGHT_LEG "Right Leg"
#define WALKER_HARDPOIN_INTERNAL "Internal"
#define WALKER_HARDPOIN_ARMOR "Armor"
#define WALKER_HARDPOIN_SPINAL "Spinal"

#define VEHICLE_REACTOR_FINE 0
#define VEHICLE_REACTOR_DAMAGE 1
#define VEHICLE_REACTOR_CRITICAL 2

//////////////////////////////////////////////////////////////


/obj/item/hardpoint/walker
	name = "Mecha Hardpoint"
	desc = "Something to place on mech."

	health = 150
	disp_icon = "walker"
	allowed_seat = VEHICLE_DRIVER

/obj/item/hardpoint/walker/proc/pilot_entered(mob/user)
	return

/obj/item/hardpoint/walker/proc/pilot_ejected(mob/user)
	return


//////////////////////////////////////////////////////////////
//REACTOR

/obj/item/hardpoint/walker/reactor
	name = "Mecha Reactor"
	desc = "Self sufficient reactor for power supply of mecha equipment."

	slot = WALKER_HARDPOIN_INTERNAL
	hdpt_layer = HDPT_LAYER_SUPPORT

	var/turned_on = TRUE
	var/rebooting = 0
	var/reboot_time = 5 MINUTES

	var/reactor_state = VEHICLE_REACTOR_FINE
	var/count_down = 0
	var/chance_of_malf = 10

/obj/item/hardpoint/walker/reactor/proc/switch_reactor_operational_state()
	if(rebooting)
		return FALSE

	if(turned_on)
		if(count_down)
			count_down = FALSE
			owner.visible_message(SPAN_WARNING("[owner] burst with steam as [src] turns off."))

		if(owner.seats[VEHICLE_DRIVER])
			to_chat(owner.seats[VEHICLE_DRIVER], SPAN_DANGER("Reactor turned off, it might take up to [reboot_time] minutes for reboot!"))

		turned_on = FALSE
	else
		if(reactor_state == VEHICLE_REACTOR_CRITICAL)
			to_chat(owner.seats[VEHICLE_DRIVER], SPAN_DANGER("It was for sure bad idea to turn on [src] in this state."))
		else
			rebooting = TRUE
			addtimer(VARSET_CALLBACK(src, turned_on, 1), reboot_time, TIMER_DELETE_ME)
			addtimer(VARSET_CALLBACK(src, rebooting, 0), reboot_time, TIMER_DELETE_ME)

/obj/item/hardpoint/walker/reactor/proc/on_consume_enegry_action()
	if(!turned_on)
		return FALSE
	if(!reactor_state)
		return TRUE

	switch(reactor_state)
		if(VEHICLE_REACTOR_DAMAGE)
			if(prob(chance_of_malf / 10))
				turned_on = FALSE
		if(VEHICLE_REACTOR_CRITICAL)
			if(prob(chance_of_malf))
				turned_on = FALSE

	if(turned_on)
		return TRUE

	rebooting = TRUE
	var/time_till_reboot = rand(10, 60)
	addtimer(VARSET_CALLBACK(src, turned_on, 1), time_till_reboot, TIMER_DELETE_ME)
	addtimer(VARSET_CALLBACK(src, rebooting, 0), time_till_reboot, TIMER_DELETE_ME)

	owner.visible_message(SPAN_WARNING("[src] burst in smoke! [owner] turns off due to short circuit."))
	if(owner.seats[VEHICLE_DRIVER])
		to_chat(owner.seats[VEHICLE_DRIVER], SPAN_DANGER("Bzzzzzz. Reactor core unstable, required [reactor_state == VEHICLE_REACTOR_CRITICAL ? "URGENT " : ""]repair. Network reboot in [time_till_reboot / 10] seconds!"))
	return FALSE

/obj/item/hardpoint/walker/reactor/Destroy()
	var/obj/vehicle/walker/vehicle = owner
	if(vehicle)
		vehicle.power_supply = null

	. = ..()

/obj/item/hardpoint/walker/reactor/on_install(obj/vehicle/walker/vehicle)
	vehicle.power_supply = src

/obj/item/hardpoint/walker/reactor/on_uninstall(obj/vehicle/walker/vehicle)
	vehicle.power_supply = null


//////////////////////////////////////////////////////////////
//HEAD

/obj/item/hardpoint/walker/head
	name = "Mecha Head"
	desc = "Protects pilot from potential danger outside mecha."

	slot = WALKER_HARDPOIN_HEAD
	hdpt_layer = HDPT_LAYER_SUPPORT


//////////////////////////////////////////////////////////////
//HANDS

/obj/item/hardpoint/walker/hand
	name = "Mecha Hand"
	desc = "Allows mecha to hold weapons."

	hdpt_layer = HDPT_LAYER_SUPPORT
	firing_arc = 45

	var/mount_class = GUN_MOUNT_MECHA
	var/obj/item/weapon/gun/mounted_gun = null

/obj/item/hardpoint/walker/hand/left
	name = "Left Mecha Hand"
	desc = "Allows mecha to hold weapons."

	slot = WALKER_HARDPOIN_LEFT_HAND

/obj/item/hardpoint/walker/hand/right
	name = "Right Mecha Hand"
	desc = "Allows mecha to hold weapons."

	slot = WALKER_HARDPOIN_RIGHT_HAND


//////////////////////////////////////////////////////////////
//LEGS

/obj/item/hardpoint/walker/leg
	name = "Mecha Leg"
	desc = "Allows mecha to move around."

	hdpt_layer = HDPT_LAYER_SUPPORT

	var/move_delay = 3
	var/move_max_momentum = 3
	var/move_momentum_build_factor = 1.8
	var/move_turn_momentum_loss_factor = 0.6

/obj/item/hardpoint/walker/leg/deactivate()
	owner.move_delay += move_delay
	owner.move_max_momentum -= move_max_momentum
	owner.move_momentum_build_factor -= move_momentum_build_factor
	owner.move_turn_momentum_loss_factor -= move_turn_momentum_loss_factor
	owner.next_move = world.time + owner.move_delay

/obj/item/hardpoint/walker/leg/on_install(obj/vehicle/walker/vehicle)
	if(move_delay)
		vehicle.move_delay -= move_delay
	if(move_max_momentum)
		vehicle.move_max_momentum += move_max_momentum
	if(move_momentum_build_factor)
		vehicle.move_momentum_build_factor += move_momentum_build_factor
	if(move_turn_momentum_loss_factor)
		vehicle.move_turn_momentum_loss_factor += move_turn_momentum_loss_factor
	owner.next_move = world.time + owner.move_delay

/obj/item/hardpoint/walker/leg/on_uninstall(obj/vehicle/walker/vehicle)
	deactivate()

/obj/item/hardpoint/walker/leg/left
	name = "Left Mecha Leg"

	slot = WALKER_HARDPOIN_LEFT_LEG

/obj/item/hardpoint/walker/leg/right
	name = "Right Mecha Leg"

	slot = WALKER_HARDPOIN_RIGHT_LEG


//////////////////////////////////////////////////////////////
//BACK

/obj/item/hardpoint/walker/back
	name = "Mecha Back Hardpoint"
	desc = "Allows special abilities."

	slot = WALKER_HARDPOIN_SPINAL
	hdpt_layer = HDPT_LAYER_SUPPORT


//////////////////////////////////////////////////////////////
//ARMOR

/obj/item/hardpoint/walker/armor
	name = "Armor Hardpoint"
	desc = "Primary armor source."
	icon = 'code_ru/icons/obj/vehicles/mecha_armor.dmi'

	slot = WALKER_HARDPOIN_ARMOR
	hdpt_layer = HDPT_LAYER_ARMOR

	damage_multiplier = 0.5

	health = 1000

/obj/item/hardpoint/walker/armor/paladin
	name = "Paladin Armor"
	desc = "Protects the vehicle from large incoming explosive projectiles."

	icon_state = "paladin_armor"
	disp_icon_state = "paladin_armor"

	type_multipliers = list(
		"all" = 0.95,
		"explosive" = 0.85
	)

/obj/item/hardpoint/walker/armor/concussive
	name = "Concussive Armor"
	desc = "Protects the vehicle from high-impact weapons."

	icon_state = "concussive_armor"
	disp_icon_state = "concussive_armor"

	type_multipliers = list(
		"all" = 0.95,
		"blunt" = 0.85
	)

/obj/item/hardpoint/walker/armor/caustic
	name = "Caustic Armor"
	desc = "Protects vehicles from most types of acid."

	icon_state = "caustic_armor"
	disp_icon_state = "caustic_armor"

	type_multipliers = list(
		"all" = 0.95,
		"acid" = 0.85
	)

/obj/item/hardpoint/walker/armor/fire
	name = "Fire Armor"
	desc = "Protects vehicles from fire."

	icon_state = "caustic_armor"
	disp_icon_state = "caustic_armor"

	type_multipliers = list(
		"all" = 0.95,
		"fire" = 0.2
	)

/obj/item/hardpoint/walker/armor/ballistic
	name = "Ballistic Armor"
	desc = "Protects the vehicle from high-penetration weapons."

	icon_state = "ballistic_armor"
	disp_icon_state = "ballistic_armor"

	type_multipliers = list(
		"all" = 0.95,
		"bullet" = 0.85,
		"slash" = 0.85,
	)


//////////////////////////////////////////////////////////////
//GUNS
/*
/obj/item/hardpoint/walker/weapon
	name = "Walker Gun"
	desc = "Primary gun source."
	icon = 'code_ru/icons/obj/vehicles/mecha_guns.dmi'

	slot = WALKER_HARDPOIN_GUN
	hdpt_layer = HDPT_LAYER_TURRET

	var/obj/item/weapon/gun/mounted_gun = null
*/

/obj/item/hardpoint/walker/hand/Destroy()
	if(mounted_gun)
		QDEL_NULL(mounted_gun.callback_can_fire)
		QDEL_NULL(mounted_gun.callback_can_stop_fire)
		QDEL_NULL(mounted_gun.callback_fire_stat)
		mounted_gun.gun_holder = null
		QDEL_NULL(mounted_gun)

	. = ..()

/obj/item/hardpoint/walker/hand/pilot_entered(mob/user)
	if(!mounted_gun)
		return

	mounted_gun.set_gun_user(user)

/obj/item/hardpoint/walker/hand/pilot_ejected(mob/user)
	if(!mounted_gun)
		return

	mounted_gun.set_gun_user(null)


//////////////////////////////////////////////////////////////
//INTERACTIONS

/obj/item/hardpoint/walker/hand/get_examine_text(mob/user)
	. = ..()

	if(mounted_gun)
		. += "There is \a [mounted_gun] module installed on [src]."
		. += mounted_gun.get_examine_text(user)

/obj/item/hardpoint/walker/hand/proc/try_reload(obj/item/attacking_item, mob/user)
	. = FALSE

	if(istype(attacking_item, /obj/item/ammo_magazine))
		. = TRUE
		mounted_gun.reload(user, attacking_item)
		update_icon()

	if(istype(attacking_item, /obj/item/explosive/grenade))
		. = TRUE
		mounted_gun.on_pocket_attackby(attacking_item, user)
		update_icon()

/obj/item/hardpoint/walker/hand/proc/try_insert(obj/item/attacking_item, mob/user)
	. = FALSE

	if(!isgun(attacking_item) || user.action_busy || mounted_gun)
		return

	var/obj/item/weapon/gun/attacking_gun = attacking_item
	if(attacking_gun.mount_class != mount_class)
		return

	if(!do_after(user, 200, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD, owner) || !mounted_gun)
		return

	if(user.drop_inv_item_to_loc(attacking_gun, src))
		return

	. = TRUE

	playsound(loc, 'sound/items/Crowbar.ogg', 25, 1)
	user.visible_message(SPAN_NOTICE("[user] places [attacking_gun] in [src]."),
	SPAN_NOTICE("You place [attacking_gun] in [src]."))

	name = "[name] with [attacking_gun]"
	mounted_gun = attacking_gun
	mounted_gun.gun_holder = src
	mounted_gun.flags_mounted_gun_features |= GUN_MOUNTED
	mounted_gun.callback_can_fire = CALLBACK(src, PROC_REF(can_fire))
	mounted_gun.callback_can_stop_fire = CALLBACK(src, PROC_REF(can_stop_fire))
	mounted_gun.callback_fire_stat = CALLBACK(src, PROC_REF(guns_debuff))
	update_icon()

/obj/item/hardpoint/walker/hand/proc/try_remove(obj/item/attacking_item, mob/user)
	. = FALSE

	if(!HAS_TRAIT(attacking_item, TRAIT_TOOL_SCREWDRIVER) || !mounted_gun)
		return

	if(user.action_busy || !do_after(user, 200, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD, src) || mounted_gun)
		return

	. = TRUE

	playsound(loc, 'sound/items/Crowbar.ogg', 25, 1)
	user.visible_message(SPAN_NOTICE("[user] removes [mounted_gun] from [src]."),
	SPAN_NOTICE("You remove [mounted_gun] from [src]."))

	QDEL_NULL(mounted_gun.callback_can_fire)
	QDEL_NULL(mounted_gun.callback_can_stop_fire)
	QDEL_NULL(mounted_gun.callback_fire_stat)
	mounted_gun.flags_mounted_gun_features &= ~GUN_MOUNTED
	mounted_gun.gun_holder = null
	user.put_in_hands(mounted_gun)
	mounted_gun = null
	name = initial(name)
	update_icon()

/obj/item/hardpoint/walker/hand/on_install(obj/vehicle/walker/vehicle)
	if(!vehicle.seats[VEHICLE_DRIVER])
		return
	pilot_entered(vehicle.seats[VEHICLE_DRIVER])

/obj/item/hardpoint/walker/hand/on_uninstall(obj/vehicle/walker/vehicle)
	if(!vehicle.seats[VEHICLE_DRIVER])
		return
	pilot_ejected(vehicle.seats[VEHICLE_DRIVER])


//////////////////////////////////////////////////////////////


/obj/item/hardpoint/walker/hand/proc/guns_debuff(obj/projectile/projectile_to_fire, mob/user)
	for(var/obj/item/hardpoint/walker/hand/hardpoint in owner.hardpoints)
		if(hardpoint == src || !hardpoint.mounted_gun)
			continue
		if(hardpoint.mounted_gun.type == mounted_gun.type)
			return list(max(0.1, mounted_gun.accuracy_mult_unwielded - 0.1*rand(5,7)), SCATTER_AMOUNT_TIER_3)

/obj/item/hardpoint/walker/hand/proc/can_fire(datum/source, atom/object, turf/location, control, params)
	var/obj/vehicle/walker/vehicle = owner
	if(!vehicle.power_supply?.on_consume_enegry_action())
		return FALSE

	var/list/modifiers = params2list(params)
	if(!modifiers[LEFT_CLICK] && !modifiers[MIDDLE_CLICK])
		return FALSE

	if(slot == WALKER_HARDPOIN_LEFT_HAND ? !modifiers[LEFT_CLICK] : !modifiers[MIDDLE_CLICK])
		return FALSE

	if(!in_firing_arc(object))
		return FALSE

	return TRUE

/obj/item/hardpoint/walker/hand/proc/can_stop_fire(datum/source, atom/object, turf/location, control, params)
	var/obj/vehicle/walker/vehicle = owner
	if(!vehicle.power_supply?.turned_on)
		return TRUE

	var/list/modifiers = params2list(params)
	if(!modifiers[LEFT_CLICK] && !modifiers[MIDDLE_CLICK])
		return FALSE

	if(slot == WALKER_HARDPOIN_LEFT_HAND ? !modifiers[LEFT_CLICK] : !modifiers[MIDDLE_CLICK])
		return FALSE

	if(slot == WALKER_HARDPOIN_LEFT_HAND ? modifiers[BUTTON] != LEFT_CLICK : modifiers[BUTTON] != MIDDLE_CLICK)
		return FALSE

	return TRUE


//////////////////////////////////////////////////////////////


/obj/item/hardpoint/walker/hand/get_icon_image(x_offset, y_offset, new_dir)
	var/hardpoint = slot == WALKER_HARDPOIN_LEFT_HAND ? "_l_hand" : "_r_hand"
	var/image/self = image(icon = disp_icon, icon_state = "[disp_icon_state + hardpoint]_[health ? "0" : "1"]", pixel_x = x_offset, pixel_y = y_offset, dir = new_dir)
	. = list(self)
	switch(floor((health / initial(health)) * 100))
		if(0)
			self.color = "#888888"
		if(1 to 20)
			self.color = "#4e4e4e"
		if(21 to 40)
			self.color = "#6e6e6e"
		if(41 to 60)
			self.color = "#8b8b8b"
		if(61 to 80)
			self.color = "#bebebe"
		else
			self.color = null

	if(mounted_gun)
		var/image/gun = image(icon = disp_icon, icon_state = "[mounted_gun.icon + hardpoint]_[health ? "0" : "1"]", pixel_x = x_offset, pixel_y = y_offset, dir = new_dir)
		gun.color = self.color
		. += gun


//////////////////////////////////////////////////////////////




















////////////////
// MEGALODON HARDPOINTS // START
////////////////

/obj/item/walker_gun
	name = "walker gun"
	icon = 'code_ru/icons/obj/vehicles/mecha_guns.dmi'
	var/equip_state = ""
	w_class = 12.0
	var/obj/vehicle/walker/owner = null
	var/magazine_type = /obj/item/ammo_magazine/walker
	var/obj/item/ammo_magazine/walker/ammo = null
	var/list/fire_sound = list('sound/weapons/gun_smartgun1.ogg', 'sound/weapons/gun_smartgun2.ogg', 'sound/weapons/gun_smartgun3.ogg')
	var/fire_delay = 0
	var/last_fire = 0

	w_class = 12.0

	var/muzzle_flash = "muzzle_flash"
	var/muzzle_flash_lum = 3 //muzzle flash brightness
	var/list/projectile_traits = list()
	var/automatic = TRUE
	var/shots_fired = 0
	var/fa_firing = FALSE

	var/atom/target = null
	var/scatter_value = 5

	var/autofire_slow_mult = 1

/obj/item/walker_gun/smartgun
	name = "M56 High-Caliber Mounted Smartgun"
	desc = "Modified version of standart USCM Smartgun System, mounted on military walkers"
	icon_state = "mech_smartgun_parts"
	equip_state = "redy_smartgun"
	magazine_type = /obj/item/ammo_magazine/walker/smartgun
	fire_delay = 1

	projectile_traits = list(/datum/element/bullet_trait_iff)

/obj/item/walker_gun/hmg
	name = "M30 Machine Gun"
	desc = "High-caliber machine gun firing small bursts of AP bullets, tearing into shreds unfortunate fellas on its way."
	icon_state = "mech_minigun_parts"
	equip_state = "redy_minigun"
	fire_sound = list('sound/weapons/gun_minigun.ogg')
	magazine_type = /obj/item/ammo_magazine/walker/hmg
	fire_delay = 2.7
	scatter_value = 40

	projectile_traits = list()

/obj/item/walker_gun/shotgun8g
	name = "M32 Mounted Shotgun"
	desc = "8 Gauge shotgun firing wave of AP bullets ineffective at distance, mounted on military walkers for devastation pacify"
	icon_state = "mech_shotgun8g_parts"
	equip_state = "redy_shotgun8g"
	fire_sound = list('sound/weapons/gun_type23.ogg')
	magazine_type = /obj/item/ammo_magazine/walker/shotgun8g
	fire_delay = 11
	scatter_value = 0
	automatic = FALSE


/obj/item/walker_gun/flamer
	name = "F40 \"Hellfire\" Flamethower"
	desc = "Powerful flamethower, that can send any unprotected target straight to hell."
	icon_state = "mech_flamer_parts"
	equip_state = "redy_flamer"
	fire_sound = 'sound/weapons/gun_flamethrower2.ogg'
	magazine_type = /obj/item/ammo_magazine/walker/flamer
	var/fuel_pressure = 1 //Pressure setting of the attached fueltank, controls how much fuel is used per tile
	var/max_range = 9 //9 tiles, 7 is screen range, controlled by the type of napalm in the canister. We max at 9 since diagonal bullshit.
	fire_delay = 4 SECONDS

	automatic = FALSE














/*
///////////////
// AMMO MAGS // START
///////////////

/obj/item/ammo_magazine/walker
	w_class = SIZE_LARGE
	icon = 'code_ru/icons/obj/vehicles/mecha_guns.dmi'

/obj/item/ammo_magazine/walker/smartgun
	name = "M56 Double-Barrel Magazine (Standard)"
	desc = "A armament MG magazine"
	caliber = "10x28mm" //Correlates to smartguns
	icon_state = "mech_smartgun_ammo"
	default_ammo = /datum/ammo/bullet/walker/smartgun
	max_rounds = 700
	gun_type = /obj/item/walker_gun/smartgun

/obj/item/ammo_magazine/walker/hmg
	name = "M30 Machine Gun Magazine"
	desc = "A armament M30 magazine"
	icon_state = "mech_minigun_ammo"
	max_rounds = 400
	default_ammo = /datum/ammo/bullet/walker/machinegun
	gun_type = /obj/item/walker_gun/hmg

/obj/item/ammo_magazine/walker/shotgun8g
	name = "M32 Mounted Shotgun Magazine"
	desc = "A armament M32 magazine"
	icon_state = "mech_shotgun8g_ammo"
	max_rounds = 60
	default_ammo = /datum/ammo/bullet/walker/shotgun8g
	gun_type = /obj/item/walker_gun/shotgun8g


/obj/item/ammo_magazine/walker/flamer
	name = "F40 UT-Napthal Canister"
	desc = "Canister for mounted flamethower"
	icon_state = "mech_flamer_s_ammo"
	max_rounds = 300
	default_ammo = /datum/ammo/flamethrower
	gun_type = /obj/item/walker_gun/flamer
	flags_magazine = AMMUNITION_HIDE_AMMO

	var/flamer_chem = "utnapthal"

	var/max_intensity = 40
	var/max_range = 5
	var/max_duration = 30

	var/fuel_pressure = 1 //How much fuel is used per tile fired
	var/max_pressure = 10

/obj/item/ammo_magazine/walker/flamer/Initialize(mapload, ...)
	. = ..()
	create_reagents(max_rounds)

	if(flamer_chem)
		reagents.add_reagent(flamer_chem, max_rounds)

	reagents.min_fire_dur = 1
	reagents.min_fire_int = 1
	reagents.min_fire_rad = 1

	reagents.max_fire_dur = max_duration
	reagents.max_fire_rad = max_range
	reagents.max_fire_int = max_intensity

/obj/item/ammo_magazine/walker/flamer/get_ammo_percent()
	if(!reagents)
		return 0

	return 100 * (reagents.total_volume / max_rounds)

/obj/item/ammo_magazine/walker/flamer/btype
	name = "F40 UT-Napthal B-type Canister"
	desc = "Canister for mounted flamethower"
	icon_state = "mech_flamer_b_ammo"
	max_rounds = 300
	default_ammo = /datum/ammo/flamethrower
	gun_type = /obj/item/walker_gun/flamer

	flamer_chem = "napalmb"

	max_intensity = 40
	max_range = 5
	max_duration = 30

	fuel_pressure = 1 //How much fuel is used per tile fired
	max_pressure = 10

///////////////
// AMMO MAGS // END
///////////////

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
*/
////////////////
// MEGALODON HARDPOINTS // END
////////////////

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
		/obj/item/ammo_magazine/walker/flamer,
		/obj/item/ammo_magazine/walker/flamer/btype,
	)
	cost = 20
	containertype = /obj/structure/closet/crate/ammo
	containername = "F40 Flamethower ammo crate"
	group = "Vehicle Ammo"

////////////////
// MEGALODON SUPPLYPACKS // END
////////////////
