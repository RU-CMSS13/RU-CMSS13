//Boot Camp AREAS------------------------------------------------//
/area/BootCamp
	icon_state = "lv-626"
	can_build_special = TRUE
	powernet_name = "ground"
	ambience_exterior = AMBIENCE_JUNGLE
	minimap_color = MINIMAP_AREA_COLONY

/area/BootCamp/ground
	name = "Ground"
	ceiling = CEILING_NO_PROTECTION

/area/BootCamp/ground/boot_camp_outside
	icon_state = "Outside"
	name = "\improper Boot Camp street"

//Ворота в мир которого нет
/area/BootCamp/ground/Gate
	name = "\improper Gate"

//Палатки
/area/BootCamp/ground/marine_tents
	name = "\improper Marines Tents"
	icon_state = "red"

//Офис CEA
/area/BootCamp/ground/SEA_office
	name = "\improper SEA Office"
	icon_state = "green"

//Кухня
/area/BootCamp/ground/Kitchen
	name = "\improper Kitchen"
	icon_state = "green"

/area/BootCamp/ground/Cargobay
	name = "\improper Cargo"
	icon_state = "red"

/area/BootCamp/ground/Medbay
	name = "\improper Medbay"
	icon_state = "green"

//Посадочная площадка
/area/BootCamp/ground/landing_zone
	name = "\improper Boot Camp landing zone"
	icon_state = "green"
	ceiling = CEILING_METAL

//Стрелковый тир
/area/BootCamp/ground/shot_range
	name = "\improper Firearms range"
	icon_state = "blue"

//Миномётный тир
/area/BootCamp/ground/mortar
	name = "\improper Mortar range"
	icon_state = "blue"

//Инженерный
/area/BootCamp/ground/engi_room
	name = "\improper Boot Camp Engineering"
	icon_state = "yellow"

//Телекомуникации
/area/BootCamp/ground/tcomms
	name = "\improper Boot Camp Communications Relay"
	icon_state = "ass_line"
	ceiling = CEILING_UNDERGROUND_METAL_ALLOW_CAS
	is_resin_allowed = FALSE
	ceiling_muffle = FALSE
	base_muffle = MUFFLE_LOW
	always_unpowered = FALSE

//Вышка у инженерного
/area/BootCamp/ground/tcomms/tcommsite
	name = "\improper Telecomms Site Communications Relay"

//Вышка у карго
/area/BootCamp/ground/tcomms/tcommcargo
	name = "\improper Cargo Telecomms Communications Relay"

/area/BootCamp/ground/hangar
	icon_state = "hangar"
	name = "\improper Hangar"

/area/BootCamp/ground/tank_crew
	name = "\improper Tank crew cryo"
	icon_state = "cryo"

//Пещеры
/area/BootCamp/ground/caves
	name ="\improper Caves"
	icon_state = "cave"
	//ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen12.ogg','sound/ambience/ambisin4.ogg')
	ambience_exterior = AMBIENCE_CAVE
	soundscape_playlist = SCAPE_PL_CAVE
	soundscape_interval = 25
	ceiling = CEILING_NO_PROTECTION
	sound_environment = SOUND_ENVIRONMENT_AUDITORIUM
	minimap_color = MINIMAP_AREA_CAVES

