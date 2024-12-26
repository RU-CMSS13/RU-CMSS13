SUBSYSTEM_DEF(factions)
	name = "Factions"
	flags = SS_NO_INIT
	runlevels = RUNLEVEL_GAME
	wait = 10 SECONDS

	var/list/datum/faction/active_factions = list()
	var/list/obj/structure/prop/sector_center/sectors = list()
	var/list/datum/faction_task/active_tasks = list()
	var/list/datum/faction_task/total_tasks = list()
	var/processing_tasks = 0

	var/list/datum/faction/current_active_run = list()
	var/list/datum/faction_task/current_active_run_tasks = list()

/datum/controller/subsystem/factions/stat_entry(msg)
	msg = "F:[length(GLOB.faction_datums)]|AF:[length(active_factions)]|S:[length(sectors)]|T:[length(total_tasks)]|P:[length(processing_tasks)]"
	return ..()

/datum/controller/subsystem/factions/fire()
	if(length(current_active_run))
		active_factions.Cut()
		processing_tasks = 0

		for(var/faction_to_get in FACTION_LIST_ALL)
			active_factions += GLOB.faction_datums[faction_to_get]

		current_active_run = active_factions.Copy()

		if(MC_TICK_CHECK)
			return

	while(length(current_active_run))
		var/datum/faction/faction = current_active_run[length(current_active_run)]
		if(!length(current_active_run_tasks))
			for(var/datum/faction_task/task in SSfactions.active_tasks)
				if(task.faction_owner != faction)
					continue
				current_active_run_tasks += task

		while(length(current_active_run_tasks))
			if(MC_TICK_CHECK)
				return

			var/datum/faction_task/task = current_active_run_tasks[length(current_active_run_tasks)]
			current_active_run_tasks.len--
			task.process()
			task.check_completion()
			if(task.state & OBJECTIVE_COMPLETE|OBJECTIVE_FAILED)
				stop_processing_task(task)

		current_active_run.len--

	try_to_set_task()

/datum/controller/subsystem/factions/proc/try_to_set_task()
	set waitfor = FALSE

	if(prob(1))
		for(var/faction_to_get in FACTION_LIST_ALL)
			if(make_potential_tasks(faction_to_get))
				break

/datum/controller/subsystem/factions/proc/make_potential_tasks(faction, use_game_enders = FALSE)
	var/datum/faction_task/faction_task
	var/picked_gen = pick(use_game_enders ? GLOB.task_gen_list_game_enders : GLOB.task_gen_list)
	switch(picked_gen)
		if("sector_control")
			for(var/obj/structure/prop/sector_center/sector in sectors)
				if(sector.faction != faction)
					continue

				for(var/obj/structure/prop/sector_center/border_sector in sector.bordered_sectors)
					if(border_sector.faction == faction || !(border_sector.home_sector && GLOB.faction_datums[faction].homes_sector_occupation))
						continue
					var/list/potential_task_list = GLOB.task_gen_list[picked_gen]
					var/list/datum/faction_task/tasks_list = border_sector.get_faction_tasks(faction)
					for(var/datum/faction_task/task in tasks_list)
						potential_task_list -= task.type
					if(length(potential_task_list))
						var/type_to_gen = pick(potential_task_list)
						faction_task = new type_to_gen(GLOB.faction_datums[faction], border_sector)
						break

				if(faction_task)
					break

		if("game_enders")
			var/list/potential_task_list = GLOB.task_gen_list_game_enders[picked_gen]
			var/game_ender_type_to_gen = pick(potential_task_list)
			faction_task = new game_ender_type_to_gen(GLOB.faction_datums[faction])

	if(faction_task)
		active_tasks += faction_task
		return TRUE
	return FALSE

/datum/controller/subsystem/factions/proc/build_sectors()
	var/list/sectors_by_id = list()
	for(var/obj/structure/prop/sector_center/sector in sectors)
		sectors_by_id[sector.sector_id] = sector

	for(var/obj/structure/prop/sector_center/sector in sectors)
		for(var/bordered_sector_id in sector.sector_connections)
			sector.bordered_sectors += sectors_by_id[bordered_sector_id]

/datum/controller/subsystem/factions/proc/add_task(datum/faction_task/task)
	total_tasks += task

/datum/controller/subsystem/factions/proc/remove_task(datum/faction_task/task)
	total_tasks -= task

/datum/controller/subsystem/factions/proc/start_processing_task(datum/faction_task/task)
	active_tasks += task

/datum/controller/subsystem/factions/proc/stop_processing_task(datum/faction_task/task)
	active_tasks -= task
