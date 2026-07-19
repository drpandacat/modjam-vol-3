---@param MOD ModReference
return function (MOD)
    local t = {}

    t.ID = Isaac.GetCardIdByName("Blue Asbestos Card")
    t.BACKDROP = Isaac.GetBackdropIdByName("Blue Asbestos Halls")
    -- t.GIANTBOOK = Isaac.GetGiantBookIdByName("Blue Asbestos Card")
    t.SPRITE = Sprite("gfx/status_rot.anm2", true)
    t.SPRITE:Play("Rot", true)
    t.SPRITE.Offset = Vector(0, 12)
    t.STATUS = StatusEffectLibrary.RegisterStatusEffect(
        "KBEIRDKDEYL_ROT",
        t.SPRITE
    )
    t.MIST_SPAWN_FREQ = 30 * 4
    t.COLOR_MIST = Color(1, 1, 2, 1.5)
    t.COLOR_MIST_TRANSPARENT = Color(1, 1, 2, 0)
    t.COLORMOD = ColorModifier(
        0.9, 0.9, 1.5,
        0.5,
        -0.025,
        1
    )
    t.COLOR_ASBESTOS = Color(
        0.9, 0.9, 1.5,
        1,
        0, 0, 0,
        0.9, 0.9, 1.5,
        1
    )
    t.MIST_FADEIN = 0.01
    t.MIST_FADEOUT = 0.01
    t.MIST_VEL = Vector(0.5, 0)
    t.MIST_DUR_MIN = 30 * 3
    t.MIST_DUR_MAX = 30 * 8
    t.MIST_DEPTH = 40 * 5
    t.ROT_SLOW_MAX = 0.25
    t.ROT_SLOW_SPEED = 30 * 5
    t.ROT_HURT_FREQ = 12
    t.ROT_HURT_AMT = 2.478

    function t:Asbestify()
        MOD:SetBackdrop(t.BACKDROP)
        MOD.GAME:SetColorModifier(t.COLORMOD)
    end

    ---@param id Card
    ---@param player EntityPlayer
    ---@param flags UseFlag
    MOD:AddCallback(ModCallbacks.MC_USE_CARD, function (_, id, player, flags)
        t:Asbestify()
        local save = EntitySaveStateManager.GetEntityData(MOD, MOD:GetGlobalPlayer())
        save.AsbestosRooms = save.AsbestosRooms or {}
        save.AsbestosRooms[MOD.LEVEL:GetCurrentRoomDesc().ListIndex] = true
        MOD.GAME:ShakeScreen(20)
        MOD.GAME:SetBloom(20, 0.5)
        if Isaac.CountEnemies() > 0 then
            MOD.SFX:Play(SoundEffect.SOUND_POISON_WARN)
        end
    end, t.ID)

    MOD:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
        local save = EntitySaveStateManager.GetEntityData(MOD, MOD:GetGlobalPlayer())
        if not save.AsbestosRooms or not save.AsbestosRooms[MOD.LEVEL:GetCurrentRoomDesc().ListIndex] then return end
        t:Asbestify()
    end)

    MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, function ()
        local room = MOD.GAME:GetRoom()
        if room:GetBackdropType() == t.BACKDROP then
            local mult = room:GetGridSize() / MOD.DEFAULT_GRID_SIZE
            if room:GetFrameCount() % math.ceil(t.MIST_SPAWN_FREQ / mult) == 0 then
                local mist = Isaac.Spawn(
                    EntityType.ENTITY_EFFECT,
                    EffectVariant.MIST,
                    0,
                    Isaac.GetRandomPosition(),
                    t.MIST_VEL,
                    nil
                ):ToEffect()
                local rng = RNG(mist.InitSeed)
                local sprite = mist:GetSprite()
                sprite:Stop()
                sprite:SetFrame(rng:RandomInt(0, sprite:GetCurrentAnimationData():GetLength()))
                MOD:GetData(mist).AsbestosMist = true
                mist.Timeout = rng:RandomInt(t.MIST_DUR_MIN, t.MIST_DUR_MAX)
                mist.Color = t.COLOR_MIST_TRANSPARENT
                mist.DepthOffset = t.MIST_DEPTH
            end
            for _, v in ipairs(Isaac.GetRoomEntities()) do
                if v:IsVulnerableEnemy()
                and not v:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
                and not StatusEffectLibrary:HasStatusEffect(v, StatusEffectLibrary.StatusFlag.KBEIRDKDEYL_ROT) then
                    StatusEffectLibrary:AddStatusEffect(v, StatusEffectLibrary.StatusFlag.KBEIRDKDEYL_ROT, -1, EntityRef(nil))
                end
            end
        end
    end)

    ---@param effect EntityEffect
    MOD:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, effect)
        if not MOD:GetData(effect).AsbestosMist then return end

        if effect.Timeout > 0 then
            effect.Color = Color.Lerp(effect.Color, t.COLOR_MIST, t.MIST_FADEIN)
        else
            local color = effect.Color
            color.A = color.A - t.MIST_FADEOUT
            if color.A <= 0 then
                effect:Remove()
                return
            end
            effect.Color = color
        end
    end, EffectVariant.MIST)

    MOD:AddCallback(ModCallbacks.MC_PRE_LEVEL_INIT, function ()
        local save = EntitySaveStateManager.GetEntityData(MOD, MOD:GetGlobalPlayer())
        save.AsbestosRooms = nil
    end)

    ---@param entity Entity
    ---@param status integer
    StatusEffectLibrary.Callbacks.AddCallback(StatusEffectLibrary.Callbacks.ID.ENTITY_STATUS_EFFECT_UPDATE, function (_, entity, status)
        local data = MOD:GetData(entity)
        data.RotIntensity = (data.RotIntensity or 0) + 1
        local progress = math.min(1, math.max(0, data.RotIntensity / t.ROT_SLOW_SPEED))
        local speed = MOD:Lerp(
            1,
            t.ROT_SLOW_MAX,
            progress
        )
        speed = math.min(speed, entity:GetSpeedMultiplier())
        if not entity:IsBoss() then
            entity:SetSpeedMultiplier(speed)
        end
        entity:SetColor(Color.Lerp(
            entity.Color,
            t.COLOR_ASBESTOS,
            MOD:Lerp(0, 1, progress)
        ), 2, 99, false, true)
        if progress == 1 and MOD.GAME:GetFrameCount() % t.ROT_HURT_FREQ == 0 then
            entity:TakeDamage(t.ROT_HURT_AMT, DamageFlag.DAMAGE_POISON_BURN, EntityRef(nil), 0)
            if entity:HasMortalDamage() then
                entity.SplatColor = t.COLOR_ASBESTOS
                MOD.SFX:Play(SoundEffect.SOUND_POISON_HURT)
            end
        end
    end, StatusEffectLibrary.StatusFlag.KBEIRDKDEYL_ROT)

    --#region Secrets

    t.Cheater = nil
    t.HINT = "Aren't you forgetting something?"

    ---@param pickup EntityPickup
    MOD:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function (_, pickup)
        if not (
            (
                pickup.Variant == PickupVariant.PICKUP_TRINKET
                and (
                    pickup.SubType == MOD.TRINKET_NEGATE_RAINBOW_CONWORM.ID
                    or pickup.SubType == MOD.TRINKET_NEGATE_RAINBOW_CONWORM.ID | TrinketType.TRINKET_GOLDEN_FLAG
                )
            ) or (
                pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE
                and pickup.SubType == MOD.COLLECTIBLE_NEGATE_RAINBOW_CONTAGION.ID
            )
        ---@diagnostic disable-next-line: undefined-field
        ) or not ImGui.IsVisible() then return end
        t.Cheater = 0
        pickup:Remove()
    end)

    MOD:AddCallback(ModCallbacks.MC_POST_RENDER, function ()
        if not t.Cheater then return end
        t.Cheater = t.Cheater - 1
        if t.Cheater > 0 then return end
        Console.PopHistory(1)
        print("")
        Console.PrintError("Error spawning entity.")
        Console.PrintWarning(t.HINT)
        t.Cheater = nil
    end)

    MOD:AddPriorityCallback(ModCallbacks.MC_PRE_ADD_COLLECTIBLE, CallbackPriority.IMPORTANT, function ()
        ---@diagnostic disable-next-line: undefined-field
        if not ImGui.IsVisible() then return end
        Console.PrintError("Error giving item.")
        Console.PrintWarning(t.HINT)
        return false
    end, MOD.COLLECTIBLE_NEGATE_RAINBOW_CONTAGION.ID)

    ---@param id TrinketType
    MOD:AddPriorityCallback(ModCallbacks.MC_PRE_ADD_TRINKET, CallbackPriority.IMPORTANT, function (_, _, id)
        if (
            id ~= MOD.TRINKET_NEGATE_RAINBOW_CONWORM.ID
            and id ~= MOD.TRINKET_NEGATE_RAINBOW_CONWORM.ID | TrinketType.TRINKET_GOLDEN_FLAG
        ---@diagnostic disable-next-line: undefined-field
        ) or not ImGui.IsVisible() then return end
        Console.PrintError("Error giving trinket.")
        Console.PrintWarning(t.HINT)
        return false
    end)
    --#endregion

    return t
end