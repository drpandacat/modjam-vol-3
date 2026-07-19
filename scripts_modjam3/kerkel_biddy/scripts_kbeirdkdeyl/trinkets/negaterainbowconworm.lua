---@param MOD ModReference
return function (MOD)
    local t = {}

    t.ID = Isaac.GetTrinketIdByName("Negate Rainbow ConWorm")
    t.HUD_SPRITE = Sprite("gfx/ui_asbestos.anm2", true)
    t.HUD_SPRITE:Play("Idle", true)
    t.STAT = FoundHUDHelper:Register(MOD, t.HUD_SPRITE)
    t.STAT.Visible = true
    t.EFFECT = Isaac.GetEntityVariantByName("Only Known Image of This Level")
    t.CUTSCENE = Isaac.GetCutsceneIdByName("CONSCARE")

    function t:Init()
        t.CONWORM = Isaac.GetTrinketIdByName("ConWorm")

        if t.CONWORM ~= -1 then
            ---@param pickup EntityPickup
            MOD:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function (_, pickup)
                if pickup.SubType ~= t.CONWORM
                or MOD.GAME:GetRoom():GetBackdropType() ~= MOD.CARD_BLUE_ASBESTOS.BACKDROP then return end
                t.Vol = Options.MusicVolume
                Options.MusicVolume = math.max(0.1, Options.SFXVolume)
                Isaac.CreateTimer(function ()
                    Options.MusicVolume = t.Vol
                end, 2, 1, true)
                pickup:Morph(
                    EntityType.ENTITY_PICKUP,
                    PickupVariant.PICKUP_TRINKET,
                    t.ID,
                    true,
                    true,
                    true
                )
                Isaac.PlayCutscene(MOD.COLLECTIBLE_NEGATE_RAINBOW_CONTAGION.CUTSCENE)
            end, PickupVariant.PICKUP_TRINKET)
        end
    end

    -- MOD:AddCallback(ModCallbacks.MC_HUD_RENDER, function ()
    --     for i = 0, 30 do
    --         t.HUD_SPRITE:Render(FoundHUDHelper:GetElementPosition(i))
    --     end
    --     if Input.IsActionPressed(ButtonAction.ACTION_DROP, -1) then
    --         for i = 0, 30 do -- its wrong but idc
    --             FoundHUDHelper:DisplayStatChange(i, "Hey", KColor(i * 0.1, 1 - i * 0.1, 1, 1), nil, nil, nil, nil, true)
    --             FoundHUDHelper:DisplayStatChange(i, "Hey", KColor(i * 0.1, 1 - i * 0.1, 1, 1), nil, nil, nil, nil, false)
    --         end
    --     end
    -- end) -- also when changing hud offset the popups dont shift Fix that ok kerkel?

    ---@param id? string
    function t:RemoveStatChanges(id)
        for statChangeIndex = #FoundHUDHelper.StatChanges, 1, -1 do
            local v = FoundHUDHelper.StatChanges[statChangeIndex]
            if (not id and (v.Identifier == "ASBESTOS" or v.Identifier == "ASBESTOS1" or v.Identifier == "ASBESTOS2"))
            or v.Identifier == id then
                table.remove(FoundHUDHelper.StatChanges, statChangeIndex)
            end
        end
    end

    ---@param val number
    ---@param i? integer
    ---@param instant? integer
    function t:SetStat(val, i, instant)
        local prev = tonumber((not i or i == 1) and t.STAT.PrimaryText or t.STAT.SecondaryText)
        local str = string.format("%.2f", val)
        if not i or i == 1 then
            t.STAT.PrimaryText = str
        else
            t.STAT.SecondaryText = str
        end
        if not prev or prev == val then return end
        local id = i and ("ASBESTOS" .. i) or "ASBESTOS"
        t:RemoveStatChanges(id)
        local pos = val > prev
        local primary
        if i then
            primary = i == 1
        end
        if instant then return end
        FoundHUDHelper:DisplayStatChange(
            FoundHUDHelper:GetIndex(t.STAT),
            (pos and "+" or "") .. string.format("%.2f", val - prev),
            val > prev and FoundHUDHelper.COLOR_STAT_CHANGE_POSITIVE or FoundHUDHelper.COLOR_STAT_CHANGE_NEGATIVE,
            nil,
            id,
            nil,
            nil,
            primary
        )
    end

    ---@param instant? boolean
    function t:UpdateStats(instant)
        ---@type EntityPlayer
        local players = HudHelper.GetHUDPlayers()
        if #players == 0 then
            HudHelper.PopulateHUDPlayers()
            players = HudHelper.GetHUDPlayers()
        end
        if #players == 1 then
            t.STAT.SecondaryText = nil
        end
        local any
        t.STAT.Visible = true
        for playerIndex, player in ipairs(players) do
            local val = player:GetCustomCacheValue("asbestos")
            any = any or val > 0
            t:SetStat(val, #players > 1 and playerIndex, instant)
            if playerIndex == 2 then break end
        end
        if not any then
            t:RemoveStatChanges()
            t.STAT.Visible = false
        end
    end

    t:UpdateStats(true)

    ---@param player EntityPlayer
    ---@param value number
    MOD:AddCallback(ModCallbacks.MC_EVALUATE_CUSTOM_CACHE, function (_, player, _, value)
        Isaac.CreateTimer(t.UpdateStats, 1, 1, true)
        return value + player:GetTrinketMultiplier(t.ID) * 0.39
    end, "asbestos")

    ---@param player EntityPlayer
    MOD:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function (_, player)
        if not player:HasTrinket(t.ID) then return end
        player.TearFlags = player.TearFlags | TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_PIERCING
    end, CacheFlag.CACHE_TEARFLAG)

    ---@param entity EntityTear | EntityBomb
    function t:EntityInit(entity)
        local player = entity.SpawnerEntity and entity.SpawnerEntity:ToPlayer()
        if not player or not player:HasTrinket(t.ID) then return end

        local effect = Isaac.Spawn(
            EntityType.ENTITY_EFFECT,
            t.EFFECT,
            0,
            entity.Position,
            Vector.Zero,
            entity
        )
        local color = Color.Lerp(entity.Color, Color.Default, 0)
        color.A = 0
        effect.Color = color
        if entity.Scale then
            effect.SpriteScale = effect.SpriteScale * entity.Scale --* Vector(entity.Velocity:Length() * 0.2, 1)
        end
        effect.PositionOffset = entity.PositionOffset * 0.8
        effect.SpriteRotation = entity.Velocity:GetAngleDegrees()
        local data = MOD:GetData(entity)
        data.Halls = EntityPtr(effect)
        data.Positions = {}
        for _, v in ipairs(t.POSITIONS) do
            local pos = effect.Position + v:Rotated(effect.SpriteRotation) * effect.SpriteScale --[[+ effect.PositionOffset]]
            data.Positions[#data.Positions + 1] = pos
        end
    end
    MOD:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, t.EntityInit)
    MOD:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB, t.EntityInit)

    ---@param entity EntityTear | EntityBomb
    function t:EntityUpdate(entity)
        ---@type {Halls: EntityPtr?, Positions: Vector[], Dist: number, NextDist: number, LastPos: Vector}
        local data = MOD:GetData(entity)
        if not data.Positions then return end
        local effect = data.Halls and data.Halls.Ref and data.Halls.Ref:ToEffect()
        if not effect then
            data.Halls = nil
        end

        data.NextDist = data.NextDist or entity.Position:Distance(data.Positions[1])

        if data.LastPos then
            data.Dist = (data.Dist or 0) + entity.Position:Distance(data.LastPos)
        end

        local aim = false

        if entity.Type == EntityType.ENTITY_TEAR then
            entity.FallingAcceleration = -0.1
            entity.FallingSpeed = 0
        -- elseif entity.Type == EntityType.ENTITY_BOMB then
        --     entity:SetExplosionCountdown(2)
        end

        if data.Dist then
            if data.Dist > data.NextDist then
                data.NextDist = nil
                table.remove(data.Positions, 1)
                data.Dist = 0
                aim = true
                if #data.Positions == 0 then
                    if entity.Type == EntityType.ENTITY_BOMB then
                        entity:SetExplosionCountdown(0)
                        data.Positions = nil
                    else
                        entity:Die()
                    end
                    return
                end
            end
        else
            aim = true
        end

        if aim then
            entity.Velocity = (data.Positions[1] - entity.Position):Resized(entity.Velocity:Length())
        end

        data.LastPos = entity.Position
    end
    ---@param tear EntityTear
    MOD:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function (_, tear)
        t:EntityUpdate(tear)
    end)
    ---@param bomb EntityBomb
    MOD:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, function (_, bomb)
        if not bomb.IsFetus then return end
        t:EntityUpdate(bomb)
    end)

    ---@type Vector[]
    t.POSITIONS = {
        Vector(30, 5) / 0.2,
        Vector(34, -118) / 0.2,
        Vector(126, -118) / 0.2,
        Vector(117, 12) / 0.2,
        Vector(197, 19) / 0.2,
    }

    ---@param effect EntityEffect
    MOD:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, effect)
        if effect.SpawnerEntity and effect.SpawnerEntity:Exists() then
            local color = Color.Lerp(effect.Color, Color.Default, 0)
            color.A = 0.5
            effect.Color = Color.Lerp(effect.Color, color, 0.2)
        else
            local color = Color.Lerp(effect.Color, Color.Default, 0)
            color.A = 0
            effect.Color = Color.Lerp(effect.Color, color, 0.1)
            if effect.Color.A < 0.01 then
                effect:Remove()
            end
        end
        -- for _, v in ipairs(t.POSITIONS) do
        --     Isaac.Spawn(
        --         EntityType.ENTITY_EFFECT,
        --         EffectVariant.HEART,
        --         0,
        --         effect.Position + v:Rotated(effect.SpriteRotation) * effect.SpriteScale + effect.PositionOffset,
        --         Vector.Zero,
        --         nil
        --     ).SpriteScale = Vector.One * 0.2
        -- end
    end, t.EFFECT)

    ---@param effect EntityEffect
    MOD:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function (_, effect)
        effect.SpriteScale = Vector.One * 0.2
        effect.DepthOffset = -500
        local color = Color.Lerp(effect.Color, Color.Default, 0)
        color.A = 0
        effect.Color = color
    end, t.EFFECT)

    t.Vol = Options.MusicVolume

    t.JUMP_CHANCE_PER_SECOND = 1 -- Out of 100
    t.JUMP_CHANCE_PER_SECOND = 1 - (1 - t.JUMP_CHANCE_PER_SECOND / 100) ^ (1 / 30)
    -- print(t.JUMP_CHANCE_PER_SECOND * 100)
    MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, function ()
        if math.random() > t.JUMP_CHANCE_PER_SECOND
        or not PlayerManager.AnyoneHasTrinket(t.ID) then return end
        t.Vol = Options.MusicVolume
        Options.MusicVolume = 1
        Isaac.CreateTimer(function ()
            Options.MusicVolume = t.Vol
        end, 2, 1, true)
        Isaac.PlayCutscene(t.CUTSCENE)
    end)

    return t
end