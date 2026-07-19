local Mod = ModJamHolder
local RED = {}
ModJamHolder.Card.RED = RED
RED.NAME = "Determination Card"
RED.ID = Isaac.GetCardIdByName(RED.NAME)
RED.SPEED_NULL = Isaac.GetNullItemIdByName("Refusal Buffs")

RED.REFUSAL_EFFECT_ID = Isaac.GetEntityVariantByName("Death Refusal")

RED.HP = 2

--[[
RED.SFX = Isaac.GetSoundIdByName("RED")
RED.SFX_ALT = Isaac.GetSoundIdByName("Cultivate")
RED.SFX_ALT_CHANCE = 0.2]]

RED.WIKI = {
    { -- Effect
        { str = "Effect", fsize = 2, clr = 3, halign = 0 },
        { str = "On use, grants a temporary speed boost, tears up and fully charges Isaac's active item." },
        { str = "When getting hit would remove your last red heart, nullify it and heal one full red heart." },
        { str = "Additionally triggers and doubles the on use effects." },
        { str = "The boosted effect also triggers when Isaac does not have any heart containers." },
        { str = "Triggering it that way will grant Isaac an extra heart container, if not a full soul heart." },

    },
    { -- Trivia
        { str = "Trivia", fsize = 2, clr = 3, halign = 0 },
        { str = "Art by Reixen" },
        { str = "Code by dpower12" },
        { str = "" },
        { str = "" },
    },
}

RED.EID = "Grants a temporary {{Speed}}, {{Tears}} boost and fully charges Isaac's active item"..
        "#This card is automatically used and doubles its effects when getting hit loses Isaac's last red heart"..
        "#Additionally heals one {{Heart}}, or adds a heart container if Isaac does not have any when hit"


---@param player EntityPlayer
---@return boolean
function RED:IsAnyLost(player)
    if Epiphany then
        return Epiphany:IsAnyLost(player)
    else
        return player:GetPlayerType() == PlayerType.PLAYER_THELOST
            or player:GetPlayerType() == PlayerType.PLAYER_THELOST_B
    end
end

---@param player EntityPlayer
---@param dAmount integer
function RED:ShouldRefuse(player, dAmount)
    local containers = player:GetMaxHearts()
	local hearts = (player:GetHearts() - player:GetRottenHearts() * 2)
	if containers <= 0 or hearts - dAmount <= 0 then
		return true
	else
		return false
	end
end

---@param player EntityPlayer
function RED:AddCharge(player, mult)
    local itemID = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
    if itemID > 0 then
        local config = Isaac.GetItemConfig():GetCollectible(itemID)
        if config.ChargeType == ItemConfig.CHARGE_NORMAL then
            player:SetActiveCharge(config.MaxCharges * mult, ActiveSlot.SLOT_PRIMARY)
        end
    end
    local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HEART, 1, player.Position, Vector.Zero, nil):ToEffect() ---@cast fx EntityEffect
    fx.SpriteOffset = Vector(0, -50)
    fx:FollowParent(player)
    Mod.SfxMan:Play(SoundEffect.SOUND_BATTERYCHARGE)
end

---@param player EntityPlayer
---@param dAmount integer
function RED:Refuse(player, dAmount)
    if not RED:IsAnyLost(player) then
        if player:GetHealthType() == HealthType.SOUL then
            player:AddSoulHearts(-dAmount)
            player:AddSoulHearts(RED.HP)
        else
            player:AddHearts(-dAmount)
            player:AddSoulHearts(-dAmount)
            player:AddRottenHearts(-(dAmount * 2))
            if player:GetMaxHearts() == 0 then
                player:AddMaxHearts(RED.HP, true)
            end
            player:AddHearts(RED.HP)
        end
    end
    RED:AddCharge(player, 2)
    player:AddNullItemEffect(RED.SPEED_NULL)
end

function RED:ActiveEffect(player)
    RED:AddCharge(player, 1)
    player:AddNullItemEffect(RED.SPEED_NULL)
end

---@param ent Entity
---@param amount integer
function RED:OnTakeDmg(ent, amount)
	local player = ent:ToPlayer()
	if player
		and player:GetCard(ActiveSlot.SLOT_PRIMARY) == RED.ID
		and RED:ShouldRefuse(player, amount)
	then
        player:RemovePocketItem(PillCardSlot.PRIMARY)
        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, RED.REFUSAL_EFFECT_ID, 0, player.Position, Vector.Zero, player):ToEffect() ---@cast effect EntityEffect
        effect.SpriteOffset = Vector(0, -50)
        effect.DepthOffset = player.DepthOffset + 5
        effect:FollowParent(player)
        effect:GetData().MJ_amount = amount

        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF04, 3, effect.Position, Vector.Zero, nil):ToEffect() ---@cast poof EntityEffect
        poof:FollowParent(player)
        poof.SpriteOffset = Vector(0, -50)
        Mod.SfxMan:Play(SoundEffect.SOUND_MEATY_DEATHS)

        player:PlayExtraAnimation("Hit")
        Mod.SfxMan:Play(SoundEffect.SOUND_ISAAC_HURT_GRUNT)
        player:SetMinDamageCooldown(240)
		return false
	end
end
Mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.EARLY, RED.OnTakeDmg, EntityType.ENTITY_PLAYER)

---@param player EntityPlayer
function RED:OnUseCard(_, player)
    RED:ActiveEffect(player)
end
Mod:AddCallback(ModCallbacks.MC_USE_CARD, RED.OnUseCard, RED.ID)

---@param effect EntityEffect
function RED:OnEffectUpdate(effect)
    if effect.Parent == nil then return end
    local sprite = effect:GetSprite()
    if sprite:IsEventTriggered("Merge") then
        local player = effect.Parent and effect.Parent:ToPlayer()
        if player then
            Mod.SfxMan:Play(SoundEffect.SOUND_POWERUP_SPEWER)
            player:PlayExtraAnimation("Happy")
            player:SetColor(Color(1, 1, 1, 1, 0.6, 0.35, 0.2), 20, 1, true, true)

            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF04, 3, effect.Position, Vector.Zero, nil):ToEffect() ---@cast poof EntityEffect
            poof:FollowParent(player)
            poof.Color = Color(1, 1, 1, 1, 3, 3, 3)
            poof.SpriteOffset = Vector(0, -50)

            RED:ActiveEffect(player)
            RED:Refuse(player, effect:GetData().MJ_amount)
        end
    elseif sprite:IsFinished()  then
        effect:Remove()
    end
end
Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, RED.OnEffectUpdate, RED.REFUSAL_EFFECT_ID)