local QBCore = exports['qb-core']:GetCoreObject()
lib.locale()
GlobalState.AnimalsNPC = {}
-- Test commnent for testing

AddEventHandler('onResourceStart', function(resource)
	if resource ~= GetCurrentResourceName() then return end
end)

AddEventHandler('onResourceStop', function(resource)
   if resource ~= GetCurrentResourceName() then return end
    for _, ped in pairs(GlobalState.AnimalsNPC) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
    GlobalState.AnimalsNPC = {}
end)

-- create callback for creatinmg a ped
lib.callback.register('qwz_hunting:server:storePed', function(source, netId)
    local tmpPedList = GlobalState.AnimalsNPC
    local ped = NetworkGetEntityFromNetworkId(netId)
    while not DoesEntityExist(ped) do
        Wait(10)
    end
    tmpPedList[#tmpPedList+1] = ped
    GlobalState.AnimalsNPC = tmpPedList
    return true
end)

-- net event to get reward
lib.callback.register('qwz_hunting:server:getReward', function(source, rewards, netId)
    -- get ped from netId
    local ped = NetworkGetEntityFromNetworkId(netId)

    -- check if ped exists and not dead and cahce.ped is close to ped
    if not DoesEntityExist(ped) then return end
    if GetEntityHealth(ped) > 0 then return end
    local qPlayer = QBCore.Functions.GetPlayer(source)
    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)
    if #(GetEntityCoords(ped) - playerCoords) > 3.0 then return end

    local chanceToGet = math.random(1, 100)
    local getItems = {}
    for _, value in ipairs(rewards) do
        if chanceToGet <= value.chance then
            local count = math.random(value.min, value.max)
            if not qPlayer.Functions.AddItem(value.name, count) then
                -- trigger client notify notification event
                TriggerClientEvent('QBCore:Notify', source, locale('no_space'), 'error', 5000)
                break
            end
            getItems[#getItems+1] = {name = value.name, count = count} -- itemsGetCount = itemsGetCount + 1 -- value.name
        end
    end
    return getItems
end)

local UsedBaitList = {}
lib.callback.register("qwz_hunting:server:useBaitItem", function(source, itemName, amount)
    local qPlayer = QBCore.Functions.GetPlayer(source)
    if not UsedBaitList[qPlayer.PlayerData.citizenid] then
        UsedBaitList[qPlayer.PlayerData.citizenid] = true
        SetTimeout(Config.UsingBaitTimeount * 1000, function()
            UsedBaitList[qPlayer.PlayerData.citizenid] = false
        end)
        print('test', UsedBaitList[qPlayer.PlayerData.citizenid], amount or 1)
        return qPlayer.Functions.RemoveItem(itemName, amount or 1)
    else
        TriggerClientEvent('QBCore:Notify', source, locale('wait_timer'), 'error', 5000)
    end
end)

lib.callback.register("qwz_hunting:server:removeItem", function(source, itemName, amount)
    local qPlayer = QBCore.Functions.GetPlayer(source)
    return qPlayer.Functions.AddItem(itemName, amount or 1)
end)

lib.callback.register("qwz_hunting:server:addItem", function(source, itemName, amount)
    local qPlayer = QBCore.Functions.GetPlayer(source)
    return qPlayer.Functions.AddItem(itemName, amount or 1)
end)

lib.callback.register("qwz_hunting:server:getItemsAmount", function(source, itemName)
    local qPlayer = QBCore.Functions.GetPlayer(source)
    local items = qPlayer.Functions.GetItemsByName(itemName)
    local amount = 0
    if items and next(items) then
        for _, value in pairs(items) do
            amount += value.amount
        end
    end
    return amount
end)

QBCore.Functions.CreateUseableItem("huntingbait", function(source, item)
    TriggerClientEvent('qwz_hunting:client:useBait', source)
end)

