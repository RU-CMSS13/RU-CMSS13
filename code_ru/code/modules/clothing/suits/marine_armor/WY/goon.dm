/obj/item/clothing/suit/storage/marine/veteran/pmc/light/corporate/ppo/strong
	icon_state = "ppo_armor_strong_ru"
	item_state = "ppo_armor_strong_ru"
	item_state_slots = list(WEAR_JACKET = "ppo_armor_strong_ru")

/obj/item/clothing/suit/storage/marine/veteran/pmc/light/corporate/ppo
	icon_state = "ppo_armor_ru"
	item_state = "ppo_armor_ru"
	item_state_slots = list(WEAR_JACKET = "ppo_armor_ru")

/obj/item/clothing/suit/storage/marine/veteran/pmc/light/corporate/ppo/strong/medium
	name = "\improper M4 pattern PPO armor"
	desc = "A modification of the standard Armat Systems M3 armor. This variant is worn by Personal Protection Officers protecting Weyland-Yutani employees, as denoted by the blue detailing."
	icon_state = "ppo_armor_strong_medium"
	item_state = "ppo_armor_strong_medium"
	item_state_slots = list(WEAR_JACKET = "ppo_armor_strong_medium")
	storage_slots = 2
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS
	flags_cold_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS
	flags_heat_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS

	armor_melee = CLOTHING_ARMOR_MEDIUM
	armor_bullet = CLOTHING_ARMOR_MEDIUM
	armor_energy = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_LOW
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_rad = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_MEDIUMLOW
	slowdown = SLOWDOWN_ARMOR_LIGHT

/obj/item/clothing/suit/storage/marine/veteran/pmc/light/corporate/ppo/strong/heavy
	name = "\improper M4 pattern PPO heavy armor"
	desc = "A modification of the standard Armat Systems M3 armor. This variant is worn by Personal Protection Officers protecting Weyland-Yutani employees, as denoted by the blue detailing. Has some armor plating added for extra protection."
	icon_state = "ppo_armor_strong_heavy"
	item_state = "ppo_armor_strong_heavy"
	item_state_slots = list(WEAR_JACKET = "ppo_armor_strong_heavy")
	storage_slots = 2
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS
	flags_cold_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS
	flags_heat_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS

	armor_melee = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bullet = CLOTHING_ARMOR_HIGHPLUS
	armor_energy = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bio = CLOTHING_ARMOR_MEDIUM
	armor_bomb = CLOTHING_ARMOR_HIGHPLUS
	armor_rad = CLOTHING_ARMOR_MEDIUMHIGH
	armor_internaldamage = CLOTHING_ARMOR_MEDIUMHIGH
	slowdown = SLOWDOWN_ARMOR_MEDIUM
