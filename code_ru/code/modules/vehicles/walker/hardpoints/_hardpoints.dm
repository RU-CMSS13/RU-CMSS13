/obj/item/hardpoint/walker
	name = "Mecha Hardpoint"
	desc = "Something to place on mech."

	icon = 'code_ru/icons/obj/vehicles/mech_hardpoints.dmi'
	icon_state = "mech_part"
	disp_icon = 'code_ru/icons/obj/vehicles/mech.dmi'
	disp_icon_state = "mech_part"

	damage_multiplier = 0.75
	material_per_repair = 5
	repair_materials = list("plastic" = 0.05, "metal" = 0.02)

	health = 150
	max_health = 150
	allowed_seat = VEHICLE_DRIVER

	// Additional move delay for every hardpoint installed on mecha
	var/weight = 0.5

	var/move_delay = 0
	var/move_max_momentum = 0
	var/move_turn_momentum_loss_factor = 0
	var/move_momentum_build_factor = 0

	var/list/custom_actions = list()

	var/zoom_size = 0
	var/obj/item/device/motiondetector/walker/motion_detector

	var/mount_class = GUN_MOUNT_NO
	var/obj/item/weapon/gun/mounted_gun = null

/obj/item/hardpoint/walker/Destroy()
	if(mounted_gun)
		remove_gun(null, TRUE)

	if(motion_detector)
		motion_detector.hardpoint_holder = null
		QDEL_NULL(motion_detector)

	if(owner)
		var/obj/vehicle/walker/vessel = owner
		vessel.hardpoints_by_slot[slot] = null

	. = ..()

/obj/item/hardpoint/walker/deactivate(obj/vehicle/walker/vessel)
	. = ..()

	if(motion_detector?.active)
		motion_detector.toggle_active(null, motion_detector.active)
	if(zoom)
		zoom = FALSE
		vessel.update_zoom_pixels(FALSE, FALSE)

/obj/item/hardpoint/walker/ex_act(severity)
	if(owner || explo_proof)
		return

	take_damage_type(list(0, severity / 2 * owner.get_dmg_multi(type)), "explosive", "explosion")

/obj/item/hardpoint/walker/get_examine_text(mob/user)
	. = ..()

	if(mounted_gun)
		. += "There is \a [mounted_gun] module installed on [src]."
		. += mounted_gun.get_examine_text(user)

/obj/item/hardpoint/walker/on_install(obj/vehicle/walker/vessel)
	. = ..()

	vessel.hardpoints_by_slot[slot] = src
	for(var/action in custom_actions)
		vessel.hardpoint_actions[action] = src
	if(!vessel.seats[VEHICLE_DRIVER])
		return
	pilot_entered(vessel.seats[VEHICLE_DRIVER])

/obj/item/hardpoint/walker/on_uninstall(obj/vehicle/walker/vessel)
	if(zoom)
		zoom = FALSE
		vessel.update_zoom_pixels(FALSE, FALSE)

	. = ..()

	vessel.hardpoints_by_slot[slot] = null
	for(var/action in custom_actions)
		vessel.hardpoint_actions -= action
	if(!vessel.seats[VEHICLE_DRIVER])
		return
	pilot_ejected(vessel.seats[VEHICLE_DRIVER])

/obj/item/hardpoint/walker/recalculate_hardpoint_bonuses()
	if(!mounted_gun)
		return
	mounted_gun.set_gun_config_values()
	mounted_gun.set_fire_delay(mounted_gun.get_fire_delay() * owner.misc_multipliers["fire_delay"])
	mounted_gun.scatter = mounted_gun.scatter * owner.misc_multipliers["scatter"]

/obj/item/hardpoint/walker/get_origin_turf()
	return get_turf(src)

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

/obj/item/hardpoint/walker/proc/tgui_additional_data(list/tgui_data)
	. = tgui_data

	.["integrity"] = health / max_health * 100

/obj/item/hardpoint/walker/proc/take_damage_type(list/damages_applied, type, atom/attacker, damage_to_apply, real_damage)
	if(!damage_to_apply)
		damage_to_apply = damages_applied[WALKER_DAMAGE_REMAINING]
	if(!real_damage)
		if(damage_to_apply > 20)
			real_damage = damage_to_apply * damage_multiplier
		else
			real_damage = damage_to_apply

	if(real_damage > health)
		real_damage = health
	damages_applied[WALKER_DAMAGE_REMAINING] -= real_damage
	damages_applied[WALKER_DAMAGE_TOTAL] += real_damage
	health -= real_damage
	if(!health && owner)
		deactivate(owner)

/obj/item/hardpoint/walker/proc/pilot_entered(mob/user)
	if(mounted_gun)
		var/obj/vehicle/walker/vessel = owner
		if(slot in GROUPS_BY_ID[vessel.selected_group])
			mounted_gun.set_gun_user(user)
	if(motion_detector)
		motion_detector.iff_signal = user.faction

/obj/item/hardpoint/walker/proc/pilot_ejected(mob/user)
	if(!mounted_gun)
		return
	mounted_gun.set_gun_user(null)

/obj/item/hardpoint/walker/proc/on_source_process(delta_time)
	if(!health)
		return FALSE

	. = TRUE

	if(zoom)
		var/obj/vehicle/walker/vessel = owner
		var/consumption = ceil(zoom_size * delta_time * 0.5)
		if(!vessel.can_consume_energy(consumption))
			zoom = FALSE
			vessel.update_zoom_pixels(FALSE, FALSE)
		else
			vessel.consume_energy(consumption)

/obj/item/hardpoint/walker/proc/custom_action(mob/user, custom_action)
	return


//////////////////////////////////////////////////////////////


/obj/item/hardpoint/walker/proc/try_reload(obj/item/attacking_item, mob/user)
	. = FALSE

	if(istype(attacking_item, /obj/item/ammo_magazine) && mounted_gun.reload(user, attacking_item))
		. = TRUE

	if(istype(attacking_item, /obj/item/explosive/grenade) && mounted_gun.on_pocket_attackby(attacking_item, user))
		. = TRUE

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

	insert_gun(attacking_gun)

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


/obj/item/hardpoint/walker/proc/insert_gun(obj/item/weapon/gun/target)
	mounted_gun = target
	target.gun_holder = src
	target.forceMove(src)
	name = "[name] with [target]"
	target.flags_mounted_gun_features |= GUN_MOUNTED
	target.callback_can_fire = CALLBACK(src, PROC_REF(can_fire))
	target.callback_can_stop_fire = CALLBACK(src, PROC_REF(can_stop_fire))
	target.callback_fire_stat = CALLBACK(src, PROC_REF(guns_debuff))
	if(!owner)
		return

	owner.update_icon()
	if(!owner.seats[VEHICLE_DRIVER])
		return
	var/obj/vehicle/walker/vessel = owner
	if(slot in GROUPS_BY_ID[vessel.selected_group])
		mounted_gun.set_gun_user(vessel.seats[VEHICLE_DRIVER])

/obj/item/hardpoint/walker/proc/remove_gun(mob/user, delete = FALSE)
	var/obj/item/weapon/gun/target = mounted_gun
	mounted_gun = null
	QDEL_NULL(target.callback_can_fire)
	QDEL_NULL(target.callback_can_stop_fire)
	QDEL_NULL(target.callback_fire_stat)
	if(delete)
		qdel(target)
		return

	target.set_gun_config_values()
	target.set_gun_user(null)
	target.gun_holder = null
	target.flags_mounted_gun_features &= ~GUN_MOUNTED
	if(user)
		user.put_in_hands(target)
	else
		target.forceMove(get_turf(src))

/obj/item/hardpoint/walker/proc/check_modifiers(modifiers, button = FALSE)
	return TRUE

/obj/item/hardpoint/walker/proc/guns_debuff(obj/projectile/projectile_to_fire, mob/user)
	for(var/obj/item/hardpoint/walker/hand/hardpoint in owner.hardpoints)
		if(hardpoint == src || !hardpoint.mounted_gun)
			continue
		if(hardpoint.mounted_gun.type == mounted_gun.type)
			var/list/modificator = list(0, 0)
			modificator[1] = max(1, mounted_gun.accuracy_mult_unwielded - 0.1 * rand(5,7) * owner.misc_multipliers["same_guns_debuff"])
			modificator[2] = (SCATTER_AMOUNT_TIER_2 + SCATTER_AMOUNT_TIER_2) * owner.misc_multipliers["same_guns_debuff"]
			return modificator

/obj/item/hardpoint/walker/proc/can_fire(datum/source, atom/object, params, consume_energy = TRUE)
	if(!health)
		return FALSE
	var/obj/vehicle/walker/vessel = owner
	if(!vessel.can_consume_energy(mounted_gun.charge_cost))
		return FALSE
	var/list/modifiers = params2list(params)
	if(length(modifiers) && !check_modifiers(modifiers))
		return FALSE
	if(!in_firing_arc(object))
		return FALSE
	if(consume_energy)
		vessel.consume_energy(mounted_gun.charge_cost)
	return TRUE

/obj/item/hardpoint/walker/proc/can_stop_fire(datum/source, atom/object, params)
	var/obj/vehicle/walker/vessel = owner
	if(!vessel.can_consume_energy(mounted_gun.charge_cost) || !health)
		return TRUE
	var/list/modifiers = params2list(params)
	if(length(modifiers) && !check_modifiers(modifiers, TRUE))
		return FALSE
	return TRUE
