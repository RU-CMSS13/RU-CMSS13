/area/skyscraper
	name = "skyscraper"
	icon = 'icons/turf/area_sky_scraper.dmi'
	can_build_special = FALSE //T-Comms structure
	flags_area = AREA_NOTUNNEL
	soundscape_playlist = list('sound/effects/wind/wind_2_1.ogg', 'sound/effects/wind/wind_2_2.ogg', 'sound/effects/wind/wind_3_1.ogg', 'sound/effects/wind/wind_4_1.ogg',  'sound/effects/wind/wind_4_2.ogg', 'sound/effects/wind/wind_5_1.ogg')
	sound_environment = SOUND_ENVIRONMENT_CITY
	powernet_name = "ground"

/area/skyscraper/out
	name = "Planet"
	icon_state = "oob"
	static_lighting = FALSE

/area/skyscraper/building
	name = "W-Y 'Almea'"
	icon_state = "sky_scraper"
	temperature = 308.7 //kelvin, 35c, 95f

/area/skyscraper/building/landing_zone
	name = "W-Y 'Almea' Landing Zone"
	icon_state = "lz_pad"
	can_build_special = TRUE
	is_resin_allowed = FALSE
	is_landing_zone = TRUE

/area/skyscraper/building/landing_zone/console
	requires_power = FALSE

/area/skyscraper/building/engineering
	name = "W-Y 'Almea' Engineering"

/area/skyscraper/building/landing_zone/one
	name = "W-Y 'Almea' Landing Zone One"

/area/skyscraper/building/landing_zone/console/one
	name = "LZ1 'Sky'"

/area/skyscraper/building/agro_sector
	name = "W-Y 'Almea' Agro Sector"

/area/skyscraper/building/eco_emulation_sector
	name = "W-Y 'Almea' Eco Emulation Sector"

/area/skyscraper/building/internal_cargo_sector
	name = "W-Y 'Almea' Eco Emulation Sector"

/area/skyscraper/building/morgue_sector
	name = "W-Y 'Almea' Morgue Sector"

/area/skyscraper/building/building_in_progress_sector
	name = "W-Y 'Almea' Empty Sector"

/area/skyscraper/building/science_sector
	name = "W-Y 'Almea' Science Sector"

/area/skyscraper/building/cargo_sector
	name = "W-Y 'Almea' Cargo Sector"

/area/skyscraper/building/landing_zone/two
	name = "W-Y 'Almea' Landing Zone Two"

/area/skyscraper/building/landing_zone/console/two
	name = "LZ2 'Cargo'"

/area/skyscraper/building/landing_zone/cargo
	name = "W-Y 'Almea' Landing Zone Cargo"

/area/skyscraper/building/engineering/upper
	name = "W-Y 'Almea' Generatoro-Filtration"

/area/skyscraper/building/security_sector/blockpost
	name = "W-Y 'Almea' Security Sector Blockpost"

/area/skyscraper/building/security_sector
	name = "W-Y 'Almea' Security Sector"
