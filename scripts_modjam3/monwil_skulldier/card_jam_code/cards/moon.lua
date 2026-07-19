local mod = HODGEPODGE

---@param entity Entity
---@param position Vector
---@param intensity number
---@param minDistance number?
local function PullTowardsPosition(entity, position, intensity, minDistance)
    local distanceSquared = entity.Position:DistanceSquared(position)
    if minDistance then
        distanceSquared = math.max(minDistance, distanceSquared)
    end
    local pull = intensity/distanceSquared
    local posDiff = position - entity.Position
    entity:AddVelocity(posDiff:Resized(math.min(pull, posDiff:Length())))
end

---@param pickup EntityPickup?
local function CreateMoonParticle(pickup)
    if not (pickup and pickup:Exists()) then
        return
    end
    local offsetDirection = RandomVector()
    local rng = RNG(math.max(1, Random()))
    local offsetDistanceModifier = rng:RandomFloat()*25
    local particle = Isaac.Spawn(
        EntityType.ENTITY_EFFECT,
        mod.EffectVariant.MOON_PARTICLE,
        0,
        pickup.Position + offsetDirection*(40 + offsetDistanceModifier) + Vector(0, -15),
        offsetDirection:Rotated(90)*2* (0.5+rng:RandomFloat()),
        pickup
    )
    local size = 0.7 + rng:RandomFloat()*0.6
    particle.SpriteScale = Vector(size, size)
    particle.Color = Color(1,1,1,0)
    particle:GetData().MoonParticleTargetVelocity = particle.Velocity:Length()
end

---@param pickup EntityPickup
local function PostCardUpdate(_, pickup)
    if pickup.SubType ~= mod.Card.MOON then
        return
    end
    local sprite = pickup:GetSprite()
    if sprite:IsEventTriggered("DropSound") then
        mod.Sfx:Stop(SoundEffect.SOUND_SCAMPER)
        mod.Sfx:Play(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND, 1, 2, false, 0.7)
        mod.Game:ShakeScreen(20)
        mod.Game:MakeShockwave(pickup.Position, 0.035, 0.025, 10)
    end

    if sprite:IsFinished("Idle") then
        local pickupPos = pickup.Position

        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            local entType = entity.Type
            if entType == EntityType.ENTITY_PLAYER then
                PullTowardsPosition(entity, pickupPos, 1000, 40^2)
            elseif entType == EntityType.ENTITY_TEAR then
                PullTowardsPosition(entity, pickupPos, 1000)
            elseif entType == EntityType.ENTITY_PROJECTILE then
                PullTowardsPosition(entity, pickupPos, 1500)
            elseif entType == EntityType.ENTITY_PICKUP then
                PullTowardsPosition(entity, pickupPos, 1500)
            elseif entType == EntityType.ENTITY_BOMB then
                PullTowardsPosition(entity, pickupPos, 1000)
            elseif entity:IsVulnerableEnemy()
                and not entity:IsBoss() then
                PullTowardsPosition(entity, pickupPos, 3000)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, PostCardUpdate, PickupVariant.PICKUP_TAROTCARD)

---@param player EntityPlayer
local function UseCard(_, _, player)
    local index = mod.Game:GetLevel():QueryRoomTypeIndex(RoomType.ROOM_SUPERSECRET, false, player:GetCardRNG(mod.Card.MOON))
    mod.Game:StartRoomTransition(index, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player)
    Isaac.CreateTimer(function ()
        mod.Sfx:Play(mod.SoundEffect.MOON_USE)
        mod.Game:Darken(0.8, 60)
        mod.Game:SetColorModifier(ColorModifier(0.3,0,0.6, 0.6), false)
    end, 1, 1, true)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, UseCard, mod.Card.MOON)

---@param pickup EntityPickup
---@param collider Entity
local function PrePickupCollision(_, pickup, collider)
    if pickup.SubType == mod.Card.MOON
    and (collider.Type == EntityType.ENTITY_PICKUP or collider.Type == EntityType.ENTITY_BOMB) then
        return true
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, PrePickupCollision, PickupVariant.PICKUP_TAROTCARD)

---@param pickup EntityPickup
local function PostCardInit(_, pickup)
    if pickup.SubType ~= mod.Card.MOON then
        return
    end
    Isaac.CreateTimer(function ()
        CreateMoonParticle(pickup)
    end, 3, 35, false)
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, PostCardInit, PickupVariant.PICKUP_TAROTCARD)


---@param effect EntityEffect
local function ParticleUpdate(_, effect)
    local targetVelocity = effect:GetData().MoonParticleTargetVelocity or effect.Velocity:Length()
    if not effect.SpawnerEntity then
        local newColor = effect.Color
        newColor.A = newColor.A - 0.01*targetVelocity
        if newColor.A <= 0 then
            effect:Remove()
            return
        end
        effect.Color = newColor
        return
    end

    local newColor = effect.Color
    newColor.A = math.min(1, newColor.A + 0.01*targetVelocity)
    effect.SpriteOffset = -effect.Velocity:Resized(60 - newColor.A*60) + Vector(0, -10)
    effect.Color = newColor

    local offset = effect.Position - effect.SpawnerEntity.Position
    effect.Velocity = offset:Rotated(90):Resized(targetVelocity) + effect.SpawnerEntity.Velocity
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, ParticleUpdate, mod.EffectVariant.MOON_PARTICLE)