/datum/job
	var/marine_sided = FALSE
	var/xeno_sided = FALSE

/datum/job/proc/add_to_battlepass_earners(mob/living/carbon/human/character)
	if(!character?.client?.ckey)
		return

	var/ckey = character.client.ckey

	// You cannot double dip; marine or xeno only
	if(marine_sided && !(ckey in SSbattlepass.xeno_battlepass_earners))
		SSbattlepass.marine_battlepass_earners |= ckey
	else if(xeno_sided && !(ckey in SSbattlepass.marine_battlepass_earners))
		SSbattlepass.xeno_battlepass_earners |= ckey
