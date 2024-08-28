//[ {"desc":"", "xp_completion":0, "mapped_modules":{["cn":"ex", "opt":{"req":{}, ...}], ...}}, ...]
// cn is code name, opt is vars to replace
/datum/battlepass_challenge
	var/name = "Example"
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
	name = null
	var/new_desc = ""
	for(var/datum/battlepass_challenge_module/module in modules)
		if(!name)
			name = module.name
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

/datum/battlepass_challenge_module/requirement/kill/hook_signals(mob/logged_mob)
	. = ..()
	if(!.)
		return
	var/req_name = req[1]
	if(req[req_name][1] == req[req_name][2])
		return
	RegisterSignal(logged_mob, COMSIG_MOB_KILL_TOTAL_INCREASED, PROC_REF(on_kill))


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
	desc = "Kill ###xenomorph_kills### ###castes###"
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

//Defib
/datum/battlepass_challenge_module/requirement/defib
	name = "Defibrillate Players"
	desc = "Successfully defibrillate ###defib### unique marine players"
	code_name = "defib"

	module_exp = list(6, 12)

	req_gen = list("defib" = list(10, 20))

	var/list/mob_name_list = list()

/datum/battlepass_challenge_module/requirement/defib/hook_signals(mob/logged_mob)
	. = ..()
	if(!.)
		return
	var/req_name = req[1]
	if(req[req_name][1] == req[req_name][2])
		return
	RegisterSignal(logged_mob, COMSIG_HUMAN_USED_DEFIB, PROC_REF(on_defib))

/datum/battlepass_challenge_module/requirement/defib/unhook_signals(mob/logged_mob)
	. = ..()
	if(!.)
		return
	UnregisterSignal(logged_mob, COMSIG_HUMAN_USED_DEFIB)

/// When the xeno plants a resin node
/datum/battlepass_challenge_module/requirement/defib/proc/on_defib(datum/source, mob/living/carbon/human/defibbed)
	SIGNAL_HANDLER

	var/current_pos = challenge_ref.modules[src]
	var/datum/battlepass_challenge_module/next_module = challenge_ref.modules[current_pos + 1]
	if(!next_module.allow_completion())
		return FALSE

	mob_name_list |= defibbed.real_name
	req[req[1]][1]++
	on_possible_challenge_completed()

/datum/battlepass_challenge_module/requirement/defib/serialize(list/options)
	options["mob_name_list"] = mob_name_list
//

//Xeno
/*
/datum/battlepass_challenge/berserker_rage
	name = "Max Berserker Rage"
	code_name = "xenobrage"
	desc = "As a Berserker Ravager, enter maximum berserker rage AMOUNT times."
	challenge_category = CHALLENGE_XENO
	completion_xp_array = list(4, 6)
	pick_weight = 6
	/// The minimum possible amount of times rage needs to be entered
	var/minimum_rages = 2
	/// The maximum
	var/maximum_rages = 4
	var/rage_requirement = 0
	var/completed_rages = 0

/datum/battlepass_challenge/berserker_rage/New(client/owning_client)
	. = ..()

	rage_requirement = rand(minimum_rages, maximum_rages)
	regenerate_desc()

/datum/battlepass_challenge/berserker_rage/regenerate_desc()
	desc = "As a Berserker Ravager, enter maximum berserker rage [rage_requirement] time\s."

/datum/battlepass_challenge/berserker_rage/hook_client_signals(datum/source, mob/logged_in_mob)
	. = ..()
	if(!.)
		return
	if(!completed)
		RegisterSignal(logged_in_mob, COMSIG_XENO_RAGE_MAX, PROC_REF(on_rage_max))

/datum/battlepass_challenge/berserker_rage/unhook_signals(mob/source)
	UnregisterSignal(source, COMSIG_XENO_RAGE_MAX)

/datum/battlepass_challenge/berserker_rage/check_challenge_completed()
	return (completed_rages >= rage_requirement)

/datum/battlepass_challenge/berserker_rage/get_completion_percent()
	return (completed_rages / rage_requirement)

/datum/battlepass_challenge/berserker_rage/get_completion_numerator()
	return completed_rages

/datum/battlepass_challenge/berserker_rage/get_completion_denominator()
	return rage_requirement

/datum/battlepass_challenge/berserker_rage/serialize()
	. = ..()
	.["rage_requirement"] = rage_requirement
	.["completed_rages"] = completed_rages

/datum/battlepass_challenge/berserker_rage/deserialize(list/save_list)
	. = ..()
	rage_requirement = save_list["rage_requirement"]
	completed_rages = save_list["completed_rages"]

/// When the xeno plants a resin node
/datum/battlepass_challenge/berserker_rage/proc/on_rage_max(datum/source)
	SIGNAL_HANDLER

	completed_rages++
	on_possible_challenge_completed()


/datum/battlepass_challenge/facehug
	name = "Facehug Humans"
	code_name = "xenohhug"
	desc = "As a facehugger, facehug AMOUNT humans."
	challenge_category = CHALLENGE_XENO
	completion_xp_array = list(4, 6)
	pick_weight = 7
	var/minimum = 1
	var/maximum = 3
	var/requirement = 0
	var/filled = 0

/datum/battlepass_challenge/facehug/datum/battlepass_challenge/kill_enemies/New(client/owning_client)
	. = ..()

	requirement = rand(minimum, maximum)
	regenerate_desc()

/datum/battlepass_challenge/facehug/regenerate_desc()
	desc = "As a facehugger, facehug [requirement] human\s."

/datum/battlepass_challenge/facehug/hook_client_signals(datum/source, mob/logged_in_mob)
	. = ..()
	if(!.)
		return
	if(!completed)
		RegisterSignal(logged_in_mob, COMSIG_XENO_FACEHUGGED_HUMAN, PROC_REF(on_sigtrigger))

/datum/battlepass_challenge/facehug/unhook_signals(mob/source)
	UnregisterSignal(source, COMSIG_XENO_FACEHUGGED_HUMAN)

/datum/battlepass_challenge/facehug/check_challenge_completed()
	return (filled >= requirement)

/datum/battlepass_challenge/facehug/get_completion_percent()
	return (filled / requirement)

/datum/battlepass_challenge/facehug/get_completion_numerator()
	return filled

/datum/battlepass_challenge/facehug/get_completion_denominator()
	return requirement

/datum/battlepass_challenge/facehug/serialize()
	. = ..()
	.["requirement"] = requirement
	.["filled"] = filled

/datum/battlepass_challenge/facehug/deserialize(list/save_list)
	. = ..()
	requirement = save_list["requirement"]
	filled = save_list["filled"]

/// When the xeno plants a resin node
/datum/battlepass_challenge/facehug/proc/on_sigtrigger(datum/source)
	SIGNAL_HANDLER

	filled++
	on_possible_challenge_completed()






/datum/battlepass_challenge/for_the_hive
	name = "For The Hive!"
	code_name = "xenorsuic"
	desc = "As an Acider Runner, detonate For The Hive at maximum acid AMOUNT times."
	challenge_category = CHALLENGE_XENO
	completion_xp_array = list(5, 7)
	pick_weight = 6
	var/minimum = 1
	var/maximum = 2
	var/requirement = 0
	var/filled = 0

/datum/battlepass_challenge/for_the_hive/datum/battlepass_challenge/kill_enemies/New(client/owning_client)
	. = ..()

	requirement = rand(minimum, maximum)
	regenerate_desc()

/datum/battlepass_challenge/for_the_hive/regenerate_desc()
	desc = "As an Acider Runner, detonate For The Hive at maximum acid [requirement] times."

/datum/battlepass_challenge/for_the_hive/hook_client_signals(datum/source, mob/logged_in_mob)
	. = ..()
	if(!.)
		return
	if(!completed)
		RegisterSignal(logged_in_mob, COMSIG_XENO_FTH_MAX_ACID, PROC_REF(on_sigtrigger))

/datum/battlepass_challenge/for_the_hive/unhook_signals(mob/source)
	UnregisterSignal(source, COMSIG_XENO_FTH_MAX_ACID)

/datum/battlepass_challenge/for_the_hive/check_challenge_completed()
	return (filled >= requirement)

/datum/battlepass_challenge/for_the_hive/get_completion_percent()
	return (filled / requirement)

/datum/battlepass_challenge/for_the_hive/get_completion_numerator()
	return filled

/datum/battlepass_challenge/for_the_hive/get_completion_denominator()
	return requirement

/datum/battlepass_challenge/for_the_hive/serialize()
	. = ..()
	.["requirement"] = requirement
	.["filled"] = filled

/datum/battlepass_challenge/for_the_hive/deserialize(list/save_list)
	. = ..()
	requirement = save_list["requirement"]
	filled = save_list["filled"]

/// When the xeno plants a resin node
/datum/battlepass_challenge/for_the_hive/proc/on_sigtrigger(datum/source)
	SIGNAL_HANDLER

	filled++
	on_possible_challenge_completed()






/datum/battlepass_challenge/glob_hits
	name = "Direct Glob Hits"
	code_name = "xenobdir"
	desc = "Land AMOUNT direct acid glob hits as a Boiler."
	challenge_category = CHALLENGE_XENO
	completion_xp_array = list(5, 7)
	pick_weight = 6
	var/minimum = 1
	var/maximum = 4
	var/requirement = 0
	var/filled = 0

/datum/battlepass_challenge/glob_hits/datum/battlepass_challenge/kill_enemies/New(client/owning_client)
	. = ..()

	requirement = rand(minimum, maximum)
	regenerate_desc()

/datum/battlepass_challenge/glob_hits/regenerate_desc()
	desc = "Land [requirement] direct acid glob hit\s as a Boiler."

/datum/battlepass_challenge/glob_hits/hook_client_signals(datum/source, mob/logged_in_mob)
	. = ..()
	if(!.)
		return
	if(!completed)
		RegisterSignal(logged_in_mob, COMSIG_FIRER_PROJECTILE_DIRECT_HIT, PROC_REF(on_sigtrigger))

/datum/battlepass_challenge/glob_hits/unhook_signals(mob/source)
	UnregisterSignal(source, COMSIG_FIRER_PROJECTILE_DIRECT_HIT)

/datum/battlepass_challenge/glob_hits/check_challenge_completed()
	return (filled >= requirement)

/datum/battlepass_challenge/glob_hits/get_completion_percent()
	return (filled / requirement)

/datum/battlepass_challenge/glob_hits/get_completion_numerator()
	return filled

/datum/battlepass_challenge/glob_hits/get_completion_denominator()
	return requirement

/datum/battlepass_challenge/glob_hits/serialize()
	. = ..()
	.["requirement"] = requirement
	.["filled"] = filled

/datum/battlepass_challenge/glob_hits/deserialize(list/save_list)
	. = ..()
	requirement = save_list["requirement"]
	filled = save_list["filled"]

/// When the xeno plants a resin node
/datum/battlepass_challenge/glob_hits/proc/on_sigtrigger(datum/source, obj/projectile/hit_projectile)
	SIGNAL_HANDLER
	if(!istype(hit_projectile.ammo, /datum/ammo/xeno/boiler_gas))
		return

	filled++
	on_possible_challenge_completed()





/datum/battlepass_challenge/plant_fruit
	name = "Plant Resin Fruit"
	code_name = "xenodplt"
	desc = "Plant AMOUNT resin fruits."
	challenge_category = CHALLENGE_XENO
	completion_xp_array = list(4, 6)
	pick_weight = 8
	var/minimum = 20
	var/maximum = 30
	var/requirement = 0
	var/filled = 0

/datum/battlepass_challenge/plant_fruit/datum/battlepass_challenge/kill_enemies/New(client/owning_client)
	. = ..()

	requirement = rand(minimum, maximum)
	regenerate_desc()

/datum/battlepass_challenge/plant_fruit/regenerate_desc()
	desc = "Plant [requirement] resin fruit\s."

/datum/battlepass_challenge/plant_fruit/hook_client_signals(datum/source, mob/logged_in_mob)
	. = ..()
	if(!.)
		return
	if(!completed)
		RegisterSignal(logged_in_mob, COMSIG_XENO_PLANTED_FRUIT, PROC_REF(on_sigtrigger))

/datum/battlepass_challenge/plant_fruit/unhook_signals(mob/source)
	UnregisterSignal(source, COMSIG_XENO_PLANTED_FRUIT)

/datum/battlepass_challenge/plant_fruit/check_challenge_completed()
	return (filled >= requirement)

/datum/battlepass_challenge/plant_fruit/get_completion_percent()
	return (filled / requirement)

/datum/battlepass_challenge/plant_fruit/get_completion_numerator()
	return filled

/datum/battlepass_challenge/plant_fruit/get_completion_denominator()
	return requirement

/datum/battlepass_challenge/plant_fruit/serialize()
	. = ..()
	.["requirement"] = requirement
	.["filled"] = filled

/datum/battlepass_challenge/plant_fruit/deserialize(list/save_list)
	. = ..()
	requirement = save_list["requirement"]
	filled = save_list["filled"]

/// When the xeno plants a resin node
/datum/battlepass_challenge/plant_fruit/proc/on_sigtrigger(datum/source, mob/planter)
	SIGNAL_HANDLER
	if(should_block_game_interaction(planter))
		return

	filled++
	on_possible_challenge_completed()




/datum/battlepass_challenge/plant_resin_nodes
	name = "Plant Resin Nodes"
	code_name = "xenocplrs"
	desc = "Plant AMOUNT resin nodes."
	challenge_category = CHALLENGE_XENO
	completion_xp_array = list(4, 6)
	pick_weight = 8
	/// The minimum possible amount of nodes that need to be planted
	var/minimum_nodes = 20
	/// The maximum
	var/maximum_nodes = 30
	/// How many nodes need to be planted
	var/node_requirement = 0
	/// How many nodes have been planted so far
	var/planted_nodes = 0

/datum/battlepass_challenge/plant_resin_nodes/datum/battlepass_challenge/kill_enemies/New(client/owning_client)
	. = ..()

	node_requirement = rand(minimum_nodes, maximum_nodes)
	regenerate_desc()

/datum/battlepass_challenge/plant_resin_nodes/regenerate_desc()
	desc = "Plant [node_requirement] resin node\s."

/datum/battlepass_challenge/plant_resin_nodes/hook_client_signals(datum/source, mob/logged_in_mob)
	. = ..()
	if(!.)
		return
	if(!completed)
		RegisterSignal(logged_in_mob, COMSIG_XENO_PLANT_RESIN_NODE, PROC_REF(on_plant_node))

/datum/battlepass_challenge/plant_resin_nodes/unhook_signals(mob/source)
	UnregisterSignal(source, COMSIG_XENO_PLANT_RESIN_NODE)

/datum/battlepass_challenge/plant_resin_nodes/check_challenge_completed()
	return (planted_nodes >= node_requirement)

/datum/battlepass_challenge/plant_resin_nodes/get_completion_percent()
	return (planted_nodes / node_requirement)

/datum/battlepass_challenge/plant_resin_nodes/get_completion_numerator()
	return planted_nodes

/datum/battlepass_challenge/plant_resin_nodes/get_completion_denominator()
	return node_requirement

/datum/battlepass_challenge/plant_resin_nodes/serialize()
	. = ..()
	.["node_requirement"] = node_requirement
	.["planted_nodes"] = planted_nodes

/datum/battlepass_challenge/plant_resin_nodes/deserialize(list/save_list)
	. = ..()
	node_requirement = save_list["node_requirement"]
	planted_nodes = save_list["planted_nodes"]

/// When the xeno plants a resin node
/datum/battlepass_challenge/plant_resin_nodes/proc/on_plant_node(datum/source, mob/planter)
	SIGNAL_HANDLER
	if(should_block_game_interaction(planter))
		return

	planted_nodes++
	on_possible_challenge_completed()



*/














//

//Additional
/datum/battlepass_challenge_module/requirement/additional

/datum/battlepass_challenge_module/requirement/additional/damage

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
		/obj/item/weapon/gun/flamer,
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

/datum/battlepass_challenge_module/requirement/bad_buffs/overdose/easy
	module_exp_modificator = 1.5

/datum/battlepass_challenge_module/requirement/bad_buffs/overdose/normal
	module_exp_modificator = 1.5

/datum/battlepass_challenge_module/requirement/bad_buffs/overdose/hard
	module_exp_modificator = 1.5
//
