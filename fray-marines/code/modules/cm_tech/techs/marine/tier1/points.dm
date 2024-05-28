/datum/tech/repeatable/req_points
	name = "Requisition Budget Increase"
	icon_state = "budget_req"
	desc = "Distributes resources to requisitions for spending. (20000$)"

	announce_name = "ALMAYER SPECIAL ASSETS AUTHORIZED"
	announce_message = "Additional supply budget has been authorised for this operation."

	required_points = 5
	increase_per_purchase = 1

	flags = TREE_FLAG_MARINE
	tier = /datum/tier/one

	points_to_give = 200

/datum/tech/repeatable/dropship_points
	name = "Dropship Budget Increase"
	icon_state = "budget_ds"
	desc = "Distributes resources to the dropship fabricator."

	announce_name = "ALMAYER SPECIAL ASSETS AUTHORIZED"
	announce_message = "Additional dropship part fabricator points have been authorised for this operation."

	required_points = 5
	increase_per_purchase = 1

	flags = TREE_FLAG_MARINE
	tier = /datum/tier/one

	points_to_give = 5000

/datum/tech/repeatable/dropship_points/on_unlock()
	. = ..()
	GLOB.supply_controller.dropship_points += points_to_give
