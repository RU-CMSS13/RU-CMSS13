/obj/item/hardpoint/walker/leg
	name = "Mecha Leg"
	desc = "Allows mecha to move around."

	hdpt_layer = HDPT_LAYER_SUPPORT
	destruction_on_zero = FALSE

	move_delay = 2
	move_max_momentum = 4
	move_turn_momentum_loss_factor = 0.5
	move_momentum_build_factor = 0.5

/obj/item/hardpoint/walker/leg/deactivate(obj/vehicle/walker/vessel)
	. = ..()

	vessel.recalculate_hardpoints()


/obj/item/hardpoint/walker/leg/left
	name = "Left Mecha Leg"

	disp_icon_state = "mech_part_l_leg"
	slot = WALKER_HARDPOIN_LEFT_LEG

/obj/item/hardpoint/walker/leg/right
	name = "Right Mecha Leg"

	disp_icon_state = "mech_part_r_leg"
	slot = WALKER_HARDPOIN_RIGHT_LEG
