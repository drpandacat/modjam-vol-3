local sfxManager = SFXManager()



ModJamV3.Cards.Megashark = {}
ModJamV3.Cards.Megashark.CARD_TYPE = Isaac.GetCardIdByName("Megashark")
ModJamV3.Cards.Megashark.STAT_BOOST_COLLECTIBLE_TYPE = Isaac.GetNullItemIdByName("Megashark Stat Boost")

ModJamV3.Cards.Megashark.GUN_RELOAD_SOUND_EFFECT = Isaac.GetSoundIdByName("ModJamV3 Gun Reloading")

---@param card Card
---@param player EntityPlayer
---@param useFlags UseFlag
ModJamV3:AddCallback(ModCallbacks.MC_USE_CARD, function (_, card, player, useFlags)

    player:AddNullItemEffect(ModJamV3.Cards.Megashark.STAT_BOOST_COLLECTIBLE_TYPE, true)

    local amountOfTearsToGive = 60

    local weapon = player:GetWeapon(1)
    if weapon ~= nil then

        if weapon:GetWeaponType() == WeaponType.WEAPON_KNIFE then
            amountOfTearsToGive = 10
        end

        if weapon:GetWeaponType() == WeaponType.WEAPON_BOMBS then
            amountOfTearsToGive = 15
        end

        if weapon:GetWeaponType() == WeaponType.WEAPON_SPIRIT_SWORD then
            amountOfTearsToGive = 20
        end
        if weapon:GetWeaponType() == WeaponType.WEAPON_FETUS then
            amountOfTearsToGive = 20
        end

    end

    player:GetEffects():GetNullEffect(ModJamV3.Cards.Megashark.STAT_BOOST_COLLECTIBLE_TYPE).Count = amountOfTearsToGive

    sfxManager:Play(ModJamV3.Cards.Megashark.GUN_RELOAD_SOUND_EFFECT)

end, ModJamV3.Cards.Megashark.CARD_TYPE)

---@param fireDirection Vector
---@param fireAmount integer
---@param owner Entity
---@param weapon Weapon
ModJamV3:AddCallback(ModCallbacks.MC_POST_TRIGGER_WEAPON_FIRED , function (_, fireDirection, fireAmount, owner, weapon)
    local player = owner:ToPlayer()
    if player == nil then return end

    local effects = player:GetEffects()

    local hasStatBoost = effects:HasNullEffect(ModJamV3.Cards.Megashark.STAT_BOOST_COLLECTIBLE_TYPE)
    if not hasStatBoost then return end

    effects:RemoveNullEffect(ModJamV3.Cards.Megashark.STAT_BOOST_COLLECTIBLE_TYPE)
end)