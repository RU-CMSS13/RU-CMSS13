/obj/structure/closet/secure_closet/marshal/alt
	icon = 'code_ru/icons/obj/structures/closet.dmi'
	icon_state = "secure_alt_locked_warrant"
	icon_closed = "secure_alt_unlocked_warrant"
	icon_locked = "secure_alt_locked_warrant"
	icon_opened = "secure_alt_open_warrant"
	icon_broken = "secure_alt_locked_warrant"
	icon_off = "secure_alt_closed_warrant"


/obj/structure/closet/secure_closet/marshal/alt/Initialize()
	. = ..()
	new /obj/item/clothing/suit/storage/CMB(src)
	new /obj/item/clothing/under/marine(src)
	new /obj/item/storage/backpack/security(src)
	new /obj/item/storage/belt/security(src)
	new /obj/item/clothing/shoes/jackboots(src)

