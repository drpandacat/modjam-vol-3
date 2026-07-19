---@param MOD ModReference
return function (MOD)
    local t = {}

    t.ID = Isaac.GetCurseIdByName("Earthquakes in Various Places")
    t.jjjjjj = 1 << (t.ID - 1)
    t.RADIUS = 40 * 4
    t.MIN_JUMP = 7.5
    t.MAX_JUMP = 15
    t.CHANCE = 0.033

    ---@param pos Vector
    function t:RebukeTheSeaAndDryItUp(pos)
        for _, v in ipairs(Isaac.FindInRadius(
            pos,
            t.RADIUS
        )) do
            if v.Type == EntityType.ENTITY_PLAYER
            or v.Type == EntityType.ENTITY_PICKUP
            or v.Type == EntityType.ENTITY_SLOT
            or v.Type == EntityType.ENTITY_BOMB
            or v:IsEnemy() then
                if not v:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK) and JumpLib:TryJump(
                    v,
                    {
                        Height = t.MIN_JUMP + (t.MAX_JUMP - t.MIN_JUMP) * (1 - v.Position:Distance(pos) / t.RADIUS),
                        Speed = 1,
                        Tags = "OAKQUAKE",
                    }
                ) then
                    v:AddKnockback(
                        EntityRef(nil),
                        (v.Position - pos):Resized(6),
                        15,
                        false
                    )
                end
            end
        end
        MOD.GAME:ShakeScreen(5)
        local player = MOD.GAME:GetNearestPlayer(pos)
        local shockwave = Isaac.Spawn(
            EntityType.ENTITY_EFFECT,
            EffectVariant.SHOCKWAVE,
            0,
            pos,
            Vector.Zero,
            player
        ):ToEffect()
        shockwave.Parent = player
        MOD.SFX:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
        MOD.SFX:Play(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND)
    end

    MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, function ()
        if MOD.LEVEL:GetCurses() & t.jjjjjj == 0 then return end
        if math.random() < t.CHANCE then
            local room = MOD.GAME:GetRoom()
            t:RebukeTheSeaAndDryItUp(room:GetRandomPosition(20))
        end
    end)

    ---@param entity Entity
    MOD:AddCallback(JumpLib.Callbacks.ENTITY_LAND, function (_, entity)
        if entity.Type == EntityType.ENTITY_PLAYER then
            local room = MOD.GAME:GetRoom()
            local coll = room:GetGridCollisionAtPos(entity.Position)
            if coll == GridCollisionClass.COLLISION_OBJECT or coll == GridCollisionClass.COLLISION_SOLID then
                entity:TakeDamage(1, 0, EntityRef(nil), 0)
            end
        else
            if not entity:IsFlying() then
                entity:TakeDamage(10, 0, EntityRef(nil), 0)
            end
        end
        MOD.SFX:Play(SoundEffect.SOUND_FETUS_LAND)
    end, {tag = "OAKQUAKE"})

    ---@param entity Entity
    ---@param source EntityRef
    ---@param flags DamageFlag
    MOD:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function (_, entity, _, flags, source)
        if MOD.LEVEL:GetCurses() & t.jjjjjj == 0 then return end
        if source.Entity
        and GetPtrHash(source.Entity) == GetPtrHash(Isaac.GetPlayer())
        and flags & DamageFlag.DAMAGE_CRUSH ~= 0 then
            return false
        end
    end)

    return t
end