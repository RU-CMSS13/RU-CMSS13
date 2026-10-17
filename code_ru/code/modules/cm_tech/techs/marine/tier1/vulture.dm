/datum/tech/vulture
    name = "M707 Anti-Materiel Rifle kit"
    desc = "Anti-Materiel Rifle kit, for using against heavy targets."
    icon_state = "weapon"

    announce_message = "M707 Anti-Materiel Rifle kit has been delivered to Requisitions' ASRS."

    tier = /datum/tier/one
    required_points = 5
    flags = TREE_FLAG_MARINE

    var/purchased = FALSE

/datum/tech/vulture/on_unlock()
	. = ..()

	var/datum/supply_order/new_order = new()
	new_order.ordernum = GLOB.supply_controller.ordernum++
	var/actual_type = GLOB.supply_packs_types["M707 Anti-Materiel Rifle crate"]
	new_order.objects = list(GLOB.supply_packs_datums[actual_type])
	new_order.orderedby = MAIN_AI_SYSTEM
	new_order.approvedby = MAIN_AI_SYSTEM

	GLOB.supply_controller.shoppinglist += new_order

