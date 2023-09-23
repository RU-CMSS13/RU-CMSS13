//heart sounds
#define SOUND_CHANNEL_HEART 724

/mob/living/carbon/proc/heartbeating()
	if(heartpouncecooldown > world.time)
		return
	if(heartbeatingcooldown > world.time)
		return
	else if(heartbeatingcooldown < world.time)
		src << sound('code/modules/carrotman2013/sounds/heartbeat/heartbeat.ogg',volume=40,channel=SOUND_CHANNEL_HEART)
		heartbeatingcooldown = world.time + 515

/mob/living/carbon/proc/heartpounce()
	if(heartbeatingcooldown > world.time)
		return
	if(heartpouncecooldown > world.time)
		return
	else if(heartpouncecooldown < world.time)
		src << sound('code/modules/carrotman2013/sounds/heartbeat/heartpounce.ogg',volume=40,channel=SOUND_CHANNEL_HEART)
		heartpouncecooldown = world.time + 15
