ESX = nil 

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local createAutomobile = GetHashKey("CREATE_AUTOMOBILE")

-- Get player list
ESX.RegisterServerCallback('pe_admin:playersOnline', function(source, cb)
    local src = source
	local currentPlayers = GetPlayers()
	local players  = {}
	for i = 1, #currentPlayers, 1 do
		table.insert(players, {
			source      = tonumber(currentPlayers[i]),
			identifier  = GetPlayerIdentifier(currentPlayers[i], 1),
            name        = GetPlayerName(currentPlayers[i]),
            health      = GetEntityHealth(GetPlayerPed(currentPlayers[i])),
            armor       = GetPedArmour(GetPlayerPed(currentPlayers[i]))
		})
	end
	cb(players)
end)

-- Send an announcement
RegisterServerEvent('pe_admin:sendAnnouncement', function(title, message, duration)
    local currentPlayers = GetPlayers()
    for i = 1, #currentPlayers, 1 do
        TriggerClientEvent('t-notify:client:Custom', currentPlayers[i], {
            style       =  'info',
            duration    =  duration * 1000,
            title       =  title,
            message     =  message,
            sound       =  true
        })
    end
end)

-- Delete all vehicles
RegisterServerEvent('pe_admin:delAll', function(action)
    if action == "veh" then
        TriggerClientEvent('pe_admin:delAll', -1, "veh")
    elseif action == "peds" then
        TriggerClientEvent('pe_admin:delAll', -1, "peds")
    elseif action == "obj" then
        TriggerClientEvent('pe_admin:delAll', -1, "obj")
    elseif action == "chat" then
        TriggerClientEvent('chat:clear', -1)
    end
end)

-- Freeze target
RegisterServerEvent('pe_admin:freezeTarget', function(targetSource)
    local targetSource = tonumber(targetSource)
    TriggerClientEvent('pe_admin:freezeTarget', targetSource)
end)

-- Freeze All
RegisterServerEvent('pe_admin:freezeAll', function()
	local currentPlayers = GetPlayers()
	for i = 1, #currentPlayers, 1 do
        TriggerClientEvent('pe_admin:freezeTarget', currentPlayers[i])
	end
end)

-- Freeze Zone
RegisterServerEvent('pe_admin:freezeZone', function(frozenArea, x, y, z, radius)
	local currentPlayers = GetPlayers()
    if frozenArea then
	    for i = 1, #currentPlayers, 1 do
            local ped = GetPlayerPed(currentPlayers[i])
            local coords = GetEntityCoords(ped)
            local marker = vector3(-305.75, -981.08, 30.08)
            local distance =  #(coords - vector3(x, y, z))
            if (distance < radius) then
                FreezeEntityPosition(ped, true)
            end
	    end
    elseif not frozenArea then
        for i = 1, #currentPlayers, 1 do
            local ped = GetPlayerPed(currentPlayers[i])
            local coords = GetEntityCoords(ped)
            FreezeEntityPosition(ped, false)
        end
    end
end)

-- Heal/Revive/Kill target
RegisterServerEvent('pe_admin:reviveHealTarget', function(targetSource, action)
    local targetSource = tonumber(targetSource)
    if action == "revive" then
        TriggerClientEvent('pe_admin:reviveHealTarget', targetSource, "revive")
    elseif action == "kill" then
        TriggerClientEvent('pe_admin:reviveHealTarget', targetSource, "kill")
    end
end)

-- Revive all
RegisterServerEvent('pe_admin:reviveAll', function(action)
    local currentPlayers = GetPlayers()
    for i = 1, #currentPlayers, 1 do
        local ped = GetPlayerPed(currentPlayers[i])
        if (GetEntityHealth(ped) <= 0) then
            TriggerClientEvent('pe_admin:reviveHealTarget', currentPlayers[i], "revive")
        end
    end
end)

-- Go to target
RegisterServerEvent('pe_admin:tpToTarget', function(targetSource)
    local src = source
    local ped = GetPlayerPed(src)
    local targetPed = GetPlayerPed(targetSource)
    local coords = GetEntityCoords(targetPed)
    SetEntityCoords(ped, coords, false, false, false, true)
end)

-- Bring Target
RegisterServerEvent('pe_admin:tpTarget', function(targetSource)
    local src = source
    local ped = GetPlayerPed(src)
    local targetPed = GetPlayerPed(targetSource)
    local coords = GetEntityCoords(ped)
    SetEntityCoords(targetPed, coords, false, false, false, true)
end)

-- Bring All
RegisterServerEvent('pe_admin:bringAll', function()
	local currentPlayers = GetPlayers()
    local ped = GetPlayerPed(source)
	for i = 1, #currentPlayers, 1 do
        local targetPed = GetPlayerPed(currentPlayers[i])
        local coords = GetEntityCoords(targetPed)
        SetEntityCoords(ped, coords, false, false, false, true)
	end
end)

-- Kick Player
RegisterServerEvent('pe_admin:kickTarget', function(targetSource, message)
    local targetSource = tonumber(targetSource)
    if message == nil then
        DropPlayer(targetSource, "Reason: No reason given")
    else
        DropPlayer(targetSource, "Reason: " .. message)
    end
end)

-- Kick All
RegisterServerEvent('pe_admin:kickAll', function(message)
	local currentPlayers = GetPlayers()
	for i = 1, #currentPlayers, 1 do
        if message == nil then
            DropPlayer(currentPlayers[i], "Reason: No reason given")
        else
            DropPlayer(currentPlayers[i], "Reason: " .. message)
        end
	end
end)


-- Spawn vehicle
RegisterNetEvent('pe_admin:spawnVehicle', function(targetSource, modelHash, action)
    if action == "self" then
        if targetSource == "source" then
            targetSource = source
        end
        local ped = GetPlayerPed(targetSource)
        local coords, heading = GetEntityCoords(ped), GetEntityHeading(ped)
        local vehicle = Citizen.InvokeNative(createAutomobile, GetHashKey(modelHash), coords.x, coords.y, coords.z - 0.5, heading, true, false)
        while GetVehiclePedIsIn(ped) ~= vehicle do
            Wait(50)
            SetPedIntoVehicle(ped, vehicle, -1)
        end
        if not DoesEntityExist(vehicle) then 
            return nil 
        end
        local entityState = Entity(vehicle).state
        entityState:set('owner', GetPlayerName(targetSource), true)
        entityState:set('finishedSpawning', false, true)
        while NetworkGetEntityOwner(vehicle) ~= targetSource do
            Wait(50)
        end

        return NetworkGetNetworkIdFromEntity(vehicle), vehicle
    elseif action == "target" then
        local ped = GetPlayerPed(targetSource)
        local coords, heading = GetEntityCoords(ped), GetEntityHeading(ped)
        if heading >= 180 then
            if heading >= 270 then
                local vehicle = Citizen.InvokeNative(createAutomobile, GetHashKey(modelHash), coords.x + math.pi, coords.y + math.pi, coords.z - 0.5, heading, true, false) -- North
            else
                local vehicle = Citizen.InvokeNative(createAutomobile, GetHashKey(modelHash), coords.x + math.pi, coords.y - math.pi, coords.z - 0.5, heading, true, false) -- Right
            end
        else
            if heading >= 90 then
                local vehicle = Citizen.InvokeNative(createAutomobile, GetHashKey(modelHash), coords.x - math.pi, coords.y - math.pi, coords.z - 0.5, heading, true, false) -- South
            else
                local vehicle = Citizen.InvokeNative(createAutomobile, GetHashKey(modelHash), coords.x - math.pi, coords.y + math.pi, coords.z - 0.5, heading, true, false) -- Left
            end
        end
        if not DoesEntityExist(vehicle) then 
            return nil 
        end
        local entityState = Entity(vehicle).state
        entityState:set('owner', GetPlayerName(source), true)
        entityState:set('finishedSpawning', false, true)
        while NetworkGetEntityOwner(vehicle) ~= source do
            Wait(50)
        end

        return NetworkGetNetworkIdFromEntity(vehicle), vehicle
    end
end)

-- Get information
RegisterServerEvent('pe_admin:getInformation', function(targetSource)
    local source = source
    local targetSource = tonumber(targetSource)
    local targetPed = GetPlayerPed(targetSource)
    local targetCoords = GetEntityCoords(targetPed)
    local id = getIdentifiers(targetSource)
    local isWalking
    if GetVehiclePedIsIn(targetPed, false) ~= 0 then isWalking = "In vehicle" else isWalking = "On foot" end
    if Config.esxExtra then
        local xPlayer = ESX.GetPlayerFromId(targetSource)
        sendDiscord(
            Config.infoWebhook,
            "**Player Information** -- *Requested by " .. GetPlayerName(source) .. " | ID: " .. tonumber(source) .. "*",
            "__Basic Player Information__\n ```Player ID: " .. targetSource .. "\nPlayer Name: " .. 
            GetPlayerName(targetSource) .. "\nPlayer Health: " .. GetEntityHealth(targetPed) .. "\nPlayer Shield: " .. GetPedArmour(targetPed) .. 
            "\nPlayer State: " .. isWalking .. "\nPlayer coords: " .. targetCoords .. "```\n __ESX Player Information__\n```Character group: " .. 
            xPlayer.getGroup() .. "\nCharacter Job: " .. xPlayer.getJob().label .. "\nCharacter Job Rank: " .. xPlayer.getJob().grade_label .. 
            "\nCharacter Money: $" .. xPlayer.getAccount('money').money .. "\nCharacter Bank: $" .. xPlayer.getAccount('bank').money .. 
            "\nCharacter Black Money: $" .. xPlayer.getAccount('black_money').money .. "\nCharacter Name: " .. xPlayer.getName() .. "\nCharacter Sex: "
            .. xPlayer.get('sex') .. "\nCharacter DOB: " .. xPlayer.get('dateofbirth') .. "\nCharacter Height: " .. xPlayer.get('height') ..
            "in```\n __ESX Inventory Information__\n```Inventory: " .. json.encode(xPlayer.getInventory(true)) .. "\nLoadout: " ..
            json.encode(xPlayer.getLoadout()) .. "```\n __Player identifiers__\n```License: "  .. id.license .. 
            "\nLicense2: ".. id.license2 .. "\nXbl: " .. id.xbl .. "\nLive: " .. id.live .. "\nDiscord: " .. id.discord .. "\nSteamHex: " ..
            id.steam .. "\nFivem: " .. id.fivem .. "\nIP: " .. id.ip .. "```",
            nil,
            3447003
        )
    else
        sendDiscord(
            Config.infoWebhook,
            "**Player Information** -- *Requested by " .. GetPlayerName(source) .. " | ID: " .. tonumber(source) .. "*",
            "__Basic Player Information__\n ```Player ID: " .. targetSource .. "\nPlayer Name: " .. 
            GetPlayerName(targetSource) .. "\nPlayer Health: " .. GetEntityHealth(targetPed) .. "\nPlayer Shield: " .. GetPedArmour(targetPed) .. 
            "\nPlayer State: " .. isWalking .. "\nPlayer coords: " .. targetCoords .. "```\n __Player identifiers__\n```License: "  .. id.license .. 
            "\nLicense2: ".. id.license2 .. "\nXbl: " .. id.xbl .. "\nLive: " .. id.live .. "\nDiscord: " .. id.discord .. "\nSteamHex: " ..
            id.steam .. "\nFivem: " .. id.fivem .. "\nIP: " .. id.ip .. "```",
            nil,
            3447003
        )
    end
end)