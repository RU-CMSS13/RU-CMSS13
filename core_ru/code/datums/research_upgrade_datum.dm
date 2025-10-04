/datum/research_upgrades/item/nanosplints
	name = "Reinforced Fiber Splints"
	desc = "A set of splints made from durable carbon fiber sheets reinforced with flexible titanium lattice, comes in a stack of five."
	value_upgrade = 800
	clearance_req = 3
	change_purchase = -100
	minimum_price = 400
	behavior = RESEARCH_UPGRADE_ITEM
	upgrade_type = ITEM_ACCESSORY_UPGRADE

/datum/research_upgrades/item/advbruise
	name = "Advanced Bruise Pack"
	desc = "Advanced Bruise Pack, heal brute damage more efficent."
	value_upgrade = 1000
	clearance_req = 3
	change_purchase = -100
	minimum_price = 400
	behavior = RESEARCH_UPGRADE_ITEM
	upgrade_type = ITEM_ACCESSORY_UPGRADE

/datum/research_upgrades/item/advbruise/on_purchase(turf/machine_loc)
	new /obj/item/stack/medical/advanced/bruise_pack/upgraded(machine_loc, 10)//adjust this to change amount of bruise packs in a stack

/datum/research_upgrades/item/advointment
	name = "Advanced Burn Kit"
	desc = "Advanced Burn Kit, heal burn damage more efficent."
	value_upgrade = 1000
	clearance_req = 3
	change_purchase = -100
	minimum_price = 400
	behavior = RESEARCH_UPGRADE_ITEM
	upgrade_type = ITEM_ACCESSORY_UPGRADE

/datum/research_upgrades/item/advointment/on_purchase(turf/machine_loc)
	new /obj/item/stack/medical/advanced/ointment/upgraded(machine_loc, 10)//adjust this to change amount of burn kits in a stack

/datum/research_upgrades/item/advdefib
	name = "Advanced Defibrillator"
	desc = "Defibrillator with safe, and high-power mode, ignore worn armor"
	value_upgrade = 3000
	clearance_req = 5
	behavior = RESEARCH_UPGRADE_ITEM
	upgrade_type = ITEM_ACCESSORY_UPGRADE
	item_reference = /obj/item/device/defibrillator/upgraded

/datum/research_upgrades/item/advinjector
	name = "Advanced Emergency Injector"
	desc = "Injector with improved cocktail of chemicals"
	value_upgrade = 500
	clearance_req = 1
	behavior = RESEARCH_UPGRADE_ITEM
	upgrade_type = ITEM_ACCESSORY_UPGRADE
	change_purchase = -50
	minimum_price = 300
	item_reference = /obj/item/reagent_container/hypospray/autoinjector/emergency/advanced

/datum/research_upgrades/armor/metal
	name = "Metal Armor Plate"
	desc = "Plate against sharp things, have a large durability and can be restored by same plate."
	value_upgrade = 500
	clearance_req = 3
	behavior = RESEARCH_UPGRADE_ITEM
	upgrade_type = ITEM_ARMOR_UPGRADE
	change_purchase = -50
	minimum_price = 300
	item_reference = /obj/item/clothing/accessory/health

/datum/research_upgrades/armor/ceramic
	clearance_req = 3

/datum/research_upgrades/item/research_credits
	name = "Research Credits"
	desc = "Sell the data acquired to the nearest Weyland-Yutani Science division team for 4 or 5 points."
	value_upgrade = 3000
	behavior = RESEARCH_UPGRADE_ITEM
	upgrade_type = ITEM_ACCESSORY_UPGRADE
	item_reference = /obj/item/research_upgrades/credits/small
	change_purchase = 500
	maximum_price = 15000
	clearance_req = 1

/datum/research_upgrades/item/toxic_ammo
	name = "Toxic ammo kit"
	desc = "Converts magazines into toxin ammo. Toxin ammo will poison your target, weakening their defences."
	value_upgrade = 2000
	behavior = RESEARCH_UPGRADE_ITEM
	upgrade_type = ITEM_ACCESSORY_UPGRADE
	change_purchase = -100
	minimum_price = 1000
	clearance_req = 4

/datum/research_upgrades/item/toxic_ammo/on_purchase(turf/machine_loc)
	new /obj/item/ammo_kit/toxin(machine_loc, 5)
