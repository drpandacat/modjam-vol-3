local DAMAGE_UP = 0.5
local LUCK_UP = 3

---@param id Card
---@param player EntityPlayer
---@param flags UseFlag
local function useCard(_, id, player, flags)
    local pos = CardjamFlipCards.GAME:GetRoom():FindFreePickupSpawnPosition(player.Position)
    local coin = Isaac.Spawn(5, PickupVariant.PICKUP_COIN, 0, pos, Vector.Zero, nil):ToPickup()

    CardjamFlipCards:playAnnouncerVoice(CardjamFlipCards.SFX_VOICE_CHARM_1, flags)
end
CardjamFlipCards:AddCallback(ModCallbacks.MC_USE_CARD, useCard, CardjamFlipCards.CARD_CHARM)

---@param player EntityPlayer
local function checkFlagsOnAddRemoveCard(_, player)
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_LUCK, true)
end
CardjamFlipCards:AddCallback(ModCallbacks.MC_POST_PLAYER_ADD_CARD, checkFlagsOnAddRemoveCard, CardjamFlipCards.CARD_CHARM)
CardjamFlipCards:AddCallback(ModCallbacks.MC_POST_PLAYER_REMOVE_CARD, checkFlagsOnAddRemoveCard, CardjamFlipCards.CARD_CHARM)

---@param player EntityPlayer
---@param pickup EntityPickup
local function destroyDroppedCard(_, player, pickup)
    pickup.Wait = 1000
    pickup.Timeout = 30

    CardjamFlipCards.SFX:Play(SoundEffect.SOUND_THUMBS_DOWN)
end
CardjamFlipCards:AddCallback(ModCallbacks.MC_POST_PLAYER_DROP_CARD, destroyDroppedCard, CardjamFlipCards.CARD_CHARM)

---@param player EntityPlayer
local function evalCache(_, player)
    local mult = 0
    for i=0, 3 do
        if(player:GetCard(i)==CardjamFlipCards.CARD_CHARM) then
            mult = mult+1
        end
    end

    if(mult==0) then return end

    player.Luck = player.Luck+mult*LUCK_UP
end
CardjamFlipCards:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache, CacheFlag.CACHE_LUCK)

---@param player EntityPlayer
---@param val number
local function evalStat(_, player, _, val)
    local mult = 0
    for i=0, 3 do
        if(player:GetCard(i)==CardjamFlipCards.CARD_CHARM) then
            mult = mult+1
        end
    end

    if(mult==0) then return end

    return val+mult*DAMAGE_UP
end
CardjamFlipCards:AddCallback(ModCallbacks.MC_EVALUATE_STAT, evalStat, EvaluateStatStage.FLAT_DAMAGE)