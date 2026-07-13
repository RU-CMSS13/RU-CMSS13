#define HUMAN_AI_HEALTHITEMS "health"
#define HUMAN_AI_AMMUNITION "ammo"
#define HUMAN_AI_GRENADES "grenades"
#define HUMAN_AI_TOOLS "tools"

#define ACTION_USING_HANDS (1<<0)
#define ACTION_USING_LEGS (1<<1)
#define ACTION_USING_MOUTH (1<<2)

/// Action is completed, delete this and move onto the next ongoing action
#define ONGOING_ACTION_COMPLETED "completed"
/// Action isn't finished, move onto the next ongoing action
#define ONGOING_ACTION_UNFINISHED "unfinished"
/// Action isn't finished, block any further actions from the AI this tick
#define ONGOING_ACTION_UNFINISHED_BLOCK "unfinished_block"

#define HUMAN_AI_MAX_PATHFINDING_RANGE 45

GLOBAL_LIST_EMPTY(ai_humans)

#define FACTION_MALF_SYNTH "Malfunctioning Synthetic"

// Human AI flags
/// This item is classified as a healing item for the sake of human AI
#define HEALING_ITEM (1<<0)
/// This item is classified as ammunition for the sake of human AI
#define AMMUNITION_ITEM (1<<1)
/// This item is classified as a grenade for the sake of human AI
#define GRENADE_ITEM (1<<2)
/// This item is classified as a tool for the sake of human AI
#define TOOL_ITEM (1<<3)
/// This item is classified as a melee weapon for the sake of human AI
#define MELEE_WEAPON_ITEM (1<<4)
/obj/item
	/// flags for human AI to determine what this item does
	var/flags_human_ai = NO_FLAGS

/obj/item/explosive/grenade
	flags_human_ai = GRENADE_ITEM

/obj/item/tool
	flags_human_ai = TOOL_ITEM

/obj/item/reagent_container/hypospray
	flags_human_ai = HEALING_ITEM

/obj/item/stack/cable_coil
	flags_human_ai = HEALING_ITEM

/obj/item/stack/medical
	flags_human_ai = HEALING_ITEM

/obj/item/stack/nanopaste
	flags_human_ai = HEALING_ITEM

/obj/item/storage/pill_bottle
	flags_human_ai = HEALING_ITEM

/obj/item/tool/weldingtool
	flags_human_ai = HEALING_ITEM

/obj/item/tool/kitchen/knife
	flags_human_ai = MELEE_WEAPON_ITEM | TOOL_ITEM

/obj/item/weapon/sword
	flags_human_ai = MELEE_WEAPON_ITEM

/obj/item/ammo_magazine
	flags_human_ai = AMMUNITION_ITEM

/obj/item/ammo_magazine/handful
	flags_human_ai = NO_FLAGS

/obj/item/attachable/bayonet
	flags_human_ai = MELEE_WEAPON_ITEM

/obj/item/ammo_magazine/handful/lever_action
	flags_human_ai = AMMUNITION_ITEM

/obj/item/ammo_magazine/handful/shotgun
	flags_human_ai = AMMUNITION_ITEM

/obj/item/ammo_magazine/handful/revolver
	flags_human_ai = AMMUNITION_ITEM

/// From /mob/living/carbon/human/proc/get_human_ai_brain() : (datum/human_ai_brain/out_brain)
#define COMSIG_HUMAN_GET_AI_BRAIN "human_get_ai_brain"


//straight directions get priority over diagonal directions in edge cases
/proc/angle2dir4ai(angle)
	if(isnull(angle))
		return null
	switch(angle) // 80/10 degrees diagonals/cardinals respectively
		if (40 to 50)
			return NORTHEAST
		if (130 to 140)
			return SOUTHEAST
		if (220 to 230)
			return SOUTHWEST
		if (310 to 320)
			return NORTHWEST
		if (0 to 40)
			return NORTH
		if (50 to 130)
			return EAST
		if (140 to 220)
			return SOUTH
		if (230 to 310)
			return WEST
		else
			return NORTH


//from /mob/living/carbon/human/u_equip()
#define COMSIG_HUMAN_UNEQUIPPED_ITEM "human_unequipped_item"
#define COMSIG_MOB_DROP_ITEM "mob_drop_item"

/// From /obj/item/restraint/proc/place_handcuffs() : ()
#define COMSIG_HUMAN_HANDCUFFED "human_handcuffed"
