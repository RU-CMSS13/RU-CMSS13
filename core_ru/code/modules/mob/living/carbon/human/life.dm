/**
 * RUCM Feline "Бегающие флаги"
 * Затронутые файлы:
 * code\datums\elements\traitbound\leadership.dm
 * code\modules\mob\living\carbon\human\life.dm
 */

//////////////////////////////////
// Обработка приказов в life.dm //
/mob/living/carbon/human
	var/current_aura = null

/mob/living/carbon/human/proc/handle_orders()
	if(current_aura)
		if(src.is_mob_incapacitated())
			current_aura = null
			return

		var/order_level = skills.get_skill_level(SKILL_LEADERSHIP)
		var/list/targets = SSquadtree.players_in_range(SQUARE(src.x, src.y, 13 + order_level*4), src.z, QTREE_SCAN_MOBS | QTREE_EXCLUDE_OBSERVER)
		targets |= src

		for(var/mob/living/carbon/human/H in targets)
			if(!(H.get_target_lock(src.faction_group)))
				continue

			H.activate_order_buff(current_aura, max(1, order_level), 3 SECONDS)

//////////////////////////////////
// Активная способность приказа //
/datum/action/human_action/issue_order_feline
	name = "Отдать Приказ"
	icon_file = 'core_ru/Feline/icons/order.dmi'
	action_icon_state = "order"
	var/new_aura = null
	cooldown = 10 SECONDS

/datum/action/human_action/issue_order_feline/give_to(mob/living/L)
	..()
	if(!ishuman(L))
		return
	cooldown = 10 SECONDS

/datum/action/human_action/issue_order_feline/action_activate()
	. = ..()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/my_owner = owner

	if(my_owner.current_aura)
		my_owner.current_aura = null
		my_owner.visible_message(SPAN_BOLDNOTICE("[src] отменяет свой предыдущий приказ!"), SPAN_BOLDNOTICE("Отменяю предыдущий приказ. Мне понадобится некоторое время для оценки ситуации перед следующим!"))
		my_owner.say(pick("Отставить!","Отбой!","Отмена!","Прекратить!"))
		cooldown = 0 SECONDS
		return
	else
		var/static/list/aura_selections = list(
			"Справка" = image(icon = 'core_ru/Feline/icons/order.dmi', icon_state = "radial_help"),
			"Марш!" = image(icon = 'core_ru/Feline/icons/order.dmi', icon_state = "order_run"),
			"Цельсь!" = image(icon = 'core_ru/Feline/icons/order.dmi', icon_state = "order_aim"),
			"Держать Строй!" = image(icon = 'core_ru/Feline/icons/order.dmi', icon_state = "order_defense")
			)

		new_aura = show_radial_menu(my_owner, my_owner.client?.eye, aura_selections)
		switch(new_aura)
			if("Справка")
				to_chat(my_owner, SPAN_DANGER("<br>Наличие командира, отдающего приказы, помогает солдатам эффективнее действовать в бою. \
				Зависимости от навыка командования.:\
				<br><B>Марш! (Зелёный)</B> - Повышение мобильности и шанса увернуться от выстрелов.\
				<br><B>Цельсь! (Красный)</B> - Повышает меткость стрельбы и эффективную дальность оружия.\
				<br><B>Держать Строй! (Синий)</B> - Повышает болевой порог и стойкость к повреждениям.<br>"))
				return
			if("Марш!")
				my_owner.current_aura = COMMAND_ORDER_MOVE
				my_owner.visible_message(SPAN_BOLDNOTICE("[my_owner] отдаёт приказ на походный порядок!"), SPAN_BOLDNOTICE("Отдаю приказ на походный порядок!"))
				my_owner.say(pick("Марш!","Отряд, Бегом Марш!","Бегом!","Ходу!"))
			if("Цельсь!")
				my_owner.current_aura = COMMAND_ORDER_FOCUS
				my_owner.visible_message(SPAN_BOLDNOTICE("[my_owner] отдаёт приказ на готовность к стрельбе!"), SPAN_BOLDNOTICE("Отдаю приказ на готовность к стрельбе!"))
				my_owner.say(pick("Цельсь!","К Бою!","В Атаку!","К Оружию!","Внимание, Враг!", "Найти и Уничтожить!"))
			if("Держать Строй!")
				my_owner.current_aura = COMMAND_ORDER_HOLD
				my_owner.visible_message(SPAN_BOLDNOTICE("[my_owner] отдаёт приказ на удержание позиции!"), SPAN_BOLDNOTICE("Отдаю приказ на удержание позиции!"))
				my_owner.say(pick("Держать Строй!","Стоять Насмерть!","Держать Линию!","Держать Рубеж!","Не Сдавать Позиций","Держаться!","К Обороне!"))

		if(!new_aura || !my_owner.current_aura)
			return
		cooldown = 10 SECONDS
	playsound(get_turf(my_owner), 'sound/items/whistle.ogg', 20, 1, vary = 0)
