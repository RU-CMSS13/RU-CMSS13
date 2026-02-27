/datum/supply_packs/sentry_gun
	name = "UA 571-C Sentry Gun"
	contains = list(
        /obj/item/defenses/handheld/sentry,
	)
	cost = 60
	containertype = /obj/structure/closet/crate/supply
	containername = "UA 571-C Sentry Gun (x1)"
	group = "Weapons"

/datum/supply_packs/sentry_flamer
	name = "UA 42-F Sentry Flamer"
	contains = list(
        /obj/item/defenses/handheld/sentry/flamer,
	)
	cost = 80
	containertype = /obj/structure/closet/crate/supply
	containername = "UA 42-F Sentry Flamer (x1)"
	group = "Weapons"

/datum/supply_packs/tesla_coil
	name = "21S Tesla Coil"
	contains = list(
        /obj/item/defenses/handheld/tesla_coil,
	)
	cost = 60
	containertype = /obj/structure/closet/crate/supply
	containername = "21S Tesla Coil (x1)"
	group = "Weapons"

/datum/supply_packs/planted_flag
	name = "JIMA Planted Flag"
	contains = list(
        /obj/item/defenses/handheld/planted_flag,
	)
	cost = 40
	containertype = /obj/structure/closet/crate/supply
	containername = "JIMA Planted Flag (x1)"
	group = "Weapons"

/datum/supply_packs/mixed_sentry
	name = "Sentry mix, all in one"
	contains = list(
		/obj/item/defenses/handheld/sentry,
		/obj/item/defenses/handheld/sentry/flamer,
		/obj/item/defenses/handheld/tesla_coil,
        /obj/item/defenses/handheld/planted_flag,
	)
	cost = 200
	containertype = /obj/structure/closet/crate/supply
	containername = "JIMA Planted Flag (x1)\n21S Tesla Coil (x1)\nUA 42-F Sentry Flamer (x1)\nUA 571-C Sentry Gun (x1)"
	group = "Weapons"
