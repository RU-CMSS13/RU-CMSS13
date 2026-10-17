//BRUTE-BREACHER

/obj/item/weapon/gun/launcher/rocket/brute/breacher
	name = "\improper M6H-BREACHER launcher system"

/obj/item/weapon/gun/launcher/rocket/brute/breacher/skill_fail(mob/living/user)
	return !skillcheck(user, SKILL_SPEC_WEAPONS ,SKILL_SPEC_BREACHER)
