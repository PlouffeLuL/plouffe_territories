CreateThread(Tr.Init)

RegisterNetEvent("plouffe_territories:sendConfig",function()
    local playerId = source
    local registred, key = Auth:Register(playerId)

    while not Server.ready do
        Wait(100)
    end

    if registred then
        local cbArray = Tr:GetData()
        cbArray.Utils.MyAuthKey = key
        TriggerClientEvent("plouffe_territories:getConfig", playerId, cbArray)
    else
        TriggerClientEvent("plouffe_territories:getConfig", playerId, nil)
    end
end)

RegisterNetEvent("plouffe_territories:ai_kills",function(authkey)
    local playerId = source
    if Auth:Validate(playerId,authkey) and Auth:Events(playerId,"plouffe_territories:ai_kills") then
        Tr:AiKills(playerId) 
    end
end)

RegisterNetEvent("plouffe_territories:soldDrugs",function(drug, netId, authkey)
    local playerId = source
    if Auth:Validate(playerId,authkey) and Auth:Events(playerId,"plouffe_territories:soldDrugs") then
        Tr:SoldDrugs(playerId,drug,netId)
    end
end)

RegisterNetEvent("plouffe_territories:tryCraft",function(data, authkey)
    local playerId = source
    if Auth:Validate(playerId,authkey) and Auth:Events(playerId,"plouffe_territories:tryCraft") then
        Tr:TryCraft(playerId, data)
    end
end)