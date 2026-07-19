local sfx = AllInJohn.SFX

---@param id Card
---@param player EntityPlayer
---@param flags UseFlag
local function useCard(_, id, player, flags)
    player:SetInnateCollectibleGroup("AllInJohnCoconutItems", {
        [CollectibleType.COLLECTIBLE_MOMS_PURSE] = 1,
        [CollectibleType.COLLECTIBLE_POLYDACTYLY] = 1,
    })

    sfx:Play(AllInJohn.SFX_BALANCE)
    AllInJohn:playAnnouncerVoice(AllInJohn.SFX_JIMBO, flags)
end
AllInJohn:AddCallback(ModCallbacks.MC_USE_CARD, useCard, AllInJohn.CARD_COCONUT)

---@param pl EntityPlayer
local function removeHatTrick(_, pl)
    if(pl.FrameCount==0) then return end

    pl:SetInnateCollectibleGroup("AllInJohnCoconutItems", {})
end
AllInJohn:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, removeHatTrick)