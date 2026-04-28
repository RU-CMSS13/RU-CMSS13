/obj/item/device/cassette_tape/milkline
	name = "milkline cassette"
	id = 19
	desc = "A cassette with some \"milk\"? heh... Sounds funny."
	icon = 'code_ru/icons/obj/items/walkman/cassette.dmi'
	icon_state = "cassette_milkline"
	side1_icon = "cassette_milkline"
	item_icons = list(
		WEAR_AS_GARB = 'icons/obj/items/walkman.dmi' // временная мера, чтобы не было ошибок или варнингов
	)
	songs = list("side1" = list("sound/music/walkman/Cool_sound1.ogg",\
								"sound/music/walkman/Cool_sound2.ogg",\
								"sound/music/walkman/Cool_sound3.ogg",\
								"sound/music/walkman/Cool_sound4.ogg",\
								"sound/music/walkman/Cool_sound5.ogg"),\
				"side2" = list(
								"sound/music/walkman/Cool_sound1-1.ogg",\
								"sound/music/walkman/Cool_sound1-2.ogg",\
								"sound/music/walkman/Cool_sound1-3.ogg",\
								"sound/music/walkman/Cool_sound1-4.ogg"))

/obj/item/device/cassette_tape/puma
	name = "Puma cassette" // Пума, ты мой любимый пупсик <З
	id = 20
	desc = "Very familiar..."
	icon = 'code_ru/icons/obj/items/walkman/cassette.dmi'
	icon_state = "cassette_puma"
	side1_icon = "cassette_puma"
	item_icons = list(
		WEAR_AS_GARB = 'icons/obj/items/walkman.dmi'
	)
	songs = list("side1" = list("sound/music/walkman/Old_cool_sound1.ogg",\
								"sound/music/walkman/Old_cool_sound2.ogg"),\
				"side2" = list("sound/music/walkman/Old_cool_sound1-1.ogg",\
								"sound/music/walkman/Old_cool_sound1-2.ogg",))

/obj/item/device/cassette_tape/duck
	name = "Duck cassette"
	id = 21
	desc = "Quack-quack!"
	icon = 'code_ru/icons/obj/items/walkman/cassette.dmi'
	icon_state = "cassette_duck"
	side1_icon = "cassette_duck"
	item_icons = list(
		WEAR_AS_GARB = 'icons/obj/items/walkman.dmi'
	)
	songs = list("side1" = list("sound/music/walkman/Fire_cool_sound1.ogg",\
								"sound/music/walkman/Fire_cool_sound2.ogg",\
								"sound/music/walkman/Fire_cool_sound3.ogg"),\
				"side2" = list("sound/music/walkman/Fire_cool_sound1-1.ogg",
								"sound/music/walkman/Fire_cool_sound1-2.ogg",))
