/obj/structure/machinery/defenses/sentry/flamer/plasma
	name = "UA 60-FP Plasma Sentry"
	defense_type = "Plasma"
	ammo = new /obj/item/ammo_magazine/sentry_flamer/glob
	health = 150
	health_max = 150
	fire_delay = 7 SECONDS
	sentry_range = FLAMER_SENTRY_SNIPER_RANGE
	handheld_type = /obj/item/defenses/handheld/sentry/flamer/plasma
	disassemble_time = 1.5 SECONDS

/obj/structure/machinery/defenses/sentry/flamer/plasma/set_range()
	switch(dir)
		if(EAST)
			range_bounds = SQUARE(x + (FLAMER_SENTRY_SNIPER_RANGE/2), y, FLAMER_SENTRY_SNIPER_RANGE)
		if(WEST)
			range_bounds = SQUARE(x - (FLAMER_SENTRY_SNIPER_RANGE/2), y, FLAMER_SENTRY_SNIPER_RANGE)
		if(NORTH)
			range_bounds = SQUARE(x, y + (FLAMER_SENTRY_SNIPER_RANGE/2), FLAMER_SENTRY_SNIPER_RANGE)
		if(SOUTH)
			range_bounds = SQUARE(x, y - (FLAMER_SENTRY_SNIPER_RANGE/2), FLAMER_SENTRY_SNIPER_RANGE)

#undef FLAMER_SENTRY_SNIPER_RANGE
