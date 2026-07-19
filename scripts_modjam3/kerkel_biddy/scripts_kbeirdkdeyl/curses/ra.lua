---@param MOD ModReference
return function (MOD)
    local t = {}

    t.ID = Isaac.GetCurseIdByName("Blurse of Ra")
    t.getcurseidbynameisdumb = 1 << (t.ID - 1)
    t.EFFECT_DEATHS = Isaac.GetEntityVariantByName("Sandy Death's Head")
    t.COLOR_EMBER = Color(
        0, 0, 0,
        1,
        193 / 255, 178 / 255, 131 / 255
    )
    t.COLOR_EMBER_B = Color(
        0, 0, 0,
        0,
        193 / 255, 178 / 255, 131 / 255
    )

    function t:GetWindDirection()
        local player = MOD:GetGlobalPlayer()
        local save = EntitySaveStateManager.GetEntityData(MOD, player)
        if not save.WindDirection then
            local rng = player:GetCardRNG(MOD.CARD_WILD.ID)
            save.WindDirection = rng:RandomInt(1, 2) == 1 and -1 or 1
        end
        return save.WindDirection
    end

    t.Cursed = MOD.LEVEL:GetCurses() & t.getcurseidbynameisdumb ~= 0

    MOD:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function ()
        t.Cursed = MOD.LEVEL:GetCurses() & t.getcurseidbynameisdumb ~= 0
    end)

    MOD:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function ()
        t.Cursed = false
    end)

    MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, function ()
        local cursed = MOD.LEVEL:GetCurses() & t.getcurseidbynameisdumb ~= 0

        if cursed and not t.Cursed then
            MOD.GAME:SetColorModifier(
                ColorModifier(0.5, 0.4, 0.2, 0.4, 0.05, 1),
                true
            )
            EntitySaveStateManager.GetEntityData(MOD, MOD:GetGlobalPlayer()).WindDirection = nil
        end

        t.Cursed = cursed

        if not cursed then return end

        local room = MOD.GAME:GetRoom()
        local dir = t:GetWindDirection()
        local width = room:GetGridWidth() * 40
        local height = room:GetGridHeight()

        for _ = 1, 3 do
            local ember = Isaac.Spawn(
                EntityType.ENTITY_EFFECT,
                EffectVariant.EMBER_PARTICLE,
                0,
                Vector(width / 2 + width * (math.random() - 0.5) * 2, height * 40 * math.random()),
                Vector(dir, 1) * (2 + math.random() * 3) * 1.5,
                nil
            ):ToEffect()
            ember.State = 1
            ember.Color = t.COLOR_EMBER
            ember:AddEntityFlags(EntityFlag.FLAG_NO_QUERY)
            ember:SetColor(t.COLOR_EMBER_B, 15, 99, true, false)
            local ptr = EntityPtr(ember)
            Isaac.CreateTimer(function ()
                if not ptr.Ref or not ptr.Ref:Exists() then return end
                ember:SetColor(t.COLOR_EMBER, 30, 100, true, false)
                ember.Color = t.COLOR_EMBER_B
                local pos = ember.Position
                local vel = ember.Velocity
                ember:Update()
                ember.Position = pos
                ember.Velocity = vel
            end, 30, 1, false)
            Isaac.CreateTimer(function ()
                if not ptr.Ref or not ptr.Ref:Exists() then return end
                ember:Remove()
            end, 60, 1, false)
        end
        for _, v in ipairs(Isaac.GetRoomEntities()) do
            if v.Type == EntityType.ENTITY_PLAYER
            or v:ToNPC()
            or v.Type == EntityType.ENTITY_TEAR
            or v.Type == EntityType.ENTITY_PROJECTILE
            or v.Type == EntityType.ENTITY_PICKUP
            or v.Type == EntityType.ENTITY_BOMB then
                v.Velocity = v.Velocity + Vector(dir * 0.03, 0)
            end
        end
        if math.random() < 0.02 then
            local pos = room:GetRandomPosition(0)
            local deaths = Isaac.Spawn(
                EntityType.ENTITY_EFFECT,
                t.EFFECT_DEATHS,
                0,
                Vector((dir == -1 and 1 or 0) * width + dir * -40, pos.Y),
                Vector.Zero,
                nil
            )
            deaths:SetColor(Color(1, 1, 1, 0), 15, 99, true, false)
            deaths:Update()
        end
    end)

    MOD:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
        if MOD.LEVEL:GetCurses() & t.getcurseidbynameisdumb == 0 then return end
        MOD.GAME:SetColorModifier(
            ColorModifier(0.5, 0.4, 0.2, 0.4, 0.05, 1),
            false
        )
        EntitySaveStateManager.GetEntityData(MOD, MOD:GetGlobalPlayer()).WindDirection = nil
    end)

    ---@param effect EntityEffect
    MOD:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, effect)
        local rng = RNG(effect.InitSeed)
        effect.Velocity = Vector(
            t:GetWindDirection() * 3,
            math.sin(effect.FrameCount * 0.05) * rng:RandomFloat() * 3
        )
        effect.FlipX = effect.Velocity.X > 0
        local sprite = effect:GetSprite()
        sprite.PlaybackSpeed = 0.8
        local room = MOD.GAME:GetRoom()
        if not room:IsPositionInRoom(Vector(effect.Position.X, MOD.GAME:GetRoom():GetGridHeight() / 2 * 40), 0)
        and not room:GetCamera():IsPosVisible(effect.Position - Vector(effect.Velocity.X * 50, 0))
        and effect.FrameCount > 30 * 2 then
            effect:Remove()
        end
        for _, v in ipairs(Isaac.FindInCapsule(effect:GetCollisionCapsule())) do
            if v.Type == EntityType.ENTITY_PLAYER then
                v:TakeDamage(1, 0, EntityRef(effect), 0)
            elseif v:IsVulnerableEnemy() then
                v:TakeDamage(5, DamageFlag.DAMAGE_COUNTDOWN, EntityRef(effect), 4)
            end
        end
    end, t.EFFECT_DEATHS)

    return t
end