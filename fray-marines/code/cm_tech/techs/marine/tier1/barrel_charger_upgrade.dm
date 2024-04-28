/datum/tech/droppod/item/barrel
	name = "Upgraded barrel charger modification"
	desc = "Gives marines powerful modification UPC for M41"
	icon_state = "medic_qol"
	droppod_name = "UPC Modification"

	flags = TREE_FLAG_MARINE

	required_points = 15
	tier = /datum/tier/one/additional

	droppod_input_message = "Choose a deployable to retrieve from the droppod."

/datum/tech/droppod/item/barrel/get_options(mob/living/carbon/human/H, obj/structure/droppod/D)
	. = ..()

	.["Upgrade Barrel Charger"] = /obj/item/attachable/heavy_barrel
