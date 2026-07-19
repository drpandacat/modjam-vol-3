---@param MOD ModReference
return function (MOD)
    local t = {}

    t.ID = Isaac.GetCardIdByName("Hexed Wild Card")
    t.EFFECT_OAKTOPUS = Isaac.GetEntityVariantByName("The Great Oak")
    t.SCARE_DUR = 30 * 2
    t.BLURSE_DELAY = 30 * 3
    t.SOUND_SUMMON = Isaac.GetSoundIdByName("Oak Summon")
    t.RARE_CHANCE = 1 / 101

    ---@type LevelCurse[]
    t.CURSES = {
        1 << (MOD.CURSE_CHARLIE.ID - 1),
        1 << (MOD.CURSE_RA.ID - 1),
        1 << (MOD.CURSE_EARTHQUAKES.ID - 1),
        1 << (MOD.CURSE_DELUGE.ID - 1),
    }

    ---@param instant? boolean
    ---@param rare? boolean
    function t:SpawnOaktopus(instant, rare)
        local room = MOD.GAME:GetRoom()
        local effect = Isaac.Spawn(
            EntityType.ENTITY_EFFECT,
            t.EFFECT_OAKTOPUS,
            rare and 1 or 0,
            room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0),
            Vector.Zero,
            nil
        )
        if instant then
            effect:GetSprite():SetLastFrame()
        else
            MOD.SFX:Play(t.SOUND_SUMMON, nil, nil, nil, 1)
            MOD.SFX:Play(SoundEffect.SOUND_THUNDER)
        end
        effect:Update()
        return effect
    end

    ---@param player EntityPlayer
    MOD:AddCallback(ModCallbacks.MC_USE_CARD, function (_, _, player)
        local save = EntitySaveStateManager.GetEntityData(MOD, MOD:GetGlobalPlayer())
        local rng = player:GetCardRNG(t.ID)
        local rare = rng:RandomFloat() < t.RARE_CHANCE

        if rare then
            save.RareOaktopus = (save.RareOaktopus or 0) + 1
        else
            save.Oaktopus = (save.Oaktopus or 0) + 1
        end

        local effect = t:SpawnOaktopus(nil, rare)

        MOD.GAME:Darken(1, t.SCARE_DUR)
        MOD.GAME:ShakeScreen(t.SCARE_DUR)

        Isaac.CreateTimer(function ()
            local curses = MOD:Filter(t.CURSES, function (v)
                return MOD.LEVEL:GetCurses() & v == 0
            end)
            if #curses == 0 then return end
            local curse = curses[rng:RandomInt(1, #curses)]
            MOD.LEVEL:AddCurse(curse, false)
            local entry = XMLData.GetEntryById(XMLNode.CURSE, curse)
            if entry and entry.name then
                MOD.HUD:ShowItemText(entry.name)
            end
        end, t.BLURSE_DELAY, 1, true)

        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 3, effect.Position, Vector.Zero, nil)
    end, t.ID)

    ---@param effect EntityEffect
    MOD:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function (_, effect)
        local sprite = effect:GetSprite()
        local data = MOD:GetData(effect)
        data.OakEyes = Sprite("gfx/effect_oaktopus.anm2", true)
        data.OakEyes:Play("pup", true)
        effect.TargetPosition = effect.Position
        effect:AddEntityFlags(EntityFlag.FLAG_DONT_OVERWRITE)
    end, t.EFFECT_OAKTOPUS)

    ---@param effect EntityEffect
    MOD:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, effect)
        local sprite = effect:GetSprite()
        if sprite:IsFinished("Spawn") then
            sprite:Play("Stand", true)
        end
        local room = MOD.GAME:GetRoom()
        room:SetGridPath(room:GetGridIndex(effect.Position), 900)
        effect.Velocity = (effect.TargetPosition - effect.Position) * 0.8
    end, t.EFFECT_OAKTOPUS)

    ---@param effect EntityEffect
    MOD:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, function (_, effect)
        ---@type {OakEyes: Sprite}
        local data = MOD:GetData(effect)
        if data.OakEyes then
            local pos = Isaac.WorldToScreen(effect.Position + effect:GetNullOffset("pup"))
            local player = MOD.GAME:GetNearestPlayer(effect.Position)
            data.OakEyes:Render(pos + Vector(3, 37) + (player.Position - effect.Position):Resized(1))
        end
    end, t.EFFECT_OAKTOPUS)

    MOD:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
        local save = EntitySaveStateManager.GetEntityData(MOD, MOD:GetGlobalPlayer())

        if save.Oaktopus then
            for _ = 1, save.Oaktopus do
                t:SpawnOaktopus(true)
            end
        end
        if save.RareOaktopus then
            for _ = 1, save.RareOaktopus do
                t:SpawnOaktopus(true, true)
            end
        end
    end)

    MOD:AddCallback(ModCallbacks.MC_PRE_LEVEL_INIT, function ()
        local data = EntitySaveStateManager.GetEntityData(MOD, MOD:GetGlobalPlayer())
        data.Oaktopus = nil
        data.RareOaktopus = nil
    end)

    return t
end