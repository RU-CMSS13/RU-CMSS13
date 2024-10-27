//ASRS

/datum/supply_packs_asrs/ammo_mortar_cluster
	reference_package = /datum/supply_packs/ammo_mortar_cluster

//largecrate_supplies
/obj/structure/largecrate/supply/explosives/mortar_cluster
	name = "80mm cluster mortar shell case (x25)"
	desc = "A case containing twenty five 80mm cluster mortar shells."
	supplies = list(/obj/item/mortar_shell/cluster = 25)

//mortar_shell

/obj/item/mortar_shell/cluster
	name = "\improper 80mm cluster mortar shell"
	desc = "An 80mm mortar shell, loaded with cluster munitions."
	icon = 'core_ru/icons/obj/structures/mortar.dmi'
	icon_state = "mortar_ammo_cluster"

	var/total_amount = 8
	var/instant_amount = 3

/obj/item/mortar_shell/cluster/detonate(turf/target)
	start_cluster(target)

/obj/item/mortar_shell/cluster/proc/start_cluster(turf/target)
	set waitfor = 0

	var/range_num = 7
	var/list/turf_list = list()

	for(var/turf/possible_turfs in RANGE_TURFS(range_num, target))
		if(protected_by_pylon(TURF_PROTECTION_MORTAR, possible_turfs))
			continue
		turf_list += possible_turfs

	for(var/i = 1 to total_amount)
		for(var/k = 1 to instant_amount)
			cell_explosion(pick(turf_list), 100, 75, EXPLOSION_FALLOFF_SHAPE_LINEAR, null, cause_data)
		sleep(5)

//mortar

/datum/supply_packs/ammo_mortar_cluster
	name = "M402 mortar shells crate (x6 Cluster)"
	cost = 20
	contains = list(
		/obj/item/mortar_shell/cluster,
		/obj/item/mortar_shell/cluster,
		/obj/item/mortar_shell/cluster,
		/obj/item/mortar_shell/cluster,
		/obj/item/mortar_shell/cluster,
		/obj/item/mortar_shell/cluster,
	)
	containertype = /obj/structure/closet/crate/secure/mortar_ammo
	containername = "\improper M402 mortar cluster shells crate"
	group = "Mortar"

