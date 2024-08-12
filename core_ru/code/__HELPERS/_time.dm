//returns time diff of two times normalized to time_rate_multiplier
/proc/daytimeDiff(timeA, timeB)
	var/time_diff = timeA > timeB ? (timeB + 1) - timeA : timeB - timeA
	return time_diff
