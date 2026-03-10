/obj/item/weapon/gun
	/// for lineart override
	var/lineart_ru = FALSE  //RUCM EDIT
	var/flags_mounted_gun_features = null

	/// Remote handling
	var/atom/gun_holder = null
	var/mount_class = GUN_MOUNT_NO

	/// For gun holder
	var/datum/callback/callback_can_fire
	var/datum/callback/callback_can_stop_fire
	var/datum/callback/callback_fire_stat

/obj/item/weapon/gun/proc/muzzle_flash(angle, mob/user)
	if(!muzzle_flash || flags_gun_features & GUN_SILENCED || isnull(angle))
		return //We have to check for null angle here, as 0 can also be an angle.

	var/atom/ref_for_muzzle = user
	if(gun_holder)
		ref_for_muzzle = gun_holder

	if(!ref_for_muzzle || !isturf(ref_for_muzzle.loc))
		return

	var/prev_light = light_range
	if(!light_on && (light_range <= muzzle_flash_lum))
		set_light_range(muzzle_flash_lum)
		set_light_on(TRUE)
		set_light_color(muzzle_flash_color)
		addtimer(CALLBACK(src, PROC_REF(reset_light_range), prev_light), 0.5 SECONDS)

	var/image/I = image('icons/obj/items/weapons/projectiles.dmi', ref_for_muzzle, muzzle_flash, ref_for_muzzle.dir == NORTH ? ABOVE_LYING_MOB_LAYER : FLOAT_LAYER)
	var/matrix/rotate = matrix()
	if(ismob(ref_for_muzzle))
		user = ref_for_muzzle
		if(iscarbonsizexeno(user))// This can't be run without mob type
			var/mob/living/carbon/xenomorph/xeno = user
			I.pixel_x = xeno.xeno_inhand_item_offset

	rotate.Translate(0, 5)
	rotate.Turn(angle)
	I.transform = rotate
	I.flick_overlay(ref_for_muzzle, 3)
// COMSIG_PARENT_QDELETING
