/obj/structure/blocker/invisible_wall/survivor_oneway_border
	name = "one-way survivor barrier"
	desc = "You cannot go this way."
	icon_state = "invisible_wall"
	opacity = FALSE
	anchored = TRUE
	density = TRUE
	throwpass = TRUE
	flags_atom = ON_BORDER
	layer = ABOVE_FLY_LAYER + 0.1 // visible in map editor
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	/// After the hive reaches the first T3, this barrier will be deleted after this delay.
	var/t3_despawn_delay = 2 MINUTES
	var/_t3_despawn_started = FALSE

/obj/structure/blocker/invisible_wall/survivor_oneway_border/New()
	..()
	icon_state = null

/obj/structure/blocker/invisible_wall/survivor_oneway_border/Initialize(mapload)
	. = ..()
	var/datum/hive_status/hive = GLOB.hive_datum?[XENO_HIVE_NORMAL]
	if(!hive)
		return
	RegisterSignal(hive, COMSIG_HIVE_FIRST_T3, PROC_REF(_on_hive_first_t3))
	if(length(hive.tier_3_xenos))
		_start_t3_despawn_timer()

/obj/structure/blocker/invisible_wall/survivor_oneway_border/Destroy(force)
	var/datum/hive_status/hive = GLOB.hive_datum?[XENO_HIVE_NORMAL]
	if(hive)
		UnregisterSignal(hive, COMSIG_HIVE_FIRST_T3)
	return ..()

/obj/structure/blocker/invisible_wall/survivor_oneway_border/proc/_is_survivor(atom/movable/mover)
	if(!ishuman(mover))
		return FALSE
	var/mob/living/carbon/human/H = mover
	return issurvivorjob(H.job) || H.faction == FACTION_SURVIVOR || (FACTION_SURVIVOR in H.faction_group)

/obj/structure/blocker/invisible_wall/survivor_oneway_border/proc/_on_hive_first_t3(datum/hive_status/source, mob/living/carbon/xenomorph/tier3_xeno)
	SIGNAL_HANDLER
	_start_t3_despawn_timer()

/obj/structure/blocker/invisible_wall/survivor_oneway_border/proc/_start_t3_despawn_timer()
	if(_t3_despawn_started || QDELETED(src))
		return
	_t3_despawn_started = TRUE
	if(t3_despawn_delay <= 0)
		qdel(src)
		return
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src), t3_despawn_delay)

/obj/structure/blocker/invisible_wall/survivor_oneway_border/BlockedPassDirs(atom/movable/mover, target_dir)
	if(isxeno(mover))
		return NO_BLOCKED_MOVEMENT
	if(!_is_survivor(mover))
		return NO_BLOCKED_MOVEMENT
	return ..()

/obj/structure/blocker/invisible_wall/survivor_oneway_border/BlockedExitDirs(atom/movable/mover, target_dir)
	if(isxeno(mover) || _is_survivor(mover))
		return NO_BLOCKED_MOVEMENT
	return ..()
