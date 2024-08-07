
////////////////////////////////////
///// Rendering stats window ///////
////////////////////////////////////

/obj/mecha/proc/get_stats_html()
	var/output = {"<html>
	<head><title>[name] data</title>
	<style>
	body {color: #00ff00; background: #000000; font-family:"Lucida Console",monospace; font-size: 12px;}
	hr {border: 1px solid #0f0; color: #0f0; background-color: #0f0;}
	a {padding:2px 5px;;color:#0f0;}
	.wr {margin-bottom: 5px;}
	.header {cursor:pointer;}
	.open, .closed {background: #32CD32; color:#000; padding:1px 2px;}
	.links a {margin-bottom: 2px;padding-top:3px;}
	.visible {display: block;}
	.hidden {display: none;}
	</style>
	<script language='javascript' type='text/javascript'>
	[js_byjax]
	[js_dropdowns]
	function ticker() {
		setInterval(function(){
			window.location='byond://?src=\ref[src]&update_content=1';
		}, 1000);
	}

	window.onload = function() {
		dropdowns();
		ticker();
	}
	</script>
	</head>
	<body>
	<div id='content'>
	[get_stats_part()]
	</div>
	<div id='eq_list'>
	[get_equipment_list()]
	</div>
	<hr>
	<div id='commands'>
	[get_commands()]
	</div>
	</body>
	</html>
	"}
	return output


/obj/mecha/proc/report_internal_damage()
	var/output = null
	var/list/dam_reports = list(
		"[MECHA_INT_FIRE]" = "<font color='red'><b>INTERNAL FIRE</b></font>",
		"[MECHA_INT_TEMP_CONTROL]" = "<font color='red'><b>LIFE SUPPORT SYSTEM MALFUNCTION</b></font>",
		"[MECHA_INT_TANK_BREACH]" = "<font color='red'><b>GAS TANK BREACH</b></font>",
		"[MECHA_INT_CONTROL_LOST]" = "<font color='red'><b>COORDINATION SYSTEM CALIBRATION FAILURE</b></font> - <a href='?src=\ref[src];repair_int_control_lost=1'>Recalibrate</a>",
		"[MECHA_INT_SHORT_CIRCUIT]" = "<font color='red'><b>SHORT CIRCUIT</b></font>"
		)
	for(var/tflag in dam_reports)
		var/intdamflag = text2num(tflag)
		if(hasInternalDamage(intdamflag))
			output += dam_reports[tflag]
			output += "<br />"
	if(return_pressure() > WARNING_HIGH_PRESSURE)
		output += "<font color='red'><b>DANGEROUSLY HIGH CABIN PRESSURE</b></font><br />"
	return output


/obj/mecha/proc/get_stats_part()
	var/integrity = health/initial(health) * 100
	var/cell_charge = get_charge()
	var/tank_pressure = internal_tank ? round(internal_tank.return_pressure(), 0.01) : "None"
	var/tank_temperature = internal_tank ? "[internal_tank.return_temperature()]K|[internal_tank.return_temperature() - T0C]&deg;C" : "Unknown" //Results in type mismatch if there is no tank.
	var/cabin_pressure = round(return_pressure(), 0.01)
	. = "[report_internal_damage()]"
	. += "[integrity < 30 ? "<font color='red'><b>DAMAGE LEVEL CRITICAL</b></font><br>":null]"
	. += "<b>Integrity: </b> [integrity]%<br>"
	. += "<b>Powercell charge: </b>[isnull(cell_charge)?"No powercell installed":"[cell.percent()]%"]<br>"
	. += "<b>Air source: </b>[use_internal_tank?"Internal Airtank":"Environment"]<br>"
	. += "<b>Airtank pressure: </b>[tank_pressure]kPa<br>"
	. += "<b>Airtank temperature: </b>[tank_temperature]<br>"
	. += "<b>Cabin pressure: </b>[cabin_pressure>WARNING_HIGH_PRESSURE ? "<font color='red'>[cabin_pressure]</font>": cabin_pressure]kPa<br>"
	. += "<b>Cabin temperature: </b> [return_temperature()]K|[return_temperature() - T0C]&deg;C<br>"
	. += "<b>Lights: </b>[lights ? "on" : "off"]<br>"
	. += "[dna ? "<b>DNA-locked:</b><br> <span style='font-size:10px;letter-spacing:-1px;'>[dna]</span> \[<a href='?src=\ref[src];reset_dna=1'>Reset</a>\]<br>":null]"
	. += "[defense_action.owner ? "<b>Defense Mode: </b> [defense_mode ? "Enabled" : "Disabled"]<br>" : ""]"
	. += "[overload_action.owner ? "<b>Leg Actuators Overload: </b> [leg_overload_mode ? "Enabled" : "Disabled"]<br>" : ""]"
	. += "[smoke_action.owner ? "<b>Smoke: </b> [smoke]<br>" : ""]"
	. += "[zoom_action.owner ? "<b>Zoom: </b> [zoom_mode ? "Enabled" : "Disabled"]<br>" : ""]"
	. += "[phasing_action.owner ? "<b>Phase Modulator: </b> [phasing ? "Enabled" : "Disabled"]<br>" : ""]"

	if(cargo_capacity > 0)
		. += "<b>Cargo Compartment Contents:</b><div style=\"margin-left: 15px;\">"
		if(LAZYLEN(cargo))
			for(var/obj/O in cargo)
				. += "<a href='?src=\ref[src];drop_from_cargo=\ref[O]'>Unload</a> : [O]<br>"
		else
			. += "Nothing"
		. += "</div>"

/obj/mecha/proc/get_commands()
	var/output = {"<div class='wr'>
		<div class='header'>Electronics</div>
		<div class='links'>
		<a href='?src=\ref[src];toggle_lights=1'>Toggle Lights</a><br>
		<b>Radio settings:</b><br>
		Microphone: <a href='?src=\ref[src];rmictoggle=1'><span id="rmicstate">[radio.broadcasting?"Engaged":"Disengaged"]</span></a><br>
		Speaker: <a href='?src=\ref[src];rspktoggle=1'><span id="rspkstate">[radio.listening?"Engaged":"Disengaged"]</span></a><br>
		Frequency:
		<a href='?src=\ref[src];rfreq=-10'>-</a>
		<a href='?src=\ref[src];rfreq=-2'>-</a>
		<span id="rfreq">[format_frequency(radio.frequency)]</span>
		<a href='?src=\ref[src];rfreq=2'>+</a>
		<a href='?src=\ref[src];rfreq=10'>+</a><br>
		</div>
		</div>
		<div class='wr'>
		<div class='header'>Airtank</div>
		<div class='links'>
		<a href='?src=\ref[src];toggle_airtank=1'>Toggle Internal Airtank Usage</a><br>
		</div>
		</div>
		<div class='wr'>
		<div class='header'>Permissions & Logging</div>
		<div class='links'>
		<a href='?src=\ref[src];toggle_id_upload=1'><span id='t_id_upload'>[add_req_access?"L":"Unl"]ock ID upload panel</span></a><br>
		<a href='?src=\ref[src];toggle_maint_access=1'><span id='t_maint_access'>[maint_access?"Forbid":"Permit"] maintenance protocols</span></a><br>
		<a href='?src=\ref[src];dna_lock=1'>DNA-Lock</a><br>
		<a href='?src=\ref[src];view_log=1'>View internal log</a><br>
		<a href='?src=\ref[src];change_name=1'>Change exosuit name</a><br>
		</div>
		</div>
		<div id='equipment_menu'>[get_equipment_menu()]</div>
		<hr>
		<a href='?src=\ref[src];eject=1'>Eject</a><br>
	"}
	return output

/obj/mecha/proc/get_equipment_menu() //outputs mecha html equipment menu
	var/output
	if(equipment.len)
		output += {"<div class='wr'>
						<div class='header'>Equipment</div>
						<div class='links'>"}
		for(var/obj/item/mecha_parts/mecha_equipment/W in equipment)
			output += "[W.name] <a href='?src=\ref[W];detach=1'>Detach</a><br>"
		output += "<b>Available equipment slots:</b> [max_equip-equipment.len]"
		output += "</div></div>"
	return output

/obj/mecha/proc/get_equipment_list() //outputs mecha equipment list in html
	if(!equipment.len)
		return
	var/output = "<b>Equipment:</b><div style=\"margin-left: 15px;\">"
	output += "<a href='?src=\ref[src];unequip=1'>Deselect Current Equipment</a><br>"
	for(var/obj/item/mecha_parts/mecha_equipment/MT in equipment)
		output += "<div id='\ref[MT]'>[MT.get_equip_info()]</div>"
	output += "</div>"
	return output


/obj/mecha/proc/get_log_html()
	var/output = "<html><head><title>[name] Log</title></head><body style='font: 13px 'Courier', monospace;'>"
	for(var/list/entry in log)
		output += {"<div style='font-weight: bold;'>[time2text(entry["time"],"DDD MMM DD hh:mm:ss")] [game_year]</div>
						<div style='margin-left:15px; margin-bottom:10px;'>[entry["message"]]</div>
						"}
	output += "</body></html>"
	return output


/obj/mecha/proc/output_access_dialog(obj/item/card/id/id_card, mob/user)
	if(!id_card || !user)
		return

	var/output = {"<html>
		<head><style>
		h1 {font-size:15px;margin-bottom:4px;}
		body {color: #00ff00; background: #000000; font-family:"Courier New", Courier, monospace; font-size: 12px;}
		a {color:#0f0;}
		</style>
		</head>
		<body>
		<h1>Following keycodes are present in this system:</h1>"}

	for(var/a in operation_req_access)
		output += "[get_access_desc(a)] - <a href='?src=\ref[src];del_req_access=[a];user=\ref[user];id_card=\ref[id_card]'>Delete</a><br>"

	output += "<hr><h1>Following keycodes were detected on portable device:</h1>"
	for(var/a in id_card.access)
		if(a in operation_req_access)
			continue

		var/a_name = get_access_desc(a)
		if(!a_name)
			continue //there's some strange access without a name

		output += "[a_name] - <a href='?src=\ref[src];add_req_access=[a];user=\ref[user];id_card=\ref[id_card]'>Add</a><br>"

	output += "<hr><a href='?src=\ref[src];finish_req_access=1;user=\ref[user]'>Finish</a> <font color='red'>(Warning! The ID upload panel will be locked. It can be unlocked only through Exosuit Interface.)</font>"
	output += "</body></html>"

	user << browse(output, "window=exosuit_add_access")
	onclose(user, "exosuit_add_access")

/obj/mecha/proc/output_maintenance_dialog(obj/item/card/id/id_card, mob/user)
	if(!id_card || !user)
		return

	var/maint_options = "<a href='?src=\ref[src];set_internal_tank_valve=1;user=\ref[user]'>Set Cabin Air Pressure</a>"
	if(locate(/obj/item/mecha_parts/mecha_equipment/tool/passenger) in contents)
		maint_options += "<a href='?src=\ref[src];remove_passenger=1;user=\ref[user]'>Remove Passenger</a>"
	if(dna)
		maint_options += "<a href='?src=\ref[src];maint_reset_dna=1;user=\ref[user]'>Revert DNA-Lock</a>"

	var/output = {"<html>
		<head>
		<style>
		body {color: #00ff00; background: #000000; font-family:"Courier New", Courier, monospace; font-size: 12px;}
		a {padding:2px 5px; background:#32CD32;color:#000;display:block;margin:2px;text-align:center;text-decoration:none;}
		</style>
		</head>
		<body>
		[add_req_access?"<a href='?src=\ref[src];req_access=1;id_card=\ref[id_card];user=\ref[user]'>Edit operation keycodes</a>":null]
		[maint_access?"<a href='?src=\ref[src];maint_access=1;id_card=\ref[id_card];user=\ref[user]'>Initiate maintenance protocol</a>":null]
		[(state>0) ? maint_options : ""]
		</body>
		</html>"}
	user << browse(output, "window=exosuit_maint_console")
	onclose(user, "exosuit_maint_console")

////////////////////////////////
/////// Messages and Log ///////
////////////////////////////////

/obj/mecha/proc/occupant_message(message)
	if(message)
		if(occupant && occupant.client)
			to_chat(occupant, "\icon[src] [message]")
	return

/obj/mecha/proc/log_message(message, red = null)
	log.len++
	log[log.len] = list("time"=world.timeofday,"message"="[red?"<font color='red'>":null][message][red?"</font>":null]")
	return log.len

/obj/mecha/proc/log_append_to_last(message, red = null)
	if(!length(log))
		return

	var/list/last_entry = log[log.len]
	last_entry["message"] += "<br>[red?"<font color='red'>":null][message][red?"</font>":null]"


/////////////////
///// Topic /////
/////////////////

/obj/mecha/Topic(href, href_list)
	. = ..()
	if(href_list["update_content"])
		if(usr != occupant)
			return
		send_byjax(occupant,"exosuit.browser","content",get_stats_part())
		return

	if(href_list["close"])
		usr << sound('sound/mecha/UI_SCI-FI_Tone_10_stereo.ogg',channel=4, volume=100);
		return

	if(usr.stat > 0)
		return

	var/datum/topic_input/m_filter = new /datum/topic_input(href,href_list)
	if(href_list["select_equip"])
		if(usr != occupant)
			return
		usr << sound('sound/mecha/UI_SCI-FI_Tone_10_stereo.ogg',channel=4, volume=100);
		var/obj/item/mecha_parts/mecha_equipment/equip = m_filter.getObj("select_equip")
		if(equip)
			selected = equip
			occupant_message("You switch to [equip]")
			visible_message("[src] raises [equip]")
			send_byjax(occupant,"exosuit.browser","eq_list",get_equipment_list())
		return

	if(href_list["unequip"])
		if(usr != occupant)
			return
		if(selected)
			usr << sound('sound/mecha/UI_SCI-FI_Tone_10_stereo.ogg',channel=4, volume=100);
			occupant_message("You deselect [selected]")
			visible_message("[src] lowers [selected]")
			selected = null
			send_byjax(occupant,"exosuit.browser","eq_list",get_equipment_list())
	if(href_list["eject"])
		if(usr != occupant)
			return
		playsound(src,'sound/mecha/ROBOTIC_Servo_Large_Dual_Servos_Open_mono.ogg',100,1)
		go_out()
		return
	if(href_list["toggle_lights"])
		if(usr != occupant)
			return
		usr << sound('sound/mecha/UI_SCI-FI_Tone_10_stereo.ogg',channel=4, volume=100)
		toggle_lights()
		return
	if(href_list["toggle_airtank"])
		if(usr != occupant)
			return
		usr << sound('sound/mecha/UI_SCI-FI_Tone_10_stereo.ogg',channel=4, volume=100)
		toggle_internal_tank()
		return
	if(href_list["rmictoggle"])
		if(usr != occupant)
			return
		usr << sound('sound/mecha/UI_SCI-FI_Tone_10_stereo.ogg',channel=4, volume=100)
		radio.broadcasting = !radio.broadcasting
		send_byjax(occupant,"exosuit.browser","rmicstate",(radio.broadcasting?"Engaged":"Disengaged"))
		return
	if(href_list["rspktoggle"])
		if(usr != occupant)
			return
		usr << sound('sound/mecha/UI_SCI-FI_Tone_10_stereo.ogg',channel=4, volume=100)
		radio.listening = !radio.listening
		send_byjax(occupant,"exosuit.browser","rspkstate",(radio.listening?"Engaged":"Disengaged"))
		return
	if(href_list["rfreq"])
		if(usr != occupant)
			return
		usr << sound('sound/mecha/UI_SCI-FI_Tone_10_stereo.ogg',channel=4, volume=100)
		var/new_frequency = (radio.frequency + m_filter.getNum("rfreq"))
		if((radio.frequency < PUBLIC_LOW_FREQ || radio.frequency > PUBLIC_HIGH_FREQ))
			new_frequency = sanitize_frequency(new_frequency)
		radio.set_frequency(new_frequency)
		send_byjax(occupant,"exosuit.browser","rfreq","[format_frequency(radio.frequency)]")
		return
	if(href_list["view_log"])
		if(usr != occupant)
			return
		usr << sound('sound/mecha/UI_SCI-FI_Tone_10_stereo.ogg',channel=4, volume=100)
		occupant << browse(get_log_html(), "window=exosuit_log")
		onclose(occupant, "exosuit_log")
		return
	if(href_list["change_name"])
		if(usr != occupant)
			return
		var/newname = sanitizeSafe(input(occupant,"Choose new exosuit name","Rename exosuit",initial(name)) as text, MAX_NAME_LEN)
		if(newname)
			usr << sound('sound/mecha/UI_SCI-FI_Tone_Deep_Wet_22_stereo_complite.ogg',channel=4, volume=100)
			name = newname
		else
			alert(occupant, "nope.avi")
		return
	if(href_list["toggle_id_upload"])
		if(usr != occupant)
			return
		usr << sound('sound/mecha/UI_SCI-FI_Tone_10_stereo.ogg',channel=4, volume=100)
		add_req_access = !add_req_access
		send_byjax(occupant,"exosuit.browser","t_id_upload","[add_req_access?"L":"Unl"]ock ID upload panel")
		return
	if(href_list["toggle_maint_access"])
		if(usr != occupant)
			return
		if(state)
			usr << sound('sound/mecha/UI_SCI-FI_Tone_10_stereo.ogg',channel=4, volume=100);
			occupant_message("<font color='red'>Maintenance protocols in effect</font>")
			return
		maint_access = !maint_access
		send_byjax(occupant,"exosuit.browser","t_maint_access","[maint_access?"Forbid":"Permit"] maintenance protocols")
		return
	if(href_list["req_access"] && add_req_access)
		if(!in_range(src, usr))
			return
		usr << sound('sound/mecha/UI_SCI-FI_Tone_10_stereo.ogg',channel=4, volume=100)
		output_access_dialog(m_filter.getObj("id_card"),m_filter.getMob("user"))
		return
	if(href_list["maint_access"] && maint_access)
		if(!in_range(src, usr))
			return
		var/mob/user = m_filter.getMob("user")
		if(user)
			if(state==0)
				state = 1
				user << sound('sound/mecha/UI_SCI-FI_Tone_Deep_Wet_22_stereo_complite.ogg',channel=4, volume=100)
				to_chat(user, "The securing bolts are now exposed.")
			else if(state==1)
				state = 0
				user << sound('sound/mecha/UI_SCI-FI_Tone_Deep_Wet_22_stereo_complite.ogg',channel=4, volume=100)
				to_chat(user, "The securing bolts are now hidden.")
			output_maintenance_dialog(m_filter.getObj("id_card"),user)
		return
	if(href_list["set_internal_tank_valve"] && state >=1)
		if(!in_range(src, usr))
			return
		var/mob/user = m_filter.getMob("user")
		if(user)
			usr << sound('sound/mecha/UI_SCI-FI_Tone_10_stereo.ogg',channel=4, volume=100)
			var/new_pressure = input(user,"Input new output pressure","Pressure setting",internal_tank_valve) as num
			if(new_pressure)
				internal_tank_valve = new_pressure
				to_chat(user, "The internal pressure valve has been set to [internal_tank_valve]kPa.")
	if(href_list["remove_passenger"] && state >= 1)
		var/mob/user = m_filter.getMob("user")
		var/list/passengers = list()
		for(var/obj/item/mecha_parts/mecha_equipment/tool/passenger/P in contents)
			if(P.occupant)
				passengers["[P.occupant]"] = P

		if(!passengers)
			to_chat(user, SPAN_WARNING("There are no passengers to remove."))
			return

		var/pname = input(user, "Choose a passenger to forcibly remove.", "Forcibly Remove Passenger") as null|anything in passengers

		if(!pname)
			return

		var/obj/item/mecha_parts/mecha_equipment/tool/passenger/P = passengers[pname]
		var/mob/occupant = P.occupant

		user.visible_message(SPAN_NOTICE("\The [user] begins opening the hatch on \the [P]..."), SPAN_NOTICE("You begin opening the hatch on \the [P]..."))
		if(!do_after(user, 40, needhand = 0))
			return

		user.visible_message(SPAN_NOTICE("\The [user] opens the hatch on \the [P] and removes [occupant]!"), SPAN_NOTICE("You open the hatch on \the [P] and remove [occupant]!"))
		P.go_out()
		P.log_message("[occupant] was removed.")
		return
	if(href_list["add_req_access"] && add_req_access && m_filter.getObj("id_card"))
		if(!in_range(src, usr))
			return
		usr << sound('sound/mecha/UI_SCI-FI_Tone_10_stereo.ogg',channel=4, volume=100)
		operation_req_access += m_filter.getNum("add_req_access")
		output_access_dialog(m_filter.getObj("id_card"),m_filter.getMob("user"))
		return
	if(href_list["del_req_access"] && add_req_access && m_filter.getObj("id_card"))
		if(!in_range(src, usr))
			return
		usr << sound('sound/mecha/UI_SCI-FI_Tone_10_stereo.ogg',channel=4, volume=100)
		operation_req_access -= m_filter.getNum("del_req_access")
		output_access_dialog(m_filter.getObj("id_card"),m_filter.getMob("user"))
		return
	if(href_list["finish_req_access"])
		if(!in_range(src, usr))
			return
		usr << sound('sound/mecha/UI_SCI-FI_Tone_10_stereo.ogg',channel=4, volume=100)
		add_req_access = 0
		var/mob/user = m_filter.getMob("user")
		user << browse(null,"window=exosuit_add_access")
		return
	if(href_list["dna_lock"])
		if(usr != occupant)
			return
		if(occupant)
			usr << sound('sound/mecha/UI_SCI-FI_Compute_01_Wet_stereo.ogg',channel=4, volume=100)
			dna = occupant.dna.unique_enzymes
			occupant_message("You feel a prick as the needle takes your DNA sample.")
		return
	if(href_list["reset_dna"])
		if(usr != occupant)
			return
		usr << sound('sound/mecha/UI_SCI-FI_Tone_10_stereo.ogg',channel=4, volume=100)
		dna = null
		occupant_message("DNA-Lock disengaged.")
	if(href_list["maint_reset_dna"])
		if(dna_reset_allowed(usr))
			usr << sound('sound/mecha/UI_SCI-FI_Tone_10_stereo.ogg',channel=4, volume=100)
			to_chat(usr, SPAN_NOTICE("DNA-Lock has been reverted."))
			dna = null
		else
			usr << sound('sound/mecha/UI_SCI-FI_Tone_Deep_Wet_15_stereo_error.ogg',channel=4, volume=100)
			to_chat(usr, SPAN_WARNING("Invalid ID: Higher clearance is required."))
			return
	if(href_list["repair_int_control_lost"])
		if(usr != occupant)
			return
		occupant_message("Recalibrating coordination system.")
		log_message("Recalibration of coordination system started.")
		usr << sound('sound/mecha/UI_SCI-FI_Compute_01_Wet_stereo.ogg',channel=4, volume=100)
		var/T = loc
		if(do_after(usr, 10 SECONDS))
			if(T == loc)
				clearInternalDamage(MECHA_INT_CONTROL_LOST)
				occupant_message("<font color='blue'>Recalibration successful.</font>")
				usr << sound('sound/mecha/UI_SCI-FI_Tone_Deep_Wet_22_stereo_complite.ogg',channel=4, volume=100)
				log_message("Recalibration of coordination system finished with 0 errors.")
			else
				usr << sound('sound/mecha/UI_SCI-FI_Tone_Deep_Wet_15_stereo_error.ogg',channel=4, volume=100)
				occupant_message("<font color='red'>Recalibration failed.</font>")
				log_message("Recalibration of coordination system failed with 1 error.",1)
	if(href_list["drop_from_cargo"])
		if(usr != occupant)
			return
		var/obj/O = locate(href_list["drop_from_cargo"])
		if(O && (O in cargo))
			occupant_message(SPAN_NOTICE("You unload [O]."))
			O.forceMove(get_turf(src))
			cargo -= O
			O.reset_plane_and_layer()
			log_message("Unloaded [O]. Cargo compartment capacity: [cargo_capacity - cargo.len]")
