local Mod = ModJamHolder
local ORANGE = {}
ModJamHolder.Card.ORANGE = ORANGE
ORANGE.NAME = "Bravery Card"
ORANGE.ID = Isaac.GetCardIdByName(ORANGE.NAME)

ORANGE.TEAR_VAR = Isaac.GetEntityVariantByName("Orange Glove")
ORANGE.WOAW_SFX = Isaac.GetSoundIdByName("Woaw")

local ONE_SEC = 30
ORANGE.COLOR_BUILDUP_SPEED = ONE_SEC * 20
ORANGE.SCALING_STRENGTH = 0.0015
ORANGE.DMG_SCALING_STRENGTH = 0.3
--[[
ORANGE.SFX = Isaac.GetSoundIdByName("ORANGE")
ORANGE.SFX_ALT = Isaac.GetSoundIdByName("Cultivate")
ORANGE.SFX_ALT_CHANCE = 0.2]]

ORANGE.WIKI = {
    { -- Effect
        { str = "Effect", fsize = 2, clr = 3, halign = 0 },
        { str = "Creates a throwable glove that the player can hold to charge. While held, the glove grows in size and its damage increases over time." },
        { str = "Attacking in any direction throws the glove. Taking damage will also throw the glove." },
    },
    { -- Trivia
        { str = "Trivia", fsize = 2, clr = 3, halign = 0 },
        { str = "Art by Reixen" },
        { str = "Code by dpower12" },
        { str = "" },
        { str = "" },
    },
}

ORANGE.EID = "{{TimerSmall}} Creates a throwable glove that charges while held, increasing in size and damage"..
            "#{{Throwable}} Shooting or getting hit fires a powerful punch"

local sfx = Mod.SfxMan

ThrowableItemLib:RegisterThrowableItem({
	ID = ORANGE.ID,
	Identifier = "Reixen-dp-Jam",
	Flags = ThrowableItemLib.Flag.DISABLE_ITEM_USE | ThrowableItemLib.Flag.DISABLE_HIDE,
	Type = ThrowableItemLib.Type.CARD,
	ThrowFn = function (player, vect, slot, mimic)
		ORANGE:ShootTear(player, vect)
	end,
	LiftFn = function (player, continued, slot, mimic)
        --#region Kerkel here: latest TIL build had bug since fixed that removed cards when lifted. The below code restores the behavior present at the time of making this card 
        if not mimic and player:GetCard(PillCardSlot.PRIMARY) == ORANGE.ID then
            player:RemovePocketItem(PillCardSlot.PRIMARY)
        end
        --#endregion
		sfx:Play(SoundEffect.SOUND_SHELLGAME, Options.SFXVolume)
	end,
    AnimateFn = function(player, state)
        ORANGE:HandleTearSprite(player, state)
        return true
    end
})

---@param player EntityPlayer
function ORANGE:HandleTearSprite(player, state)
    if state == ThrowableItemLib.State.LIFT then
        local tear = ORANGE:GetTear(player)
        if not tear:Exists() then
            tear = ORANGE:CreateTear(player)
        end
        player:AnimatePickup(Sprite(), true, "LiftItem")
    elseif state == ThrowableItemLib.State.THROW or state == ThrowableItemLib.State.HIDE then
        player:AnimatePickup(Sprite(), true, "HideItem")
    end
end

function ORANGE:ShootTear(player, vect)
    local tear = ORANGE:GetTear(player)
    local data = player:GetData()
    tear:GetData().thrown = true
    tear:GetSprite():Play("Shoot")
    tear:GetSprite():RemoveOverlay()
    Mod.SfxMan:Play(SoundEffect.SOUND_SWORD_SPIN, Options.SFXVolume, 0, false, 0.5)
    tear.Position = player.Position
    tear.Velocity = vect * 10
    data.bonusTear = nil
    tear.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
    tear.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
    Mod.SfxMan:Stop(ORANGE.WOAW_SFX)
end

---@param player EntityPlayer
---@return EntityTear
function ORANGE:CreateTear(player)
    local tear = player:FireTear(Vector.Zero, Vector.Zero, false, true, false, player)
    tear:ChangeVariant(ORANGE.TEAR_VAR)
    tear:GetSprite():Play("Idle")
    tear:GetSprite():PlayOverlay("Wooshy")
    tear:AddTearFlags(TearFlags.TEAR_PUNCH)
    tear.Parent = player
    tear.SpawnerEntity = player
    local data = player:GetData()
    data.bonusTear = tear
    tear.DepthOffset = 999999

    local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0, tear.Position + tear.PositionOffset, Vector.Zero, tear):ToEffect()
    trail.Parent = tear
    trail:FollowParent(tear)
    trail.SpriteScale = Vector(4, 4)
    trail.Color = Color(1, 0.8, .6, 1, 0.4, 0.1)

    tear:GetData().MJ_trail = trail

    return tear
end

function ORANGE:GetTear(player)
    local data = player:GetData()
    if data.bonusTear and data.bonusTear:ToTear() then
        return data.bonusTear
    else
        return ORANGE:CreateTear(player)
    end
end
---@param player EntityPlayer
function ORANGE:OnUseCard(_, player)

end
Mod:AddCallback(ModCallbacks.MC_USE_CARD, ORANGE.OnUseCard, ORANGE.ID)

---@param tear EntityTear
function ORANGE:onTearUpdate(tear)
    local data = tear:GetData()
    local sprite = tear:GetSprite()
    local trail = data.MJ_trail

    if not data.thrown then
        tear:AddTearFlags(TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_PIERCING)
        tear.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        tear.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
       
        -- Get the player holding the tear
        local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
        if player then
            -- Position tear at player's hand
            tear.Position = player.Position + Vector(0, -30)
            tear.Velocity = Vector.Zero
        end

        tear.FallingSpeed = -0.1
        tear.FallingAcceleration = -0.05
        tear.Scale = tear.Scale + ORANGE.SCALING_STRENGTH

        local gloveId = 0
        local layer = sprite:GetLayer(gloveId)
        local colorIntensity = (tear.FrameCount / ORANGE.COLOR_BUILDUP_SPEED) * 0.2
        layer:SetColor(Color(1, 1, 1, 1, colorIntensity))

        trail.SpriteScale = Vector(trail.SpriteScale.X + ORANGE.SCALING_STRENGTH, trail.SpriteScale.Y + ORANGE.SCALING_STRENGTH)
        trail.Color = Color(trail.Color.R, trail.Color.G, trail.Color.B, trail.Color.A, trail.Color.RO + colorIntensity)

        local arcLength = math.pi / (ONE_SEC / 3)
        local whiteningStrength = 0.2
        local whitening = (whiteningStrength / 2) * math.sin(arcLength * (tear.FrameCount)) + whiteningStrength
        tear.Color = Color(tear.Color.R, tear.Color.G, tear.Color.B, tear.Color.A, whitening, whitening, whitening)

        -- Increase damage each frame while held
        tear.CollisionDamage = tear.CollisionDamage + ORANGE.DMG_SCALING_STRENGTH + (math.ceil(Mod.Game:GetLevel():GetStage() / 2) / 10)

        local sfxIntensity = 1.5 + colorIntensity
        Mod.SfxMan:Play(ORANGE.WOAW_SFX, Options.SFXVolume / 2, math.ceil(36 / sfxIntensity), false, sfxIntensity)
    else
        tear.Color = Color.Default
    end

    sprite.Rotation = tear.Velocity:GetAngleDegrees()
end
Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, ORANGE.onTearUpdate, ORANGE.TEAR_VAR)

function ORANGE:onDmg(entity, dmg)
    local player = entity:ToPlayer()
    if player then
        local data = player:GetData()
        if data.bonusTear then
            ORANGE:ShootTear(player, player.Velocity)
        end
    end
end
Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, ORANGE.onDmg, EntityType.ENTITY_PLAYER)