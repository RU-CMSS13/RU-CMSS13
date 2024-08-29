
// CONDITIONS
//TODO: conditions

/datum/battlepass_challenge_module/condition
	pick_weight = 5

//Задержка, например "Убить 4 морпехов" + " с задержкой 2 минуты"
/datum/battlepass_challenge_module/condition/delay
	name = "Delay"
	desc = " with delay ###DELAY###"
	code_name = "delay"

	module_exp_modificator = 1.25

	compatibility = list(
		"strict" = list(
			/datum/battlepass_challenge_module/condition/after,
			/datum/battlepass_challenge_module/condition/before,
			/datum/battlepass_challenge_module/condition/and,
			/datum/battlepass_challenge_module/condition/exempt,
		),
		"subtyped" = list()
	)

//За отведенное время, например "Реанимировать 10 морпехов" + " за 2 минуты"
/datum/battlepass_challenge_module/condition/time
	name = "Time"
	desc = " in ###TIME###"
	code_name = "time"

	module_exp_modificator = 1.25

	compatibility = list(
		"strict" = list(
			/datum/battlepass_challenge_module/condition/with,
			/datum/battlepass_challenge_module/condition/without,
			/datum/battlepass_challenge_module/condition/after,
			/datum/battlepass_challenge_module/condition/before,
			/datum/battlepass_challenge_module/condition/and,
			/datum/battlepass_challenge_module/condition/exempt,
		),
		"subtyped" = list()
	)

//"Убить 2 ксеносов" + " с" (наприммер " m41a")
/datum/battlepass_challenge_module/condition/with
	name = "With"
	desc = " with"
	code_name = "with"

	compatibility = list("strict" = list(), "subtyped" = list(/datum/battlepass_challenge_module/requirement/bad_buffs))

//"Убить 2 ксеносов" + " без" (например " брони")
/datum/battlepass_challenge_module/condition/without
	name = "Without"
	desc = " without"
	code_name = "without"

	compatibility = list("strict" = list(), "subtyped" = list(/datum/battlepass_challenge_module/requirement/good_buffs))

//"Убить 4 ксеноса" + " после" (" реанимации" / " краша" / " оглушения" / или другой сложный реквайрмент)
/datum/battlepass_challenge_module/condition/after
	name = "After"
	desc = " after"
	code_name = "after"

	compatibility = list("strict" = list(), "subtyped" = list(/datum/battlepass_challenge_module/requirement))

//"Убить 4 ксеноса" + " перед" (" реанимацией" + некст действие / " краша" / " оглушения")
/datum/battlepass_challenge_module/condition/before
	name = "Before"
	desc = " before"
	code_name = "before"

	compatibility = list("strict" = list(), "subtyped" = list(/datum/battlepass_challenge_module/requirement))

// " и"
/datum/battlepass_challenge_module/condition/and
	name = "And"
	desc = " and"
	code_name = "and"

	compatibility = list("strict" = list(), "subtyped" = list(/datum/battlepass_challenge_module/requirement))

// " исключая"
/datum/battlepass_challenge_module/condition/exempt
	name = "Exempt"
	desc = " exempt"
	code_name = "exempt"

	compatibility = list("strict" = list(), "subtyped" = list(/datum/battlepass_challenge_module/requirement))
