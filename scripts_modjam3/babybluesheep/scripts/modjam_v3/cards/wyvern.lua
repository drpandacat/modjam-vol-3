local sfxManager = SFXManager()



ModJamV3.Cards.Wyvern = {}
ModJamV3.Cards.Wyvern.CARD_TYPE = Isaac.GetCardIdByName("Wyvern")
ModJamV3.Cards.Wyvern.STAT_BOOST_COLLECTIBLE_TYPE = Isaac.GetNullItemIdByName("Wyvern Stat Boost")

---@param card Card
---@param player EntityPlayer
---@param useFlags UseFlag
ModJamV3:AddCallback(ModCallbacks.MC_USE_CARD, function (_, card, player, useFlags)

    player:AddNullItemEffect(ModJamV3.Cards.Wyvern.STAT_BOOST_COLLECTIBLE_TYPE, true)

    sfxManager:Play(SoundEffect.SOUND_DOGMA_ANGEL_TRANSFORM_END)

    local poof = Isaac.Spawn
    (
        EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0,
        player.Position, Vector.Zero,
        nil
    )
    poof:GetSprite().Color = Color
    (
        1, 1, 1, 1,
        0.4, 0.4, 0.4,
        1, 1, 1, 1
    )

end, ModJamV3.Cards.Wyvern.CARD_TYPE)