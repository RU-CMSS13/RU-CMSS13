// REQUIREMENTS
/datum/battlepass_challenge_module/main_requirement // Базовое требование для выполнения задачи
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

/datum/battlepass_challenge_module/main_requirement/serialize(list/options)
	. = ..()
	var/list/re_mapped_modules = list()
	for(var/datum/battlepass_challenge_module/module in sub_requirements)
		re_mapped_modules += module.serialize()
	options["mapped_sub_requirements"] = re_mapped_modules

/datum/battlepass_challenge_module/main_requirement/proc/can_apply(mob_type)
	return TRUE



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
	var/req_name = req[1]
	if(req[req_name][1] == req[req_name][2])
		return
	RegisterSignal(logged_mob, COMSIG_MOB_KILL_TOTAL_INCREASED, PROC_REF(on_kill))


/datum/battlepass_challenge_module/main_requirement/kill/unhook_signals(mob/logged_mob)
	. = ..()
	if(!.)
		return
	UnregisterSignal(logged_mob, COMSIG_MOB_KILL_TOTAL_INCREASED)

/datum/battlepass_challenge_module/main_requirement/kill/proc/on_kill(mob/source, mob/killed_mob, datum/cause_data/cause_data)
	SIGNAL_HANDLER

	var/req_name = req[1]
	if(!killed_mob.life_value || req[req_name][1] == req[req_name][2])
		return FALSE

	if(source.faction == killed_mob.faction)
		return FALSE

	if((killed_mob.type in valid_kill_paths["strict"]) || (length(valid_kill_paths["subtyped"]) && is_type_in_list(killed_mob, valid_kill_paths["subtyped"])))
		var/current_pos = challenge_ref.modules[src]
		var/datum/battlepass_challenge_module/next_module = challenge_ref.modules[current_pos + 1]
		if(!next_module.allow_completion())
			return FALSE

		req[req_name][1]++
		on_possible_challenge_completed()

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
	var/req_name = req[1]
	if(req[req_name][1] == req[req_name][2])
		return
	RegisterSignal(logged_mob, COMSIG_HUMAN_USED_DEFIB, PROC_REF(on_defib))

/datum/battlepass_challenge_module/main_requirement/defib/unhook_signals(mob/logged_mob)
	. = ..()
	if(!.)
		return
	UnregisterSignal(logged_mob, COMSIG_HUMAN_USED_DEFIB)

/// When the xeno plants a resin node
/datum/battlepass_challenge_module/main_requirement/defib/proc/on_defib(datum/source, mob/living/carbon/human/defibbed)
	SIGNAL_HANDLER

	var/req_name = req[1]
	if(req[req_name][1] == req[req_name][2])
		return

	var/current_pos = challenge_ref.modules[src]
	var/datum/battlepass_challenge_module/next_module = challenge_ref.modules[current_pos + 1]
	if(!next_module.allow_completion())
		return FALSE

	mob_name_list |= defibbed.real_name
	req[req_name][1]++
	on_possible_challenge_completed()

/datum/battlepass_challenge_module/main_requirement/defib/serialize(list/options)
	. = ..()
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
