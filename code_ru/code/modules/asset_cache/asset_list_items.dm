/datum/asset/spritesheet/gun_lineart/register()
	var/icon_file = 'core_ru/icons/obj/items/weapons/guns/lineart.dmi'
	InsertAll("", icon_file)
	for(var/obj/item/weapon/gun/current_gun as anything in subtypesof(/obj/item/weapon/gun))
		if(isnull(initial(current_gun.icon_state)))
			continue
		if(initial(current_gun.flags_gun_features) & GUN_UNUSUAL_DESIGN)
			continue // These don't have a way to inspect weapon stats
		if(!(current_gun.lineart_ru))
			continue
		var/obj/item/weapon/gun/temp_gun = new current_gun
		var/icon_state = temp_gun.base_gun_icon // base_gun_icon is set in Initialize generally
		qdel(temp_gun)
		if(icon_state && isnull(sprites[icon_state]))
			// downgrade this to a log_debug if we don't want missing lineart to be a lint
			stack_trace("[current_gun] does not have a valid lineart icon state, icon=[icon_file], icon_state=[json_encode(icon_state)]")
