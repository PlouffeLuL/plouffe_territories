local Utils = exports.plouffe_lib:Get("Utils")

local AddBlipForArea = AddBlipForArea
local SetBlipRotation = SetBlipRotation
local SetBlipColour = SetBlipColour
local SetBlipAlpha = SetBlipAlpha
local SetBlipDisplay = SetBlipDisplay
local RemoveBlip = RemoveBlip

local NetworkGetEntityFromNetworkId = NetworkGetEntityFromNetworkId
local NetworkGetPlayerIndexFromPed = NetworkGetPlayerIndexFromPed
local IsEntityDead = IsEntityDead
local IsEntityAPed = IsEntityAPed

local PlayerPedId = PlayerPedId
local GetEntityHeading = GetEntityHeading
local GetEntityCoords = GetEntityCoords
local SetEntityCoords = SetEntityCoords
local SetEntityHeading = SetEntityHeading
local TaskPlayAnim = TaskPlayAnim

local DeleteEntity = DeleteEntity
local TaskGoToEntity = TaskGoToEntity
local SetPedDropsWeaponsWhenDead = SetPedDropsWeaponsWhenDead
local SetPedFleeAttributes = SetPedFleeAttributes
local TaskCombatPed = TaskCombatPed
local TaskStandStill = TaskStandStill
local TaskSmartFleePed = TaskSmartFleePed
local TaskWanderStandard = TaskWanderStandard
local TaskWanderInArea = TaskWanderInArea
local SetPedSuffersCriticalHits = SetPedSuffersCriticalHits
local SetPedKeepTask = SetPedKeepTask
local GiveWeaponToPed = GiveWeaponToPed
local ClearPedTasks = ClearPedTasks
local SetEntityHealth = SetEntityHealth
local SetPedMaxHealth = SetPedMaxHealth
local SetPedArmour = SetPedArmour
local SetPedCombatAbility = SetPedCombatAbility
local SetPedInfiniteAmmoClip = SetPedInfiniteAmmoClip
local SetPedFleeAttributes = SetPedFleeAttributes
local SetPedSuffersCriticalHits = SetPedSuffersCriticalHits
local IsPedArmed = IsPedArmed
local GetPedType = GetPedType
local IsPedAPlayer = IsPedAPlayer
local IsPedDeadOrDying = IsPedDeadOrDying
local IsPedInMeleeCombat = IsPedInMeleeCombat
local IsPedInAnyVehicle = IsPedInAnyVehicle
local AttachEntityToEntity = AttachEntityToEntity
local SetEntityCollision = SetEntityCollision
local SetPedAsNoLongerNeeded = SetPedAsNoLongerNeeded
local PedToNet = PedToNet
local SetEntityAsMissionEntity = SetEntityAsMissionEntity
local SetPedRelationshipGroupHash = SetPedRelationshipGroupHash
local DoesEntityExist = DoesEntityExist

local GetPedBoneIndex = GetPedBoneIndex
local IsPedRagdoll = IsPedRagdoll
local IsPedFleeing = IsPedFleeing
local IsPedSwimming = IsPedSwimming
local SetEntityAsNoLongerNeeded = SetEntityAsNoLongerNeeded
local SetEntityVisible = SetEntityVisible

local GetClosestVehicleNodeWithHeading = GetClosestVehicleNodeWithHeading
local FreezeEntityPosition = FreezeEntityPosition
local GetOffsetFromEntityInWorldCoords = GetOffsetFromEntityInWorldCoords
local StartShapeTestRay = StartShapeTestRay
local GetShapeTestResult = GetShapeTestResult

local GetGameTimer = GetGameTimer
local Wait = Wait
local CreateThread = CreateThread
local Core = nil

function Tr:Start()
    TriggerEvent('ooc_core:getCore', function(Core)
        while not Core.Player:IsPlayerLoaded() do
            Wait(500)
        end

        self.Player = Core.Player:GetPlayerData()

        self:RegisterKeys()
        self:ExportAllZones()
        self:RegisterEvents()
        self:DrawBlips()
    end)
end

function Tr:RegisterKeys()
    RegisterCommand('+SellDrug', self.Sell)
    RegisterCommand('-SellDrug', function() end, false)

    RegisterKeyMapping('+SellDrug', 'Vendre de la drogue', 'keyboard', 'H')
end

function Tr:ExportAllZones()
    for k,v in pairs(self.Territories) do
        for x,y in pairs(v.coords) do
            exports.plouffe_lib:ValidateZoneData(y)
        end
    end

    self.Zones = {}

    for k,v in pairs(self.Territories) do
        for x,y in pairs(v.coords) do
            if y.name:find("_territory") then
                self.Zones[k] = y
                break
            end
        end
    end

    setmetatable(self.Zones, {
        __call = function(self, ...)
            for k,v in pairs(self) do
                if exports.plouffe_lib:IsInZone(v.name) then
                    return Tr.Territories[k]
                end
            end
        end
    })
end

function Tr:RegisterEvents()
    self.playerIndex = PlayerId()
    self.playerId = GetPlayerServerId(self.playerIndex)
    self.currentTerritory = nil
    self.currentKills = {}
    self.customerPed = {}

    RegisterNetEvent("ooc_core:setgang", function(gang)
        self.Player.gang = gang
        self:DrawBlips()
    end)

    RegisterNetEvent("plouffe_lib:inVehicle", function(inVehicle, vehicle)
        self.Utils.inVehicle = inVehicle
        self.Utils.vehicle = vehicle
    end)

    RegisterNetEvent("plouffe_lib:hasWeapon", function(hasWeapon, weapon)
        self.Utils.hasWeapon = hasWeapon
        self.Utils.weapon = weapon
    end)

    RegisterNetEvent("plouffe_territories:onZone", function(params)
        self[params.fnc](self, params)
    end)

    RegisterNetEvent("plouffe_territories:new_owner", function(territory, data)
        self:NewOwner(territory, data)
    end)

    RegisterNetEvent("plouffe_territories:craftBench:in", function(params)
        if self.Territories[params.territory] and self.Territories[params.territory].coords[params.zone] then
            self.currentCraftBench = params
        end
    end)

    RegisterNetEvent("plouffe_territories:craftBench:out", function(params)
        self.currentCraftBench = nil
    end)

    RegisterNetEvent("plouffe_territories:inTerritoty", function(params)
        self.currentTerritory = params.zone

        if not self.currentKills[self.currentTerritory] then
            self.currentKills[self.currentTerritory] = 0
        end

        Player(self.playerId).state:set("territory", self.currentTerritory, true)

        self.gameEventHandler = AddEventHandler('gameEventTriggered', Tr.EntityKills)
    end)

    RegisterNetEvent("plouffe_territories:leftTerritoty", function(params)
        self.currentTerritory = nil
        Player(self.playerId).state:set("territory", self.currentTerritory, true)

        RemoveEventHandler(self.gameEventHandler)
    end)

    RegisterNetEvent("plouffe_territories:updateHighvalueTasks", function()
        local ped = NetworkGetEntityFromNetworkId(GlobalState.highValue.ped)
        local coords = GetEntityCoords(ped)

        Utils:AssureEntityControl(ped)

        SetEntityAsMissionEntity(ped, true, true)
        SetPedMaxHealth(ped, 500)
        SetEntityHealth(ped, 500)
        SetPedArmour(ped, 100)
        SetPedInfiniteAmmoClip(ped, true)
        SetPedSuffersCriticalHits(ped, false)
        SetPedDropsWeaponsWhenDead(ped,false)
        SetPedCombatAbility(ped, 2)

        SetPedRelationshipGroupHash(ped, joaat("AMBIENT_GANG_MEXICAN"))

        GiveWeaponToPed(ped, joaat("weapon_heavysniper_mk2"), 999, true, true)
        TaskWanderInArea(ped, coords.x, coords.y, coords.z, 50.0, 8, 0.2)
        -- TaskWanderInArea(
        --     ped, 
        --     pedCoords.x, 
        --     pedCoords.y, 
        --     pedCoords.z, 
        --     100, 
        --     2000, 
        --     2
        -- )
    end)

    AddStateBagChangeHandler("territory" ,("player:%s"):format(self.playerId), function(bagName,key,value,reserved,replicated)
        if value ~= self.currentTerritory then

        end
    end)

    AddStateBagChangeHandler("highValue", nil, function(bagName,key,value,reserved,replicated)
        if value == nil then
            RemoveEventHandler(self.highvalueHandler)
            return
        end

        self.highvalueHandler = AddEventHandler("entityDamaged", self.CheckHighValue)
    end)
end

function Tr:RemoveBlips()
    for k,v in pairs(self.Territories) do
        RemoveBlip(v.blip.id)
        v.blip.id = nil
    end
end

function Tr:DrawBlips()
    if not self.Gangs[self.Player.gang.name] then
        return self:RemoveBlips()
    end

    for k,v in pairs(self.Territories) do
        if v.blip.id then
            RemoveBlip(v.blip.id)
        end

        v.blip.id = AddBlipForArea(
            v.blip.coords.x,
            v.blip.coords.y,
            v.blip.coords.z,
            v.blip.width,
            v.blip.height
        )

        SetBlipRotation(v.blip.id, v.blip.rotation)
        SetBlipColour(v.blip.id, v.blip.color)
        SetBlipAlpha(v.blip.id, 120)
        SetBlipDisplay(v.blip.id, 3)
    end
end

function Tr.HasAcces()
    local zone = Tr.Zones()

    if not zone or (zone and not zone.owned) then
        return false
    end

    return zone
end

function Tr:OpenStash(params)
    local zone = self:HasAcces()

    if not zone then
        return Utils:Notify("Cette personne n'est pas intéresser a vous parler")
    end

    if zone.owned.gang == self.Player.gang.name then
        exports.ox_inventory:openInventory("stash", {id = params.stash, type = "stash"})
    end
end

function Tr:OpenShop(params)
    local zone = self:HasAcces()

    if not zone then
        return Utils:Notify("Cette personne n'est pas intéresser a vous parler")
    end

    if zone.owned.gang == self.Player.gang.name then
        exports.ox_inventory:openInventory("shop", {type = params.shop})
    end
end

function Tr:NewOwner(territory,data)
    self:RemoveBlips()
    self.Territories[territory] = data
    self:DrawBlips()


    for k,v in pairs(self.Territories[territory].coords) do
        if v.pedInfo then
            exports.plouffe_lib:UpdatePedModel(v.name,v.pedInfo.model)
        end
    end
end

function Tr.EntityKills(event, data)
    self = Tr

    if not self.currentTerritory or not self.currentKills[self.currentTerritory] then
        return
    end

    if event == 'CEventNetworkEntityDamage' then
        local victim = tonumber(data[1])
        local attacker = tonumber(data[2])
        local player = NetworkGetPlayerIndexFromPed(attacker)

        if victim ~= nil and attacker ~= nil and self.playerIndex == player and IsEntityDead(victim) and IsEntityAPed(victim) then
            self.currentKills[self.currentTerritory] =  self.currentKills[self.currentTerritory] + 1

            if self.currentKills[self.currentTerritory] >= 15 then
                self.currentKills[self.currentTerritory] = 0
                TriggerServerEvent("plouffe_territories:ai_kills", self.Utils.MyAuthKey)
            end
        end
    end
end

function Tr.CheckHighValue(victim, culprit, weapon, baseDamage)
    if not GlobalState.highValue then
        return
    end

    local highValuePed = NetworkGetEntityFromNetworkId(GlobalState.highValue.ped)

    if DoesEntityExist(highValuePed) and IsPedDeadOrDying(victim) and highValuePed == victim and Entity(highValuePed).state.killer and Entity(highValuePed).state.killer == 0 then
        Entity(highValuePed).state:set("killer", self.playerId, true)
    end
end

function Tr:CanSellDrug(targetPed, ped)
    if targetPed == 0 then
        return false, "Target ped is 0"
    elseif GetPedType(targetPed) == 28 then
        return false, "Ped type is 28"
    elseif IsPedAPlayer(targetPed) then
        return false, "Ped is a player"
    elseif IsPedDeadOrDying(targetPed) then
        return false, "Ped is dead"
    elseif IsPedInMeleeCombat(targetPed) then
        return false, "Ped is in mele combat"
    elseif IsPedInMeleeCombat(ped) then
        return false, "Player is in mele combat"
    elseif IsPedArmed(targetPed,4) then
        return false, "ped is armed"
    elseif Entity(targetPed).state.boughtDrugs then
        return false, "ped already bought drugs"
    elseif IsPedInAnyVehicle(ped) then
        return false, "player is in vehicle"
    elseif IsPedInAnyVehicle(targetPed) then
        return false, "ped is in a vehicle"
    -- elseif NetworkGetEntityOwner(targetPed) == -1 then
    --     return false, "ped is a local ped"
    elseif IsPedRagdoll(targetPed) == true then
        return false, "ped is in ragodll"
    elseif IsPedRagdoll(ped) == true then
        return false, "player is in ragdoll"
    elseif IsPedFleeing(targetPed) then
        return false, "ped is fleeing"
    elseif IsPedSwimming(ped) == 1 then
        return false, "player is swiming"
    elseif IsPedSwimming(targetPed) == 1 then
        return false, "ped is swiming"
    end

    return true
end

function Tr:ClearCreatedPeds()
    local time = GetGameTimer()
    local remove = {}

    for k,v in pairs(self.customerPed) do
        if IsEntityDead(k) or time - v.time > 1000 * 120 or v.remove then
            remove[k] = true
            DeleteEntity(k)
        end
    end

    for k,v in pairs(remove) do
        self.customerPed[k] = nil
    end
end

function Tr:RepostionPed(ped,targetPed)
    local myOffSet = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.2, 0.0)
    local nPedCoords = GetEntityCoords(targetPed)
    local dstCheck = #(nPedCoords - myOffSet)

    TaskStandStill(targetPed, 6000)
    SetEntityHeading(targetPed, GetEntityHeading(ped) - 180)

    if dstCheck > 0.6 then
        SetEntityCoords(targetPed, myOffSet.x, myOffSet.y, myOffSet.z - 1.0)
    end
end

function Tr:DoSellAnim(ped,targetped)
    local bag_model = 'prop_paper_bag_small'
    local cash_model = 'prop_cash_pile_02'

    local dict = "reaction@intimidation@1h"
    local anim = "intro"
    local targetPedCoords = GetEntityCoords(targetped)
    local pedCoords = GetEntityCoords(ped)

    local myBoneindx = GetPedBoneIndex(ped, 58868)
    local targetBoneindx = GetPedBoneIndex(targetped, 58868)

    self:RepostionPed(ped,targetped)

    Utils:AssureAnim(dict)
    TaskPlayAnim(ped, dict, anim, 1.0, 1.0, 3000, 1, 2, 0, 0, 0 )

    Wait(1000)

    local bag_prop = Utils:CreateProp(bag_model, pedCoords, true)
    SetEntityCollision(bag_prop, false, true)
    AttachEntityToEntity(bag_prop, ped, myBoneindx, 0, 0, 0, 0, 0, 200.0, true, true, false, true, 1, true)

    dict = "mp_ped_interaction"
    anim = "handshake_guy_a"

    Wait(1500)

    Utils:AssureAnim(dict)
    TaskPlayAnim(ped, dict, anim, 1.0, 1.0, 3000, 1, 2, 0, 0, 0 )

    Wait(1000)

    self:RepostionPed(ped,targetped)

    TaskPlayAnim(ped, dict, anim, 1.0, 1.0, 1650, 01, 2, 0, 0, 0 )
    TaskPlayAnim(targetped, dict, anim, 1.0, 1.0, 1650, 01, 2, 0, 0, 0 )

    Wait(950)
    AttachEntityToEntity(bag_prop, targetped, targetBoneindx, 0, 0, 0, 0, 0, 200.0, true, true, false, true, 1, true)

    Wait(650)

    dict = "reaction@intimidation@1h"
    anim = "outro"

    Utils:AssureAnim(dict)
    TaskPlayAnim(targetped, dict, anim, 1.0, 1.0, 3000, 1, 2, 0, 0, 0 )

    Wait(1800)

    DeleteEntity(bag_prop)

    anim = "intro"

    targetPedCoords = GetEntityCoords(targetped)
    pedCoords = GetEntityCoords(ped)

    local dstCheck = #(pedCoords - targetPedCoords)

    if dstCheck <= 2.5 then
        self:RepostionPed(ped,targetped)

        Utils:AssureAnim(dict)
        TaskPlayAnim(targetped, dict, anim, 1.0, 1.0, 3000, 01, 2, 0, 0, 0 )

        Wait(1000)

        local cash_prop = Utils:CreateProp(cash_model, targetPedCoords, true)
        SetEntityCollision(cash_prop, false, true)
        AttachEntityToEntity(cash_prop, targetped, targetBoneindx, 0, 0, 0, 0, 0, 200.0, true, true, false, true, 1, true)

        Wait(2000)

        dict = "mp_ped_interaction"
        anim = "handshake_guy_a"

        Utils:AssureAnim(dict)
        TaskPlayAnim(ped, dict, anim, 1.0, 1.0, 1850, 01, 2, 0, 0, 0 )
        TaskPlayAnim(targetped, dict, anim, 1.0, 1.0, 1850, 01, 2, 0, 0, 0 )

        Wait(950)
        AttachEntityToEntity(cash_prop, ped, myBoneindx, 0, 0, 0, 0, 0, 200.0, true, true, false, true, 1, true)
        Wait(650)

        dict = "reaction@intimidation@1h"
        anim = "outro"

        Wait(1250)
        Utils:AssureAnim(dict)
        TaskPlayAnim(ped, dict, anim, 1.0, 1.0, 2500, 1, 2, 0, 0, 0 )

        Wait(1350)
        DeleteEntity(cash_prop)
        SetPedAsNoLongerNeeded(targetped)

        return true
    end
end

function Tr:CanCornerSell(initialCoords, pedCoords)
    if not self.cornerSelling or #(initialCoords - pedCoords) > 10 or LocalPlayer.state.dead or self.Utils.inVehicle or self.Utils.isCuffed then
        return false
    end

    return true
end

function Tr:CornerSell()
    local currentZone = self.Zones()

    if not currentZone or self.cornerSelling then
        return
    end

    Utils:PlayAnim(4000, "cellphone@", "cellphone_call_listen_base" , 49, 3.0, 2.0, 4000, false, true, false, {model = "prop_npc_phone_02", bone = 28422})
    Utils:Notify("Vous avez commencer a vendre, attendez vos clients")

    if not self.customerPed then
        self.customerPed = {}
    end

    self.cornerSelling = true

    CreateThread(function()
        local time = GetGameTimer()
        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)
        local initialCoords = pedCoords
        local lastCustomer = time
        local lastAlert = time
        local customerDelay = math.random(1000 * 10, 1000 * 30)
        local alertDelay = math.random(1000 * 60 * 5, 1000 * 60 * 10)

        while self:CanCornerSell(initialCoords, pedCoords) do
            time = GetGameTimer()

            if time - lastAlert > alertDelay then
                local letAlert = math.random(0, 100) >= 95
                if letAlert then
                    exports.plouffe_dispatch:SendAlert("IllegalActivity")
                    lastAlert = time
                end
            end

            self.Utils.pedCoords = GetEntityCoords(ped)
            self.Utils.ped = PlayerPedId()

            if not self:CanCornerSell(initialCoords, self.Utils.pedCoords) then
                break
            end

            if time - lastCustomer > customerDelay then
                local reason = self:CreateCustomer(self.Utils.pedCoords)
                if not reason then
                    lastCustomer = time
                    customerDelay = math.random(1000 * 20, 1000 * 40)
                end
            end

            self:CheckCustomerPostions()

            Wait(1000)
        end

        for k,v in pairs(self.customerPed) do
            ClearPedTasks(k)
            SetEntityAsNoLongerNeeded(k)
        end

        self.customerPed = {}

        self.cornerSelling = false

        Utils:Notify("Vente terminer")
    end)
end

function Tr:GetNode(pedCoords)
    local init = GetGameTimer()

    repeat
        local coords = (vector3(pedCoords.x + math.random(-80,80),pedCoords.y + math.random(-80,80), pedCoords.z))
        local found, nodeCoords, nodeHeading = GetClosestVehicleNodeWithHeading(coords.x, coords.y, coords.z, 1, 3.0, 0)
        local dst = #(nodeCoords - pedCoords)

        if dst < 120 and dst > 60 then
            return nodeCoords, nodeHeading
        end

        Wait(100)
    until GetGameTimer() - init > 10000
end

function Tr:GetColision(customerPed, nodeCoords)
    local offset = GetOffsetFromEntityInWorldCoords(customerPed, 30.0, 0.0, -1.0)
    local rayHandle = StartShapeTestRay(nodeCoords.x, nodeCoords.y, nodeCoords.z, offset.x, offset.y, offset.z, 1, customerPed, 1)
    local retval, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
    return endCoords
end

function Tr:CreateCustomer(pedCoords)
    self:ClearCreatedPeds()

    local ped = PlayerPedId()

    if IsPedArmed(ped,4) then
        return
    end

    local nodeCoords, nodeHeading = self:GetNode(pedCoords)

    if not nodeCoords then
        return ("Invalid node")
    end

    local this = self.currentTerritory and self.Territories[self.currentTerritory] or nil
    if not this then
        return ("Invalid_territory")
    end

    local model = this.owned and this.owned.gang and self.Gangs[this.owned.gang] and self.Gangs[this.owned.gang].ped or "a_f_m_bodybuild_01"
    local customerPed = Utils:SpawnPed(model, nodeCoords, nodeHeading, true)

    self.customerPed[customerPed] = {time = GetGameTimer(), remove = false}

    FreezeEntityPosition(customerPed,true)
    SetPedDropsWeaponsWhenDead(customerPed, false)
    SetPedFleeAttributes(customerPed, 0, 0)
    SetPedSuffersCriticalHits(customerPed, false)
    SetEntityVisible(customerPed, false, 0)

    local endCoords = self:GetColision(customerPed, nodeCoords)

    if not endCoords or endCoords == vector3(0,0,0) then
        DeleteEntity(customerPed)
        self.customerPed[customerPed] = nil
        return "cant_reposition"
    end

    SetEntityCoords(customerPed, endCoords)
    FreezeEntityPosition(customerPed, false)
    SetEntityVisible(customerPed, true, 0)

    TaskGoToEntity(customerPed, ped, -1, 2.0, 1.0, 1073741824, 0)
    SetPedKeepTask(customerPed, true)

    local hasTerritoryControl = self.currentTerritory and self.Territories[self.currentTerritory].owned.gang == self.Player.gang.name

    if not hasTerritoryControl then
        local randi = math.random(0,20)

        if randi <= 2 then
            GiveWeaponToPed(customerPed, joaat("WEAPON_PISTOL"), 100, false, true)

            CreateThread(function()
                local init = GetGameTimer()

                while #(GetEntityCoords(customerPed) - GetEntityCoords(ped)) > 8 and GetGameTimer() - init < 1000 * 60 do
                    Wait(100)
                end

                TaskCombatPed(customerPed, ped, 0, 16)
                SetPedKeepTask(customerPed, true)

                exports.plouffe_dispatch:SendAlert('GunShot', nil, 5000)
            end)
        end
    end
end

function Tr:CheckCustomerPostions()
    for k,v in pairs(self.customerPed) do
        local pedCoords = GetEntityCoords(k)
        local dst = #(self.Utils.pedCoords - pedCoords)

        if dst < 3 then
            v.reached = not v.buying and v.reached and v.reached + 1 or 1

            if v.reached == 10 then
                local randi = math.random(1,2)
                local randi = 1
                if randi == 1 then
                    TaskWanderStandard(k, 10.0, 10)
                    Wait(5000)
                    Utils:PlayAnim(4000, "cellphone@", "cellphone_call_listen_base" , 49, 3.0, 2.0, 4000, false, true, false, {model = "prop_npc_phone_02", bone = 28422},nil,{ped = k})
                    TaskSmartFleePed(k, self.Utils.ped, 500.0, -1, true, true)
                    exports.plouffe_dispatch:SendAlert("RefusedDrugDeal")
                elseif randi == 2 then
                    TaskCombatPed(k, self.Utils.ped, 0, 16)
                    SetPedKeepTask(k)
                end

                SetPedAsNoLongerNeeded(k)
                self.customerPed[k] = nil
                break
            end
        end
    end
end

function Tr:GetClosestPed()
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local closest = nil
    local closestDistance = 5

    for k,v in pairs(self.customerPed) do
        if not v.reached or v.reached and v.reached < 10 then
            local distance = #(GetEntityCoords(k) - pedCoords)

            if distance < closestDistance and not Entity(k).state.boughtDrugs then
                distance = closestDistance
                closest = k
            end
        end
    end

    return closest and closest or nil
end

function Tr:GetItemCount(item)
    local count = exports.ox_inventory:Search("count", item)
    count = count and count or 0
    return count, item
end

function Tr:GetDrugForSell(list)
    for k,v in pairs(list) do
        local itemCount = self:GetItemCount(k)

        if itemCount > v.amount then
            return v
        end
    end
end

function Tr.Sell()
    self = Tr

    if self.Utils.inVehicle or self.Utils.hasWeapon or self.Utils.isCuffed then
        return
    end

    local targetPed = self:GetClosestPed()

    if not targetPed then
        return
    end

    local zone = self.Zones()

    if not zone then
        return
    end

    local drug = self:GetDrugForSell(zone.drugs)

    if not drug then
        return Utils:Notify("Vous n'avez pas de drogues a vendre")
    end

    local ped = PlayerPedId()
    local canSell, reason = self:CanSellDrug(targetPed, ped)

    if not canSell then
        return
    end

    self.customerPed[targetPed].buying = true

    if self:DoSellAnim(ped, targetPed) then
        if self.customerPed[targetPed] then
            self.customerPed[targetPed] = nil
            local netId = PedToNet(targetPed)
            TriggerServerEvent("plouffe_territories:soldDrugs", drug, netId, self.Utils.MyAuthKey)
            exports.plouffe_status:Add("Stress", 2)
        end
    end
end

function Tr.BurnerPhone(data)
    if Tr:GetItemCount("burner_phone") > 0 then
        Tr:CornerSell()
    end
end
exports("BurnerPhone", Tr.BurnerPhone)

function Tr:HouseRobbery()
    exports.plouffe_houserobbery:Register()
    Utils:PlayAnim(8000, "cellphone@", "cellphone_text_read_base" , 49, 3.0, 2.0, 8000, false, true, false, {model = "prop_npc_phone_02", bone = 28422})
end

function Tr:TrainRobbery()
    exports.plouffe_trainrobbery:RequestTrainSpawn()
end

function Tr.TryCraftOthers(name)
    if not Tr.Craftables[name] then
        return
    end

    for k,v in pairs(Tr.Craftables[name].required) do
        if Tr:GetItemCount(k) < v.amount then
            return Utils:Notify(("Il vous manque %s x %s"):format(v.label, v.amount))
        end
    end

    local finished = exports.ox_lib:progressCircle({
        duration = 20000,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        anim = {
            dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
            clip = "machinic_loop_mechandplayer",
            flag = 1
        },
        disable = {
            move = true,
            car = true,
            combat = true,
        }
    })

    if not finished then
        return
    end

    TriggerServerEvent("plouffe_territories:tryCraft", {name = name}, Tr.Utils.MyAuthKey)
end
exports("CraftOther", Tr.TryCraftOthers)

function Tr.TryCraft(data)
    if data.name ~= "blueprint" or Tr:GetItemCount("blueprint") < 1 then
        return
    end

    local zone = Tr:HasAcces()

    if not Tr.currentCraftBench or (Tr.currentCraftBench and not zone) or (zone.owned.gang ~= Tr.Player.gang.name) then
        return Utils:Notify("Vous avez besoin d'un workbench")
    end

    if not Tr.Craftables[data.metadata.weapon] then
        return Utils:Notify("Il est impossible de fabriquer cette arme")
    end

    for k,v in pairs(Tr.Craftables[data.metadata.weapon].required) do
        if Tr:GetItemCount(k) < v.amount then
            return Utils:Notify(("Il vous manque %s x %s"):format(v.label, v.amount))
        end
    end

    local finished = exports.ox_lib:progressCircle({
        duration = 20000,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        anim = {
            dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
            clip = "machinic_loop_mechandplayer",
        },
        disable = {
            move = true,
            car = true,
            combat = true,
        }
    })

    if not finished then
        return
    end

    TriggerServerEvent("plouffe_territories:tryCraft", data, Tr.Utils.MyAuthKey)
end
exports("TryCraft", Tr.TryCraft)

local function getZone()
    return Tr.Zones()
end

exports("getZone", getZone)
exports("hasAcces", Tr.HasAcces)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == "plouffe_territories" then
        local peds = Tr.customerPed
        for k,v in pairs(peds) do
            DeleteEntity(k)
        end
    end
end)

AddEventHandler("populationPedCreating", function(x, y, z, model, setters)
    local coords = vector3(x,y,z)
    for k,v in pairs(Tr.TerritoryZones) do
        if exports.plouffe_lib:AreCoordsInZone(k, coords) then
            local variations = Tr.Gangs[Tr.Territories[v].owned.gang].variations
            local model = variations[math.random(1, #variations)]
            Utils:AssureModel(model)
            setters.setModel(model)
            break
        end
    end
end)