/obj/item/reagent_container/hypospray/autoinjector/emergency/advanced
	name = "advanced emergency autoinjector (CAUTION)"
	desc = "An auto-injector loaded with a special cocktail of basic and enchanced chemicals, to be used in life-threatening situations. Doesn't require any training to use."
	icon_state = "adv_emergency"
	chemname = "emergency"
	amount_per_transfer_from_this = (REAGENTS_OVERDOSE-1)*4 + (MED_REAGENTS_OVERDOSE-1) + (LOWH_REAGENTS_OVERDOSE-1) * 5
	volume = (REAGENTS_OVERDOSE-1)*4 + (MED_REAGENTS_OVERDOSE-1) + (LOWH_REAGENTS_OVERDOSE-1) * 3
	mixed_chem = TRUE
	uses_left = 1
	injectSFX = 'sound/items/air_release.ogg'
	injectVOL = 70//limited-supply emergency injector with v.large injection of drugs. Variable sfx freq sometimes rolls too quiet.
	display_maptext = TRUE //see anaesthetic injector
	maptext_label = "!!!"
	skilllock = SKILL_MEDICAL_TRAINED

/obj/item/reagent_container/hypospray/autoinjector/emergency/advanced/Initialize()
	. = ..()
	reagents.add_reagent("tricordrazine", REAGENTS_OVERDOSE-1)
	reagents.add_reagent("anti_toxin", REAGENTS_OVERDOSE-1)
	reagents.add_reagent("arithrazine", LOWH_REAGENTS_OVERDOSE-1)
	reagents.add_reagent("meralyne", LOWH_REAGENTS_OVERDOSE-1)
	reagents.add_reagent("dermaline", LOWH_REAGENTS_OVERDOSE-1)
	reagents.add_reagent("peridaxon", LOWH_REAGENTS_OVERDOSE-1)
	reagents.add_reagent("dexalinp", LOWH_REAGENTS_OVERDOSE-1)
	update_icon()

// TODO: Make OD restriction and injection adjust
