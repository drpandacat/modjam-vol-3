local mod = CardJam_AeroTruji
local id = mod.Enums.POLYMERIZATION
local id2 = mod.Enums.AMALGAM
local polyConfig = mod.Consts.Conf:GetCard(id)

---@param player EntityPlayer
---@return table
local function GetPolymerizationData(player)
    local data, exists = EntitySaveStateManager.GetEntityData(mod, player)
    -- if not exists then
        data.Polymerization = data.Polymerization or {}
    -- end
    return data.Polymerization
end

--[[ local function PolymerizationSpawnCondition()
    local spawnCard = true
    for _, player in ipairs(PlayerManager.GetPlayers()) do
        if #GetPolymerizationData(player) > 0 then
            spawnCard = false
            break
        end
    end
    return spawnCard
end ]]

---@param player EntityPlayer
mod:AddCallback(ModCallbacks.MC_USE_CARD, function (_, card, player, useflags)
    local data = GetPolymerizationData(player)
    local pills = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL)
    local cards = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD)
    local consumables = mod.Functions.CombineTables(pills, cards)
    for _, p in ipairs(consumables) do
        p = p:ToPickup()
        if p.Price == 0 then
            table.insert(data, {p.Variant, p.SubType})
            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, p.Position, Vector.Zero, nil)
            local col = poof.Color
            col:SetColorize(2, 0, 1, 1)
            poof.Color = col
            p:Remove()
        end
    end
    Isaac.CreateTimer(function ()
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, id2, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, player)
    end, 5, 1, true)
    --polyConfig:SetAvailabilityCondition(PolymerizationSpawnCondition)
end, id)

---@param player EntityPlayer
mod:AddCallback(ModCallbacks.MC_USE_CARD, function (_, card, player, useflags)
    local data = GetPolymerizationData(player)
    local basedelay = mod.Functions.Clamp(90 / #data, 4, 30)
    basedelay = math.ceil(basedelay)
    for i = 1, #data do
        local consumable = data[i]
        local delay = basedelay * i + 1
        if consumable[1] == PickupVariant.PICKUP_PILL then
            Isaac.CreateTimer(function ()
                local effect = mod.Consts.Game:GetItemPool():GetPillEffect(consumable[2], player)
                player:UsePill(effect, consumable[2], UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
            end, delay, 1, true)
        elseif consumable[1] == PickupVariant.PICKUP_TAROTCARD then
            Isaac.CreateTimer(function ()
                player:UseCard(consumable[2], UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
            end, delay, 1, true)
        end
    end
    data = EntitySaveStateManager.GetEntityData(mod, player)
    data.Polymerization = {}
    --polyConfig:ClearAvailabilityCondition()
end, id2)