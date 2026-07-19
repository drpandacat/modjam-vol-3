local mod = HODGEPODGE

local validItems = {}

local cardConfig = mod.ItemConfig:GetCard(mod.Card.ECHO)

local ITEM_BLACKLIST = {
    [CollectibleType.COLLECTIBLE_RED_KEY] = true,
    [CollectibleType.COLLECTIBLE_CLEAR_RUNE] = true,
    [CollectibleType.COLLECTIBLE_BLANK_CARD] = true,
    [CollectibleType.COLLECTIBLE_PLACEBO] = true,
    [CollectibleType.COLLECTIBLE_MOVING_BOX] = true,
    [CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS] = true,
}

for id = 1, mod.ItemConfig:GetCollectibles().Size-1 do
    local item = mod.ItemConfig:GetCollectible(id)
    if item
    and not ITEM_BLACKLIST[id]
    and item.Type == ItemType.ITEM_ACTIVE
    and item.ChargeType == 0 --"Normal" chargetype
    and not item.Hidden
    and not item:HasCustomTag("nometronome")
    and not item:HasTags(ItemConfig.TAG_NO_EDEN)
    and item.MaxCharges > 0
    and item.InitCharge == -1 then
        table.insert(validItems, id)
    end
end

---@param item integer?
local function UpdateCardName(item)
    if not item then --This should never happen
        cardConfig.Description = "...TRANSMISSION FAILURE...MISSING ANCHOR POINT DEFINITION...SIMULATION COHERENCE VIOLATED...TIMELINE DIVERGENCE CRITICAL...ABANDONING ALL HOPE...RESTORING INERT STATE OF OPERATION..."
        return
    end

    local itemConfig = mod.ItemConfig:GetCollectible(item)
    local description = itemConfig.Description
    if string.sub(description, 1, 1) == "#" then
        description = Isaac.GetLocalizedString("Items", string.sub(description, 2), Options.Language)
    end
    cardConfig.Description = description
    cardConfig.MimicCharge = itemConfig.MaxCharges
end

local function RollNewMimicItem()
    local data = mod.SaveManager.GetRunSave()
    if not data.MimicSeed then
        data.MimicSeed = mod.Game:GetSeeds():GetStartSeed()
    end
    local rng = RNG(data.MimicSeed)
    local newItem = validItems[rng:RandomInt(1, #validItems)]

    data.MimicItem = newItem
    data.MimicSeed = rng:GetSeed()

    UpdateCardName(newItem)
end

---@param isContinued boolean
local function PostGameStarted(_, isContinued)
    if not isContinued then
        RollNewMimicItem()
    else
        UpdateCardName(mod.SaveManager.GetRunSave().MimicItem)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, PostGameStarted)

---@param flags integer
---@param player EntityPlayer
local function UseCard(_, _, player, flags)
    local data = mod.SaveManager.GetRunSave()
    if data.MimicItem then
        player:UseActiveItem(data.MimicItem, UseFlag.USE_NOANIM)
    end

    if flags & (UseFlag.USE_MIMIC | UseFlag.USE_CARBATTERY | UseFlag.USE_NOANIM) == 0 then
        local rng = player:GetCardRNG(mod.Card.ECHO)
        local effects = player:GetEffects()
        local failChance = effects:GetNullEffectNum(mod.NullItemID.ECHO_STREAK_COUNTER)*0.25
        if rng:RandomFloat() < failChance then
            effects:RemoveNullEffect(mod.NullItemID.ECHO_STREAK_COUNTER, -1)
        else
            local pos = Isaac.GetFreeNearPosition(player.Position, 10)
            Isaac.Spawn(
                EntityType.ENTITY_PICKUP,
                PickupVariant.PICKUP_TAROTCARD,
                mod.Card.ECHO,
                pos,
                Vector.Zero,
                nil
            )
            effects:AddNullEffect(mod.NullItemID.ECHO_STREAK_COUNTER)
        end
    end

    RollNewMimicItem()
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, UseCard, mod.Card.ECHO)