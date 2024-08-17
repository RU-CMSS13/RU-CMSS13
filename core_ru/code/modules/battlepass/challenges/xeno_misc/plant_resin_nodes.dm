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


