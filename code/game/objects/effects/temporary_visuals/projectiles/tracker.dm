//object that moves constantly toward a target.

/obj/effect/tracker
	name = "tracker"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "soul2"
	mouse_opacity = FALSE
	animate_movement = FALSE
	var/absolute_X = 0
	var/absolute_Y = 0
	var/atom/target = null
	var/speed = 2
	var/acceleration = 1
	var/maxdist = 320
	var/refresh = 1

/obj/effect/tracker/New()
	. = ..()
	absolute_X = (x * WORLD_ICON_SIZE)
	absolute_Y = (y * WORLD_ICON_SIZE)

	addtimer(CALLBACK(src, .proc/begin_processing), 1) //We can't callback a macro as far as I know

/obj/effect/tracker/soul
	name = "soul"
	icon_state = "soul3"

/obj/effect/tracker/drain
	name = "blood"
	color = "red"

/obj/effect/tracker/proc/begin_processing()
	START_PROCESSING(SSfastprocess, src)

/obj/effect/tracker/Destroy(force)
	STOP_PROCESSING(SSfastprocess, src)
	. = ..()

/obj/effect/tracker/process()
	. = ..()
	if(!target)
		for(var/T in view(7, src))
			var/failsafe
			if(isliving(T))
				target = T
				break
			while(failsafe < 100)
				failsafe++
				return
			qdel(src)

	if(target.z != z)
		qdel(src)
		return

	var/target_absolute_X = target.x * WORLD_ICON_SIZE
	var/target_absolute_Y = target.y * WORLD_ICON_SIZE

	var/dx = target_absolute_X - absolute_X
	var/dy = target_absolute_Y - absolute_Y

	var/dist = sqrt(abs(dx)**2 + abs(dy)**2)
	if(dist > maxdist)
		qdel(src)
		return
	else if(dist < 16)
		qdel(src)
		return

	if(abs(dx) > abs(dy))
		absolute_X += (dx/abs(dx)) * speed
		absolute_Y += round((speed * dy)/abs(dx))
	else if(abs(dx) < abs(dy))
		absolute_X += round((speed * dx)/abs(dy))
		absolute_Y += (dy/abs(dy)) * speed
	else
		absolute_X += (dx/abs(dx)) * speed
		absolute_Y += (dy/abs(dy)) * speed


	absolute_X += round((dx/100)*speed)
	absolute_Y += round((dy/100)*speed)

	speed += acceleration

	x = absolute_X/WORLD_ICON_SIZE
	y = absolute_Y/WORLD_ICON_SIZE
	update_icon()

	addtimer(CALLBACK(src, .proc/begin_processing), refresh)


/obj/effect/tracker/update_icon()
	pixel_x = absolute_X % WORLD_ICON_SIZE
	pixel_y = absolute_Y % WORLD_ICON_SIZE

/obj/effect/tracker/narsie_act()
	return

/obj/effect/tracker/singularity_act()
	return

/obj/effect/tracker/singularity_pull()
	return

/proc/make_tracker_effects(tr_source, tr_destination, tr_number = 10, custom_icon_state = "soul", number_of_icons = 3, tr_type = /obj/effect/tracker/soul, force_size)
	spawn()
		var/list/possible_icons = list()
		if(custom_icon_state)
			for(var/i = 1;i <= number_of_icons;i++)
				if (force_size)
					possible_icons.Add("[custom_icon_state][force_size]")
				else
					possible_icons.Add("[custom_icon_state][i]")
		for(var/i = 0;i < tr_number;i++)
			var/obj/effect/tracker/Tr = new tr_type(tr_source)
			Tr.target = tr_destination
			if(custom_icon_state)
				Tr.icon_state = pick(possible_icons)
