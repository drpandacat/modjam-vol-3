local mod = HODGEPODGE

---@param player EntityPlayer
local function UseCard(_, _, player)
    ---@type EntityPlayer
    local clone = mod.CoplayerManager.SpawnCoplayer(player, mod.PlayerType.MANIFESTATION)
    clone.Position = player.Position

    for _, trinket in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET)) do
        Isaac.Spawn(
            EntityType.ENTITY_EFFECT,
            EffectVariant.POOF01,
            0,
            trinket.Position,
            Vector.Zero,
            nil
        )
        local ghost = Isaac.Spawn(
            EntityType.ENTITY_EFFECT,
            EffectVariant.ENEMY_SOUL,
            0,
            trinket.Position,
            (clone.Position - trinket.Position):Resized(15),
            clone
        ):ToEffect()
        ---@cast ghost EntityEffect
        ghost.Target = clone
        clone:AddSmeltedTrinket(trinket.SubType)
        trinket:Remove()
    end

    for _, pedestal in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
        local item = pedestal.SubType
        local config = mod.ItemConfig:GetCollectible(item)
        if item ~= 0
        and not config:HasTags(ItemConfig.TAG_QUEST)
        and config.Type ~= ItemType.ITEM_ACTIVE then
            Isaac.Spawn(
                EntityType.ENTITY_EFFECT,
                EffectVariant.POOF01,
                0,
                pedestal.Position,
                Vector.Zero,
                nil
            )
            local ghost = Isaac.Spawn(
                EntityType.ENTITY_EFFECT,
                EffectVariant.ENEMY_SOUL,
                0,
                pedestal.Position,
                (clone.Position - pedestal.Position):Resized(15),
                clone
            ):ToEffect()
            ---@cast ghost EntityEffect
            ghost.Target = clone
            pedestal:Remove()
            clone:AddCollectible(item)
        end
    end

    clone:PlayExtraAnimation("Appear")
    clone.ControlsEnabled = false
    Isaac.CreateTimer(function ()
        clone.ControlsEnabled = true
    end, 40, 1, true)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, UseCard, mod.Card.MANIFESTATION)

---@param player EntityPlayer
---@param amount integer
---@param type AddHealthType
local function PrePlayerAddHealth(_, player, amount, type)
    if type == AddHealthType.BROKEN then
        if amount < 0
        and player.FrameCount > 1
        and player:GetPlayerType() == mod.PlayerType.MANIFESTATION
        and not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
            return 0
        end
    else
        if amount > 0
        and player.FrameCount > 1
        and player:GetPlayerType() == mod.PlayerType.MANIFESTATION
        and not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
            return 0
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, PrePlayerAddHealth)

---@param pickup EntityPickup
---@param collider Entity
local function PreHeartCollision(_, pickup, collider)
    local player = collider:ToPlayer()
    if not player then
        return
    end
    if player:GetPlayerType() == mod.PlayerType.MANIFESTATION
    and not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
        return false
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, PreHeartCollision, PickupVariant.PICKUP_HEART)

---@param player EntityPlayer
---@param cacheFlag CacheFlag
local function CacheEval(_, player, cacheFlag)
    if cacheFlag == CacheFlag.CACHE_FLYING
    and player:GetPlayerType() == mod.PlayerType.MANIFESTATION then
        player.CanFly = true
    elseif cacheFlag == CacheFlag.CACHE_TEARFLAG
    and player:GetPlayerType() == mod.PlayerType.MANIFESTATION then
        player.TearFlags = player.TearFlags | TearFlags.TEAR_SPECTRAL
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, CacheEval)