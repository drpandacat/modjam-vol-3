--[[
Negative Nancy
 - +9% planetarium chance permanently
]]

local PLANETARIUM_CHANCE = 0.09

---@param id Card
---@param player EntityPlayer
---@param flags UseFlag
local function useCard(_, id, player, flags)
    local data = AllInJane:getUniversalData()
    data.NANCY_CHANCE = (data.NANCY_CHANCE or 0)+PLANETARIUM_CHANCE

    AllInJane.SFX:Play(AllInJane.SFX_POLYCHROME)
    AllInJane:playAnnouncerVoice(AllInJane.SFX_JIMBO, flags)
end
AllInJane:AddCallback(ModCallbacks.MC_USE_CARD, useCard, AllInJane.CARD_NEGATIVE_NANCY)

---@param chance number
local function applyChance(_, chance)
    local data = AllInJane:getUniversalData()
    if(data.NANCY_CHANCE) then
        return chance+data.NANCY_CHANCE
    end
end
AllInJane:AddCallback(ModCallbacks.MC_PRE_PLANETARIUM_APPLY_ITEMS, applyChance)