// 	Стрейны низшего
/datum/xeno_strain/scout
	name = "Разведчик"
	description = "Мутация - Разведчик: Теряя смольную, кислотную железы и феромоны, вы получаете возможность кратковременного ускорения скорости передвижения - однако во время спринта сила атаки снижатся вдвое. В дополнение к этому у вас перманентно увеличивается радиус обзора."
	flavor_description = "Run!"
	icon_state_prefix = "Scout"

	actions_to_remove = list(
		/datum/action/xeno_action/onclick/emit_pheromones,
		/datum/action/xeno_action/activable/corrosive_acid/weak,
		/datum/action/xeno_action/onclick/plant_weeds/lesser,
		/datum/action/xeno_action/onclick/choose_resin,
		/datum/action/xeno_action/activable/secrete_resin,
	)
	actions_to_add = list(
		/datum/action/xeno_action/onclick/lesser_run,
	)

/datum/xeno_strain/scout/apply_strain(mob/living/carbon/xenomorph/lesser_drone/lesser)
	lesser.client?.change_view(9, src)
	lesser.health_modifier -= XENO_HEALTH_MOD_SMALL

	lesser.recalculate_everything()

//	Способности

/datum/action/xeno_action/onclick/lesser_run
	name = "На четырех лапах"
	action_icon_state = "agility_on"
	ability_name = "На четырех лапах"
	macro_path = /datum/action/xeno_action/verb/verb_lesser_shield
	ability_primacy = XENO_PRIMARY_ACTION_1
	plasma_cost = 100
	action_type = XENO_ACTION_CLICK
	xeno_cooldown = 45 SECONDS
	cooldown_message = "Мы отдохнули и готовы бежать вновь."
	var/speed_bonus = XENO_SPEED_TIER_8

/datum/action/xeno_action/verb/verb_lesser_run()
	set category = "Alien"
	set name = "На четырех лапах"
	set hidden = TRUE
	var/action_name = "lesser_run"
	handle_xeno_macro(src, action_name)

/datum/action/xeno_action/onclick/lesser_run/use_ability(atom/Target)
	var/mob/living/carbon/xenomorph/xeno = owner

	if (!istype(xeno))
		return

	if (!action_cooldown_check())
		return

	if (!xeno.check_state())
		return

	if (!check_and_use_plasma_owner())
		return

	xeno.visible_message(SPAN_XENOWARNING("[xeno] опускается на четыре лапы и стремительно набирает скорость!"), SPAN_XENOHIGHDANGER("Мы опускаемся на все четыре лапы и начинаем набирать скорость!"))
	button.icon_state = "template_active"

	xeno.speed_modifier += speed_bonus
	xeno.damage_modifier -= XENO_DAMAGE_MOD_SMALL
	xeno.recalculate_everything()

	addtimer(CALLBACK(src, PROC_REF(remove_lesser_run)), 150, TIMER_UNIQUE|TIMER_OVERRIDE)

	apply_cooldown()
	return ..()

/datum/action/xeno_action/onclick/lesser_run/proc/remove_lesser_run()
	var/mob/living/carbon/xenomorph/xeno = owner
	xeno.speed_modifier = initial(xeno.speed_modifier)
	xeno.damage_modifier = initial(xeno.damage_modifier)
	xeno.recalculate_everything()
	to_chat(xeno, SPAN_XENOHIGHDANGER("Мы слишком устали чтобы бежать дальше"))
	button.icon_state = "template"
