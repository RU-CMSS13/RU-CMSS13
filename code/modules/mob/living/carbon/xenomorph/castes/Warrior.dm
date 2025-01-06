/datum/caste_datum/warrior
	caste_type = XENO_CASTE_WARRIOR
	tier = 2

	melee_damage_lower = XENO_DAMAGE_TIER_3
	melee_damage_upper = XENO_DAMAGE_TIER_5
	melee_vehicle_damage = XENO_DAMAGE_TIER_5
	max_health = XENO_HEALTH_TIER_6
	plasma_gain = XENO_PLASMA_GAIN_TIER_9
	plasma_max = XENO_NO_PLASMA
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_4
	armor_deflection = XENO_ARMOR_TIER_1
	evasion = XENO_EVASION_NONE
	speed = XENO_SPEED_TIER_7

	available_strains = list(/datum/xeno_strain/boxer)
	behavior_delegate_type = /datum/behavior_delegate/warrior_base

	evolves_to = list(XENO_CASTE_PRAETORIAN, XENO_CASTE_CRUSHER)
	deevolves_to = list(XENO_CASTE_DEFENDER)
	caste_desc = "A powerful front line combatant."
	can_vent_crawl = 0

	tackle_min = 2
	tackle_max = 4

	agility_speed_increase = -0.9

	heal_resting = 1.4

	minimum_evolve_time = 9 MINUTES

	minimap_icon = "warrior"

/mob/living/carbon/xenomorph/warrior
	caste_type = XENO_CASTE_WARRIOR
	name = XENO_CASTE_WARRIOR
	desc = "A beefy alien with an armored carapace."
	icon = 'icons/mob/xenos/warrior.dmi'
	icon_size = 64
	icon_state = "Warrior Walking"
	plasma_types = list(PLASMA_CATECHOLAMINE)
	pixel_x = -16
	old_x = -16
	tier = 2
	pull_speed = 2 // about what it was before, slightly faster
	organ_value = 2000
	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/regurgitate,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/tail_stab,
		/datum/action/xeno_action/activable/warrior_punch,
		/datum/action/xeno_action/activable/lunge,
		/datum/action/xeno_action/activable/fling,
		/datum/action/xeno_action/onclick/tacmap,
	)

	claw_type = CLAW_TYPE_SHARP

	icon_xeno = 'icons/mob/xenos/warrior.dmi'
	icon_xenonid = 'icons/mob/xenonids/warrior.dmi'

	weed_food_icon = 'icons/mob/xenos/weeds_64x64.dmi'
	weed_food_states = list("Warrior_1","Warrior_2","Warrior_3")
	weed_food_states_flipped = list("Warrior_1","Warrior_2","Warrior_3")

	var/lunging = FALSE // whether or not the warrior is currently lunging (holding) a target

/mob/living/carbon/xenomorph/warrior/throw_item(atom/target)
	toggle_throw_mode(THROW_MODE_OFF)

/mob/living/carbon/xenomorph/warrior/stop_pulling()
	if(isliving(pulling) && lunging)
		lunging = FALSE // To avoid extreme cases of stopping a lunge then quickly pulling and stopping to pull someone else
		var/mob/living/lunged = pulling
		lunged.set_effect(0, STUN)
		lunged.set_effect(0, WEAKEN)
	return ..()

/mob/living/carbon/xenomorph/warrior/start_pulling(atom/movable/movable_atom, lunge)
	if (!check_state())
		return FALSE

	if(!isliving(movable_atom))
		return FALSE
	var/mob/living/living_mob = movable_atom
	var/should_neckgrab = !(src.can_not_harm(living_mob)) && lunge

	if(!QDELETED(living_mob) && !QDELETED(living_mob.pulledby) && living_mob != src ) //override pull of other mobs
		visible_message(SPAN_WARNING("[src] has broken [living_mob.pulledby]'s grip on [living_mob]!"), null, null, 5)
		living_mob.pulledby.stop_pulling()

	. = ..(living_mob, lunge, should_neckgrab)

	if(.) //successful pull
		if(isxeno(living_mob))
			var/mob/living/carbon/xenomorph/xeno = living_mob
			if(xeno.tier >= 2) // Tier 2 castes or higher immune to warrior grab stuns
				return

		if(should_neckgrab && living_mob.mob_size < MOB_SIZE_BIG)
			living_mob.drop_held_items()
			var/duration = get_xeno_stun_duration(living_mob, 2)
			living_mob.KnockDown(duration)
			living_mob.Stun(duration)
			if(living_mob.pulledby != src)
				return // Grab was broken, probably as Stun side effect (eg. target getting knocked away from a manned M56D)
			visible_message(SPAN_XENOWARNING("[src] grabs [living_mob] by the throat!"), \
			SPAN_XENOWARNING("We grab [living_mob] by the throat!"))
			lunging = TRUE
			addtimer(CALLBACK(src, PROC_REF(stop_lunging)), get_xeno_stun_duration(living_mob, 2) SECONDS + 1 SECONDS)

/mob/living/carbon/xenomorph/warrior/proc/stop_lunging(world_time)
	lunging = FALSE

/mob/living/carbon/xenomorph/warrior/hitby(atom/movable/movable_atom)
	if(ishuman(movable_atom))
		return
	..()

/datum/behavior_delegate/warrior_base
	name = "Base Warrior Behavior Delegate"

	var/lifesteal_percent = 7
	var/max_lifesteal = 9
	var/lifesteal_range =  3 // Marines within 3 tiles of range will give the warrior extra health
	var/lifesteal_lock_duration = 20 // This will remove the glow effect on warrior after 2 seconds
	var/color = "#6c6f24"
	var/emote_cooldown = 0

/datum/behavior_delegate/warrior_base/melee_attack_additional_effects_target(mob/living/carbon/carbon)
	..()

	if(SEND_SIGNAL(bound_xeno, COMSIG_XENO_PRE_HEAL) & COMPONENT_CANCEL_XENO_HEAL)
		return

	var/final_lifesteal = lifesteal_percent
	var/list/mobs_in_range = oviewers(lifesteal_range, bound_xeno)

	for(var/mob/mob as anything in mobs_in_range)
		if(final_lifesteal >= max_lifesteal)
			break

		if(mob.stat == DEAD || HAS_TRAIT(mob, TRAIT_NESTED))
			continue

		if(bound_xeno.can_not_harm(mob))
			continue

		final_lifesteal++

// This part is then outside the for loop
		if(final_lifesteal >= max_lifesteal)
			bound_xeno.add_filter("empower_rage", 1, list("type" = "outline", "color" = color, "size" = 1, "alpha" = 90))
			bound_xeno.visible_message(SPAN_DANGER("[bound_xeno.name] glows as it heals even more from its injuries!."), SPAN_XENODANGER("We glow as we heal even more from our injuries!"))
			bound_xeno.flick_heal_overlay(2 SECONDS, "#00B800")
		if(istype(bound_xeno) && world.time > emote_cooldown && bound_xeno)
			bound_xeno.emote("roar")
			bound_xeno.xeno_jitter(1 SECONDS)
			emote_cooldown = world.time + 5 SECONDS
		addtimer(CALLBACK(src, PROC_REF(lifesteal_lock)), lifesteal_lock_duration/2)

	bound_xeno.gain_health(clamp(final_lifesteal / 100 * (bound_xeno.maxHealth - bound_xeno.health), 20, 40))

/datum/behavior_delegate/warrior_base/proc/lifesteal_lock()
	bound_xeno.remove_filter("empower_rage")


/// Warrior specific behaviour for increasing pull power, limb rip.
/mob/living/carbon/xenomorph/warrior/pull_power(mob/mob)
	if(!ripping_limb && mob.stat != DEAD)
		if(mob.status_flags & XENO_HOST)
			to_chat(src, SPAN_XENOWARNING("This would harm the embryo!"))
			return
		ripping_limb = TRUE
		if(rip_limb(mob))
			stop_pulling()
		ripping_limb = FALSE


/// Warrior Rip Limb - called by pull_power()
/mob/living/carbon/xenomorph/warrior/proc/rip_limb(mob/mob)
	if(!istype(mob, /mob/living/carbon/human))
		return FALSE

	if(action_busy) //can't stack the attempts
		return FALSE

	var/mob/living/carbon/human/human = mob
	var/obj/limb/limb = human.get_limb(check_zone(zone_selected))

	if(can_not_harm(human))
		to_chat(src, SPAN_XENOWARNING("We can't harm this host!"))
		return

	if(!limb || limb.body_part == BODY_FLAG_CHEST || limb.body_part == BODY_FLAG_GROIN || (limb.status & LIMB_DESTROYED)) //Only limbs and head.
		to_chat(src, SPAN_XENOWARNING("We can't rip off that limb."))
		return FALSE
	var/limb_time = rand(40,60)

	if(limb.body_part == BODY_FLAG_HEAD)
		limb_time = rand(90,110)

	visible_message(SPAN_XENOWARNING("[src] begins pulling on [mob]'s [limb.display_name] with incredible strength!"), \
	SPAN_XENOWARNING("We begin to pull on [mob]'s [limb.display_name] with incredible strength!"))

	if(!do_after(src, limb_time, INTERRUPT_ALL|INTERRUPT_DIFF_SELECT_ZONE, BUSY_ICON_HOSTILE) || mob.stat == DEAD || mob.status_flags & XENO_HOST)
		to_chat(src, SPAN_NOTICE("We stop ripping off the limb."))
		if(mob.status_flags & XENO_HOST)
			to_chat(src, SPAN_NOTICE("We detect an embryo inside [mob] which overwhelms our instinct to rip."))
		return FALSE

	if(limb.status & LIMB_DESTROYED)
		return FALSE

	if(limb.status & (LIMB_ROBOT|LIMB_SYNTHSKIN))
		limb.take_damage(rand(30,40), 0, 0) // just do more damage
		visible_message(SPAN_XENOWARNING("You hear [mob]'s [limb.display_name] being pulled beyond its load limits!"), \
		SPAN_XENOWARNING("[mob]'s [limb.display_name] begins to tear apart!"))
	else
		visible_message(SPAN_XENOWARNING("We hear the bones in [mob]'s [limb.display_name] snap with a sickening crunch!"), \
		SPAN_XENOWARNING("[mob]'s [limb.display_name] bones snap with a satisfying crunch!"))
		limb.take_damage(rand(15,25), 0, 0)
		limb.fracture(100)
	mob.last_damage_data = create_cause_data(initial(caste_type), src)
	src.attack_log += text("\[[time_stamp()]\] <font color='red'>ripped the [limb.display_name] off of [mob.name] ([mob.ckey]) 1/2 progress</font>")
	mob.attack_log += text("\[[time_stamp()]\] <font color='orange'>had their [limb.display_name] ripped off by [src.name] ([src.ckey]) 1/2 progress</font>")
	log_attack("[src.name] ([src.ckey]) ripped the [limb.display_name] off of [mob.name] ([mob.ckey]) 1/2 progress")

	if(!do_after(src, limb_time, INTERRUPT_ALL|INTERRUPT_DIFF_SELECT_ZONE, BUSY_ICON_HOSTILE)  || mob.stat == DEAD || iszombie(mob))
		to_chat(src, SPAN_NOTICE("We stop ripping off the limb."))
		return FALSE

	if(limb.status & LIMB_DESTROYED)
		return FALSE

	visible_message(SPAN_XENOWARNING("[src] rips [mob]'s [limb.display_name] away from their body!"), \
	SPAN_XENOWARNING("[mob]'s [limb.display_name] rips away from their body!"))
	src.attack_log += text("\[[time_stamp()]\] <font color='red'>ripped the [limb.display_name] off of [mob.name] ([mob.ckey]) 2/2 progress</font>")
	mob.attack_log += text("\[[time_stamp()]\] <font color='orange'>had their [limb.display_name] ripped off by [src.name] ([src.ckey]) 2/2 progress</font>")
	log_attack("[src.name] ([src.ckey]) ripped the [limb.display_name] off of [mob.name] ([mob.ckey]) 2/2 progress")

	limb.droplimb(0, 0, initial(name))

	return TRUE

/datum/behavior_delegate/boxer
	name = "Boxer Warrior Behavior Delegate"
	var/ko_delay = 5 SECONDS
	var/max_clear_head = 3
	var/clear_head_delay = 15 SECONDS
	var/clear_head = 3
	var/next_clear_head_regen
	var/clear_head_tickcancel
	var/mob/punching_bag
	var/ko_counter = 0
	var/ko_reset_timer
	var/max_ko_counter = 15
	var/image/ko_icon
	var/image/big_ko_icon

/datum/behavior_delegate/boxer/New()
	. = ..()
	if(SSticker.mode && (SSticker.mode.flags_round_type & MODE_XVX)) // this is pain to do, but how else? hopefully we can replace clarity with something better in the future
		clear_head = 0
		max_clear_head = 0

/datum/behavior_delegate/boxer/append_to_stat()
	. = list()
	if(punching_bag)
		. += "Beating [punching_bag] - [ko_counter] hits"
	. += "Clarity [clear_head] hits"

/datum/behavior_delegate/boxer/on_life()
	var/wt = world.time
	if(wt > next_clear_head_regen && clear_head<max_clear_head)
		clear_head++
		next_clear_head_regen = wt + clear_head_delay

/datum/behavior_delegate/boxer/melee_attack_additional_effects_target(mob/living/carbon/A, ko_boost = 0.5)
	if(!ismob(A))
		return

	if(punching_bag != A)
		remove_ko()
		punching_bag = A
		ko_icon = image(null, A)
		ko_icon.alpha = 196
		ko_icon.maptext_width = 16
		ko_icon.maptext_x = 16
		ko_icon.maptext_y = 16
		ko_icon.layer = 20
		if(bound_xeno.client && bound_xeno.client.prefs && !bound_xeno.client.prefs.lang_chat_disabled)
			bound_xeno.client.images += ko_icon

	ko_counter += ko_boost
	if(ko_counter > max_ko_counter)
		ko_counter = max_ko_counter
	var/to_display = round(ko_counter)
	ko_icon.maptext = "<span class='center langchat'>[to_display]</span>"
	ko_reset_timer = addtimer(CALLBACK(src, .proc/remove_ko), ko_delay, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_NO_HASH_WAIT|TIMER_STOPPABLE)

/datum/behavior_delegate/boxer/proc/remove_ko()
	punching_bag = null
	ko_counter = 0
	if(bound_xeno.client && ko_icon)
		bound_xeno.client.images -= ko_icon
	ko_icon = null

/datum/behavior_delegate/boxer/proc/display_ko_message(mob/carbon)
	if(!bound_xeno.client)
		return

	if(!bound_xeno.client.prefs || bound_xeno.client.prefs.lang_chat_disabled)
		return

	big_ko_icon = image(null, carbon)
	big_ko_icon.alpha = 196
	big_ko_icon.maptext_y = carbon.langchat_height
	big_ko_icon.maptext_width = LANGCHAT_WIDTH
	big_ko_icon.maptext_height = 64
	big_ko_icon.color = "#FF0000"
	big_ko_icon.maptext_x = bound_xeno.get_maxptext_x_offset(big_ko_icon)
	big_ko_icon.maptext = "<span class='center langchat langchat_bolditalicbig'>KO!</span>"
	bound_xeno.client.images += big_ko_icon
	addtimer(CALLBACK(src, .proc/remove_big_ko), 2 SECONDS)

/datum/behavior_delegate/boxer/proc/remove_big_ko()
	if(bound_xeno.client && big_ko_icon)
		bound_xeno.client.images -= big_ko_icon
	big_ko_icon = null

/mob/living/carbon/xenomorph/Warrior/proc/handle_warrior_effects()
	var/datum/behavior_delegate/boxer/behavior_boxer = behavior_delegate
	if(!istype(behavior_boxer) || behavior_boxer.clear_head <= 0)
		return TRUE

	if(behavior_boxer.clear_head_tickcancel == world.time)
		return

	behavior_boxer.clear_head_tickcancel = world.time
	behavior_boxer.clear_head--
	if(behavior_boxer.clear_head <= 0)
		behavior_boxer.clear_head = 0

// a lot of repeats but it's because we are calling different parent procs
/mob/living/carbon/xenomorph/Warrior/Daze(amount)
	if(handle_warrior_effects())
		return ..(amount)

/mob/living/carbon/xenomorph/Warrior/SetDaze(amount)
	if(handle_warrior_effects())
		return ..(amount)

/mob/living/carbon/xenomorph/Warrior/AdjustDaze(amount)
	if(handle_warrior_effects())
		return ..(amount)

/mob/living/carbon/xenomorph/Warrior/KnockDown(amount, forced)
	if(handle_warrior_effects())
		return ..(amount)

/mob/living/carbon/xenomorph/Warrior/SetKnockDown(amount)
	if(handle_warrior_effects())
		return ..(amount)

/mob/living/carbon/xenomorph/Warrior/AdjustKnockDown(amount)
	if(handle_warrior_effects())
		return ..(amount)

/mob/living/carbon/xenomorph/Warrior/Stun(amount)
	if(handle_warrior_effects())
		return ..(amount)

/mob/living/carbon/xenomorph/Warrior/SetStun(amount) //if you REALLY need to set stun to a set amount without the whole "can't go below current stunned"
	if(handle_warrior_effects())
		return ..(amount)

/mob/living/carbon/xenomorph/Warrior/AdjustStun(amount)
	if(handle_warrior_effects())
		return ..(amount)
