#define WO_MAX_WAVE 15

/proc/check_wo()
	if(SSticker.mode == GAMEMODE_WHISKEY_OUTPOST || GLOB.master_mode == GAMEMODE_WHISKEY_OUTPOST)
		return TRUE
	return FALSE

/datum/game_mode/whiskey_outpost
	name = GAMEMODE_WHISKEY_OUTPOST
	config_tag = GAMEMODE_WHISKEY_OUTPOST
	required_players = 40
	xeno_bypass_timer = 1
	flags_round_type = MODE_NEW_SPAWN
	role_mappings = list(
		/datum/job/command/commander/whiskey = JOB_CO,
		/datum/job/command/executive/whiskey = JOB_XO,
		/datum/job/civilian/synthetic/whiskey = JOB_SYNTH,
		/datum/job/command/warrant/whiskey = JOB_CHIEF_POLICE,
		/datum/job/command/bridge/whiskey = JOB_SO,
		/datum/job/command/tank_crew/whiskey = JOB_CREWMAN,
		/datum/job/command/police/whiskey = JOB_POLICE,
		/datum/job/command/pilot/whiskey = JOB_PILOT,
		/datum/job/logistics/requisition/whiskey = JOB_CHIEF_REQUISITION,
		/datum/job/civilian/professor/whiskey = JOB_CMO,
		/datum/job/civilian/doctor/whiskey = JOB_DOCTOR,
		/datum/job/civilian/researcher/whiskey = JOB_RESEARCHER,
		/datum/job/logistics/engineering/whiskey = JOB_CHIEF_ENGINEER,
		/datum/job/logistics/tech/maint/whiskey = JOB_MAINT_TECH,
		/datum/job/logistics/cargo/whiskey = JOB_CARGO_TECH,
		/datum/job/civilian/liaison/whiskey = JOB_CORPORATE_LIAISON,
		/datum/job/marine/leader/whiskey = JOB_SQUAD_LEADER,
		/datum/job/marine/specialist/whiskey = JOB_SQUAD_SPECIALIST,
		/datum/job/marine/smartgunner/whiskey = JOB_SQUAD_SMARTGUN,
		/datum/job/marine/medic/whiskey = JOB_SQUAD_MEDIC,
		/datum/job/marine/engineer/whiskey = JOB_SQUAD_ENGI,
		/datum/job/marine/standard/whiskey = JOB_SQUAD_MARINE,
	)


	latejoin_larva_drop = 0 //You never know

	//var/mob/living/carbon/human/Commander //If there is no Commander, marines wont get any supplies
	//No longer relevant to the game mode, since supply drops are getting changed.
	var/checkwin_counter = 0
	var/finished = 0
	var/has_started_timer = 10 //This is a simple timer so we don't accidently check win conditions right in post-game
	var/randomovertime = 0 //This is a simple timer so we can add some random time to the game mode.
	var/spawn_next_wave = 12 MINUTES //Spawn first batch at ~12 minutes
	var/last_wave_time = 0 // Stores the time the last wave (wave 15) started
	var/xeno_wave = 1 //Which wave is it

	var/wave_ticks_passed = 0 //Timer for xeno waves

	var/list/players = list()

	var/list/turf/xeno_spawns = list()
	var/list/turf/supply_spawns = list()

	//Who to spawn and how often which caste spawns
		//The more entires with same path, the more chances there are to pick it
			//This will get populated with spawn_xenos() proc
	var/list/spawnxeno = list()
	var/list/xeno_pool = list()

	var/next_supply = 1 MINUTES //At which wave does the next supply drop come?

	var/ticks_passed = 0
	var/lobby_time = 0 //Lobby time does not count for marine 1h win condition

	var/map_locale = 0 // 0 is Jungle Whiskey Outpost, 1 is Big Red Whiskey Outpost, 2 is Ice Colony Whiskey Outpost, 3 is space
	var/spawn_next_wo_wave = FALSE

	var/list/whiskey_outpost_waves = list()

	hardcore = TRUE

	votable = TRUE
	vote_cycle = 2 // Почаще чем 'approx. once every 5 days, if it wins the vote', но не так часто как Дистресс сигнал

	taskbar_icon = 'icons/taskbar/gml_wo.png'

/datum/game_mode/whiskey_outpost/New()
	. = ..()
	required_players = CONFIG_GET(number/whiskey_required_players)

/datum/game_mode/whiskey_outpost/get_roles_list()
	return GLOB.ROLES_WO

/datum/game_mode/whiskey_outpost/announce()
	return 1

/datum/game_mode/whiskey_outpost/pre_setup()
	SSticker.mode.toggleable_flags ^= MODE_HARDCORE_PERMA
	for(var/obj/effect/landmark/whiskey_outpost/xenospawn/X)
		xeno_spawns += X.loc
	for(var/obj/effect/landmark/whiskey_outpost/supplydrops/S)
		supply_spawns += S.loc

	var/datum/hive_status/hive = GLOB.hive_datum[XENO_HIVE_NORMAL]
	hive.allow_queen_evolve = FALSE
	hive.allow_no_queen_actions = TRUE

	//  WO waves
	var/list/paths = typesof(/datum/whiskey_outpost_wave) - /datum/whiskey_outpost_wave - /datum/whiskey_outpost_wave/random
	for(var/i in 1 to WO_MAX_WAVE)
		whiskey_outpost_waves += i
		whiskey_outpost_waves[i] = list()
	for(var/T in paths)
		var/datum/whiskey_outpost_wave/WOW = new T
		if(WOW.wave_number > 0)
			whiskey_outpost_waves[WOW.wave_number] += WOW

	return ..()

/datum/game_mode/whiskey_outpost/post_setup()
	set waitfor = 0
	update_controllers()
	initialize_post_marine_gear_list()
	lobby_time = world.time

	CONFIG_SET(flag/remove_gun_restrictions, TRUE)
	sleep(10)
	to_world(SPAN_ROUND_HEADER("Режим игры - WHISKEY OUTPOST!"))
	to_world(SPAN_ROUNDBODY("События происходят на планете LV-624 в 2177 году, за пять лет до прибытия военного корабля USS «Almayer» и 2-го батальона «Падающие соколы» в сектор."))
	to_world(SPAN_ROUNDBODY("3 Батальону 'Пустынных рейдеров' выдана задача распространять влияние USCM в Секторе Нероид."))
	to_world(SPAN_ROUNDBODY("[SSmapping.configs[GROUND_MAP].map_name], одна из баз 'Пустынных рейдеров' расположившаяся в этом секторе, попала под атаку неизвестных инопланетных форм жизни."))
	to_world(SPAN_ROUNDBODY("С ростом количества жертв и постепенно истощающимися припасами, 'Dust Raiders' на [SSmapping.configs[GROUND_MAP].map_name] должны прожить еще час, чтобы оповестить оставшуюся часть своего батальона в секторе о надвигающейся опасности."))
	to_world(SPAN_ROUNDBODY("Продержитесь столько, сколько сможете."))
	world << sound('sound/effects/siren.ogg')

	sleep(10)
	switch(map_locale) //Switching it up.
		if(0)
			marine_announcement("Это капитан Ханс Найхе, командир 3-го батальона «Пустынных рейдеров», который находится здесь на LV-624. В ходе наших попыток создать базу на этой планете, несколько наших патрулей были уничтожены враждебными существами. Мы отправляем сигнал бедствия, но нам нужно, чтобы вы продержались на [SSmapping.configs[GROUND_MAP].map_name] пока наши инженеры настроят ретранслятор. Мы готовим несколько минометных установок M402 для оказания огневой поддержки. Если они захватят вашу позицию, мы будем уничтожены и не сможем позвать на помощь. Держите оборону или мы все умрем.", "Капитан Ханс, командир 3-го батальона, гарнизон LV-624")
	addtimer(CALLBACK(src, PROC_REF(story_announce), 0), 3 MINUTES)
	return ..()

/datum/game_mode/whiskey_outpost/proc/story_announce(time)
	switch(time)
		if(0)
			marine_announcement("Это капитан Ханс Найхе, командир 3-го батальона «Пустынных рейдеров» на LV-624. Как вы уже знаете, несколько наших патрулей пропали без вести и, вероятно были уничтожены враждебно настроенными местными существами, когда мы пытались обустроить нашу базу.", "Капитан Найхе, командир 3-го батальона, гарнизон LV-624")
		if(1)
			marine_announcement("Наши разведчики сообщают о возросшей активности в этом районе, и учитывая наши разведданные, мы уже готовимся к худшему. Мы устанавливаем ретранслятор, чтобы отправить сигнал бедствия, но нам потребуется время, пока наши инженеры все подготовят. Все остальные аванпосты должны подготовиться соответствующим образом и обеспечить максимальную боевую готовность, которая должна вступить в силу немедленно.", "Капитан Найхе, командир 3-го батальона, гарнизон LV-624")
		if(2)
			marine_announcement("Говорит капитан Найхе. Мы засекли основные силы противника, и [SSmapping.configs[GROUND_MAP].map_name]  скорее всего, они будут уничтожены до того, как достигнут базы. Нам нужно, чтобы вы задержали их, пока мы не отправим сигнал бедствия. Прибытие ожидается в течение нескольких минут. Удачи [SSmapping.configs[GROUND_MAP].map_name].", "Капитан Найхе, командир 3-го батальона, гарнизон LV-624")

	if(time <= 2)
		addtimer(CALLBACK(src, PROC_REF(story_announce), time+1), 3 MINUTES)

/datum/game_mode/whiskey_outpost/proc/update_controllers()
	//Update controllers while we're on this mode
	if(SSitem_cleanup)
		//Cleaning stuff more aggressively
		SSitem_cleanup.start_processing_time = 0
		SSitem_cleanup.percentage_of_garbage_to_delete = 1
		SSitem_cleanup.wait = 1 MINUTES
		SSitem_cleanup.next_fire = 1 MINUTES
		spawn(0)
			//Deleting Almayer, for performance!
			SSitem_cleanup.delete_almayer()


//PROCCESS
/datum/game_mode/whiskey_outpost/process(delta_time)
	. = ..()
	checkwin_counter++
	ticks_passed++
	wave_ticks_passed++

	if(wave_ticks_passed >= (spawn_next_wave/(delta_time SECONDS)))
		wave_ticks_passed = 0
		spawn_next_wo_wave = TRUE

	if(spawn_next_wo_wave)
		spawn_next_xeno_wave()

	if(has_started_timer > 0) //Initial countdown, just to be safe, so that everyone has a chance to spawn before we check anything.
		has_started_timer--

	if(world.time > next_supply)
		place_whiskey_outpost_drop()
		next_supply += 2 MINUTES

	if(checkwin_counter >= 10) //Only check win conditions every 10 ticks.
		if(xeno_wave == WO_MAX_WAVE && last_wave_time == 0)
			last_wave_time = world.time
		if(!finished && GLOB.round_should_check_for_win && last_wave_time != 0)
			check_win()
		checkwin_counter = 0
	return 0

/datum/game_mode/whiskey_outpost/proc/spawn_next_xeno_wave()
	spawn_next_wo_wave = FALSE
	var/wave = pick(whiskey_outpost_waves[xeno_wave])
	spawn_whiskey_outpost_xenos(wave)
	announce_xeno_wave(wave)
	if(xeno_wave == 7)
		//Wave when Marines get reinforcements!
		get_specific_call(/datum/emergency_call/wo, FALSE, TRUE) // "Marine Reinforcements (Squad)"
	xeno_wave = min(xeno_wave + 1, WO_MAX_WAVE)


/datum/game_mode/whiskey_outpost/proc/announce_xeno_wave(datum/whiskey_outpost_wave/wave_data)
	if(!istype(wave_data))
		return
	if(wave_data.command_announcement.len > 0)
		marine_announcement(wave_data.command_announcement[1], wave_data.command_announcement[2])
	if(wave_data.sound_effect.len > 0)
		playsound_z(SSmapping.levels_by_trait(ZTRAIT_GROUND), pick(wave_data.sound_effect))

//CHECK WIN
/datum/game_mode/whiskey_outpost/check_win()
	var/C = count_humans_and_xenos(SSmapping.levels_by_trait(ZTRAIT_GROUND))

	if(C[1] == 0)
		finished = 1 //Alien win
	else if(world.time > last_wave_time + 15 MINUTES) // Around 1:12 hh:mm
		finished = 2 //Marine win

/datum/game_mode/whiskey_outpost/proc/disablejoining()
	for(var/i in GLOB.RoleAuthority.roles_by_name)
		var/datum/job/J = GLOB.RoleAuthority.roles_by_name[i]

		// If the job has unlimited job slots, We set the amount of slots to the amount it has at the moment this is called
		if (J.spawn_positions < 0)
			J.spawn_positions = J.current_positions
			J.total_positions = J.current_positions
		J.current_positions = J.get_total_positions(TRUE)
	to_world("<B>New players may no longer join the game.</B>")
	message_admins("Wave one has begun. Disabled new player game joining.")
	message_admins("Wave one has begun. Disabled new player game joining except for replacement of cryoed marines.")
	world.update_status()

/datum/game_mode/whiskey_outpost/count_xenos()//Counts braindead too
	var/xeno_count = 0
	for(var/i in GLOB.living_xeno_list)
		var/mob/living/carbon/xenomorph/X = i
		if(is_ground_level(X.z) && !istype(X.loc,/turf/open/space)) // If they're connected/unghosted and alive and not debrained
			xeno_count += 1 //Add them to the amount of people who're alive.

	return xeno_count

/datum/game_mode/whiskey_outpost/proc/pickovertime()
	var/randomtime = ((rand(0,6)+rand(0,6)+rand(0,6)+rand(0,6))*50 SECONDS)
	var/maxovertime = 20 MINUTES
	if (randomtime >= maxovertime)
		return maxovertime
	return randomtime

///////////////////////////////
//Checks if the round is over//
///////////////////////////////
/datum/game_mode/whiskey_outpost/check_finished()
	if(finished != 0)
		return 1

	return 0

//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relevant information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/whiskey_outpost/declare_completion()
	if(GLOB.round_statistics)
		GLOB.round_statistics.track_round_end()
	if(finished == 1)
		log_game("Round end result - xenos won")
		to_world(SPAN_ROUND_HEADER("Ксеноморфы успешно защитили свой улей от колонизации."))
		to_world(SPAN_ROUNDBODY("Отличная работа, вы закрепились на LV-624 за улей!"))
		to_world(SPAN_ROUNDBODY("Пройдет еще пять лет, прежде чем USCM вернется в сектор Нероид, с прибытием 2-го батальона «Падающих соколов» и эсминца USS Almayer."))
		to_world(SPAN_ROUNDBODY("До тех пор улью ксеноморфов на LV-624 ничто не угрожает..."))
		world << sound('sound/misc/Game_Over_Man.ogg')
		if(GLOB.round_statistics)
			GLOB.round_statistics.round_result = MODE_INFESTATION_X_MAJOR
			if(GLOB.round_statistics.current_map)
				GLOB.round_statistics.current_map.total_xeno_victories++
				GLOB.round_statistics.current_map.total_xeno_majors++

	else if(finished == 2)
		log_game("Round end result - marines won")
		to_world(SPAN_ROUND_HEADER("Несмотря на этот натиск, морпехи выжили."))
		to_world(SPAN_ROUNDBODY("Сигнал поступает на корабль USS Alistoun, и Пустынные рейдеры дислоцированные в других местах сектора Нероид начинают стягиваться к LV-624."))
		to_world(SPAN_ROUNDBODY("В конце концов, в 2182 году Пустынные рейдеры захватывают LV-624 и весь сектор Нероидов, умиротворяя его и устанавливая мир в секторе на десятилетия вперед."))
		to_world(SPAN_ROUNDBODY("USS Almayer и 2-й батальон «Падающих соколов» так и не были отправлены в этот сектор, и их судьба была решена в 2186 году."))
		world << sound('sound/misc/hell_march.ogg')
		if(GLOB.round_statistics)
			GLOB.round_statistics.round_result = MODE_INFESTATION_M_MAJOR
			if(GLOB.round_statistics.current_map)
				GLOB.round_statistics.current_map.total_marine_victories++
				GLOB.round_statistics.current_map.total_marine_majors++

	else
		log_game("Round end result - no winners")
		to_world(SPAN_ROUND_HEADER("Никто не выйграл!"))
		to_world(SPAN_ROUNDBODY("Как? Не спрашивай меня..."))
		world << 'sound/misc/sadtrombone.ogg'
		if(GLOB.round_statistics)
			GLOB.round_statistics.round_result = MODE_INFESTATION_DRAW_DEATH

	if(GLOB.round_statistics)
		GLOB.round_statistics.game_mode = name
		GLOB.round_statistics.round_length = world.time
		GLOB.round_statistics.end_round_player_population = GLOB.clients.len

		GLOB.round_statistics.log_round_statistics()

		round_finished = 1

	calculate_end_statistics()


	return 1

/datum/game_mode/proc/auto_declare_completion_whiskey_outpost()
	return

/datum/game_mode/whiskey_outpost/proc/place_whiskey_outpost_drop(OT = "sup") //Art revamping spawns 13JAN17
	var/turf/T = pick(supply_spawns)
	var/randpick
	var/list/randomitems = list()
	var/list/spawnitems = list()
	var/choosemax
	var/obj/structure/closet/crate/crate

	if(!OT)
		OT = "sup" //no breaking anything.

	else if (OT == "sup")
		randpick = rand(0,90)
		switch(randpick)
			if(0 to 3)//Marine Gear 3% Chance.
				crate = new /obj/structure/closet/crate/secure/gear(T)
				choosemax = rand(5,10)
				randomitems = list(/obj/item/clothing/head/helmet/marine,
								/obj/item/clothing/head/helmet/marine,
								/obj/item/clothing/head/helmet/marine,
								/obj/item/clothing/suit/storage/marine/medium,
								/obj/item/clothing/suit/storage/marine/medium,
								/obj/item/clothing/suit/storage/marine/medium,
								/obj/item/clothing/head/helmet/marine/tech,
								/obj/item/clothing/head/helmet/marine/medic,
								/obj/item/clothing/under/marine/medic,
								/obj/item/clothing/under/marine/engineer,
								/obj/effect/landmark/wo_supplies/storage/webbing,
								/obj/item/device/binoculars)

			if(4 to 6)//Lights and shiet 2%
				new /obj/structure/largecrate/supply/floodlights(T)
				new /obj/structure/largecrate/supply/supplies/flares(T)


			if(7 to 10) //3% Chance to drop this !FUN! junk.
				crate = new /obj/structure/closet/crate/secure/gear(T)
				spawnitems = list(/obj/item/storage/belt/utility/full,
									/obj/item/storage/belt/utility/full,
									/obj/item/storage/belt/utility/full,
									/obj/item/storage/belt/utility/full)

			if(11 to 22)//Materials 12% Chance.
				crate = new /obj/structure/closet/crate/secure/gear(T)
				choosemax = rand(3,8)
				randomitems = list(/obj/item/stack/sheet/metal,
								/obj/item/stack/sheet/metal,
								/obj/item/stack/sheet/metal,
								/obj/item/stack/sheet/plasteel,
								/obj/item/stack/sandbags_empty/half,
								/obj/item/stack/sandbags_empty/half,
								/obj/item/stack/sandbags_empty/half)

			if(23 to 25)//Blood Crate 2% chance
				crate = new /obj/structure/closet/crate/medical(T)
				spawnitems = list(/obj/item/reagent_container/blood/OMinus,
								/obj/item/reagent_container/blood/OMinus,
								/obj/item/reagent_container/blood/OMinus,
								/obj/item/reagent_container/blood/OMinus,
								/obj/item/reagent_container/blood/OMinus)

			if(26 to 30)//Advanced meds Crate 5%
				crate = new /obj/structure/closet/crate/medical(T)
				spawnitems = list(/obj/item/storage/firstaid/fire,
								/obj/item/storage/firstaid/regular,
								/obj/item/storage/firstaid/toxin,
								/obj/item/storage/firstaid/o2,
								/obj/item/storage/firstaid/adv,
								/obj/item/bodybag/cryobag,
								/obj/item/bodybag/cryobag,
								/obj/item/storage/belt/medical/lifesaver/full,
								/obj/item/storage/belt/medical/lifesaver/full,
								/obj/item/clothing/glasses/hud/health,
								/obj/item/clothing/glasses/hud/health,
								/obj/item/device/defibrillator)

			if(31 to 34)//Random Medical Items 4%. Made the list have less small junk
				crate = new /obj/structure/closet/crate/medical(T)
				spawnitems = list(/obj/item/storage/belt/medical/lifesaver/full,
								/obj/item/storage/belt/medical/lifesaver/full,
								/obj/item/storage/belt/medical/lifesaver/full,
								/obj/item/storage/belt/medical/lifesaver/full,
								/obj/item/storage/belt/medical/lifesaver/full)

			if(35 to 40)//Random explosives Crate 5% because the lord commeth and said let there be explosives.
				crate = new /obj/structure/closet/crate/ammo(T)
				choosemax = rand(1,5)
				randomitems = list(/obj/item/storage/box/explosive_mines,
								/obj/item/storage/box/explosive_mines,
								/obj/item/explosive/grenade/high_explosive/m15,
								/obj/item/explosive/grenade/high_explosive/m15,
								/obj/item/explosive/grenade/high_explosive,
								/obj/item/storage/box/nade_box
								)
			if(41 to 44)
				crate = new /obj/structure/closet/crate/ammo(T)
				spawnitems = list(
									/obj/item/attachable/heavy_barrel,
									/obj/item/attachable/heavy_barrel,
									/obj/item/attachable/heavy_barrel,
									/obj/item/attachable/heavy_barrel)

			if(45 to 50)//Weapon + supply beacon drop. 5%
				crate = new /obj/structure/closet/crate/ammo(T)
				spawnitems = list(/obj/item/device/whiskey_supply_beacon,
								/obj/item/device/whiskey_supply_beacon,
								/obj/item/device/whiskey_supply_beacon,
								/obj/item/device/whiskey_supply_beacon)

			if(51 to 57)//Rare weapons. Around 6%
				crate = new /obj/structure/closet/crate/ammo(T)
				spawnitems = list(/obj/effect/landmark/wo_supplies/ammo/box/rare/m41aap,
								/obj/effect/landmark/wo_supplies/ammo/box/rare/m41aapmag,
								/obj/effect/landmark/wo_supplies/ammo/box/rare/m41aextend,
								/obj/effect/landmark/wo_supplies/ammo/box/rare/smgap,
								/obj/effect/landmark/wo_supplies/ammo/box/rare/smgextend)

			if(58 to 65) // Sandbags kit
				crate = new /obj/structure/closet/crate(T)
				spawnitems = list(/obj/item/tool/shovel/etool,
								/obj/item/stack/sandbags_empty/half,
								/obj/item/stack/sandbags_empty/half,
								/obj/item/stack/sandbags_empty/half)

			if(66 to 70) // Mortar shells. Pew Pew!
				crate = new /obj/structure/closet/crate/secure/mortar_ammo(T)
				choosemax = rand(6,10)
				randomitems = list(/obj/item/mortar_shell/he,
								/obj/item/mortar_shell/incendiary,
								/obj/item/mortar_shell/flare,
								/obj/item/mortar_shell/frag)

			if(71 to 79)
				crate = new /obj/structure/closet/crate/ammo(T)
				choosemax = rand(2, 3)
				randomitems = list(/obj/item/ammo_box/rounds,
								/obj/item/ammo_box/rounds/ap,
								/obj/item/ammo_box/rounds/smg,
								/obj/item/ammo_box/rounds/smg/ap,
								/obj/item/ammo_box/magazine/ap,
								/obj/item/ammo_box/magazine/ext,
								/obj/item/ammo_box/magazine/m4ra/ap,
								/obj/item/ammo_box/magazine/m4ra/ap,
								/obj/item/ammo_box/magazine/m39/ap,
								/obj/item/ammo_box/magazine/m39/ext,
				)

			if(80 to 82)
				crate = new /obj/structure/closet/crate/ammo(T)
				choosemax = rand(2, 3)
				randomitems = list(/obj/item/ammo_magazine/rifle/lmg/holo_target,
								/obj/item/ammo_magazine/rifle/lmg/holo_target,
								/obj/item/ammo_magazine/rifle/lmg,
								/obj/item/ammo_magazine/rifle/lmg,
				)

			if(83 to 86)
				crate = new /obj/structure/closet/crate/ammo(T)
				spawnitems = list(
									/obj/item/attachable/magnetic_harness,
									/obj/item/attachable/magnetic_harness,
									/obj/item/attachable/magnetic_harness,
									/obj/item/attachable/magnetic_harness)

			if(86 to 90)
				crate = new /obj/structure/closet/crate/secure/gear(T)
				spawnitems = list(
									/obj/item/device/binoculars/range,
									/obj/item/device/binoculars/range,
				)

	if(crate)
		crate.storage_capacity = 60

	if(randomitems.len)
		for(var/i = 0; i < choosemax; i++)
			var/path = pick(randomitems)
			var/obj/I = new path(crate)
			if(OT == "sup")
				if(I && istype(I,/obj/item/stack/sheet/mineral/phoron) || istype(I,/obj/item/stack/rods) || istype(I,/obj/item/stack/sheet/glass) || istype(I,/obj/item/stack/sheet/metal) || istype(I,/obj/item/stack/sheet/plasteel) || istype(I,/obj/item/stack/sheet/wood))
					I:amount = rand(30,50) //Give them more building materials.
				if(I && istype(I,/obj/structure/machinery/floodlight))
					I.anchored = FALSE


	else
		if(crate)
			for(var/path in spawnitems)
				new path(crate)

//Whiskey Outpost Recycler Machine. Teleports objects to centcomm so it doesnt lag
/obj/structure/machinery/wo_recycler
	icon = 'icons/obj/structures/machinery/recycling.dmi'
	icon_state = "grinder-o0"
	var/icon_on = "grinder-o1"

	name = "Recycler"
	desc = "Instructions: Place objects you want to destroy on top of it and use the machine. Use with care"
	density = FALSE
	anchored = TRUE
	unslashable = TRUE
	unacidable = TRUE
	var/working = 0

/obj/structure/machinery/wo_recycler/attack_hand(mob/living/user)
	if(inoperable(MAINT))
		return
	if(user.is_mob_incapacitated())
		return
	if(istype(usr, /mob/living/carbon/xenomorph))
		to_chat(usr, SPAN_DANGER("You don't have the dexterity to do this!"))
		return
	if(working)
		to_chat(user, SPAN_DANGER("Wait for it to recharge first."))
		return

	var/remove_max = 10
	var/turf/T = src.loc
	if(T)
		to_chat(user, SPAN_DANGER("You turn on the recycler."))
		var/removed = 0
		for(var/i, i < remove_max, i++)
			for(var/obj/O in T)
				if(istype(O,/obj/structure/closet/crate))
					var/obj/structure/closet/crate/C = O
					if(C.contents.len)
						to_chat(user, SPAN_DANGER("[O] must be emptied before it can be recycled"))
						continue
					new /obj/item/stack/sheet/metal(get_step(src,dir))
					O.forceMove(get_turf(locate(84,237,2))) //z.2
// O.forceMove(get_turf(locate(30,70,1)) )//z.1
					removed++
					break
				else if(istype(O,/obj/item))
					var/obj/item/I = O
					if(I.anchored)
						continue
					O.forceMove(get_turf(locate(84,237,2))) //z.2
// O.forceMove(get_turf(locate(30,70,1)) )//z.1
					removed++
					break
			for(var/mob/M in T)
				if(istype(M,/mob/living/carbon/xenomorph))
					var/mob/living/carbon/xenomorph/X = M
					if(!X.stat == DEAD)
						continue
					X.forceMove(get_turf(locate(84,237,2))) //z.2
// X.forceMove(get_turf(locate(30,70,1)) )//z.1
					removed++
					break
			if(removed && !working)
				playsound(loc, 'sound/effects/meteorimpact.ogg', 25, 1)
				working = 1 //Stops the sound from repeating
			if(removed >= remove_max)
				break

	working = 1
	addtimer(VARSET_CALLBACK(src, working, FALSE), 10 SECONDS)

/obj/structure/machinery/wo_recycler/ex_act(severity)
	return


////////////////////
//Art's Additions //
////////////////////

/////////////////////////////////////////
// Whiskey Outpost V2 Standard Edition //
/////////////////////////////////////////

////////////////////////////////////////////////////////////
//Supply drops for Whiskey Outpost via SLs
//These will come in the form of ammo drops. Will have probably like 5 settings? SLs will get a few of them.
//Should go: Regular ammo, Spec Rocket Ammo, Spec Smartgun ammo, Spec Sniper ammo, and then explosives (grenades for grenade spec).
//This should at least give SLs the ability to rearm their squad at the frontlines.

/obj/item/device/whiskey_supply_beacon //Whiskey Outpost Supply beacon. Might as well reuse the IR target beacon (Time to spook the fucking shit out of people.)
	name = "ASB beacon"
	desc = "Маяк снабжения боеприпасами, он имеет 5 различных типов боеприпасов для вызова. Посмотрите на своё оружие и выберите тип боеприпасов которые хотите заказать."
	icon = 'icons/turf/whiskeyoutpost.dmi'
	icon_state = "ir_beacon"
	w_class = SIZE_SMALL
	var/activated = 0
	var/icon_activated = "ir_beacon_active"
	var/supply_drop = 0 //0 = Regular ammo, 1 = Rocket, 2 = Smartgun, 3 = Sniper, 4 = Explosives + GL

/obj/item/device/whiskey_supply_beacon/attack_self(mob/user)
	..()

	if(!ishuman(user))
		return
	if(!user.mind)
		to_chat(user, "It doesn't seem to do anything for you.")
		return

	playsound(src,'sound/machines/click.ogg', 15, 1)

	var/list/supplies = list(
		"10x24mm, пули для дробовика, дробь для дробовика, и 10x20mm патроны",
		"Взрывчатка и гранаты",
		"Ракеты",
		"Снайперские магазины",
		"Топливные баки для пиротехника",
		"Магазины для разведчика",
		"Барабаны на СГ",
	)

	var/supply_drop_choice = tgui_input_list(user, "Какие припасы вы хотите заказать?", "Сброс припасов", supplies)

	switch(supply_drop_choice)
		if("10x24mm, пули для дробовика, дробь для дробовика, и 10x20mm патроны")
			supply_drop = 0
			to_chat(usr, SPAN_NOTICE("10x24mm, пули для дробовика, дробь для дробовика, и 10x20mm патроны скоро прилетят!"))
		if("Ракеты")
			supply_drop = 1
			to_chat(usr, SPAN_NOTICE("Ракеты скоро прилетят!"))
		if("Барабаны на СГ")
			supply_drop = 2
			to_chat(usr, SPAN_NOTICE("Барабаны на СГ скоро прилетят!"))
		if("Снайперские магазины")
			supply_drop = 3
			to_chat(usr, SPAN_NOTICE("Снайперские магазины скоро прилетят!"))
		if("Взрывчатка и гранаты")
			supply_drop = 4
			to_chat(usr, SPAN_NOTICE("Взрывчатка и гранаты скоро прилетят!"))
		if("Топливные баки для пиротехника")
			supply_drop = 5
			to_chat(usr, SPAN_NOTICE("Топливные баки для пиротехника скоро прилетят!"))
		if("Магазины для разведчика")
			supply_drop = 6
			to_chat(usr, SPAN_NOTICE("Магазины для разведчика скоро прилетят!"))
		else
			return

	if(activated)
		to_chat(user, "Бросьте его чтобы припасы прилетели!")
		return

	if(!is_ground_level(user.z))
		to_chat(user, "Вы должны быть под небом чтобы использовать или он просто не передаст сигнал.")
		return

	activated = 1
	anchored = TRUE
	w_class = 10
	icon_state = "[icon_activated]"
	playsound(src, 'sound/machines/twobeep.ogg', 15, 1)
	to_chat(user, "Вы активировали [src]. Сейчас бросьте его, скоро прилетят припасы!")

	var/mob/living/carbon/C = user
	if(istype(C) && !C.throw_mode)
		C.toggle_throw_mode(THROW_MODE_NORMAL)

	sleep(100) //10 seconds should be enough.
	var/turf/T = get_turf(src) //Make sure we get the turf we're tossing this on.
	drop_supplies(T, supply_drop)
	playsound(src,'sound/effects/bamf.ogg', 50, 1)
	qdel(src)
	return

/obj/item/device/whiskey_supply_beacon/proc/drop_supplies(turf/T, SD)
	if(!istype(T)) return
	var/list/spawnitems = list()
	var/obj/structure/closet/crate/crate
	crate = new /obj/structure/closet/crate/secure/weapon(T)
	switch(SD)
		if(0) // Alright 2 mags for the SL, a few mags for M41As that people would need. M39s get some love and split the shotgun load between slugs and buckshot.
			spawnitems = list(/obj/item/ammo_magazine/rifle/m41aMK1,
							/obj/item/ammo_magazine/rifle/m41aMK1,
							/obj/item/ammo_magazine/rifle,
							/obj/item/ammo_magazine/rifle,
							/obj/item/ammo_magazine/rifle,
							/obj/item/ammo_magazine/rifle/ap,
							/obj/item/ammo_magazine/rifle/ap,
							/obj/item/ammo_magazine/rifle/ap,
							/obj/item/ammo_magazine/rifle/ap,
							/obj/item/ammo_magazine/smg/m39,
							/obj/item/ammo_magazine/smg/m39,
							/obj/item/ammo_magazine/smg/m39,
							/obj/item/ammo_magazine/smg/m39,
							/obj/item/ammo_magazine/smg/m39/ap,
							/obj/item/ammo_magazine/smg/m39/ap,
							/obj/item/ammo_magazine/smg/m39/ap,
							/obj/item/ammo_magazine/smg/m39/ap,
							/obj/item/ammo_magazine/shotgun/slugs,
							/obj/item/ammo_magazine/shotgun/slugs,
							/obj/item/ammo_magazine/shotgun/slugs,
							/obj/item/ammo_magazine/shotgun/buckshot,
							/obj/item/ammo_magazine/shotgun/buckshot,
							/obj/item/ammo_magazine/shotgun/buckshot)
		if(1) // Six rockets should be good. Tossed in two AP rockets for possible late round fighting.
			spawnitems = list(/obj/item/ammo_magazine/rocket,
							/obj/item/ammo_magazine/rocket,
							/obj/item/ammo_magazine/rocket,
							/obj/item/ammo_magazine/rocket,
							/obj/item/ammo_magazine/rocket,
							/obj/item/ammo_magazine/rocket,
							/obj/item/ammo_magazine/rocket,
							/obj/item/ammo_magazine/rocket,
							/obj/item/ammo_magazine/rocket/ap,
							/obj/item/ammo_magazine/rocket/ap,
							/obj/item/ammo_magazine/rocket/ap,
							/obj/item/ammo_magazine/rocket/wp,
							/obj/item/ammo_magazine/rocket/wp,
							/obj/item/ammo_magazine/rocket/wp)
		if(2) //Smartgun supplies
			spawnitems = list(
					/obj/item/smartgun_battery,
					/obj/item/smartgun_battery,
					/obj/item/ammo_magazine/smartgun,
					/obj/item/ammo_magazine/smartgun,
					/obj/item/ammo_magazine/smartgun,
					/obj/item/ammo_magazine/smartgun,
					/obj/item/ammo_magazine/smartgun,
					/obj/item/ammo_magazine/smartgun,
				)
		if(3) //Full Sniper ammo loadout.
			spawnitems = list(/obj/item/ammo_magazine/sniper,
							/obj/item/ammo_magazine/sniper,
							/obj/item/ammo_magazine/sniper,
							/obj/item/ammo_magazine/sniper/incendiary,
							/obj/item/ammo_magazine/sniper/flak)
		if(4) // Give them explosives + Grenades for the Grenade spec. Might be too many grenades, but we'll find out.
			spawnitems = list(/obj/item/storage/box/explosive_mines,
							/obj/item/storage/belt/grenade/full)
		if(5) // Pyrotech
			var/fuel = pick(/obj/item/ammo_magazine/flamer_tank/large/B, /obj/item/ammo_magazine/flamer_tank/large/X)
			spawnitems = list(/obj/item/ammo_magazine/flamer_tank/large,
							/obj/item/ammo_magazine/flamer_tank/large,
							fuel)
		if(6) // Scout
			spawnitems = list(/obj/item/ammo_magazine/rifle/m4ra/custom,
							/obj/item/ammo_magazine/rifle/m4ra/custom,
							/obj/item/ammo_magazine/rifle/m4ra/custom/incendiary,
							/obj/item/ammo_magazine/rifle/m4ra/custom/impact)
	crate.storage_capacity = 60
	for(var/path in spawnitems)
		new path(crate)

/obj/item/storage/box/attachments
	name = "attachment package"
	desc = "A package containing some random attachments. Why not see what's inside?"
	icon_state = "circuit"
	w_class = SIZE_TINY
	can_hold = list()
	storage_slots = 3
	max_w_class = 0
	foldable = null
	var/list/common = list(/obj/item/attachable/suppressor, /obj/item/attachable/bayonet, /obj/item/attachable/flashlight)
	var/list/attachment_1 = list(/obj/item/attachable/reddot, /obj/item/attachable/burstfire_assembly, /obj/item/attachable/lasersight,
								/obj/item/attachable/extended_barrel,/obj/item/attachable/verticalgrip, /obj/item/attachable/angledgrip,
								/obj/item/attachable/gyro, /obj/item/attachable/bipod)
	var/list/attachment_2 = list(/obj/item/attachable/stock/smg, /obj/item/attachable/stock/shotgun, /obj/item/attachable/stock/rifle, /obj/item/attachable/magnetic_harness,
								/obj/item/attachable/heavy_barrel, /obj/item/attachable/scope,
								/obj/item/attachable/scope/mini)

/obj/item/storage/box/attachments/fill_preset_inventory()
	var/a1 = pick(common)
	var/a2 = pick(attachment_1)
	var/a3 = pick(attachment_2)
	if(a1) new a1(src)
	if(a2) new a2(src)
	if(a3) new a3(src)
	return

/obj/item/storage/box/attachments/update_icon()
	if(!contents.len)
		var/turf/T = get_turf(src)
		if(T)
			new /obj/item/paper/crumpled(T)
		qdel(src)

/obj/structure/machinery/cm_vending/clothing/medical_crew/wo_med //Ниже добавлены вендоры для медбея, СГ, спека и СЛа, делать по такому же типу остальные
	vendor_role = list(JOB_WO_DOCTOR,JOB_WO_RESEARCHER,JOB_WO_CMO)
/obj/structure/machinery/cm_vending/clothing/medical_crew/wo_med/get_listed_products(mob/user)
	if(!user)
		var/list/combined = list()
		combined += GLOB.cm_vending_clothing_researcher
		combined += GLOB.cm_vending_clothing_cmo
		combined += GLOB.cm_vending_clothing_doctor
		return combined
	if(user.job == JOB_WO_RESEARCHER)
		return GLOB.cm_vending_clothing_researcher
	else if(user.job == JOB_WO_CMO)
		return GLOB.cm_vending_clothing_cmo
	else if(user.job == JOB_WO_DOCTOR)
		return GLOB.cm_vending_clothing_doctor
	return ..()

/obj/structure/machinery/cm_vending/gear/spec/wo_spec
	vendor_role = list(JOB_WO_CREWMAN,JOB_WO_SQUAD_SPECIALIST,JOB_SQUAD_SPECIALIST)
/obj/structure/machinery/cm_vending/gear/spec/wo_spec/get_listed_products(mob/user)
	return GLOB.cm_vending_gear_spec

/obj/structure/machinery/cm_vending/gear/leader/wo_leader
	vendor_role = list(JOB_WO_CHIEF_POLICE,JOB_WO_SQUAD_LEADER,JOB_SQUAD_LEADER)
/obj/structure/machinery/cm_vending/gear/leader/wo_leader/get_listed_products(mob/user)
	return GLOB.cm_vending_gear_leader

/obj/structure/machinery/cm_vending/gear/smartgun/wo_smartgun
	vendor_role = list(JOB_WO_SQUAD_SMARTGUNNER,JOB_SQUAD_SMARTGUN)
/obj/structure/machinery/cm_vending/gear/smartgun/wo_smartgun/get_listed_products(mob/user)
	return GLOB.cm_vending_gear_smartgun

/datum/game_mode/whiskey_outpost/announce_bioscans(variance = 2)
	return // No bioscans needed in WO

/datum/game_mode/whiskey_outpost/get_escape_menu()
	return "Making a last stand on..."
