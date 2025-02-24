// Holds data about the player that should persist for the entire game

/datum/moba_player
	var/tied_ckey
	var/mob/living/carbon/xenomorph/tied_xeno
	var/client/tied_client
	var/list/datum/moba_player_slot/queue_slots = list()

	var/kills = 0
	var/deaths = 0
	var/damage_dealt = 0
	var/list/held_item_types = list()

/datum/moba_player/New(ckey, client/new_client)
	. = ..()
	tied_ckey = ckey
	tied_client = new_client
	RegisterSignal(new_client, COMSIG_PARENT_QDELETING, PROC_REF(on_client_delete))

/datum/moba_player/proc/on_client_delete(datum/source)
	SIGNAL_HANDLER

	qdel(src)

/datum/moba_player/Destroy(force, ...)
	tied_client = null
	tied_xeno = null
	QDEL_NULL_LIST(queue_slots)
	return ..()
