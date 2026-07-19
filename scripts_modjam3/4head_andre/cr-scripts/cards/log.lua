-- Author: 4Head (ConJam Submission)
-- log.lua
-- 7/13/26
-- Logic for the Log data.

---@class LogThrowData
---@field Height number
---@field VerticalVelocity number
---@field ThrowVelocity Vector
---@field Bounces integer
---@field MaxBounces integer
---@field Damping number
---@field HitEntities table<integer, boolean>

local this = {}

local THROW_SPEED = 9
local LIFETIME_FRAMES = 123
local HOP_VELOCITY = 7
local GRAVITY = 0.6
local BOUNCE_DAMPING_MIN = 0.45
local BOUNCE_DAMPING_MAX = 0.75
local MIN_BOUNCES = 2
local MAX_BOUNCES = 6
local MIN_BOUNCE_SPEED = 1.0
local GRID_CLEAR_HEIGHT = 12
local RENDER_DEPTH_OFFSET = 100
local DAMAGE_MULTIPLIER = 1.5
local KNOCKBACK_STRENGTH = 12
local FREEZE_DURATION = 15

local DUST_RING_PARAMS = {
	scale_min = 0.2,
	scale_max = 1,
	speed_min = 3,
	speed_max = 7,
	lifetime_min = 20,
	lifetime_max = 40,
	color = Color(1, 1, 1, 0.4)
}

local cardSprite = Sprite("gfx/card_log.anm2", true)
cardSprite:Play("Idle", true)

---@type table<integer, boolean>
local playersHoldingLog = {}

---@param player EntityPlayer
local function RestoreLogCard(player)
	for slot = 0, player:GetMaxPocketItems() - 1 do
		if player:GetCard(slot) == Card.CARD_NULL and player:GetPill(slot) == PillColor.PILL_NULL then
			player:SetCard(slot, ClashRoyaleCards.Enums.Card.LOG)
			return
		end
	end

	local freePos = Isaac.GetFreeNearPosition(player.Position, 40)
	player:DropPocketItem(PillCardSlot.PRIMARY, freePos)
	player:SetCard(PillCardSlot.PRIMARY, ClashRoyaleCards.Enums.Card.LOG)
end

---@param effect EntityEffect
---@return LogThrowData
local function GetLogThrowData(effect)
	local data = effect:GetData()

	if not data.LogThrowData then
		local rng = RNG(effect.InitSeed, 35)

		data.LogThrowData = {
			Height = 0,
			VerticalVelocity = HOP_VELOCITY,
			ThrowVelocity = Vector.Zero,
			Bounces = 0,
			MaxBounces = rng:RandomInt(MIN_BOUNCES, MAX_BOUNCES),
			Damping = BOUNCE_DAMPING_MIN + rng:RandomFloat() * (BOUNCE_DAMPING_MAX - BOUNCE_DAMPING_MIN),
			HitEntities = {},
		}
	end

	return data.LogThrowData
end

---@param positions Vector[]
local function TryBreakGrids(positions)
	local room = Game():GetRoom()

	for _, position in ipairs(positions) do
		local gridEntity = room:GetGridEntityFromPos(position)

		if gridEntity then
			gridEntity:Destroy(false)
		end
	end
end

--- Because logs are wide, we need three tiles in total for accurate grid collision detection.
---@param position Vector
---@param direction Vector
local function GetLogPositions(position, direction)
	return {
		position,
		position + Vector(-direction.Y, direction.X):Resized(40),
		position - Vector(-direction.Y, direction.X):Resized(40),
	}
end

---@param positions Vector[]
---@param height number
local function HitDeadEnd(positions, height)
	local room = Game():GetRoom()
	local pitCount = 0

	for _, position in ipairs(positions) do
		local gridEnt = room:GetGridEntityFromPos(position)
		local hasPitCollision = gridEnt ~= nil and gridEnt.CollisionClass == GridCollisionClass.COLLISION_PIT 

		if gridEnt and 
			(gridEnt.CollisionClass == GridCollisionClass.COLLISION_WALL
				or gridEnt.CollisionClass == GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER
			)
		then
			return true
		end


		if gridEnt and height < GRID_CLEAR_HEIGHT then
			if not gridEnt:IsBreakableRock() and not hasPitCollision then
				return true
			end

			if hasPitCollision then
				pitCount = pitCount + 1
			end
		end
	end

	return pitCount == #positions
end

---@param effect EntityEffect
---@param data LogThrowData
local function DamageEnemies(effect, data)
	local capsule = effect:GetNullCapsule("Hitbox")
	local source = EntityRef(effect)
	local velocity = effect.Velocity:Resized(KNOCKBACK_STRENGTH)

	---@type EntityPartition
	---@diagnostic disable-next-line: assign-type-mismatch
	local partitions = EntityPartition.ENEMY | EntityPartition.BULLET | EntityPartition.PICKUP

	for _, entity in ipairs(Isaac.FindInCapsule(capsule, partitions)) do
		entity:AddKnockback(source, velocity, 5, false)
		entity:ForceCollide(effect, false)

		if entity:IsVulnerableEnemy() then
			entity:TakeDamage(effect.CollisionDamage, DamageFlag.DAMAGE_COUNTDOWN, source, 2)

			local hash = GetPtrHash(entity)

			if not data.HitEntities[hash] then
				data.HitEntities[hash] = true
				entity:AddFreeze(source, FREEZE_DURATION)
			end
		end
	end
end

---@param effect EntityEffect
local function DestroyLog(effect)
	ClashRoyaleCards.SFXMan:Stop(ClashRoyaleCards.Enums.SoundEffect.LOG_ROLL)
	ClashRoyaleCards.SFXMan:Play(ClashRoyaleCards.Enums.SoundEffect.LOG_DESTROY)

	Game():SpawnParticles(effect.Position, EffectVariant.WOOD_PARTICLE, 25, 5)
	ClashRoyaleCards:SpawnDustRing(effect.Position, effect, 20, DUST_RING_PARAMS)

	effect:Remove()
end

---@param _card Card
---@param player EntityPlayer
local function UseCardLog(_, _card, player)
	player:SetItemState(ClashRoyaleCards.Enums.NullItem.LOG_CARD)
	playersHoldingLog[GetPtrHash(player)] = true
	player:AnimateCard(ClashRoyaleCards.Enums.Card.LOG, "LiftItem")
	ClashRoyaleCards.SFXMan:Play(ClashRoyaleCards.Enums.SoundEffect.CARD_USE)
end

---@param player EntityPlayer
local function PostPlayerUpdate(_, player)
	local hash = GetPtrHash(player)

	if player:GetItemState() ~= ClashRoyaleCards.Enums.NullItem.LOG_CARD then
		if playersHoldingLog[hash] then
			playersHoldingLog[hash] = nil
			player:AnimateCard(ClashRoyaleCards.Enums.Card.LOG, "HideItem")
			RestoreLogCard(player)
		end

		return
	end

	local aim = player:GetAimDirection()

	if aim:Length() <= .1 then
		return
	end

	local direction = Isaac.GetAxisAlignedUnitVectorFromDir(player:GetFireDirection())
	local logPositions = GetLogPositions(player.Position, direction)

	-- Makes sure the log just doesn't break immediately on throw, cuz that'd be bullshit!
	if HitDeadEnd(logPositions, 0) then
		return
	end

	player:AnimateCard(ClashRoyaleCards.Enums.Card.LOG, "HideItem")

	local velocity = direction:Resized(THROW_SPEED)

	local effect = Isaac.Spawn(
		EntityType.ENTITY_EFFECT,
		ClashRoyaleCards.Enums.EffectVariant.LOG,
		0,
		player.Position,
		velocity,
		player
	):ToEffect()

	if effect then
		effect:GetSprite():Play("log", false)
		effect.SpriteRotation = direction:GetAngleDegrees() + 90
		effect.DepthOffset = RENDER_DEPTH_OFFSET
		effect.CollisionDamage = player.Damage * DAMAGE_MULTIPLIER

		local data = GetLogThrowData(effect)
		data.ThrowVelocity = velocity

		playersHoldingLog[hash] = nil

		ClashRoyaleCards.SFXMan:Play(ClashRoyaleCards.Enums.SoundEffect.LOG_VOCAL)
		ClashRoyaleCards.SFXMan:Play(ClashRoyaleCards.Enums.SoundEffect.LOG_ROLL)
	end

	player:ResetItemState()
end

---@param entity Entity
local function PostEntityRemovePlayer(_, entity)
	playersHoldingLog[GetPtrHash(entity)] = nil
end

---@param effect EntityEffect
local function PostEffectUpdateLog(_, effect)
	local data = GetLogThrowData(effect)

	local positions = GetLogPositions(effect.Position, data.ThrowVelocity)

	if effect.FrameCount >= LIFETIME_FRAMES or HitDeadEnd(positions, data.Height) then
		DestroyLog(effect)
		return
	end

	effect.Velocity = data.ThrowVelocity

	TryBreakGrids(positions)
	DamageEnemies(effect, data)

	data.VerticalVelocity = data.VerticalVelocity - GRAVITY
	data.Height = data.Height + data.VerticalVelocity

	if data.Height <= 0 then
		data.Height = 0

		if data.Bounces < data.MaxBounces and math.abs(data.VerticalVelocity) > MIN_BOUNCE_SPEED then
			data.VerticalVelocity = -data.VerticalVelocity * data.Damping
			data.Bounces = data.Bounces + 1
		else
			data.VerticalVelocity = 0
		end
	end

	effect.SpriteOffset = Vector(0, -data.Height)
end

function this:Init()
	ClashRoyaleCards:AddCallback(ModCallbacks.MC_USE_CARD, UseCardLog, ClashRoyaleCards.Enums.Card.LOG)
	ClashRoyaleCards:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PostPlayerUpdate)
	ClashRoyaleCards:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostEffectUpdateLog,
		ClashRoyaleCards.Enums.EffectVariant.LOG)
	ClashRoyaleCards:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, PostEntityRemovePlayer, EntityType.ENTITY_PLAYER)
end

return this
