/obj/vehicle/walker/Collide(atom/A)
	if(A && !QDELETED(A))
		A.last_bumped = world.time
		A.Collided(src)
	return A.handle_vehicle_bump(src)
