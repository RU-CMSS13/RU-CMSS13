/datum/emote/living/carbon/human/spit
	key = "spit"
	key_third_person = "spits"
	message = "spits on something."
	alt_message = "spits"
	sound = 'core_ru/sound/misc/spitemote.ogg'
	cooldown = 5 SECONDS
	emote_type = EMOTE_AUDIBLE|EMOTE_VISIBLE

/datum/emote/living/carbon/human/laugh/get_sound(mob/living/user)
	if(ishumansynth_strict(user))
		if(user.gender == MALE)
			return pick('core_ru/sound/voice/human_male_laugh_1.ogg', 'core_ru/sound/voice/human_male_laugh_2.ogg')
		else
			return pick('core_ru/sound/voice/human_female_laugh_1.ogg', 'core_ru/sound/voice/human_female_laugh_2.ogg')
