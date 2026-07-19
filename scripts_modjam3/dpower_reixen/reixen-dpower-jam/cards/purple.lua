local Mod = ModJamHolder
local PURPLE = {}
ModJamHolder.Card.PURPLE = PURPLE
PURPLE.NAME = "Perseverance Card"
PURPLE.ID = Isaac.GetCardIdByName(PURPLE.NAME)

PURPLE.FAMILIARS = 3
PURPLE.FAMILIAR_RANGE = 240
PURPLE.BOOK_SPEED = 6
PURPLE.DECAY_RANGE = 20 ^ 2
PURPLE.BOOK_DAMAGE = 3
PURPLE.DMG_COUNTDOWN = 15

--[[
PURPLE.SFX = Isaac.GetSoundIdByName("PURPLE")
PURPLE.SFX_ALT = Isaac.GetSoundIdByName("Cultivate")
PURPLE.SFX_ALT_CHANCE = 0.2]]

PURPLE.FLYING_BOOK_ID = Isaac.GetEntityVariantByName("Flying Book")

PURPLE.WIKI = {
    { -- Effect
        { str = "Effect", fsize = 2, clr = 3, halign = 0 },
        { str = "Summons three flying book familiars that block shots, seek out enemies and deal contact damage." },
        { str = "Books deal damage to enemies and trigger their book effect on death." },
    },
    { -- Trivia
        { str = "Trivia", fsize = 2, clr = 3, halign = 0 },
        { str = "Art by Reixen" },
        { str = "Code by dpower12" },
        { str = "" },
        { str = "" },
    },
}

PURPLE.EID = "{{Library}} Summons three flying book familiars that block shots, seek enemies and deal contact damage"..
            "#{{Warning}} When a book dies, it triggers its collectible effect"

local itemconf = Isaac.GetItemConfig()
local function GetAverageCollColor(id)
    local coll_config = itemconf:GetCollectible(id)
    if not coll_config then
        return 0,0,0
    end
    local path = coll_config.GfxFileName
    local success,img = pcall(Renderer.LoadImage,path)
    if not success then
        return 0,0,0
    end
    local texel = img:GetTexelRegion(0,0,32,32)
    local count = 0
    local total_r = 0
    local total_g = 0
    local total_b = 0
    local bytes = {string.byte(texel, 1, #texel)}
    for i=1, #texel, 4 do
        local r,g,b,a=bytes[i],bytes[i+1],bytes[i+2],bytes[i+3]
        if a ~= 0 and not(r == 8 and b == 0 and g == 0) and not(r == 0 and b == 0 and g == 0) then
            total_r=total_r+r
            total_g=total_g+g
            total_b=total_b+b
            count = count + 1
        end
    end
    total_r=total_r/count
    total_g=total_g/count
    total_b=total_b/count
    return total_r/255,total_g/255,total_b/255
end



---@param familiar EntityFamiliar
function PURPLE:GetBookColor(familiar)
    local r, g, b = GetAverageCollColor(familiar.SubType)
    return Color(r, g, b)
end

function PURPLE:GetPageColor(familiar)
    local r, g, b = 1, 1, 1
    return Color(r, g, b)
end

---@param familiar EntityFamiliar
function PURPLE:FindTarget(familiar)
    local distance = 9999
    familiar.Target = nil
    for _, entity in ipairs(Isaac.FindInRadius(familiar.Position, PURPLE.FAMILIAR_RANGE, EntityPartition.ENEMY)) do
        if
            entity:IsActiveEnemy(false)
            and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
            and entity:IsVulnerableEnemy()
        then
            local entityDistance = (entity.Position - familiar.Position):Length()
            if entityDistance < distance then
                distance = entityDistance
                familiar.Target = entity
            end
        end
    end
    if not familiar.Target then
        familiar.Target = familiar.Player
    end
end

---@param familiar EntityFamiliar
function PURPLE:GetTarget(familiar)
    if familiar.Target and not familiar.Target:IsDead() then
        return familiar.Target
    end
    if Game():GetRoom():GetAliveEnemiesCount() > 0 then
        familiar.Target = familiar.Player
    else
        PURPLE:FindTarget(familiar)
    end
    return familiar.Target
end

---@param familiar EntityFamiliar
---@param player EntityPlayer
function PURPLE:GetTargetPos(familiar, player)

    local target = PURPLE:GetTarget(familiar)
    if not target or not target.Position then
        return Game():GetRoom():GetCenterPos()
    end
    return target.Position
end


---@param player EntityPlayer
function PURPLE:OnUseCard(_, player)
    local rng = player:GetCardRNG(PURPLE.ID)
    for i = 1, PURPLE.FAMILIARS do
        local angle = rng:RandomFloat()
	    angle = (angle * 90) + 45
        local ID = Game():GetItemPool():GetCollectible(ItemPoolType.POOL_LIBRARY, false, rng:GetSeed(), CollectibleType.COLLECTIBLE_NULL, GetCollectibleFlag.BAN_PASSIVES)
        if ID == CollectibleType.COLLECTIBLE_NULL then
            ID = CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL
        end
        local fam = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, PURPLE.FLYING_BOOK_ID, ID, player.Position + Vector(0, 10), Vector.FromAngle(angle) * 5, player):ToFamiliar()
        fam.Player = player
    end
    Mod.SfxMan:Play(SoundEffect.SOUND_SUMMON_POOF)
end
Mod:AddCallback(ModCallbacks.MC_USE_CARD, PURPLE.OnUseCard, PURPLE.ID)

---@param familiar EntityFamiliar
function PURPLE:OnBookInit(familiar)
    local sprite = familiar:GetSprite()
    sprite:SetFrame(math.random(0, 25))
    familiar.SpriteOffset = Vector(0, math.random(1, 5))
    EntityPickup.SetupCollectibleGraphics(sprite, 0, familiar.SubType, false,  Random(), true)
    familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
    local basedColor = PURPLE:GetBookColor(familiar)
    local pageColor = PURPLE:GetPageColor(familiar)
    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, familiar.Position + Vector(20, 0), Vector.Zero, nil)
	poof:SetColor(basedColor, -1, 1, true, true)
    sprite:GetLayer(1):SetColor(basedColor)
    sprite:GetLayer(2):SetColor(pageColor)
end
Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, PURPLE.OnBookInit, PURPLE.FLYING_BOOK_ID)

---@param familiar EntityFamiliar
function PURPLE:OnBookUpdate(familiar)
    local player = familiar.Player

    if familiar.FrameCount % 30 == 0 then
        PURPLE:FindTarget(familiar)
    end

    local targetPos = PURPLE:GetTargetPos(familiar, player)
    local distance = familiar.Position:DistanceSquared(familiar.Target.Position)
    local speed = PURPLE.BOOK_SPEED
    if distance < PURPLE.DECAY_RANGE then
        speed = (distance / PURPLE.DECAY_RANGE) * PURPLE.BOOK_SPEED
    else
        familiar.FlipX = math.abs((familiar.Position - familiar.Target.Position):GetAngleDegrees()) < 90
    end
    familiar.Velocity = (targetPos - familiar.Position):Resized(math.min(speed))

     local capsule = familiar:GetCollisionCapsule()
    -- should this be in the collision code? yes, but I don't feel like changing it rn
    ---@diagnostic disable-next-line: param-type-mismatch
    for _, familiar2 in ipairs(Isaac.FindInCapsule(capsule, EntityPartition.FAMILIAR | EntityPartition.ENEMY)) do
        familiar.Velocity = familiar.Velocity + (familiar.Position - familiar2.Position):Normalized()
        familiar2.Velocity = familiar2.Velocity + (familiar2.Position - familiar.Position):Normalized()
    end

    if familiar:GetSprite():IsEventTriggered("Flap") then
        Mod.SfxMan:Play(SoundEffect.SOUND_BIRD_FLAP)
    end
end
Mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, PURPLE.OnBookUpdate, PURPLE.FLYING_BOOK_ID)

---@param familiar EntityFamiliar
---@param collider Entity
function PURPLE:OnBookCollsion(familiar, collider)
    if familiar:GetDamageCountdown() > 0 then return end
	local bullet, npc = collider:ToProjectile(), collider:ToNPC()

	if bullet and not (bullet:HasEntityFlags(EntityFlag.FLAG_CHARM) or bullet:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) or bullet:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)) then
		familiar:TakeDamage(bullet.CollisionDamage, 0, EntityRef(bullet), PURPLE.DMG_COUNTDOWN)
		bullet:Die()
	elseif npc
		and npc:IsActiveEnemy(false)
		and npc:IsVulnerableEnemy()
		and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
        and familiar:GetSprite():IsEventTriggered("Flap")
	then
		if npc:TakeDamage(PURPLE.BOOK_DAMAGE, 0, EntityRef(familiar), 0) then
			familiar:TakeDamage(1, 0, EntityRef(npc), PURPLE.DMG_COUNTDOWN)
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_COLLISION, PURPLE.OnBookCollsion, PURPLE.FLYING_BOOK_ID)

---@param ent Entity
function PURPLE:OnBookDeath(ent)
	local familiar = ent:ToFamiliar()
	if familiar and familiar.Variant == PURPLE.FLYING_BOOK_ID then
		Mod.SfxMan:Play(SoundEffect.SOUND_STEAM_HALFSEC)
		local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, ent.Position, Vector.Zero, ent):ToEffect() ---@cast poof EntityEffect
		local color = PURPLE:GetBookColor(familiar)
		poof:SetColor(color, -1, 1, true, true)
        if familiar.Player then
            local player = familiar.Player
            ---@diagnostic disable-next-line: param-type-mismatch
            player:UseActiveItem(familiar.SubType, UseFlag.USE_NOANIM | UseFlag.USE_NOHUD, -1)
        end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, PURPLE.OnBookDeath, EntityType.ENTITY_FAMILIAR)

function PURPLE:onNewRoom()
    for _, book in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, PURPLE.FLYING_BOOK_ID)) do
        book:Remove()
    end
end
Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PURPLE.onNewRoom)