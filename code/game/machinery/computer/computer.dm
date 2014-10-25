/obj/machinery/computer
	name = "computer"
	icon = 'icons/obj/computer.dmi'
	density = 1
	anchored = 1.0
	use_power = 1
	idle_power_usage = 300
	active_power_usage = 300
	var/obj/item/weapon/circuitboard/circuit = null //if circuit==null, computer can't disassembly
	var/processing = 0
	machine_flags = EMAGGABLE | SCREWTOGGLE | WRENCHMOVE | FIXED2WORK

/obj/machinery/computer/New()
	..()
	if(ticker)
		initialize()

/obj/machinery/computer/initialize()
	power_change()

/obj/machinery/computer/process()
	if(stat & (NOPOWER|BROKEN))
		return 0
	return 1

/obj/machinery/computer/meteorhit(var/obj/O as obj)
	for(var/x in verbs)
		verbs -= x
	set_broken()
	var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
	smoke.set_up(5, 0, src)
	smoke.start()
	return


/obj/machinery/computer/emp_act(severity)
	if(prob(20/severity)) set_broken()
	..()


/obj/machinery/computer/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(25))
				qdel(src)
				return
			if (prob(50))
				for(var/x in verbs)
					verbs -= x
				set_broken()
		if(3.0)
			if (prob(25))
				for(var/x in verbs)
					verbs -= x
				set_broken()
		else
	return

/obj/machinery/computer/bullet_act(var/obj/item/projectile/Proj)
	if(prob(Proj.damage))
		set_broken()
	..()


/obj/machinery/computer/blob_act()
	if (prob(75))
		for(var/x in verbs)
			verbs -= x
		set_broken()
		density = 0

/obj/machinery/computer/update_icon()
	..()
	icon_state = initial(icon_state)
	// Broken
	if(stat & BROKEN)
		icon_state += "b"

	// Powered
	else if(stat & NOPOWER)
		icon_state = initial(icon_state)
		icon_state += "0"



/obj/machinery/computer/power_change()
	..()
	update_icon()
	if(!(stat & (BROKEN|NOPOWER)))
		SetLuminosity(2)
	else
		SetLuminosity(0)


/obj/machinery/computer/proc/set_broken()
	stat |= BROKEN
	update_icon()

/obj/machinery/computer/togglePanelOpen(var/obj/toggleitem, mob/user)
	if(!circuit) //we can't disassemble with no circuit, so add some fucking circuits if you want disassembly
		return
	playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
	user.visible_message(	"[user] begins to unscrew \the [src]'s monitor.",
							"You begin to unscrew the monitor...")
	if(do_after(user, 20))
		var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
		var/obj/item/weapon/circuitboard/M = new circuit( A )
		A.circuit = M
		A.anchored = 1
		for (var/obj/C in src)
			C.loc = src.loc
		if (src.stat & BROKEN)
			user << "<span class='notice'>\icon[src] The broken glass falls out.</span>"
			getFromPool(/obj/item/weapon/shard, loc)
			A.state = 3
			A.icon_state = "3"
		else
			user << "<span class='notice'>\icon[src] You disconnect the monitor.</span>"
			A.state = 4
			A.icon_state = "4"
		Destroy(src)
		return 1
	return

/obj/machinery/computer/attackby(I as obj, user as mob)
	if(..())
		return
	else
		src.attack_hand(user)
	return
