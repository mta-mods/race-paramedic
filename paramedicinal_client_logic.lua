g_PatientStates = {}
g_OpenSeats = g_MAX_PATIENTS_IN_VEHICLE
g_SpeedCheckState = nil -- we can only pick up once or drop off at a time

function getNewPatients()
	local level = getElementData(localPlayer, "race.checkpoint") or 1 -- relying on base race impl
	g_PatientStates = {}

	local range = #g_PATIENT_PICKUP_POSITIONS
	local maxPatients = g_PATIENTS_FOR_LEVEL(level)
	local numPatients = 0

	while numPatients < maxPatients do
		local rand = math.random(range)
		if not g_PatientStates[rand] then
			g_PatientStates[rand] = {
				pickedUp = false,
				marker = nil,
				blip = nil
			}
			numPatients = numPatients + 1
		end
	end

	drawPatientMarkers()
end

function drawPatientMarkers()
	for id, state in pairs(g_PatientStates) do
		if state.pickedUp then
			if g_PatientStates[id].marker then
				destroyElement(g_PatientStates[id].marker)
				g_PatientStates[id].marker = nil
			end
			if g_PatientStates[id].blip then
				destroyElement(g_PatientStates[id].blip)
				g_PatientStates[id].blip = nil
			end
		else
			local x = getElementData(g_PATIENT_PICKUP_POSITIONS[id], "posX")
			local y = getElementData(g_PATIENT_PICKUP_POSITIONS[id], "posY")
			local z = getElementData(g_PATIENT_PICKUP_POSITIONS[id], "posZ")

			if not g_PatientStates[id].marker then
				g_PatientStates[id].marker = createMarker(x, y, z - 0.6, "checkpoint", g_PATIENT_PICKUP_MARKER_SIZE, 0, 0, 200, 255)
			end
			if not g_PatientStates[id].blip then
				g_PatientStates[id].blip = createBlip(x, y, z, 0, 2, 0, 0, 200, 255, 2)
			end
		end
	end
end

function triggerSpeedCheck(onSuccessFn)
	if g_SpeedCheckState then
		removeSpeedCheck()
	end

	g_SpeedCheckState = setTimer(function()
		local x, y, z = getElementVelocity(getPedOccupiedVehicle(localPlayer))
		local completeVelocity = x * x + y * y + z * z
		if completeVelocity < g_PICKUP_SPEED_LIMIT then
			removeSpeedCheck()
			onSuccessFn()
			return
		end
	end, g_SPEED_CHECK_INTERVAL, 0)
end

function removeSpeedCheck()
	if not g_SpeedCheckState then return end

	killTimer(g_SpeedCheckState)
	g_SpeedCheckState = nil
end

function isPlayerVehicle(element)
	return getElementType(element) == "vehicle" and
		getPedOccupiedVehicle(localPlayer) == element
end

function validCollision(id, element)
	return isPlayerVehicle(element) and
		g_PatientStates[id] and
		not g_PatientStates[id].pickedUp
end

function initializeHospital(hospital)
	local x = getElementData(hospital, "posX")
	local y = getElementData(hospital, "posY")
	local z = getElementData(hospital, "posZ")
	createMarker(x, y, z - 0.6, "cylinder", g_HOSPITAL_MARKER_SIZE, 254, 0, 0, 73)
	createMarker(x, y, z - 0.6, "cylinder", g_HOSPITAL_MARKER_SIZE + 0.5, 254, 0, 0, 65)
	createMarker(x, y, z - 0.6, "cylinder", g_HOSPITAL_MARKER_SIZE + 1, 254, 0, 0, 51)
	createBlip(x, y, z, 22, 1, 0, 0, 0, 255, 1, 1500)

	local col = createColCircle(getElementData(hospital, "posX"), getElementData(hospital, "posY"), g_HOSPITAL_MARKER_SIZE)
	addEventHandler("onClientColShapeHit", col, function(element)
		if not isPlayerVehicle(element) then return end
		if g_OpenSeats == g_MAX_PATIENTS_IN_VEHICLE then return end

		triggerSpeedCheck(function()
			playSound("bloop.wav")
			g_OpenSeats = g_MAX_PATIENTS_IN_VEHICLE
			drawText(g_RESCUED_TEXT, 3500)

			for _, p in pairs(g_PatientStates) do
				if not p.pickedUp then return end
			end

			triggerEvent("onClientCall_race", root, "checkpointReached", element)
			local level = getElementData(localPlayer, "race.checkpoint")
			if level <= g_NUM_LEVELS then
				getNewPatients(level)
			end
		end)
	end)

	addEventHandler("onClientColShapeLeave", col, function(element)
		if not isPlayerVehicle(element) then return end
		removeSpeedCheck()
	end)
end

function initializePatient(id, p)
	local col = createColCircle(getElementData(p, "posX"), getElementData(p, "posY"), g_PATIENT_PICKUP_MARKER_SIZE)

	addEventHandler("onClientColShapeHit", col, function(element)
		if not validCollision(id, element) then return end
		if g_OpenSeats == 0 then
			drawText(g_AMBULANCE_FULL_TEXT, 3500)
			return
		end

		triggerSpeedCheck(function()
			playSound("blip.wav")
			g_PatientStates[id].pickedUp = true;
			drawPatientMarkers();

			g_OpenSeats = g_OpenSeats - 1
			if g_OpenSeats == 0 then drawText(g_AMBULANCE_FULL_TEXT, 3500) end
		end)
	end)

	addEventHandler("onClientColShapeLeave", col, function(element)
		if not validCollision(id, element) then return end
		removeSpeedCheck()
	end)
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	for _, h in pairs(g_HOSPITAL_POSITIONS) do
		initializeHospital(h)
	end

	for id, p in ipairs(g_PATIENT_PICKUP_POSITIONS) do
		initializePatient(id, p)
	end

	getNewPatients()
end)

addEventHandler("onClientPlayerWasted", localPlayer, function()
	g_OpenSeats = g_MAX_PATIENTS_IN_VEHICLE
	-- dying several times in a row w/o hitting a checkpoint puts you back without
	-- resetting patients so you'll have to pick up level + 1 patients for level
	for id, _ in pairs(g_PatientStates) do
		g_PatientStates[id].pickedUp = false
	end
	drawPatientMarkers()
end)

addEventHandler("onClientExplosion", root, function(x, y, z, t)
	if t == 4 then
		cancelEvent()
	end
end)