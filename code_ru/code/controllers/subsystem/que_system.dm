GLOBAL_DATUM_INIT(xeno_queue, /datum/queue_handler_datum/xeno, new("XQ", 10 MINUTES))

SUBSYSTEM_DEF(queue_system)
	name = "Queue"
	wait = 5 SECONDS
	priority = 0.5
	flags = SS_BACKGROUND | SS_POST_FIRE_TIMING | SS_NO_INIT
	runlevels = RUNLEVEL_GAME

	var/list/datum/queue_handler_datum/handled_queues = list()

/datum/controller/subsystem/queue_system/stat_entry(msg)
	msg = null
	for(var/datum/queue_handler_datum/queue as anything in handled_queues)
		if(!queue.identificator)
			continue
		if(msg)
			msg += "|"
		msg += "[queue.identificator]:([length(queue.queued_players)] | [time2text(world.time - queue.last_time_exited, "hh:mm:ss", 0)])"
	return ..()

/datum/controller/subsystem/queue_system/fire()
	for(var/datum/queue_handler_datum/queue as anything in handled_queues)
		queue.process()

/datum/controller/subsystem/queue_system/Recover()
	handled_queues |= SSqueue_system.handled_queues



//////////////////////////////////////////////////////////////



/datum/queue_handler_datum
	///If you want it to show up in the queue system stats
	var/identificator
	///Time before position get removed after client left
	var/hold_time_after_leave = 0
	///When que last time moved (world time)
	var/last_time_exited = 0
	var/list/datum/queued_player/queued_players = list()

/datum/queue_handler_datum/New(identificator, hold_time_after_leave)
	src.identificator = identificator
	src.hold_time_after_leave = hold_time_after_leave
	SSqueue_system.handled_queues += src
	last_time_exited = world.time

/datum/queue_handler_datum/Destroy()
	SSqueue_system.handled_queues -= src

	. = ..()

/datum/queue_handler_datum/process()
	var/hold_time = world.time - hold_time_after_leave
	for(var/datum/queued_player/info as anything in queued_players)
		info.process(hold_time)

/datum/queue_handler_datum/proc/progress(offset = 0)
	if(1 + offset > length(queued_players))
		return
	return queued_players[1 + offset]

/datum/queue_handler_datum/proc/on_que_change()
	var/postion_offset = 0
	for(var/position in 1 to length(queued_players))
		var/datum/queued_player/info = queued_players[position]
		info.real_position = position
		info.position = info.real_position - postion_offset
		info.process()
		if(info.eligible_queue())
			continue
		postion_offset++

/datum/queue_handler_datum/proc/set_custom_pos(datum/queued_player/wanted_info, wanted_position)
	if(wanted_position > length(queued_players))
		return

	queued_players -= wanted_info
	queued_players.Insert(wanted_position, wanted_info)
	on_que_change()

//////////////////////////////////////////////////////////////

/datum/queue_handler_datum/xeno/process()
	. = ..()

	GLOB.larva_pool_candidate_count = length(queued_players)



//////////////////////////////////////////////////////////////



/datum/queued_player
	///Position in list of que
	var/real_position = 0
	///Offseted position in que without queued players who left
	var/position = 0
	///When added to queue
	var/time_join = 0
	///World time when client left server
	var/left_server_time = 0

	var/player_ckey = null
	var/datum/queue_handler_datum/owner = null

/datum/queued_player/New(player_ckey, datum/queue_handler_datum/owner)
	src.player_ckey = player_ckey
	if(owner)
		add_to_queue(owner)

/datum/queued_player/Destroy()
	remove_from_queue()

	. = ..()

/datum/queued_player/process(hold_time)
	if(left_server_time && hold_time && (left_server_time > hold_time))
		remove_from_queue()
		return

	var/client/client = GLOB.directory[player_ckey]
	if(client)
		left_server_time = 0
	else
		if(!left_server_time)
			left_server_time = world.time

/datum/queued_player/proc/add_to_queue(datum/queue_handler_datum/owner)
	time_join = world.time
	src.owner = owner
	owner.queued_players += src
	owner.on_que_change()

/datum/queued_player/proc/remove_from_queue()
	real_position = 0
	position = 0
	time_join = 0
	if(owner)
		owner.queued_players -= src
		owner.on_que_change()
		owner = null

/datum/queued_player/proc/can_be_added(soft)
	return TRUE

/datum/queued_player/proc/can_be_removed(soft)
	return TRUE

/datum/queued_player/proc/eligible_queue()
	if(left_server_time)
		return FALSE
	return TRUE

//////////////////////////////////////////////////////////////

/datum/queued_player/xeno
	var/admin_larva_protection = FALSE
	var/cached_admin_larva_protection = FALSE

	var/mob/living/carbon/human/linked_human = null

	var/larva_pool_message = null
	var/mob/mob_to_clear = null

/datum/queued_player/xeno/Destroy()
	var/datum/player_details/details = GLOB.player_details[player_ckey]
	if(details)
		details.xeno_que_position = null

	. = ..()

/datum/queued_player/xeno/process()
	. = ..()

	var/position_text = "[position]\th"
	if(position != real_position)
		position_text += " or \[[real_position]\th with countinng ineligible players\]"

	if(eligible_queue())
		larva_pool_message = "You are currently [position_text] in the larva pool."
		return

	larva_pool_message = "You are currently ineligible to be a larva but would be [position_text] in the pool. \
		Your current position will shift as others change their preferences or go inactive, but your relative position compared to everyone in the que is the same. \
		Note: You can play as a facehugger/lesser or in the thunderdome, this wont remove you from que. \
		If disconnect for more than 10 minutes you'll lose your position."

/datum/queued_player/xeno/add_to_queue(datum/queue_handler_datum/owner)
	var/client/client = GLOB.directory[player_ckey]
	if(client?.mob.mind?.original && ishuman(client.mob.mind.original))
		linked_human = client.mob.mind.original
		RegisterSignal(linked_human, list(COMSIG_LIVING_REJUVENATED, COMSIG_HUMAN_REVIVED, COMSIG_PARENT_PREQDELETED), PROC_REF(on_human_revive))

	. = ..()

/datum/queued_player/xeno/remove_from_queue()
	larva_pool_message = null

	. = ..()

	if(linked_human)
		on_human_revive(linked_human)

/datum/queued_player/xeno/can_be_added(soft)
	var/client/client = GLOB.directory[player_ckey]
	if(!client)
		return

	if(!(client.prefs.be_special & BE_ALIEN))
		return

	var/mob/client_mob = client.mob
	if(jobban_isbanned(client_mob, JOB_XENOMORPH))
		return

	if(admin_larva_protection)
		return

	. = ..()

	if(!soft)
		return

	if(mob_eligible(client.mob))
		return
	return FALSE

/datum/queued_player/xeno/can_be_removed(soft)
	var/client/client = GLOB.directory[player_ckey]
	if(!client)
		return

	. = ..()

	if(!soft)
		return

	if(mob_eligible(client.mob))
		return FALSE

/datum/queued_player/xeno/eligible_queue(datum/hive_status/hive)
	. = ..()
	if(!.)
		return

	. = FALSE

	var/client/client = GLOB.directory[player_ckey]
	if(!client)
		return

	// AFK players cannot be drafted
	if(client.inactivity > XENO_JOIN_AFK_TIME_LIMIT)
		return

	if(tod_check())
		return

	if(hive)
		for(var/mob_name, ckey in hive.banished_ckeys)
			if(ckey != player_ckey)
				continue
			return

	if(isobserver(client.mob))
		var/mob/dead/observer/client_mob = client.mob
		var/deathtime = world.time - client_mob.timeofdeath
		if(deathtime < XENO_JOIN_DEAD_TIME && !client_mob.bypass_time_of_death_checks && !check_client_rights(client, R_ADMIN, FALSE))
			return
	else if(!mob_eligible(client.mob))
		return
	return TRUE

/datum/queued_player/xeno/proc/tod_check()
	if(!linked_human)
		return

	if(!linked_human.check_tod() || !linked_human.is_revivable())
		return

	return TRUE

/datum/queued_player/xeno/proc/mob_eligible(mob/client_mob)
	. = TRUE

	if(client_mob.is_dead())
		return

	if(isfacehugger(client_mob) || islesserdrone(client_mob))
		return

	if(should_block_game_interaction(client_mob, include_hunting_grounds = TRUE))
		return
	return FALSE

/datum/queued_player/xeno/proc/offer_spawn(datum/hive_status/hive, force_ask, custom_alert_desc, custom_alert_name)
	if(!eligible_queue(hive))
		return

	var/client/client = GLOB.directory[player_ckey]
	var/is_observer = isobserver(client.mob)
	if(!force_ask && is_observer)
		return client

	if(tgui_alert(
		client.mob, custom_alert_desc ? custom_alert_desc : "You reached your turn in xeno que, do you want to join in?",
		custom_alert_name ? custom_alert_name : "Xeno Join",
		list("Yes", "No"),
		10 SECONDS) != "Yes")
		return
	if(!is_observer)
		mob_to_clear = client.mob
	return client

/datum/queued_player/xeno/proc/confirm_spawn()
	remove_from_queue()
	if(!QDELETED(mob_to_clear))
		mob_to_clear.ghostize(FALSE, FALSE, TRUE, TRUE)
	mob_to_clear = null

/datum/queued_player/xeno/proc/on_human_revive(mob/living/carbon/human/source)
	SIGNAL_HANDLER
	if(owner)
		var/client/client = GLOB.directory[player_ckey]
		if(client.mob == source)
			remove_from_queue()
	linked_human = null
	UnregisterSignal(source, list(COMSIG_LIVING_REJUVENATED, COMSIG_HUMAN_REVIVED, COMSIG_PARENT_PREQDELETED))



//////////////////////////////////////////////////////////////



/datum/player_details
	///BACK WAY ASSOCIATION DON'T WORK! WE ARE DOOMED!
	var/player_ckey = null
	var/datum/queued_player/xeno/xeno_que_position = null

/datum/player_details/Destroy(force, ...)
	. = ..()

	QDEL_NULL(xeno_que_position)

/datum/player_details/proc/add_to_xeno_queue(soft)
	if(xeno_que_position.owner)
		return

	if(!xeno_que_position.can_be_added(soft))
		return

	xeno_que_position.add_to_queue(GLOB.xeno_queue)

/datum/player_details/proc/remove_from_xeno_queue(soft)
	if(!xeno_que_position.owner)
		return

	if(!xeno_que_position.can_be_removed(soft))
		return

	xeno_que_position.remove_from_queue()



//////////////////////////////////////////////////////////////



/mob/living/carbon/xenomorph/lesser_drone/get_status_tab_items()
	. = ..()

	if(client?.player_details.xeno_que_position.larva_pool_message)
		. += client.player_details.xeno_que_position.larva_pool_message
		. += ""

/obj/item/alien_embryo/proc/offer_larva(datum/queued_player/xeno/queued, is_nested)
	var/client/client = queued.offer_spawn(GLOB.hive_datum[hivenumber], !is_nested, "An [is_nested ? "nested" : "unnested"] host is about to burst! Do you want to control the new larva?", "Larva maturation")
	if(client)
		queued.confirm_spawn()
		return client
