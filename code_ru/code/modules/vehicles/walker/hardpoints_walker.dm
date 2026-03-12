
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

	icon = 'code_ru/icons/obj/vehicles/mech_hardpoints.dmi'
	icon_state = "mech_part"
	disp_icon = 'code_ru/icons/obj/vehicles/mech.dmi'
	disp_icon_state = "mech_part"

	damage_multiplier = 0.5
	material_per_repair = 1
	repair_materials = list("plastic" = 0.5, "metal" = 0.10)

	health = 150
	max_health = 150
	allowed_seat = VEHICLE_DRIVER

/obj/item/hardpoint/walker/ex_act(severity)
	if(owner || explo_proof)
		return

	take_damage_type(list(0, severity / 2 * owner.get_dmg_multi(type)), "explosive", "explosion")

/obj/item/hardpoint/walker/proc/tgui_additional_data(list/tgui_data)
	. = tgui_data

	.["integrity"] = "[health / max_health * 100]"

/obj/item/hardpoint/walker/proc/take_damage_type(list/damages_applied, type, atom/attacker, damage_to_apply, real_damage)
	if(!damage_to_apply)
		damage_to_apply = damages_applied[2]
	if(!real_damage)
		real_damage = damage_to_apply * damage_multiplier

	damages_applied[2] -= real_damage
	damages_applied[1] += real_damage
	health = max(0, health - real_damage)
	if(!health)
		if(owner)
			deactivate()
			remove_buff(owner)
		on_destroy()
	update_icon()

/obj/item/hardpoint/walker/proc/pilot_entered(mob/user)
	return

/obj/item/hardpoint/walker/proc/pilot_ejected(mob/user)
	return


//////////////////////////////////////////////////////////////
// REACTOR

/obj/item/hardpoint/walker/reactor
	name = "Shielded Mecha Reactor"
	desc = "Self sufficient reactor for power supply of mecha equipment."

	slot = WALKER_HARDPOIN_INTERNAL
	hdpt_layer = HDPT_LAYER_SUPPORT

	damage_multiplier = 0.1
	repair_materials = list("metal" = 0.5, "plasteel" = 0.10)

	var/turned_on = TRUE
	var/rebooting = FALSE
	var/count_down = FALSE

	var/reboot_time = 2.5 MINUTES
	var/meltdown_time = 1 MINUTES
	var/meltdown_timer_id = null

	var/reactor_state = VEHICLE_REACTOR_FINE
	var/chance_of_malf = 10

	var/list/reactor_sounds = list('code_ru/sound/effects/switch.ogg', 'code_ru/sound/effects/switch2.ogg', 'code_ru/sound/effects/switch3.ogg')
	var/obj/item/fuel_cell/reactor/fuel

/obj/item/hardpoint/walker/reactor/Destroy()
	var/obj/vehicle/walker/vehicle = owner
	if(vehicle)
		vehicle.power_supply = null

	QDEL_NULL(fuel)

	. = ..()

/obj/item/hardpoint/walker/reactor/recovered()
	deltimer(meltdown_timer_id)
	meltdown_timer_id = null
	reactor_state = VEHICLE_REACTOR_FINE

/obj/item/hardpoint/walker/reactor/material_use(obj/item/tool/weldingtool/welder, mob/user, modificator = 4)
	if(reactor_state)
		modificator *= reactor_state / 2

	. = ..(welder, user, modificator)

/obj/item/hardpoint/walker/reactor/tgui_additional_data()
	. = ..()

	.["value_name"] = "Fuel"
	.["current_rounds"] = "[fuel.fuel_amount]"
	.["max_rounds"] = "[fuel.max_fuel_amount]"

/obj/item/hardpoint/walker/reactor/take_damage_type(list/damages_applied, type, atom/attacker, damage_to_apply, real_damage)
	if(!damage_to_apply || !real_damage)
		damage_to_apply = round(damages_applied[2])
		real_damage = damage_to_apply * damage_multiplier

	if(reactor_state < VEHICLE_REACTOR_CRITICAL && prob(real_damage / (chance_of_malf / 2)))
		reactor_state++
		if(reactor_state == VEHICLE_REACTOR_CRITICAL)
			count_down = TRUE
			meltdown_timer_id = addtimer(CALLBACK(src, PROC_REF(meltdown)), meltdown_time, TIMER_STOPPABLE|TIMER_UNIQUE|TIMER_DELETE_ME)

	. = ..(damages_applied, type, attacker, damage_to_apply, real_damage)

/obj/item/hardpoint/walker/reactor/proc/meltdown()
	var/datum/cause_data/cause = create_cause_data("Reactor meltdown")
	var/obj/vehicle/walker/vehicle = owner
	if(vehicle?.seats[VEHICLE_DRIVER])
		vehicle.seats[VEHICLE_DRIVER].unset_interaction()
		vehicle.power_supply = null

	cell_explosion(get_turf(src), 1000, 300, EXPLOSION_FALLOFF_SHAPE_LINEAR, null, cause)

/obj/item/hardpoint/walker/reactor/proc/switch_reactor_operational_state()
	if(rebooting)
		return FALSE

	if(turned_on)
		if(count_down)
			count_down = FALSE
			owner.visible_message(SPAN_WARNING("[owner] burst with steam as [src] turns off."))

		if(owner.seats[VEHICLE_DRIVER])
			to_chat(owner.seats[VEHICLE_DRIVER], SPAN_DANGER("Reactor turned off, it might take up to [reboot_time / 10] seconds for reboot!"))

		playsound(get_turf(src), pick(reactor_sounds), 25, 1)
		turned_on = FALSE
	else
		if(reactor_state == VEHICLE_REACTOR_CRITICAL)
			to_chat(owner.seats[VEHICLE_DRIVER], SPAN_DANGER("It was for sure bad idea to turn on [src] in this state."))
		else
			playsound(get_turf(src), pick(reactor_sounds), 25, 1)
			to_chat(owner.seats[VEHICLE_DRIVER], SPAN_WARNING("Booting up reactor, it might take you to [reboot_time / 10] seconds"))

			rebooting = TRUE
			addtimer(VARSET_CALLBACK(src, turned_on, 1), reboot_time, TIMER_DELETE_ME)
			addtimer(VARSET_CALLBACK(src, rebooting, 0), reboot_time, TIMER_DELETE_ME)

/obj/item/hardpoint/walker/reactor/proc/replace_fuel(obj/new_fuel, mob/user)
	if(user.skills.get_skill_level(SKILL_POWERLOADER) <= SKILL_POWERLOADER_DEFAULT)
		to_chat(user, "You dont know how to operate it")
		return

	if(!do_after(user, 10 SECONDS, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_GENERIC, owner, INTERRUPT_MOVED))
		return FALSE

	playsound(get_turf(src), pick(reactor_sounds), 25, 1)
	fuel.forceMove(get_turf(src))
	new_fuel.forceMove(src)
	fuel = new_fuel
	return TRUE

/obj/item/hardpoint/walker/reactor/proc/on_consume_enegry_action()
	if(!turned_on)
		return FALSE
	if(!fuel.fuel_amount)
		turned_on = FALSE
		return FALSE
	if(!reactor_state)
		fuel.fuel_amount = max(0, fuel.fuel_amount - 1)
		return TRUE

	switch(reactor_state)
		if(VEHICLE_REACTOR_DAMAGE)
			if(prob(chance_of_malf / 10))
				turned_on = FALSE
		if(VEHICLE_REACTOR_CRITICAL)
			if(prob(chance_of_malf))
				turned_on = FALSE

	if(turned_on)
		fuel.fuel_amount = max(0, fuel.fuel_amount - 1)
		return TRUE

	rebooting = TRUE
	var/time_till_reboot = rand(10, 60)
	addtimer(VARSET_CALLBACK(src, turned_on, 1), time_till_reboot, TIMER_DELETE_ME)
	addtimer(VARSET_CALLBACK(src, rebooting, 0), time_till_reboot, TIMER_DELETE_ME)

	owner.visible_message(SPAN_WARNING("[src] burst in smoke! [owner] turns off due to short circuit."))
	if(owner.seats[VEHICLE_DRIVER])
		to_chat(owner.seats[VEHICLE_DRIVER], SPAN_DANGER("Bzzzzzz. Reactor core unstable, required [reactor_state == VEHICLE_REACTOR_CRITICAL ? "URGENT " : ""]repair. Network reboot in [time_till_reboot / 10] seconds!"))
	return FALSE

/obj/item/hardpoint/walker/reactor/on_install(obj/vehicle/walker/vehicle)
	vehicle.power_supply = src

/obj/item/hardpoint/walker/reactor/on_uninstall(obj/vehicle/walker/vehicle)
	vehicle.power_supply = null


/obj/item/hardpoint/walker/reactor/enhanced
	name = "Enhanced Mecha Reactor"
	desc = "Self sufficient reactor for power supply of mecha equipment."


//////////////////////////////////////////////////////////////
// HEAD

/obj/item/hardpoint/walker/head
	name = "Mecha Head"
	desc = "Protects pilot from potential danger outside mecha."

	slot = WALKER_HARDPOIN_HEAD
	hdpt_layer = HDPT_LAYER_SUPPORT
	destruction_on_zero = FALSE

/obj/item/hardpoint/walker/head/on_destroy()
	return

//////////////////////////////////////////////////////////////
// HANDS

/obj/item/hardpoint/walker/hand
	name = "Mecha Hand"
	desc = "Allows mecha to hold weapons."

	hdpt_layer = HDPT_LAYER_SUPPORT
	firing_arc = 45
	destruction_on_zero = FALSE

	var/mount_class = GUN_MOUNT_MECHA
	var/obj/item/weapon/gun/mounted_gun = null

/obj/item/hardpoint/walker/hand/on_destroy()
	return

/obj/item/hardpoint/walker/hand/left
	name = "Left Mecha Hand"
	desc = "Allows mecha to hold weapons."

	slot = WALKER_HARDPOIN_LEFT_HAND

/obj/item/hardpoint/walker/hand/right
	name = "Right Mecha Hand"
	desc = "Allows mecha to hold weapons."

	slot = WALKER_HARDPOIN_RIGHT_HAND


//////////////////////////////////////////////////////////////
// LEGS

/obj/item/hardpoint/walker/leg
	name = "Mecha Leg"
	desc = "Allows mecha to move around."

	hdpt_layer = HDPT_LAYER_SUPPORT
	destruction_on_zero = FALSE

	var/move_delay = 3
	var/move_max_momentum = 2
	var/move_turn_momentum_loss_factor = 0.25
	var/move_momentum_build_factor = 0.5

/obj/item/hardpoint/walker/leg/on_destroy()
	return

/obj/item/hardpoint/walker/leg/deactivate()
	var/obj/vehicle/walker/vehicle
	vehicle.recalculate_legs()

/obj/item/hardpoint/walker/leg/on_install(obj/vehicle/walker/vehicle)
	if(!health)
		return

	vehicle.recalculate_legs()

/obj/item/hardpoint/walker/leg/on_uninstall(obj/vehicle/walker/vehicle)
	deactivate()

/obj/item/hardpoint/walker/leg/left
	name = "Left Mecha Leg"

	slot = WALKER_HARDPOIN_LEFT_LEG

/obj/item/hardpoint/walker/leg/right
	name = "Right Mecha Leg"

	slot = WALKER_HARDPOIN_RIGHT_LEG


//////////////////////////////////////////////////////////////
// BACK

/obj/item/hardpoint/walker/back
	name = "Mecha Back Hardpoint"
	desc = "Allows special abilities."

	icon = 'code_ru/icons/obj/vehicles/mech_back.dmi'

	slot = WALKER_HARDPOIN_SPINAL
	hdpt_layer = HDPT_LAYER_SUPPORT

/obj/item/hardpoint/walker/back/powerful_cooling
	name = "Active Mecha Cooling"
	desc = "This very powerful cooling can take twice as much heat out of system! Allows do actions much faster."


/obj/item/hardpoint/walker/back/artilery
	name = "Detection Array \"Night Hawk\""
	desc = "Grant precision vision over entire battle field via special equipment of this hardpoint, additionaly grants very powerful motion detector at cost of faster reactor consumption."

	var/zoom_size = 12
	var/obj/item/device/motiondetector/walker/motion_detector

/obj/item/hardpoint/walker/back/artilery/Initialize()
	. = ..()

	motion_detector = new(src)
	motion_detector.owner = src

/obj/item/hardpoint/walker/back/artilery/Destroy()
	. = ..()

	motion_detector.owner = null
	QDEL_NULL(motion_detector)

/obj/item/hardpoint/walker/back/artilery/pilot_entered(mob/user)
	motion_detector.iff_signal = user.faction

/obj/item/hardpoint/walker/back/artilery/pilot_ejected(mob/user)
	return

/obj/item/device/motiondetector/walker
	detector_range = 24

	var/obj/item/hardpoint/walker/back/artilery/owner

/obj/item/device/motiondetector/walker/get_user()
	return owner?.owner?.seats[VEHICLE_DRIVER]


/obj/item/hardpoint/walker/back/tactical_rocket
	name = "Tactical Rocket Unit"
	desc = "\"Special Deliver Package System\" includes a pair of heavy binoculars with laser aiming device, and bunker buster rocket. However due to only ground spotting and no remote, you have guide it at all the flight time for good hits."


/obj/item/hardpoint/walker/back/shield
	name = "Resonation Projecting System \"F35\""
	desc = "This modification grants you unvulnereability, as long as you have unlimited source of energy."

	var/damage_capacity = 200
	var/max_damage_capacity = 200
	var/cooldown_end_time = 0
	var/delay_between_hits = 10 SECONDS

/obj/item/hardpoint/walker/back/shield/Initialize()
	. = ..()

	START_PROCESSING(SSobj, src)

/obj/item/hardpoint/walker/back/shield/Destroy()
	. = ..()

	STOP_PROCESSING(SSobj, src)

/obj/item/hardpoint/walker/back/shield/proc/take_hits(list/damages_applied)
	cooldown_end_time = world.time + delay_between_hits
	if(!damage_capacity)
		return FALSE

	damage_capacity -= damages_applied[2]
	if(damage_capacity < 0)
		damage_capacity = 0
		cooldown_end_time = world.time + delay_between_hits * 6
		owner.visible_message(SPAN_WARNING("Arc of sparks coming out from [src] installed on [owner]. Seems it got disabled for sufficient time!"))
		if(owner.seats[VEHICLE_DRIVER])
			to_chat(owner.seats[VEHICLE_DRIVER], SPAN_DANGER("SHIELD DISABLED, main system frame overloded. Rebooting, ETA: [delay_between_hits / 10] seconds"))
	return TRUE

/obj/item/hardpoint/walker/back/shield/process()
	if(cooldown_end_time > world.time)
		return

	damage_capacity = min(damage_capacity + 2, max_damage_capacity)


/obj/item/hardpoint/walker/back/jetpack
	name = "Mecha Jetpack"
	desc = "Special \"B-2 Spirit\" modification, spread democracy where nobody can reach! Jump in and even faster move out of combat zone after delivering payload."


//////////////////////////////////////////////////////////////
// ARMOR

/obj/item/hardpoint/walker/armor
	name = "Armor Hardpoint"
	desc = "Primary armor source."

	icon = 'code_ru/icons/obj/vehicles/mech_armor.dmi'

	slot = WALKER_HARDPOIN_ARMOR
	hdpt_layer = HDPT_LAYER_ARMOR

	health = 500
	max_health = 500

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

	icon_state = "concussive_armor"
	disp_icon_state = "concussive_armor"

	type_multipliers = list(
		"all" = 0.95,
		"fire" = 0
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
// GUNS

/obj/item/hardpoint/walker/hand/tgui_additional_data()
	. = ..()

	.["value_name"] = "Ammo"
	.["current_rounds"] = "[mounted_gun.current_mag.reagents?.total_volume || mounted_gun.current_mag.current_rounds]"
	.["max_rounds"] = "[mounted_gun.current_mag.max_rounds]"

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
// INTERACTIONS

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

	if(!do_after(user, 200, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD, owner, INTERRUPT_MOVED) || !mounted_gun)
		return

	if(user.drop_inv_item_to_loc(attacking_gun, src))
		return

	. = TRUE

	playsound(get_turf(src), 'sound/items/Crowbar.ogg', 25, 1)
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

	if(user.action_busy || !do_after(user, 200, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD, owner, INTERRUPT_MOVED) || mounted_gun)
		return

	. = TRUE

	playsound(get_turf(src), 'sound/items/Crowbar.ogg', 25, 1)
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
	if(!vehicle.power_supply?.on_consume_enegry_action() || !health)
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
	if(!vehicle.power_supply?.turned_on || !health)
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
	var/image/self = image(icon = disp_icon, icon_state = "[disp_icon_state + hardpoint]", pixel_x = x_offset, pixel_y = y_offset, dir = new_dir)
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
		var/image/gun = image(icon = disp_icon, icon_state = "[mounted_gun.item_state + hardpoint]", pixel_x = x_offset, pixel_y = y_offset, dir = new_dir)
		gun.color = self.color
		. += gun




//////////////////////////////////////////////////////////////
// GUNS

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

/obj/item/weapon/gun/mounted/mecha_smartgun/set_gun_config_values()
	. = ..()

	set_fire_delay(FIRE_DELAY_TIER_SMG)

	fa_scatter_peak = FULL_AUTO_SCATTER_PEAK_TIER_8
	fa_max_scatter = SCATTER_AMOUNT_TIER_9

	accuracy_mult += HIT_ACCURACY_MULT_TIER_3

	scatter = SCATTER_AMOUNT_TIER_10
	recoil = RECOIL_OFF

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

/obj/item/weapon/gun/mounted/mecha_hmg/set_gun_config_values()
	. = ..()

	set_fire_delay(FIRE_DELAY_TIER_12)

	fa_scatter_peak = FULL_AUTO_SCATTER_PEAK_TIER_8
	fa_max_scatter = SCATTER_AMOUNT_TIER_9

	accuracy_mult += HIT_ACCURACY_MULT_TIER_1

	scatter = SCATTER_AMOUNT_TIER_6
	recoil = RECOIL_AMOUNT_TIER_3

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

	var/basic_fire_delay = FIRE_DELAY_TIER_1 + FIRE_DELAY_TIER_8
	var/overheat_reset_cooldown = 3 SECONDS
	var/overheat_rate = 2
	var/overheat = 0
	var/overheat_upper_limit = 8
	var/overheat_self_destruction_rate = 5 //при финальном перегреве начнет получать урон при стрельбе умноженный на перегрев
	var/steam_effect = /obj/effect/particle_effect/smoke/bad/wm88

/obj/item/weapon/gun/mounted/mecha_wm88/Initialize(mapload)
	. = ..()

	RegisterSignal(src, COMSIG_GUN_BEFORE_FIRE, PROC_REF(apply_effect))
	RegisterSignal(src, COMSIG_MOB_FIRED_GUN, PROC_REF(after_fire_effect))

/obj/item/weapon/gun/mounted/mecha_wm88/Destroy()
	UnregisterSignal(src, list(COMSIG_MOB_FIRED_GUN, COMSIG_GUN_BEFORE_FIRE))

	. = ..()

/obj/item/weapon/gun/mounted/mecha_wm88/set_gun_config_values()
	. = ..()

	set_fire_delay(basic_fire_delay)

	fa_scatter_peak = FULL_AUTO_SCATTER_PEAK_TIER_8
	fa_max_scatter = SCATTER_AMOUNT_TIER_9

	accuracy_mult += HIT_ACCURACY_MULT_TIER_5

	scatter = SCATTER_AMOUNT_NONE
	recoil = RECOIL_AMOUNT_TIER_3

	damage_mult = BASE_BULLET_DAMAGE_MULT

/obj/item/weapon/gun/mounted/mecha_wm88/set_bullet_traits()
	LAZYADD(traits_to_give, list(
		BULLET_TRAIT_ENTRY_ID("iff", /datum/element/bullet_trait_iff)
	))

/obj/item/weapon/gun/mounted/mecha_wm88/proc/apply_effect(obj/item/proj, atom/target, mob/living/user)
	if(!overheat)
		return
	switch(overheat)
		if(2)
			current_mag.default_ammo = GLOB.ammo_list[/datum/ammo/bullet/walker/wm88/a20]
		if(4)
			current_mag.default_ammo = GLOB.ammo_list[/datum/ammo/bullet/walker/wm88/a30]
		if(6)
			current_mag.default_ammo = GLOB.ammo_list[/datum/ammo/bullet/walker/wm88/a40]
		if(8)
			current_mag.default_ammo = GLOB.ammo_list[/datum/ammo/bullet/walker/wm88/a50]

/obj/item/weapon/gun/mounted/mecha_wm88/proc/after_fire_effect(mob/living/user)
	if(overheat == overheat_upper_limit)
		var/turf/T = get_turf(src)
		new steam_effect(T)
		var/damage = overheat_self_destruction_rate * overheat
		var/obj/item/hardpoint/walker/hand = gun_holder
		hand.owner.take_damage_type(damage, "abstract", src)
	else if(overheat < overheat_upper_limit)
		overheat += overheat_rate
	set_fire_delay(basic_fire_delay - overheat)

	addtimer(CALLBACK(src, PROC_REF(reset_overheat_buff), user), overheat_reset_cooldown, TIMER_OVERRIDE|TIMER_UNIQUE|TIMER_DELETE_ME)

/obj/item/weapon/gun/mounted/mecha_wm88/proc/reset_overheat_buff(mob/user)
	SIGNAL_HANDLER
	to_chat(user, SPAN_WARNING("[src] beeps as it's extinguish."))
	overheat = 0
	current_mag.default_ammo = GLOB.ammo_list[/datum/ammo/bullet/walker/wm88]
	set_fire_delay(basic_fire_delay)

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

/obj/item/weapon/gun/launcher/grenade/mounted/afterattack(atom/target, mob/user, proximity_flag, click_parameters, force = FALSE)
	if(!force)
		return
	. = ..()
// FUCK them ALIVE to DEATH

/obj/item/weapon/gun/launcher/grenade/mounted/update_icon()
	return


//////////////////////////////////////////////////////////////


/obj/item/weapon/gun/launcher/grenade/mounted/mecha_grenade_launcher
	name = "Heavy Grenadelauncher"
	desc = "Heavy Grenadelauncher."

	icon_state = "mech_smartgun_parts"
	item_state = "redy_smartgun"

	preload = /obj/item/explosive/grenade/incendiary/airburst

	is_lobbing = TRUE
	direct_draw = FALSE
	internal_slots = 24

/obj/item/weapon/gun/launcher/grenade/mounted/mecha_grenade_launcher/set_gun_config_values()
	. = ..()

	set_fire_delay(FIRE_DELAY_TIER_4*2)




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

	current_mag = /obj/item/ammo_magazine/rocket/brute/tactical

	var/f_aiming_time = 30 SECONDS
	var/aiming = FALSE

/obj/item/weapon/gun/launcher/rocket/mounted/mecha_tactical_missile/handle_fire(atom/target, mob/living/user, params, reflex = FALSE, dual_wield, check_for_attachment_fire, akimbo, fired_by_akimbo)
	if(aiming)
		return

	if(!(istype(target, /obj/structure) || istype(target, /turf/closed/wall)))
		to_chat(user, SPAN_WARNING("Invalid target!"))
		return

	var/list/turf/path = get_line(user, target, include_start_atom = FALSE)
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
	laser_beam = target.beam(user, beam, 'icons/effects/beam.dmi', (f_aiming_time + 1 SECONDS), beam_type = /obj/effect/ebeam/laser/intense)
	laser_beam.visuals.alpha = 0
	animate(laser_beam.visuals, alpha = initial(laser_beam.visuals.alpha), f_aiming_time, easing = SINE_EASING|EASE_OUT)

	if(do_after(user, f_aiming_time, INTERRUPT_ALL, BUSY_ICON_HOSTILE))
		if(!QDELETED(target))
			. = ..()

	target.overlays -= lockon_icon
	target.overlays -= lockon_direction_icon
	qdel(laser_beam)
	aiming = FALSE

/obj/item/weapon/gun/launcher/rocket/mounted/tactical_missile/make_rocket(mob/user, drop_override = 0, empty = 1)
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


/obj/item/weapon/gun/shotgun/mounted/mecha_shotgun8g
	name = "M32 Mounted Shotgun"
	desc = "8 Gauge shotgun firing wave of AP bullets ineffective at distance, mounted on military walkers for devastation pacify"

	icon_state = "mech_shotgun8g_parts"
	item_state = "redy_shotgun8g"

	current_mag = /obj/item/ammo_magazine/walker/shotgun8g
	fire_sound = list('sound/weapons/gun_type23.ogg')

/obj/item/weapon/gun/shotgun/mounted/mecha_shotgun8g/set_gun_config_values()
	. = ..()

	set_fire_delay(FIRE_DELAY_TIER_2)




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

	current_mag = /obj/item/ammo_magazine/walker/flamer
	fire_sound = list('sound/weapons/gun_flamethrower2.ogg')




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
	gun_type = /obj/item/weapon/gun/shotgun/mounted/mecha_shotgun8g


/obj/item/ammo_magazine/walker/flamer
	name = "F40 UT-Napthal Canister"
	desc = "Canister for mounted flamethower"
	icon_state = "mech_flamer_s_ammo"
	max_rounds = 300
	default_ammo = /datum/ammo/flamethrower
	gun_type = /obj/item/weapon/gun/flamer/mounted/mecha_flamer
	flags_magazine = AMMUNITION_HIDE_AMMO

	var/flamer_chem = "utnapthal"

	var/max_intensity = 40
	var/max_range = 5
	var/max_duration = 30

	var/fuel_pressure = 1 //How much fuel is used per tile fired
	var/max_pressure = 10

/obj/item/ammo_magazine/walker/flamer/Initialize(mapload)
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
	gun_type = /obj/item/weapon/gun/flamer/mounted/mecha_flamer

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
		/obj/item/ammo_magazine/walker/flamer,
		/obj/item/ammo_magazine/walker/flamer/btype,
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

/datum/supply_packs/ammo_wm88_walker
	name = "M1488 Tactical Laser-Guided Rocket (x1)"
	contains = list(
		/obj/item/ammo_magazine/rocket/brute/tactical,
	)
	cost = 100
	containertype = /obj/structure/closet/crate/ammo
	containername = "M1488 Tactical Laser-Guided Rocket crate"
	group = "Vehicle Ammo"


#undef VEHICLE_REACTOR_FINE
#undef VEHICLE_REACTOR_DAMAGE
#undef VEHICLE_REACTOR_CRITICAL
