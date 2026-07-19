local mod = HODGEPODGE

--Reimplementing subtype selection to make OLD_DATA not overwrite the coins.
--Mostly a 1:1 copy of vanilla decompilation provided by Guantol.
--https://github.com/Guantol-Lemat/Isaac.LuaDecomps/blob/cb49e67241e897286df908887ede38edf9bb12ff/_Legacy/Entity/Pickup/Initializer.lua#L321
---@param rng RNG
---@return CoinSubType coinType
local function get_random_coin_sub_type(rng)
    local pgd = Isaac.GetPersistentGameData()
    local coinType = CoinSubType.COIN_PENNY

    if rng:RandomInt(20) == 0 then
        coinType = CoinSubType.COIN_NICKEL
    elseif rng:RandomInt(100) == 0 and pgd:Unlocked(Achievement.STICKY_NICKELS) then
        coinType = CoinSubType.COIN_STICKYNICKEL
    end

    if rng:RandomInt(100) == 0 then
        coinType = CoinSubType.COIN_DIME
    elseif rng:RandomInt(100) == 0 and pgd:Unlocked(Achievement.LUCKY_PENNIES) then
        coinType = CoinSubType.COIN_LUCKYPENNY
    end

    if rng:RandomInt(200) == 0 and pgd:Unlocked(Achievement.GOLDEN_PENNY) then
        coinType = CoinSubType.COIN_GOLDEN
    end

    return coinType
end

---@param player EntityPlayer
return function (player)
    local rng = player:GetCardRNG(mod.Card.SD_CARD)
    local coinCount = rng:RandomInt(3,8)
    for i = 1, coinCount do
        local pos = Isaac.GetFreeNearPosition(player.Position, 20)
        Isaac.Spawn(
            EntityType.ENTITY_PICKUP,
            PickupVariant.PICKUP_COIN,
            get_random_coin_sub_type(rng),
            pos,
            Vector.Zero,
            nil
        )
    end
end