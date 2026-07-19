local sfx = AllInJohn.SFX

---@param id Card
---@param player EntityPlayer
---@param flags UseFlag
local function useCard(_, id, player, flags)
    Isaac.CreateTimer(
        ---@param effect EntityEffect
        function(effect)
            if(effect.FrameCount>1) then
                player:UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW, UseFlag.USE_NOANIM)
                sfx:Play(SoundEffect.SOUND_MIRROR_BREAK, 0.7, nil, nil, 1.2)
            end
        end,
        30, 1, true
    )

    sfx:Play(AllInJohn.SFX_FOIL)
    AllInJohn:playAnnouncerVoice(AllInJohn.SFX_JIMBO, flags)
end
AllInJohn:AddCallback(ModCallbacks.MC_USE_CARD, useCard, AllInJohn.CARD_EULENSPIEGEL)



local ICON_SPRITE = Sprite("gfx/ui/ui_legendary_jokers_john.anm2", true)
ICON_SPRITE:Play("Idle", true)
ICON_SPRITE:SetFrame(1)
ICON_SPRITE:Stop(true)

-- also stolen from kerkel
HudHelper.RegisterHUDElement({
    Name = "CARD_EULENSPIEGEL",
    Priority = HudHelper.Priority.HIGH,
    Condition = function(player)
        return (player:GetCard(0)==AllInJohn.CARD_EULENSPIEGEL)
    end,
	OnRender = function(player, _, layout, position, alpha, scale)
        ICON_SPRITE:SetFrame("Back", 1)
        ICON_SPRITE.Rotation = 0
        ICON_SPRITE.Scale = Vector(scale, scale)
        ICON_SPRITE.Color = Color(1,1,1,alpha)
        ICON_SPRITE:Render(position)

        ICON_SPRITE:SetFrame("Idle", 1)
        local frame = AllInJohn.GAME:GetFrameCount()
        ICON_SPRITE.Rotation = math.cos(math.rad(frame*10))*10
        ICON_SPRITE.Scale = ICON_SPRITE.Scale*(0.98+math.sin(math.rad(frame*3))*0.06)
        ICON_SPRITE:Render(position-Vector(0,3)*scale)
	end,
}, HudHelper.HUDType.POCKET)