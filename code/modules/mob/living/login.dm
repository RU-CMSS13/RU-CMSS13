
/mob/living/Login()
	//Mind updates
	mind_initialize() //updates the mind (or creates and initializes one if one doesn't exist)
	mind.active = 1 //indicates that the mind is currently synced with a client

	..()

	if(LAZYLEN(pipes_shown)) //ventcrawling, need to reapply pipe vision
		var/obj/structure/pipes/A = loc
		if(istype(A)) //a sanity check just to be safe
			remove_ventcrawl()
			update_pipe_icons(A)

	//RUCM START
	if(SStts.tts_enabled)
		if(client?.prefs?.forced_voice)
			tts_voice = client.prefs.forced_voice
		else
			tts_voice = SAFEPICK(SStts.available_speakers)
	//RUCM END
