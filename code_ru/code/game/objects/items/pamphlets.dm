/obj/item/pamphlet/skill/medical/ppo
	name = "corporate medical instructional pamphlet"
	desc = "A pamphlet used to quickly impart vital knowledge. This one has a medical insignia."
	icon_state = "pamphlet_medical"
	trait = /datum/character_trait/skills/medical/ppo
	bypass_pamphlet_limit = TRUE

/obj/item/pamphlet/skill/engineer/ppo
	name = "corporate engineer instructional pamphlet"
	desc = "A pamphlet used to quickly impart vital knowledge. This one has an engineering insignia."
	icon_state = "pamphlet_construction"
	trait = /datum/character_trait/skills/engineering/ppo
	bypass_pamphlet_limit = TRUE

/obj/item/pamphlet/skill/ppo
	name = "corporate combat instructional pamphlet"
	desc = "A pamphlet used to quickly impart vital knowledge."
	icon_state = "pamphlet_written"
	trait = /datum/character_trait/skills/ppo
	bypass_pamphlet_limit = TRUE

/obj/item/pamphlet/skill/ppo/command
	name = "corporate commanding instructional pamphlet"
	desc = "A pamphlet used to quickly impart vital knowledge."
	icon_state = "pamphlet_reading"
	trait = /datum/character_trait/skills/ppo/command
	bypass_pamphlet_limit = TRUE

/obj/item/pamphlet/skill/minimed
	name = "Advance medical instructional pamphlet"
	desc = "A pamphlet used to quickly impart vital knowledge. This one has a medical insignia."
	icon_state = "pamphlet_medical"
	trait = /datum/character_trait/skills/minimed

/obj/item/pamphlet/skill/minimed/can_use(mob/living/carbon/human/user)
	if((user.job != JOB_SQUAD_MARINE) && (user.job != JOB_SQUAD_LEADER))
		to_chat(user, SPAN_WARNING("Only squad riflemen or squad leader can use this."))
		return FALSE
	return ..()
