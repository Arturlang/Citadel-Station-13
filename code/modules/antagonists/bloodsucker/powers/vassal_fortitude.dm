/datum/action/bloodsucker/vassal/lesser_fortitude
	name = "Sanguine Fortitude"
	desc = "A lesser form of your master's fortitude power, allowing you to avoid going into critical to a point, and keeping you on your feet."
	button_icon_state = "power_fortitude"
	amToggle = TRUE
	bloodcost = 10
	cooldown = 100
	must_be_capacitated = TRUE
	ability_traits = list(TRAIT_TASED_RESISTANCE, TRAIT_NOSOFTCRIT, TRAIT_CULT_EYES, TRAIT_STUNIMMUNE)
	var/initial_right_eye_color
	var/initial_left_eye_color

/datum/action/bloodsucker/vassal/lesser_fortitude/CheckCanUse(display_error)
	. = ..()
	if(!.)
		return
	if(owner.stat != CONSCIOUS)
		return FALSE
	return TRUE

/datum/action/bloodsucker/vassal/lesser_fortitude/ActivatePower()
	..()
	if(!ishuman(owner))
		to_chat(owner, "<span class='notice'>Your current form is too weak to support this ability</span>")
		return
	to_chat(owner, "<span class='notice'>Your muscles clench and your skin crawls as your master's immortal blood knits your wounds and gives you stamina.</span>")
	var/mob/living/carbon/human/H = owner
	initial_left_eye_color = H.left_eye_color
	initial_right_eye_color = H.right_eye_color
	H.left_eye_color = "f00"
	H.right_eye_color = "f00"
	H.update_body()
	if(H.physiology.stamina_buffer_mod == 1) //Let's not fucking fuck up something else if something else is changing this
		H.physiology.stamina_buffer_mod = 0.5
	while(ContinueActive(owner))
		H.adjustStaminaLoss(50)
		if(!H.jitteriness)
			H.Jitter(10)
		sleep(11)

/datum/action/bloodsucker/vassal/lesser_fortitude/DeactivatePower()
	..()
	var/mob/living/carbon/human/H = owner
	H.update_body()
	if(H.physiology.stamina_buffer_mod == 0.5)
		H.physiology.stamina_buffer_mod = 1
	H.left_eye_color = initial_left_eye_color
	H.right_eye_color = initial_right_eye_color
	H.update_body()

/datum/action/bloodsucker/vassal/lesser_fortitude/ContinueActive(mob/living/user, mob/living/target)
	return ..() && !user.incapacitated()
