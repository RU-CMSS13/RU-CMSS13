/datum/asset/spritesheet/battlepass
	name = "battlepass"

/datum/asset/spritesheet/battlepass/register()
	var/list/iconstates_added = list()
	for(var/datum/battlepass_reward/reward as anything in subtypesof(/datum/battlepass_reward))
		reward = new reward
		if(reward.icon_state in iconstates_added)
			qdel(reward)
			continue

		var/icon/sprite = icon(reward.icon, reward.icon_state)
		sprite.Scale(96, 96)
		Insert(reward.icon_state, sprite)
		iconstates_added += reward.icon_state
		qdel(reward)
	return ..()
