


//									IDEAS		--
//					An object that disguises your coffin while you're in it!
//
//					An object that lets your lair itself protect you from sunlight, like a coffin would (no healing tho)



// Hide a random object somewhere on the station:
//		var/turf/targetturf = get_random_station_turf()
//		var/turf/targetturf = get_safe_random_station_turf()




// 		CRYPT OBJECTS
//
//
// 	PODIUM		Stores your Relics
//
// 	ALTAR		Transmute items into sacred items.
//
//	PORTRAIT	Gaze into your past to: restore mood boost?
//
//	BOOKSHELF	Discover secrets about crew and locations. Learn languages. Learn marial arts.
//
//	BRAZER		Burn rare ingredients to gleen insights.
//
//	RUG			Ornate, and creaks when stepped upon by any humanoid other than yourself and your vassals.
//
//	X COFFIN		(Handled elsewhere)
//
//	X CANDELABRA	(Handled elsewhere)
//
//	THRONE		Your mental powers work at any range on anyone inside your crypt.
//
//	MIRROR		Find any person
//
//	BUST/STATUE	Create terror, but looks just like you (maybe just in Examine?)


//		RELICS
//
//	RITUAL DAGGER
//
// 	SKULL
//
//	VAMPIRIC SCROLL
//
//	SAINTS BONES
//
//	GRIMOIRE


// 		RARE INGREDIENTS
// Ore
// Books (Manuals)


// 										NOTE:  Look up AI and Sentient Disease to see how the game handles the selector logo that only one player is allowed to see. We could add hud for vamps to that?
//											   ALTERNATIVELY, use the Vamp Huds on relics to mark them, but only show to relevant vamps?


/obj/structure/bloodsucker
	var/mob/living/owner

/*
/obj/structure/bloodsucker/bloodthrone
	name = "wicked throne"
	desc = "Twisted metal shards jut from the arm rests. Very uncomfortable looking. It would take a sadistic sort to sit on this jagged piece of furniture."

/obj/structure/bloodsucker/bloodaltar
	name = "bloody altar"
	desc = "It is marble, lined with basalt, and radiates an unnerving chill that puts your skin on edge."

/obj/structure/bloodsucker/bloodstatue
	name = "bloody countenance"
	desc = "It looks upsettingly familiar..."

/obj/structure/bloodsucker/bloodportrait
	name = "oil portrait"
	desc = "A disturbingly familiar face stares back at you. On second thought, the reds don't seem to be painted in oil..."

/obj/structure/bloodsucker/bloodbrazer
	name = "lit brazer"
	desc = "It burns slowly, but doesn't radiate any heat."

/obj/structure/bloodsucker/bloodmirror
	name = "faded mirror"
	desc = "You get the sense that the foggy reflection looking back at you has an alien intelligence to it."
*/


/obj/structure/bloodsucker/candelabrum
	name = "candelabrum"
	desc = "It burns slowly, but doesn't radiate any heat."
	icon = 'icons/obj/vamp_obj.dmi'
	icon_state = "candelabrum"
	light_color = "#66FFFF"//LIGHT_COLOR_BLUEGREEN // lighting.dm
	light_power = 3
	light_range = 0 // to 2
	density = FALSE
	anchored = FALSE
	var/lit = FALSE
///obj/structure/bloodsucker/candelabrum/is_hot() // candle.dm
	//return FALSE

/obj/structure/bloodsucker/candelabrum/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..() //return a hint

/obj/structure/bloodsucker/candelabrum/update_icon_state()
	icon_state = "candelabrum[lit ? "_lit" : ""]"

/obj/structure/bloodsucker/candelabrum/examine(mob/user)
	. = ..()
	if((AmBloodsucker(user)) || isobserver(user))
		. += {"<span class='cult'>This is a magical candle which drains at the sanity of mortals who are not under your command while it is active.</span>"}
		. += {"<span class='cult'>You can alt click on it from any range to turn it on remotely, or simply be next to it and click on it to turn it on and off normally.</span>"}
/*	if(user.mind.has_antag_datum(ANTAG_DATUM_VASSAL)
		. += {"<span class='cult'>This is a magical candle which drains at the sanity of the fools who havent yet accepted your master, as long as it is active.\n
		You can turn it on and off by clicking on it while you are next to it</span>"} */

/obj/structure/bloodsucker/candelabrum/on_attack_hand(mob/user, act_intent = user.a_intent, unarmed_attack_flags)
	var/datum/antagonist/vassal/T = user.mind.has_antag_datum(ANTAG_DATUM_VASSAL)
	if(AmBloodsucker(user) || istype(T))
		toggle()

/obj/structure/bloodsucker/candelabrum/AltClick(mob/user)
	// Bloodsuckers can turn their candles on from a distance. SPOOOOKY.
	if(AmBloodsucker(user))
		toggle()

/obj/structure/bloodsucker/candelabrum/proc/toggle(mob/user)
	lit = !lit
	if(lit)
		set_light(2, 3, "#66FFFF")
		START_PROCESSING(SSobj, src)
	else
		set_light(0)
		STOP_PROCESSING(SSobj, src)
	update_icon()

/obj/structure/bloodsucker/candelabrum/process()
	if(!lit)
		return
	for(var/mob/living/carbon/human/H in range(7, src))
		if(H.sight & SEE_MOBS)
			H.client.images += src

	for(var/mob/living/carbon/human/H in fov_viewers(7, src))
		var/datum/antagonist/vassal/T = H.mind.has_antag_datum(ANTAG_DATUM_VASSAL)
		if(AmBloodsucker(H) || T) //We dont want vassals or vampires affected by this
			return
		H.hallucination = 20
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "vampcandle", /datum/mood_event/vampcandle)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   OTHER THINGS TO USE: HUMAN BLOOD. /obj/effect/decal/cleanable/blood

/obj/item/restraints/legcuffs/beartrap/bloodsucker
