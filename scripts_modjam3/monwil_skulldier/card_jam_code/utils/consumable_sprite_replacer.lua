local mod = HODGEPODGE

local SPRITESHEET_PATH = "gfx/items/pick ups/hodgepodge_cards.png"
local RESPRITED_CONSUMABLES =
{
    [mod.Card.RED_SEAL] = true,
    [mod.Card.NIHIL] = true,
    [mod.Card.ECHO] = true,
    [mod.Card.THE_161_OF_CLUBS] = true,
    [mod.Card.CLAM_CARD] = true,
    [mod.Card.MANIFESTATION] = true,
    [mod.Card.SD_CARD] = true,
}

---@param pickup EntityPickup
local function PostPickupInitCard(_, pickup)
    if pickup.SubType == mod.Card.MOON then
        local sprite = pickup:GetSprite()
        local anim = sprite:GetAnimation()
        sprite:Load("gfx/moon_card.anm2", true)
        sprite:Play(anim, true)
        pickup:SetShadowSize(0.2)
        return
    end
    if not RESPRITED_CONSUMABLES[pickup.SubType] then
        return end

    local sprite = pickup:GetSprite()
    sprite:ReplaceSpritesheet(0, SPRITESHEET_PATH)
    sprite:LoadGraphics()
end

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, PostPickupInitCard, PickupVariant.PICKUP_TAROTCARD)
