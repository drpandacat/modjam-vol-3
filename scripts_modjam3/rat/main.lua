RATJAM3 = RegisterMod("Ratjam3", 1)
local mod = RATJAM3
local sfx = SFXManager()

include("scripts_modjam3.rat.scripts.throwableitemlib"):Init()

---@class Card
CARD_RETAIL = Isaac.GetCardIdByName("Membership Card")

---@class EffectVariant
HOTDOG = Isaac.GetEntityVariantByName("Hotdog")

ThrowableItemLib:RegisterThrowableItem({
    Type = ThrowableItemLib.Type.CARD,
    ID = CARD_RETAIL,
    Identifier = "Retail",
    ThrowFn = function (player, vect, slot, mimic)
        local dog = Isaac.Spawn(EntityType.ENTITY_EFFECT, HOTDOG, 0, player.Position, vect * 20, player):ToEffect()
        dog.Timeout = 300
        dog.CollisionDamage = math.min(player:GetData().MeatTimer * (50/6), 5000)
        dog.SpriteOffset = Vector(0, -16)

        local sprite = player:GetHeldSprite()
        if dog and sprite then
            local dogSprite = dog:GetSprite()
            dogSprite:SetFrame(sprite:GetFrame())
            dogSprite.PlaybackSpeed = sprite.PlaybackSpeed
        end
        sfx:Play(SoundEffect.SOUND_SHELLGAME)
    end,
    AnimateFn = function (player, state)
        if state == ThrowableItemLib.State.LIFT then
            local sprite = Sprite()
            sprite:Load("gfx/effect_meatspin.anm2", true)
            sprite:Play("Idle")
            player:AnimatePickup(sprite, true, "LiftItem")
            return true
        elseif state == ThrowableItemLib.State.THROW then
            player:AnimatePickup(Sprite(), true, "HideItem")
            return true
        elseif state == ThrowableItemLib.State.HIDE then
            player:AnimatePickup(player:GetHeldSprite(), true, "HideItem")
            return true
        end
    end
    -- Flags = ThrowableItemLib.Flag.NO_DISCHARGE, -- Testing
})

---@param player EntityPlayer
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
    local throwData = ThrowableItemLib.Internal:GetData(player)
    if player:IsHoldingItem() and throwData and throwData.HeldConfig and throwData.HeldConfig.Type == ThrowableItemLib.Type.CARD and throwData.HeldConfig.ID == CARD_RETAIL then
        local data = player:GetData()
        data.MeatTimer = data.MeatTimer or 0

        data.MeatTimer = data.MeatTimer + 1
        local sprite = player:GetHeldSprite()

        if sprite then
            sprite.PlaybackSpeed = math.min(0.5 + (data.MeatTimer / 300) ^ 2, 4.5)
            if data.MeatTimer >= 600 then
                local tint = 0.5 + math.sin(math.pi * data.MeatTimer / 10) / 2
                sprite.Color:SetOffset(tint, tint, tint)
            end
        end
    else
        player:GetData().MeatTimer = 0
    end
end)

---@param effect EntityEffect
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    for _, entity in pairs(Isaac.FindInRadius(effect.Position, 60, EntityPartition.ENEMY)) do
        entity:TakeDamage(effect.CollisionDamage, DamageFlag.DAMAGE_COUNTDOWN | DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(effect), 30)
    end
end, HOTDOG)