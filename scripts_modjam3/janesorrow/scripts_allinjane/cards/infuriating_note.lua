--[[
Infuriating Note
 - passively gives +1 damage, replaces every pickup with infuriating note
 ]]

local DAMAGE_UP = 2

---@param id Card
---@param player EntityPlayer
---@param flags UseFlag
local function useCard(_, id, player, flags)
    if(flags & UseFlag.USE_OWNED == 0) then
        local pos = AllInJane.GAME:GetRoom():FindFreePickupSpawnPosition(player.Position)
        local coin = Isaac.Spawn(5, PickupVariant.PICKUP_TAROTCARD, AllInJane.CARD_INFURIATING_NOTE, pos, Vector.Zero, nil):ToPickup()
    end

    AllInJane:playAnnouncerVoice(AllInJane.SFX_JIMBO, flags)
end
AllInJane:AddCallback(ModCallbacks.MC_USE_CARD, useCard, AllInJane.CARD_INFURIATING_NOTE)

---@param player EntityPlayer
local function checkFlagsOnAddRemoveCard(_, player)
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
end
AllInJane:AddCallback(ModCallbacks.MC_POST_PLAYER_ADD_CARD, checkFlagsOnAddRemoveCard, AllInJane.CARD_INFURIATING_NOTE)
AllInJane:AddCallback(ModCallbacks.MC_POST_PLAYER_REMOVE_CARD, checkFlagsOnAddRemoveCard, AllInJane.CARD_INFURIATING_NOTE)

---@param player EntityPlayer
---@param val number
local function evalStat(_, player, _, val)
    local mult = 0
    for i=0, 3 do
        if(player:GetCard(i)==AllInJane.CARD_INFURIATING_NOTE) then
            mult = mult+1
        end
    end

    if(mult==0) then return end

    return val+mult*DAMAGE_UP
end
AllInJane:AddCallback(ModCallbacks.MC_EVALUATE_STAT, evalStat, EvaluateStatStage.FLAT_DAMAGE)

---@param pickup EntityPickup
local function infuriate(_, pickup, var, sub, rvar, rsub, rng)
    if(not (rvar==0 or rsub==0)) then return end

    for i=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        for j=0, 3 do
            if(pl:GetCard(j)==AllInJane.CARD_INFURIATING_NOTE) then
                return {PickupVariant.PICKUP_TAROTCARD, AllInJane.CARD_INFURIATING_NOTE, false}
            end
        end
    end
end
AllInJane:AddCallback(ModCallbacks.MC_POST_PICKUP_SELECTION, infuriate)