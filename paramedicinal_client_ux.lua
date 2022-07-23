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
		for _, p in pairs(g_PatientStates) do
			if not p.pickedUp then
				patients = patients + 1
			end
		end
		dxDrawText("LEVEL                " .. level .. "/" .. g_NUM_LEVELS, screenWidth * 0.65 + 2, screenHeight * 0.25 + 2, screenWidth, screenHeight, tocolor(0, 0, 0, 255), 1, "bankgothic")
		dxDrawText("LEVEL                " .. level .. "/" .. g_NUM_LEVELS, screenWidth * 0.65, screenHeight * 0.25, screenWidth, screenHeight, tocolor(190, 222, 222, 255), 1, "bankgothic")
		dxDrawText("PATIENTS              " .. patients, screenWidth * 0.65 + 2, screenHeight * 0.28 + 2, screenWidth, screenHeight, tocolor(0, 0, 0, 255), 1, "bankgothic")
		dxDrawText("PATIENTS              " .. patients, screenWidth * 0.65, screenHeight * 0.28, screenWidth, screenHeight, tocolor(190, 222, 222, 255), 1, "bankgothic")
		dxDrawText("SEATS FREE          " .. g_OpenSeats, screenWidth * 0.65 + 2, screenHeight * 0.33 + 2, screenWidth, screenHeight, tocolor(0, 0, 0, 255), 1, "bankgothic")
		dxDrawText("SEATS FREE          " .. g_OpenSeats, screenWidth * 0.65, screenHeight * 0.33, screenWidth, screenHeight, tocolor(190, 222, 222, 255), 1, "bankgothic")

		if g_SpeedCheckState then -- pickup timer visualisationicator
			local timeToCheck = getTimerDetails(g_SpeedCheckState)
			local percent = (g_SPEED_CHECK_INTERVAL - timeToCheck) / g_SPEED_CHECK_INTERVAL

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