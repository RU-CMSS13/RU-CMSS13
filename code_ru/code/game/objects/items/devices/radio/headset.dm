/obj/item/device/radio/headset/almayer/mcom/synth
	name = "marine synth headset"
	desc = "Issued only to USCM synthetics. Channels are as follows: :v - marine command, :p - military police, :a - alpha squad, :b - bravo squad, :c - charlie squad, :d - delta squad, :n - engineering, :m - medbay, :u - requisitions, :j - JTAC,  :t - intel."
	icon_state = "ms_headset"
	initial_keys = list(/obj/item/device/encryptionkey/cmpcom/synth)
	minimap_type = /datum/action/minimap/marine/live

/obj/item/device/radio/headset/almayer/mcom/synth/equipped(mob/user, slot)
	. = ..()

	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user

	if(!H.assigned_equipment_preset)
		return

	if(!istype(H.assigned_equipment_preset, /datum/equipment_preset/synth) && (slot == WEAR_L_EAR || slot == WEAR_R_EAR))
		to_chat(user, SPAN_WARNING("This headset does not fit you."))
		H.temp_drop_inv_item(src)
		H.put_in_hands(src)
		return
