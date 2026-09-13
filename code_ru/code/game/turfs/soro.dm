//Turf for LV624 Lazarus Landing - by Arom-beep

/turf/open/gm/brown_dirt/random_rocks
	icon = 'code_ru/icons/turf/floors/auto_lv_turf.dmi'
	icon_state = "sand_1_1_N"


/turf/open/gm/brown_dirt/random_rocks/New()
		..()
		icon_state = pick("sand_1_1_N", "sand_1_1_NE", "sand_1_1_E", "sand_1_1_SE", "sand_1_1_S", "sand_1_1_SW", "sand_1_1_W", "sand_1_1_NW")
		dir = null


/turf/open/gm/brown_dirt/random_rocks_alt
	icon = 'code_ru/icons/turf/floors/auto_lv_turf.dmi'
	icon_state = "sand_1_2_N"


/turf/open/gm/brown_dirt/random_rocks_alt/New()
		..()
		icon_state = pick("sand_1_2_N", "sand_1_2_NE", "sand_1_2_E", "sand_1_2_SE", "sand_1_2_S", "sand_1_2_SW", "sand_1_2_W", "sand_1_2_NW")
		dir = null

