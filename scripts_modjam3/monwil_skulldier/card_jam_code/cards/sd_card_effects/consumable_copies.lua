local mod = HODGEPODGE

local bannedCards = {
    [Card.CARD_FOOL] = true,
    [Card.CARD_EMPEROR] = true,
    [Card.CARD_HERMIT] = true,
    [Card.CARD_STARS] = true,
    [Card.CARD_MOON] = true,
    [Card.CARD_JOKER] = true,
    [Card.CARD_SUICIDE_KING] = true,
    [Card.CARD_QUESTIONMARK] = true,
    [Card.CARD_REVERSE_WHEEL_OF_FORTUNE] = true,
    [Card.CARD_REVERSE_MOON] = true,
    [Card.CARD_WILD] = true,

    [Card.CARD_SOUL_LAZARUS] = true,
}

local cards = {Card.CARD_DEVIL}
local runes = {Card.RUNE_SHARD}

local function PostGameStarted()
    cards = {}
    runes = {}
    for id = 1, Card.NUM_CARDS do
        if bannedCards[id] then
            goto continue
        end
        local config = mod.ItemConfig:GetCard(id)
        if not (config and config:IsAvailable()) then
            goto continue
        end
        if config:IsCard() then
            table.insert(cards, id)
        elseif config:IsRune() then
            table.insert(runes, id)
        end
        ::continue::
    end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, PostGameStarted)

---@param player EntityPlayer
local function TriggerRandomCard(player)
    local rng = player:GetCardRNG(mod.Card.SD_CARD)
    local card = cards[rng:RandomInt(1, #cards)]
    player:UseCard(card, UseFlag.USE_MIMIC)
end

---@param player EntityPlayer
local function TriggerRandomRune(player)
    local rng = player:GetCardRNG(mod.Card.SD_CARD)
    local card = runes[rng:RandomInt(1, #runes)]
    player:UseCard(card, UseFlag.USE_MIMIC)
end

return {TriggerRandomCard, TriggerRandomRune}