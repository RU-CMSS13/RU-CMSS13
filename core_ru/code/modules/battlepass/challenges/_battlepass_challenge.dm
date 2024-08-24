//[ {"desc":"", "xp_completion":0, "mapped_modules":{"ex": {"opt":{"req":{}, ...}}, ...}, "progress":{}}, ...]
// cn is code name, opt is vars to replace
/datum/battlepass_challenge
	var/desc = "Example"
	var/xp_completion = 0
	// Modules builder
	var/list/mapped_modules

	var/list/progress

	// Untracked
	var/completed = FALSE
	var/list/datum/battlepass_challenge_module/modules = list()

/datum/battlepass_challenge/New(list/opt)
	if(opt)
		for(var/param in opt)
			vars[param] = opt[param]

		for(var/module in mapped_modules)
			modules[module] = new GLOB.challenge_modules_types[module](mapped_modules[module]["opt"])

		completed = check_challenge_completed()
		regenerate_desc()

/datum/battlepass_challenge/proc/regenerate_desc()
	var/new_desc = ""
	for(var/datum/battlepass_challenge_module/module in modules)
		new_desc += module.get_description()
	desc = new_desc

/datum/battlepass_challenge/proc/get_completion_percent()
	if(!length(progress))
		return 0
	var/name = progress[1]
	return (progress[name][1] / progress[name][2])

/datum/battlepass_challenge/proc/get_completion_numerator()
	if(!length(progress))
		return 0
	var/name = progress[1]
	return progress[name][1]

/datum/battlepass_challenge/proc/get_completion_denominator()
	if(!length(progress))
		return 1
	var/name = progress[1]
	return progress[name][2]

/datum/battlepass_challenge/proc/check_challenge_completed()
	var/total = length(progress)
	var/current = 0
	for(var/name in progress)
		if(progress[name][1] != progress[name][2])
			continue
		current++
	if(current == total)
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
		"mapped_modules" = re_mapped_modules,
		"progress" = progress
	)

/datum/battlepass_challenge/proc/check_other_components(datum/battlepass_challenge_module/source)
	for(var/datum/battlepass_challenge_module/module in modules - source)
		if(module.on_possible_challenge_completed())
			continue
		return FALSE
	return TRUE


// Handle moduled req actions to finish challenge
/datum/battlepass_challenge_module
	var/name = "Example"
	var/desc = "Example"
	var/code_name = "ex"
	var/challenge_category = CHALLENGE_NONE

	var/pick_weight = 1
	var/module_exp = list(0, 0)
	var/module_exp_modificator = 1

	var/signals
	var/list/req_gen

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
	if(source.statistic_exempt)
		return FALSE
	return TRUE

/datum/battlepass_challenge_module/proc/serialize()
	. = list(code_name = list("opt" = list("req" = req)))

/datum/battlepass_challenge_module/proc/on_possible_challenge_completed()
	return TRUE



// Задача сделать модульные челенджи по типу "Убить 2 ксеноса" + ", с m41a" + " при передозе Oxycodone"



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
