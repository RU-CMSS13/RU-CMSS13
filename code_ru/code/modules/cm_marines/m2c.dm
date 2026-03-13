/obj/structure/blocker/anti_cade/mounted
	var/obj/structure/machinery/mounted_defence/to_block = null

/obj/structure/blocker/anti_cade/mounted/Destroy()
	if(to_block)
		to_block.cadeblockers.Remove(src)
		to_block = null

	return ..()
