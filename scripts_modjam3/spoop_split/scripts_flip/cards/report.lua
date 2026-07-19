local BLOCK_DAMAGE_COOLDOWN = 30*1.5
local CLEAR_CAP = 10

---@param id Card
---@param player EntityPlayer
---@param flags UseFlag
local function useCard(_, id, player, flags)
    if(flags & UseFlag.USE_OWNED == 0) then
        player:AddHearts(1)
        player:AddNullItemEffect(CardjamFlipCards.NULL_REPORT_LUCK_UP)

        return
    end

    local data = player:GetData().JUST_REMOVED_DATA or {}
    print(data.Value)
    if(data.ID==id) then
        local value = data.Value or 0
        if(value>0) then
            player:AddHearts(value)

            local eff = player:GetEffects()
            eff:AddNullEffect(CardjamFlipCards.NULL_REPORT_LUCK_UP, true, value)

            CardjamFlipCards.SFX:Play(SoundEffect.SOUND_THUMBSUP)
        else
            CardjamFlipCards.SFX:Play(SoundEffect.SOUND_THUMBS_DOWN)
        end
    else
        CardjamFlipCards.SFX:Play(SoundEffect.SOUND_THUMBS_DOWN)
    end

    CardjamFlipCards:playAnnouncerVoice(CardjamFlipCards.SFX_VOICE_REPORT_1, flags)
end
CardjamFlipCards:AddCallback(ModCallbacks.MC_USE_CARD, useCard, CardjamFlipCards.CARD_REPORT)

---@param player EntityPlayer
local function roomClear(_, player)
    for i=0, 3 do
        if(player:GetCard(i)==CardjamFlipCards.CARD_REPORT) then
            local val = CardjamFlipCards:getCardData(player, i)
            if(val<CLEAR_CAP) then
                CardjamFlipCards:setCardData(player, i, CardjamFlipCards:getCardData(player, i)+1)

                CardjamFlipCards.SFX:Play(SoundEffect.SOUND_BEEP)
            end
        end
    end
end
CardjamFlipCards:AddCallback(ModCallbacks.MC_POST_PLAYER_TRIGGER_ROOM_CLEAR, roomClear)

---@param ent Entity
local function playerHit(_, ent, _, flags, source)
    if(source.Type==6) then return end
    if(flags & (DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_IV_BAG | DamageFlag.DAMAGE_CLONES | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_NO_PENALTIES)~=0) then return end

    local player = ent:ToPlayer()
    if(not (player and player:GetCard(0)==CardjamFlipCards.CARD_REPORT)) then return end

    player:UseCard(CardjamFlipCards.CARD_REPORT, UseFlag.USE_OWNED | UseFlag.USE_NOANIM)
    if(player:GetCard(0)==CardjamFlipCards.CARD_REPORT) then
        player:RemovePocketItem(0)
    end
    player:TakeDamage(1, DamageFlag.DAMAGE_FAKE, EntityRef(player), 0)
    player:SetMinDamageCooldown(BLOCK_DAMAGE_COOLDOWN)

    CardjamFlipCards.SFX:Play(SoundEffect.SOUND_KISS_LIPS1)

    return false
end
CardjamFlipCards:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, playerHit, EntityType.ENTITY_PLAYER)


local REPORT_SPRITE = Sprite("gfx/ui/ui_card_report.anm2", true)
REPORT_SPRITE:Play("Idle", true)
REPORT_SPRITE:Stop(true)

-- also stolen from kerkel
HudHelper.RegisterHUDElement({
    Name = "CARD_REPORT",
    Priority = HudHelper.Priority.HIGH,
    Condition = function(player)
        return (player:GetCard(0)==CardjamFlipCards.CARD_REPORT)
    end,
	OnRender = function(player, _, layout, position, alpha, scale)
        local val = CardjamFlipCards:getCardData(player, 0)
        REPORT_SPRITE:SetLayerFrame(1, math.min(math.max(0, val), 4))

        REPORT_SPRITE.Scale = Vector(scale, scale)
        REPORT_SPRITE.Color = Color(1,1,1,alpha)
        REPORT_SPRITE:Render(position)
	end,
}, HudHelper.HUDType.POCKET)