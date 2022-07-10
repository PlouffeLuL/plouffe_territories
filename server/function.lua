local GetResourceKvpString = GetResourceKvpString
local SetResourceKvp = SetResourceKvp
local GetResourceKvpInt = GetResourceKvpInt
local SetResourceKvpInt = SetResourceKvpInt

local Wait = Wait
local CreatePed = CreatePed
local DoesEntityExist = DoesEntityExist
local DeleteEntity = DeleteEntity
local NetworkGetNetworkIdFromEntity = NetworkGetNetworkIdFromEntity
local NetworkGetEntityOwner = NetworkGetEntityOwner

local os = os

function Tr:Init()
    self = Tr

    local items = exports.ox_inventory:Items()

    for k,v in pairs(self.Craftables) do
        for x,y in pairs(v.required) do
            y.label = items[x].label
        end
    end

    self.TerritoryZones = {}

    self.lastActions = json.decode(GetResourceKvpString("lastActions")) or {}

    local lastHighValue = GetResourceKvpInt("lastHighValue")

    self.lastHighValue = lastHighValue ~= 0 and lastHighValue  or os.time()

    for k,v in pairs(self.Territories) do
        self.lastActions[k] = self.lastActions[k] or 0

        v.status = json.decode(GetResourceKvpString(("status_%s"):format(k)))
        v.owned = json.decode(GetResourceKvpString(("owned_%s"):format(k))) or {gang = "default", color = 0}
        v.blip.color = (not v.owned and 0) or (v.owned and self.Gangs[v.owned.gang] and self.Gangs[v.owned.gang].color)

        if not v.status then
            v.status = {}
            for gang, data in pairs(self.Gangs) do
                v.status[gang] = {amount = 0}
            end
        end

        for x,y in pairs(v.coords) do
            y.name = x
            y.coords = y.coords or v.blip.coords
            y.maxZ = y.maxZ or 50.0
            y.minZ = y.minZ or -50.0

            if x:find("_stash") then
                exports.ox_inventory:RegisterStash(x,"Pogerino", 10, 100000, nil, nil, y.coords)
            end

            if x:find("_territory") then
                y.params = {zone = k}
                y.isZone = true
                y.zoneMap = {
                    inEvent = "plouffe_territories:inTerritoty",
                    outEvent = "plouffe_territories:leftTerritoty"
                }

                self.TerritoryZones[x] = k
            end

            if v.owned and self.Gangs[v.owned.gang] and y.pedInfo then
                y.pedInfo.model = self.Gangs[v.owned.gang].ped
            end
        end
    end

    SetResourceKvpInt("lastHighValue", self.lastHighValue)
    SetResourceKvp("lastActions", json.encode(self.lastActions))

    Server.ready = true

    self:Process()
end

function Tr:Process()
    local lastUpdates = json.decode(GetResourceKvpString("lastUpdates")) or {}
    local sleepTimer = 1000 * 60 * 15
    local delay = 60 * 60
    local highValueIntervall = math.random(60 * 60 * 3,60 * 60 * 12 )

    while true do
        Wait(sleepTimer)
        local time = os.time()

        if time - self.lastHighValue > highValueIntervall then
            if self:PrepareHighValue() then
                highValueIntervall = math.random(60 * 60 * 3,60 * 60 * 12 )
                self.lastHighValue = time
                self:PrepareHighValue()
                SetResourceKvpInt("lastHighValue", self.lastHighValue)
            end
        end

        for territoryName,data in pairs(self.Territories) do
            if time - self.lastActions[territoryName] > (60 * 60 * 6) then
                self.lastActions[territoryName] = time

                if self.Gangs[data.owned.gang] and data.owned.gang ~= "default" then
                    print(("Removing 10 status from %s in territory %s"):format(data.owned.gang, territoryName))
                    self.RemoveTerritoryStatus(territoryName, data.owned.gang, 10)
                elseif not self.Gangs[data.owned.gang] then
                    print(("Reseting territory %s"):format(territoryName))
                    self.AddTerritoryStatus(territoryName, "default", 100)
                end
            end

            for k,v in pairs(data.coords) do
                if k:find("_stash") then
                    local interval = time - (lastUpdates[k] or 0)
                    local letUpdate = interval >= delay

                    if letUpdate then
                        local inventory = exports.ox_inventory:Inventory(k)

                        if inventory then
                            for i = 1, 10 do
                                local item = inventory.items[i]

                                if item then
                                    local removed = false

                                    if item.metadata and item.metadata.durability then
                                        local durability = item.metadata.durability

                                        if item.name:find("WEAPON_") then
                                            if durability <= 0 then
                                                exports.ox_inventory:RemoveItem(k, item.name, item.count, nil, item.slot)
                                                removed = true
                                            end
                                        else
                                            if durability - time <= 0 then
                                                exports.ox_inventory:RemoveItem(k, item.name, item.count, nil, item.slot)
                                                removed = true
                                            end
                                        end
                                    end

                                    if not removed then
                                        local exchange = self.StashItems.exchange[item.name]

                                        if exchange and item.count >= exchange.amount then
                                            local this = exchange.items[math.random(1, #exchange.items)]

                                            if exports.ox_inventory:CanCarryItem(k, this.name, this.amount, this.metadata) then
                                                exports.ox_inventory:RemoveItem(k, item.name, exchange.amount)
                                                exports.ox_inventory:AddItem(k, this.name, this.amount, this.metadata)
                                            end
                                        end
                                    end
                                end
                            end

                            lastUpdates[k] = os.time()

                            local randi = math.random(0,100)
                            local item = self.StashItems.add[math.random(1, #self.StashItems.add)]

                            if item.chances >= randi then
                                local amount = type(item.amount) == "table" and math.random(item.amount.min, item.amount.max) or type(item.amount) == "number" and item.amount or 1

                                if exports.ox_inventory:CanCarryItem(k, item.name, amount, item.metadata) then
                                    exports.ox_inventory:AddItem(k, item.name, amount, item.metadata)
                                end
                            end
                        end
                    end
                end
            end
        end

        SetResourceKvp("lastUpdates", json.encode(lastUpdates))
        SetResourceKvp("lastActions", json.encode(self.lastActions))
    end
end

function Tr:GetData()
    local retval = {}

    for k,v in pairs(self) do
        if type(v) ~= "function" then
            retval[k] = v
        end
    end

    return retval
end

function Tr.AddTerritoryStatus(territory, gang, amount)
    self = Tr

    amount = tonumber(amount) or 0
    gang = tostring(gang) or ""

    local this = Tr.Territories[territory]

    if not this then
        return
    end

    local owningGang = this.owned and this.owned.gang and this.owned.gang ~= "default" and this.owned.gang or nil

    if owningGang and owningGang ~= gang then
        this.status[owningGang].amount = this.status[owningGang].amount - amount > 0 and this.status[owningGang].amount - amount or 0
    end

    if not this.status[gang] then
        this.status[gang] = {amount = amount}
    else
        this.status[gang].amount = this.status[gang].amount + amount < 100 and this.status[gang].amount + amount or 100
    end

    Tr.Territories[territory] = this

    SetResourceKvp(("status_%s"):format(territory), json.encode(Tr.Territories[territory].status))

    self:SendGangMessage(gang,("Vous avez gagner %s point de controle dans le territoire %s. Vous etes a %s points."):format(amount, this.label, this.status[gang].amount))

    local changeOwner = owningGang and this.status[owningGang].amount == 0 and true or not owningGang and this.status[gang].amount == 100 and true

    if changeOwner then
        local newOwner = this.status[gang].amount == 100 and gang or "default"
        self:ChangeTerritory(territory, newOwner)
    end
end
exports("add", Tr.AddTerritoryStatus)

function Tr.RemoveTerritoryStatus(territory, gang, amount)
    self = Tr

    local this = Tr.Territories[territory]
    if not this then
        return
    end

    if not this.status[gang] then
        return print(("Gang %s dosent exist in territoy %s"):format(gang, territory))
    end

    this.status[gang].amount = this.status[gang].amount - amount > 0 and this.status[gang].amount - amount or 0

    Tr.Territories[territory] = this

    SetResourceKvp(("status_%s"):format(territory), json.encode(this.status))

    self:SendGangMessage(gang,("Vous avez perdu %s point de controle dans le territoire %s"):format(amount, this.label))

    if this.status[gang].amount == 0 then
        self:ChangeTerritory(territory)
    end

end
exports("remove", Tr.RemoveTerritoryStatus)

function Tr:ChangeTerritory(territory, newOwner)
    newOwner = newOwner or "default"

    self:SendGangMessage(Tr.Territories[territory].owned.gang, "Vous avez perdu le controle d'un de vos térritoire")

    Tr.Territories[territory].owned.gang = newOwner
    Tr.Territories[territory].blip.color = self.Gangs[newOwner] and self.Gangs[newOwner].color or 0

    for k,v in pairs(Tr.Territories[territory].status) do
        if k ~= newOwner then
            v.amount = 0
        end
    end

    for k,v in pairs(Tr.Territories[territory].coords) do
        if v.pedInfo then
            v.pedInfo.model = self.Gangs[newOwner] and self.Gangs[newOwner].ped or self.Gangs.default.ped
        end
    end

    TriggerClientEvent("plouffe_territories:new_owner", -1, territory, Tr.Territories[territory])

    SetResourceKvp(("status_%s"):format(territory), json.encode(Tr.Territories[territory].status))
    SetResourceKvp(("owned_%s"):format(territory), json.encode(Tr.Territories[territory].owned))

    self:SendGangMessage(Tr.Territories[territory].owned.gang, "Vous avez pris le controle d'un térritoire")
    return true
end

function Tr:SendGangMessage(gang, message)
    local players = exports.plouffe_gangs:GetPlayersPerGang(gang)

    if not players then
        return
    end

    for k,v in pairs(players) do
        local player = exports.ooc_core:getPlayerFromId(k)
        local phoneNumber = player and player.phone_number

        if phoneNumber then
            local messageData = {senderNumber = "Plug", targetNumber = tostring(phoneNumber), message = message}
            exports.npwd:emitMessage(messageData)
        end
    end
end

function Tr:AiKills(playerId)
    local player = exports.ooc_core:getPlayerFromId(playerId)
    local gang = player.gang.name

    if not self.Gangs[gang] then
        return
    end

    local territory = Player(playerId).state.territory

    if not territory then
        return
    end

    self.AddTerritoryStatus(territory, gang, 1)
    local this = Tr.Territories[territory]

    local owningGang = this and this.owned and this.owned.gang and this.owned.gang ~= "default" and this.owned.gang or nil

    local newActionTime = self.lastActions[territory] - (60 * 5)
    self.lastActions[territory] = newActionTime > 0 and newActionTime or 0

    if not owningGang then
        return
    end

    self:SendGangMessage(owningGang, "Les membres de ton gang sont entrain de ce faire massacré")
end

function Tr:SoldDrugs(playerId,drug,netId)
    local territory = Player(playerId).state.territory

    if not territory then
        return
    end

    territory = territory:gsub("_territory","")

    if not self.Territories[territory] then
        return
    end

    if not self.Territories[territory].drugs[drug.name] then
        return
    end

    local itemCount = exports.ox_inventory:GetItem(playerId, drug.name, nil, true)

    if itemCount < drug.amount then
        return
    end

    exports.ox_inventory:RemoveItem(playerId, drug.name, drug.amount)
    exports.ox_inventory:AddItem(playerId, "black_money", drug.price)

    local player = exports.ooc_core:getPlayerFromId(playerId)
    local gang = player.gang.name

    if not self.Gangs[gang] then
        return
    end

    self.AddTerritoryStatus(territory, gang, math.random(1,4))

    self.lastActions[territory] = os.time()
end

function Tr:StartHighValue(territory)
    self.HighValue.territory = territory

    local this = Tr.Territories[territory]
    local owningGang = this and this.owned and this.owned.gang and this.owned.gang ~= "default" and this.owned.gang or nil

    if not owningGang then
        return
    end

    local model = self.Gangs[this.owned.gang] and self.Gangs[this.owned.gang].ped or self.Gangs.default.ped

    local coords = this.highValue.spawn
    local ped = CreatePed(1, joaat(model), coords.x, coords.y, coords.z, 0.0, true, true)

    local gangList = exports.plouffe_gangs:GetPlayersPerGang()

    local attackersMessage = ("Une cible haute priorité est en mouvement, tuer la. Vous avez 15 minutes. Cartier: %s"):format(this.label)
    local defendantMessage = ("Une cible haute priorité est en mouvement dans votre téritoire, defender la pendant 15 minutes. Cartier: %s"):format(this.label)

    for gang,gangData in pairs(gangList) do
        if gang ~= "none" then
            for playerId,subgroup in pairs(gangData) do

                local player = exports.ooc_core:getPlayerFromId(playerId)
                local phoneNumber = player and player.phone_number
                local messageData = {senderNumber = "Plug", targetNumber = tostring(phoneNumber), message = attackersMessage}

                if gang == owningGang then
                    messageData.message = defendantMessage
                    exports.npwd:emitMessage(messageData)
                else
                    exports.npwd:emitMessage(messageData)
                end
            end
        end
    end

    CreateThread(function()
        local init = os.time()

        while not DoesEntityExist(ped) and os.time() - init < 10 do
            Wait(100)
        end

        if not DoesEntityExist(ped) then
            return
        end
        local netId = NetworkGetNetworkIdFromEntity(ped)

        GlobalState.highValue = {ped = netId, territory = territory}

        Entity(ped).state:set("killer", 0, true)

        RemoveStateBagChangeHandler(self.highvalueHandler)

        self.highvalueHandler = AddStateBagChangeHandler("killer", ("entity:%s"):format(netId), function(bagName,key,value,reserved,replicated)
            local player = exports.ooc_core:getPlayerFromId(value)

            if not player then
                return
            end

            if not self.Gangs[player.gang.name] then
                return
            end

            if owningGang == player.gang.name then
                local newActionTime = self.lastActions[territory] - (60 * 60)
                self.lastActions[territory] = newActionTime > 0 and newActionTime or 0

                self.RemoveTerritoryStatus(territory, owningGang, 50)

                self:SendGangMessage(owningGang, "La cible que vous deviez defendre a été tuer par un membre de votre gang")
            else
                self.AddTerritoryStatus(territory, player.gang.name, 25)

                self:SendGangMessage(player.gang.name, "Vous avez réussi a tuer la cible")
                self:SendGangMessage(owningGang, "La cible que vous deviez defendre a été tuer")
            end

            Wait(10000)

            DeleteEntity(ped)
        end)

        Wait(1000)

        local ownerSet = false

        while os.time() - init < (60 * 15) and DoesEntityExist(ped) do
            local playerId = NetworkGetEntityOwner(ped)

            if playerId ~= -1 and not ownerSet then
                ownerSet = true
                TriggerClientEvent("plouffe_territories:updateHighvalueTasks", playerId)
            end

            Wait(10000)
        end

        if DoesEntityExist(ped) then
            DeleteEntity(ped)
            GlobalState.highValue = nil
        end
    end)
end

function Tr:PrepareHighValue()
    local accessible = {}
    for k,v in pairs(self.Territories) do
        if v.owned and v.owned.gang ~= "default" then
            accessible[#accessible + 1] = k
        end
    end

    if #accessible == 0 then
        return false
    end

    self:StartHighValue(accessible[math.random(1, #accessible)])

    return true
end

function Tr.TryCraftOthers(playerId, name)
    if not Tr.Craftables[name] then
        return
    end

    for k,v in pairs(Tr.Craftables[name].required) do
        if exports.ox_inventory:GetItem(playerId, k, nil, true) < v.amount then
            return
        end

        exports.ox_inventory:RemoveItem(playerId, k, v.amount)
    end

    exports.ox_inventory:AddItem(playerId, name, 1)
end

function Tr:TryCraft(playerId, data)
    local territory = Player(playerId).state.territory

    if data.name ~= "blueprint" then
        return Tr.TryCraftOthers(playerId, data.name)
    end

    if not territory then
        return
    end

    territory = territory:gsub("_territory","")

    if not self.Territories[territory] then
        return
    end

    local itemCount = exports.ox_inventory:GetItem(playerId, data.name, data.metadata, true)

    exports.ox_inventory:RemoveItem(playerId, data.name, 1, data.metadata, data.slot)

    for k,v in pairs(Tr.Craftables[data.metadata.weapon].required) do
        if exports.ox_inventory:GetItem(playerId, k, nil, true) < v.amount then
            return
        end

        exports.ox_inventory:RemoveItem(playerId, k, v.amount)
    end

    exports.ox_inventory:AddItem(playerId, data.metadata.weapon, 1)
end

RegisterCommand("addTerritory", function(s,a,r)
    Tr.AddTerritoryStatus(a[1], a[2], a[3])
end, true)

RegisterCommand("highValue", function()
    Tr:PrepareHighValue()
end, true)