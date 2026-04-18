/obj/structure/mineop/design/upgraded_pick
	name = "Боевая кирка"
	desc = "Сильное оружие ближнего боя и инструмент с огромным потенциалом для копания."

	icon_state = "better_pickaxe"

	buycost = 20
	buildtime = 2 SECONDS

	type_to_create = /obj/item/tool/pickaxe/mineop/upgraded
	design_id = "upgraded_pickaxe"
	already_researched = TRUE

/obj/item/tool/pickaxe/mineop
	digging_tool = TRUE
	digging_speed = 2 SECONDS
	digging_power = 5

/obj/item/tool/pickaxe/mineop/upgraded
	name = "pickaxe"
	icon = 'code_ru/code/events/mining_op/drg_tools.dmi'
	icon_state = "drg_pickaxe"

	var/charged = TRUE
	var/prepared = FALSE

	digging_speed = 1 SECONDS
	digging_power = 10

	force = 20
	throwforce = 10

/obj/item/tool/pickaxe/mineop/upgraded/clicked(mob/user, list/mods)
	if(mods[MIDDLE_CLICK])
		if(!prepared && charged)
			prepared = TRUE
			force = 120
			throwforce = 60
			add_filter("prepared_outline", 1, list("type" = "outline", "color" = COLOR_CYAN, "size" = 1))
			return TRUE

		if(prepared)
			prepared = FALSE
			force = initial(force)
			throwforce = initial(throwforce)
			remove_filter("prepared_outline")
			return TRUE

	return ..()

/obj/item/tool/pickaxe/mineop/upgraded/attack(mob/living/M, mob/living/user)
	. = ..()
	if(prepared)

		force = initial(force)
		throwforce = initial(throwforce)

		remove_filter("prepared_outline")

		prepared = FALSE
		charged = FALSE
		addtimer(CALLBACK(src, PROC_REF(recharge_pickaxe), user), 10 SECONDS)

/obj/item/tool/pickaxe/mineop/upgraded/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()

	if(prepared)

		if(istype(target, /turf/closed/wall/mineop/destructable_rock))
			var/turf/closed/wall/mineop/destructable_rock/R = target
			for(var/turf/closed/wall/mineop/destructable_rock/D in range(1,R))
				if(D.cannot_be_destructed_normally)
					continue
				animation_flash_color(D, "#ffbb00")
				D.dismantle_wall()

		force = initial(force)
		throwforce = initial(throwforce)

		remove_filter("prepared_outline")

		prepared = FALSE
		charged = FALSE
		addtimer(CALLBACK(src, PROC_REF(recharge_pickaxe), user), 10 SECONDS)

/obj/item/tool/pickaxe/mineop/upgraded/proc/recharge_pickaxe(mob/user)
	charged = TRUE
	balloon_alert(user, "*кирка перезарядилась!*", COLOR_CYAN)
