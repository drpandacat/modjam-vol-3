local game = Game()
local sfxManager = SFXManager()



ModJamV3.Cards.Werewolf = {}
ModJamV3.Cards.Werewolf.CARD_TYPE = Isaac.GetCardIdByName("Werewolf")
ModJamV3.Cards.Werewolf.STAT_BOOST_COLLECTIBLE_TYPE = Isaac.GetNullItemIdByName("Werewolf Stat Boost")

---@param card Card
---@param player EntityPlayer
---@param useFlags UseFlag
ModJamV3:AddCallback(ModCallbacks.MC_USE_CARD, function (_, card, player, useFlags)

    local effects = player:GetEffects()

    effects:RemoveNullEffect(ModJamV3.Cards.Werewolf.STAT_BOOST_COLLECTIBLE_TYPE, -1)
    effects:AddNullEffect(ModJamV3.Cards.Werewolf.STAT_BOOST_COLLECTIBLE_TYPE, true, 1)

    local playerRef = EntityRef(player)

    sfxManager:Play(SoundEffect.SOUND_ISAAC_ROAR)

    game:MakeShockwave(player.Position, 0.05, 0.02, 10)

    for _, entity in ipairs(Isaac.FindInRadius(player.Position, 120, EntityPartition.ENEMY)) do
        local npc = entity:ToNPC()
        if npc == nil then goto continuePush end

        if not (npc:IsVulnerableEnemy() and npc:IsEnemy()) then goto continuePush end

        local distance = entity.Position:Distance(player.Position)
        local pushAmount = ModJamV3.InverseLerp(160, 40, distance)

        npc:AddKnockback(playerRef, (entity.Position - player.Position):Normalized() * pushAmount * 15, 60, true)

        ::continuePush::
    end

    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        local npc = entity:ToNPC()
        if npc == nil then goto continueFear end
        
        if not (npc:IsVulnerableEnemy() and npc:IsEnemy()) then goto continueFear end
        
        npc:AddFear(playerRef, 30 * 4)

        ::continueFear::
    end

    for i = 0, 2 do
        Isaac.CreateTimer(function ()

            ---@type EntityEffect
            ---@diagnostic disable-next-line: assign-type-mismatch
            local shockwaveRing = Isaac.Spawn
            (
                EntityType.ENTITY_EFFECT, EffectVariant.BIG_ATTRACT, 10,
                player.Position, Vector.Zero,
                player
            ):ToEffect()

            shockwaveRing:SetTimeout(8)
            shockwaveRing:FollowParent(player)

            shockwaveRing.MinRadius = 10
            shockwaveRing.MaxRadius = 40

            shockwaveRing:Update()

        end, i * 2, 1, false)
    end

    for i = 0, 6 do
        Isaac.CreateTimer(function ()

            ---@type EntityEffect
            ---@diagnostic disable-next-line: assign-type-mismatch
            local shockwaveLine = Isaac.Spawn
            (
                EntityType.ENTITY_EFFECT, EffectVariant.BIG_ATTRACT, 11,
                player.Position, Vector.Zero,
                player
            ):ToEffect()

            shockwaveLine:SetTimeout(6)
            shockwaveLine:FollowParent(player)

            shockwaveLine.MinRadius = 10
            shockwaveLine.MaxRadius = 40

            shockwaveLine:Update()
            
        end, i, 1, false)
    end

end, ModJamV3.Cards.Werewolf.CARD_TYPE)

---@param entity Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
---@param extraSource EntityRef?
ModJamV3:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function (_, entity, amount, flags, source, countdown, extraSource)

    local player = entity:ToPlayer()
    if not player then return end

    if not player:GetEffects():HasNullEffect(ModJamV3.Cards.Werewolf.STAT_BOOST_COLLECTIBLE_TYPE) then return end

    return {
        Damage = amount * 2
    }

end)

---@param entity Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
---@param extraSource EntityRef?
ModJamV3:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, function (_, entity, amount, flags, source, countdown, extraSource)

    local player = entity:ToPlayer()
    if not player then return end

    if not player:GetEffects():HasNullEffect(ModJamV3.Cards.Werewolf.STAT_BOOST_COLLECTIBLE_TYPE) then return end

    entity:TakeDamage(amount * 30, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(player), 0)

end)

--[[

---@param entity Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
---@param extraSource EntityRef?
ModJamV3:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, function (_, entity, amount, flags, source, countdown, extraSource)

    if source.Entity == nil then return end
    local sourceEntity = source.Entity
    if sourceEntity:ToNPC() == nil then return end
    if not sourceEntity:IsVulnerableEnemy() then return end

    local player = entity:ToPlayer()
    if not player then return end

    if not player:GetEffects():HasNullEffect(ModJamV3.Cards.Werewolf.STAT_BOOST_COLLECTIBLE_TYPE) then return end

    sourceEntity:TakeDamage(amount * 8, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(player), 0)
    sourceEntity:AddBleeding(EntityRef(player), 30)

    if sourceEntity:HasMortalDamage() then
        sourceEntity:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
    end

end)

]]