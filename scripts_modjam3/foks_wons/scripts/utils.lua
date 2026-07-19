local mod = _MODJAM_CARDS
local game = Game()
local sfx = SFXManager()

----------------
-- << MATH >> --
----------------
function mod.MakeEven(num, down)
	local remainder = num % 2
	
	return down and num - remainder or num + remainder
end

---------------
-- << RNG >> --
---------------
function mod.RNG(seed, shiftId)
	return RNG(math.max(seed or Random(), 1), shiftId)
end

function mod.RandomIntRange(minimum, maximum, seed, rng)
	return (rng or mod.RNG(seed)):RandomInt(minimum, maximum)
end

function mod.RandomFloatRange(minimum, maximum, seed, rng)
	return minimum + (rng or mod.RNG(seed)):RandomFloat() * (maximum - minimum)
end

-----------------
-- << ISAAC >> --
-----------------
function mod.Spawn(type, variant, subtype, position, velocity, spawner, seed)
	return game:Spawn(type, variant, position, velocity or Vector.Zero, spawner, subtype, math.max(seed or Random(), 1))
end

function mod.SpawnPickup(variant, subtype, position, velocity, spawner, timeout, delay, touched, quickAppear)
	local pickupVel = velocity
	
	if type(velocity) == "number" then pickupVel = EntityPickup.GetRandomPickupVelocity(position) * velocity end
	local pickup = mod.Spawn(EntityType.ENTITY_PICKUP, variant, subtype, position, pickupVel, spawner):ToPickup()
	local pickupSpr = pickup:GetSprite()
	
	if quickAppear and pickupSpr:GetAnimationData("AppearFast") then pickupSpr:Play("AppearFast") end
	if timeout then pickup.Timeout = timeout end
	if delay then pickup:SetDropDelay(delay) end
	if touched then pickup.Touched = touched end
	
	return pickup
end

------------------
-- << ENTITY >> --
------------------
function mod.GetEntityData(entity) -- To mitigate issues with other mods
	if not entity then return end
	local entityData = entity:GetData()
	
	entityData[mod.Name] = entityData[mod.Name] or {}
	
	return entityData[mod.Name]
end

function mod.MakeBloodSplat(entity, position, scale, color, offset)
	local effect = mod.Spawn(
		EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, 
		position or entity.Position, nil, entity):ToEffect()
	
	if scale then effect.SpriteScale = scale * Vector.One end
	if color then effect.Color = color end
	if offset then effect.PositionOffset = offset end
	effect:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR | EntityFlag.FLAG_RENDER_WALL)
	effect:Update()
	
	return effect
end
