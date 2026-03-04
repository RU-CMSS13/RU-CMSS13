/datum/world_topic/delay
	key = "set_delay"
	required_params = list("delay")

/datum/world_topic/delay/Run(list/input)
	. = ..()

	if(SSticker.delay_start == input["delay"])
		statuscode = 501
		response = "Delay already set to same state."
		return

	SSticker.delay_start = input["delay"]
	message_admins(SPAN_NOTICE("[input["source"]] ([input["addr"]]) [SSticker.delay_start ? "delayed the round start" : "has made the round start normally"]."))
	to_chat(world, SPAN_CENTERBOLD("The game start has been [SSticker.delay_start ? "delayed" : "continued"]."))
	if(SSticker.delay_start)
		statuscode = 200
		response = "Delay set."
	else
		statuscode = 200
		response = "Delay removed."

/datum/world_topic/shutdown_warning
	key = "lowpop_shutdown_warning"

/datum/world_topic/shutdown_warning/Run(list/input)
	. = ..()

	message_admins(SPAN_NOTICE("[input["source"]] ([input["addr"]]), WARNING, you have approximately 30 SECONDS before the server will be turned offline automaticaly due to lowpop (<a href='byond://?_src_=\ref[src];[HrefToken(forceGlobal = TRUE)];denyserverreboot=1'>DENY</a>)"))
	to_chat(world, SPAN_CENTERBOLD("Server will be turned offline in 30 SECONDS due to lowpop. Only admins can deny this action in this time frame."))

	statuscode = 200
	response = "Request Sended"

/datum/world_topic/shutdown_warning/Topic(href, href_list)
	if(href_list["denyserverreboot"])
		REDIS_PUBLISH("byond.round", "state" = "stop_auto_stop")
		to_chat(world, SPAN_CENTERBOLD("Shutdown canceled."))
