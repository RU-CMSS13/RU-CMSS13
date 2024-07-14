/datum/tech/xeno/multiburst_t3
	name = "Кровавый легион"
	desc = "Максимально увеличивает количество рождаемых лярв из одного носителя. \n2 лярвы - 60%, 3 лярвы - 30%, 4 лярвы 10%."
	icon = 'core_ru/icons/effects/techtree/tech.dmi'
	icon_state = "multi_burst_3"

	flags = TREE_FLAG_XENO
	required_points = 10
	tier = /datum/tier/four

/datum/tech/xeno/multiburst_t3/on_unlock(datum/techtree/tree)
	. = ..()
	GLOB.xeno_multiburst = 4
	xeno_announcement("<i>\"И имя мне легион, потому что нас много...\"</i>\n\nМы чувствуем как наша плодовитость достигла максимума! Из одного носителя может родится от 2 до 4 сестер!", hivenumber, "Открыто улучшение улья - \"Кровавый легион\"")

/datum/tech/xeno/multiburst_t3/can_unlock(mob/M)
	. = ..()
	if(!.)
		return

	if(GLOB.xeno_multiburst != 3)
		to_chat(M, SPAN_XENOHIGHDANGER("Сначала откройте второй уровень!"))
		return FALSE
