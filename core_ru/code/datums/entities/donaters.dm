GLOBAL_LIST_EMPTY(discord_ranks)
GLOBAL_LIST_EMPTY_TYPED(donators_info, /datum/donator_info)

GLOBAL_LIST_INIT_TYPED(all_gun_decorators, /datum/decorator/weapon_map_decorator, create_decorators())

/proc/create_decorators()
	. = list()
	for(var/decorator_type in subtypesof(/datum/decorator/weapon_map_decorator))
		. += new decorator_type

/datum/entity/player
	var/datum/donator_info/donator_info

/datum/entity/discord_rank
	var/rank_id
	var/rank_name
	var/functions
	var/role_id
	var/list/buns = list()

BSQL_PROTECT_DATUM(/datum/entity/discord_rank)

/datum/entity_meta/discord_rank
	entity_type = /datum/entity/discord_rank
	table_name = "discord_ranks"
	field_types = list(
		"rank_id" = DB_FIELDTYPE_INT,
		"rank_name" = DB_FIELDTYPE_STRING_LARGE,
		"functions" = DB_FIELDTYPE_STRING_MAX,
		"role_id" = DB_FIELDTYPE_STRING_LARGE,
	)

/datum/entity_meta/discord_rank/map(datum/entity/discord_rank/rank, list/values)
	..()
	if(values["functions"])
		rank.buns = json_decode(values["functions"])

/datum/entity_meta/discord_rank/unmap(datum/entity/discord_rank/rank)
	. = ..()
	if(length(rank.buns))
		.["functions"] = json_encode(rank.buns)

/datum/view_record/discord_rank
	var/rank_id
	var/rank_name
	var/functions
	var/role_id
	var/list/buns = list()

/datum/entity_view_meta/discord_rank
	root_record_type = /datum/entity/discord_rank
	destination_entity = /datum/view_record/discord_rank
	fields = list(
		"rank_id",
		"rank_name",
		"functions",
		"role_id",
	)
	order_by = list("rank_id" = DB_ORDER_BY_ASC)

/datum/entity_view_meta/discord_rank/map(datum/view_record/discord_rank/rank, list/values)
	..()
	if(values["functions"])
		rank.buns = json_decode(values["functions"])

/datum/entity/skin
	var/player_id
	var/skin_name
	var/skins_db
	var/list/skin = list()

BSQL_PROTECT_DATUM(/datum/entity/skin)

/datum/entity_meta/skin
	entity_type = /datum/entity/skin
	table_name = "players_skins"
	field_types = list(
		"player_id" = DB_FIELDTYPE_BIGINT,
		"skin_name" = DB_FIELDTYPE_STRING_LARGE,
		"skins_db" = DB_FIELDTYPE_STRING_MAX,
	)

/datum/entity_meta/skin/map(datum/entity/skin/skin, list/values)
	..()
	if(values["skins_db"])
		skin.skin = json_decode(values["skins_db"])

/datum/entity_meta/skin/unmap(datum/entity/skin/skin)
	. = ..()
	if(length(skin.skin))
		.["skins_db"] = json_encode(skin.skin)

/datum/donator_info
	var/datum/entity/player/player_datum
	var/list/skins = list()
	var/list/skins_used = list()

/datum/donator_info/New(datum/entity/player/owner_datum)
	player_datum = owner_datum
	load_info()

/datum/donator_info/proc/load_info()
	DB_FILTER(/datum/entity/skin, DB_COMP("player_id", DB_EQUALS, player_datum.id), CALLBACK(src, TYPE_PROC_REF(/datum/donator_info, load_skins)))
	if(patreon_function_available("ooc_color"))
		GLOB.donaters |= player_datum.owning_client
		add_verb(player_datum.owning_client, /client/proc/set_ooc_color_self)

/datum/donator_info/proc/load_skins(list/datum/entity/skin/entity_skins)
	for(var/datum/entity/skin/skin in entity_skins)
		skins[skin.skin_name] = skin

/datum/donator_info/proc/patreon_function_available(required)
	if(player_datum?.discord_link)
		var/datum/view_record/discord_rank/discord_rank = GLOB.discord_ranks["[player_datum.discord_link.role_rank]"]
		if(discord_rank)
			return discord_rank.buns[required]
	return FALSE

/obj/structure/painting_table
	name = "\improper Painting Table"
	desc = "Can repaint equipment."
	icon = 'core_ru/icons/obj/structures/workbenches.dmi'
	icon_state = "paint_bench"
	unacidable = TRUE
	density = TRUE
	anchored = TRUE
	bound_width = 64
	bound_height = 32

/obj/structure/painting_table/attackby(obj/item/item as obj, mob/user as mob)
	if(user?.client?.player_data?.donator_info)
		if(user.client.player_data.donator_info.skins["[item.type]"] && !user.client.player_data.donator_info.skins_used["[item.type]"])
			handle_skinning(item, user)
			return
/* OOD, upstream messed around so need fix
	if(handle_decorator_override(item, user))
		return
*/
	. = ..()

/proc/handle_skinning(obj/item, mob/user)
	var/datum/entity/skin/skin_selection = user.client.player_data.donator_info.skins["[item.type]"]
	if(!skin_selection)
		return
	var/list/skins_choice = list()
	for(var/i in skin_selection.skin)
		skins_choice += skin_selection.skin[i]
	var/skin = tgui_input_list(usr, "Select skin, you can only one time use it for round (cancel for selecting normal one)", "Skin Selector", skins_choice)
	if(!skin)
		to_chat(user, SPAN_WARNING("Vending base skin."))
		return

	user.client.player_data.donator_info.skins_used["[item.type]"] = skin_selection
	item.flags_atom |= ATOM_DECORATED
	item.skin(skin)
	return TRUE

//COMPACT VERSION << ALL IN ONE >>
/obj/proc/skin(S)
	return

/obj/CanProcCall(procname)
	if(procname == "skin")
		return FALSE
	. = ..()

//HELMET
/obj/item/clothing/head/helmet/skin(skin)
	icon = 'core_ru/icons/custom/items/clothings.dmi'
	icon_state = "[icon_state]_[skin]"
	item_state = "[item_state]_[skin]"
	item_icons = list(
		WEAR_HEAD = 'core_ru/icons/custom/items/clothing_on_mob.dmi'
	)

/obj/item/clothing/head/helmet/vv_edit_var(var_name, new_value)
	var/static/list/banned_edits = list(NAMEOF_STATIC(src, icon_state), NAMEOF_STATIC(src, item_state))
	if(var_name in banned_edits)
		return FALSE
	. = ..()

//STORAGE
/obj/item/clothing/suit/storage/marine/skin(skin)
	icon = 'core_ru/icons/custom/items/clothings.dmi'
	icon_state = "[icon_state]_[skin]"
	item_state = "[item_state]_[skin]"
	item_state_slots[WEAR_BODY] = icon_state

/obj/item/clothing/suit/storage/marine/vv_edit_var(var_name, new_value)
	var/static/list/banned_edits = list(NAMEOF_STATIC(src, icon_state), NAMEOF_STATIC(src, item_state))
	if(var_name in banned_edits)
		return FALSE
	. = ..()

//UNDER
/obj/item/clothing/under/skin(skin)
	icon = 'core_ru/icons/custom/items/clothings.dmi'
	icon_state += "_[skin]"
	worn_state = icon_state

	item_icons = list(WEAR_BODY = 'core_ru/icons/custom/items/clothing_on_mob.dmi')

	icon_override = 'core_ru/icons/custom/items/clothings.dmi'

	item_state_slots[WEAR_BODY] = worn_state
	update_rollsuit_status()

/obj/item/clothing/under/vv_edit_var(var_name, new_value)
	var/static/list/banned_edits = list(NAMEOF_STATIC(src, icon_state))
	if(var_name in banned_edits)
		return FALSE
	. = ..()

//GUNS
/obj/item/weapon/gun/skin(skin)
	base_gun_icon = "[base_gun_icon]_[skin]"
	icon = 'core_ru/icons/custom/items/guns.dmi'

	item_icons = list(
		WEAR_L_HAND = 'core_ru/icons/custom/items/items_lefthand_1.dmi',
		WEAR_R_HAND = 'core_ru/icons/custom/items/items_righthand_1.dmi',
		WEAR_BACK = 'core_ru/icons/custom/items/back.dmi',
		WEAR_J_STORE = 'core_ru/icons/custom/items/suit_slot.dmi'
		)

	item_state = "[base_gun_icon]"

	LAZYSET(item_state_slots, WEAR_BACK, item_state)

//	var/icon/I = new /icon('core_ru/icons/custom/items/attach_recoloring.dmi', skin)
//	attachment_recoloring = image(I)
//	attachment_recoloring.alpha = 180
//	attachment_recoloring.blend_mode = BLEND_ADD|BLEND_INSET_OVERLAY|BLEND_SUBTRACT
	update_icon()
