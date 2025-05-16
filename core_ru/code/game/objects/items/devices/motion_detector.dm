/*
/obj/item/device/motiondetector/integrated
	name = "integrated motion detector"
	desc = "A motion sensing component from another device."

/obj/item/device/motiondetector/integrated/get_user()
	var/atom/A = loc
	if(ishuman(A.loc))
		return A.loc
*/
