local BASE_HP = 15

---@param entity Entity
local function isValidEnemy(entity)
    local npc = entity:ToNPC()
    return npc and (npc:IsEnemy() and npc:IsActiveEnemy() and npc:IsVulnerableEnemy() and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY))
end

---@param id Card
---@param player EntityPlayer
---@param flags UseFlag
local function useCard(_, id, player, flags)
    local enemyPicker = WeightedOutcomePicker()
    local validEnemies = {}

    local numEnemies = 0

    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        if(isValidEnemy(ent) and not ent:IsBoss()) then
            numEnemies = numEnemies+1

            table.insert(validEnemies, ent)
            enemyPicker:AddOutcomeFloat(numEnemies, ent.MaxHitPoints/BASE_HP)
        end
    end

    if(numEnemies>0) then
        local idx = enemyPicker:PickOutcome(player:GetCardRNG(CardjamFlipCards.CARD_CHARM_ALT))
        local npc = validEnemies[idx]:ToNPC() ---@cast npc EntityNPC
        npc:AddCharmed(EntityRef(player), -1)
        npc:MakeChampion(Random(), ChampionColor.GIANT, false)
        CardjamFlipCards:getData(npc).CHARMED = true

        local poof1 = Isaac.Spawn(1000, EffectVariant.POOF02, 0, npc.Position, Vector.Zero, nil):ToEffect()
        if(poof1) then
            poof1:GetSprite().PlaybackSpeed = 1.5
            poof1.SpriteScale = Vector(1,1)*0.8
            poof1.Color = Color(0,0,0,0.7,208/255,170/255,192/255)
            poof1.DepthOffset = -1000
        end

        local poof2 = Isaac.Spawn(1000, EffectVariant.POOF02, 0, player.Position, Vector.Zero, nil):ToEffect()
        if(poof2) then
            poof2:GetSprite().PlaybackSpeed = 1.3
            poof2.Color = Color(0,0,0,0.7,208/255,170/255,192/255)
            poof2.DepthOffset = -1000
        end

        CardjamFlipCards.SFX:Play(SoundEffect.SOUND_KISS_LIPS1)
    end

    CardjamFlipCards:playAnnouncerVoice(CardjamFlipCards.SFX_VOICE_CHARM_2, flags)
end
CardjamFlipCards:AddCallback(ModCallbacks.MC_USE_CARD, useCard, CardjamFlipCards.CARD_CHARM_ALT)