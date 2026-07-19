---@param MOD ModReference
return function (MOD)
    local t = {}

    t.ID = Isaac.GetItemIdByName("Loot Box")
    t.EFFECT = Isaac.GetEntityVariantByName("Skart Loot Box")
    t.XML_EFFECT = XMLData.GetEntityByTypeVarSub(EntityType.ENTITY_EFFECT, t.EFFECT)
    t.FIRST_DROP = 30 * 5
    t.DROP_DELAY = 30 * 15
    t.Queued = 0
    t.MAX_ON_FLOOR = 3
    t.LIFESPAN = 30 * 8
    t.FLASH_DUR = 30 * 2

    ---@param effect EntityEffect
    MOD:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function (_, effect)
        effect.PositionOffset = Vector(0, -32 * 10)
        effect.FallingAcceleration = 1
        effect.FallingSpeed = 0
        effect:Update()
    end, t.EFFECT)

    MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, function ()
        local amt = PlayerManager.GetNumCollectibles(t.ID)
        if amt == 0 then return end
        local room = MOD.GAME:GetRoom()
        if room:IsClear() and not room:IsAmbushActive() then return end
        local delay = math.max(1, t.DROP_DELAY // amt)
        if (room:GetFrameCount() + delay - t.FIRST_DROP) % delay == 0 then
            t.Queued = t.Queued + 1
        end
        if t.Queued > 0 then
            if #Isaac.FindByType(EntityType.ENTITY_EFFECT, t.EFFECT) < t.MAX_ON_FLOOR then
                Isaac.Spawn(
                    EntityType.ENTITY_EFFECT,
                    t.EFFECT,
                    0,
                    room:FindFreePickupSpawnPosition(
                        room:GetRandomPosition(0),
                        40,
                        true,
                        true
                    ),
                    Vector.Zero,
                    nil
                )
                t.Queued = t.Queued - 1
            end
        end
    end)

    MOD:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
        t.Queued = 0
    end)

    ---@param effect EntityEffect
    MOD:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, effect)
        effect.FallingSpeed = effect.FallingSpeed + effect.FallingAcceleration
        effect.PositionOffset = effect.PositionOffset + Vector(0, effect.FallingSpeed)
        if effect.PositionOffset.Y >= 0 then
            if MOD.GAME:GetRoom():GetGridCollisionAtPos(effect.Position) == GridCollisionClass.COLLISION_PIT then
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, effect.Position, Vector.Zero, nil)
                effect:Remove()
                MOD.SFX:Play(286, 0.8)
                return
            end
            if effect.PositionOffset.Y > 1 then
                MOD.SFX:Play(SoundEffect.SOUND_SCAMPER)
            end
            effect.FallingSpeed = effect.FallingSpeed * -0.5
            effect.PositionOffset = Vector(0, 0)
        end
        if effect.PositionOffset.Y > -16 then
            for _, v in ipairs(Isaac.FindInCapsule(effect:GetCollisionCapsule(), EntityPartition.PLAYER)) do
                local player = v:ToPlayer()
                player:UseCard(MOD.CARD_SMASH.ID, UseFlag.USE_NOANNOUNCER)
                effect:Remove()
                break
            end
        end
        effect:SetShadowSize(math.max(0, tonumber(t.XML_EFFECT.shadowsize) * 0.01 + effect.PositionOffset.Y * 0.01 * 0.2))
        local sprite = effect:GetSprite()
        local layer = sprite:GetLayer(0)
        local size = Vector(math.sin(effect.FrameCount * 0.1), 1)
        layer:SetSize(size)
        local brightness = 0.5 + math.abs(size.X) * 0.5
        effect.Color = Color(
            brightness, brightness, brightness,
            effect.State == 0 and MOD:LerpClamped(0, 1, effect.FrameCount / 30) or 0
        )
        effect.SpriteOffset = Vector(-1.5 * size.X, 0)
        layer:SetCropOffset(Vector(size.X < 0 and 0 or 32 * 3, 0))
        if effect.FrameCount > t.LIFESPAN - t.FLASH_DUR then
            if effect.FrameCount % (effect.FrameCount > t.LIFESPAN - t.FLASH_DUR / 4 and 2 or 4) == 0 then
                effect.State = effect.State == 0 and 1 or 0
            end
            if effect.FrameCount > t.LIFESPAN and effect.State == 0 then
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, effect.Position, Vector.Zero, nil)
                effect:Remove()
            end
        end
    end, t.EFFECT)

    -- ---@param effect EntityEffect
    -- MOD:AddCallback(ModCallbacks.MC_PRE_EFFECT_RENDER, function (_, effect)
    --     effect:GetSprite():Render(Isaac.WorldToScreen(effect.Position) + Vector(-1, 0))
    -- end, t.EFFECT)

    return t
end