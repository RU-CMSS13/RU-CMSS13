/obj/item/spraycan
	name = "spray paint can"
	desc = "A can of spray paint."
	icon = 'core_ru/icons/obj/items/spraycan.dmi'
	icon_state = "spraycan"
	item_state = "deathcan"
	w_class = 2

	var/list/colors = list(
		"Red" = "#ff0000",
		"Blue" = "#0000ff",
		"Green" = "#00ff00",
		"Yellow" = "#ffff00",
		"Black" = "#000000"
	)

	var/current_color = "#ff0000"
	var/erase_mode = FALSE


/obj/item/spraycan/attack_self(mob/user)
	if(!user)
		return

	var/list/options = list()
	for(var/C in colors)
		options += C
	options += "Erase paint"

	var/choice = input(user, "Select spray mode", "Spraycan") as null|anything in options
	if(!choice)
		return

	if(choice == "Erase paint")
		erase_mode = TRUE
		user << "<span class='notice'>You switch the spraycan to erase mode.</span>"
		return

	erase_mode = FALSE
	current_color = colors[choice]
	user << "<span class='notice'>You select [choice] paint.</span>"


/obj/item/spraycan/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !target || !user)
		return

	if(ismob(target))
		user << "<span class='warning'>You can't spray living beings.</span>"
		return

	if(istype(target, /obj/item/weapon))
		user << "<span class='warning'>You can't spray weapons.</span>"
		return

	if(istype(target, /obj/item/implant))
		user << "<span class='warning'>That can't be painted.</span>"
		return

	if(erase_mode)
		erase_paint(target, user)
	else
		paint_target(target, user)


/obj/item/spraycan/proc/paint_target(atom/A, mob/user)
	if(!A)
		return

	A.color = current_color
	user << "<span class='notice'>You spray paint [A].</span>"


/obj/item/spraycan/proc/erase_paint(atom/A, mob/user)
	if(!A)
		return

	if(!A.color)
		user << "<span class='notice'>There is no paint to remove.</span>"
		return

	A.color = null
	user << "<span class='notice'>You remove the paint from [A].</span>"