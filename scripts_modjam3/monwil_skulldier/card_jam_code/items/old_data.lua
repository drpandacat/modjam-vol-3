local mod = HODGEPODGE

local function GetCard()
    if PlayerManager.AnyoneHasCollectible(mod.CollectibleType.OLD_DATA) then
        return mod.Card.SD_CARD
    end
end
mod:AddCallback(ModCallbacks.MC_GET_CARD, GetCard)

local PICKUP_BLACKLIST = {
    [PickupVariant.PICKUP_COLLECTIBLE] = true,
    [PickupVariant.PICKUP_BED] = true,
    [PickupVariant.PICKUP_TROPHY] = true,
    [PickupVariant.PICKUP_THROWABLEBOMB] = true,
    [PickupVariant.PICKUP_POOP] = true,
    [PickupVariant.PICKUP_BROKEN_SHOVEL] = true,
    [PickupVariant.PICKUP_BIGCHEST] = true,
}

local pickups = {
    {PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY}
}

---@param pickup EntityPickup
---@param variant integer
---@param subType integer
---@param reqVariant integer
---@param reqSubType integer
---@param rng RNG
local function PickupSelection(_, pickup, variant, subType, reqVariant, reqSubType, rng)
    if reqVariant ~= 0 and reqSubType ~= 0 then
        return
    end
    if PICKUP_BLACKLIST[variant] then
        return
    end
    if not PlayerManager.AnyoneHasCollectible(mod.CollectibleType.OLD_DATA) then
        return
    end
    local result = pickups[rng:RandomInt(1, #pickups)]
    if result[1] == PickupVariant.PICKUP_PILL then
        return {PickupVariant.PICKUP_PILL, rng:RandomInt(1, PillColor.NUM_STANDARD_PILLS-1)}
    elseif result[1] == PickupVariant.PICKUP_TRINKET then
        return {PickupVariant.PICKUP_TRINKET, mod.ItemPool:GetTrinket()}
    end
    return result

end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_SELECTION, PickupSelection)

local function PostGameStarted()
    pickups = {
        {PickupVariant.PICKUP_PILL, 0},
        {PickupVariant.PICKUP_TRINKET, 0},
        {PickupVariant.PICKUP_TAROTCARD, mod.Card.SD_CARD},

        {PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL},
        {PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF},
        {PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL},
        {PickupVariant.PICKUP_HEART, HeartSubType.HEART_ETERNAL},
        {PickupVariant.PICKUP_HEART, HeartSubType.HEART_DOUBLEPACK},
        {PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK},
        {PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLENDED},

        {PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY},
        {PickupVariant.PICKUP_COIN, CoinSubType.COIN_NICKEL},
        {PickupVariant.PICKUP_COIN, CoinSubType.COIN_DIME},
        {PickupVariant.PICKUP_COIN, CoinSubType.COIN_DOUBLEPACK},

        {PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL},
        {PickupVariant.PICKUP_BOMB, BombSubType.BOMB_DOUBLEPACK},
        {PickupVariant.PICKUP_BOMB, BombSubType.BOMB_TROLL},
        {PickupVariant.PICKUP_BOMB, BombSubType.BOMB_SUPERTROLL},

        {PickupVariant.PICKUP_KEY, KeySubType.KEY_NORMAL},
        {PickupVariant.PICKUP_KEY, KeySubType.KEY_GOLDEN},
        {PickupVariant.PICKUP_KEY, KeySubType.KEY_DOUBLEPACK},

        {PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_NORMAL},
        {PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_MEGA},
    }

    local pgd = Isaac.GetPersistentGameData()

    if pgd:Unlocked(Achievement.EVERYTHING_IS_TERRIBLE) then
        table.insert(pickups, {PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF_SOUL})
        table.insert(pickups, {PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_MICRO})
    end
    if pgd:Unlocked(Achievement.GOLDEN_HEARTS) then
        table.insert(pickups, {PickupVariant.PICKUP_HEART, HeartSubType.HEART_GOLDEN})
    end
    if pgd:Unlocked(Achievement.SCARED_HEART) then
        table.insert(pickups, {PickupVariant.PICKUP_HEART, HeartSubType.HEART_SCARED})
    end
    if pgd:Unlocked(Achievement.BONE_HEARTS) then
        table.insert(pickups, {PickupVariant.PICKUP_HEART, HeartSubType.HEART_BONE})
    end
    if pgd:Unlocked(Achievement.ROTTEN_HEARTS) then
        table.insert(pickups, {PickupVariant.PICKUP_HEART, HeartSubType.HEART_ROTTEN})
    end
    if pgd:Unlocked(Achievement.LUCKY_PENNIES) then
        table.insert(pickups, {PickupVariant.PICKUP_COIN, CoinSubType.COIN_LUCKYPENNY})
    end
    if pgd:Unlocked(Achievement.STICKY_NICKELS) then
        table.insert(pickups, {PickupVariant.PICKUP_COIN, CoinSubType.COIN_STICKYNICKEL})
    end
    if pgd:Unlocked(Achievement.GOLDEN_PENNY) then
        table.insert(pickups, {PickupVariant.PICKUP_COIN, CoinSubType.COIN_GOLDEN})
    end
    if pgd:Unlocked(Achievement.ASHPIT) then
        table.insert(pickups, {PickupVariant.PICKUP_BOMB, BombSubType.BOMB_GIGA})
    end
    if pgd:Unlocked(Achievement.GOLDEN_BOMBS) then
        table.insert(pickups, {PickupVariant.PICKUP_BOMB, BombSubType.BOMB_GOLDEN})
        table.insert(pickups, {PickupVariant.PICKUP_BOMB, BombSubType.BOMB_GOLDENTROLL})
    end
    if pgd:Unlocked(Achievement.CHARGED_KEY) then
        table.insert(pickups, {PickupVariant.PICKUP_KEY, KeySubType.KEY_CHARGED})
    end
    if pgd:Unlocked(Achievement.GOLDEN_BATTERY) then
        table.insert(pickups, {PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_GOLDEN})
    end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, PostGameStarted)