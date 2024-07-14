//  Мультибурст

/obj/item/clothing/mask/facehugger/proc/get_impregnation_amount(mob/living/carbon/target)

	var/impregnation_amount

	if(!ishuman(target))
		impregnation_amount = 1
	else
		switch(GLOB.xeno_multiburst)
			if(1)
				impregnation_amount = 1
			if(2)
				impregnation_amount = pick(
					prob(67); 1,
					prob(33); 2,
				)
			if(3)
				impregnation_amount = pick(
					prob(30); 1,
					prob(60); 2,
					prob(10); 3,
				)
			if(4)
				impregnation_amount = pick(
					prob(60); 2,
					prob(30); 3,
					prob(10); 4,
				)
			if(5)
				impregnation_amount = 5
	return impregnation_amount
