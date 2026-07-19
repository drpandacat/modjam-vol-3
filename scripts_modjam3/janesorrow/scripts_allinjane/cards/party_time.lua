local FIRERATE_ADD = 0.03
local EFF_DURATION = 30*20

---@param id Card
---@param player EntityPlayer
---@param flags UseFlag
local function useCard(_, id, player, flags)
    local data = AllInJane:getData(player)
    data.PARTY_TIME_DURATION = (data.PARTY_TIME_DURATION or 0)+EFF_DURATION

    AllInJane.SFX:Play(AllInJane.SFX_FOIL)
    AllInJane:playAnnouncerVoice(AllInJane.SFX_JIMBO, flags)
end
AllInJane:AddCallback(ModCallbacks.MC_USE_CARD, useCard, AllInJane.CARD_PARTY_TIME)

---@param player EntityPlayer
local function peffectUpdate(_, player)
    local data = AllInJane:getData(player)
    if(data.PARTY_TIME_DURATION) then
        data.PARTY_TIME_DURATION = data.PARTY_TIME_DURATION-1
        if(data.PARTY_TIME_DURATION<=0) then
            data.PARTY_TIME_DURATION = nil
        end
    end
end
AllInJane:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, peffectUpdate)

---@param npc EntityNPC
local function addFirerate(_, npc)
    for i=0, AllInJane.GAME:GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        if(pl and AllInJane:getData(pl).PARTY_TIME_DURATION) then
            local data = AllInJane:getData(pl)
            if(data.PARTY_TIME_DURATION) then
                data.PARTY_TIME_STAT = (data.PARTY_TIME_STAT or 0)+FIRERATE_ADD
                pl:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
            end
        end
    end
end
AllInJane:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, addFirerate)

---@param pl EntityPlayer
---@param val number
local function evalStat(_, pl, stat, val)
    local data = AllInJane:getData(pl)
    if(not data.PARTY_TIME_STAT) then return end

    return val+data.PARTY_TIME_STAT
end
AllInJane:AddCallback(ModCallbacks.MC_EVALUATE_STAT, evalStat, EvaluateStatStage.FLAT_TEARS)