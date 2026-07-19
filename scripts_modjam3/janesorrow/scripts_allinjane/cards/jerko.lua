--[[
Jerko
 - +0.25 damage and take fake damage, retriggers 0-10 times at random
]]

local sfx = AllInJane.SFX

local DAMAGE_UP = 0.25
local MAX_TRIGGERS = 10
local TRIGGER_DELAY = 30

local RETRIGGER_DELAY_DEC = 2

---@param player EntityPlayer
local function jerkoEffect(player)
    local data = AllInJane:getData(player)
    data.JERKO_DAMAGE = (data.JERKO_DAMAGE or 0)+DAMAGE_UP
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)

    player:TakeDamage(1, DamageFlag.DAMAGE_FAKE, EntityRef(player), 0)
end

---@param id Card
---@param player EntityPlayer
---@param flags UseFlag
local function useCard(_, id, player, flags)
    jerkoEffect(player)
    player:AnimateCard(id, "UseItem")

    local numRetriggers = player:GetCardRNG(id):RandomInt(0, MAX_TRIGGERS)
    if(numRetriggers>0) then
        local retriggersSoFar = 0
        local nextEffectFrame = TRIGGER_DELAY
        local maxEffectFrame = TRIGGER_DELAY*numRetriggers-(numRetriggers*(numRetriggers-1)/2)*RETRIGGER_DELAY_DEC

       Isaac.CreateTimer(
            ---@param effect EntityEffect
            function(effect)
                if(effect.FrameCount==nextEffectFrame) then
                    if(player and player:Exists()) then
                        retriggersSoFar = retriggersSoFar+1

                        jerkoEffect(player)
                        sfx:Play(AllInJane.SFX_MULT,nil,nil,nil,1+retriggersSoFar*0.05)
                        player:AnimateCard(id, "UseItem")

                        nextEffectFrame = nextEffectFrame+TRIGGER_DELAY-retriggersSoFar*RETRIGGER_DELAY_DEC
                    end
                end
            end,
            1,
            maxEffectFrame,
            false
       )
    end

    sfx:Play(AllInJane.SFX_MULT)
    AllInJane:playAnnouncerVoice(AllInJane.SFX_JIMBO, flags)
end
AllInJane:AddCallback(ModCallbacks.MC_USE_CARD, useCard, AllInJane.CARD_JERKO)

---@param pl EntityPlayer
---@param val number
local function evalStat(_, pl, stat, val)
    local data = AllInJane:getData(pl)
    if(not data.JERKO_DAMAGE) then return end

    return val+data.JERKO_DAMAGE
end
AllInJane:AddCallback(ModCallbacks.MC_EVALUATE_STAT, evalStat, EvaluateStatStage.FLAT_DAMAGE)

---@param pl EntityPlayer
local function removeJerkoStats(_, pl)
    local data = AllInJane:getData(pl)
    if(data.JERKO_DAMAGE) then
        data.JERKO_DAMAGE = nil
        pl:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
    end
end
AllInJane:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, removeJerkoStats)
