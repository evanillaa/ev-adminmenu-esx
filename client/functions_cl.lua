local Wait          = Wait
local CreateThread  = CreateThread
local PlayerPedId   = PlayerPedId


--[[The MIT License (MIT)
Copyright (c) 2017 IllidanS4
Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:
The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
]]

local entityEnumerator = {
  __gc = function(enum)
    if enum.destructor and enum.handle then
      enum.destructor(enum.handle)
    end
    enum.destructor = nil
    enum.handle = nil
  end
}

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
  return coroutine.wrap(function()
    local iter, id = initFunc()
    if not id or id == 0 then
      disposeFunc(iter)
      return
    end
    
    local enum = {handle = iter, destructor = disposeFunc}
    setmetatable(enum, entityEnumerator)
    
    local next = true
    repeat
      coroutine.yield(id)
      next, id = moveFunc(iter)
    until not next
    
    enum.destructor, enum.handle = nil, nil
    disposeFunc(iter)
  end)
end

function EnumerateObjects()
  return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

function EnumeratePeds()
  return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

function EnumerateVehicles()
  return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end




--[[START CODE HERE. ENUMERATOR ABOVE]]

local noClip, noClipSpeed, noClipVelocity = false, Config.noClipSpeed, 0.05
local noClipMin, noClipMax, noClipSum, noClipMath = 0.1,  10.0, 0.25, math.pi/180.0
local isRendering = false
local invincible, invisible = false, false

-- Draw buttons
local function buttonMessage(text)
  BeginTextCommandScaleformString("STRING")
  AddTextComponentScaleform(text)
  EndTextCommandScaleformString()
end

local function controlButton(ControlButton)
  N_0xe83a3e3557a56640(ControlButton)
end

local function runScaleform(scaleform)
  local scaleform = RequestScaleformMovie(scaleform)
  while not HasScaleformMovieLoaded(scaleform) do
    Wait(1)
  end
  PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
  PopScaleformMovieFunctionVoid()

  PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
  PushScaleformMovieFunctionParameterInt(4)
  controlButton(GetControlInstructionalButton(2, 32, true))
  buttonMessage("Forward")
  PopScaleformMovieFunctionVoid()

  PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
  PushScaleformMovieFunctionParameterInt(3)
  controlButton(GetControlInstructionalButton(2, 33, true))
  buttonMessage("Backward")
  PopScaleformMovieFunctionVoid()

  PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
  PushScaleformMovieFunctionParameterInt(2)
  controlButton(GetControlInstructionalButton(2, 105, true))
  buttonMessage("Reset")
  PopScaleformMovieFunctionVoid()

  PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
  PushScaleformMovieFunctionParameterInt(1)
  controlButton(GetControlInstructionalButton(2, 46, true))
  buttonMessage("+ Speed")
  PopScaleformMovieFunctionVoid()

  PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
  PushScaleformMovieFunctionParameterInt(0)
  controlButton(GetControlInstructionalButton(2, 44, true))
  buttonMessage("- Speed")
  PopScaleformMovieFunctionVoid()

  PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
  PopScaleformMovieFunctionVoid()

  return scaleform

end

local function renderScaleform(scaleform)
  DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
end

-- Draw buttons scaleform
function scaleForm()
  if not isRendering then
    isRendering = true
  else
    isRendering = false
  end
end

if Config.drawButtons then
  CreateThread(function()
    local initalizedScaleform = runScaleform("instructional_buttons")
    while true do 
      if isRendering then
        renderScaleform(initalizedScaleform)
      end
      Wait(5)
    end
  end)
end

-- Fix current vehicle
function vehicleFix()
  local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
  if IsPedInVehicle(PlayerPedId(), vehicle, false) then
    SetVehicleDirtLevel(vehicle, 0)
    SetVehicleFixed(vehicle)
    SetVehicleDeformationFixed(vehicle)
    SetVehicleUndriveable(vehicle, false)
    SetVehicleEngineOn(vehicle, true, true)
    if Config.tNotify then
        
    elseif Config.esxNotify then

    elseif Config.debugNotify then
      print("Vehicle has been fixed")
    end
  else
    if Config.tNotify then
    
    elseif Config.esxNotify then

    elseif Config.debugNotify then
      print("Not in a vehicle \nState: " .. tostring(IsPedInAnyVehicle(PlayerPedId(), false)))
    end
  end
end

-- Delete vehicle
function vehicleDelete()
  local ped = PlayerPedId()
  if IsPedInAnyVehicle(ped, false) then
    local vehicle = GetVehiclePedIsIn(ped, false)
    SetEntityAsMissionEntity(vehicle, false, false)
    DeleteVehicle(vehicle)
    if Config.tNotify then
    
    elseif Config.esxNotify then

    elseif Config.debugNotify then
        print("Current vehicle deleted")
    end
  elseif not IsPedInAnyVehicle(ped, false) then
    local coordA, coordB = GetEntityCoords(ped), GetOffsetFromEntityInWorldCoords(ped, 0.0, 5.0, 0.0)
    local closestVeh = getVehicleInDirection(coordA, coordB)
    if DoesEntityExist(closestVeh) then
      SetEntityAsMissionEntity(closestVeh, false, false)
      DeleteVehicle(closestVeh)
      if Config.tNotify then
  
      elseif Config.esxNotify then

      elseif Config.debugNotify then
        print("Vehicle deleted\nState: " .. closestVeh)
      end
    else
      if Config.tNotify then
  
      elseif Config.esxNotify then

      elseif Config.debugNotify then
        print("No vehicle found\nState: " .. closestVeh)
      end
    end
  end
end

-- Find vehicle in direction
function getVehicleInDirection(coordFrom, coordTo)
	local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, PlayerPedId(), 0)
	local a, b, c, d, vehicle = GetRaycastResult(rayHandle)
	return vehicle
end

-- Set player model
function setPlayerModel(model)
  if IsModelInCdimage(model) then
    while not HasModelLoaded(model) do
      Wait(50)
      RequestModel(model)
    end
    SetPlayerModel(PlayerId(), model)
  else
      if Config.tNotify then
      
      elseif Config.esxNotify then
        
      elseif Config.debugNotify then
          print("Wrong model:" .. model .. "\nCurrent model:" .. GetPlayerPed())
      end
  end
end
-- Cam direction function
local function camDirection()
  local heading, pitch = GetGameplayCamRelativeHeading() + GetEntityHeading(PlayerPedId()), GetGameplayCamRelativePitch()
  local x, y, z = -math.sin(noClipMath * heading), math.cos(noClipMath * heading), math.sin(noClipMath * pitch) -- Math.pi = 3.14, 180 = Turn around. Cos Angle = Adj / Hypotenuse. Sin = Opposite / Hypotenuse
  local l = math.sqrt(x * x + y * y + z * z)
  if l ~= 0 then -- Need to test this at home since I believe it might not do anything.
    x, y, z = x / l, y / l, z / l
  end
  return x, y, z
end

-- Noclip thread
CreateThread(function()
	while true do
		Wait(35)
		if noClip then
      local ped = nil
      if IsPedInAnyVehicle(PlayerPedId(), false) then
        ped = GetVehiclePedIsIn(PlayerPedId(), false)
      else 
        ped = PlayerPedId()
      end
			local x, y, z = table.unpack(GetEntityCoords(ped))
			local headingX, headingY, headingZ = camDirection() -- Returns X, Y, Z Headings
      if (noClipSpeed < noClipMax) and (noClipSpeed > noClipMin) then
        if IsControlPressed(0, 46) then
          noClipSpeed = noClipSpeed + noClipSum
        elseif IsControlPressed(0, 44) then
          noClipSpeed = noClipSpeed - noClipSum
        end
      else
        if (noClipSpeed >= noClipMax) then
          if Config.tNotify then

          elseif Config.esxNotify then
  
          elseif Config.debugNotify then
            print('Max Speed: ' .. noClipSpeed)
          end
          noClipSpeed = noClipMax - 0.1
        elseif (noClipSpeed <= noClipMin) then
          if Config.tNotify then

          elseif Config.esxNotify then
  
          elseif Config.debugNotify then
            print('Min Speed: ' .. noClipSpeed)
          end
          noClipSpeed = noClipSpeed + 0.1
        end
      end
			if IsControlPressed(0, 32) then
				x, y, z = x + noClipSpeed * headingX, y + noClipSpeed * headingY, z + noClipSpeed * headingZ
			elseif IsControlPressed(0, 33) then
				x, y, z = x - noClipSpeed * headingX, y - noClipSpeed * headingY, z - noClipSpeed * headingZ
      elseif IsControlPressed(0, 105) then
        if Config.tNotify then

        elseif Config.esxNotify then

        elseif Config.debugNotify then
          print("Speed was reset: " .. noClipSpeed)
        end
        noClipSpeed = 1.0
			end
			SetEntityCoordsNoOffset(ped, x, y, z, true, true, true)
    end
	end
end)

-- Noclip
function setPedNoclip()
  local ped = PlayerPedId()
	if not noClip then
    noClip = true
    if (not invisible and IsEntityVisible(ped)) then
        SetEntityVisible(ped, false, false)
    end
    SetEntityVelocity(ped, noClipVelocity, noClipVelocity, noClipVelocity)
    if Config.tNotify then
    
    elseif Config.esxNotify then

    elseif Config.debugNotify then
      print("NoClip State: " .. tostring(noClip))
    end
    scaleForm() -- Turn on Buttons
	else
    noClip = false
    if (not invisible and not IsEntityVisible(ped)) then
        SetEntityVisible(ped, true, false)
    end
    if Config.tNotify then
    
    elseif Config.esxNotify then

    elseif Config.debugNotify then
      print("NoClip State: " .. tostring(noClip))
    end
    scaleForm() -- Turn off Buttons
  end
end

-- Invincible
function setPedInvincible()
  local ped = PlayerPedId()
	if not invincible then
    invincible = true
    SetEntityInvincible(ped, true)
    SetPedCanRagdoll(ped, false)
    if Config.tNotify then
    
    elseif Config.esxNotify then

    elseif Config.debugNotify then
      print("Invincible State: " ..  tostring(invincible))
    end
	else
    invincible = false
    SetEntityInvincible(ped, false)
    SetPedCanRagdoll(ped, true)
    if Config.tNotify then
    
    elseif Config.esxNotify then

    elseif Config.debugNotify then
      print("Invincible State: " ..  tostring(invincible))
    end
  end
end

-- Invisible
function setPedInvisible()
  local ped = PlayerPedId()
	if not invisible then
    invisible = true
    SetEntityVisible(ped, false, false)
    if Config.tNotify then
    
    elseif Config.esxNotify then

    elseif Config.debugNotify then
        print("Invisible State: " .. tostring(invisible))
    end
	else
    if not noClip then
      invisible = false
      SetEntityVisible(ped, true, false)
      if Config.tNotify then
  
      elseif Config.esxNotify then

      elseif Config.debugNotify then
        print("Invisible State: " ..  tostring(invisible))
      end
    else
      if Config.tNotify then
  
      elseif Config.esxNotify then

      elseif Config.debugNotify then
        print("Currently in NoClip")
      end
    end
  end
end

-- Teleport to marker
function teleportToMarker()
  local marker = GetFirstBlipInfoId(8)
  if DoesBlipExist(marker) then
    local coords = GetBlipInfoIdCoord(marker)
    for i = 1, 1000 do
      SetPedCoordsKeepVehicle(PlayerPedId(), coords.x, coords.y, i + 0.0)
      local zCoords = GetGroundZFor_3dCoord(coords.x, coords.y, i + 0.0)
      if zCoords then
        SetPedCoordsKeepVehicle(PlayerPedId(), coords.x, coords.y, i + 0.0)
        break
      end
      Wait(15)
    end
  else
    print("No blip")
  end
end

-- Teleport to the closest vehicle
function findVehicle()
  local ped = PlayerPedId()
  local coords = GetEntityCoords(ped)
  local vehClose = GetClosestVehicle(coords, 1000.0, 0, 4)
  local vehCloseCoords = GetEntityCoords(vehClose)
  local airClose = GetClosestVehicle(coords, 1000.0, 0, 10000)
  local airCloseCoords = GetEntityCoords(airClose)
  local driverPed = GetPedInVehicleSeat(vehClose, -1)
  print("Wait 2 second")
  Wait(2500)
  if (vehClose == 0) and (airClose == 0) then
    print("No vehicle found")
  elseif (vehClose == 0) and (airClose ~= 0) then
    if IsVehicleSeatFree(airClose, -1) then
      SetPedIntoVehicle(ped, airClose, -1)
      SetVehicleDoorsLocked(airClose, 1)
      SetVehicleNeedsToBeHotwired(airClose, false)
    else
      ClearPedTasksImmediately(driverPed)
      SetEntityAsMissionEntity(driverPed, 1, 1)
      DeleteEntity(driverPed)
      SetPedIntoVehicle(ped, airClose, -1)
      SetVehicleDoorsLocked(airClose, 1)
      SetVehicleNeedsToBeHotwired(airClose, false)
    end
  elseif (vehClose ~= 0) and (airClose == 0) then
    if IsVehicleSeatFree(vehClose, -1) then
      SetPedIntoVehicle(ped, vehClose, -1)
      SetVehicleDoorsLocked(vehClose, 1)
      SetVehicleNeedsToBeHotwired(vehClose, false)
    else
      SetEntityAsMissionEntity(driverPed, 1, 1)
      DeleteEntity(driverPed)
      SetPedIntoVehicle(ped, vehClose, -1)
      SetVehicleDoorsLocked(vehClose, 1)
      SetVehicleNeedsToBeHotwired(vehClose, false)
    end
  elseif (vehClose ~= 0) and (airClose ~= 0) then
    if #(vector3(vehCloseCoords) - vector3(airCloseCoords)) then
      if IsVehicleSeatFree(vehClose, -1) then
        SetPedIntoVehicle(ped, vehClose, -1)
        SetVehicleDoorsLocked(vehClose, 1)
        SetVehicleNeedsToBeHotwired(vehClose, false)
      else
        SetEntityAsMissionEntity(driverPed, 1, 1)
        DeleteEntity(driverPed)
        SetPedIntoVehicle(ped, vehClose, -1)
        SetVehicleDoorsLocked(vehClose, 1)
        SetVehicleNeedsToBeHotwired(vehClose, false)
      end
    elseif #(vector3(vehCloseCoords) - vector3(airCloseCoords)) then
      if IsVehicleSeatFree(airClose, -1) then
        SetPedIntoVehicle(ped, airClose, -1)
        SetVehicleDoorsLocked(airClose, 1)
        SetVehicleNeedsToBeHotwired(airClose, false)
      else
        SetEntityAsMissionEntity(driverPed, 1, 1)
        DeleteEntity(driverPed)
        SetPedIntoVehicle(ped, airClose, -1)
        SetVehicleDoorsLocked(airClose, 1)
        SetVehicleNeedsToBeHotwired(airClose, false)
      end
    end
  end
end