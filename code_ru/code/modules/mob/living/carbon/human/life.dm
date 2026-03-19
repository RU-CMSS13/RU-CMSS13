/mob/living/carbon/human
	var/current_aura = null

/mob/living/carbon/human/proc/handle_orders()
	if(current_aura)
		if(src.is_mob_incapacitated())
			current_aura = null
			return

		var/order_level = skills.get_skill_level(SKILL_LEADERSHIP)
		var/list/targets = SSquadtree.players_in_range(SQUARE(src.x, src.y, 13 + order_level*4), src.z, QTREE_SCAN_MOBS | QTREE_FILTER_LIVING)
		targets |= src

		for(var/mob/living/carbon/human/H in targets)
			if(!(H.get_target_lock(src.faction_group)))
				continue

			H.activate_order_buff(current_aura, max(1, order_level), 3 SECONDS)

/datum/action/human_action/issue_order
	name = "Give Order"
	icon_file = 'icons/mob/radial.dmi'
	action_icon_state = "order"
	var/new_aura = null
	cooldown = 10 SECONDS

/datum/action/human_action/issue_order/give_to(mob/living/L)
	..()
	if(!ishuman(L))
		return
	cooldown = 10 SECONDS

/datum/action/human_action/issue_order/action_activate()
	. = ..()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/my_owner = owner
	var/default_lang = my_owner.get_default_language()

	if(my_owner.current_aura)
		my_owner.current_aura = null
		my_owner.visible_message(SPAN_BOLDNOTICE("[src] cancels his previous order!"), SPAN_BOLDNOTICE("I'll have to wait a bit before issuing new order"))
		cooldown = 10 SECONDS
		return
	else
		var/static/list/aura_selections = list(
			"Help" = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_help"),
			"Move!" = image(icon = 'icons/mob/radial.dmi', icon_state = "order_move"),
			"Aim!" = image(icon = 'icons/mob/radial.dmi', icon_state = "order_aim"),
			"Hold!" = image(icon = 'icons/mob/radial.dmi', icon_state = "order_hold")
			)

		var/atom/movable/real_anchor = my_owner
		while(real_anchor.loc && !isturf(real_anchor.loc))// If we want to find the fucking real atom located on map
			real_anchor = real_anchor.loc
		new_aura = show_radial_menu(my_owner, real_anchor, aura_selections, radius = 38, require_near = TRUE, tooltips = TRUE)
		switch(new_aura)
			if("Help")
				to_chat(my_owner, SPAN_DANGER("<br>Each order has it's own effects. \
				Those are:\
				<br><B>Move!</B> - Increases speed and chance to dodge bullets.\
				<br><B>Aim!</B> - Increases accuracy and effective range of weapons.\
				<br><B>Hold!</B> - Increases pain tolerance and damage resistance.<br>"))
				return
			if("Move!")
				my_owner.current_aura = COMMAND_ORDER_MOVE
				my_owner.visible_message(SPAN_BOLDNOTICE("[my_owner] gives an order to move!"), SPAN_BOLDNOTICE("I give an order to move!"))
				if(default_lang == GLOB.all_languages[LANGUAGE_RUSSIAN])
					my_owner.say(pick("Марш!","Отряд, Бегом Марш!","Бегом!","Выкатываемся!"))
				else
					my_owner.say(pick("Move!","Double time!","With haste!","Roll out!"))
			if("Aim!")
				my_owner.current_aura = COMMAND_ORDER_FOCUS
				my_owner.visible_message(SPAN_BOLDNOTICE("[my_owner] gives an order to aim!"), SPAN_BOLDNOTICE("I give an order to aim!"))
				if(default_lang == GLOB.all_languages[LANGUAGE_RUSSIAN])
					my_owner.say(pick("Цельсь!","К Бою!","В Атаку!","К Оружию!","Внимание, Враг!", "Найти и Уничтожить!", "За Родину!"))
				else
					my_owner.say(pick("Aim!","To arms!","Attack!","Check your targets!","Clear them out", "Find and destroy!"))
			if("Hold!")
				my_owner.current_aura = COMMAND_ORDER_HOLD
				my_owner.visible_message(SPAN_BOLDNOTICE("[my_owner] gives an order to hold!"), SPAN_BOLDNOTICE("I give an order to hold!"))
				if(default_lang == GLOB.all_languages[LANGUAGE_RUSSIAN])
					my_owner.say(pick("Держать Строй!","Стоять Насмерть!","Держать Линию!","Держать Рубеж!","Не Сдавать Позиций","Держаться!","К Обороне!"))
				else
					my_owner.say(pick("Hold here!","No step back!","Hold the line!","Stand your ground!"))

		if(!new_aura || !my_owner.current_aura)
			return
		cooldown = 10 SECONDS
