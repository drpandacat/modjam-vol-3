---@param MOD ModReference
return function (MOD)
    local t = {}

    t.ID = Isaac.GetCurseIdByName("The Great Deluge")
    t.WTF = 1 << (t.ID - 1)
    t.RAIN_CHANCE = 0.0025
    t.RAIN_MARGIN = 10
    t.WATER_INCREASE = 0.01
    t.CRACK_CHANCE = 0.00033
    t.WATER_WAIT = 20
    t.COLORMOD = ColorModifier(
        1, 1.2, 3,
        0.15, -0.08, 0.82
    )

    t.Cursed = false

    MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, function ()
        local cursed = MOD.LEVEL:GetCurses() & t.WTF ~= 0

        -- if cursed and not t.Cursed then
            -- MOD.GAME:SetColorModifier(t.COLORMOD)
            -- print("poooop")
        -- end

        -- t.Cursed = cursed
        if not cursed then return end

        local room = MOD.GAME:GetRoom()

        for _ = 1, room:GetGridSize() do
            if math.random() < t.RAIN_CHANCE then
                Isaac.Spawn(
                    EntityType.ENTITY_EFFECT,
                    EffectVariant.RAIN_DROP,
                    0,
                    room:GetRandomPosition(t.RAIN_MARGIN),
                    Vector.Zero,
                    nil
                )
            end
            if math.random() < t.CRACK_CHANCE then
                local pos = room:GetRandomPosition(t.RAIN_MARGIN)
                if room:GetGridCollisionAtPos(pos) == GridCollisionClass.COLLISION_NONE then
                    Isaac.Spawn(
                        EntityType.ENTITY_EFFECT,
                        EffectVariant.CRACK_THE_SKY,
                        2,
                        pos,
                        Vector.Zero,
                        nil
                    )
                end
            end
        end

        if room:GetFrameCount() > t.WATER_WAIT then
            local water = room:GetWaterAmount()
            room:SetWaterAmount(math.min(water + t.WATER_INCREASE, math.max(1, water)))
        end
    end)

    MOD:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
        if MOD.LEVEL:GetCurses() & t.WTF == 0 then return end
        MOD.GAME:GetRoom():SetWaterAmount(1)
        -- MOD.GAME:SetColorModifier(t.COLORMOD, false)
    end)

    return t
end