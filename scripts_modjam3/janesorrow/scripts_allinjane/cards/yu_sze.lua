--[[
Yu Sze
 - every boss item you have is doubled for the room
]]

---@param id Card
---@param player EntityPlayer
---@param flags UseFlag
local function useCard(_, id, player, flags)
    local history = player:GetHistory():GetCollectiblesHistory()
    for _, itemData in pairs(history) do
        if(itemData:GetItemPoolType()==ItemPoolType.POOL_BOSS or itemData:GetItemPoolType()==ItemPoolType.POOL_GREED_BOSS) then
            player:AddInnateCollectible(itemData:GetItemID(), 1, "AllInJaneTalhak")
        end
    end

    AllInJane.SFX:Play(AllInJane.SFX_BALANCE)
    AllInJane:playAnnouncerVoice(AllInJane.SFX_JIMBO, flags)
end
AllInJane:AddCallback(ModCallbacks.MC_USE_CARD, useCard, AllInJane.CARD_YU_SZE)

---@param pl EntityPlayer
local function removeYuSzeItems(_, pl)
    pl:SetInnateCollectibleGroup("AllInJaneTalhak", {})
end
AllInJane:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, removeYuSzeItems)

local ICON_SPRITE = Sprite("gfx/ui/ui_legendary_jokers_jane.anm2", true)
ICON_SPRITE:Play("Idle", true)
ICON_SPRITE:SetFrame(1)
ICON_SPRITE:Stop(true)

-- also stolen from kerkel
HudHelper.RegisterHUDElement({
    Name = "CARD_YU_SZE",
    Priority = HudHelper.Priority.HIGH,
    Condition = function(player)
        return (player:GetCard(0)==AllInJane.CARD_YU_SZE)
    end,
	OnRender = function(player, _, layout, position, alpha, scale)
        ICON_SPRITE:SetFrame("Back", 1)
        ICON_SPRITE.Rotation = 0
        ICON_SPRITE.Scale = Vector(scale, scale)
        ICON_SPRITE.Color = Color(1,1,1,alpha)
        ICON_SPRITE:Render(position)

        ICON_SPRITE:SetFrame("Idle", 1)
        local frame = AllInJane.GAME:GetFrameCount()
        ICON_SPRITE.Rotation = math.cos(math.rad(frame*10))*10
        ICON_SPRITE.Scale = ICON_SPRITE.Scale*(0.98+math.sin(math.rad(frame*3))*0.06)
        ICON_SPRITE:Render(position-Vector(0,2)*scale)
	end,
}, HudHelper.HUDType.POCKET)