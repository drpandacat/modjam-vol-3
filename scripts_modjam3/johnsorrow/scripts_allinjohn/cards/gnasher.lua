local sfx = AllInJohn.SFX

local COPY_SPAWNS = 2

---@param id Card
---@param player EntityPlayer
---@param flags UseFlag
local function useCard(_, id, player, flags)
    local copyableConsumables = {}
    for _, ent in ipairs(Isaac.FindByType(5)) do
        if(ent.Variant==PickupVariant.PICKUP_PILL or ent.Variant==PickupVariant.PICKUP_TAROTCARD) then
            local pickup = ent:ToPickup()
            if(pickup and not pickup:IsShopItem()) then
                table.insert(copyableConsumables, pickup)
            end
        end
    end

    if(#copyableConsumables>0) then
        local rng = player:GetCardRNG(id)
        local selPickup = copyableConsumables[rng:RandomInt(1,#copyableConsumables)] ---@type EntityPickup

        local room = AllInJohn.GAME:GetRoom()
        for i=1, COPY_SPAWNS do
            local pos = room:FindFreePickupSpawnPosition(selPickup.Position, 40)
            local newPick = Isaac.Spawn(5,selPickup.Variant,selPickup.SubType,pos,Vector.Zero,nil):ToPickup()
            if(newPick) then
                newPick:SetDropDelay((i-1)*2)
            end
        end
    end

    sfx:Play(AllInJohn.SFX_JOKER,1.3)
    AllInJohn:playAnnouncerVoice(AllInJohn.SFX_JIMBO, flags)
end
AllInJohn:AddCallback(ModCallbacks.MC_USE_CARD, useCard, AllInJohn.CARD_GNASHER)