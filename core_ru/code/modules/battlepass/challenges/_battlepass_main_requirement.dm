// REQUIREMENTS
/datum/battlepass_challenge_module/main_requirement // Базовое требование для выполнения задачи
	pick_weight = 5

	var/list/mapped_sub_requirements
	var/list/datum/battlepass_challenge_module/sub_requirements

/datum/battlepass_challenge_module/main_requirement/New(list/opt)
	. = ..()
	if(mapped_sub_requirements)
		for(var/list/list_module in mapped_sub_requirements)
			var/target_type = GLOB.challenge_modules_types[list_module["cn"]]
			var/datum/battlepass_challenge_module/module = new target_type(list_module["opt"])
			module.challenge_ref = src
			sub_requirements += module

/datum/battlepass_challenge_module/main_requirement/generate_module()
	var/total_sub_modules = rand(1, 3)
	var/list/actual_sub_requirements = GLOB.challenge_sub_modules_weighted.Copy()
	for(var/i = 1, i <= total_sub_modules, i++)
		var/selected_type = pick_weight(actual_sub_requirements)
		actual_sub_requirements -= selected_type
		var/datum/battlepass_challenge_module/sub_requirement = new selected_type()
		sub_requirement.generate_module()
		sub_requirements += sub_requirement

		var/list/potential_modules_to_pick = list()
		for(var/subtype in sub_requirement.compatibility["subtyped"])
			potential_modules_to_pick += subtypesof(subtype)
		for(var/type in sub_requirement.compatibility["strict"])
			potential_modules_to_pick += type
		var/datum/battlepass_challenge_module/condition/selected_condition = pick_weight(GLOB.challenge_condition_modules_weighted & potential_modules_to_pick)
		sub_requirements += selected_condition

	return TRUE

/*
	var/total_xp_modificator = 1
	var/total_main_modules = rand(1, 3)
	var/list/available_modules = GLOB.challenge_modules_weighted.Copy()

	var/picked_type = pick_weight(available_modules)
	var/datum/battlepass_challenge_module/initial_module = new picked_type
	initial_module.challenge_ref = src
	initial_module.generate_module()
	modules += initial_module

	xp_completion += rand(initial_module.module_exp[1], initial_module.module_exp[2])
	total_xp_modificator *= initial_module.module_exp_modificator

	var/datum/battlepass_challenge_module/previous_module = initial_module
	for(var/i = 1, i <= total_main_modules, i++)
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
*/

/datum/battlepass_challenge_module/main_requirement/hook_signals(mob/logged_mob)
	. = ..()
	if(!.)
		return
	for(var/req_name in req)
		if(req[req_name][1] != req[req_name][2])
			return TRUE

//TODO: Do it count every subbmodule
/datum/battlepass_challenge_module/main_requirement/allow_completion()
	var/current_pos = challenge_ref.modules[src]
	var/datum/battlepass_challenge_module/next_module = challenge_ref.modules[current_pos + 1]
	if(!next_module.allow_completion())
		return FALSE

/datum/battlepass_challenge_module/main_requirement/serialize(list/options)
	. = ..()
	var/list/re_mapped_modules = list()
	for(var/datum/battlepass_challenge_module/module in sub_requirements)
		re_mapped_modules += module.serialize()
	options["mapped_sub_requirements"] = re_mapped_modules

/datum/battlepass_challenge_module/main_requirement/proc/can_apply(mob_type)
	return TRUE

/datum/battlepass_challenge_module/main_requirement/proc/count_for_completion(amount, req_name)
	if(req[req_name][1] == req[req_name][2])
		return

	if(!allow_completion())
		return FALSE

	req[req_name][1] = min(req[req_name][1] + amount, req[req_name][2])
	on_possible_challenge_completed()



//Kill
/datum/battlepass_challenge_module/main_requirement/kill
	name = "Kill"
	desc = "Kill ###kills### enemies"
	code_name = "kill"

	module_exp = list(4, 8)

	req_gen = list("kills" = list(2, 6))

	var/list/valid_kill_paths = list("strict" = list(), "subtyped" = list())

/datum/battlepass_challenge_module/main_requirement/kill/hook_signals(mob/logged_mob)
	. = ..()
	if(!.)
		return
	RegisterSignal(logged_mob, COMSIG_MOB_KILL_TOTAL_INCREASED, PROC_REF(on_kill))


/datum/battlepass_challenge_module/main_requirement/kill/unhook_signals(mob/logged_mob)
	. = ..()
	if(!.)
		return
	UnregisterSignal(logged_mob, COMSIG_MOB_KILL_TOTAL_INCREASED)

/datum/battlepass_challenge_module/main_requirement/kill/proc/on_kill(mob/source, mob/killed_mob, datum/cause_data/cause_data)
	SIGNAL_HANDLER

	if(!killed_mob.life_value)
		return FALSE

	if(source.faction == killed_mob.faction)
		return FALSE

	if((killed_mob.type in valid_kill_paths["strict"]) || (length(valid_kill_paths["subtyped"]) && is_type_in_list(killed_mob, valid_kill_paths["subtyped"])))
		count_for_completion(1, req[1])

/datum/battlepass_challenge_module/main_requirement/kill/human
	name = "Kill Humans"
	desc = "Kill ###human_kills### humans"
	code_name = "kill_human"

	module_exp = list(6, 10)

	req_gen = list("human_kills" = list(2, 6))

	valid_kill_paths = list("strict" = list(), "subtyped" = list(/mob/living/carbon/human))

/datum/battlepass_challenge_module/main_requirement/kill/xenomorph
	name = "Kill Xenomorphs"
	desc = "Kill ###xenomorph_kills### xenomorphs"
	code_name = "kill_xenomorph"

	module_exp = list(6, 10)

	req_gen = list("xenomorph_kills" = list(2, 6))

	valid_kill_paths = list("strict" = list(), "subtyped" = list(/mob/living/carbon/xenomorph))

/datum/battlepass_challenge_module/main_requirement/kill/xenomorph/caste
	name = "Kill Xenomorphs - Caste"
	desc = "Kill ###xenomorph_kills### ###castes###"
	code_name = "kill_xenomorph_caste"

	valid_kill_paths = list("strict" = list(), "subtyped" = list(/mob/living/carbon/xenomorph))

	var/mob/xeno_caste

//TODO: Get here selection and module_exp * on xeno tier value

/datum/battlepass_challenge_module/main_requirement/kill/xenomorph/caste/get_description()
	. = ..()
	. = replacetext_char(., "###castes###", initial(xeno_caste.name))

/datum/battlepass_challenge_module/main_requirement/kill/xenomorph/caste/serialize(list/options)
	. = ..()
	options["xeno_caste"] = xeno_caste
//

//Defib
/datum/battlepass_challenge_module/main_requirement/defib
	name = "Defibrillate Players"
	desc = "Successfully defibrillate ###defib### unique marine players"
	code_name = "defib"

	module_exp = list(6, 12)

	req_gen = list("defib" = list(10, 20))

	var/list/mob_name_list = list()

/datum/battlepass_challenge_module/main_requirement/defib/hook_signals(mob/logged_mob)
	. = ..()
	if(!.)
		return
	RegisterSignal(logged_mob, COMSIG_HUMAN_USED_DEFIB, PROC_REF(on_defib))

/datum/battlepass_challenge_module/main_requirement/defib/unhook_signals(mob/logged_mob)
	. = ..()
	if(!.)
		return
	UnregisterSignal(logged_mob, COMSIG_HUMAN_USED_DEFIB)

/datum/battlepass_challenge_module/main_requirement/defib/proc/on_defib(datum/source, mob/living/carbon/human/defibbed)
	SIGNAL_HANDLER
	count_for_completion(1, req[1])
//

//Damage
/datum/battlepass_challenge_module/main_requirement/damage
	name = "Damage"
	desc = "Survive ###damage### damage"
	code_name = "additional_survive_damage"

	module_exp = list(4, 10)

	req_gen = list("damage" = list(1000, 6000))

//REDO: DO IT COUNT IT EVERY TIMME YOU TAKE DAMAGE
/datum/battlepass_challenge_module/main_requirement/damage/hook_signals(mob/logged_mob)
	. = ..()
	if(!.)
		return
	RegisterSignal(SSdcs, COMSIG_GLOB_CONFIG_LOADED, PROC_REF(on_game_end), logged_mob)

/datum/battlepass_challenge_module/main_requirement/damage/unhook_signals(mob/logged_mob)
	. = ..()
	if(!.)
		return
	UnregisterSignal(SSdcs, COMSIG_GLOB_CONFIG_LOADED)

/datum/battlepass_challenge_module/main_requirement/damage/proc/on_game_end(mob/logged_mob)
	count_for_completion(logged_mob.life_damage_taken_total, req[1])
//

//Berserk Rage
/datum/battlepass_challenge_module/main_requirement/berserker_rage
	name = "Max Berserker Rage"
	desc = "As a Berserker Ravager, enter maximum berserker rage ###rages### times."
	code_name = "berserker_rage"

	module_exp = list(4, 6)

	req_gen = list("rages" = list(2, 4))

/datum/battlepass_challenge_module/main_requirement/berserker_rage/hook_signals(mob/logged_mob)
	. = ..()
	if(!.)
		return
	RegisterSignal(logged_mob, COMSIG_XENO_RAGE_MAX, PROC_REF(on_rage_max))

/datum/battlepass_challenge_module/main_requirement/berserker_rage/unhook_signals(mob/logged_mob)
	. = ..()
	if(!.)
		return
	UnregisterSignal(logged_mob, COMSIG_XENO_RAGE_MAX)

/datum/battlepass_challenge_module/main_requirement/berserker_rage/proc/on_rage_max(datum/source)
	SIGNAL_HANDLER
	count_for_completion(1, req[1])
//

//Facehugs
/datum/battlepass_challenge_module/main_requirement/facehug
	name = "Facehug Humans"
	desc = "As a facehugger, facehug ###huggs### humans."
	code_name = "facehug"

	module_exp = list(4, 6)

	req_gen = list("facehugs" = list(2, 4))

/datum/battlepass_challenge_module/main_requirement/facehug/hook_signals(mob/logged_mob)
	. = ..()
	if(!.)
		return
	RegisterSignal(logged_mob, COMSIG_XENO_FACEHUGGED_HUMAN, PROC_REF(on_facehug))

/datum/battlepass_challenge_module/main_requirement/facehug/unhook_signals(mob/logged_mob)
	. = ..()
	if(!.)
		return
	UnregisterSignal(logged_mob, COMSIG_XENO_FACEHUGGED_HUMAN)

/datum/battlepass_challenge_module/main_requirement/facehug/proc/on_facehug(datum/source)
	SIGNAL_HANDLER
	count_for_completion(1, req[1])
//

//For The Hive
/datum/battlepass_challenge_module/main_requirement/for_the_hive
	name = "For The Hive!"
	desc = "As an Acider Runner, detonate For The Hive at maximum acid ###forhivesuicides### times."
	code_name = "for_the_hive"

	module_exp = list(5, 7)

	req_gen = list("forhivesuicides" = list(2, 4))

/datum/battlepass_challenge_module/main_requirement/for_the_hive/hook_signals(mob/logged_mob)
	. = ..()
	if(!.)
		return
	RegisterSignal(logged_mob, COMSIG_XENO_FTH_MAX_ACID, PROC_REF(on_for_the_hive))

/datum/battlepass_challenge_module/main_requirement/for_the_hive/unhook_signals(mob/logged_mob)
	. = ..()
	if(!.)
		return
	UnregisterSignal(logged_mob, COMSIG_XENO_FTH_MAX_ACID)

/datum/battlepass_challenge_module/main_requirement/for_the_hive/proc/on_for_the_hive(datum/source)
	SIGNAL_HANDLER
	count_for_completion(1, req[1])
//

// Glob Hits
/datum/battlepass_challenge_module/main_requirement/glob_hits
	name = "Direct Glob Hits"
	desc = "Land ###boilerhits### direct acid glob hits as a Boiler."
	code_name = "glob_hits"

	module_exp = list(5, 7)

	req_gen = list("boilerhits" = list(6, 12))

/datum/battlepass_challenge_module/main_requirement/glob_hits/hook_signals(mob/logged_mob)
	. = ..()
	if(!.)
		return
	RegisterSignal(logged_mob, COMSIG_FIRER_PROJECTILE_DIRECT_HIT, PROC_REF(on_glob_hit))

/datum/battlepass_challenge_module/main_requirement/glob_hits/unhook_signals(mob/logged_mob)
	. = ..()
	if(!.)
		return
	UnregisterSignal(logged_mob, COMSIG_FIRER_PROJECTILE_DIRECT_HIT)

/datum/battlepass_challenge_module/main_requirement/glob_hits/proc/on_glob_hit(datum/source, obj/projectile/hit_projectile)
	SIGNAL_HANDLER
	if(!istype(hit_projectile.ammo, /datum/ammo/xeno/boiler_gas))
		return FALSE
	count_for_completion(1, req[1])
//

// Plant Fruits
/datum/battlepass_challenge_module/main_requirement/plant_fruits
	name = "Plant Resin Fruit"
	desc = "Plant ###plantedfruits### resin fruits."
	code_name = "plant_fruits"

	module_exp = list(4, 6)

	req_gen = list("plantedfruits" = list(20, 40))

/datum/battlepass_challenge_module/main_requirement/plant_fruits/hook_signals(mob/logged_mob)
	. = ..()
	if(!.)
		return
	RegisterSignal(logged_mob, COMSIG_XENO_PLANTED_FRUIT, PROC_REF(on_plant_fruit))

/datum/battlepass_challenge_module/main_requirement/plant_fruits/unhook_signals(mob/logged_mob)
	. = ..()
	if(!.)
		return
	UnregisterSignal(logged_mob, COMSIG_XENO_PLANTED_FRUIT)

/datum/battlepass_challenge_module/main_requirement/plant_fruits/proc/on_plant_fruit(datum/source, mob/planter)
	SIGNAL_HANDLER
	count_for_completion(1, req[1])
//

// Plant Resin Nodes
/datum/battlepass_challenge_module/main_requirement/plant_resin_nodes
	name = "Plant Resin Nodes"
	desc = "Plant ###node_requirement### resin nodes."
	code_name = "plant_resin_nodes"

	module_exp = list(4, 6)

	req_gen = list("node_requirement" = list(20, 40))
	var/planted_nodes = 0

/datum/battlepass_challenge_module/main_requirement/plant_resin_nodes/hook_signals(mob/logged_mob)
	. = ..()
	if(!.)
		return
	RegisterSignal(logged_mob, COMSIG_XENO_PLANT_RESIN_NODE, PROC_REF(on_plant_node))

/datum/battlepass_challenge_module/main_requirement/plant_resin_nodes/unhook_signals(mob/logged_mob)
	. = ..()
	if(!.)
		return
	UnregisterSignal(logged_mob, COMSIG_XENO_PLANT_RESIN_NODE)

/datum/battlepass_challenge_module/main_requirement/plant_resin_nodes/proc/on_plant_node(datum/source, mob/planter)
	SIGNAL_HANDLER
	count_for_completion(1, req[1])
//
