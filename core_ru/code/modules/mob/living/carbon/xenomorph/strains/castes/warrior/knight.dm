/**
 * RUCM Feline "Стрейн Воина - Рыцарь"
 * Затронутые файлы:
 * code\__DEFINES\xeno.dm
 * code\datums\mob_hud.dm
 * code\modules\mob\living\carbon\carbon.dm
 * code\modules\mob\living\carbon\xenomorph\attack_alien.dm
 * code\modules\mob\living\carbon\xenomorph\damage_procs.dm
 */

///////////////////
// Мутация Воина //
/mob/living/carbon/xenomorph/warrior
	icon_xeno = 'core_ru/Feline/icons/warrior_new.dmi'
	icon_xenonid = 'core_ru/Feline/icons/warrior_new.dmi'

/datum/xeno_strain/knight
	name = WARRIOR_KNIGHT
	description = "Вы теряете способность к рывкам, захвату, удару хвостом, а ваше базовое здоровье снижено. \
				Вы получаете на 50% больше урона от огня. Ваша базовая броня увеличена. Вы получаете возможность \
				пожирать металл и баррикады тем самым создавая неспадающий металлический щит. Однако металлический щит не защищает от огня. \
				Урон по металлическим баррикадам дополнительно усилен и вы игнорируете урон от колючей проволоки. \
				С увеличением прочности вашего щита удар \"Череполома\" дизориентирует сильнее, а \"Натиск\" отбрасывает дальше."
	flavor_description = "Поцелуй мой блестящий зад!"
	icon_state_prefix = "Knight"

	actions_to_remove = list(
		/datum/action/xeno_action/activable/fling,
		/datum/action/xeno_action/activable/lunge,
		/datum/action/xeno_action/activable/tail_stab,
		/datum/action/xeno_action/activable/warrior_punch,
	)

	actions_to_add = list(
		/datum/action/xeno_action/onclick/skull_breaker,
		/datum/action/xeno_action/activable/onslaught,
	)

	behavior_delegate_type = /datum/behavior_delegate/warrior_knight

/datum/xeno_strain/knight/apply_strain(mob/living/carbon/xenomorph/warrior/warrior)
	ADD_TRAIT(warrior, TRAIT_WEAK_TO_FLAME, TRAIT_SOURCE_STRAIN)
	warrior.health_modifier -= XENO_HEALTH_MOD_VERY_LARGE
	warrior.armor_modifier += XENO_ARMOR_MOD_SMALL
	warrior.recalculate_everything()
	warrior.desc = "Чужой с отливающей металлом псевдоплотью. Пусть он выглядит не таким проворным как обычный, но зато явно прочнее."

///////////////////
// Делегирование //
/datum/behavior_delegate/warrior_knight
	var/datum/xeno_shield/shield
	var/armor_state
	var/shield_passive_regen = 1
	var/shield_limit = 200 			// Стартовый лимит. Увеличивается со временем
	var/shield_limit_old = 0		// Ячейка памяти

	// Способности
	var/charged_attack_base = 5
	var/charged_attack_advanced  = 10
	var/charged_attack_maximum = 15

	var/next_slash_buffed = FALSE

//////////////////////
// Заряженная атака //
/datum/behavior_delegate/warrior_knight/melee_attack_modify_damage(original_damage, mob/living/carbon/target_carbon)
	if (!isxeno_human(target_carbon))
		return original_damage

	if (next_slash_buffed)
		switch(armor_state)
			if(0)
				to_chat(bound_xeno, SPAN_XENOHIGHDANGER("Мы атакуем [target_carbon] заряженной атакой!"))
				to_chat(target_carbon, SPAN_XENOHIGHDANGER("По телу проносится волна боли, когда [bound_xeno] наносит мне размашистый удар!"))
				sound_to(target_carbon, 'core_ru/Feline/sound/tinnitus_3.ogg')
				original_damage += charged_attack_base		// Заряженный удар базовый
				target_carbon.make_jittery(100)				// Тряска персонажа
				target_carbon.make_dizzy(100)				// Тряска экрана

			if(1)
				to_chat(bound_xeno, SPAN_XENOHIGHDANGER("Мы атакуем [target_carbon] заряженной атакой!"))
				to_chat(target_carbon, SPAN_XENOHIGHDANGER("В глазах темнеет, когда [bound_xeno] наносит мне размашистый удар!"))
				sound_to(target_carbon, 'core_ru/Feline/sound/tinnitus_6.ogg')
				original_damage += charged_attack_base		// Заряженный удар базовый
				target_carbon.adjust_effect(4, SLOW)		// Замедление слабое
				target_carbon.apply_effect(4, DAZE) 		// Сотрясение - ограничение обзора
				target_carbon.make_jittery(120)				// Тряска персонажа
				target_carbon.make_dizzy(120)				// Тряска экрана

			if(2)
				to_chat(bound_xeno, SPAN_XENOHIGHDANGER("Мы атакуем [target_carbon] заряженной атакой!"))
				to_chat(target_carbon, SPAN_XENOHIGHDANGER("Глаза заволакивает поволока боли, когда [bound_xeno] наносит мне страшный удар!"))
				sound_to(target_carbon, 'core_ru/Feline/sound/tinnitus_9.ogg')
				original_damage += charged_attack_advanced	// Заряженный удар усиленный +
				target_carbon.adjust_effect(5, SLOW)		// Замедление слабое
				target_carbon.apply_effect(5, DAZE) 		// Сотрясение - ограничение обзора
				target_carbon.apply_effect(4, EYE_BLUR) 	// Мыльцо
				target_carbon.make_jittery(140)				// Тряска персонажа
				target_carbon.make_dizzy(140)				// Тряска экрана

			if(3)
				to_chat(bound_xeno, SPAN_XENOHIGHDANGER("Мы атакуем [target_carbon] заряженной атакой!"))
				to_chat(target_carbon, SPAN_XENOHIGHDANGER("Теряю ориентацию в пространстве, когда [bound_xeno] наносит мне страшный удар!"))
				sound_to(target_carbon, 'core_ru/Feline/sound/tinnitus_12.ogg')
				original_damage += charged_attack_advanced	// Заряженный удар усиленный +
				target_carbon.adjust_effect(6, SLOW)		// Замедление слабое
				target_carbon.adjust_effect(2, SUPERSLOW)	// Замедление сильное
				target_carbon.apply_effect(6, DAZE) 		// Сотрясение - ограничение обзора
				target_carbon.apply_effect(6, EYE_BLUR) 	// Мыльцо
				target_carbon.make_jittery(160)				// Тряска персонажа
				target_carbon.make_dizzy(160)				// Тряска экрана

			if(4)
				to_chat(bound_xeno, SPAN_XENOHIGHDANGER("Мы атакуем [target_carbon] заряженной атакой!"))
				to_chat(target_carbon, SPAN_XENOHIGHDANGER("Теряю ориентацию в пространстве и падаю, когда [bound_xeno] наносит мне чудовищный удар!"))
				sound_to(target_carbon, 'core_ru/Feline/sound/tinnitus_15.ogg')
				original_damage += charged_attack_maximum	// Заряженный удар максимальный ++
				target_carbon.adjust_effect(8, SLOW)		// Замедление слабое
				target_carbon.adjust_effect(2, SUPERSLOW)	// Замедление сильное
				target_carbon.apply_effect(8, DAZE) 		// Сотрясение - ограничение обзора
				target_carbon.apply_effect(8, EYE_BLUR) 	// Мыльцо
				target_carbon.apply_effect(0.5, WEAKEN) 	// Опрокидывание
				target_carbon.make_jittery(180)				// Тряска персонажа
				target_carbon.make_dizzy(180)				// Тряска экрана

		playsound(target_carbon,'core_ru/Feline/sound/metall_hit_2.ogg', 30, 1)
		next_slash_buffed = FALSE
		var/datum/action/xeno_action/onclick/skull_breaker/ability = get_action(bound_xeno, /datum/action/xeno_action/onclick/skull_breaker)
		if(ability)
			ability.button.icon_state = "template"
			ability.apply_cooldown()

	return original_damage

//////////////////////////
// Перезапись намерения //
/datum/behavior_delegate/warrior_knight/override_intent(mob/living/carbon/target_carbon)
	. = ..()

	if(!isxeno_human(target_carbon))
		return

	if(next_slash_buffed)
		return INTENT_HARM

///////////////////////
// Обновление иконок //
/datum/behavior_delegate/warrior_knight/on_update_icons()
	if(bound_xeno.stat == DEAD)
		return

	if(!shield)
		for(var/datum/xeno_shield/found in bound_xeno.xeno_shields)
			if(found.shield_source == XENO_SHIELD_KNIGHT)
				shield = found
				break

	if(bound_xeno.health > 0)
		if(shield)
			switch(shield.amount)
				if(0 to 30)
					armor_state = 0
				if(31 to 150)
					armor_state = 1
				if(151 to 300)
					armor_state = 2
				if(301 to 450)
					armor_state = 3
				if(451 to 600)
					armor_state = 4

			if(bound_xeno.body_position == LYING_DOWN)
				if(!HAS_TRAIT(bound_xeno, TRAIT_INCAPACITATED) && !HAS_TRAIT(bound_xeno, TRAIT_FLOORED))
					bound_xeno.icon_state = "[bound_xeno.get_strain_icon()] Warrior Sleeping[armor_state > 0 ? " Armor[armor_state]" : ""]"
				else
					bound_xeno.icon_state = "[bound_xeno.get_strain_icon()] Warrior Knocked Down[armor_state > 0 ? " Armor[armor_state]" : ""]"
			else
				bound_xeno.icon_state = "[bound_xeno.get_strain_icon()] Warrior Running[armor_state > 0 ? " Armor[armor_state]" : ""]"
			return TRUE

////////////////
// Объявление //
/datum/behavior_delegate/warrior_knight/proc/add_limit()
	if(shield_limit_old != shield_limit)
		shield_limit_old = shield_limit
		playsound_client(bound_xeno.client, get_sfx("evo_screech"), bound_xeno.loc, 70, "minor")
		to_chat(bound_xeno, SPAN_XENOBOLDNOTICE("Наш максимум усвоения металла достиг [shield_limit] единиц!"))

////////////////
// Тики жизни //
/datum/behavior_delegate/warrior_knight/on_life()
	if(!bound_xeno)
		return

	switch(ROUND_TIME)	// Воин доступен с 9 минуты
		if(0 to 15 MINUTES)				// 1 полная, 2 слабая стадия
			shield_limit = 200
		if(15 MINUTES to 25 MINUTES)	// 1-2 полная стадия
			shield_limit = 300
		if(25 MINUTES to 40 MINUTES)	// 1-2 полная, 3 средняя стадия
			shield_limit = 400
		if(40 MINUTES to 50 MINUTES)	// 1-3 полная, 4 слабая стадия
			shield_limit = 500
		else
			shield_limit = 600			// 1-4 полная стадия

	if(bound_xeno.stat == DEAD)
		return

	switch(armor_state)
		if(0 to 2)
			if(bound_xeno.speed_modifier != 0)
				bound_xeno.speed_modifier = 0
				bound_xeno.recalculate_speed()
/*
			if(bound_xeno.speed_modifier != XENO_SPEED_SLOWMOD_TIER_6)
				bound_xeno.speed_modifier = XENO_SPEED_SLOWMOD_TIER_6
				bound_xeno.recalculate_speed()
*/
		if(3)
			if(bound_xeno.speed_modifier != XENO_SPEED_SLOWMOD_TIER_6)
				bound_xeno.speed_modifier = XENO_SPEED_SLOWMOD_TIER_6
				bound_xeno.recalculate_speed()
/*
			if(bound_xeno.speed_modifier != XENO_SPEED_SLOWMOD_TIER_8)
				bound_xeno.speed_modifier = XENO_SPEED_SLOWMOD_TIER_8
				bound_xeno.recalculate_speed()
*/
		if(4)
			if(bound_xeno.speed_modifier != XENO_SPEED_SLOWMOD_TIER_8)
				bound_xeno.speed_modifier = XENO_SPEED_SLOWMOD_TIER_8
				bound_xeno.recalculate_speed()
/*
			if(bound_xeno.speed_modifier != XENO_SPEED_SLOWMOD_TIER_10)
				bound_xeno.speed_modifier = XENO_SPEED_SLOWMOD_TIER_10
				bound_xeno.recalculate_speed()
*/

	if(shield)
		if(shield.amount <= 0)
			shield = null
	if(bound_xeno.health == bound_xeno.maxHealth)
		bound_xeno.add_xeno_shield(shield_passive_regen, XENO_SHIELD_KNIGHT, add_shield_on = TRUE, max_shield = shield_limit)
		bound_xeno.overlay_shields()
	add_limit()

////////////
// Смерть //
/datum/behavior_delegate/warrior_knight/handle_death(mob/M)
	if(shield)
		var/S = round(shield.amount/60)
		create_shrapnel(bound_xeno.loc, S, null, null, , create_cause_data(initial(bound_xeno.caste_type), bound_xeno), ignore_source_mob = TRUE)
		for (var/i=0 to max(S,1))
			var/obj/item/stack/sheet/plasteel/sheet
			if(prob(60))
				sheet = new /obj/item/stack/sheet/metal(bound_xeno.loc)
			else
				sheet = new /obj/item/stack/sheet/plasteel(bound_xeno.loc)
			sheet.throw_random_direction(rand(1, 4), SPEED_FAST, spin = TRUE)

		shield.amount = 0
		bound_xeno.overlay_shields()


/////////////////
// СПОСОБНОСТИ //
/////////////////

//////////////////////////
// Удар с отбрасыванием //
/datum/action/xeno_action/activable/onslaught
	name = "Натиск"
	icon_file = 'core_ru/Feline/icons/actions_xeno.dmi'
	action_icon_state = "onslaught"
	macro_path = /datum/action/xeno_action/verb/verb_onslaught
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_2
	xeno_cooldown = 15 SECONDS

//	var/damage = 4
	var/stun_power = 0
	var/weaken_power = 0
	var/slowdown = 2
	var/base_damage = 20

// Макрос
/datum/action/xeno_action/verb/verb_onslaught()
	set category = "Alien"
	set name = "Натиск"
	set hidden = TRUE
	var/action_name = "Натиск"
	handle_xeno_macro(src, action_name)

// Функция
/datum/action/xeno_action/activable/onslaught/use_ability(atom/affected_atom)
	var/mob/living/carbon/xenomorph/fling_user = owner

	if (!action_cooldown_check())
		return

	if (!isxeno_human(affected_atom) || fling_user.can_not_harm(affected_atom))
		return

	if (!fling_user.check_state() || fling_user.agility)
		return

	if (!fling_user.Adjacent(affected_atom))
		return

	var/mob/living/carbon/carbon = affected_atom
	if(carbon.stat == DEAD)
		return

	if(HAS_TRAIT(carbon, TRAIT_NESTED))
		return

	if(carbon == fling_user.pulling)
		fling_user.stop_pulling()

	if(carbon.mob_size >= MOB_SIZE_BIG)
		to_chat(fling_user, SPAN_XENOWARNING("[carbon] слишком велик, для того чтобы его швырнуть!"))
		return

	if (!check_and_use_plasma_owner())
		return

	fling_user.visible_message(SPAN_XENOWARNING("[fling_user] с легкостью отбрасывает [carbon] в сторону!"), SPAN_XENOWARNING("Мы легко отбрасываем [carbon] в сторону!"))
	playsound(carbon,'core_ru/Feline/sound/metall_hit_1.ogg', 75, 1)
	if(stun_power)
		carbon.Stun(get_xeno_stun_duration(carbon, stun_power))
	if(weaken_power)
		carbon.KnockDown(get_xeno_stun_duration(carbon, weaken_power))
	if(slowdown)
		if(carbon.slowed < slowdown)
			carbon.apply_effect(slowdown, SLOW)
	carbon.last_damage_data = create_cause_data(initial(fling_user.caste_type), fling_user)

	var/facing = get_dir(fling_user, carbon)

	var/datum/behavior_delegate/warrior_knight/behavior = fling_user.behavior_delegate

	var/damage = (rand(base_damage, base_damage + 5) + 5 * behavior.armor_state)

	carbon.apply_armoured_damage(get_xeno_damage_slash(carbon, damage), ARMOR_MELEE, BRUTE)

	fling_user.face_atom(carbon)
	fling_user.animation_attack_on(carbon)
	fling_user.flick_attack_overlay(carbon, "disarm")
	fling_user.throw_carbon(carbon, facing, behavior.armor_state + 3, SPEED_VERY_FAST, shake_camera = TRUE, immobilize = TRUE)

	apply_cooldown()
	return ..()

/////////////////////
// Заряженный удар //
/datum/action/xeno_action/onclick/skull_breaker
	name = "Череполом"
	icon_file = 'core_ru/Feline/icons/actions_xeno.dmi'
	action_icon_state = "skull_breaker"
	macro_path = /datum/action/xeno_action/verb/verb_skull_breaker
	ability_primacy = XENO_PRIMARY_ACTION_1
	action_type = XENO_ACTION_ACTIVATE
	xeno_cooldown = 15 SECONDS

	var/buff_duration = 10 SECONDS

// Макрос
/datum/action/xeno_action/verb/verb_skull_breaker()
	set category = "Alien"
	set name = "Череполом"
	set hidden = TRUE
	var/action_name = "Череполом"
	handle_xeno_macro(src, action_name)

// Функция
/datum/action/xeno_action/onclick/skull_breaker/use_ability(atom/targeted_atom)
	var/mob/living/carbon/xenomorph/xeno = owner

	if (!istype(xeno))
		return

	if (!action_cooldown_check())
		return

	var/datum/behavior_delegate/warrior_knight/behavior = xeno.behavior_delegate
	if (istype(behavior))
		behavior.next_slash_buffed = TRUE

	to_chat(xeno, SPAN_XENOHIGHDANGER("Наш следующий удар нанесет повышенный урон!"))
	playsound(xeno,'core_ru/Feline/sound/metall_hit_3.ogg', 25, 1)

	addtimer(CALLBACK(src, PROC_REF(unbuff_slash)), buff_duration)

	apply_cooldown()
	return ..()

/datum/action/xeno_action/onclick/skull_breaker/proc/unbuff_slash()
	var/mob/living/carbon/xenomorph/xeno = owner
	if (!istype(xeno))
		return
	var/datum/behavior_delegate/warrior_knight/behavior = xeno.behavior_delegate
	if (istype(behavior))
		if (!behavior.next_slash_buffed)
			return
		behavior.next_slash_buffed = FALSE

	to_chat(xeno, SPAN_XENODANGER("Мы слишком долго тянули с заряженным ударом, наша следующая атака будет обычной!"))
