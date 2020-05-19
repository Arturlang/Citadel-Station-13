/datum/hud/constructs
	ui_style = 'icons/mob/screen_construct.dmi'

/datum/hud/constructs/New(mob/owner)
	..()
	pull_icon = new /obj/screen/pull()
	pull_icon.icon = ui_style
	pull_icon.hud = src
	pull_icon.update_icon()
	pull_icon.screen_loc = ui_construct_pull
	static_inventory += pull_icon

	healths = new /obj/screen/healths/construct()
	healths.hud = src
	infodisplay += healths

/obj/screen/constructs/soulblade/blood_display
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "power_display2" //alien one for now, wip
	name = "blood stored"
	screen_loc = ui_alienplasmadisplay
