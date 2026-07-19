-- Author: 4Head (ConJam Submission)
-- utils.lua
-- 7/14/26
-- Utility functions. Lazy af just copied this effect from my other mod.

---@class DustRingParams
---@field scale_min number?
---@field scale_max number?
---@field speed_min number?
---@field speed_max number?
---@field lifetime_min number?
---@field lifetime_max number?
---@field color Color?

local rng = RNG(Random(), 35)

---@param min number
---@param max number
function ClashRoyaleCards:GetRandomFloat(min, max)
	return min + rng:RandomFloat() * (max - min)
end

---@param position Vector
---@param spawner Entity? Default = nil.
---@param amount integer? Default = 1.
---@param params DustRingParams? Default = {}
function ClashRoyaleCards:SpawnDustRing(position, spawner, amount, params)
	amount = amount or 1
	params = params or {}
	params.scale_min = params.scale_min or 1
	params.scale_max = params.scale_max or 1
	params.speed_min = params.speed_min or 1
	params.speed_max = params.speed_max or 1
	params.lifetime_min = params.lifetime_min or 30
	params.lifetime_max = params.lifetime_max or 30
	params.color = params.color or Color.Default

	for i = 1, amount do
		local speed = ClashRoyaleCards:GetRandomFloat(params.speed_min, params.speed_max)
		local velocity = RandomVector() * speed

		local dust = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DUST_CLOUD, 0, position, velocity, spawner)
			:ToEffect()

		if dust then
			dust:SetTimeout(rng:RandomInt(params.lifetime_min, params.lifetime_max))

			local scale = ClashRoyaleCards:GetRandomFloat(params.scale_min, params.scale_max)
			dust.SpriteScale = Vector(scale, scale)
			dust.Color = params.color
		end
	end
end