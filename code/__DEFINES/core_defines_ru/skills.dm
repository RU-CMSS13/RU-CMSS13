/**
 * #DEFINE_SKILL
 * Дефайны навыков
 */

//spec_weapons skill
//hidden. who can and can't use specialist weapons
#define SKILL_SPEC_DEFAULT 0
/// Is trained to use specialist gear, but hasn't picked a kit.
#define SKILL_SPEC_TRAINED 1
/// Is trained to use specialist gear & HAS picked a kit. (Functionally same as SPEC_ROCKET)
#define SKILL_SPEC_KITTED 2
/// Can use RPG
#define SKILL_SPEC_ROCKET 2
/// Can use thermal cloaks and custom M4RA rifle
#define SKILL_SPEC_SCOUT 3
/// Can use sniper rifles and camo suits
#define SKILL_SPEC_SNIPER 4
/// Can use the rotary grenade launcher and heavy armor
#define SKILL_SPEC_GRENADIER 5
/// Can use heavy flamers
#define SKILL_SPEC_PYRO 6
/// Can use Heavy-Shield and N45
#define SKILL_SPEC_ST 7
/// Can use smartguns
#define SKILL_SPEC_SMARTGUN 8
/// UPP special training
#define SKILL_SPEC_UPP 9
/// Can use ALL specialist weapons
#define SKILL_SPEC_ALL 10

///////////////////////
// Навык пулемётчика //
#define SKILL_MACHINGUNNER "machinegunner"

#define SKILL_MACHINGUNNER_DEFAULT 0
#define SKILL_MACHINGUNNER_TRAINED 1   // Возможность использовать расширенные возможности пулемёта
#define SKILL_MACHINGUNNER_MAX 1

#define COMSIG_MOB_MG_SCOPE "mob_mg_scope"
#define COMSIG_MOB_MG_TURN_LEFT "mob_mg_turn_left"
#define COMSIG_MOB_MG_TURN_RIGHT "mob_mg_turn_right"
///////////////////////
