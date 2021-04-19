// organ_internal.dm   --   /obj/item/organ

// Do I have a stake in my heart?
/mob/living/AmStaked()
	var/obj/item/bodypart/BP = get_bodypart("chest")
	if (!BP)
		return FALSE
	for(var/obj/item/I in BP.embedded_objects)
		if (istype(I,/obj/item/stake/))
			return TRUE
	return FALSE

/mob/proc/AmStaked()
	return FALSE

/mob/living/proc/StakeCanKillMe()
	return IsSleeping() || stat >= UNCONSCIOUS || blood_volume <= 0 || HAS_TRAIT(src, TRAIT_FAKEDEATH) // NOTE: You can't go to sleep in a coffin with a stake in you.

/obj/item/stake
	name = "wooden stake"
	desc = "A simple wooden stake carved to a sharp point."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "wood"
	item_state = "wood"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	attack_verb = list("staked", "poked", "stabbed")
	custom_materials = list(/datum/material/wood=500)
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	hitsound = 'sound/weapons/bladeslice.ogg'
	force = 6
	throwforce = 10
	embedding = list("embed_chance" = 25, "fall_chance" = 0.5)
	//embed_chance = 25  // Look up "is_pointed" to see where we set stakes able to do this.
	//embedded_fall_chance = 0.5 // Chance it will fall out.
	obj_integrity = 30
	max_integrity = 30
	//embedded_fall_pain_multiplier
	var/time_to_stake = 120		// Time it takes to embed the stake into someone's chest.
	var/datum/brain_trauma/severe/paralysis/paraplegic/T
	var/blessed

/obj/item/stake/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WELDER && src.type == /obj/item/stake && W.tool_start_check(user, amount=5))
		if(W.use_tool(src, user, 80, volume = 50, amount = 5))
			user.visible_message("[user.name] scorched the pointy end of [src] with the welding tool.", \
						 "<span class='notice'>You scorch the pointy end of [src] with the welding tool.</span>", \
						 "<span class='italics'>You hear welding.</span>")
		// Create the Stake
		qdel(src)
		var/obj/item/stake/hardened/new_item = new(usr.loc)
		user.put_in_hands(new_item)
	else
		return ..()

/obj/item/stake/afterattack(atom/target, mob/user, proximity)
	// Invalid Target, or not targetting chest with HARM intent?
	if(!iscarbon(target) || check_zone(user.zone_selected) != "chest" || user.a_intent != INTENT_HARM)
		return
	var/mob/living/carbon/C = target
	// Needs to be Down/Slipped in some way to Stake.
	if(!C.can_be_staked())
		var/attack_embed_chance = embedding["embed_chance"] * 0.2 //We don't want this to be high because people hit quite often
		if(prob(attack_embed_chance))
			attempt_embed(target, user) //Very, very low chance to embed while just attacking
			// Oops! Can't.
	if(HAS_TRAIT(C, TRAIT_PIERCEIMMUNE))
		to_chat(user, "<span class='danger'>The [src] won't go in, the skin of [C] is too tough.</span>")
		return
	// Make Attempt...
	attempt_embed(target, user)

/obj/item/stake/proc/attempt_embed(atom/target, mob/user)
	var/mob/living/carbon/C = target
	to_chat(user, "<span class='notice'>You put all your weight into embedding the stake into [target]'s chest...</span>")
	playsound(user, 'sound/magic/Demon_consume.ogg', 50, TRUE)
	do_mob(C, user, time_to_stake, FALSE, TRUE, extra_checks=CALLBACK(C, /mob/living/carbon/proc/can_be_staked), resume_time = 5) //So the victim can see it happening.
	if(!do_mob(user, C, time_to_stake, FALSE, TRUE, extra_checks=CALLBACK(C, /mob/living/carbon/proc/can_be_staked), resume_time = 5)) // user / target / time / uninterruptable / show progress bar / extra checks
		return

	// Drop & Embed Stake
	user.visible_message("<span class='danger'>[user.name] drives the [src] into [target]'s chest!</span>", \
			 "<span class='danger'>You drive the [src] into [target]'s chest!</span>")
	playsound(get_turf(target), 'sound/effects/splat.ogg', 40, TRUE)
	user.dropItemToGround(src, TRUE) //user.drop_item() // "drop item" doesn't seem to exist anymore. New proc is user.dropItemToGround() but it doesn't seem like it's needed now?
	var/obj/item/bodypart/B = C.get_bodypart("chest")  // This was all taken from hitby() in human_defense.dm
	if(!B)
		return
	B.embedded_objects |= src
	embedded()
	add_mob_blood(target) //Place blood on the stake
	loc = C // Put INSIDE the character
	B.receive_damage(w_class * embedding["pain_mult"])
	if(C.mind)
		var/datum/antagonist/bloodsucker/bloodsucker = C.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
		if(bloodsucker && C.StakeCanKillMe())
			T = new("full")
			C.gain_trauma(T, TRAUMA_RESILIENCE_ABSOLUTE) //Just oof.
			to_chat(C, "<span class='danger'>You've been staked in your heart! You won't be able to do ANYTHING until it's taken out of your heart!</span>")

/obj/item/stake/embedded(atom/embedded_target)
	var/mob/living/carbon/C = embedded_target
	if(!blessed && !C.StakeCanKillMe())
		START_PROCESSING(SSobj, src)

/obj/item/stake/process(delta_time)
	if(DT_PROB(2, delta_time))
		if(iscarbon(loc))
			var/mob/living/carbon/C = loc
			to_chat(C, "<span class='danger'>The blessed stake in your chest is setting your unholy flesh on fire! Get it out before it burns you to ashes!</span>")
			C.fire_stacks ++
			C.IgniteMob()


/obj/item/stake/unembedded(atom/embedded_target)
	var/mob/living/carbon/C = embedded_target
	C.cure_trauma_type(T, TRAUMA_RESILIENCE_ABSOLUTE)
	STOP_PROCESSING(SSobj, src)
	..()

// Can this target be staked? If someone stands up before this is complete, it fails. Best used on someone stationary.
/mob/living/carbon/proc/can_be_staked()
	return !CHECK_MOBILITY(src, MOBILITY_STAND)

/obj/item/stake/hardened
	// Created by welding and acid-treating a simple stake.
	name = "hardened stake"
	desc = "A hardened wooden stake carved to a sharp point and scorched at the end."
	icon_state = "hardened"
	force = 8
	throwforce = 12
	armour_penetration = 10
	embedding = list("embed_chance" = 50, "fall_chance" = 0)
	obj_integrity = 120
	max_integrity = 120
	time_to_stake = 80

/obj/item/stake/hardened/silver
	name = "silver stake"
	desc = "Polished and sharp at the end. For when some mofo is always trying to iceskate uphill."
	icon_state = "silver"
	item_state = "silver"
	siemens_coefficient = 1
	force = 9
	armour_penetration = 25
	custom_materials = list(/datum/material/silver=200, custom_materials = list(/datum/material/wood=500))
	embedding = list("embed_chance" = 65)
	obj_integrity = 300
	max_integrity = 300
	time_to_stake = 60

// Convert back to Silver
/obj/item/stake/hardened/silver/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WELDER && I.tool_start_check(user, amount=5))
		if(I.use_tool(src, user, 80, volume = 50, amount = 5))
			var/obj/item/stack/sheet/mineral/silver/newsheet = new (user.loc)
			for(var/obj/item/stack/sheet/mineral/silver/S in user.loc)
				if(S == newsheet)
					continue
				if(S.amount >= S.max_amount)
					continue
				S.attackby(newsheet, user)
			to_chat(user, "<span class='notice'>You melt down the stake and add it to the stack. It now contains [newsheet.amount] sheet\s.</span>")
			qdel(src)
	else
		return ..()


/datum/crafting_recipe/silver_stake
	name = "Silver Stake"
	result = /obj/item/stake/hardened/silver
	tools = list(/obj/item/weldingtool)
	reqs = list(/obj/item/stack/sheet/mineral/silver = 1,
				/obj/item/stake/hardened = 1)
				///obj/item/stack/packageWrap = 8,
				///obj/item/pipe = 2)
	time = 80
	category = CAT_WEAPONRY
	subcategory = CAT_MELEE
