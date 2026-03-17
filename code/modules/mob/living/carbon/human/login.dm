/mob/living/carbon/human/Login()
	..()
	if(species)
		species.handle_login_special(src)
	if(selected_ability)
		set_selected_ability(null) // This has winsets that can sleep, so all variables must be set prior in the event Logout occurs during sleep

//RUCM START
	if(!tts_voice && SStts.tts_enabled && has_tts_voice)
		tts_voice = SAFEPICK(gender == MALE ? GLOB.tts_voices_men : GLOB.tts_voices_woman)
//RUCM END

/mob/living/carbon/human/proc/add_fax_responder()
	if(SSticker.mode)
		SSticker.mode.fax_responders += src
		return TRUE
	return FALSE

/mob/living/carbon/human/proc/despawn_fax_responder()
	if(SSticker.mode)
		SSticker.mode.fax_responders -= src
		return TRUE
	return FALSE
