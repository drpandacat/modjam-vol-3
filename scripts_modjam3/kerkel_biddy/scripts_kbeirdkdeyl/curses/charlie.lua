---@param MOD ModReference
return function (MOD)
    local t = {}

    t.ID = Isaac.GetCurseIdByName("Charlie Blurse")
    t.EFFECT = Isaac.GetEntityVariantByName("Oak Laser Sight")
    t.WARN_TIME = 15
    t.SHOOT_DELAY = 30 * 3
    t.EFFECT_COLOR = Color(1, 0, 0, 0.5, 0.5)
    t.SOUND_PRIME = Isaac.GetSoundIdByName("Oak Laser Sight")
    t.RADIUS_PLAYER = 20
    t.RADIUS_ENEMY = 30
    t.DMG_ENEMY = 25
    t.DMG_PLAYER = 1

    -- ---@param player EntityPlayer
    -- MOD:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function (_, player)
    --     if Input.IsActionTriggered(ButtonAction.ACTION_DROP, player.ControllerIndex) then
    --         Isaac.Spawn(
    --             EntityType.ENTITY_EFFECT,
    --             t.EFFECT,
    --             0,
    --             Game():GetRoom():GetCenterPos(),
    --             Vector.Zero,
    --             nil
    --         )
    --     end
    -- end)

    ---@param effect EntityEffect
    MOD:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function (_, effect)
        local sprite = effect:GetSprite()
        sprite.Scale = Vector(0, 1)
        -- local ret = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TARGET, 0, effect.Position, Vector.Zero, nil):ToEffect()
        -- ret:FollowParent(effect)
        -- ret.Visible = false
        -- ret:AddEntityFlags(EntityFlag.FLAG_NO_QUERY)
        -- effect.Child = ret
        MOD.SFX:Play(t.SOUND_PRIME)
        local color = Color.Lerp(t.EFFECT_COLOR, Color.Default, 0)
        color.A = 0
        effect.Color = color

        -- sprite:GetLayer(0):SetRenderFlags(AnimRenderFlags.ENABLE_LAYER_LIGHTING)
    end, t.EFFECT)

    t.fgdrgdfg = 0.1

    ---@param effect EntityEffect
    MOD:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, effect)
        effect.Target = effect.Target or Isaac.GetPlayer()
        local sprite = effect:GetSprite()
        for _, layer in ipairs(sprite:GetAllLayers()) do
            layer:SetRenderFlags(layer:GetRenderFlags() | AnimRenderFlags.ENABLE_LAYER_LIGHTING)
        end
        if sprite:GetFrame() > 3 then
            sprite:SetFrame(3)
        end
        sprite.Scale = MOD:Lerp(sprite.Scale, Vector.One, t.fgdrgdfg)
        effect.DepthOffset = 10
        local player = effect.Target:ToPlayer()
        local speed = player and player.MoveSpeed or 1
        effect.Velocity = MOD:Lerp(
            effect.Velocity,
            (effect.Target.Position - effect.Position):Resized(
                math.min(8 - (1 - speed) * 3.5, effect.Target.Position:Distance(effect.Position))
            ),
            0.2
        )
        if effect.FrameCount > t.SHOOT_DELAY - t.WARN_TIME then
            -- if effect.FrameCount % 2 == 0 then
                effect.State = effect.State == 1 and 2 or 1
            -- end
            MOD.SFX:Play(SoundEffect.SOUND_BEEP)
            if effect.State == 1 then
                local color = Color.Lerp(t.EFFECT_COLOR, Color.Default, 0)
                color.A = 0.1
                effect.Color = color
            else
                effect.Color = t.EFFECT_COLOR
            end
        else
            effect.Color = Color.Lerp(effect.Color, t.EFFECT_COLOR, t.fgdrgdfg)
        end
        for _, v in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, t.EFFECT)) do
            if v.Position:Distance(effect.Position) < 20 then
                effect.Velocity = effect.Velocity + (effect.Position - v.Position) / 20
                v.Velocity = v.Velocity + (v.Position - effect.Position) / 20
            end
        end
        if effect.FrameCount > t.SHOOT_DELAY then
            local impact = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.IMPACT, 0, effect.Position, Vector.Zero, nil)
            impact.SpriteScale = Vector.One * 0.8
            impact:GetSprite().PlaybackSpeed = 0.75
            local fire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HOT_BOMB_FIRE, 0, effect.Position, Vector.Zero, nil)
            fire:Die()
            fire:Update()
            fire:GetSprite():SetFrame(1)
            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, effect.Position, Vector.Zero, nil)
            poof.SpriteScale = Vector.One * 0.7
            poof.Color = Color(0.5, 0.5, 0.5, 0.7)
            local crater = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.LADDER, 0, effect.Position, Vector.Zero, nil):ToEffect()
            local craterSprite = crater:GetSprite()
            craterSprite:Load("gfx/1000.018_bomb crater.anm2", true)
            craterSprite:Play("IdleSmall", true)
            craterSprite:Stop()
            craterSprite:SetFrame(crater:GetDropRNG():RandomInt(0, craterSprite:GetCurrentAnimationData():GetLength()))
            crater:AddEntityFlags(EntityFlag.FLAG_NO_QUERY | EntityFlag.FLAG_RENDER_FLOOR)
            crater:Update()
            MOD.GAME:ShakeScreen(5)
            if effect.Child then
                effect.Child:Remove()
            end
            effect:Remove()
            MOD.SFX:Play(SoundEffect.SOUND_GFUEL_GUNSHOT_LARGE)
            for _, v in ipairs(Isaac.FindInRadius(effect.Position, t.RADIUS_ENEMY, EntityPartition.ENEMY)) do
                v:TakeDamage(t.DMG_ENEMY, 0, EntityRef(effect), 0)
                if v:HasMortalDamage() then
                    v:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
                end
            end
            for _, v in ipairs(Isaac.FindInRadius(effect.Position, t.RADIUS_PLAYER, EntityPartition.PLAYER)) do
                v = v:ToPlayer()
                local cooldown = v:GetDamageCooldown()
                if v:TakeDamage(t.DMG_PLAYER, 0, EntityRef(effect), 0) then
                    v:SpawnBloodEffect()
                    v:BloodExplode()
                    v:ResetDamageCooldown()
                    v:SetMinDamageCooldown(cooldown)
                end
            end
        end
    end, t.EFFECT)

    t.SPAWN_CHANCE = 0.02

    MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, function ()
        if MOD.LEVEL:GetCurses() & (1 << (t.ID - 1)) == 0 then return end
        local rng = Isaac.GetPlayer():GetCardRNG(MOD.CARD_WILD.ID)
        if rng:RandomFloat() > t.SPAWN_CHANCE then return end
        Isaac.Spawn(
            EntityType.ENTITY_EFFECT,
            t.EFFECT,
            0,
            Isaac.GetRandomPosition(),
            Vector.Zero, nil
        )
    end)

    return t
end