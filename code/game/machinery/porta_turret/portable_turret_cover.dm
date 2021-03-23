
/************************
* PORTABLE TURRET COVER *
************************/

/obj/machinery/porta_turret_cover
	name = "turret"
	icon = 'icons/obj/turrets.dmi'
	icon_state = "turretCover"
	layer = HIGH_OBJ_LAYER
	density = FALSE
	max_integrity = 80
	var/obj/machinery/porta_turret/parent_turret = null

/obj/machinery/porta_turret_cover/examine(mob/user)
	if(parent_turret)
		parent_turret.examine(user)

/obj/machinery/porta_turret_cover/Destroy()
	if(parent_turret)
		parent_turret.cover = null
		parent_turret.invisibility = 0
		parent_turret = null
	return ..()

//The below code is pretty much just recoded from the initial turret object. It's necessary but uncommented because it's exactly the same!
//>necessary
//I'm not fixing it because i'm fucking bored of this code already, but someone should just reroute these to the parent turret's procs.

/obj/machinery/porta_turret_cover/attack_ai(mob/user)
	. = ..()
	if(.)
		return

	return parent_turret.attack_ai(user)


/obj/machinery/porta_turret_cover/on_attack_hand(mob/user, act_intent = user.a_intent, unarmed_attack_flags)

	return parent_turret.attack_hand(user)


/obj/machinery/porta_turret_cover/attackby(obj/item/I, mob/user, params)
	if(parent_turret)
		parent_turret.attackby(I, user, params)

/obj/machinery/porta_turret_cover/attacked_by(obj/item/I, mob/user, attackchain_flags = NONE, damage_multiplier = 1)
	return parent_turret.attacked_by(I, user)

/obj/machinery/porta_turret_cover/attack_alien(mob/living/carbon/alien/humanoid/user)
	parent_turret.attack_alien(user)

/obj/machinery/porta_turret_cover/attack_animal(mob/living/simple_animal/user)
	parent_turret.attack_animal(user)

/obj/machinery/porta_turret_cover/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	return parent_turret.attack_hulk(user)

/obj/machinery/porta_turret_cover/can_be_overridden()
	. = 0

/obj/machinery/porta_turret_cover/emag_act(mob/user)
	if(parent_turret)
		parent_turret.emag_act(user)
