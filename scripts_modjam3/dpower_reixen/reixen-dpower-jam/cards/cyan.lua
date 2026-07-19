local Mod = ModJamHolder
local CYAN = {}
ModJamHolder.Card.CYAN = CYAN
CYAN.NAME = "Patience Card"
CYAN.ID = Isaac.GetCardIdByName(CYAN.NAME)

CYAN.KNIFE_SUBTYPE = Isaac.GetEntitySubTypeByName("Cyan Toy Knife")

CYAN.KNIFE_INIT_ORBIT_SPEED = 2
CYAN.KNIFE_INIT_SPIN_SPEED = 4.5
CYAN.KNIFE_FINAL_ORBIT_SPEED = 6
CYAN.KNIFE_FINAL_SPIN_SPEED = 13
CYAN.MAX_EXTRA_WAVE_DISTANCE =  50

local ONE_SEC = 30
CYAN.RAMPUP_TIME = ONE_SEC * 20
CYAN.WAVE_PERIOD = ONE_SEC * 5
CYAN.KNIFE_RADIUS = 70

--[[
CYAN.SFX = Isaac.GetSoundIdByName("CYAN")
CYAN.SFX_ALT = Isaac.GetSoundIdByName("Cultivate")
CYAN.SFX_ALT_CHANCE = 0.2]]

CYAN.WIKI = {
    { -- Effect
        { str = "Effect", fsize = 2, clr = 3, halign = 0 },
        { str = "Summons 3 toy knives that orbits the player. The knife gradually increases its orbit and spin speed, becoming more aggressive over time." },
        { str = "The knives damage enemies and destroys enemy projectiles that collide with it." },
    },
    { -- Trivia
        { str = "Trivia", fsize = 2, clr = 3, halign = 0 },
        { str = "Art by Reixen" },
        { str = "Code by dpower12" },
        { str = "" },
        { str = "" },
    },
}

CYAN.EID = "Summons 3 toy knives that orbits the player and speeds up over time#The knives damage enemies and destroys enemy projectiles it touches"

---@param player EntityPlayer
function CYAN:OnUseCard(_, player)
    local randomAngle = math.random() * 360
    for i = 1, 3 do
        local knife = player:FireKnife(player, 0, true, CYAN.KNIFE_SUBTYPE, 0)
        knife:GetSprite():Play("Idle")
        if knife then
            local data = knife:GetData()
            data.MoonOrbit = {
                angle = randomAngle - i * 120,
                spinAngle = 0,
            }
            knife.Velocity = Vector.Zero
            knife.DepthOffset = player.DepthOffset + 5
            knife.Parent = player
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, Vector.FromAngle(data.MoonOrbit.angle) * CYAN.KNIFE_RADIUS + player.Position, Vector.Zero, nil)
        end
        Mod.SfxMan:Play(SoundEffect.SOUND_SUMMON_POOF)
    end
    --knife.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
end
Mod:AddCallback(ModCallbacks.MC_USE_CARD, CYAN.OnUseCard, CYAN.ID)

---@param knife EntityKnife
function CYAN:onKnifeUpdate(knife)
    local data = knife:GetData()
    if not data.MoonOrbit then
        return
    end

    local player = (knife.Parent and knife.Parent:ToPlayer()) or (knife.SpawnerEntity and knife.SpawnerEntity:ToPlayer())
    if not player or not player:Exists() then
        return
    end

    local orbit = data.MoonOrbit
    local rotateStrength = math.min(1, knife.FrameCount / CYAN.RAMPUP_TIME)

    local orbitSpeed = (CYAN.KNIFE_FINAL_ORBIT_SPEED - CYAN.KNIFE_INIT_ORBIT_SPEED) * rotateStrength + CYAN.KNIFE_INIT_ORBIT_SPEED
    local spinSpeed = (CYAN.KNIFE_FINAL_SPIN_SPEED - CYAN.KNIFE_INIT_SPIN_SPEED) * rotateStrength + CYAN.KNIFE_INIT_SPIN_SPEED
    orbit.angle = (orbit.angle + orbitSpeed) % 360
    orbit.spinAngle = (orbit.spinAngle + spinSpeed) % 360

    local arcLength = math.pi / CYAN.WAVE_PERIOD
    local extraDist = CYAN.MAX_EXTRA_WAVE_DISTANCE
    local waveDist = (extraDist / 2) * math.sin(arcLength * (knife.FrameCount)) + extraDist

    local radians = math.rad(orbit.angle)
    knife.Position = player.Position + Vector(math.cos(radians), math.sin(radians)) * (CYAN.KNIFE_RADIUS + rotateStrength * waveDist)
    knife.Velocity = Vector.Zero
    knife.SpriteRotation = orbit.spinAngle
    knife.DepthOffset = player.DepthOffset + 5

    if orbit.spinAngle > 340 then
        Mod.SfxMan:Play(SoundEffect.SOUND_SHELLGAME, Options.SFXVolume, 15, false, 0.1 + (0.1 * rotateStrength))
    end
    local hitbox = knife:GetCollisionCapsule()
    for _, bullet in ipairs (Isaac.FindInCapsule(hitbox, EntityPartition.BULLET)) do
        bullet:Die()
    end
end
Mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, CYAN.onKnifeUpdate, CYAN.KNIFE_SUBTYPE)