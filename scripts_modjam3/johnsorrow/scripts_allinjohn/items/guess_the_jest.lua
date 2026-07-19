local CARD_SPAWNS = 3

local POSSIBLE_SPAWNS = {
    AllInJohn.CARD_LITTLE_BOY_BLUE,
    AllInJohn.CARD_HAT_TRICK,
    AllInJohn.CARD_COMEDIANS_MANIFESTO,
    AllInJohn.CARD_LEXICON,
    AllInJohn.CARD_GNASHER,
    AllInJohn.CARD_SILVIO,
    AllInJohn.CARD_EULENSPIEGEL,
    AllInJohn.CARD_COCONUT,
}

local CARD_PICKER = WeightedOutcomePicker()
CARD_PICKER:AddOutcomeFloat(AllInJohn.CARD_LITTLE_BOY_BLUE, 1)
CARD_PICKER:AddOutcomeFloat(AllInJohn.CARD_HAT_TRICK, 1)
CARD_PICKER:AddOutcomeFloat(AllInJohn.CARD_COMEDIANS_MANIFESTO, 1)
CARD_PICKER:AddOutcomeFloat(AllInJohn.CARD_LEXICON, 1)
CARD_PICKER:AddOutcomeFloat(AllInJohn.CARD_GNASHER, 1)
CARD_PICKER:AddOutcomeFloat(AllInJohn.CARD_SILVIO, 1)
CARD_PICKER:AddOutcomeFloat(AllInJohn.CARD_EULENSPIEGEL, 0.1)
CARD_PICKER:AddOutcomeFloat(AllInJohn.CARD_COCONUT, 1)
CARD_PICKER:AddOutcomeFloat(Card.CARD_JOKER, 1)

if(AllInJane) then
    CARD_PICKER:AddOutcomeFloat(AllInJane.CARD_NOBODY, 1)
    CARD_PICKER:AddOutcomeFloat(AllInJane.CARD_PARTY_TIME, 1)
    CARD_PICKER:AddOutcomeFloat(AllInJane.CARD_INFURIATING_NOTE, 1)
    CARD_PICKER:AddOutcomeFloat(AllInJane.CARD_BEANSTALK, 1)
    CARD_PICKER:AddOutcomeFloat(AllInJane.CARD_JERKO, 1)
    CARD_PICKER:AddOutcomeFloat(AllInJane.CARD_NEGATIVE_NANCY, 0.1)
    CARD_PICKER:AddOutcomeFloat(AllInJane.CARD_TALHAK, 1)
    CARD_PICKER:AddOutcomeFloat(AllInJane.CARD_YU_SZE, 1)
end


---@param rng RNG
---@param pl EntityPlayer
---@param flags UseFlag
local function useItem(_, _, rng, pl, flags, slot, _)
    local pickupIndex

    local room = AllInJane.GAME:GetRoom()

    local ogPos = room:FindFreePickupSpawnPosition(pl.Position+Vector(0,40), 0)

    for i=1, CARD_SPAWNS do
        local subToSpawn = CARD_PICKER:PickOutcome(rng)

        local pos = room:FindFreePickupSpawnPosition(ogPos+Vector((i-2)*40,0), 0)
        local card = Isaac.Spawn(5,PickupVariant.PICKUP_TAROTCARD,subToSpawn,pos,Vector.Zero,nil):ToPickup()
        if(card) then
            card:SetDropDelay(i*2)

            if(pickupIndex) then
                card.OptionsPickupIndex = pickupIndex
            else
                pickupIndex = card:SetNewOptionsPickupIndex()
            end
        end
    end

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
AllInJohn:AddCallback(ModCallbacks.MC_USE_ITEM, useItem, AllInJohn.COLLECTIBLE_GUESS_THE_JEST)