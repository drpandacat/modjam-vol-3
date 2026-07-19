local sfx = AllInJohn.SFX

---@param id Card
---@param player EntityPlayer
---@param flags UseFlag
local function useCard(_, id, player, flags)
    local pool = AllInJohn.GAME:GetItemPool()
    local rng = player:GetCardRNG(id)

    local conf = Isaac.GetItemConfig()
    local desc = player:GetActiveItemDesc(0)
    local iconf = conf:GetCollectible(desc.Item)

    local numItems = player:GetTotalActiveCharge(0)
    if(iconf) then
        if(iconf.ChargeType==ItemConfig.CHARGE_TIMED or iconf.ChargeType==ItemConfig.CHARGE_SPECIAL) then
            numItems = 1
        end
    end

    if(numItems==0) then
        Isaac.CreateTimer(
            function()
                local itemId = CollectibleType.COLLECTIBLE_THE_WIZ

                player:AddInnateCollectible(itemId, 1, "AllInJohnSilvioItems")

                player:AnimateCollectible(itemId, "UseItem")
                sfx:Play(SoundEffect.SOUND_DERP)
                AllInJohn.GAME:Fart(player.Position)
            end,
            9, 1, false
        )
    else
        Isaac.CreateTimer(
            function()
                local itempool = AllInJohn.GAME:GetRoom():GetItemPool(rng:Next())
                itempool = (itempool==ItemPoolType.POOL_NULL and ItemPoolType.POOL_TREASURE or itempool)

                local itemId
                repeat
                    itemId = pool:GetCollectible(itempool, false, nil, CollectibleType.COLLECTIBLE_THE_WIZ, GetCollectibleFlag.BAN_ACTIVES)
                until(conf:GetCollectible(itemId) and conf:GetCollectible(itemId):HasTags(ItemConfig.TAG_SUMMONABLE))

                player:AddInnateCollectible(itemId, 1, "AllInJohnSilvioItems")

                player:AnimateCollectible(itemId, "UseItem")
                sfx:Play(SoundEffect.SOUND_POWERUP1)
            end,
            9, numItems, false
        )
    end

    sfx:Play(AllInJohn.SFX_JOKER,1.3)
    AllInJohn:playAnnouncerVoice(AllInJohn.SFX_JIMBO, flags)
end
AllInJohn:AddCallback(ModCallbacks.MC_USE_CARD, useCard, AllInJohn.CARD_SILVIO)

---@param pl EntityPlayer
local function removeSilvioItems(_, pl)
    pl:SetInnateCollectibleGroup("AllInJohnSilvioItems", {})
end
AllInJohn:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, removeSilvioItems)

local ICON_SPRITE = Sprite("gfx/ui/ui_legendary_jokers_john.anm2", true)
ICON_SPRITE:Play("Idle", true)
ICON_SPRITE:SetFrame(0)
ICON_SPRITE:Stop(true)

-- also stolen from kerkel
HudHelper.RegisterHUDElement({
    Name = "CARD_SILVIO",
    Priority = HudHelper.Priority.HIGH,
    Condition = function(player)
        return (player:GetCard(0)==AllInJohn.CARD_SILVIO)
    end,
	OnRender = function(player, _, layout, position, alpha, scale)
        ICON_SPRITE:SetFrame("Back", 0)
        ICON_SPRITE.Rotation = 0
        ICON_SPRITE.Scale = Vector(scale, scale)
        ICON_SPRITE.Color = Color(1,1,1,alpha)
        ICON_SPRITE:Render(position)

        ICON_SPRITE:SetFrame("Idle", 0)
        local frame = AllInJohn.GAME:GetFrameCount()
        ICON_SPRITE.Rotation = math.cos(math.rad(frame*10))*10
        ICON_SPRITE.Scale = ICON_SPRITE.Scale*(0.98+math.sin(math.rad(frame*3))*0.06)
        ICON_SPRITE:Render(position-Vector(0,3)*scale)
	end,
}, HudHelper.HUDType.POCKET)