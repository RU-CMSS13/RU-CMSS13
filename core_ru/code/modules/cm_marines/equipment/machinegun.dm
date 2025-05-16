/**
 * RUCM Feline "Фоботы"
 * Добавляет навык владения пулемётом и повышает удобство его использования при наличии этого навыка: кнопки поворота и прицела, стрельба поверх
 * кад, пулемёт можно починить сваркой после разрушения, а так же растворить кислотой
 * Затронутые файлы:
 * code\modules\cm_marines\smartgun_mount.dm
 */

//////////////////
// Пулемет М56d //
/datum/skill/feline_machinegunner
	skill_name = SKILL_MACHINGUNNER
	skill_level = SKILL_MACHINGUNNER_DEFAULT
	max_skill_level = SKILL_MACHINGUNNER_MAX

/obj/item/pamphlet/skill/machinegunner
	name = "Брошюра крупнокалиберного пулемётчика"
	desc = "Брошюра, для быстрого освоения практических навыков. На обложке присутствует эмблема инженерных войск и изображение пулемёта."
	icon_state = "pamphlet_machinegunner"
	trait = /datum/character_trait/skills/feline_machinegunner
	bypass_pamphlet_limit = TRUE

/datum/character_trait/skills/feline_machinegunner
	trait_name = "Тренировка Пулемётчика"
	trait_desc = "Отвечает за навык стрельбы из крупнокалиберного пулемёта."
	skill_increment = 1
	skill = SKILL_MACHINGUNNER
	skill_cap = SKILL_MACHINGUNNER_TRAINED
	secondary_skill = SKILL_ENGINEER
	secondary_skill_cap = SKILL_ENGINEER_NOVICE

/obj/item/device/m56d_gun
	icon = 'core_ru/Feline/icons/machinegun.dmi'
	item_icons = list(
		WEAR_BACK = 'icons/mob/humans/onmob/clothing/back/guns_by_type/machineguns.dmi',
		WEAR_L_HAND = 'icons/mob/humans/onmob/inhands/weapons/guns/machineguns_lefthand.dmi',
		WEAR_R_HAND = 'icons/mob/humans/onmob/inhands/weapons/guns/machineguns_righthand.dmi'
	)
	icon_state = "M56D_gun_e"
	defense_check_range = 2
	zoom = FALSE
	var/broken_gun = FALSE
	var/field_recovery = 130

/obj/structure/machinery/m56d_hmg
	icon = 'core_ru/Feline/icons/machinegun.dmi'

// Прицел
/datum/action/human_action/mg_scope
	name = "Переключить прицел"
	icon_file = 'core_ru/Feline/icons/machinegun_actions.dmi'
	action_icon_state = "accuracy_improvement"

/datum/action/human_action/mg_scope/action_activate()
	. = ..()
	if(!can_use_action())
		return

	if(!skillcheck(owner, SKILL_MACHINGUNNER, SKILL_MACHINGUNNER_TRAINED))
		to_chat(owner, SPAN_WARNING("Я не знаю как этим пользоваться!"))
		return

	var/mob/living/carbon/human/human_user = owner
	SEND_SIGNAL(human_user, COMSIG_MOB_MG_SCOPE)

// Поворот налево / против часовой
/datum/action/human_action/mg_turn_left
	name = "Повернуть против часовой стрелки"
	icon_file = 'core_ru/Feline/icons/machinegun_actions.dmi'
	action_icon_state = "mg_turn_left"
//	listen_signal = COMSIG_KB_HUMAN_WEAPON_MG_TURN_LEFT

/datum/action/human_action/mg_turn_left/action_activate()
	. = ..()
	if(!can_use_action())
		return

	if(!skillcheck(owner, SKILL_MACHINGUNNER, SKILL_MACHINGUNNER_TRAINED))
		to_chat(owner, SPAN_WARNING("Я не знаю как этим пользоваться!"))
		return

	var/mob/living/carbon/human/human_user = owner
	SEND_SIGNAL(human_user, COMSIG_MOB_MG_TURN_LEFT)

// Поворот направо / по часовой
/datum/action/human_action/mg_turn_right
	name = "Повернуть по часовой стрелке"
	icon_file = 'core_ru/Feline/icons/machinegun_actions.dmi'
	action_icon_state = "mg_turn_right"

/datum/action/human_action/mg_turn_right/action_activate()
	. = ..()
	if(!can_use_action())
		return

	if(!skillcheck(owner, SKILL_MACHINGUNNER, SKILL_MACHINGUNNER_TRAINED))
		to_chat(owner, SPAN_WARNING("Я не знаю как этим пользоваться!"))
		return

	var/mob/living/carbon/human/human_user = owner
	SEND_SIGNAL(human_user, COMSIG_MOB_MG_TURN_RIGHT)
