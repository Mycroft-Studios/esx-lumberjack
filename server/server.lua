local Chopped = false

RegisterNetEvent('esx-lumberjack:sellItems', function()
    local source = source
    local price = 0
    local xPlayer = ESX.GetPlayerFromId(source)
    for k,v in pairs(Config.Sell) do 
        local item = xPlayer.getInventoryItem(k)
        if item and item.count >= 1 then
            price = price + (v * item.count)
            xPlayer.removeInventoryItem(k, item.count)
        end
    end
    if price > 0 then
        xPlayer.addMoney(price)
        if Config.NotificationType == "ESX" then
            TriggerClientEvent('esx:showNotification', source, Config.Alerts["successfully_sold"], "success")
        elseif Config.NotificationType == "ox_lib" then
            TriggerClientEvent('ox_lib:notify', source, { type = 'success', description = Config.Alerts["successfully_sold"] })
        end
    else
        if Config.NotificationType == "ESX" then
            TriggerClientEvent('esx:showNotification', source, Config.Alerts["no_item"], "error")
        elseif Config.NotificationType == "ox_lib" then
            TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = Config.Alerts["no_item"] })
        end
    end
end)

RegisterNetEvent('esx-lumberjack:BuyAxe', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local TRAxeClassicPrice = LumberJob.AxePrice
    local axe = xPlayer.getInventoryItem('WEAPON_BATTLEAXE')
    if axe.count >= 1 then
        if Config.NotificationType == "ESX" then
            TriggerClientEvent('esx:showNotification', source, Config.Alerts["axe_check"], "error")
        elseif Config.NotificationType == "ox_lib" then
            TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = Config.Alerts["axe_check"] })
        end
        return false
    else
        if Config.UseOxInventory then
            xPlayer.addInventoryItem('WEAPON_BATTLEAXE', 1)
        else
            xPlayer.addWeapon('WEAPON_BATTLEAXE', 1)
        end
        xPlayer.removeMoney(LumberJob.AxePrice)
        if Config.NotificationType == "ESX" then
            TriggerClientEvent('esx:showNotification', source, Config.Alerts["axe_bought"], "success")
        elseif Config.NotificationType == "ox_lib" then
            TriggerClientEvent('ox_lib:notify', source, { type = 'success', description = Config.Alerts["axe_bought"] })
        end
        return true
    end
end)

ESX.RegisterServerCallback('esx-lumberjack:axe', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        if Config.UseOxInventory then
            if xPlayer.hasItem('WEAPON_BATTLEAXE') then
                cb(true)
            else
                cb(false)
            end
        else
            if xPlayer.hasWeapon('WEAPON_BATTLEAXE') then
                cb(true)
            else
                cb(false)
            end
        end
    end
end)

RegisterNetEvent('esx-lumberjack:setLumberStage', function(stage, state, k)
    Config.TreeLocations[k][stage] = state
    TriggerClientEvent('esx-lumberjack:getLumberStage', -1, stage, state, k)
end)

RegisterNetEvent('esx-lumberjack:setChoppedTimer', function()
    if not Chopped then
        Chopped = true
        CreateThread(function()
            Wait(Config.Timeout)
            for k, v in pairs(Config.TreeLocations) do
                Config.TreeLocations[k]["isChopped"] = false
                TriggerClientEvent('esx-lumberjack:getLumberStage', -1, 'isChopped', false, k)
            end
            Chopped = false
        end)
    end
end)

RegisterServerEvent('esx-lumberjack:recivelumber', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local lumber = math.random(LumberJob.LumberAmount_Min, LumberJob.LumberAmount_Max)
    local bark = math.random(LumberJob.TreeBarkAmount_Min, LumberJob.TreeBarkAmount_Max)
    xPlayer.addInventoryItem('tree_lumber', lumber)
    xPlayer.addInventoryItem('tree_bark', bark)
end)

ESX.RegisterServerCallback('esx-lumberjack:lumber', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        if xPlayer.getInventoryItem("tree_lumber").count >= 1 then
            cb(true)
        else
            cb(false)
        end
    end
end)

RegisterServerEvent('esx-lumberjack:lumberprocessed', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local lumber = xPlayer.getInventoryItem('tree_lumber')
    local TradeAmount = math.random(LumberJob.TradeAmount_Min, LumberJob.TradeAmount_Max)
    local TradeRecevied = math.random(LumberJob.TradeRecevied_Min, LumberJob.TradeRecevied_Max)
    if lumber.count < 1 then 
        if Config.NotificationType == "ESX" then
            TriggerClientEvent('esx:showNotification', source, Config.Alerts['error_lumber'], "error")
        elseif Config.NotificationType == "ox_lib" then
            TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = Config.Alerts['error_lumber'] })
        end
        return false
    end

    local amount = lumber.count
    if amount >= 1 then
        amount = TradeAmount
    else
      return false
    end
    if lumber.count >= amount then 
        xPlayer.removeInventoryItem('tree_lumber', amount)
        if Config.NotificationType == "ESX" then
            TriggerClientEvent('esx:showNotification', source, Config.Alerts["lumber_processed_trade"] ..TradeAmount.. Config.Alerts["lumber_processed_lumberamount"] ..TradeRecevied.. Config.Alerts["lumber_processed_received"], "info")
        elseif Config.NotificationType == "ox_lib" then
            TriggerClientEvent('ox_lib:notify', source, { type = 'inform', description = Config.Alerts["lumber_processed_trade"] ..TradeAmount.. Config.Alerts["lumber_processed_lumberamount"] ..TradeRecevied.. Config.Alerts["lumber_processed_received"] })
        end
        Wait(750)
        xPlayer.addInventoryItem('wood_plank', TradeRecevied)
    else
        if Config.NotificationType == "ESX" then
            TriggerClientEvent('esx:showNotification', source, Config.Alerts['itemamount'], "info")
        elseif Config.NotificationType == "ox_lib" then
            TriggerClientEvent('ox_lib:notify', source, { type = 'inform', description = Config.Alerts['itemamount'] })
        end
        return false
    end
end)