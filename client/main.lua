local chopping = false
local LumberDepo = Config.Blips.LumberDepo
local LumberProcessor = Config.Blips.LumberProcessor
local LumberSeller = Config.Blips.LumberSeller

RegisterNetEvent('esx-lumberjack:getLumberStage', function(stage, state, k)
    Config.TreeLocations[k][stage] = state
end)

local function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(3)
    end
end

local function axe()
    local ped = PlayerPedId()
    local pedWeapon = GetSelectedPedWeapon(ped)

    for k, v in pairs(Config.Axe) do
        if pedWeapon == k then
            return true
        end
    end

    if Config.NotificationType == "ESX" then
        ESX.ShowNotification(Config.Alerts["error_axe"], "error", 3000)
    elseif Config.NotificationType == "ox_lib" then
        lib.notify({
            description = Config.Alerts["error_axe"],
            type = "error",
            duration = 3000,
        })
    end
end

local function ChopLumber(k)
    local animDict = "melee@hatchet@streamed_core"
    local animName = "plyr_rear_takedown_b"
    local trClassic = PlayerPedId()
    local choptime = LumberJob.ChoppingTreeTimer
    chopping = true

    local success = lib.progressBar({
        duration = choptime,
        label = Config.Alerts["chopping_tree"],
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            mouse = false,
            combat = true
        },
        anim = {
            dict = 'melee@hatchet@streamed_core',
            clip = 'plyr_rear_takedown_b'
        },
    })

    if success then
        TriggerServerEvent('esx-lumberjack:setLumberStage', "isChopped", true, k)
        TriggerServerEvent('esx-lumberjack:setLumberStage', "isOccupied", false, k)
        TriggerServerEvent('esx-lumberjack:recivelumber')
        TriggerServerEvent('esx-lumberjack:setChoppedTimer')
        chopping = false
        return true
    else
        ClearPedTasks(trClassic)
        TriggerServerEvent('esx-lumberjack:setLumberStage', "isOccupied", false, k)
        chopping = false
        return false
    end
    TriggerServerEvent('esx-lumberjack:setLumberStage', "isOccupied", true, k)
    CreateThread(function()
        while chopping do
            loadAnimDict(animDict)
            TaskPlayAnim(trClassic, animDict, animName, 3.0, 3.0, -1, 2, 0, 0, 0, 0 )
            Wait(3000)
        end
    end)
end

RegisterNetEvent('esx-lumberjack:StartChopping', function()
    for k, v in pairs(Config.TreeLocations) do
        if not Config.TreeLocations[k]["isChopped"] then
            if axe() then
                ChopLumber(k)
            end
        end
    end
end)

if Config.Job then
    CreateThread(function()
        for k, v in pairs(Config.TreeLocations) do
            exports["qtarget"]:AddBoxZone("trees" .. k, v.coords, 1.5, 1.5, {
                name = "trees" .. k,
                heading = 40,
                minZ = v.coords["z"] - 2,
                maxZ = v.coords["z"] + 2,
                debugPoly = false
            }, {
                options = {
                    {
                        action = function()
                            if axe() then
                                ChopLumber(k)
                            end
                        end,
                        event = "esx-lumberjack:StartChopping",
                        icon = "fa fa-hand",
                        label = Config.Alerts["Tree_label"],
                        job = "lumberjack",
                        canInteract = function()
                            if v["isChopped"] or v["isOccupied"] then
                                return false
                            end
                            return true
                        end,
                    }
                },
                distance = 1.0
            })

        end
    end)
    exports['qtarget']:AddBoxZone("lumberjackdepo", LumberDepo.targetZone, 1, 1, {
        name = "Lumberjackdepo",
        heading = LumberDepo.targetHeading,
        debugPoly = false,
        minZ = LumberDepo.minZ,
        maxZ = LumberDepo.maxZ,
    }, {
        options = {
            {
                event = "esx-lumberjack:bossmenu",
                icon = "Fas Fa-hands",
                label = Config.Alerts["depo_label"],
                job = "lumberjack",
            },
        },
        distance = 1.0
    })
    exports['qtarget']:AddBoxZone("LumberProcessor", LumberProcessor.targetZone, 1, 1, {
        name = "LumberProcessor",
        heading = LumberProcessor.targetHeading,
        debugPoly = false,
        minZ = LumberProcessor.minZ,
        maxZ = LumberProcessor.maxZ,
    }, {
        options = {
            {
                event = "esx-lumberjack:processormenu",
                icon = "Fas Fa-hands",
                label = Config.Alerts["mill_label"],
                job = "lumberjack",
            },
        },
        distance = 1.0
    })
    exports['qtarget']:AddBoxZone("LumberSeller", LumberSeller.targetZone, 1, 1, {
        name = "LumberProcessor",
        heading = LumberSeller.targetHeading,
        debugPoly = false,
        minZ = LumberSeller.minZ,
        maxZ = LumberSeller.maxZ,
    }, {
        options = {
            {
                type = "server",
                event = "esx-lumberjack:sellItems",
                icon = "fa fa-usd",
                label = Config.Alerts["Lumber_Seller"],
                job = "lumberjack",
            },
        },
        distance = 1.0
    })
else
    CreateThread(function()
        for k, v in pairs(Config.TreeLocations) do
            exports["qtarget"]:AddBoxZone("trees" .. k, v.coords, 1.5, 1.5, {
                name = "trees" .. k,
                heading = 40,
                minZ = v.coords["z"] - 2,
                maxZ = v.coords["z"] + 2,
                debugPoly = false
            }, {
                options = {
                    {
                        action = function()
                            if axe() then
                                ChopLumber(k)
                            end
                        end,
                        type = "client",
                        event = "esx-lumberjack:StartChopping",
                        icon = "fa fa-hand",
                        label = Config.Alerts["Tree_label"],
                        canInteract = function()
                            if v["isChopped"] or v["isOccupied"] then
                                return false
                            end
                            return true
                        end,
                    }
                },
                distance = 1.0
            })

        end
    end)
    exports['qtarget']:AddBoxZone("lumberjackdepo", LumberDepo.targetZone, 1, 1, {
        name = "Lumberjackdepo",
        heading = LumberDepo.targetHeading,
        debugPoly = false,
        minZ = LumberDepo.minZ,
        maxZ = LumberDepo.maxZ,
    }, {
        options = {
        {
          type = "client",
          event = "esx-lumberjack:bossmenu",
          icon = "Fas Fa-hands",
          label = Config.Alerts["depo_label"],
        },
        },
        distance = 1.0
    })
    exports['qtarget']:AddBoxZone("LumberProcessor", LumberProcessor.targetZone, 1, 1, {
        name = "LumberProcessor",
        heading = LumberProcessor.targetHeading,
        debugPoly = false,
        minZ = LumberProcessor.minZ,
        maxZ = LumberProcessor.maxZ,
    }, {
        options = {
        {
          type = "client",
          event = "esx-lumberjack:processormenu",
          icon = "Fas Fa-hands",
          label = Config.Alerts["mill_label"],
        },
        },
        distance = 1.0
    })
    exports['qtarget']:AddBoxZone("LumberSeller", LumberSeller.targetZone, 1, 1, {
        name = "LumberProcessor",
        heading = LumberSeller.targetHeading,
        debugPoly = false,
        minZ = LumberSeller.minZ,
        maxZ = LumberSeller.maxZ,
    }, {
        options = {
        {
          type = "server",
          event = "esx-lumberjack:sellItems",
          icon = "fa fa-usd",
          label = Config.Alerts["Lumber_Seller"],
        },
        },
        distance = 1.0
    })
end

RegisterNetEvent('esx-lumberjack:vehicle', function()
    local vehicle = LumberDepo.Vehicle
    local coords = LumberDepo.VehicleCoords
    local TR = PlayerPedId()
    RequestModel(vehicle)
    while not HasModelLoaded(vehicle) do
        Wait(0)
    end
    if not IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
        local JobVehicle = CreateVehicle(vehicle, coords, 45.0, true, false)
        SetVehicleHasBeenOwnedByPlayer(JobVehicle,  true)
        SetEntityAsMissionEntity(JobVehicle,  true,  true)
        Config.FuelSystem(JobVehicle, 100.0)
        local id = NetworkGetNetworkIdFromEntity(JobVehicle)
        DoScreenFadeOut(1500)
        Wait(1500)
        SetNetworkIdCanMigrate(id, true)
        TaskWarpPedIntoVehicle(TR, JobVehicle, -1)
        DoScreenFadeIn(1500)
    else
        if Config.NotificationType == "ESX" then
            ESX.ShowNotification(Config.Alerts["depo_blocked"], "error", 3000)
        elseif Config.NotificationType == "ox_lib" then
            lib.notify({
                description = Config.Alerts["depo_blocked"],
                type = "error",
                duration = 3000,
            })
        end
    end
end)

RegisterNetEvent('esx-lumberjack:removevehicle', function()
    local TR92 = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(TR92,true)
    SetEntityAsMissionEntity(TR92,true)
    DeleteVehicle(vehicle)
    if Config.NotificationType == "ESX" then
        ESX.ShowNotification(Config.Alerts["depo_stored"], "success", 3000)
    elseif Config.NotificationType == "ox_lib" then
        lib.notify({
            description = Config.Alerts["depo_stored"],
            type = "success",
            duration = 3000,
        })
    end
end)

RegisterNetEvent('esx-lumberjack:getaxe', function()
    TriggerServerEvent('esx-lumberjack:BuyAxe')
end)

RegisterNetEvent('esx-lumberjack:bossmenu', function()
    if Config.UseOxLib then
        print('kokot')
        lib.registerContext({
            id = 'esx-lumberjack:bossmenu',
            title = Config.Alerts["vehicle_header"],
            options = {
                {
                    title = Config.Alerts["vehicle_text"],
                    event = 'esx-lumberjack:vehicle',
                },
                {
                    title = Config.Alerts["remove_text"],
                    event = 'esx-lumberjack:removevehicle',
                },
                {
                    title = Config.Alerts["battleaxe_text"],
                    event = 'esx-lumberjack:getaxe',
                },
            },
        })
        lib.showContext('esx-lumberjack:bossmenu')
    elseif not Config.UseOxLib then
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'boss_menu', {
            title    = Config.Alerts["vehicle_header"],
            align    = 'top-left',
            elements = {
                {label = Config.Alerts["vehicle_text"], event = 'esx-lumberjack:vehicle'},
                {label = Config.Alerts["remove_text"], event = 'esx-lumberjack:removevehicle'},
                {label = Config.Alerts["battleaxe_text"], event = 'esx-lumberjack:getaxe'},
        }}, function(data, menu)
            TriggerEvent(data.current.event)
            menu.close()
        end, function(data, menu)
            menu.close()
        end)
    end
end)

RegisterNetEvent('esx-lumberjack:processormenu', function()
    if Config.UseOxLib then
        print('Server using Ox Lib')
        lib.registerContext({
            id = 'esx-lumberjack:processormenu',
            title = Config.Alerts["lumber_mill"],
            options = {
                {
                    title = Config.Alerts["lumber_text"],
                    event = 'esx-lumberjack:processor',
                    description = Config.Alerts["lumber_text_description"],
                    metadata = {Config.Alerts["lumber_text_description_meta_data"]},
                },
                {
                    title = Config.Alerts["remove_text"],
                    event = 'esx-lumberjack:removevehicle'
                },
                {
                    title = Config.Alerts["battleaxe_text"],
                    event = 'esx-lumberjack:getaxe'
                },
            },
        })
        lib.showContext('esx-lumberjack:processormenu')
    elseif not Config.UseOxLib then
        print('Server not using Ox Lib')
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'boss_menu', {
            title    = Config.Alerts["lumber_mill"],
            align    = 'top-left',
            elements = {
                {label = Config.Alerts["lumber_text"], event = 'esx-lumberjack:processor'},
                {label = Config.Alerts["remove_text"], event = 'esx-lumberjack:removevehicle'},
                {label = Config.Alerts["battleaxe_text"], event = 'esx-lumberjack:getaxe'},
        }}, function(data, menu)
            TriggerEvent(data.current.event)
            menu.close()
        end, function(data, menu)
            menu.close()
        end)
    end
end)

RegisterNetEvent('esx-lumberjack:processor', function()
    ESX.TriggerServerCallback('esx-lumberjack:lumber', function(lumber)
        if lumber then
            local success = lib.progressBar({
                duration = LumberJob.ProcessingTime,
                label = Config.Alerts['lumber_progressbar'],
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                    move = true,
                    mouse = false,
                    combat = true
                },
                anim = {
                    dict = 'missheistdockssetup1clipboard@idle_a',
                    clip = 'idle_a'
                },
            })
        
            if success then
                TriggerServerEvent("esx-lumberjack:lumberprocessed")
                return true
            else
                if Config.NotificationType == "ESX" then
                    ESX.ShowNotification(Config.Alerts['cancel'], "error", 3000)
                elseif Config.NotificationType == "ox_lib" then
                    lib.notify({
                        description = Config.Alerts['cancel'],
                        type = "error",
                        duration = 3000,
                    })
                end
                return false
            end
        else
            if Config.NotificationType == "ESX" then
                ESX.ShowNotification(Config.Alerts['error_lumber'], "error", 3000)
            elseif Config.NotificationType == "ox_lib" then
                lib.notify({
                    description = Config.Alerts['error_lumber'],
                    type = "error",
                    duration = 3000,
                })
            end
        end
    end)
end)
