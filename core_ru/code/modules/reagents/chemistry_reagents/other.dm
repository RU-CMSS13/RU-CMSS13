/datum/reagent/napalm/plasmid
	name = "Plasmid"
	id = "napalmp"
	description = "Liquid plasma that penetrates through the best flame retardants."
	color = COLOR_PURPLE
	burncolor = COLOR_PURPLE
	burn_sprite = "dynamic"
	properties = list(
		PROPERTY_INTENSITY = BURN_LEVEL_TIER_3,
		PROPERTY_DURATION = BURN_TIME_TIER_3,
		PROPERTY_RADIUS = 6,
	)
	fire_type = FIRE_VARIANT_TYPE_B //Armor Shredding Greenfire
