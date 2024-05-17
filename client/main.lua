QBCore = exports['qb-core']:GetCoreObject()
lib.locale()
local isInHuntingZone = false

local function createInputMenu(itemName, itemPrice)
    local itemLabel = QBCore.Shared.Items[itemName].label
    local itemsCount = lib.callback.await('qwz_hunting:server:getItemsAmount', false, itemName)
    if itemsCount <= 0 then
        return QBCore.Functions.Notify(locale('failed_to_remove_item') .. itemLabel, 'error')
    end

    local input = lib.inputDialog(locale('sell_menu_title'), {
        {type = 'slider', label = locale('sell_menu_amount'), description = locale('sell_menu_amount_description'), required = true, min = 1, max = itemsCount, default = 1, step = 1},
    })
    if not input then return end

    local removed = lib.callback.await('qwz_hunting:server:removeItem', false, itemName, input[1])
    if not removed then
        return QBCore.Functions.Notify(locale('failed_to_remove_item') .. itemLabel, 'error')
    end
    local added = lib.callback.await('qwz_hunting:server:addItem', false, Config.MoneyItem, itemPrice * input[1])
    if not added then return end
    QBCore.Functions.Notify(locale('success_selling_item') .. itemLabel, 'success')
end


local function createItemsMenu(items)
    local itemsOptions = {}
    for _, itemData in ipairs(items) do
        itemsOptions[#itemsOptions+1] = {
            title = locale('sell_menu_item') .. QBCore.Shared.Items[itemData.name].label .. ' - ' .. itemData.price .. '$',
            description = QBCore.Shared.Items[itemData.name].description,
            icon = 'arrow-left',
            onSelect = function()
                createInputMenu(itemData.name, itemData.price)
            end,
        }
    end

    lib.registerContext({
        id = 'sell_animal_rewards',
        title = locale("sell_animal_rewards"),
        options = itemsOptions
    })
end
local function InitShopData()
    for key, value in pairs(Config.ShopData) do
        local pedModel = GetHashKey(value.pedModel)
        lib.requestModel(pedModel)

        local ped = CreatePed(4, pedModel, value.coords.x, value.coords.y, value.coords.z -0.98, value.coords.w, false, false)
        SetEntityInvincible(ped, true)
        FreezeEntityPosition(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)

        createItemsMenu(value.items)
        if Config.UseQBTarget then
            local options = {
                label = locale('open_shop'),
                name = 'open_shop',
                distance = 2.0,
                canInteract = function (entity, distance, data)
                    return true -- Get Ped is Animal (28 type)
                end,
                action = function (entity)
                    lib.showContext('sell_animal_rewards')
                end
            }
            exports['qb-target']:AddTargetEntity(ped, {options = {options}})
        else
            local options = {
                label = locale('open_shop'),
                name = 'open_shop',
                distance = 2.0,
                canInteract = function (entity, distance, coords, name, bone)
                    return true -- Get Ped is Animal (28 type)
                end,
                onSelect = function (data)
                    lib.showContext('sell_animal_rewards')
                end
            }
            exports.ox_target:addLocalEntity(ped, options)
        end
    end
end

local function startSlughterAnimal(ped)
    lib.requestAnimDict(Config.Animations['slughter'].animDict)
    if lib.progressBar({
        duration = Config.SlaughteringSpeed * 1000,
        label = locale('slaughter_label'),
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            combat = true,
            move = true
        },
        anim = {
            dict = Config.Animations['slughter'].animDict,
            clip = Config.Animations['slughter'].animName
        },
    }) then
        local pedModel = GetEntityModel(ped)
        for modelName, value in pairs(Config.AnimalsData) do
            if pedModel == GetHashKey(modelName) then
                local netId = PedToNet(ped)
                local getRewards = lib.callback.await('qwz_hunting:server:getReward', false, value.rewards, netId)
                if not getRewards or not next(getRewards) then
                    QBCore.Functions.Notify(locale('no_reward'), 'error')
                    return
                end
                for _, rewardData in ipairs(getRewards) do
                    local notifyStr = locale('you_get_items')
                    QBCore.Functions.Notify((notifyStr .. '%s x%d'):format(QBCore.Shared.Items[rewardData.name].label, rewardData.count), 'success')
                end
                DeleteEntity(ped)
                break
            end
        end
    else
        QBCore.Functions.Notify(locale("cancel_event"), 'success')
    end
end

local function InitAnimalSlaughter()
    local options = {
        label = locale('slaughter_target_label'),
        name = 'slughter_animal',
        distance = 2.0,
        canInteract = function (entity, distance, coords, name, bone)
            return GetPedType(entity) == 28 -- Get Ped is Animal (28 type)
        end,
        onSelect = function (data)
            TaskTurnPedToFaceEntity(cache.ped, data.entity, 2000)
            startSlughterAnimal(data.entity)
        end
    }
    for modelName, _ in pairs(Config.AnimalsData) do
        exports.ox_target:addModel(modelName, options)
    end
end

local function createPedAndTask()
    local tmpAnimals = {}
    for key, _ in pairs(Config.AnimalsData) do
        tmpAnimals[#tmpAnimals+1] = key
    end
    local randomAnimal = tmpAnimals[math.random(1, #tmpAnimals)]
    local pedModel = GetHashKey(randomAnimal)
    lib.requestModel(pedModel)

    local coords = GetEntityCoords(cache.ped)
    local randomDist = math.random(Config.MinSpawnDistance, Config.MaxSpawnDistance)
    local isSafe = false
    local pedPos = spawnCoords
    CreateThread(function()
        repeat
            local spawnCoords = vector3(coords.x + math.random(randomDist, randomDist), coords.y + math.random(randomDist, randomDist), coords.z)
            isSafe, pedPos = GetSafeCoordForPed(spawnCoords.x, spawnCoords.y, spawnCoords.z, false, 16)
            Wait(100)
        until isSafe

        if isSafe then
            -- call a server callback with await to get ped
            local ped = CreatePed(28, pedModel, pedPos.x, pedPos.y, pedPos.z, 0.0, true, true)

            local isStored = lib.callback.await('qwz_hunting:server:storePed', false, PedToNet(ped))
            if not isStored then return end
            -- print is exist and dead
            if not DoesEntityExist(ped) or IsPedDeadOrDying(ped, true) then return end

            if not NetworkHasControlOfEntity(ped) then NetworkRequestControlOfEntity(ped) end

            TaskFollowNavMeshToCoord(ped, coords.x, coords.y, coords.z, 1.0, -1, 2.0, 4, 0.0)
            local noPathTimer = 0
            CreateThread(function()
                while true do
                    if not DoesEntityExist(ped) or IsPedDeadOrDying(ped, true) then return end
                    local _, _, isPathReady = GetNavmeshRouteDistanceRemaining(ped)
                    local taskStatus = GetScriptTaskStatus(ped, "SCRIPT_TASK_FOLLOW_NAV_MESH_TO_COORD") --TASK_FOLLOW_NAV_MESH_TO_COORD
                    -- if taskStatus == 7 and not IsPedFleeing(ped) then
                    --     print('here', taskStatus, IsPedFleeing(ped), NetworkHasControlOfEntity(ped))
                    --     TaskFollowNavMeshToCoord(ped, coords.x, coords.y, coords.z, 1.0, -1, 2.0, 4, 0.0)
                    -- end
                    if isPathReady == 0 and not IsPedFleeing(ped) and taskStatus == 1  then
                        noPathTimer +=1
                        if noPathTimer >= 10 then
                            DeleteEntity(ped)
                            return QBCore.Functions.Notify(locale('bait_dont_work'), 'error')
                        end
                    end
                    local currenPedPos = GetEntityCoords(ped)
                    local dist = #(currenPedPos - GetEntityCoords(cache.ped))
                    if dist <= Config.AnimalsFleeView then
                        if not IsPedFleeing(ped) then
                            TaskSmartFleePed(ped, cache.ped, Config.AnimalsFleeDistance, Config.AnimalsFleeTime * 1000, false, false)
                        end
                    elseif dist >= 400.0 then
                        if DoesEntityExist(ped) then DeleteEntity(ped) end
                        -- check if entity exist and alive then send notify
                        if not IsPedDeadOrDying(ped, true) then
                            return QBCore.Functions.Notify(locale('animal_flees_away'), 'error')
                        end
                        return true
                    end
                    Wait(200)
                end
            end)
        end
    end)
end

local function useBait()
    local isUsedBait = lib.callback.await('qwz_hunting:server:useBaitItem', false, Config.BaitItem, 1)
    if not isUsedBait then return end

    if Config.EnableHuntingZones and not isInHuntingZone then return QBCore.Functions.Notify(locale('not_in_hunting_zone'), 'error') end

    lib.requestAnimDict(Config.Animations['bait'].animDict)
    if lib.progressBar({
        duration = Config.BaitPlacementSpeed * 1000,
        label = locale('placing_bait_item'),
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            combat = true,
            move = true
        },
        anim = {
            dict = Config.Animations['bait'].animDict,
            clip = Config.Animations['bait'].animName
        },
    }) then createPedAndTask() else locale('cancel_event') end
end

local Blip = nil
local function createHuntingZoneBlips(value)
    if not value.showBlip then return end
    Blip = AddBlipForCoord(value.coords.x, value.coords.y, value.coords.z)
    SetBlipAsShortRange(Blip, true)
    if value.radiusBlip then
        SetBlipSprite(Blip, 141)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(value.name)
        EndTextCommandSetBlipName(Blip)

        local RadiusBlip = AddBlipForRadius(value.coords.x, value.coords.y, value.coords.z, value.radius)
        SetBlipRotation(RadiusBlip, 0)
        SetBlipColour(RadiusBlip, 1)
        SetBlipAlpha(RadiusBlip, 64)
    else
        SetBlipSprite(Blip, 442)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(value.name)
        EndTextCommandSetBlipName(Blip)
    end
    SetBlipDisplay(Blip, 4)
    SetBlipScale(Blip, 0.6)
    SetBlipColour(Blip, 49)
end

local function InitHuntingZones()
    for key, value in pairs(Config.HuntingZones) do
        local coords = vector3(value.coords.x, value.coords.y, value.coords.z)

        createHuntingZoneBlips(value)
        local function onEnter(self)
            isInHuntingZone = true
        end
        local function onExit(self)
            isInHuntingZone = false
        end
        local zone = lib.zones.sphere({coords = coords, radius = value.radius, debug = Config.Debug, onEnter = onEnter, onExit = onExit})
    end
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(2000)
    InitAnimalSlaughter()
    InitShopData()
    if Config.EnableHuntingZones then InitHuntingZones() end
end)


AddEventHandler('onResourceStart', function(r)
    if GetCurrentResourceName() ~= r then return end
    InitAnimalSlaughter()
    InitShopData()
    if Config.EnableHuntingZones then InitHuntingZones() end
end)

-- register event after hunting bait using
RegisterNetEvent('qwz_hunting:client:useBait', function()
    useBait()
end)