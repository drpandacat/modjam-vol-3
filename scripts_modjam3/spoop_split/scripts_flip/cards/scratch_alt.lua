local CARD_SPEED = 15
local CARD_DAMAGE = 10

---@param id Card
---@param player EntityPlayer
---@param flags UseFlag
local function useCard(_, id, player, flags)
    local rotation = 90
    if(player:GetAimDirection():Length()>0.01) then
        rotation = player:GetAimDirection():GetAngleDegrees()
    elseif(player:GetMovementJoystick():Length()>0.01) then
        rotation = player:GetMovementJoystick():GetAngleDegrees()
    elseif(player.Velocity:Length()>0.5) then
        rotation = player.Velocity:GetAngleDegrees()
    end

    local vec = Vector.FromAngle(rotation):Resized(CARD_SPEED)
    local tear = Isaac.Spawn(EntityType.ENTITY_TEAR,CardjamFlipCards.TEAR_SCRATCH_ALT,0,player.Position,vec,player)
    if(vec.X<0) then
        tear.FlipX = true
    end

    CardjamFlipCards.SFX:Play(SoundEffect.SOUND_TOOTH_AND_NAIL, 0.6,nil,nil,1.2)

    CardjamFlipCards:playAnnouncerVoice(CardjamFlipCards.SFX_VOICE_SCRATCH_2, flags)
end
CardjamFlipCards:AddCallback(ModCallbacks.MC_USE_CARD, useCard, CardjamFlipCards.CARD_SCRATCH_ALT)

---@param tear EntityTear
local function tearInit(_, tear)
    tear.CollisionDamage = CARD_DAMAGE

    tear:GetSprite():Play("Rotate", true)

    tear:AddTearFlags(TearFlags.TEAR_PIERCING)
end
CardjamFlipCards:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, tearInit, CardjamFlipCards.TEAR_SCRATCH_ALT)

---@param tear EntityTear
local function tearUpdate(_, tear)
    tear:ResetSpriteScale(true)
    tear.SpriteScale = Vector(1,1)
    tear.Scale = 1
end
CardjamFlipCards:AddCallback(ModCallbacks.MC_PRE_TEAR_UPDATE, tearUpdate, CardjamFlipCards.TEAR_SCRATCH_ALT)

---@param tear EntityTear
local function tearDeath(_, tear)
    local impact = Isaac.Spawn(1000,97,0,tear.Position,Vector.Zero,nil)

    for _=1,3 do
        local vel = RandomVector()
        local gib = Isaac.Spawn(1000,86,0,tear.Position,vel*2,nil)
    end

    CardjamFlipCards.SFX:Play(SoundEffect.SOUND_POT_BREAK, 0.3, nil, nil, 1.2)
end
CardjamFlipCards:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, tearDeath, CardjamFlipCards.TEAR_SCRATCH_ALT)

---@param ent Entity
---@param source EntityRef
local function postScratchDamage(_, ent, _, _, source)
    if(source.Type==EntityType.ENTITY_TEAR and source.Variant==CardjamFlipCards.TEAR_SCRATCH_ALT) then
        if(ent and ent:ToNPC() and ent:IsActiveEnemy(false) and ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
            ent:SetBossStatusEffectCooldown(0)
            ent:AddBleeding(EntityRef(source.Entity and source.Entity.SpawnerEntity), 30*3)
            CardjamFlipCards:getData(ent).PERMA_BLEED = true
        end
    end
end
CardjamFlipCards:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, postScratchDamage)

---@param npc EntityNPC
local function scratchBleedUpdate(_, npc)
    if(CardjamFlipCards:getData(npc).PERMA_BLEED) then
        npc:SetBleedingCountdown(30*3)
    end
end
CardjamFlipCards:AddCallback(ModCallbacks.MC_NPC_UPDATE, scratchBleedUpdate)