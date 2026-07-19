---@param MOD ModReference
return function (MOD)
    local t = {}

    t.ID = Isaac.GetCardIdByName("VIII - Justice!")
    t.SPRITE = Sprite("gfx/003.202_damocles.anm2", true)
    ---@class Damocles
    t.Damocles = {
        Frame = 0,
        Anim = "Idle",
    }
    t.Damocles.__index = t.Damocles
    setmetatable(t.Damocles, {
        __call = function (self, ...)
            return setmetatable({}, self)
        end
    })
    t.BOSS_HURT_PERCENT = 0.25
    t.SEQUENTIAL_DROP_DELAY = 2
    t.FALL_CHANCE = 0.0025

    ---@param pos Vector
    ---@param frame? integer
    function t:SpawnEffect(pos, frame)
        local effect = Isaac.Spawn(
            EntityType.ENTITY_EFFECT,
            EffectVariant.SPEAR_OF_DESTINY,
            0,
            pos,
            Vector.Zero,
            nil
        )
        effect.SortingLayer = SortingLayer.SORTING_NORMAL
        effect:AddEntityFlags(EntityFlag.FLAG_NO_QUERY)
        local sprite = effect:GetSprite()
        sprite:Load("gfx/003.202_damocles.anm2", true)
        sprite:Play("Fall", true)
        if frame then
            sprite:SetFrame(frame)
        end
    end

    MOD:AddCallback(ModCallbacks.MC_USE_CARD, function ()
        local i = 0
        local spawned
        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            if entity:IsVulnerableEnemy() and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
                spawned = true
                local ptr = EntityPtr(entity)
                ---@type {Damocles: Damocles[]}
                local data = MOD:GetData(entity)
                local fall = data.Damocles and #data.Damocles
                data.Damocles = data.Damocles or {}
                data.Damocles[#data.Damocles + 1] = t.Damocles()
                Isaac.Spawn(
                    EntityType.ENTITY_EFFECT,
                    EffectVariant.POOF01,
                    0,
                    entity.Position,
                    Vector.Zero,
                    nil
                )
                if fall then
                    Isaac.CreateTimer(function ()
                        if not ptr.Ref then return end
                        if data.Damocles then
                            for ii, damocles in ipairs(data.Damocles) do
                                if ii > fall then break end
                                if damocles.Anim ~= "Fall" then
                                    damocles.Frame = 0
                                    damocles.Anim = "Fall"
                                end
                            end
                        end
                    end, i * t.SEQUENTIAL_DROP_DELAY, 1, entity:HasEntityFlags(EntityFlag.FLAG_PERSISTENT))
                    i = i + 1
                end
            end
        end
        if spawned then
            MOD.SFX:Play(286)
            MOD.SFX:Play(SoundEffect.SOUND_TOOTH_AND_NAIL)
        end
    end, t.ID)

    ---@param npc EntityNPC
    MOD:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_UPDATE, CallbackPriority.IMPORTANT, function (_, npc)
        ---@type {Damocles: Damocles[]}
        local data = MOD:GetData(npc)
        if not data.Damocles then return end
        local rng
        for i = #data.Damocles, 1, -1 do
            local v = data.Damocles[i]
            v.Frame = v.Frame + 1
            if v.Anim == "Fall" then
                if v.Frame == 15 then
                    t:SpawnEffect(npc.Position, 15)
                    table.remove(data.Damocles, i)
                    if npc:IsBoss() then
                        npc:TakeDamage(npc.MaxHitPoints * t.BOSS_HURT_PERCENT, 0, EntityRef(nil), 0)
                        if npc:HasMortalDamage() then
                            npc:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
                        end
                    else
                        npc:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
                        npc:Kill()
                    end
                    MOD.SFX:Play(SoundEffect.SOUND_MEATY_DEATHS)
                    MOD.SFX:Play(SoundEffect.SOUND_GOOATTACH0)
                end
            elseif v.Anim ~= "Idle" then
                rng = rng or Isaac.GetPlayer():GetCardRNG(t.ID)
                if rng:RandomFloat() < t.FALL_CHANCE then
                    v.Frame = 0
                    v.Anim = "Fall"
                end
            end
        end
    end)

    ---@param npc EntityNPC
    MOD:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, function (_, npc)
        ---@type {Damocles: Damocles[]}
        local data = MOD:GetData(npc)
        if not data.Damocles then return end
        local pos = Isaac.WorldToScreen(npc.Position)
        for _, v in ipairs(data.Damocles) do
            t.SPRITE:Play(v.Anim, true)
            v.Frame = v.Frame % t.SPRITE:GetCurrentAnimationData():GetLength()
            t.SPRITE:SetFrame(v.Frame)
            t.SPRITE:Render(pos)
        end
    end)

    ---@param npc EntityNPC
    MOD:AddCallback(ModCallbacks.MC_POST_NPC_MORPH, function (_, npc)
        if not npc:IsDead() then return end
        ---@type {Damocles: Damocles[]}
        local data = MOD:GetData(npc)
        data.Damocles = nil
    end)

    ---@param entity Entity
    MOD:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function (_, entity)
        ---@type {Damocles: Damocles[]}
        local data = MOD:GetData(entity)
        if not data.Damocles then return end
        for _, v in ipairs(data.Damocles) do
            if v.Anim ~= "Fall" then
                v.Frame = 0
            end
            t:SpawnEffect(entity.Position, v.Frame)
            Isaac.CreateTimer(function ()
                MOD.SFX:Play(SoundEffect.SOUND_GOOATTACH0)
            end, 15, 1, false)
        end
    end)

    ---@param entity Entity
    MOD:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, function (_, entity)
        ---@type {Damocles: Damocles[]}
        local data = MOD:GetData(entity)
        if not data.Damocles then return end
        for _, v in ipairs(data.Damocles) do
            if v.Anim == "Idle" then
                v.Anim = "Idle3"
            end
        end
    end)

    return t
end