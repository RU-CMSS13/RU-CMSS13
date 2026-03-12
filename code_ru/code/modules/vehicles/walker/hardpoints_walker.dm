
#define WALKER_HARDPOIN_HEAD "Head"
#define WALKER_HARDPOIN_LEFT_HAND "Left Hand"
#define WALKER_HARDPOIN_RIGHT_HAND "Right Hand"
#define WALKER_HARDPOIN_LEFT_LEG "Left Leg"
#define WALKER_HARDPOIN_RIGHT_LEG "Right Leg"
#define WALKER_HARDPOIN_INTERNAL "Internal"
#define WALKER_HARDPOIN_ARMOR "Armor"
#define WALKER_HARDPOIN_SPINAL "Spinal"

#define SELECTED_GROUP_HANDS list(WALKER_HARDPOIN_LEFT_HAND, WALKER_HARDPOIN_RIGHT_HAND)
#define SELECTED_GROUP_SPINAL list(WALKER_HARDPOIN_SPINAL)

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

	var/mount_class = GUN_MOUNT_NO
	var/obj/item/weapon/gun/mounted_gun = null

/obj/item/hardpoint/walker/get_icon_image(x_offset, y_offset, new_dir, type_slot)
	var/image/self = image(icon = disp_icon, icon_state = "[disp_icon_state + type_slot]", pixel_x = x_offset, pixel_y = y_offset, dir = new_dir)
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

/obj/item/hardpoint/walker/get_origin_turf()
	return get_turf(src)

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
	if(!health && owner)
		deactivate(owner)
		remove_buff(owner)

/obj/item/hardpoint/walker/proc/pilot_entered(mob/user)
	if(!mounted_gun)
		return

	var/obj/vehicle/walker/source = owner
	if(slot in source.selected_group)
		mounted_gun.set_gun_user(user)

/obj/item/hardpoint/walker/proc/pilot_ejected(mob/user)
	if(!mounted_gun)
		return
	mounted_gun.set_gun_user(null)


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

/obj/item/hardpoint/walker/reactor/Initialize()
	. = ..()

	fuel = new(src)

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
	if(fuel)
		fuel.forceMove(get_turf(src))
	user.drop_inv_item_to_loc(new_fuel, src)
	fuel = new_fuel
	return TRUE

/obj/item/hardpoint/walker/reactor/proc/on_consume_enegry_action()
	if(!turned_on)
		return FALSE
	if(!fuel?.fuel_amount)
		turned_on = FALSE
		return FALSE

	fuel.fuel_amount = max(0, fuel.fuel_amount - 1)
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

	icon = 'code_ru/icons/obj/vehicles/mech_armor.dmi'
	icon_state = "cockpit_glass"
	disp_icon_state = "mech_cockpit"

	slot = WALKER_HARDPOIN_HEAD
	hdpt_layer = HDPT_LAYER_SUPPORT
	destruction_on_zero = FALSE


/obj/item/hardpoint/walker/head/get_icon_image(x_offset, y_offset, new_dir, type_slot)
	if(owner?.seats[VEHICLE_DRIVER])
		type_slot = "_closed"
	else
		type_slot = "_open"

	. = ..(x_offset, y_offset, new_dir, type_slot)


//////////////////////////////////////////////////////////////
// HANDS

/obj/item/hardpoint/walker/hand
	name = "Mecha Hand"
	desc = "Allows mecha to hold weapons."

	hdpt_layer = HDPT_LAYER_SUPPORT
	firing_arc = 45
	destruction_on_zero = FALSE

	mount_class = GUN_MOUNT_MECHA

/obj/item/hardpoint/walker/hand/get_icon_image(x_offset, y_offset, new_dir, type_slot)
	type_slot = slot == WALKER_HARDPOIN_LEFT_HAND ? "_l_hand" : "_r_hand"

	. = ..(x_offset, y_offset, new_dir, type_slot)

	if(mounted_gun)
		var/image/gun = image(icon = disp_icon, icon_state = "[mounted_gun.item_state + type_slot]", pixel_x = x_offset, pixel_y = y_offset, dir = new_dir)
		var/image/self = .[1]
		gun.color = self.color
		. += gun

/obj/item/hardpoint/walker/hand/tgui_additional_data()
	. = ..()

	.["value_name"] = "Ammo"
	if(!mounted_gun?.current_mag)
		return

	.["current_rounds"] = "[mounted_gun.current_mag.reagents?.total_volume || mounted_gun.current_mag.current_rounds]"
	.["max_rounds"] = "[mounted_gun.current_mag.max_rounds]"

/obj/item/hardpoint/walker/hand/check_modifiers(modifiers, button = FALSE)
	if(slot == WALKER_HARDPOIN_LEFT_HAND ? !modifiers[LEFT_CLICK] : !modifiers[MIDDLE_CLICK])
		return FALSE

	if(button && (slot == WALKER_HARDPOIN_LEFT_HAND ? modifiers[BUTTON] != LEFT_CLICK : modifiers[BUTTON] != MIDDLE_CLICK))
		return FALSE
	return TRUE


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

	var/move_delay = 4
	var/move_max_momentum = 1
	var/move_turn_momentum_loss_factor = 0.25
	var/move_momentum_build_factor = 0.5

/obj/item/hardpoint/walker/leg/deactivate(obj/vehicle/walker/vehicle)
	vehicle.recalculate_legs()

/obj/item/hardpoint/walker/leg/on_install(obj/vehicle/walker/vehicle)
	if(!health)
		return

	vehicle.recalculate_legs()

/obj/item/hardpoint/walker/leg/left
	name = "Left Mecha Leg"

	slot = WALKER_HARDPOIN_LEFT_LEG

/obj/item/hardpoint/walker/leg/right
	name = "Right Mecha Leg"

	slot = WALKER_HARDPOIN_RIGHT_LEG


//////////////////////////////////////////////////////////////
// BACK

/obj/item/hardpoint/walker/spinal
	name = "Mecha Back Hardpoint"
	desc = "Allows special abilities."

	icon = 'code_ru/icons/obj/vehicles/mech_back.dmi'

	slot = WALKER_HARDPOIN_SPINAL
	hdpt_layer = HDPT_LAYER_SUPPORT

/obj/item/hardpoint/walker/spinal/powerful_cooling
	name = "Active Mecha Cooling"
	desc = "This very powerful cooling can take twice as much heat out of system! Allows do actions much faster."


/obj/item/hardpoint/walker/spinal/artilery
	name = "Detection Array \"Night Hawk\""
	desc = "Grant precision vision over entire battle field via special equipment of this hardpoint, additionaly grants very powerful motion detector at cost of faster reactor consumption."

	var/zoom_size = 12
	var/obj/item/device/motiondetector/walker/motion_detector

/obj/item/hardpoint/walker/spinal/artilery/Initialize()
	. = ..()

	motion_detector = new(src)
	motion_detector.owner = src

/obj/item/hardpoint/walker/spinal/artilery/Destroy()
	motion_detector.owner = null
	QDEL_NULL(motion_detector)

	. = ..()

/obj/item/hardpoint/walker/spinal/artilery/pilot_entered(mob/user)
	motion_detector.iff_signal = user.faction

/obj/item/hardpoint/walker/spinal/artilery/pilot_ejected(mob/user)
	return

/obj/item/device/motiondetector/walker
	detector_range = 24

	var/obj/item/hardpoint/walker/spinal/artilery/owner

/obj/item/device/motiondetector/walker/get_user()
	return owner?.owner?.seats[VEHICLE_DRIVER]


/obj/item/hardpoint/walker/spinal/tactical_missile
	name = "M1488 Tactical Rocket Unit"
	desc = "\"Special Deliver Package System\" includes a pair of heavy binoculars with laser aiming device, and bunker buster rocket. However due to only ground spotting and no remote, you have guide it at all the flight time for good hits."

	mount_class = GUN_MOUNT_NO

/obj/item/hardpoint/walker/spinal/tactical_missile/Initialize()
	. = ..()

	mounted_gun = new /obj/item/weapon/gun/launcher/rocket/mounted/mecha_tactical_missile(src)
	insert_gun()

/obj/item/hardpoint/walker/spinal/tactical_missile/tgui_additional_data()
	. = ..()

	.["value_name"] = "Rockets"
	if(!mounted_gun?.current_mag)
		return

	.["current_rounds"] = "[mounted_gun.current_mag?.current_rounds || 0]"
	.["max_rounds"] = "1"

/obj/item/hardpoint/walker/spinal/tactical_missile/check_modifiers(modifiers, button = FALSE)
	if(!modifiers[MIDDLE_CLICK])
		return FALSE

	if(button && (modifiers[BUTTON] != MIDDLE_CLICK))
		return FALSE
	return TRUE











/obj/item/hardpoint/walker/spinal/shield
	name = "F35 Resonation Projecting System"
	desc = "This modification grants you unvulnereability, as long as you have unlimited source of energy."

	var/damage_capacity = 200
	var/max_damage_capacity = 200
	var/cooldown_end_time = 0
	var/delay_between_hits = 10 SECONDS

/obj/item/hardpoint/walker/spinal/shield/Initialize()
	. = ..()

	START_PROCESSING(SSobj, src)

/obj/item/hardpoint/walker/spinal/shield/Destroy()
	. = ..()

	STOP_PROCESSING(SSobj, src)

/obj/item/hardpoint/walker/spinal/shield/proc/take_hits(list/damages_applied)
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
	else
		owner.visible_message(SPAN_WARNING("Arc of sparks coming out from aura around [owner], seems like reflecting an attack."))
	return TRUE

/obj/item/hardpoint/walker/spinal/shield/process()
	if(cooldown_end_time > world.time)
		return

	damage_capacity = min(damage_capacity + 2, max_damage_capacity)


/obj/item/hardpoint/walker/spinal/jetpack
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
	name = "Fire Fighter Armor"
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


/obj/item/hardpoint/walker/Destroy()
	if(mounted_gun)
		remove_gun()

	. = ..()

/obj/item/hardpoint/walker/on_install(obj/vehicle/walker/vehicle)
	. = ..()

	if(!vehicle.seats[VEHICLE_DRIVER])
		return
	pilot_entered(vehicle.seats[VEHICLE_DRIVER])

/obj/item/hardpoint/walker/on_uninstall(obj/vehicle/walker/vehicle)
	. = ..()

	if(!vehicle.seats[VEHICLE_DRIVER])
		return
	pilot_ejected(vehicle.seats[VEHICLE_DRIVER])

/obj/item/hardpoint/walker/get_examine_text(mob/user)
	. = ..()

	if(mounted_gun)
		. += "There is \a [mounted_gun] module installed on [src]."
		. += mounted_gun.get_examine_text(user)

/obj/item/hardpoint/walker/proc/try_reload(obj/item/attacking_item, mob/user)
	. = FALSE

	if(istype(attacking_item, /obj/item/ammo_magazine))
		. = TRUE
		mounted_gun.reload(user, attacking_item)

	if(istype(attacking_item, /obj/item/explosive/grenade))
		. = TRUE
		mounted_gun.on_pocket_attackby(attacking_item, user)

/obj/item/hardpoint/walker/proc/try_insert(obj/item/attacking_item, mob/user)
	. = FALSE

	if(!isgun(attacking_item) || user.action_busy || mounted_gun)
		return

	var/obj/item/weapon/gun/attacking_gun = attacking_item
	if(attacking_gun.mount_class != mount_class)
		return

	if(!do_after(user, 200, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD, owner, INTERRUPT_MOVED) || mounted_gun)
		return

	. = TRUE

	user.drop_inv_item_to_loc(attacking_gun, src)

	playsound(get_turf(src), 'sound/items/Crowbar.ogg', 25, 1)
	user.visible_message(SPAN_NOTICE("[user] places [attacking_gun] in [src]."),
	SPAN_NOTICE("You place [attacking_gun] in [src]."))

	mounted_gun = attacking_item
	insert_gun(user)
	name = "[name] with [attacking_gun]"

/obj/item/hardpoint/walker/proc/try_remove(obj/item/attacking_item, mob/user)
	. = FALSE

	if(!HAS_TRAIT(attacking_item, TRAIT_TOOL_SCREWDRIVER) || !mounted_gun)
		return

	if(user.action_busy || !do_after(user, 200, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD, owner, INTERRUPT_MOVED) || !mounted_gun)
		return

	. = TRUE

	playsound(get_turf(src), 'sound/items/Crowbar.ogg', 25, 1)
	user.visible_message(SPAN_NOTICE("[user] removes [mounted_gun] from [src]."),
	SPAN_NOTICE("You remove [mounted_gun] from [src]."))

	remove_gun(user)
	name = initial(name)
	owner.update_icon()


//////////////////////////////////////////////////////////////


/obj/item/hardpoint/walker/proc/insert_gun(mob/user)
	mounted_gun.gun_holder = src
	mounted_gun.flags_mounted_gun_features |= GUN_MOUNTED
	mounted_gun.callback_can_fire = CALLBACK(src, PROC_REF(can_fire))
	mounted_gun.callback_can_stop_fire = CALLBACK(src, PROC_REF(can_stop_fire))
	mounted_gun.callback_fire_stat = CALLBACK(src, PROC_REF(guns_debuff))
	if(owner)
		owner.update_icon()

	if(user)
		var/obj/vehicle/walker/source = owner
		if(slot in source.selected_group)
			mounted_gun.set_gun_user(user)

/obj/item/hardpoint/walker/proc/remove_gun(mob/user)
	QDEL_NULL(mounted_gun.callback_can_fire)
	QDEL_NULL(mounted_gun.callback_can_stop_fire)
	QDEL_NULL(mounted_gun.callback_fire_stat)
	mounted_gun.set_gun_user(null)
	mounted_gun.gun_holder = null
	if(!user)
		QDEL_NULL(mounted_gun)
		return

	mounted_gun.flags_mounted_gun_features &= ~GUN_MOUNTED
	user.put_in_hands(mounted_gun)
	mounted_gun = null

/obj/item/hardpoint/walker/proc/check_modifiers(modifiers, button = FALSE)
	return TRUE

/obj/item/hardpoint/walker/proc/guns_debuff(obj/projectile/projectile_to_fire, mob/user)
	for(var/obj/item/hardpoint/walker/hand/hardpoint in owner.hardpoints)
		if(hardpoint == src || !hardpoint.mounted_gun)
			continue
		if(hardpoint.mounted_gun.type == mounted_gun.type)
			return list(max(0.1, mounted_gun.accuracy_mult_unwielded - 0.1*rand(5,7)), SCATTER_AMOUNT_TIER_2 + SCATTER_AMOUNT_TIER_2)

/obj/item/hardpoint/walker/proc/can_fire(datum/source, atom/object, params)
	var/obj/vehicle/walker/vehicle = owner
	if(!vehicle.power_supply?.on_consume_enegry_action() || !health)
		return FALSE
	var/list/modifiers = params2list(params)
	if(length(modifiers) && !check_modifiers(modifiers))
		return FALSE
	if(!in_firing_arc(object))
		return FALSE
	return TRUE

/obj/item/hardpoint/walker/proc/can_stop_fire(datum/source, atom/object, params)
	var/obj/vehicle/walker/vehicle = owner
	if(!vehicle.power_supply?.turned_on || !health)
		return TRUE
	var/list/modifiers = params2list(params)
	if(length(modifiers) && !check_modifiers(modifiers, TRUE))
		return FALSE
	return TRUE


//////////////////////////////////////////////////////////////


#undef VEHICLE_REACTOR_FINE
#undef VEHICLE_REACTOR_DAMAGE
#undef VEHICLE_REACTOR_CRITICAL
