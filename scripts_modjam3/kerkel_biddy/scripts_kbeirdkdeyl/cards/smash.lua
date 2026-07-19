--shoulda made each its own file but whatevar

---@param MOD ModReference
return function (MOD)
    local t = {}

    t.ID = Isaac.GetCardIdByName("Smash Kard")
    t.EFFECT_LOBGRENUKE = Isaac.GetEntityVariantByName("Lobgrenuke")
    t.EFFECT_SNOW_BALL = Isaac.GetEntityVariantByName("Skartball")
    t.EFFECT_SNOW_GIB = Isaac.GetEntityVariantByName("Skartball Gib")
    t.EFFECT_SNOW_PARTICLE = Isaac.GetEntityVariantByName("Skartball Particle")
    t.EFFECT_SPIKE = Isaac.GetEntityVariantByName("Fricking,....Skart spike")
    t.SOUND_BEEP = Isaac.GetSoundIdByName("Skart Beep")
    t.SOUND_BUBBLE = Isaac.GetSoundIdByName("Skart Bubble")
    t.SOUND_POWERUP = Isaac.GetSoundIdByName("Skart Powerup")
    t.SOUND_RIFLE = Isaac.GetSoundIdByName("Skart Rifle")
    t.SOUND_SNOW = Isaac.GetSoundIdByName("Skart Snow")
    t.SOUND_WHOOSH = Isaac.GetSoundIdByName("Skart Whoosh")
    t.NULL_BUBBLE = Isaac.GetNullItemIdByName("Skart Bubble")

    ---@param player EntityPlayer
    function t:SpawnSpieks(player)
        for i = 1, 3 do
            local effect = Isaac.Spawn(
                EntityType.ENTITY_EFFECT,
                t.EFFECT_SPIKE,
                i,
                player.Position,
                Vector.Zero,
                player
            )
        end
    end

    t.SPIKE_DUR = 30 * 5

    ---@alias SmashKardOutcome fun(player: EntityPlayer): string

    ---@type SmashKardOutcome[]
    t.OUTCOMES = {
        function (player)
            local rng = player:GetCardRNG(t.ID)
            if rng:RandomFloat() < 0.1 then
                local data = MOD:GetData(player)
                data.BubbleSprite = data.BubbleSprite or Sprite("gfx/characters/058_book of shadows.anm2", true)
                -- data.BubbleSprite.Color = Color(
                --     1, 1, 1,
                --     0.5,
                --     1, 1, 0
                -- )
                data.BubbleSprite:GetLayer(0):GetBlendMode():SetMode(BlendType.ADDITIVE)
                data.BubbleSprite:Play("WalkDown", true)
                data.BubbleDuration = (data.BubbleDuration or 0) + 30 * 8
                MOD.SFX:Stop(t.SOUND_BUBBLE)
                local fx = player:GetEffects()
                if fx:GetNullEffectNum(t.NULL_BUBBLE) == 0 then
                    fx:AddNullEffect(t.NULL_BUBBLE)
                end
                return "Invincibility"
            end
            ---@type SmashKardOutcome[]
            local choices = {}
            for i = 2, #t.OUTCOMES do
                choices[#choices + 1] = t.OUTCOMES[i]
            end
            return choices[rng:RandomInt(1, #choices)](player)
        end,
        function (player)
            Isaac.Spawn(
                EntityType.ENTITY_EFFECT,
                t.EFFECT_LOBGRENUKE,
                0,
                player.Position,
                Vector.Zero,
                nil
            ).Parent = player
            Isaac.Spawn(
                EntityType.ENTITY_EFFECT,
                EffectVariant.POOF01,
                0,
                player.Position,
                Vector.Zero,
                nil
            ).DepthOffset = 10
            MOD.SFX:Play(286, 0.8)
            return "Lobgrenuke"
        end,
        function (player)
            local data = MOD:GetData(player)
            data.Snowballs = (data.Snowballs or 0) + 1
            MOD.SFX:Play(SoundEffect.SOUND_FREEZE)
            return "Snowballs"
        end,
        function (player)
            local data = MOD:GetData(player)
            if not data.SpikyDur then
                data.SpikyDur = 0
                t:SpawnSpieks(player)
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, nil)
            end
            MOD.SFX:Play(286, 0.8)
            data.SpikyDur = data.SpikyDur + t.SPIKE_DUR
            return "Spiky-Go-Round"
        end,
        function (player)
            local data = MOD:GetData(player)
            data.SkartBullets = (data.SkartBullets or 0) + 9
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SHOTSPEED, true)
            player:AddCostume(MOD.CONFIG:GetCollectible(CollectibleType.COLLECTIBLE_INNER_EYE))
            return "Bullets"
        end
    }
    ---@param player EntityPlayer
    ---@param flags UseFlag
    MOD:AddCallback(ModCallbacks.MC_USE_CARD, function (_, _, player, flags)
        local rng = player:GetCardRNG(t.ID)
        MOD.SFX:Play(t.SOUND_POWERUP)
        local text = t.OUTCOMES[rng:RandomInt(1, #t.OUTCOMES)](player)
        -- if flags & UseFlag.USE_OWNED ~= 0 then
            MOD.HUD:ShowItemText(text)
        -- end
    end, t.ID)

    ---@param effect EntityEffect
    MOD:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function (_, effect)
        local sprite = effect:GetSprite()
        sprite:Play("Front", true)
        sprite:Stop()
        sprite:SetFrame(0)
        MOD:GetData(effect).LobChargeBar = Sprite("gfx/chargebar.anm2", true)
    end, t.EFFECT_LOBGRENUKE)

    MOD:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, function ()
        for _, v in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, t.EFFECT_LOBGRENUKE)) do
            if v.Parent and v:ToEffect().State == 0 then
                local parent = EntityPtr(v.Parent)
                Isaac.CreateTimer(function ()
                    if not parent.Ref or not parent.Ref:Exists() then return end
                    Isaac.Spawn(
                        EntityType.ENTITY_EFFECT,
                        t.EFFECT_LOBGRENUKE,
                        v.SubType,
                        parent.Ref.Position,
                        Vector.Zero,
                        nil
                    ).Parent = parent.Ref
                end, 0, 1, true)
            end
        end
    end)

    t.LGN_THROW_HEIGHT = -20
    t.LGN_THROW_GRAVITY = 1.5
    t.LGN_THROW_VEL = 7.5
    t.LGN_RADIUS = 40
    t.LGN_EXPLODE_DELAY = 30
    t.LGN_BEEP_FREQ = 4
    t.LGN_MAX_DUR = 30 * 2
    t.LGN_BEEP_COLOR = Color(
        0.8, 0.8, 0.8,
        1,
        0.5
    )
    t.LGN_MAX_CHARGE = 30
    t.LGN_FAKE_MAX_CHARGE = t.LGN_MAX_CHARGE
    t.LGN_MIN_CHARGE = 3

    ---@param effect EntityEffect
    MOD:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, effect)
        effect.Parent = effect.Parent or MOD.GAME:GetNearestPlayer(effect.Position)
        local player = effect.Parent and effect.Parent:ToPlayer()
        if not player then return end

        local sprite = effect:GetSprite()
        ---for anim
        local dir

        if effect.State == 0 then
            local parentHash = GetPtrHash(effect.Parent)
            local lgnHash = GetPtrHash(effect)
            local lgns = 0
            local idx = -1
            for _, v in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, t.EFFECT_LOBGRENUKE)) do
                if v:ToEffect().State == 0 and v.Parent and GetPtrHash(v.Parent) == parentHash then
                    lgns = lgns + 1
                    if GetPtrHash(v) == lgnHash then
                        idx = lgns
                    end
                end
            end
            local rotOfsett = lgns == 1 and 0 or MOD:SpreadShotAngle(idx, lgns, lgns * 15)
            effect.PositionOffset = Vector(0, -6)
            effect.Rotation = MOD:LerpAngle(
                effect.Rotation,
                MOD:DirectionToAngle(player:GetHeadDirection()) + rotOfsett,
                effect.FrameCount < 2 and 1 or 0.33
            ) % 360
            dir = MOD:AngleToDirection(effect.Rotation)
            local angle = MOD:DirectionToAngle(dir)
            if not angle then
                effect:Remove()
                return
            end
            sprite.Rotation = effect.Rotation - angle

            effect.DepthOffset = 2
            local offset = Vector(12, 0):Rotated(effect.Rotation)
            offset.X = offset.X * 1.7
            local targPos = player.Position + offset * (effect.FrameCount / (effect.FrameCount + 1))
            effect.Velocity = (targPos - effect.Position) + player.Velocity
            if player:GetAimDirection():Length() > 0.1 then
                effect.SubType = math.min(effect.SubType + 1, t.LGN_MAX_CHARGE)
            else
                if effect.SubType > t.LGN_MIN_CHARGE then
                    local stren = math.min(effect.SubType / t.LGN_FAKE_MAX_CHARGE, 1)
                    effect.State = 1
                    effect.FallingSpeed = t.LGN_THROW_HEIGHT * stren
                    -- effect.Rotation = MOD:DirectionToAngle(MOD:AngleToDirection(effect.Rotation))
                    effect.Velocity = Vector.FromAngle(effect.Rotation):Resized(t.LGN_THROW_VEL * stren)
                    effect.Velocity = effect.Velocity + player:GetTearMovementInheritance(effect.Velocity)
                    MOD.SFX:Play(SoundEffect.SOUND_SHELLGAME)
                    sprite.Rotation = 0
                end
                effect.SubType = 0
            end
        end
        if effect.State == 1 then
            dir = MOD:VectorToDirection(effect.Velocity)
            -- effect.Rotation = MOD:DirectionToAngle(dir)
            effect.FallingSpeed = effect.FallingSpeed + t.LGN_THROW_GRAVITY
            effect.PositionOffset = effect.PositionOffset + Vector(0, effect.FallingSpeed)
            if effect.PositionOffset.Y >= 0 then
                effect.PositionOffset = Vector.Zero
                effect.State = 2
                effect.Timeout = t.LGN_MAX_DUR
                MOD.SFX:Play(SoundEffect.SOUND_FETUS_LAND)
                if dir == Direction.LEFT then
                    sprite:Play("SideLand", true)
                    sprite.FlipX = false
                elseif dir == Direction.UP then
                    sprite:Play("BackLand", true)
                elseif dir == Direction.RIGHT then
                    sprite:Play("SideLand", true)
                    sprite.FlipX = true
                elseif dir == Direction.DOWN then
                    sprite:Play("FrontLand", true)
                end
                sprite:GetLayer(0):SetCropOffset(Vector(96, 0))
            end
            effect.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
        end
        if effect.State >= 2 then
            effect.Velocity = effect.Velocity * 0.2
            effect.DepthOffset = 0
            effect.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
            if effect.State == 2 then
                if #Isaac.FindInRadius(effect.Position, t.LGN_RADIUS, EntityPartition.ENEMY) > 0
                or effect.Timeout <= 0 then
                    if effect.Timeout == t.LGN_MAX_DUR then
                        effect.State = t.LGN_EXPLODE_DELAY
                    else
                        effect.State = 3
                    end
                end
            end
            if effect.State >= 3 then
                effect.State = effect.State + 1
                if effect.State > t.LGN_EXPLODE_DELAY - 3 then
                    effect:Remove()
                    MOD.GAME:BombExplosionEffects(
                        effect.Position,
                        100,
                        player:GetBombFlags(),
                        nil,
                        player,
                        nil,
                        nil,
                        false,
                        nil
                    )
                    return
                end
                if (effect.State - 3) % t.LGN_BEEP_FREQ == 0 then
                    MOD.SFX:Play(t.SOUND_BEEP, nil, nil, nil, 1.2)
                    effect:SetColor(t.LGN_BEEP_COLOR, t.LGN_BEEP_FREQ, 99, true, false)
                end
            end
        else
            if dir == Direction.LEFT then
                sprite:Play("Left")
            elseif dir == Direction.UP then
                sprite:Play("Back")
            elseif dir == Direction.RIGHT then
                sprite:Play("Right")
            elseif dir == Direction.DOWN then
                sprite:Play("Front")
            end
            if effect.State == 0 then
                sprite:Stop()
            end
        end
    end, t.EFFECT_LOBGRENUKE)

    ---@param effect EntityEffect
    MOD:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, function (_, effect)
        local sprite = MOD:GetData(effect).LobChargeBar
        if not sprite then return end
        HudHelper.RenderChargeBar(sprite, effect.SubType, t.LGN_MAX_CHARGE, Isaac.WorldToScreen(effect.Position) + Vector(18, -18))
    end, t.EFFECT_LOBGRENUKE)

    t.SNOW_POOF_COLOR = Color(
        1, 1, 1,
        0.75,
        0, 0, 0,
        2, 2.25, 2.5,
        1
    )
    t.SNOW_RADIUS = 30
    t.SNOW_FREEZE_DUR = 30 * 5
    t.SNOW_DMG = 3.5
    t.SNOW_SPREAD = 45

    ---@param player EntityPlayer
    MOD:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)
        local data = MOD:GetData(player)
        if data.Snowballs then
            if player.Velocity:Length() > 1 then
                if player.FrameCount % 2 == 0 then
                    Isaac.Spawn(
                        EntityType.ENTITY_EFFECT,
                        t.EFFECT_SNOW_PARTICLE,
                        20 * player.SpriteScale.Y,
                        player.Position,
                        Vector.Zero,
                        nil
                    )
                end
            elseif player.FrameCount % 3 == 0 then
                Isaac.Spawn(
                    EntityType.ENTITY_EFFECT,
                    t.EFFECT_SNOW_PARTICLE,
                    20 * player.SpriteScale.Y,
                    player.Position + Vector.FromAngle(math.random() * 360):Resized(math.random() * 20),
                    Vector.Zero,
                    nil
                )
            end
            -- if player.FrameCount % 45 == 0 then
                player:SetColor(Color.Lerp(
                    player.Color,
                    Color(
                        1, 1, 1,
                        1,
                        0.2, 0.3, 0.4,
                        1, 1, 1,
                        0.5
                    ), math.abs(math.sin(player.FrameCount * 0.05))
                ), 2, 99, false, false)
            -- end
        end
        if data.SpikyDur then
            if (data.SpikyDur - t.SPIKE_DUR + 14) % 14 == 0 then
                MOD.SFX:Play(t.SOUND_WHOOSH)
            end
            data.SpikyDur = data.SpikyDur - 1
            if data.SpikyDur <= 0 then
                data.SpikyDur = nil
                local hash = GetPtrHash(player)
                for _, v in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, t.EFFECT_SPIKE)) do
                    if v.SpawnerEntity and GetPtrHash(v.SpawnerEntity) == hash then
                        v:Remove()
                        MOD.SFX:Play(286, 0.8)
                        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, v.Position, Vector.Zero, nil)
                    end
                end
            end
        end
        if data.BubbleDuration then
            if data.BubbleSprite then
                data.BubbleSprite:Update()
                if data.BubbleDuration < 30 * 2.5 then
                    data.BubbleSprite:Play("Blink")
                end
                local r, g, b = MOD.COLLECTIBLE_NEGATE_RAINBOW_CONTAGION:GetRainbow(player.FrameCount * 3, 0.1)
                data.BubbleSprite.Color = Color(
                    1, 1, 1,
                    0.5,
                    r, g, b
                )
                if player.FrameCount % 10 == 0 then
                    player:SetColor(Color.Lerp(data.BubbleSprite.Color, Color.Default, 0.6), 10, 99, true, false)
                end
            end
            if player.Velocity:Length() > 2 and player.FrameCount % 3 == 0 then
                player:CreateAfterimage(15, player.Position)
            end
            data.BubbleDuration = data.BubbleDuration - 1
            if data.BubbleDuration <= 0 then
                data.BubbleDuration = nil
                MOD.SFX:Stop(t.SOUND_BUBBLE)
                data.BubbleSprite = nil
                player:GetEffects():RemoveNullEffect(t.NULL_BUBBLE, -1)
                player:SetMinDamageCooldown(60)
            end
        end
    end)

    MOD:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function ()
        -- MOD.SFX:Stop(t.SOUND_BUBBLE)
        for _, player in ipairs(PlayerManager.GetPlayers()) do
            player:GetEffects():RemoveNullEffect(t.NULL_BUBBLE, -1)
        end
    end)

    ---@param player EntityPlayer
    MOD:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, function (_, player)
        local data = MOD:GetData(player)
        if not data.BubbleSprite then return end
        data.BubbleSprite.Scale = player.SpriteScale
        data.BubbleSprite:Render(Isaac.WorldToScreen(player.Position))
        if not MOD.SFX:IsPlaying(t.SOUND_BUBBLE) then
            MOD.SFX:Play(t.SOUND_BUBBLE, nil, nil, true)
        end
    end)

    ---@param player EntityPlayer
    ---@param grid GridEntity?
    MOD:AddCallback(ModCallbacks.MC_PRE_PLAYER_GRID_COLLISION, function (_, player, _, grid)
        if not grid or not MOD:GetData(player).BubbleDuration then return end
        local type = grid:GetType()
        if type == GridEntityType.GRID_ROCK
        -- or type == GridEntityType.GRID_ROCKB
        or type == GridEntityType.GRID_ROCKT
        or type == GridEntityType.GRID_ROCK_BOMB
        or type == GridEntityType.GRID_ROCK_ALT
        or type == GridEntityType.GRID_TNT
        or type == GridEntityType.GRID_POOP
        or type == GridEntityType.GRID_DOOR
        or type == GridEntityType.GRID_ROCK_SS
        or type == GridEntityType.GRID_ROCK_SPIKED
        or type == GridEntityType.GRID_ROCK_ALT2
        or type == GridEntityType.GRID_ROCK_SPIKED
        or type == GridEntityType.GRID_ROCK_GOLD then
            grid:Destroy()
            -- MOD.GAME:ShakeScreen(6)
            return true
        end
    end)

    ---@param entity Entity
    ---@param flags DamageFlag
    ---@param source EntityRef
    MOD:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function (_, entity, _, flags, source)
        if not MOD:GetData(entity).BubbleDuration
        or (source.Entity and GetPtrHash(source.Entity) == GetPtrHash(entity)) then return end
        return false
    end, EntityType.ENTITY_PLAYER)

    ---@param entity Entity
    ---@param collider Entity
    function t:PreCollision(entity, collider)
        if not MOD:GetData(collider).BubbleDuration then return end
        if entity:IsBoss() then
            entity:TakeDamage(5, DamageFlag.DAMAGE_COUNTDOWN, EntityRef(collider), 4)
            return
        elseif entity:IsEnemy() then
            entity:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
            entity:Kill()
        else
            entity:Die()
        end
        return true
    end
    MOD:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, t.PreCollision)
    MOD:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, t.PreCollision)

    ---@param effect EntityEffect
    MOD:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function (_, effect)
        local sprite = effect:GetSprite()
        sprite:Play("Particle", true)
        sprite:SetFrame(math.random(1, 3))
        if effect.SpawnerEntity then
            effect.PositionOffset = effect.SpawnerEntity.PositionOffset
        end
        effect.PositionOffset = effect.PositionOffset - Vector(0, effect.SubType)
        sprite.PlaybackSpeed = 0.5 + math.random() * 0.5
        local rng = effect:GetDropRNG()
        effect.SpriteOffset = Vector(rng:RandomFloat() - 0.5, rng:RandomFloat() - 0.5) * 10
    end, t.EFFECT_SNOW_PARTICLE)

    ---@param effect EntityEffect
    MOD:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, effect)
        local sprite = effect:GetSprite()
        if sprite:IsFinished() then
            effect:Remove()
        end
        effect.Velocity = effect.Velocity * 0.9
    end, t.EFFECT_SNOW_PARTICLE)

    ---@param effect EntityEffect
    MOD:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function (_, effect)
        effect.PositionOffset = Vector(0, -20)
        local sprite = effect:GetSprite()
        sprite:Stop()
        sprite:SetFrame(math.random(0, 1))
        sprite.FlipX = math.random(2) == 1
        effect.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS

        local trail = Isaac.Spawn(
            EntityType.ENTITY_EFFECT,
            EffectVariant.SPRITE_TRAIL,
            0,
            effect.Position,
            Vector.Zero,
            effect
        ):ToEffect()
        trail:SetRadii(0.1, 0.1)
        trail.SpriteScale = Vector.One * 2
        trail:FollowParent(effect)
        trail.ParentOffset = effect.PositionOffset
        trail:GetSprite().Color = Color(
            0, 0, 0,
            1,
            0.5, 0.8, 1
        )
    end, t.EFFECT_SNOW_BALL)

    ---@param effect EntityEffect
    MOD:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, effect)
        if math.random() < 0.1 then
            Isaac.Spawn(
                EntityType.ENTITY_EFFECT,
                t.EFFECT_SNOW_PARTICLE,
                0,
                effect.Position + Vector.FromAngle(math.random() * 360):Resized(math.random() * 10),
                Vector.Zero,
                effect
            )
        end
        if effect:CollidesWithGrid()
        or effect.FrameCount > 30
        or #Isaac.FindInCapsule(effect:GetCollisionCapsule(), EntityPartition.ENEMY) > 0 then
            for _, v in ipairs(Isaac.FindInRadius(effect.Position, t.SNOW_RADIUS, EntityPartition.ENEMY)) do
                v:AddIce(EntityRef(effect), t.SNOW_FREEZE_DUR)
                v:AddFreeze(EntityRef(effect), t.SNOW_FREEZE_DUR)
                v:TakeDamage(t.SNOW_DMG, 0, EntityRef(effect), 0)
                MOD.SFX:Play(SoundEffect.SOUND_FREEZE)
            end
            MOD.SFX:Play(t.SOUND_SNOW)
            for _ = 1, 5 do
                Isaac.Spawn(
                    EntityType.ENTITY_EFFECT,
                    t.EFFECT_SNOW_PARTICLE,
                    -math.ceil(effect.PositionOffset.Y),
                    effect.Position,
                    Vector.FromAngle(math.random() * 360):Resized(math.random() * 10),
                    nil
                )
                -- MOD.SFX:Play(286, 0.9, nil, nil, 1.4)
                -- MOD.SFX:Play(SoundEffect.SOUND_FREEZE_SHATTER, 0.7, nil, nil, 1)
            end
            -- for _ = 1, math.random(2, 3) do
            --     Isaac.Spawn(
            --         EntityType.ENTITY_EFFECT,
            --         t.EFFECT_SNOW_GIB,
            --         -math.ceil(effect.PositionOffset.Y),
            --         effect.Position,
            --         Vector.FromAngle(math.random() * 360):Resized(math.random() * 5)
            --         + effect.Velocity * math.random(),
            --         nil
            --     )
            --     MOD.SFX:Play(SoundEffect.SOUND_FREEZE_SHATTER)
            -- end
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, effect.Position, Vector.Zero, nil).Color = t.SNOW_POOF_COLOR
            effect:Remove()
        end
    end, t.EFFECT_SNOW_BALL)

    ---@param effect EntityEffect
    MOD:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function (_, effect)
        local sprite = effect:GetSprite()
        sprite:Play("Gib", true)
        effect.PositionOffset = Vector(0, -effect.SubType)
        effect.FallingSpeed = -5 - math.random() * 5
        sprite:SetFrame(math.random(0, 4))
        sprite.FlipX = math.random(2) == 1
        effect.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
    end, t.EFFECT_SNOW_GIB)

    ---@param effect EntityEffect
    MOD:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, effect)
        local sprite = effect:GetSprite()
        effect.FallingSpeed = effect.FallingSpeed + 1
        effect.PositionOffset = effect.PositionOffset + Vector(0, effect.FallingSpeed)
        if effect.PositionOffset.Y >= 0 then
            effect.Velocity = effect.Velocity * 0.5
            sprite.PlaybackSpeed = 0.25 + RNG(effect.InitSeed):RandomFloat() * 0.75
            effect.PositionOffset = Vector(effect.PositionOffset.X, 0)
        else
            sprite.PlaybackSpeed = 0
        end
        if sprite:IsFinished() then
            effect:Remove()
        end
    end, t.EFFECT_SNOW_GIB)

    ---@param player EntityPlayer
    function t:PostFireForBulletttt(player)
        local data = MOD:GetData(player)
        if data.SkartBullets then
            data.SkartBullets = data.SkartBullets - 1
            MOD.SFX:Stop(SoundEffect.SOUND_TEARS_FIRE)
            MOD.SFX:Play(t.SOUND_RIFLE)
            if data.SkartBullets <= 0 then
                data.SkartBullets = nil
                player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SHOTSPEED, true)
                if not player:HasCollectible(CollectibleType.COLLECTIBLE_INNER_CHILD) then
                    player:RemoveCostume(MOD.CONFIG:GetCollectible(CollectibleType.COLLECTIBLE_INNER_EYE))
                end
                player.FireDelay = player.MaxFireDelay
            end
        end
    end

    ---@param vec Vector
    ---@param owner Entity
    ---@param weap Weapon
    MOD:AddCallback(ModCallbacks.MC_POST_TRIGGER_WEAPON_FIRED, function (_, vec, _, owner, weap)
        local data = MOD:GetData(owner)
        if data.Snowballs then
            data.Snowballs = data.Snowballs - 1
            owner.Velocity = owner.Velocity + vec:Rotated(180):Resized(2)
            if data.Snowballs == 0 then
                for _ = 1, 10 do
                    Isaac.Spawn(
                        EntityType.ENTITY_EFFECT,
                        t.EFFECT_SNOW_PARTICLE,
                        20 * owner.SpriteScale.Y,
                        owner.Position + owner.Velocity,
                        Vector.FromAngle(math.random() * 360):Resized(math.random() * 10),
                        nil
                    )
                    MOD.SFX:Play(SoundEffect.SOUND_FREEZE_SHATTER)
                end
                -- Isaac.Spawn(
                --     EntityType.ENTITY_EFFECT,
                --     EffectVariant.POOF01,
                --     0,
                --     owner.Position + owner.Velocity,
                --     Vector.Zero,
                --     nil
                -- ).Color = t.SNOW_POOF_COLOR
                owner:SetColor(Color(1, 1, 1, 1, 0.8, 0.9, 1), 10, 99, true, false)
                data.Snowballs = nil
            end
            MOD.SFX:Play(SoundEffect.SOUND_MUSHROOM_POOF)
            local bonus = Vector.Zero
            if owner.Type == EntityType.ENTITY_PLAYER then
                bonus = owner:ToPlayer():GetTearMovementInheritance(vec)
            end

            for i = 1, 3 do
                local effect = Isaac.Spawn(
                    EntityType.ENTITY_EFFECT,
                    t.EFFECT_SNOW_BALL,
                    0,
                    owner.Position,
                    (vec + owner.Velocity * 0.05):Resized(10):Rotated(MOD:SpreadShotAngle(i, 3, t.SNOW_SPREAD)) + bonus,
                    owner
                )
            end
        end
        local wt = weap:GetWeaponType()
        if wt ~= WeaponType.WEAPON_BRIMSTONE and owner.Type == EntityType.ENTITY_PLAYER then
            t:PostFireForBulletttt(owner:ToPlayer())
        end
    end)

    ---@param laser EntityLaser
    MOD:AddCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE, function (_, laser)
        local player = laser.Parent and laser.Parent:ToPlayer()
        if not player then return end
        t:PostFireForBulletttt(player)
    end)

    ---@param effect EntityEffect
    MOD:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, effect)
        local player = effect.SpawnerEntity and effect.SpawnerEntity:ToPlayer()
        if not player then return end
        local angle = (120 * effect.SubType + player.FrameCount * 7.5) % 360
        effect.m_Height = MOD:Lerp(effect.m_Height, 60, 0.2)
        effect.Velocity = player.Position + Vector.FromAngle(angle):Resized(effect.m_Height) - effect.Position + player.Velocity
        local sprite = effect:GetSprite()
        local frames = sprite:GetCurrentAnimationData():GetLength()
        -- print(angle / 360)
        -- local frame = frames * (angle - 45) / 360 // 1
        -- if effect.SubType == 1 then
        --     print(angle / 360)
        -- end
        -- effect:GetSprite():SetFrame(frame)
        for _, v in ipairs(Isaac.FindInCapsule(effect:GetCollisionCapsule())) do
            if v.Type == EntityType.ENTITY_PROJECTILE then
                v:Die()
            elseif v:IsVulnerableEnemy() and not v:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
                if v:TakeDamage(5, DamageFlag.DAMAGE_COUNTDOWN, EntityRef(effect), 4) then
                    -- v:BloodExplode()
                    MOD.SFX:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.5)
                    Isaac.Spawn(
                        EntityType.ENTITY_EFFECT,
                        EffectVariant.BLOOD_EXPLOSION,
                        2,
                        v.Position,
                        Vector.Zero,
                        nil
                    ).Color = v.SplatColor
                    MOD.GAME:SpawnParticles(
                        v.Position,
                        EffectVariant.BLOOD_PARTICLE,
                        4,
                        2,
                        v.SplatColor
                    )
                end
            end
        end
    end, t.EFFECT_SPIKE)

    ---@param player EntityPlayer
    MOD:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, function (_, player)
        local data = MOD:GetData(player)
        if not data.SpikyDur then return end
        t:SpawnSpieks(player)
    end)

    ---@param player EntityPlayer
    ---@param flag CacheFlag
    MOD:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function (_, player, flag)
        if flag == CacheFlag.CACHE_FIREDELAY then
            local data = MOD:GetData(player)
            if not data.SkartBullets then return end
            player.MaxFireDelay = player.MaxFireDelay / 1.8181818181
        elseif flag == CacheFlag.CACHE_DAMAGE then
            local data = MOD:GetData(player)
            if not data.SkartBullets then return end
            player.Damage = player.Damage * 1.5
        elseif flag == CacheFlag.CACHE_SHOTSPEED then
            local data = MOD:GetData(player)
            if not data.SkartBullets then return end
            player.ShotSpeed = player.ShotSpeed * 1.25
        end
    end)

    ---@param player EntityPlayer
    ---@param params MultiShotParams
    ---@param weap WeaponType
    MOD:AddCallback(ModCallbacks.MC_EVALUATE_MULTI_SHOT_PARAMS, function (_, player, params, weap)
        local data = MOD:GetData(player)
        if not data.SkartBullets then return end
        params:SetNumEyesActive(1)
        params:SetSpreadAngle(weap, 5)
        local tears = params:GetNumTears() * 3
        params:SetNumLanesPerEye(tears)
        params:SetNumTears(tears)
    end)

    return t
end