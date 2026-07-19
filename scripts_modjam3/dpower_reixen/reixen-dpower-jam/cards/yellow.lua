local Mod = ModJamHolder
local YELLOW = {}
ModJamHolder.Card.YELLOW = YELLOW
YELLOW.NAME = "Justice Card"
YELLOW.ID = Isaac.GetCardIdByName(YELLOW.NAME)
YELLOW.GUN_ID = Isaac.GetEntityVariantByName("Yellow's Colt Anaconda")

YELLOW.BULLETS = 6

YELLOW.STARTING_DELAY = 120
YELLOW.BASE_DAMAGE = 25

YELLOW.SHOOTING_SFX = Isaac.GetSoundIdByName("Revolver Shot")

YELLOW.WIKI = {
    { -- Effect
        { str = "Effect", fsize = 2, clr = 3, halign = 0 },
        { str = "Summons a revolver effect that locks on and fires six high-damage bullets at nearby enemies (prefers non-bosses, then bosses)." },
        { str = "Bullets are fired sequentially and scale in damage with floor stage." },
    },
    { -- Trivia
        { str = "Trivia", fsize = 2, clr = 3, halign = 0 },
        { str = "Art by Reixen" },
        { str = "Code by dpower12" },
        { str = "" },
        { str = "" },
    },
}

YELLOW.EID = "Summons a revolver that fires six insta-kill bullets at nearby enemies#Bullets deal 25 base damage to bosses and scales with floor stage"

function YELLOW:FindValidBoys(player)
    local enemies = {}
    local closestBoss = nil

    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity:IsActiveEnemy(false) and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and entity:IsVulnerableEnemy() then
            if entity:IsBoss() then
                if not closestBoss or (entity.Position - player.Position):Length() < (closestBoss.Position - player.Position):Length() then
                    closestBoss = entity
                end
            else
                enemies[#enemies + 1] = entity
            end
        end
    end

    table.sort(enemies, function(a, b)
        local distA = (a.Position - player.Position):Length()
        local distB = (b.Position - player.Position):Length()
        return distA < distB
    end)
    return enemies, closestBoss
end

function YELLOW:InitialiseBounties(gun, enemies, closestBoss)

    local data = gun:GetData()
    local bullets = data.MJ_bullets
    data.MJ_Positions = {}
    for _, entity in ipairs(enemies) do
        data.MJ_Positions[bullets] = entity.Position
        bullets = bullets - 1
        if bullets <= 0 then
            break
        end
    end
    if bullets > 0 and closestBoss then
        for i = 1, bullets do
            data.MJ_Positions[i] = closestBoss.Position
            bullets = bullets - 1
        end
    end
    if bullets > 0 then
        for i = 1, bullets do
            data.MJ_Positions[bullets] = Game():GetRoom():GetRandomPosition(0)
            bullets = bullets - 1
        end
    end
end

---@param gun EntityEffect
---@return Vector[]
function YELLOW:GetBounties(gun)
    local data = gun:GetData()
    return data.MJ_Positions
end

---@param player EntityPlayer
---@param gun EntityEffect
---@param pos Vector
function YELLOW:ShootBullet(player, gun, pos)
    gun.SpriteRotation = (pos - gun.Position):GetAngleDegrees()
    local holePos = gun.Position + gun:GetNullOffset("bulletHole")
    local bullet = player:FireTear(holePos, (pos - holePos):Normalized() * 40, false, true, false, gun) ---@cast bullet EntityTear
    -- I have no idea why the bullet doesnt spawn on the correct position
    -- the poof effect literally spawns exactly where it should, idk why the bullet is to difficult
    --local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, holePos, Vector.Zero, nil)
    --fx.SpriteScale = Vector(0.5, 0.5)

    if (gun.SpriteRotation < -10 and gun.SpriteRotation > -170) then
        gun.DepthOffset = player.DepthOffset - 1
    else
        gun.DepthOffset = player.DepthOffset + 1
    end

    -- I am unsure if FireTear is based off of the player's current items so I place it here
    bullet:ChangeVariant(TearVariant.COIN)

    local sprite = bullet:GetSprite()
    sprite:ReplaceSpritesheet(0, "gfx/tears/tear_revolver_bullet.png", true)
    sprite:Play("Rotate1", true)

    local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0, bullet.Position + bullet.PositionOffset, Vector.Zero, bullet):ToEffect() ---@cast trail EntityEffect
    trail.Parent = bullet
    trail:FollowParent(bullet)
    trail.Color = Color.TearNumberOne

    -- dp TODO: figure out a way to stop tears from playing the fire sound
    --Mod.SfxMan:Stop(SoundEffect.SOUND_TEARS_FIRE)
    Mod.SfxMan:Play(YELLOW.SHOOTING_SFX, Options.SFXVolume, 0)
    bullet:GetData().YellowKiller = true
    bullet:AddTearFlags(TearFlags.TEAR_SPECTRAL)
    bullet.CollisionDamage = YELLOW.BASE_DAMAGE + ((YELLOW.BASE_DAMAGE / 2) * Mod.Game:GetLevel():GetStage())
end

---@param player EntityPlayer
function YELLOW:OnUseCard(_, player)
    local enemies, boss = YELLOW:FindValidBoys(player)
    -----@diagnostic disable-next-line: param-type-mismatch
    Mod.Game:GetRoom():SetPauseTimer(80)
    player:AddControlsCooldown(160)

    local gun = Isaac.Spawn(EntityType.ENTITY_EFFECT, YELLOW.GUN_ID, 0, player.Position + Vector(0, -4), Vector.Zero, player):ToEffect() ---@cast gun EntityEffect
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position + Vector(20, 0), Vector.Zero, nil)
    Mod.SfxMan:Play(SoundEffect.SOUND_SUMMON_POOF)
    Mod.SfxMan:Play(SoundEffect.SOUND_SHELLGAME, Options.SFXVolume, 0, true, 0.7)
    gun.DepthOffset = player.DepthOffset + 5
    gun.Parent = player
    gun:FollowParent(player)

    local data = gun:GetData()
    data.MJ_bullets = YELLOW.BULLETS
    YELLOW:InitialiseBounties(gun, enemies, boss)
end
Mod:AddCallback(ModCallbacks.MC_USE_CARD, YELLOW.OnUseCard, YELLOW.ID)

---@param gun EntityEffect
function YELLOW:OnGunUpdate(gun)
    local sprite = gun:GetSprite()
    if sprite:IsFinished("Spawn") then
        Mod.SfxMan:Stop(SoundEffect.SOUND_SHELLGAME)
        sprite:Play("Shoot", true)
    end
    if sprite:IsFinished("Shoot") then
        local data = gun:GetData()
        local bullets = data.MJ_bullets
        if bullets > 0 then
            sprite:Play("Shoot", true)
        else
            gun:Remove()
        end
    end
    if sprite:IsEventTriggered("Shoot") then
        local data = gun:GetData()
        local bullets = data.MJ_bullets
        local bounties = YELLOW:GetBounties(gun)
        local player = gun.Parent and gun.Parent:ToPlayer()
        if not player then
            gun:Remove()
            return
        end
        YELLOW:ShootBullet(player, gun, bounties[bullets])
        data.MJ_bullets = data.MJ_bullets - 1
    end
end
Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, YELLOW.OnGunUpdate, YELLOW.GUN_ID)

---@param entity Entity
---@param Damage integer
---@param DamageFlag DamageFlag
---@param source EntityRef
function YELLOW:onTakeDmg(entity, Damage, DamageFlag, source)
    if source.Entity and source.Entity.Type == EntityType.ENTITY_LASER and source.Entity:GetData().YellowKiller then
        if entity:IsActiveEnemy(false) and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and entity:IsVulnerableEnemy() and not entity:IsBoss() then
            entity:Kill()
        end
    end
end
Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, YELLOW.onTakeDmg)