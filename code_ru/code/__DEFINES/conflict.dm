#define AMMO_IGNORE_XENO_IFF (1<<23)

#define MODE_HAS_TOGGLEABLE_FLAG(flag) (SSticker.mode.toggleable_flags & flag)

#define MODE_HUMAN_AI_TWEAKS (1<<0)
#define MODE_NO_MAKE_BARRICADES (1<<1)

/// From /mob/living/carbon/human/proc/set_species() : (new_species)
#define COMSIG_HUMAN_SET_SPECIES "human_set_species"
