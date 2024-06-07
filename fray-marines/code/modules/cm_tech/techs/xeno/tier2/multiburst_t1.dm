/datum/tech/xeno/multiburst_t1
	name = "Бесноватое порождение"
	desc = "Незначительно увеличивает количество рождаемых лярв из одного носителя. \n1 лярва - 67%, 2 лярвы - 33%."
	icon = 'fray-marines/icons/effects/techtree/tech.dmi'
	icon_state = "multi_burst_1"

	flags = TREE_FLAG_XENO
	required_points = 10
	tier = /datum/tier/two

/datum/tech/xeno/multiburst_t1/on_unlock(datum/techtree/tree)
	. = ..()
	GLOB.xeno_multiburst = 2
	xeno_announcement("<i>\"Люди, принявшие их в себя, становились тотчас же бесноватыми и сумасшедшими...\"</i>\n\nМы чувствуем как наша плодовитость усилилась! Из одного носителя с небольшим шансом может родится 2 сестры!", hivenumber, "Открыто улучшение улья - \"Бесноватое Порождение\"")
