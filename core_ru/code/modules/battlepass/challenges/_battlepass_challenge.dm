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

	var/client/client_reference

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




/datum/battlepass_challenge/proc/generate_challenge()
    var/total_xp_modificator = 1
    var/total_main_modules = rand(1, 3)
    var/list/available_modules = typesof(/datum/battlepass_challenge_module/main_requirement)

    var/datum/battlepass_challenge_module/initial_module = new pick(available_modules)
    initial_module.challenge_ref = src
    initial_module.generate_module()
    modules += initial_module

    xp_completion += rand(initial_module.module_exp[1], initial_module.module_exp[2])
    total_xp_modificator *= initial_module.module_exp_modificator

    var/datum/battlepass_challenge_module/previous_module = initial_module
    for (var/i in 2 to total_main_modules)
        var/datum/battlepass_challenge_module/next_module = pick_next_compatible_module(available_modules, previous_module)
        next_module.challenge_ref = src
        next_module.generate_module()
        modules += next_module

        xp_completion += rand(next_module.module_exp[1], next_module.module_exp[2])
        total_xp_modificator *= next_module.module_exp_modificator

        previous_module = next_module

    xp_completion *= total_xp_modificator

/datum/battlepass_challenge/proc/pick_next_compatible_module(list/available_modules, datum/battlepass_challenge_module/previous_module)
    var/list/compatible_modules = filter_modules_by_compatibility(available_modules, previous_module)
    if(!compatible_modules.len)
        return null
    var/datum/battlepass_challenge_module/selected_module = pick(compatible_modules)
    available_modules -= selected_module
    return selected_module

/datum/battlepass_challenge/proc/filter_modules_by_compatibility(list/available_modules, datum/battlepass_challenge_module/previous_module)
    var/list/filtered_modules = list()
    for (var/module in available_modules)
        if (check_compatibility(previous_module, module))
            filtered_modules += module
    return filtered_modules

/datum/battlepass_challenge/proc/check_compatibility(datum/battlepass_challenge_module/previous_module, datum/battlepass_challenge_module/next_module)
    if (next_module.type in previous_module.compatibility["strict"] || istype(next_module.type, previous_module.compatibility["subtyped"]))
        return TRUE
    return FALSE




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
		client_reference = logged
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

/datum/battlepass_challenge_module/proc/generate_module()
	return TRUE

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
