local sfx = AllInJohn.SFX

---@param id Card
---@param player EntityPlayer
---@param flags UseFlag
local function useCard(_, id, player, flags)
    local data = AllInJohn:getUniversalData()
    if(data.COMEDIANS_MANIFESTO_ACTIVE) then
        player:UseCard(Card.CARD_JUDGEMENT, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
    else
        data.COMEDIANS_MANIFESTO_ACTIVE = true
    end

    sfx:Play(AllInJohn.SFX_FORGE)
    AllInJohn:playAnnouncerVoice(AllInJohn.SFX_JIMBO, flags)
end
AllInJohn:AddCallback(ModCallbacks.MC_USE_CARD, useCard, AllInJohn.CARD_COMEDIANS_MANIFESTO)

local converting = false

---@param pickup EntityPickup
local function convertToCard(_, pickup)
    if(pickup.Variant==PickupVariant.PICKUP_TAROTCARD and pickup.SubType==Card.CARD_JUDGEMENT) then return end
    if(converting) then return end

    local data = AllInJohn:getUniversalData()
    if(data.COMEDIANS_MANIFESTO_ACTIVE) then
        converting = true
        pickup:Morph(5,PickupVariant.PICKUP_TAROTCARD,Card.CARD_JUDGEMENT,true)
        converting = false
    end
end
AllInJohn:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, convertToCard, PickupVariant.PICKUP_TAROTCARD)
AllInJohn:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, convertToCard, PickupVariant.PICKUP_PILL)

local function resetManifestoData(_)
    if(not AllInJohn.GAME:GetRoom():IsFirstVisit()) then return end

    local data = AllInJohn:getUniversalData()
    data.COMEDIANS_MANIFESTO_ACTIVE = nil
end
AllInJohn:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, resetManifestoData)