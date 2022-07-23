addEvent(g_SHOW_HOSPITAL_EVENT, true)
addEventHandler(g_SHOW_HOSPITAL_EVENT, localPlayer, function(id)
	local hospital = g_HOSPITAL_POSITIONS[id]
	local x = getElementData(hospital, "posX")
	local y = getElementData(hospital, "posY")
	local z = getElementData(hospital, "posZ")
	createMarker(x, y, z - 0.6, "cylinder", g_HOSPITAL_MARKER_SIZE, 254, 0, 0, 73)
	createMarker(x, y, z - 0.6, "cylinder", g_HOSPITAL_MARKER_SIZE + 0.5, 254, 0, 0, 65)
	createMarker(x, y, z - 0.6, "cylinder", g_HOSPITAL_MARKER_SIZE + 1, 254, 0, 0, 51)
	createBlip(x, y, z, 22, 1, 0, 0, 0, 255, 1, 1500)
end)

g_PatientMarkers = {}
addEvent(g_SHOW_PATIENT_EVENT, true)
addEventHandler(g_SHOW_PATIENT_EVENT, localPlayer, function(id)
	if g_PatientMarkers[id] then return end

	local x = getElementData(g_PATIENT_PICKUP_POSITIONS[id], "posX")
	local y = getElementData(g_PATIENT_PICKUP_POSITIONS[id], "posY")
	local z = getElementData(g_PATIENT_PICKUP_POSITIONS[id], "posZ")

	g_PatientMarkers[id] = {
		marker = createMarker(x, y, z - 0.6, "checkpoint", g_PATIENT_PICKUP_MARKER_SIZE, 0, 0, 200, 255),
		blip = createBlip(x, y, z, 0, 2, 0, 0, 200, 255, 2)
	}
end)

addEvent(g_HIDE_PATIENT_EVENT, true)
addEventHandler(g_HIDE_PATIENT_EVENT, localPlayer, function(id)
	-- possible to use x, y, z to remove the element instead of keeping track of?
	if not g_PatientMarkers[id] then return end

	destroyElement(g_PatientMarkers[id].marker)
	destroyElement(g_PatientMarkers[id].blip)

	g_PatientMarkers[id] = nil
end)

addEvent(g_PATIENTS_DROPPED_OFF_EVENT, true)
addEventHandler(g_PATIENTS_DROPPED_OFF_EVENT, localPlayer, function(numPatients)
	playSound("bloop.wav")
	drawText(g_RESCUED_TEXT, 3500)
end)

addEvent(g_PATIENT_PICKED_UP, true)
addEventHandler(g_PATIENT_PICKED_UP, localPlayer, function()
	playSound("blip.wav")
end)

addEvent(g_AMBULANCE_FULL_EVENT, true)
addEventHandler(g_AMBULANCE_FULL_EVENT, localPlayer, function(alreadyFull)
	drawText(g_AMBULANCE_FULL_TEXT, 3500)
end)

g_SpeedCheckTimer = nil
addEvent(g_START_SPEEDCHECK_EVENT, true)
addEventHandler(g_START_SPEEDCHECK_EVENT, localPlayer, function(timer)
	g_SpeedCheckTimer = timer
end)

addEvent(g_SUCCEED_SPEEDCHECK_EVENT, true)
addEventHandler(g_SUCCEED_SPEEDCHECK_EVENT, localPlayer, function()
end)

addEvent(g_FAIL_SPEEDCHECK_EVENT, true)
addEventHandler(g_FAIL_SPEEDCHECK_EVENT, localPlayer, function()
end)

addEvent(g_EXIT_SPEEDCHECK_EVENT, true)
addEventHandler(g_EXIT_SPEEDCHECK_EVENT, localPlayer, function()
	g_SpeedCheckStart = nil
end)

g_DrawStates = {}
g_GAMEMODE_DESCRIPTION_TEXT = "mawfeen sux"
g_AMBULANCE_FULL_TEXT = "me: 12 levels seems like too much"
g_RESCUED_TEXT = "him: but original paramedic has 12 levels"

function drawText(textKey, duration)
	g_DrawStates[textKey] = true
	setTimer(function ()
		g_DrawStates[textKey] = false
	end, duration, 1)
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	drawText(g_GAMEMODE_DESCRIPTION_TEXT, 12000)

	addEventHandler("onClientRender", root, function()
		local screenWidth, screenHeight = guiGetScreenSize()

		if g_DrawStates[g_GAMEMODE_DESCRIPTION_TEXT] then
			dxDrawText("Drive the patients to Hospital CAREFULLY. Each ", screenWidth / 2 - screenWidth / 5 + 3, screenHeight * 0.75 + 3, 800, screenHeight, tocolor(0, 0, 0, 255), 2.8, "default-bold")
			dxDrawText("Drive the #3344DBpatients #C8C8C8to #DE1A1AHospital #C8C8C8CAREFULLY. Each ", screenWidth / 2 - screenWidth / 5, screenHeight * 0.75, 800, screenHeight, tocolor(210, 210, 210, 255), 2.8, "default-bold", center, top, true, true, false, true)
			dxDrawText("bump reduces their chances of survival.", screenWidth / 2 - screenWidth / 6 + 3, screenHeight * 0.75 + 3 + 40, 800, screenHeight, tocolor(0, 0, 0, 255), 2.8, "default-bold")
			dxDrawText("bump reduces their chances of survival.", screenWidth / 2 - screenWidth / 6, screenHeight * 0.75 + 40, 800, screenHeight, tocolor(210, 210, 210, 255), 2.8, "default-bold")
		end

		if g_DrawStates[g_AMBULANCE_FULL_TEXT] then
			dxDrawText("Ambulance full!!", screenWidth / 2 - 117, screenHeight * 0.8 + 3,  screenWidth, screenHeight, tocolor(0, 0, 0, 255), 3, "default-bold")
			dxDrawText("Ambulance full!!", screenWidth / 2 - 120, screenHeight * 0.8,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 3, "default-bold")
		end

		if g_DrawStates[g_RESCUED_TEXT] then
			dxDrawText("RESCUED!", screenWidth / 2 - 198, screenHeight * 0.2 + 2,  screenWidth, screenHeight, tocolor(0, 0, 0, 255), 6, "arial",center)
			dxDrawText("RESCUED!", screenWidth / 2 - 202, screenHeight * 0.2 - 2,  screenWidth, screenHeight, tocolor(0, 0, 0, 255), 6, "arial")
			dxDrawText("RESCUED!", screenWidth / 2 - 200, screenHeight * 0.2,  screenWidth, screenHeight, tocolor(150, 120, 0, 255), 6, "arial")
		end

		local level = getElementData(localPlayer, "race.checkpoint") or 1
		local patients = 0
		for _ in pairs(g_PatientMarkers) do
			patients = patients + 1
		end

		dxDrawText("LEVEL                " .. level .. "/" .. g_NUM_LEVELS, screenWidth * 0.65 + 2, screenHeight * 0.25 + 2, screenWidth, screenHeight, tocolor(0, 0, 0, 255), 1, "bankgothic")
		dxDrawText("LEVEL                " .. level .. "/" .. g_NUM_LEVELS, screenWidth * 0.65, screenHeight * 0.25, screenWidth, screenHeight, tocolor(190, 222, 222, 255), 1, "bankgothic")
		dxDrawText("PATIENTS              " .. patients, screenWidth * 0.65 + 2, screenHeight * 0.28 + 2, screenWidth, screenHeight, tocolor(0, 0, 0, 255), 1, "bankgothic")
		dxDrawText("PATIENTS              " .. patients, screenWidth * 0.65, screenHeight * 0.28, screenWidth, screenHeight, tocolor(190, 222, 222, 255), 1, "bankgothic")
		dxDrawText("SEATS FREE          " .. g_OpenSeats, screenWidth * 0.65 + 2, screenHeight * 0.33 + 2, screenWidth, screenHeight, tocolor(0, 0, 0, 255), 1, "bankgothic")
		dxDrawText("SEATS FREE          " .. g_OpenSeats, screenWidth * 0.65, screenHeight * 0.33, screenWidth, screenHeight, tocolor(190, 222, 222, 255), 1, "bankgothic")

		if g_SpeedCheckTimer then -- pickup timer visualisationicator
			local timeLeft = getTimerDetails(g_SpeedCheckTimer)
			local percent = (g_SPEED_CHECK_INTERVAL - timeLeft) / g_SPEED_CHECK_INTERVAL

			local x, y, z = getElementVelocity(getPedOccupiedVehicle(localPlayer))
			local completeVelocity = x * x + y * y + z * z
			local redScale = math.min(math.max(completeVelocity - g_PICKUP_SPEED_LIMIT, 0) / (3 * g_PICKUP_SPEED_LIMIT), 1)
			local color = tocolor(200 * redScale, 200 * (1 - redScale), 0)

			dxDrawRectangle(screenWidth / 2 - 126, screenHeight * 0.85, 252, 27, tocolor(0, 0, 0))
			dxDrawRectangle(screenWidth / 2 - 122, screenHeight * 0.85 + 4, 244, 19, tocolor(40, 40, 40))
			dxDrawRectangle(screenWidth / 2 - 122, screenHeight * 0.85 + 4, 244 * percent, 19, color)
		end
	end)
end)