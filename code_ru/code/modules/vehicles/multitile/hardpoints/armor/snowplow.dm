/obj/item/hardpoint/armor/snowplow
	name = "Engineering Plow"
	desc = "Clears road for friendlies."

	icon_state = "snowplow"
	disp_icon = "tank"
	disp_icon_state = "snowplow"

	health = 1000
	activatable = TRUE
	damage_multiplier = 0.95

	type_multipliers = list(
		"blunt" = 0.8,
		"all" = 0.95
	)

	allowed_seat = VEHICLE_DRIVER

	var/max_debri = 20000
	var/debri_ammount = 0
	var/is_active = 0

	var/active_movement_delay = 2
	var/active_full_movement_delay = 4

/obj/item/hardpoint/armor/snowplow/handle_fire(atom/target, mob/living/user, params)
	is_active = !is_active
	to_chat(user, SPAN_WARNING("You [is_active ? "lower" : "rais"] plow"))

/obj/item/hardpoint/armor/snowplow/take_damage_type(list/damages_applied, type, atom/attacker, damage_to_apply, real_damage)
	damage_to_apply = round(damages_applied[2] * owner.get_dmg_multi(type))
	real_damage = damage_to_apply * damage_multiplier
	if(is_active && !(get_dir(owner.dir, attacker) in get_related_directions(owner.dir)))
		real_damage *= 0.5

	. = ..(damages_applied, type, attacker, damage_to_apply, real_damage)

/obj/item/hardpoint/armor/snowplow/get_examine_text(mob/user)
	. = ..()
	. += "Plow is [is_active ? "lowered" : "raised"]"
	if(isobserver(user) || (ishuman(user) && (skillcheck(user, SKILL_ENGINEER, SKILL_ENGINEER_NOVICE) || skillcheck(user, SKILL_VEHICLE, SKILL_VEHICLE_CREWMAN))))
		. += "It's cluttering progress [round(100*debri_ammount/max_debri, 1)]%!"

/obj/item/hardpoint/armor/snowplow/livingmob_interact(mob/living/living_unit)
	var/turf/targ = get_step(living_unit, owner.dir)
	targ = get_step(living_unit, owner.dir)
	living_unit.throw_atom(targ, 4, SPEED_VERY_FAST, src, 1)
	living_unit.apply_damage(50 + rand(0, 100), BRUTE)

/obj/item/hardpoint/armor/snowplow/on_move(turf/old, turf/new_turf, move_dir)
	if(health <= 0 || !is_active || dir != move_dir)
		return

	owner.next_move += active_movement_delay
	if(max_debri <= debri_ammount)
		owner.next_move += active_full_movement_delay

	var/turf/ahead = get_step(new_turf, move_dir)

	var/list/turfs_ahead = list(ahead, get_step(ahead, turn(move_dir, 90)), get_step(ahead, turn(move_dir, -90)))
	for(var/turf/open/turf in turfs_ahead)
		for(var/atom/movable/atom as anything in turf.contents)
			if(!atom.anchored)
				INVOKE_ASYNC(atom, TYPE_PROC_REF(/atom/movable, throw_atom), get_step(turf, owner.dir), 4, SPEED_SLOW, src, TRUE, HIGH_LAUNCH)
				continue

			if(istype(atom, /obj/effect/alien))
				var/obj/effect/alien/constrution = atom
				var/damage_to_deal = min(constrution.health, max_debri - debri_ammount)
				if(!damage_to_deal)
					continue

				constrution.health -= damage_to_deal
				debri_ammount += damage_to_deal
				playsound(turf, "alien_resin_break", 25)
				if(constrution.health <= 0)
					owner.visible_message(SPAN_DANGER("[owner] uproots [constrution]!"))
					constrution.deconstruct()

		if(!istype(turf, /turf/open/snow) && !istype(turf, /turf/open/auto_turf/snow))
			continue

		var/turf/open/open = turf
		new /obj/item/stack/snow(open, open.bleed_layer)
		if(istype(open, /turf/open/auto_turf/snow))
			var/turf/open/auto_turf/snow/auto_turf = open
			auto_turf.changing_layer(0)
		else
			open.bleed_layer = 0
			open.update_icon(TRUE, FALSE)
