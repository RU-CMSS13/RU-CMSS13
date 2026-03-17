/mob/living/carbon/xenomorph/Login()
	..()
	if(client)
		set_lighting_alpha_from_prefs(client)
/* RUCM CHANGE
		if(client.player_data)
			generate_name()
*/
//RUCM START
		generate_name()
//RUCM END
	if(SSticker.mode)
		SSticker.mode.xenomorphs |= mind
	if(selected_ability)
		set_selected_ability(null)
