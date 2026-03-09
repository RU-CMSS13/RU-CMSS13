//armor & threads -> guns & sup -> turret -> corpuse
/obj/vehicle/multitile/proc/take_damage_type(damage, type, atom/attacker)
	var/list/damages_applied = list(0, damage)
	var/obj/item/hardpoint/armor/tank_armor = locate() in hardpoints
	if(tank_armor?.can_take_damage())
		tank_armor.take_damage_type(damages_applied, type, attacker)
	var/list/obj/item/hardpoint/hardpoints_remaining = hardpoints.Copy() - tank_armor
	for(var/length = 1 to length(hardpoints_remaining))// First option with while loop, but then I remembered why while loops is evil in opensource game dev
		var/obj/item/hardpoint/attacked_hardpoint = pick(hardpoints_remaining)
		hardpoints_remaining -= attacked_hardpoint
		if(!attacked_hardpoint.can_take_damage())
			continue
		attacked_hardpoint.take_damage_type(damages_applied, type, attacker)

	//bc it's final stage we wont take this param from damage
	var/damage_to_apply = round(damages_applied[2] * get_dmg_multi(type))
	damages_applied[1] += damage_to_apply
	health = max(0, health - damage_to_apply)

	if(ismob(attacker))
		var/mob/M = attacker
		log_attack("[src] took [damages_applied[1]] [type] damage from [M] ([M.client ? M.client.ckey : "disconnected"]).")
	else
		log_attack("[src] took [damages_applied[1]] [type] damage from [attacker].")
	update_icon()

/obj/item/hardpoint/proc/take_damage_type(list/damages_applied, type, atom/attacker, damage_to_apply, real_damage)
	if(!damage_to_apply || !real_damage)
		damage_to_apply = round(damages_applied[2] * owner.get_dmg_multi(type))
		real_damage = damage_to_apply * damage_multiplier

	damages_applied[2] -= damage_to_apply * 0.5
	damages_applied[1] += real_damage
	health = max(0, health - real_damage)
	if(!health)
		on_destroy()
	return TRUE

/obj/item/hardpoint/holder/take_damage_type(list/damages_applied, type, atom/attacker, damage_to_apply, real_damage)
	. = ..()

	for(var/obj/item/hardpoint/attacked_hardpoint as anything in hardpoints)
		if(!attacked_hardpoint.can_take_damage())
			continue
		attacked_hardpoint.take_damage_type(damages_applied, type, attacker)
