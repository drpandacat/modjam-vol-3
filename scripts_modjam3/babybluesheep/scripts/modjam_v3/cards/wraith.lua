local sfxManager = SFXManager()



ModJamV3.Cards.Wraith = {}
ModJamV3.Cards.Wraith.CARD_TYPE = Isaac.GetCardIdByName("Wraith")
ModJamV3.Cards.Wraith.FLIGHT_COLLECTIBLE_TYPE = Isaac.GetNullItemIdByName("Wraith Flight")

---@param player EntityPlayer
local function GetPlayerDeathSound(player)
	local playerType = player:GetPlayerType()
	local playerData = XMLData.GetEntryById(XMLNode.PLAYER, playerType)

	local defaultDeathSound = SoundEffect.SOUND_ISAACDIES

	if playerData.deathsound == nil then
		return defaultDeathSound
    end

	local deathSoundNumber = tonumber(playerData.deathsound)
    if deathSoundNumber ~= nil then
        return deathSoundNumber
    end
    return Isaac.GetSoundIdByName(playerData.deathsound)
end

---@param card Card
---@param player EntityPlayer
---@param useFlags UseFlag
ModJamV3:AddCallback(ModCallbacks.MC_USE_CARD, function (_, card, player, useFlags)

    local fakePlayer = Isaac.Spawn
    (
        EntityType.ENTITY_EFFECT, EffectVariant.DEVIL, 0,
        player.Position, Vector.Zero,
        nil
    )

    fakePlayer:Update()
    fakePlayer.Position = player.Position

    fakePlayer:GetSprite():Load(player:GetSprite():GetFilename(), true)
    fakePlayer:GetSprite():ReplaceSpritesheet(12, EntityConfig.GetPlayer(player:GetPlayerType()):GetSkinPath(), true)
    fakePlayer:GetSprite():GetLayer("ghost"):SetVisible(false)
    fakePlayer:GetSprite():Play("Death", true)

    sfxManager:Play(GetPlayerDeathSound(player))

    for i = 1, 2 do
        local poof = Isaac.Spawn
        (
            EntityType.ENTITY_EFFECT, EffectVariant.POOF02, i,
            player.Position, Vector.Zero,
            nil
        )

        local sprite = poof:GetSprite()
        sprite.Color = Color
        (
            0.5, 0.5, 0.5, 1,
            0, 0, 0,
            1, 1, 1, 1
        )
        sprite.PlaybackSpeed = 0.75
    end

    sfxManager:Play(SoundEffect.SOUND_BLACK_POOF)

    player:AddInnateCollectible(CollectibleType.COLLECTIBLE_SHADE, 2, "WraithTemporaryItems", 0, true)
    player:AddInnateCollectible(CollectibleType.COLLECTIBLE_SPIRIT_OF_THE_NIGHT, 1, "WraithTemporaryItems", 0, true)
    player:AddBlackHearts(1)

    player:AddNullItemEffect(ModJamV3.Cards.Wraith.FLIGHT_COLLECTIBLE_TYPE, true)

end, ModJamV3.Cards.Wraith.CARD_TYPE)

---@param player EntityPlayer
---@param cacheFlags CacheFlag
ModJamV3:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, function (_, player, cacheFlags)

    if not player:GetEffects():HasNullEffect(ModJamV3.Cards.Wraith.FLIGHT_COLLECTIBLE_TYPE) then return end

    --if cacheFlags & CacheFlag.CACHE_FLYING == CacheFlag.CACHE_FLYING then
        --player.CanFly = true
    --end
    if cacheFlags & CacheFlag.CACHE_COLOR == CacheFlag.CACHE_COLOR then
        player.Color = Color
        (
            1, 1, 1, 1,--0.5, 0.5, 0.5, 1,
            0, 0, 0,
            1, 1, 1, 1
        )
    end

end)

ModJamV3:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function (_)

    for _, player in ipairs(PlayerManager.GetPlayers()) do
        player:ClearInnateItemGroup("WraithTemporaryItems")
    end

end)
