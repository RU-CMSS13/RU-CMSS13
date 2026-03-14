/obj/item/device/cassette_tape/hotline
	name = "Hotline cassette"
	id = 19
	desc = "A cassette with some \"chicken\"?."
	icon_state = "cassette_hotline"
	side1_icon = "cassette_hotline"
	songs = list(
		"side1" = list(
			"code_ru/sound/music/walkman/Hotline-A-New-Morning.ogg",
			"code_ru/sound/music/walkman/Hotline-Crystals.ogg",
			"code_ru/sound/music/walkman/Hotline-Daisuke.ogg",
			"code_ru/sound/music/walkman/Hotline-Hydrogen.ogg",
			"code_ru/sound/music/walkman/Hotline-It_s-Safe-Now.ogg"
		),
		"side2" = list(
			"code_ru/sound/music/walkman/Hotline-Miami.ogg",
			"code_ru/sound/music/walkman/Hotline-Musik.ogg",
			"code_ru/sound/music/walkman/Hotline-Paris.ogg",
			"code_ru/sound/music/walkman/Hotline-Perturbator.ogg"
		)
	)

/obj/item/device/cassette_tape/puma
	name = "Puma cassette" // Пума, ты мой любимый пупсик <З
	id = 20
	desc = "Very familiar..."
	icon_state = "cassette_puma"
	side1_icon = "cassette_puma"
	songs = list(
		"side1" = list(
			"code_ru/sound/music/walkman/Louie,-Louie.ogg",
			"code_ru/sound/music/walkman/These-Boots-Are-Made-For-Walkin.ogg"
		),
		"side2" = list(
			"code_ru/sound/music/walkman/Venus.ogg",
			"code_ru/sound/music/walkman/Wooly-Bully.ogg"
		)
	)

/obj/item/device/cassette_tape/duck
	name = "Duck cassette"
	id = 21
	desc = "Quack-quack!"
	icon = 'code_ru/icons/obj/items/walkman/cassette.dmi'
	icon_state = "cassette_duck"
	side1_icon = "cassette_duck"
	songs = list(
		"side1" = list(
			"code_ru/sound/music/walkman/ANTAG-TYPE-BEAT.ogg",
			"code_ru/sound/music/walkman/HONK.ogg",
			"code_ru/sound/music/walkman/Sudden Changes.ogg",
		),
		"side2" = list(
			"code_ru/sound/music/walkman/Helltaker-Take-me.ogg",
			"code_ru/sound/music/walkman/The-Fate-of-Sickle.ogg",
		)
	)

/obj/item/device/cassette_tape/hotline/attack_self(mob/user)
	..()
	if(flipped)
		icon_state = "cassette_hotline_flip"
	else
		icon_state = "cassette_hotline"
	update_icon()

/obj/item/device/cassette_tape/puma/attack_self(mob/user)
	..()
	if(flipped)
		icon_state = "cassette_puma_flip"
	else
		icon_state = "cassette_puma"
	update_icon()

/obj/item/device/cassette_tape/duck/attack_self(mob/user)
	..()
	if(flipped)
		icon_state = "cassette_duck_flip"
	else
		icon_state = "cassette_duck"
	update_icon()
