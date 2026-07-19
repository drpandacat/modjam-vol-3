local mod = HODGEPODGE

---@param player EntityPlayer
---@return EntityPickup?
local function FindClosestItemPedestal(player)
    local pedestals = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)
    local filteredPedestals = {}
    for _, pedestal in ipairs(pedestals) do
        if pedestal.SubType ~= 0
        and pedestal:ToPickup():CanReroll() then
            table.insert(filteredPedestals, pedestal)
        end
    end
    if #filteredPedestals == 0 then
        return
    end
    local playerPos = player.Position
    table.sort(filteredPedestals, function (a, b)
        return a.Position:DistanceSquared(playerPos) < b.Position:DistanceSquared(playerPos)
    end)
    return filteredPedestals[1]:ToPickup()
end

---@param player EntityPlayer
local function UseCard(_, _, player)
    local target = FindClosestItemPedestal(player)
    local persistentData = mod.SaveManager.GetPersistentSave()

    if not target then
        persistentData.NihilStoredItem = nil
        return
    end

    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, target.Position, Vector.Zero, nil)
    local currentItem = target.SubType
    if persistentData.NihilStoredItem
    and mod.ItemConfig:GetCollectible(persistentData.NihilStoredItem) then --Precaution if ID becomes invalid because of changing mods.
        target:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, persistentData.NihilStoredItem, true)
    else
        target:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, mod.CollectibleType.OLD_DATA, true)
    end
    persistentData.NihilStoredItem = currentItem
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, UseCard, mod.Card.NIHIL)