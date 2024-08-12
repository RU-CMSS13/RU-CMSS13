//returns time diff of two times normalized to time_rate_multiplier
/proc/daytimeDiff(timeA, timeB)
	var/time_diff = timeA > timeB ? (timeB + 1) - timeA : timeB - timeA
	return time_diff

/proc/game_time()
	return REALTIMEOFDAY % 864000

/proc/game_time_timestamp(format = "hh:mm:ss")
	return time2text(game_time(), format)

/proc/planet_game_time_timestamp(format = "hh:mm:ss")
	return time2text(SSsunlighting.game_time_offseted() - GLOB.timezoneOffset, format)
