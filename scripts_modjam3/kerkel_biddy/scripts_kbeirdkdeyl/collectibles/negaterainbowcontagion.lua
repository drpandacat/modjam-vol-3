---@param MOD ModReference
return function (MOD)
    local t = {}

    t.ID = Isaac.GetItemIdByName("Negate Rainbow Contagion")
    t.DURATION = 30 * 10
    t.CUTSCENE = Isaac.GetCutsceneIdByName("Blue Asbestos Halls")
    t.Vol = Options.MusicVolume

    ---@param pos Vector
    function t:BlueAsbestoot(pos)
        local effect = Isaac.Spawn(
            EntityType.ENTITY_EFFECT,
            EffectVariant.FART,
            0,
            pos,
            Vector.Zero,
            nil
        )
        effect.Color = MOD.CARD_BLUE_ASBESTOS.COLOR_ASBESTOS
        if PlayerManager.AnyoneHasTrinket(TrinketType.TRINKET_GIGANTE_BEAN) then
            effect.SpriteScale = effect.SpriteScale * 2
            MOD.GAME:ShakeScreen(3)
        end
        for _, v in ipairs(Isaac.FindInRadius(effect.Position, 80 * effect.SpriteScale.X, EntityPartition.ENEMY)) do
            StatusEffectLibrary:AddStatusEffect(v, StatusEffectLibrary.StatusFlag.KBEIRDKDEYL_ROT, t.DURATION, EntityRef(effect))
            local data = StatusEffectLibrary:GetStatusEffectData(v, StatusEffectLibrary.StatusFlag.KBEIRDKDEYL_ROT)
            if data and data.CustomData then
                data.CustomData.NegateRainbowContagion = true
            end
        end
    end

    ---@param entity Entity
    MOD:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function (_, entity)
        local npc = entity:ToNPC()
        if not npc then return end
        local room = MOD.GAME:GetRoom()
        local fx = room:GetEffects()
        local data = StatusEffectLibrary:GetStatusEffectData(npc, StatusEffectLibrary.StatusFlag.KBEIRDKDEYL_ROT)
        if (
            fx:HasCollectibleEffect(t.ID)
            and not (data and data.CustomData and data.CustomData.NegateRainbowContagion)
        ) or not PlayerManager.AnyoneHasCollectible(t.ID) then return end
        fx:AddCollectibleEffect(t.ID)
        t:BlueAsbestoot(npc.Position)
    end)

    ---@param frame integer
    ---@param brightness? number
    function t:GetRainbow(frame, brightness)
        brightness = brightness or t.RAINBOW_BRIGHTNESS
        frame = frame * t.RAINBOW_CYCLE_SPEED
        return brightness + math.sin(frame) * 0.5 + 0.5,
        brightness + math.sin(frame + 2 * math.pi / 3) * 0.5 + 0.5,
        brightness + math.sin(frame + 4 * math.pi / 3) * 0.5 + 0.5
    end

    t.RAINBOW_BRIGHTNESS = 0
    t.RAINBOW_BRIGHTNESS_NOAH = 0.2
    t.RAINBOW_CYCLE_SPEED = 0.05

    ---@param player EntityPlayer
    ---@param params TearParams
    MOD:AddCallback(ModCallbacks.MC_EVALUATE_TEAR_HIT_PARAMS, function (_, player, params)
        if not player:HasCollectible(t.ID) then return end
        local color = player:GetColor()
        params.TearColor = color
    end)

    ---@param player EntityPlayer
    function t:GetLaserColor(player)
        local color = Color.Lerp(player:GetColor(), Color.Default, 0)
        color.RO = color.R + 1
        color.GO = color.G + 1
        color.BO = color.B + 1
        color.R = 0
        color.G = 0
        color.B = 0
        return color
    end

    ---@param player EntityPlayer
    ---@param flag CacheFlag
    MOD:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, function (_, player, flag)
        if flag == CacheFlag.CACHE_TEARCOLOR then
            if not player:HasCollectible(t.ID) then return end
            player.LaserColor = t:GetLaserColor(player)
            player.TearColor = player:GetColor()
        elseif flag == CacheFlag.CACHE_COLOR then
            if not player:HasCollectible(t.ID) then return end
            local r, g, b = t:GetRainbow(player.FrameCount)
            player.Color = Color(
                -1 + r, -1 + g, -1 + b,
                player.Color.A,
                1, 1, 1
            )
        end
    end)

    ---@param entity Entity
    ---@param player EntityPlayer?
    function t:UpdateColorForFlippoinnggggEntity(entity, player)
        player = player or (entity.Parent and entity.Parent:ToPlayer())
        or (entity.SpawnerEntity and entity.SpawnerEntity:ToPlayer())
        if not player or not player:HasCollectible(t.ID) then return end
        entity.Color = t:GetLaserColor(player)
    end
    MOD:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, t.UpdateColorForFlippoinnggggEntity, EffectVariant.TECH_DOT)
    ---@param effect EntityEffect
    MOD:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, effect)
        if not effect.Parent or effect.Parent.Type ~= EntityType.ENTITY_LASER then return end
        local parent = effect:GetLastParent()
        if not parent or not parent.SpawnerEntity then return end
        local player = (parent.SpawnerEntity.Type == EntityType.ENTITY_PLAYER and parent.SpawnerEntity)
        or (parent.SpawnerEntity.SpawnerEntity and parent.SpawnerEntity.SpawnerEntity.Type == EntityType.ENTITY_PLAYER and parent.SpawnerEntity.SpawnerEntity)
        if not player or player.Type ~= EntityType.ENTITY_PLAYER then return end
        t:UpdateColorForFlippoinnggggEntity(effect, player:ToPlayer())
    end, EffectVariant.LASER_IMPACT)
    MOD:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, t.UpdateColorForFlippoinnggggEntity)

    ---@param player EntityPlayer
    function t:Update(player)
        local data = MOD:GetData(player)

        if player:HasCollectible(t.ID) then
            local r, g, b = t:GetRainbow(player.FrameCount)
            player:AddCacheFlags(CacheFlag.CACHE_TEARCOLOR | CacheFlag.CACHE_COLOR, true)
            if not data.RainbowLight or not data.RainbowLight.Ref then
                local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.LIGHT, 0, player.Position, Vector.Zero, nil):ToEffect()
                data.RainbowLight = EntityPtr(effect)
                effect:FollowParent(player)
                effect:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
            end
            if data.RainbowLight and data.RainbowLight.Ref then
                data.RainbowLight.Ref.Color = Color(
                    r, g, b,
                    4,
                    r, g, b
                )
                data.RainbowLight.Ref.SpriteScale = Vector.One
                data.RainbowLight.Ref:ToEffect().ParentOffset = Vector(3, -33 / 2 * player.SpriteScale.Y)
            end
        else
            if data.RainbowLight and data.RainbowLight.Ref then
                data.RainbowLight.Ref:Remove()
                data.RainbowLight = nil
            end
        end
    end
    MOD:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, t.Update)
    ---@param player EntityPlayer
    MOD:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function (_, player)
        if not player:IsDead() then return end
        t:Update(player)
    end)

    ---@param entity Entity
    MOD:AddCallback(ModCallbacks.MC_PRE_RENDER_ENTITY_LIGHTING, function (_, entity)
        if entity.Type ~= EntityType.ENTITY_PLAYER
        or not entity:ToPlayer():HasCollectible(t.ID) then return end
        local data = MOD:GetData(entity)
        if not data.RainbowLight then return end
        return false
    end)

    ---@param pickup EntityPickup
    MOD:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function (_, pickup)
        if pickup.SubType ~= CollectibleType.COLLECTIBLE_CONTAGION
        or MOD.GAME:GetRoom():GetBackdropType() ~= MOD.CARD_BLUE_ASBESTOS.BACKDROP then return end
        t.Vol = Options.MusicVolume
        Options.MusicVolume = math.max(0.1, Options.SFXVolume)
        Isaac.CreateTimer(function ()
            Options.MusicVolume = t.Vol
        end, 2, 1, true)
        pickup:Morph(
            EntityType.ENTITY_PICKUP,
            PickupVariant.PICKUP_COLLECTIBLE,
            t.ID,
            true,
            true,
            true
        )
        Isaac.PlayCutscene(t.CUTSCENE)
    end, PickupVariant.PICKUP_COLLECTIBLE)

    return t
end