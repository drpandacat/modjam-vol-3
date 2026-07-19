local Mod = ModJamHolder
local BLUE = {}
ModJamHolder.Card.BLUE = BLUE
BLUE.NAME = "Integrity Card"
BLUE.ID = Isaac.GetCardIdByName(BLUE.NAME)

BLUE.STOMPS = 7
BLUE.FOOT = Isaac.GetEntityVariantByName("Ballet Leg")
BLUE.STOMP_RADIUS = 80
BLUE.STOMP_DMG = 100
BLUE.FOOT_DISTANCE = 100
BLUE.FOOT_TIMER = 15

--[[
BLUE.SFX = Isaac.GetSoundIdByName("BLUE")
BLUE.SFX_ALT = Isaac.GetSoundIdByName("Cultivate")
BLUE.SFX_ALT_CHANCE = 0.2]]

BLUE.WIKI = {
    { -- Effect
        { str = "Effect", fsize = 2, clr = 3, halign = 0 },
        { str = "Spawns seven consecutive Ballet Mom's Foot that home and stomp nearby enemies, dealing heavy crush damage and destroying rocks." },
        { str = "Each foot homes toward enemies within range. After a stomp triggers, another foot may spawn from the stomp position until all seven stomps are performed." },
    },
    { -- Trivia
        { str = "Trivia", fsize = 2, clr = 3, halign = 0 },
        { str = "Art by Reixen" },
        { str = "Code by dpower12" },
        { str = "" },
        { str = "" },
    },
}

BLUE.EID = "{{MomBossSmall}} Spawns seven consecutive Ballet Mom's Foot that home, stomp enemies and destroy rocks"..
            "#{{Warning}} Each stomp deals 100 crush damage and knocks enemies back"

--- Returns a shallow copy of a given table.
--- Does not copy metatables.
---@generic K,V
---@param tab table<K,V>
---@return table<K,V>
function BLUE:ShallowCopy(tab)
	local copy = {}
	for k, v in pairs(tab) do
		copy[k] = v
	end
	return copy
end

---@generic V
---@param tab V[]
---@param rng RNG
---@return V[]
function BLUE:ShuffleTable(tab, rng)
	local out = BLUE:ShallowCopy(tab)

	for i = #out, 2, -1 do
		local j = rng:RandomInt(i) + 1
		out[i], out[j] = out[j], out[i]
	end
	return out
end

function BLUE:GetTarget(rng)
    local entitiesRaw = Isaac.GetRoomEntities()
    local entities = BLUE:ShuffleTable(entitiesRaw, rng)
    for _, entity in ipairs(entities) do
        if entity:IsActiveEnemy(false) then
            return entity
        end
    end
    return nil
end

---@param rng RNG
---@param player EntityPlayer
---@param ogPosition? Vector
---@param stompCount? integer
function BLUE:MakeStomp(rng, player, ogPosition, stompCount)
    local target = BLUE:GetTarget(rng)
    if not target then
        target = player
    end
    local stompPositon
    if ogPosition then
        local distance = ogPosition:Distance(target.Position)
        if distance < BLUE.FOOT_DISTANCE / 3 then
            stompPositon = ogPosition + RandomVector() * (BLUE.FOOT_DISTANCE / 3)
        elseif distance < BLUE.FOOT_DISTANCE then
            stompPositon = target.Position
        else
            local maxDisplacement = (target.Position - ogPosition):Normalized() * BLUE.FOOT_DISTANCE
            stompPositon = ogPosition + maxDisplacement
        end
    else
        stompPositon = target.Position
    end
    local foot = Isaac.Spawn(EntityType.ENTITY_EFFECT, BLUE.FOOT, 0, stompPositon, Vector.Zero, player)
    local data = foot:GetData()
    stompCount = stompCount or BLUE.STOMPS
    data.Player = player
    data.stompCount = stompCount - 1
    data.nextStompTimer = BLUE.FOOT_TIMER
end

---@param player EntityPlayer
function BLUE:OnUseCard(_, player)
    local rng = player:GetCardRNG(BLUE.ID)
    BLUE:MakeStomp(rng, player)
end
Mod:AddCallback(ModCallbacks.MC_USE_CARD, BLUE.OnUseCard, BLUE.ID)

---@param position Vector
---@param radius number
---@return GridEntity[]
local function GetGridsInRadius(position, radius)
    local room = Game():GetRoom()
    local grids = {}
    for i = 0, room:GetGridSize() - 1 do
        local gridEntity = room:GetGridEntity(i)
        if gridEntity then
            local distance = (gridEntity.Position - position):Length()
            if distance <= radius then
                table.insert(grids, gridEntity)
            end
        end
    end
    return grids
end

---@param leg EntityEffect
function BLUE:StompDmg(leg)
    Mod.SfxMan:Play(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND)
    local enemies = Isaac.FindInRadius(leg.Position, BLUE.STOMP_RADIUS, EntityPartition.ENEMY)
    local players = Isaac.FindInRadius(leg.Position, BLUE.STOMP_RADIUS, EntityPartition.PLAYER)
    local grids = GetGridsInRadius(leg.Position, BLUE.STOMP_RADIUS)
    for _, entity in ipairs(enemies) do
        entity:TakeDamage(BLUE.STOMP_DMG, DamageFlag.DAMAGE_CRUSH, EntityRef(leg), 30)
        local knockbackDirection = (entity.Position - leg.Position):Normalized()
        entity:AddKnockback(EntityRef(leg), knockbackDirection * 5, 3, true)
    end
    for _, entity in ipairs(players) do
        entity:TakeDamage(2, DamageFlag.DAMAGE_CRUSH, EntityRef(leg), 30)
        local knockbackDirection = (entity.Position - leg.Position):Normalized()
        entity:AddKnockback(EntityRef(leg), knockbackDirection * 5, 2, false)
    end
    for _, grid in ipairs(grids) do
        grid:Destroy()
    end
end

---@param leg EntityEffect
function BLUE:onLegInit(leg)
    local sprite = leg:GetSprite()
    sprite:Play("Stomp", true)
end
Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, BLUE.onLegInit, BLUE.FOOT)

---@param leg EntityEffect
function BLUE:onLegUpdate(leg)
    local sprite = leg:GetSprite()
    local data = leg:GetData()
    if data.nextStompTimer == 0 then
        if data.stompCount and data.stompCount > 0 then
            BLUE:MakeStomp(leg:GetDropRNG(), data.Player or Isaac.GetPlayer(), leg.Position, data.stompCount)
        end
    end
    data.nextStompTimer = data.nextStompTimer - 1

    -- if sprite:IsEventTriggered("Stomp") then
    if sprite:GetFrame() == 27 then
        BLUE:StompDmg(leg)
    elseif sprite:IsFinished("Stomp") then
        sprite:Play("Return", true)
    elseif sprite:IsFinished("Return") then
        leg:Remove()
    end
end
Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, BLUE.onLegUpdate, BLUE.FOOT)