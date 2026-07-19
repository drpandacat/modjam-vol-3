-- Author: 4Head (ConJam Submission)
-- rage.lua
-- 7/16/26
-- Logic for the Rage card.

---@class RageAreaData
---@field Active boolean

local this = {}

local AREA_RADIUS = 100
local AREA_DEPTH_OFFSET = -1000

local FIRE_RATE_MULTIPLIER = 2
local SPEED_MULTIPLIER = 2
local DAMAGE_MULTIPLIER = 2
local LUCK_MULTIPLIER = 10
local RANGE_MULTIPLIER = 2
local SHOT_SPEED_MULTIPLIER = 1.5
local FAMILIAR_MULTIPLIER = 1.35

local TINT_FADE_FRAMES = 20
local TINT_OFFSET = Color(1, 1, 1, 1, 0.25, -0.15, 0.4)


---@type CacheFlag
---@diagnostic disable-next-line: assign-type-mismatch
local RAGE_CACHE_FLAGS = CacheFlag.CACHE_FIREDELAY
	| CacheFlag.CACHE_SPEED
	| CacheFlag.CACHE_DAMAGE
	| CacheFlag.CACHE_LUCK
	| CacheFlag.CACHE_RANGE
	| CacheFlag.CACHE_SHOTSPEED

---@type table<integer, boolean>
local ragedPlayers = {}

---@type table<integer, boolean>
local ragedFamiliars = {}

---@type table<integer, number>
local tintProgress = {}

---@param effect Entity
---@return RageAreaData
local function GetRageAreaData(effect)
	local data = effect:GetData()

	if not data.RageAreaData then
		data.RageAreaData = {
			Active = true,
		}
	end

	return data.RageAreaData
end

---@param _card Card
---@param player EntityPlayer
local function UseCardRage(_, _card, player)
	Isaac.Spawn(
		EntityType.ENTITY_EFFECT,
		ClashRoyaleCards.Enums.EffectVariant.RAGE_POTION,
		0,
		player.Position,
		Vector.Zero,
		player
	)
	ClashRoyaleCards.SFXMan:Play(ClashRoyaleCards.Enums.SoundEffect.CARD_USE)
end

---@param effect EntityEffect
local function PostEffectUpdateRagePotion(_, effect)
	if not effect:GetSprite():IsFinished("rage bottle") then
		return
	end

	effect:Remove()

	local area = Isaac.Spawn(
		EntityType.ENTITY_EFFECT,
		ClashRoyaleCards.Enums.EffectVariant.RAGE_AREA,
		0,
		effect.Position,
		Vector.Zero,
		effect.SpawnerEntity
	):ToEffect()

	ClashRoyaleCards.SFXMan:Play(ClashRoyaleCards.Enums.SoundEffect.RAGE_USE, 1, 0, false)

	if area then
		area.DepthOffset = AREA_DEPTH_OFFSET
		area:GetSprite():Play("rage deploy", false)
	end
end

---@param effect EntityEffect
local function PostEffectUpdateRageArea(_, effect)
	local sprite = effect:GetSprite()
	local data = GetRageAreaData(effect)

	if sprite:IsEventTriggered("stop") then
		data.Active = false
	end

	if sprite:IsFinished("rage deploy") then
		sprite:Play("rage area", false)
		return
	end

	if sprite:IsFinished("rage area") then
		effect:Remove()
	end
end

---@param position Vector
local function IsInActiveRageArea(position)
	for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, ClashRoyaleCards.Enums.EffectVariant.RAGE_AREA, 0)) do
		local data = GetRageAreaData(entity)

		if entity and data.Active and position:Distance(entity.Position) <= AREA_RADIUS then
			return true
		end
	end

	return false
end

---@param entity Entity
---@param isRaged boolean
local function UpdateRageTint(entity, isRaged)
	local hash = GetPtrHash(entity)
	local progress = tintProgress[hash]

	if not progress then
		if not isRaged then
			return
		end

		progress = 0
	end

	local step = 1 / TINT_FADE_FRAMES

	if isRaged then
		progress = math.min(progress + step, 1)
	else
		progress = math.max(progress - step, 0)
	end

	if progress <= 0 then
		tintProgress[hash] = nil
		entity.Color = Color.Default
		return
	end

	tintProgress[hash] = progress

	local eased = progress^2 * (3 - 2 * progress)

	entity.Color = Color(
		entity.Color.R,
		entity.Color.G,
		entity.Color.B,
		entity.Color.A,
		TINT_OFFSET.RO * eased,
		TINT_OFFSET.GO * eased,
		TINT_OFFSET.BO * eased
	)
end

---@param player EntityPlayer
local function PostPEffectUpdate(_, player)
	local hash = GetPtrHash(player)
	local isRaged = IsInActiveRageArea(player.Position)
	local wasRaged = ragedPlayers[hash] == true

	if isRaged ~= wasRaged then
		ragedPlayers[hash] = isRaged
		player:AddCacheFlags(RAGE_CACHE_FLAGS, true)
	end

	UpdateRageTint(player, isRaged)
end

---@param familiar EntityFamiliar
local function FamiliarUpdate(_, familiar)
	local hash = GetPtrHash(familiar)
	local isRaged = IsInActiveRageArea(familiar.Position)
	local wasRaged = ragedFamiliars[hash] == true

	if isRaged ~= wasRaged then
		ragedFamiliars[hash] = isRaged
		familiar:InvalidateCachedMultiplier()
	end

	UpdateRageTint(familiar, isRaged)
end

---@param entity Entity
local function PostEntityRemove(_, entity)
	local hash = GetPtrHash(entity)

	ragedPlayers[hash] = nil
	ragedFamiliars[hash] = nil
	tintProgress[hash] = nil
end

---@param player EntityPlayer
---@param cacheFlag CacheFlag
local function EvaluateCache(_, player, cacheFlag)
	if not ragedPlayers[GetPtrHash(player)] then
		return
	end

	if cacheFlag == CacheFlag.CACHE_FIREDELAY then
		local tearRate = 30 / (player.MaxFireDelay + 1)
		player.MaxFireDelay = 30 / (tearRate * FIRE_RATE_MULTIPLIER) - 1
	elseif cacheFlag == CacheFlag.CACHE_SPEED then
		player.MoveSpeed = player.MoveSpeed * SPEED_MULTIPLIER
	elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage * DAMAGE_MULTIPLIER
	elseif cacheFlag == CacheFlag.CACHE_LUCK then
		player.Luck = math.max(1, player.Luck) * LUCK_MULTIPLIER
	elseif cacheFlag == CacheFlag.CACHE_RANGE then
		player.TearRange = player.TearRange * RANGE_MULTIPLIER
	elseif cacheFlag == CacheFlag.CACHE_SHOTSPEED then
		player.ShotSpeed = player.ShotSpeed * SHOT_SPEED_MULTIPLIER
	end
end

---@param familiar EntityFamiliar
---@param multiplier number
local function EvaluateFamiliarMultiplier(_, familiar, multiplier)
	if not ragedFamiliars[GetPtrHash(familiar)] then
		return
	end

	return multiplier * FAMILIAR_MULTIPLIER
end

function this:Init()
	ClashRoyaleCards:AddCallback(ModCallbacks.MC_USE_CARD, UseCardRage, ClashRoyaleCards.Enums.Card.RAGE)
	ClashRoyaleCards:AddCallback(
		ModCallbacks.MC_POST_EFFECT_UPDATE,
		PostEffectUpdateRagePotion,
		ClashRoyaleCards.Enums.EffectVariant.RAGE_POTION
	)
	ClashRoyaleCards:AddCallback(
		ModCallbacks.MC_POST_EFFECT_UPDATE,
		PostEffectUpdateRageArea,
		ClashRoyaleCards.Enums.EffectVariant.RAGE_AREA
	)
	ClashRoyaleCards:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PostPEffectUpdate)
	ClashRoyaleCards:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, FamiliarUpdate)
	ClashRoyaleCards:AddCallback(ModCallbacks.MC_EVALUATE_FAMILIAR_MULTIPLIER, EvaluateFamiliarMultiplier)
	ClashRoyaleCards:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, PostEntityRemove)
	
	-- Late cuz stat multipliers
	ClashRoyaleCards:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, EvaluateCache)
end

return this
