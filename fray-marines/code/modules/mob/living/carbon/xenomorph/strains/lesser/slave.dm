GLOBAL_LIST_INIT(resin_build_order_lesser_slave, list(
	/datum/resin_construction/resin_turf/wall/lesser_slave,
	/datum/resin_construction/resin_turf/membrane/lesser_slave,
	/datum/resin_construction/resin_obj/door/lesser_slave,
	/datum/resin_construction/resin_obj/sticky_resin,
	/datum/resin_construction/resin_obj/fast_resin,
	))

/datum/xeno_strain/slave
	name = "Раб"
	description = "Мутация - Раб: Вы теряете кислотную железу, возможность атаковать, но взамен значительно увеличиваете запас плазмы и увеличиваете скорость строительства. Однако возведенные вами постройки будут слабее и вы будете погибать вне смолы."
	flavor_description = "Okay, okay i will work!"
	icon_state_prefix = "Slave"

	actions_to_remove = list(
		/datum/action/xeno_action/activable/corrosive_acid/weak,
		/datum/action/xeno_action/activable/tail_stab,
	)

	behavior_delegate_type = /datum/behavior_delegate/lesser_slave

/datum/xeno_strain/slave/apply_strain(mob/living/carbon/xenomorph/lesser_drone/lesser)
	lesser.plasmapool_modifier = 1.5 // +50%
	lesser.speed_modifier = XENO_SPEED_SLOWMOD_TIER_4
	lesser.damage_modifier -= XENO_DAMAGE_MOD_LARGE
	lesser.tackle_chance_modifier = -35
	lesser.caste.build_time_mult = BUILD_TIME_MULT_BUILDER

	lesser.recalculate_everything()

	lesser.set_resin_build_order(GLOB.resin_build_order_lesser_slave)
	for(var/datum/action/xeno_action/action in lesser.actions)

		if(istype(action, /datum/action/xeno_action/onclick/choose_resin))
			var/datum/action/xeno_action/onclick/choose_resin/choose_resin_ability = action
			if(choose_resin_ability)
				choose_resin_ability.update_button_icon(lesser.selected_resin)
				break

//  Смерть вне травы
/datum/behavior_delegate/lesser_slave/on_life()
	if(bound_xeno.body_position == STANDING_UP && !(locate(/obj/effect/alien/weeds) in get_turf(bound_xeno)))
		bound_xeno.adjustBruteLoss(20)

//	Способности

/datum/resin_construction/resin_turf/wall/lesser_slave
	name = "Смоляная Стена"
	desc = "Хрупкая смоляная стена."
	cost = 60
	build_path = /turf/closed/wall/resin/lesser_slave
	build_animation_effect = /obj/effect/resin_construct/weak

/turf/closed/wall/resin/lesser_slave
	name = "хрупкая смоляная стена"
	desc = "Хрупкая смолянистая масса, образующая некоторое подобие стены."
	damage_cap = 600
	color = rgb(181, 222, 248)

/datum/resin_construction/resin_turf/membrane/lesser_slave
	name = "Хрупкая Смоляная Мембрана"
	desc = "Смоляная полупрозрачная мембрана."
	cost = 50
	build_path = /turf/closed/wall/resin/membrane/lesser_slave
	build_animation_effect = /obj/effect/resin_construct/transparent/weak

/turf/closed/wall/resin/membrane/lesser_slave
	name = "хрупкая смоляная мембрана"
	desc = "Неприятная на вид, полупрозрачная, смолистая масса."
	damage_cap = 200
	color = rgb(181, 222, 248)

/datum/resin_construction/resin_obj/door/lesser_slave
	name = "Хрупкая Смоляная Дверь"
	desc = "Смоляная дверь пропускающая только наших сестер."
	cost = 60
	build_path = /obj/structure/mineral_door/resin/lesser_slave
	build_animation_effect = /obj/effect/resin_construct/door

/obj/structure/mineral_door/resin/lesser_slave
	name = "хрупкая смоляная дверь"
	hardness = 1
	health = 300
	color = rgb(181, 222, 248)
