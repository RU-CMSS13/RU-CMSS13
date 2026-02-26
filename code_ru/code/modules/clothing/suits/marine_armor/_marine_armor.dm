/obj/item/clothing/suit/storage/marine/specialist
	desc = "A heavy, rugged set of armor plates for when you really, really need to not die horribly. Slows you down though.\nComes with two emergency injectors in each arm guard."
	icon_state = "xarmor_ru"
	armor_melee = CLOTHING_ARMOR_HIGHPLUS
	armor_bullet = CLOTHING_ARMOR_VERYHIGHPLUS
	armor_bomb = CLOTHING_ARMOR_ULTRAHIGH
	armor_bio = CLOTHING_ARMOR_HIGHPLUS
	armor_rad = CLOTHING_ARMOR_HIGH
	armor_internaldamage = CLOTHING_ARMOR_HIGHPLUS
	armor_energy = CLOTHING_ARMOR_HIGH

/obj/item/clothing/suit/storage/marine/specialist/verb/inject()
	set name = "Create Injector"
	set category = "Object"
	set src in usr

	if(usr.is_mob_incapacitated())
		return 0

	if(!injections)
		to_chat(usr, "Your armor is all out of injectors.")
		return 0

	if(usr.get_active_hand())
		to_chat(usr, "Your active hand must be empty.")
		return 0

	to_chat(usr, "You feel a faint hiss and an injector drops into your hand.")
	var/obj/item/reagent_container/hypospray/autoinjector/emergency/O = new(usr)
	usr.put_in_active_hand(O)
	injections--
	playsound(src,'sound/machines/click.ogg', 15, 1)
	return
