/obj/item/storage/box/kit/ppo
	name = "\improper Corporate Bodyguard Standart Kit"
	pro_case_overlay = "defense"

/obj/item/storage/box/kit/ppo/fill_preset_inventory()
	new /obj/item/pamphlet/skill/ppo(src)
	new /obj/item/pamphlet/skill/ppo/command(src)
	new /obj/item/weapon/shield/riot/metal(src)
	new /obj/item/clothing/accessory/health/ceramic_plate(src)
	new /obj/item/clothing/accessory/health(src)
	new /obj/item/storage/pouch/magazine/large/wy(src)
	new /obj/item/weapon/gun/energy/rxfm5_eva(src)
	new /obj/item/explosive/grenade/custom/teargas(src)
	new /obj/item/explosive/grenade/custom/teargas(src)

/obj/item/storage/box/kit/ppo/engi
	name = "\improper Corporate Bodyguard Technician Kit"
	pro_case_overlay = "engi"

/obj/item/storage/box/kit/ppo/engi/fill_preset_inventory()
	new /obj/item/pamphlet/skill/engineer/ppo(src)
	new /obj/item/device/helmet_visor/welding_visor(src)
	new /obj/item/storage/belt/utility/full(src)
	new /obj/item/storage/pouch/construction/full/wy(src)
	new /obj/item/storage/backpack/marine/engineerpack/ert/four_slot(src)
	new /obj/item/defenses/handheld/sentry/wy/mini(src)

/obj/item/storage/box/kit/ppo/medic
	name = "\improper Corporate Bodyguard Medic Kit"
	pro_case_overlay = "medic"

/obj/item/storage/box/kit/ppo/medic/fill_preset_inventory()
	new /obj/item/pamphlet/skill/medical/ppo(src)
	new /obj/item/storage/belt/medical/full/with_suture_and_graft(src)
	new	/obj/item/device/healthanalyzer(src)
	new /obj/item/storage/surgical_case/regular(src)
	new /obj/item/clothing/glasses/hud/health(src)
	new	/obj/item/device/defibrillator/compact(src)
	new /obj/item/roller(src)
