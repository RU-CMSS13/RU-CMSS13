/datum/tech/xeno/multiburst_t2
	name = "Безумное деление"
	desc = "Значительно увеличивает количество рождаемых лярв из одного носителя. \n1 лярва - 30%, 2 лярвы - 60%, 3 лярвы 10%."
	icon = 'fray-marines/icons/effects/techtree/tech.dmi'
	icon_state = "multi_burst_2"

	flags = TREE_FLAG_XENO
	required_points = 10
	tier = /datum/tier/three

/datum/tech/xeno/multiburst_t2/on_unlock(datum/techtree/tree)
	. = ..()
	GLOB.xeno_multiburst = 3
	xeno_announcement("<i>\"Безумие порождает только безумие...\"</i>\n\nМы чувствуем как наша плодовитость прогрессирует! Из одного носителя может родится от 1 до 3 сестер!", hivenumber, "Открыто улучшение улья - \"Безумное Деление\"")

/datum/tech/xeno/multiburst_t2/can_unlock(mob/M)
	. = ..()
	if(!.)
		return

	if(GLOB.xeno_multiburst != 2)
		to_chat(M, SPAN_XENOHIGHDANGER("Сначала откройте первый уровень!"))
		return FALSE
