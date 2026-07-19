local FLIPFLOP_CARDS = {
    CardjamFlipCards.CARD_REPORT,
    CardjamFlipCards.CARD_SCRATCH,
    CardjamFlipCards.CARD_CHARM,
    CardjamFlipCards.CARD_BOARD,
    CardjamFlipCards.CARD_REPORT_ALT,
    CardjamFlipCards.CARD_SCRATCH_ALT,
    CardjamFlipCards.CARD_CHARM_ALT,
    CardjamFlipCards.CARD_BOARD_ALT,
}

local CARD_FLIPS = {
    [CardjamFlipCards.CARD_REPORT] = CardjamFlipCards.CARD_REPORT_ALT,
    [CardjamFlipCards.CARD_SCRATCH] = CardjamFlipCards.CARD_SCRATCH_ALT,
    [CardjamFlipCards.CARD_CHARM] = CardjamFlipCards.CARD_CHARM_ALT,
    [CardjamFlipCards.CARD_BOARD] = CardjamFlipCards.CARD_BOARD_ALT,

    [CardjamFlipCards.CARD_REPORT_ALT] = CardjamFlipCards.CARD_REPORT,
    [CardjamFlipCards.CARD_SCRATCH_ALT] = CardjamFlipCards.CARD_SCRATCH,
    [CardjamFlipCards.CARD_CHARM_ALT] = CardjamFlipCards.CARD_CHARM,
    [CardjamFlipCards.CARD_BOARD_ALT] = CardjamFlipCards.CARD_BOARD,

    [Card.CARD_FOOL] = Card.CARD_REVERSE_FOOL,
    [Card.CARD_MAGICIAN] = Card.CARD_REVERSE_MAGICIAN,
    [Card.CARD_HIGH_PRIESTESS] = Card.CARD_REVERSE_HIGH_PRIESTESS,
    [Card.CARD_EMPRESS] = Card.CARD_REVERSE_EMPRESS,
    [Card.CARD_EMPEROR] = Card.CARD_REVERSE_EMPEROR,
    [Card.CARD_HIEROPHANT] = Card.CARD_REVERSE_HIEROPHANT,
    [Card.CARD_LOVERS] = Card.CARD_REVERSE_LOVERS,
    [Card.CARD_CHARIOT] = Card.CARD_REVERSE_CHARIOT,
    [Card.CARD_JUSTICE] = Card.CARD_REVERSE_JUSTICE,
    [Card.CARD_HERMIT] = Card.CARD_REVERSE_HERMIT,
    [Card.CARD_WHEEL_OF_FORTUNE] = Card.CARD_REVERSE_WHEEL_OF_FORTUNE,
    [Card.CARD_STRENGTH] = Card.CARD_REVERSE_STRENGTH,
    [Card.CARD_HANGED_MAN] = Card.CARD_REVERSE_HANGED_MAN,
    [Card.CARD_DEATH] = Card.CARD_REVERSE_DEATH,
    [Card.CARD_TEMPERANCE] = Card.CARD_REVERSE_TEMPERANCE,
    [Card.CARD_DEVIL] = Card.CARD_REVERSE_DEVIL,
    [Card.CARD_TOWER] = Card.CARD_REVERSE_TOWER,
    [Card.CARD_STARS] = Card.CARD_REVERSE_STARS,
    [Card.CARD_MOON] = Card.CARD_REVERSE_MOON,
    [Card.CARD_SUN] = Card.CARD_REVERSE_SUN,
    [Card.CARD_JUDGEMENT] = Card.CARD_REVERSE_JUDGEMENT,
    [Card.CARD_WORLD] = Card.CARD_REVERSE_WORLD,

    [Card.CARD_REVERSE_FOOL] = Card.CARD_FOOL,
    [Card.CARD_REVERSE_MAGICIAN] = Card.CARD_MAGICIAN,
    [Card.CARD_REVERSE_HIGH_PRIESTESS] = Card.CARD_HIGH_PRIESTESS,
    [Card.CARD_REVERSE_EMPRESS] = Card.CARD_EMPRESS,
    [Card.CARD_REVERSE_EMPEROR] = Card.CARD_EMPEROR,
    [Card.CARD_REVERSE_HIEROPHANT] = Card.CARD_HIEROPHANT,
    [Card.CARD_REVERSE_LOVERS] = Card.CARD_LOVERS,
    [Card.CARD_REVERSE_CHARIOT] = Card.CARD_CHARIOT,
    [Card.CARD_REVERSE_JUSTICE] = Card.CARD_JUSTICE,
    [Card.CARD_REVERSE_HERMIT] = Card.CARD_HERMIT,
    [Card.CARD_REVERSE_WHEEL_OF_FORTUNE] = Card.CARD_WHEEL_OF_FORTUNE,
    [Card.CARD_REVERSE_STRENGTH] = Card.CARD_STRENGTH,
    [Card.CARD_REVERSE_HANGED_MAN] = Card.CARD_HANGED_MAN,
    [Card.CARD_REVERSE_DEATH] = Card.CARD_DEATH,
    [Card.CARD_REVERSE_TEMPERANCE] = Card.CARD_TEMPERANCE,
    [Card.CARD_REVERSE_DEVIL] = Card.CARD_DEVIL,
    [Card.CARD_REVERSE_TOWER] = Card.CARD_TOWER,
    [Card.CARD_REVERSE_STARS] = Card.CARD_STARS,
    [Card.CARD_REVERSE_MOON] = Card.CARD_MOON,
    [Card.CARD_REVERSE_SUN] = Card.CARD_SUN,
    [Card.CARD_REVERSE_JUDGEMENT] = Card.CARD_JUDGEMENT,
    [Card.CARD_REVERSE_WORLD] = Card.CARD_WORLD,

    [Card.CARD_RULES] = Card.CARD_HUMANITY,
    [Card.CARD_HUMANITY] = Card.CARD_RULES
}


---@param rng RNG
---@param pl EntityPlayer
---@param flags UseFlag
local function useItem(_, _, rng, pl, flags, slot, _)
    if(slot==-1 or pl:GetTotalActiveCharge(slot)>=pl:GetActiveMaxCharge(slot)) then
        local cardSelect = FLIPFLOP_CARDS[rng:RandomInt(1,#FLIPFLOP_CARDS)]
        pl:AddCard(cardSelect)

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    else
        pl:AddActiveCharge(-1, slot)

        for i=0,3 do
            if(CARD_FLIPS[pl:GetCard(i)]) then
                pl:SetCard(i, CARD_FLIPS[pl:GetCard(i)])
            end
        end

        return {
            Discharge = false,
            Remove = false,
            ShowAnim = true,
        }
    end
end
CardjamFlipCards:AddCallback(ModCallbacks.MC_USE_ITEM, useItem, CardjamFlipCards.COLLECTIBLE_DOUBLE_SIDED_CARD)

---@param slot ActiveSlot
---@param pl EntityPlayer
---@param minCharge integer
local function getMinUsableCharge(_, slot, pl, minCharge)
    return 1
end
CardjamFlipCards:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MIN_USABLE_CHARGE, getMinUsableCharge, CardjamFlipCards.COLLECTIBLE_DOUBLE_SIDED_CARD)