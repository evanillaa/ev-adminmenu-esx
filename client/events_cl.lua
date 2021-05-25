local Wait          = Wait
local PlayerPedId   = PlayerPedId

local freeze = false

-- Delete all
RegisterNetEvent('pe_admin:delAll')
AddEventHandler('pe_admin:delAll', function(action)
    if action == "veh" then
        for vehicle in EnumerateVehicles() do
            if not IsPedAPlayer(GetPedInVehicleSeat(vehicle, -1)) then
                SetVehicleHasBeenOwnedByPlayer(vehicle, false)
                SetEntityAsMissionEntity(vehicle, false, false)
                DeleteVehicle(vehicle)
                if DoesEntityExist(vehicle) then
                    DeleteVehicle(vehicle)
                end
            end
        end
    elseif action == "obj" then
        for object in EnumerateObjects() do
            SetEntityAsMissionEntity(object, false, false)
            DeleteObject(object)
            if DoesEntityExist(object) then 
                DeleteObject(object)
            end
        end
    elseif action == "peds" then
        for ped in EnumeratePeds() do
            if not IsPedAPlayer(ped) then
                DeleteEntity(ped)
                RemoveAllPedWeapons(ped, true)
                if DoesEntityExist(ped) then
                    DeleteVehicle(ped)
                end
            end
        end
    end
end)

-- Freeze target
RegisterNetEvent('pe_admin:freezeTarget')
AddEventHandler('pe_admin:freezeTarget', function()
	local ped = PlayerPedId()
	if not freeze then
		SetEntityCollision(ped, false)
		FreezeEntityPosition(ped, true)
		SetPlayerInvincible(ped, true)
		ClearPedTasksImmediately(ped, true)
		RequestAnimDict("amb@world_human_jog_standing@female@idle_a")
			while not HasAnimDictLoaded("amb@world_human_jog_standing@female@idle_a") do
				Wait(10)
			end
		TaskPlayAnim(ped, "amb@world_human_jog_standing@female@idle_a", "idle_a", -25.0, -8.0, -1, 1, 0, false, false, false)
        freeze = true
	else
		SetEntityCollision(ped, true)
		FreezeEntityPosition(ped, false)  
		SetPlayerInvincible(ped, false)
		ClearPedTasksImmediately(ped, false)
        EnableAllControlActions(0)
        freeze = false
	end
end)

-- Revive and heal target
RegisterNetEvent('pe_admin:reviveHealTarget')
AddEventHandler('pe_admin:reviveHealTarget', function(action)
	local ped = PlayerPedId()
    local coords, heading = GetEntityCoords(ped), GetEntityHeading(ped)
    if action == "revive" then
        if IsEntityDead(ped) then
            NetworkResurrectLocalPlayer(coords, heading, false, false)
        end
    elseif action == "kill" then
        SetEntityHealth(ped, 0)
    end
end)