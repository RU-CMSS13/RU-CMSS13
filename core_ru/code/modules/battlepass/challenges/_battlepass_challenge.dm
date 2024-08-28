//[ {"desc":"", "xp_completion":0, "mapped_modules":{["cn":"ex", "opt":{"req":{}, ...}], ...}}, ...]
// cn is code name, opt is vars to replace
/datum/battlepass_challenge
	var/desc = "Example"
	var/xp_completion = 0
	// Modules builder
	var/list/mapped_modules

	// Untracked
	var/completed = FALSE
	var/list/datum/battlepass_challenge_module/modules = list()

/datum/battlepass_challenge/New(list/opt)
	if(opt)
		for(var/param in opt)
			vars[param] = opt[param]

		for(var/list/list_module in mapped_modules)
			var/target_type = GLOB.challenge_modules_types[list_module["cn"]]
			var/datum/battlepass_challenge_module/module = new target_type(list_module["opt"])
			module.challenge_ref = src
			modules += module

		completed = check_challenge_completed()
		regenerate_desc()

/datum/battlepass_challenge/proc/regenerate_desc()
	var/new_desc = ""
	for(var/datum/battlepass_challenge_module/module in modules)
		new_desc += module.get_description()
	desc = new_desc

/datum/battlepass_challenge/proc/get_completion_percent()
	return (get_completion_numerator() / get_completion_denominator())

/datum/battlepass_challenge/proc/get_completion_numerator()
	var/current_max = 0
	for(var/datum/battlepass_challenge_module/module in modules)
		if(!length(module.req))
			continue
		for(var/progress_name in module.req)
			current_max += module.req[progress_name][1]
	return current_max

/datum/battlepass_challenge/proc/get_completion_denominator()
	var/current_max = 1
	for(var/datum/battlepass_challenge_module/module in modules)
		if(!length(module.req))
			continue
		for(var/progress_name in module.req)
			current_max += module.req[progress_name][2]
	return current_max

/datum/battlepass_challenge/proc/check_challenge_completed()
	for(var/datum/battlepass_challenge_module/module in modules)
		if(module.on_possible_challenge_completed())
			continue
		return FALSE
	if(get_completion_numerator() == get_completion_denominator())
		return TRUE
	return FALSE

/datum/battlepass_challenge/proc/on_possible_challenge_completed()
	if(!check_challenge_completed())
		return FALSE
	SEND_SIGNAL(src, COMSIG_BATTLEPASS_CHALLENGE_COMPLETED)
	return TRUE

//Signals
/datum/battlepass_challenge/proc/on_client(client/logged)
	if(logged && !completed)
		if(logged.mob)
			hook_signals(src, logged.mob)
		else
			RegisterSignal(logged, COMSIG_CLIENT_MOB_LOGGED_IN, PROC_REF(hook_signals))

/datum/battlepass_challenge/proc/hook_signals(datum/source, mob/logged_mob)
	SIGNAL_HANDLER
	SHOULD_CALL_PARENT(TRUE)

	UnregisterSignal(logged_mob.client, COMSIG_CLIENT_MOB_LOGGED_IN)
	RegisterSignal(logged_mob, COMSIG_MOB_LOGOUT, PROC_REF(unhook_signals))

	if(logged_mob.statistic_exempt)
		return FALSE

	for(var/datum/battlepass_challenge_module/module in modules)
		module.hook_signals(logged_mob)

	return TRUE

/datum/battlepass_challenge/proc/unhook_signals(mob/source)
	SIGNAL_HANDLER
	SHOULD_CALL_PARENT(TRUE)

	UnregisterSignal(source, COMSIG_MOB_LOGOUT)
	if(source.logging_ckey in GLOB.directory)
		RegisterSignal(GLOB.directory[source.logging_ckey], COMSIG_CLIENT_MOB_LOGGED_IN, PROC_REF(hook_signals))

	if(source.statistic_exempt)
		return FALSE

	for(var/datum/battlepass_challenge_module/module in modules)
		module.unhook_signals(source)

	return TRUE

//[ {"desc":"", "xp_completion":0, "mapped_modules":{"killp1": {"cn":"ex","opt":{"req":{}, ...}}, ...}, "progress":{}}, ...]

/datum/battlepass_challenge/proc/serialize()
	SHOULD_CALL_PARENT(TRUE)
	var/list/re_mapped_modules = list()
	for(var/datum/battlepass_challenge_module/module in modules)
		re_mapped_modules += module.serialize()
	return list(
		"desc" = desc,
		"xp_completion" = xp_completion,
		"mapped_modules" = re_mapped_modules
	)

//TODO: СДЕЛАТЬ ВЫДАЧУ ЕСЛИ ЕСТЬ module_exp или module_exp_modificator

// Handle moduled req actions to finish challenge
/datum/battlepass_challenge_module
	var/name = "Example"
	var/desc = "Example"
	var/code_name = "ex"
	var/datum/battlepass_challenge/challenge_ref

	var/pick_weight = 0
	var/module_exp = list(0, 0)
	var/module_exp_modificator = 1

	var/signals
	var/list/req_gen
	var/list/compatibility = list("strict" = list(), "subtyped" = list()) // Проверяется пикая следующее условие, например есть 1 и в 2, теперь время выбрать 3, мы смотрим что в 2 за ограничения на пик

	// Tracked
	var/list/req

/datum/battlepass_challenge_module/New(list/opt)
	if(opt)
		for(var/param in opt)
			vars[param] = opt[param]

/datum/battlepass_challenge_module/proc/get_description()
	. = initial(desc)
	for(var/name in req)
		. = replacetext_char(., "###[name]###", req[name])
	desc = .

/datum/battlepass_challenge_module/proc/hook_signals(mob/logged_mob)
	SIGNAL_HANDLER
	SHOULD_CALL_PARENT(TRUE)
	if(logged_mob.statistic_exempt)
		return FALSE
	return TRUE

/datum/battlepass_challenge_module/proc/unhook_signals(mob/logged_mob)
	SIGNAL_HANDLER
	SHOULD_CALL_PARENT(TRUE)
	if(logged_mob.statistic_exempt)
		return FALSE
	return TRUE

/datum/battlepass_challenge_module/proc/serialize(list/options)
	options["req"] = req
	. = list(list("cn" = code_name, "opt" = options))

/datum/battlepass_challenge_module/proc/on_possible_challenge_completed()
	return TRUE

/datum/battlepass_challenge_module/proc/allow_completion()
	return TRUE


// Задача сделать модульные челенджи по типу "Убить 2 ксеноса" + ", с m41a" + " при передозе Oxycodone"



//TODO: Creating task
/*
/datum/battlepass_challenge/New(client/owner)
	. = ..()
	if(!completion_xp)
		if(length(completion_xp_array))
			completion_xp = rand(completion_xp_array[1], completion_xp_array[2])
		if(GLOB.current_battlepass.mapped_point_sources["daily"][code_name] && length(GLOB.current_battlepass.mapped_point_sources["daily"][code_name]["xp"]))
			completion_xp = rand(GLOB.current_battlepass.mapped_point_sources["daily"][code_name]["xp"][1], GLOB.current_battlepass.mapped_point_sources["daily"][code_name]["xp"][2])

	if(owner)
		on_client_hooked(owner)

*/


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
			/datum/battlepass_challenge_module/condition/with,
			/datum/battlepass_challenge_module/condition/without,
			/datum/battlepass_challenge_module/condition/after,
			/datum/battlepass_challenge_module/condition/before,
			/datum/battlepass_challenge_module/condition/and,
			/datum/battlepass_challenge_module/condition/or,
			/datum/battlepass_challenge_module/condition/exempt
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
			/datum/battlepass_challenge_module/condition/or,
			/datum/battlepass_challenge_module/condition/exempt
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

// " или"
/datum/battlepass_challenge_module/condition/or
	name = "Or"
	desc = " or"
	code_name = "or"

	compatibility = list("strict" = list(), "subtyped" = list(/datum/battlepass_challenge_module/requirement))

// " исключая"
/datum/battlepass_challenge_module/condition/exempt
	name = "Exempt"
	desc = " exempt"
	code_name = "exempt"

	compatibility = list("strict" = list(), "subtyped" = list(/datum/battlepass_challenge_module/requirement))


// REQUIREMENTS

/datum/battlepass_challenge_module/requirement // Базовое требование для выполнения задачи

/datum/battlepass_challenge_module/requirement/proc/can_apply(mob_type)
	return TRUE


//Kill
/datum/battlepass_challenge_module/requirement/kill
	name = "Kill"
	desc = "Kill ###kills### enemies"
	code_name = "kill"

	module_exp = list(4, 8)

	req_gen = list("kills" = list(2, 6))

	var/list/valid_kill_paths = list("strict" = list(), "subtyped" = list())

/datum/battlepass_challenge_module/requirement/kill/hook_signals(datum/source, mob/logged_in_mob)
	. = ..()
	if(!.)
		return
	RegisterSignal(logged_in_mob, COMSIG_MOB_KILL_TOTAL_INCREASED, PROC_REF(on_kill))


/datum/battlepass_challenge_module/requirement/kill/unhook_signals(mob/logged_mob)
	. = ..()
	if(!.)
		return
	UnregisterSignal(logged_mob, COMSIG_MOB_KILL_TOTAL_INCREASED)

/datum/battlepass_challenge_module/requirement/kill/proc/on_kill(mob/source, mob/killed_mob, datum/cause_data/cause_data)
	SIGNAL_HANDLER

	if(!killed_mob.life_value)
		return FALSE

	if(source.faction == killed_mob.faction)
		return FALSE

	if((killed_mob.type in valid_kill_paths["strict"]) || (length(valid_kill_paths["subtyped"]) && is_type_in_list(killed_mob, valid_kill_paths["subtyped"])))
		var/current_pos = challenge_ref.modules[src]
		var/datum/battlepass_challenge_module/next_module = challenge_ref.modules[current_pos + 1]
		if(!next_module.allow_completion())
			return FALSE

		req[req[1]][1]++
		on_possible_challenge_completed()

/datum/battlepass_challenge_module/requirement/kill/human
	name = "Kill Humans"
	desc = "Kill ###human_kills### humans"
	code_name = "kill_human"

	module_exp = list(6, 10)

	req_gen = list("human_kills" = list(2, 6))

	valid_kill_paths = list("strict" = list(), "subtyped" = list(/mob/living/carbon/human))

/datum/battlepass_challenge_module/requirement/kill/xenomorph
	name = "Kill Xenomorphs"
	desc = "Kill ###xenomorph_kills### xenomorphs"
	code_name = "kill_xenomorph"

	module_exp = list(6, 10)

	req_gen = list("xenomorph_kills" = list(2, 6))

	valid_kill_paths = list("strict" = list(), "subtyped" = list(/mob/living/carbon/xenomorph))

/datum/battlepass_challenge_module/requirement/kill/xenomorph/caste
	name = "Kill Xenomorphs - Caste"
	desc = "Kill ###xenomorph_kills### ###castes###."
	code_name = "kill_xenomorph_caste"

	valid_kill_paths = list("strict" = list(), "subtyped" = list(/mob/living/carbon/xenomorph))

	var/mob/xeno_caste

//TODO: Get here selection and module_exp * on xeno tier value

/datum/battlepass_challenge_module/requirement/kill/xenomorph/caste/get_description()
	. = ..()
	. = replacetext_char(., "###castes###", initial(xeno_caste.name))

/datum/battlepass_challenge_module/requirement/kill/xenomorph/caste/serialize(list/options)
	options["xeno_caste"] = xeno_caste
//


//Additional
/datum/battlepass_challenge_module/requirement/additional

/datum/battlepass_challenge_module/requirement/additional/weapon
	name = "Weapon"
	desc = "using a ###weapon###"
	code_name = "weapon"

	module_exp_modificator = 1.25

	var/list/possible_weapons = list()
	var/obj/weapon_to_use

/datum/battlepass_challenge_module/requirement/additional/weapon/get_description()
	. = ..()
	. = replacetext_char(., "###weapon###", initial(weapon_to_use.name))

/datum/battlepass_challenge_module/requirement/additional/weapon/allow_completion(mob/source, mob/killed_mob, datum/cause_data/cause_data)
	if(!findtext(cause_data.cause_name, weapon_to_use))
		return FALSE
	return TRUE

/datum/battlepass_challenge_module/requirement/additional/weapon/serialize(list/options)
	options["weapon_to_use"] = weapon_to_use

/datum/battlepass_challenge_module/requirement/additional/weapon/common
	code_name = "weapon_common"

	module_exp_modificator = 1.2

	possible_weapons = list(
		/obj/item/weapon/gun/smg/m39,
		/obj/item/weapon/gun/rifle/m4ra,
		/obj/item/weapon/gun/rifle/m41a,
		/obj/item/weapon/gun/shotgun/pump,
	)

/datum/battlepass_challenge_module/requirement/additional/weapon/pistol
	code_name = "weapon_pistol"

	module_exp_modificator = 1.5

	possible_weapons = list(
		/obj/item/storage/box/guncase/vp78,
		/obj/item/storage/box/guncase/smartpistol,
		/obj/item/weapon/gun/pistol/mod88,
		/obj/item/weapon/gun/revolver/m44,
		/obj/item/weapon/gun/pistol/m4a3,
	)

/datum/battlepass_challenge_module/requirement/additional/weapon/req
	code_name = "weapon_req"

	module_exp_modificator = 1.1

	possible_weapons = list(
		/obj/item/weapon/gun/flame,
		/obj/item/weapon/gun/shotgun/double/mou53,
		/obj/item/storage/box/guncase/xm88,
		/obj/item/weapon/gun/rifle/m41a,
		/obj/item/storage/box/guncase/m41aMK1,
		/obj/item/storage/box/guncase/lmg,
	)
//


//Buffs
/datum/battlepass_challenge_module/requirement/good_buffs // Хороший, баф который должен быть исключен для выполенния задания (саб задание)

/datum/battlepass_challenge_module/requirement/good_buffs/ammunition
	name = "Ammunition"
	desc = " ammunition ###type###"
	code_name = "overdose"

	module_exp = list(2, 4)

	var/list/ammo_types = list()
//


//Debuffs
/datum/battlepass_challenge_module/requirement/bad_buffs // Плохой баф, который должен быть для выполнения задания (саб задание)

/datum/battlepass_challenge_module/requirement/bad_buffs/overdose
	name = "OD"
	desc = " OD ###type###"
	code_name = "overdose"

	module_exp = list(2, 4)

	var/list/overdose_types = list()

/datum/battlepass_challenge_module/requirement/bad_buffs/overdose/small
	module_exp_modificator = 1.5
//
