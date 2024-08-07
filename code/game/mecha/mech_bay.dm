/obj/machinery/mech_recharger
	name = "mech recharger"
	desc = "A mech recharger, built into the floor."
	icon = 'icons/mecha/mech_bay.dmi'
	icon_state = "recharge_floor"
	density = 0
	layer = TURF_LAYER + 0.1
	anchored = 1
	circuit = /obj/item/circuitboard/mech_recharger

	var/obj/mecha/charging = null
	var/charge = 200
	var/repair = 0

/obj/machinery/mech_recharger/Crossed(var/obj/mecha/M)
	. = ..()
	if(istype(M) && charging != M)
		start_charging(M)

/obj/machinery/mech_recharger/Uncrossed(var/obj/mecha/M)
	. = ..()
	if(M == charging)
		stop_charging()

/obj/machinery/mech_recharger/RefreshParts()
	..()
	charge = 0
	repair = -5
	for(var/obj/item/stock_parts/P in component_parts)
		if(istype(P, /obj/item/stock_parts/capacitor))
			charge += P.rating * 100
		if(istype(P, /obj/item/stock_parts/scanning_module))
			charge += P.rating * 10
			repair += P.rating
		if(istype(P, /obj/item/stock_parts/manipulator))
			repair += P.rating * 2

/obj/machinery/mech_recharger/Process()
	..()
	if(!charging)
		return
	if(charging.loc != loc) // Could be qdel or teleport or something
		stop_charging()
		return
	var/done = 1
	if(charging.cell)
		var/t = min(charge, charging.cell.maxcharge - charging.cell.charge)
		if(t > 0)
			charging.give_power(t)
			use_power(t * 500)
			done = 0
		else
			charging.occupant_message(SPAN_NOTICE("Fully charged."))
	if(repair && charging.health < initial(charging.health))
		charging.health = min(charging.health + repair, initial(charging.health))
		if(charging.health == initial(charging.health))
			charging.occupant_message(SPAN_NOTICE("Fully repaired."))

		else
			done = 0
	if(done)
		stop_charging()

/obj/machinery/mech_recharger/attackby(var/obj/item/I, var/mob/user)
	if(default_deconstruction(I, user))
		return

	if(default_part_replacement(I, user))
		return

/obj/machinery/mech_recharger/proc/start_charging(var/obj/mecha/M)
	if(stat & (NOPOWER | BROKEN))
		M.occupant_message(SPAN_WARNING("Power port not responding. Terminating."))
		return

	if(M.cell)
		M.occupant_message(SPAN_NOTICE("Now charging..."))
		charging = M

/obj/machinery/mech_recharger/proc/stop_charging()
	if(!charging)
		return

	charging = null
