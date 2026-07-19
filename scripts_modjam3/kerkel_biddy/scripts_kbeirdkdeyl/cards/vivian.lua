---@param MOD ModReference
return function (MOD)
    local t = {}

    t.ID = Isaac.GetCardIdByName("Vivian Card")
    t.FAMILIAR_COCONUT = Isaac.GetEntityVariantByName("Vivian Coconut")
    t.FAMILIAR_GUY = Isaac.GetEntityVariantByName("Vivian Guy")
    t.FAMILIAR_CLOUD = Isaac.GetEntityVariantByName("Vivian Cloud")
    t.EFFECT_BOX = Isaac.GetEntityVariantByName("Vivian Box")
    t.NULL_COCONUT = Isaac.GetNullItemIdByName("Vivian Coconut")
    t.NULL_GUY = Isaac.GetNullItemIdByName("Vivian Guy")
    t.NULL_CLOUD = Isaac.GetNullItemIdByName("Vivian Cloud")
    t.EFFECT_TARGET = Isaac.GetEntityVariantByName("Vivian Box Target")
    t.MUSIC_CLOUD = Isaac.GetMusicIdByName("Vivian Clark Title")
    ---@type NullItemID[]
    t.NULLS = {
        t.NULL_COCONUT,
        t.NULL_CLOUD,
        t.NULL_GUY,
    }
    ---@type table<NullItemID, FamiliarVariant>
    t.NULL_TO_FAMILIAR = {
        [t.NULL_COCONUT] = t.FAMILIAR_COCONUT,
        [t.NULL_CLOUD] = t.FAMILIAR_CLOUD,
        [t.NULL_GUY] = t.FAMILIAR_GUY,
    }

    ---@param player EntityPlayer
    MOD:AddCallback(ModCallbacks.MC_USE_CARD, function (_, _, player)
        local rng = player:GetCardRNG(t.ID)
        player:GetEffects():AddNullEffect(t.NULLS[rng:RandomInt(1, #t.NULLS)])
        MOD.MUSIC:PlayJingle(t.MUSIC_CLOUD, 60 * 35) -- how tf do you stop this
    end, t.ID)

    ---@param player EntityPlayer
    MOD:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function (_, player)
        local fx = player:GetEffects()
        local rng = player:GetCardRNG(t.ID)
        for k, v in pairs(t.NULL_TO_FAMILIAR) do
            player:CheckFamiliar(v, fx:GetNullEffectNum(k), rng)
            rng:Next()
        end
    end, CacheFlag.CACHE_FAMILIARS)

    ---@param player EntityPlayer
    MOD:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, function (_, player)
        local fx = player:GetEffects()
        for _, v in ipairs(t.NULLS) do
            fx:RemoveNullEffect(v, -1)
        end
    end)

    t.COCONUT_SPEED = 1
    t.COCONUT_DAMAGE_AMT = 2.5
    t.COCONUT_STUN_CHANCE = 0.03
    t.COCONUT_DAMAGE_FREQ = 12
    t.COCONUT_STUN_DUR = 30 * 4

    ---@param familiar EntityFamiliar
    MOD:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function (_, familiar)
        local sprite = familiar:GetSprite()
        local speed = familiar.Velocity:Length() / 6 / t.COCONUT_SPEED
        if speed < 0.2 then
            if sprite:GetAnimation() ~= "WalkDown" then
                sprite:Play("WalkDown", true)
            end
            sprite:SetFrame(16)
            familiar.FlipX = false
        else
            local dir = MOD:VectorToDirection(familiar.Velocity)
            -- if dir ~= familiar.LastDirection then
                if dir == Direction.LEFT then
                    sprite:SetAnimation("WalkSide", false)
                    familiar.FlipX = true
                elseif dir == Direction.RIGHT then
                    sprite:SetAnimation("WalkSide", false)
                    familiar.FlipX = false
                elseif dir == Direction.UP then
                    sprite:SetAnimation("WalkUp", false)
                    familiar.FlipX = false
                else
                    sprite:SetAnimation("WalkDown", false)
                    familiar.FlipX = false
                end
            -- end
            -- familiar.LastDirection = dir
        end

        sprite.PlaybackSpeed = speed
        local pf = familiar:GetPathFinder()
        familiar:PickEnemyTarget(40 * 10)
        familiar.Target = familiar.Target or familiar.Player
        familiar.TargetPosition = familiar.Target and familiar.Target.Position or familiar.TargetPosition

        if (familiar.Target and familiar.Target.Type ~= EntityType.ENTITY_PLAYER)
        or familiar.Position:Distance(familiar.TargetPosition) > 40 then
            pf:FindGridPath(familiar.TargetPosition, t.COCONUT_SPEED, 0, true)
        else
            familiar.Velocity = familiar.Velocity * 0.5
        end

        familiar.SpriteOffset = Vector(0, 2)
        familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND

        local dmg = t.COCONUT_DAMAGE_AMT * familiar:GetMultiplier()
        local stun = familiar:GetDropRNG():RandomFloat() < t.COCONUT_STUN_CHANCE

        for _, v in ipairs(Isaac.FindInCapsule(familiar:GetCollisionCapsule(), EntityPartition.ENEMY)) do
            if v:TakeDamage(dmg, DamageFlag.DAMAGE_COUNTDOWN, EntityRef(familiar), t.COCONUT_DAMAGE_FREQ)
            and stun then
                v:AddFreeze(EntityRef(familiar), t.COCONUT_STUN_DUR)
            end
        end

        for _, v in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, t.FAMILIAR_COCONUT)) do
            if v.Position:Distance(familiar.Position) < 20 then
                familiar.Velocity = familiar.Velocity + (familiar.Position - v.Position) / 20
                v.Velocity = v.Velocity + (v.Position - familiar.Position) / 20
            end
        end
    end, t.FAMILIAR_COCONUT)

    ---@param familiar EntityFamiliar
    MOD:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function (_, familiar)
        familiar:AddToFollowers()
    end, t.FAMILIAR_GUY)

    t.GUY_COLOR_A = Color(0, 0.7, 1)
    t.GUY_FADE_A = 0.3
    t.GUY_COLOR_B = Color(0, 0.7, 1, 0)
    t.GUY_FADE_B = 0.3
    t.GUY_MAX_CHARGE = 30 * 1 // 1
    t.GUY_OFFSET_SPEED = 1

    ---@param familiar EntityFamiliar
    MOD:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function (_, familiar)
        familiar:FollowParent()
        familiar:Shoot()
        ---@type {
        ---GuyCharge: integer,
        ---GuyTargets: table<integer, EntityPtr>,
        ---GuyIndex: integer,
        ---GuyCharge: number,
        ---GuyChargeBar: Sprite,
        ---Charged: boolean,
        ---}
        local data = MOD:GetData(familiar)
        if not data.GuyChargeBar then
            data.GuyChargeBar = Sprite("gfx/chargebar.anm2", true)
        end
        data.GuyCharge = data.GuyCharge or 0
        local aim = familiar.Player:GetAimDirection()
        local room = MOD.GAME:GetRoom()
        if aim:Length() > 0.1 then
            -- familiar.TargetPosition = familiar.TargetPosition + aim:Resized(5)
            data.GuyCharge = data.GuyCharge + 1
        else
            if data.GuyCharge >= t.GUY_MAX_CHARGE then
                data.GuyCharge = t.GUY_MAX_CHARGE
                if room:GetGridCollisionAtPos(familiar.TargetPosition) == GridCollisionClass.COLLISION_NONE
                and room:GetGridPathFromPos(familiar.TargetPosition) < 900 then
                    local grid = room:GetGridEntityFromPos(familiar.TargetPosition)
                    if grid then
                        room:RemoveGridEntityImmediate(room:GetGridIndex(familiar.TargetPosition), 0, false)
                    end
                    -- MOD.SFX:Play(SoundEffect.SOUND_ROCKET_LAUNCH_SHORT, 0.5, nil, nil, 1.4)
                    -- MOD.SFX:Play(286, 0.8)
                    -- MOD.SFX:Play(SoundEffect., nil, nil, nil, 2)
                    Isaac.Spawn(
                        EntityType.ENTITY_EFFECT,
                        EffectVariant.POOF01,
                        0,
                        familiar.TargetPosition,
                        Vector.Zero,
                        nil
                    )
                    Isaac.Spawn(
                        EntityType.ENTITY_EFFECT,
                        t.EFFECT_BOX,
                        0,
                        familiar.TargetPosition,
                        Vector.Zero,
                        familiar.Player
                    )
                    data.GuyCharge = 0
                end
            else
                data.GuyCharge = 0
            end
            -- familiar.TargetPosition = familiar.Position
        end
        -- familiar.TargetPosition = familiar.Position
        -- + Vector.FromAngle(
        --     MOD:LerpAngle(
        --         (familiar.TargetPosition - familiar.Position):GetAngleDegrees(),
        --         aim:GetAngleDegrees(),
        --         0.3
        --     )
        -- ):Resized(math.max(0, (data.GuyCharge - t.GUY_MAX_CHARGE) * t.GUY_OFFSET_SPEED))

        -- familiar.TargetPosition = room:GetClampedPosition(familiar.TargetPosition, 20)
        local targetIndex = room:GetGridIndex(familiar.TargetPosition)
        data.GuyTargets = data.GuyTargets or {}
        if data.GuyCharge >= t.GUY_MAX_CHARGE then
            if not data.Charged then
                -- MOD.SFX:Play(MOD.CURSE_CHARLIE.SOUND_PRIME, 0.9, nil, nil, 1.3)
            end
            if (data.GuyCharge - t.GUY_MAX_CHARGE) % 12 == 0 then
                if data.Charged then
                    -- MOD.SFX:Play(SoundEffect.SOUND_BEEP, 0.5, nil, nil, 1.33)
                end
                familiar.TargetPosition = room:GetGridPosition(room:GetGridIndex(room:GetClampedPosition(familiar.TargetPosition + aim:Resized(40), 10)))
            end
            data.Charged = true
            local ptr = data.GuyTargets[targetIndex]
            if not ptr
            or not ptr.Ref
            or not ptr.Ref:Exists() then
                local effect = Isaac.Spawn(
                    EntityType.ENTITY_EFFECT,
                    t.EFFECT_TARGET,
                    0,
                    room:GetGridPosition(targetIndex),
                    Vector.Zero,
                    nil
                )
                effect.Color = t.GUY_COLOR_B
                ptr = EntityPtr(effect)
                data.GuyTargets[targetIndex] = ptr
            end
            -- if ptr and ptr.Ref and ptr.Ref:Exists() then
            -- end
        else
            data.Charged = nil
            familiar.TargetPosition = room:GetGridPosition(room:GetGridIndex(familiar.Position))
        end
        for k, v in pairs(data.GuyTargets) do
            local effect = v.Ref and v.Ref:Exists() and v.Ref
            if effect then
                if k == targetIndex and data.GuyCharge >= t.GUY_MAX_CHARGE then
                    effect.Color = Color.Lerp(effect.Color, t.GUY_COLOR_A, t.GUY_FADE_A)
                else
                    effect.Color = Color.Lerp(effect.Color, t.GUY_COLOR_B, t.GUY_FADE_B)
                    if effect.Color.A < 0.01 then
                        effect:Remove()
                        data.GuyTargets[k] = nil
                    end
                end
            end
        end

        data.GuyIndex = targetIndex
    end, t.FAMILIAR_GUY)

    ---@param familiar EntityFamiliar
    MOD:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, function (_, familiar)
        local data = MOD:GetData(familiar)
        if not data.GuyChargeBar or not data.GuyCharge then return end
        local pos = Isaac.WorldToScreen(familiar.Position)
        HudHelper.RenderChargeBar(
            data.GuyChargeBar,
            data.GuyCharge,
            t.GUY_MAX_CHARGE,
            pos + Vector(12, -35)
        )
    end, t.FAMILIAR_GUY)

    ---@param familiar EntityFamiliar
    MOD:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_RENDER, function (_, familiar)
        local data = MOD:GetData(familiar)
        if not data.GuyChargeBar or not data.GuyCharge then return end
        local pos = Isaac.WorldToScreen(familiar.Position)
        if data.GuyTargets then
            local sprite = familiar:GetSprite()
            local frame = sprite:GetCurrentAnimationData():GetLayer(0):GetFrame(sprite:GetFrame())
            pos = pos + frame:GetPos() + Vector(0, -8)
            for k, v in pairs(data.GuyTargets) do
                local effect = v.Ref
                if effect then
                    local color = KColor(effect.Color.R, effect.Color.G, effect.Color.B, effect.Color.A)
                    local color2 = KColor(effect.Color.R, effect.Color.G, effect.Color.B, 0)
                    Isaac.DrawLine(
                        pos,
                        Isaac.WorldToScreen(effect.Position),
                        color2,
                        color,
                        3
                    )
                end
            end
        end
    end, t.FAMILIAR_GUY)

    ---@param familiar EntityFamiliar
    MOD:AddCallback(ModCallbacks.MC_GET_FOLLOWER_PRIORITY, function (_, familiar)
        return FollowerPriority.SHOOTER
    end, t.FAMILIAR_GUY)

    t.GUY_BOX_DURATION = 30 * 15

    ---@param effect Entity
    function t:DestoryBox(effect)
        Isaac.Spawn(
            EntityType.ENTITY_EFFECT,
            EffectVariant.POOF01,
            0,
            effect.Position,
            Vector.Zero,
            nil
        )
        MOD.GAME:SpawnParticles(
            effect.Position,
            EffectVariant.TOOTH_PARTICLE,
            6,
            4
        )
        effect:Remove()
        MOD.SFX:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 0.7)
    end

    ---@param player EntityPlayer
    MOD:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function (_, player)
        if Input.IsActionTriggered(ButtonAction.ACTION_DROP, player.ControllerIndex) then
            local hash
            local boxes = Isaac.FindByType(EntityType.ENTITY_EFFECT, t.EFFECT_BOX)
            if #boxes == 0 then return end
            boxes = MOD:Filter(boxes, function (v)
                hash = hash or GetPtrHash(player)
                return v.SpawnerEntity and GetPtrHash(v.SpawnerEntity) == hash
            end)
            if #boxes == 0 then return end
            table.sort(boxes, function (a, b)
                return a.Position:DistanceSquared(player.Position) < b.Position:DistanceSquared(player.Position)
            end)
            t:DestoryBox(boxes[1])
        end
    end)

    ---@param effect EntityEffect
    MOD:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function (_, effect)
        local sprite = effect:GetSprite()
        sprite:Play("Spawn", true)
        sprite.PlaybackSpeed = 0.5
        MOD.SFX:Play(SoundEffect.SOUND_STONE_IMPACT, 0.7)
        MOD.SFX:Play(SoundEffect.SOUND_1UP, 0.7, nil, nil, 1.2)
    end, t.EFFECT_BOX)

    ---@param effect EntityEffect
    MOD:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, effect)
        local room = MOD.GAME:GetRoom()
        local idx = room:GetGridIndex(effect.Position)
        room:SetGridPath(idx, 3999)
        for _, v in ipairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE)) do
            if room:GetGridIndex(v.Position) == idx
            and v.GridCollisionClass > EntityGridCollisionClass.GRIDCOLL_WALLS
            and v:ToProjectile().Height > -30 then
                v:Die()
            end
        end
        for _, v in ipairs(Isaac.FindByType(EntityType.ENTITY_TEAR)) do
            if room:GetGridIndex(v.Position) == idx
            and v.GridCollisionClass > EntityGridCollisionClass.GRIDCOLL_WALLS
            and v:ToTear().Height > -30 then
                v:Die()
            end
        end
        if effect.FrameCount > t.GUY_BOX_DURATION then
            t:DestoryBox(effect)
        end
    end, t.EFFECT_BOX)

    ---@param familiar EntityFamiliar
    MOD:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function (_, familiar)
        familiar:AddToFollowers()
        local sprite = familiar:GetSprite()
        sprite:Play("Float", true)
    end, t.FAMILIAR_CLOUD)

    t.EFFECT_CLOUD = Isaac.GetEntityVariantByName("Vivian Cloud Effect")
    t.CLOUD_FREQ = 30 * 5
    t.CLOUD_DUR = 30 * 7.5 // 1
    t.CLOUD_TEARS_FREQ = 12
    t.CLOUD_TEARS_ADD = 5
    t.CLOUD_TEARS_DUR = 30 * 3.5

    ---@param familiar EntityFamiliar
    MOD:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function (_, familiar)
        familiar:FollowParent()
        familiar.FlipX = familiar.Velocity.X < 0
        if familiar.FrameCount % t.CLOUD_FREQ == 0 then
            Isaac.Spawn(
                EntityType.ENTITY_EFFECT,
                t.EFFECT_CLOUD,
                0,
                MOD.GAME:GetRoom():FindFreePickupSpawnPosition(Isaac.GetRandomPosition()),
                Vector.Zero,
                nil
            )
        end
    end, t.FAMILIAR_CLOUD)

    -- ---@param effect EntityEffect
    -- MOD:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function (_, effect)
        
    -- end, t.EFFECT_CLOUD)

    ---@param effect EntityEffect
    MOD:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, effect)
        local sprite = effect:GetSprite()

        if sprite:IsFinished("PoofStart") then
            sprite:Play("PoofLoop", true)
        end

        if sprite:IsFinished("PoofEnd") then
            effect:Remove()
        end

        -- if sprite:GetAnimation() == "PoofLoop" then
            -- sprite.PlaybackSpeed = 0.5
        -- else
            -- sprite.PlaybackSpeed = 1
        -- end

        if effect.FrameCount == t.CLOUD_DUR then
            sprite:Play("PoofEnd", true)
        end

        sprite.Offset = Vector(0, 8)
        effect.Color = Color(
            1, 1, 1,
            0.7,
            0, 0, 0,
            0.5, 0.9, 2,
            1.2
        )
        if sprite:GetAnimation() ~= "PoofEnd" then
            for _, v in ipairs(Isaac.FindInRadius(effect.Position, 20, EntityPartition.PLAYER)) do
                local player = v:ToPlayer()
                if player then
                    sprite:Play("PoofEnd", true)
                    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TEAR_POOF_A, 10, player.Position, Vector.Zero, nil):ToEffect()
                    poof.Rotation = 0
                    poof.SpriteOffset = Vector(0, player.SpriteScale.Y * -20) + player:GetFlyingOffset()
                    poof.DepthOffset = -20
                    poof:FollowParent(player)
                    poof.SpriteScale = player.SpriteScale
                    poof.FlipX = math.random() > 0.5
                    local data = MOD:GetData(player)
                    data.CloudTears = (data.CloudTears or 0) + 1
                    data.CloudFrame = player.FrameCount
                    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
                    MOD.SFX:Play(458, nil, nil, nil, 1.2)
                    player:SetColor(Color(
                        1, 1, 1,
                        1,
                        0.3, 0.4, 0.8
                    ), 12, 99, true, false)
                    break
                end
            end
            sprite.PlaybackSpeed = 0.5
        else
            sprite.PlaybackSpeed = 1
        end
    end, t.EFFECT_CLOUD)

    ---@param player EntityPlayer
    MOD:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)
        local data = MOD:GetData(player)
        if not data.CloudFrame or not data.CloudTears then return end
        if (player.FrameCount - data.CloudFrame) % t.CLOUD_TEARS_FREQ == 0 then
            data.CloudTears = data.CloudTears - t.CLOUD_TEARS_FREQ / t.CLOUD_TEARS_DUR
            if data.CloudTears <= 0 then
                data.CloudTears = nil
                data.CloudFrame = nil
            end
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
        end
    end)

    MOD:AddCallback(ModCallbacks.MC_EVALUATE_STAT, function (_, player, stage, val)
        local data = MOD:GetData(player)
        if not data.CloudTears then return end
        return val + data.CloudTears * t.CLOUD_TEARS_ADD
    end, EvaluateStatStage.FLAT_TEARS)

    return t
end