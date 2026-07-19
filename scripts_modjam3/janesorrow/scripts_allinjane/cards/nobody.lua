local NUM_CLEARS = 2

---@param id Card
---@param player EntityPlayer
---@param flags UseFlag
local function useCard(_, id, player, flags)
    if(flags & UseFlag.USE_OWNED == 0) then
        local pos = AllInJane.GAME:GetRoom():FindFreePickupSpawnPosition(player.Position, 40)
        local heart = Isaac.Spawn(5,PickupVariant.PICKUP_HEART,HeartSubType.HEART_BLACK,pos,Vector.Zero,nil)

        return
    end

    local data = player:GetData().JUST_REMOVED_DATA or {}
    if(data.ID==id and (data.Value or 0)>=NUM_CLEARS) then
        local rng = player:GetCardRNG(id)
        local conf = Isaac.GetItemConfig()
        local pool = AllInJane.GAME:GetItemPool()
        local itempool = AllInJane.GAME:GetRoom():GetItemPool(rng:Next())
        itempool = (itempool==ItemPoolType.POOL_NULL and ItemPoolType.POOL_TREASURE or itempool)

        local itemId
        local diddyFailsafe = 250
        repeat
            itemId = pool:GetCollectible(itempool, false, nil, CollectibleType.COLLECTIBLE_SAD_ONION)

            diddyFailsafe = diddyFailsafe-1
        until((conf:GetCollectible(itemId) and conf:GetCollectible(itemId).Quality>=3) or diddyFailsafe<=0)

        local pos = AllInJane.GAME:GetRoom():FindFreePickupSpawnPosition(player.Position, 40)
        local item = Isaac.Spawn(5,100,itemId,pos,Vector.Zero,nil)
        pool:RemoveCollectible(itemId)

        AllInJane.SFX:Play(AllInJane.SFX_JOKER)
    else
        local pos = AllInJane.GAME:GetRoom():FindFreePickupSpawnPosition(player.Position, 40)
        local heart = Isaac.Spawn(5,PickupVariant.PICKUP_HEART,HeartSubType.HEART_BLACK,pos,Vector.Zero,nil)
    end

    AllInJane:playAnnouncerVoice(AllInJane.SFX_JIMBO, flags)
end
AllInJane:AddCallback(ModCallbacks.MC_USE_CARD, useCard, AllInJane.CARD_NOBODY)

---@param player EntityPlayer
local function roomClear(_, player)
    for i=0, 3 do
        if(player:GetCard(i)==AllInJane.CARD_NOBODY) then
            local val = AllInJane:getCardData(player, i)
            if(val<NUM_CLEARS) then
                AllInJane:setCardData(player, i, AllInJane:getCardData(player, i)+1)

                AllInJane.SFX:Play(SoundEffect.SOUND_BEEP)
            end
        end
    end

    Isaac.GetItemConfig():GetCard(AllInJane.CARD_NOBODY).ModdedCardFront.Color = Color.Default
end
AllInJane:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, roomClear)

---@param player EntityPlayer
---@param pickup EntityPickup
local function destroyDroppedCard(_, player, pickup)
    pickup.Wait = 1000
    pickup.Timeout = 30

    AllInJane.SFX:Play(SoundEffect.SOUND_THUMBS_DOWN)
end
AllInJane:AddCallback(ModCallbacks.MC_POST_PLAYER_DROP_CARD, destroyDroppedCard, AllInJane.CARD_NOBODY)

-- also stolen from kerkel
HudHelper.RegisterHUDElement({
    Name = "CARD_NOBODY",
    Priority = HudHelper.Priority.HIGH,
    Condition = function (player)
        return (player:GetCard(0)==AllInJane.CARD_NOBODY and AllInJane:getCardData(player, 0)>=NUM_CLEARS)
    end,
	OnRender = function(player, _, layout, position, alpha, scale)
        local conf = Isaac.GetItemConfig():GetCard(AllInJane.CARD_NOBODY)
        local sprite = conf.ModdedCardFront
        sprite:Play(conf.HudAnim, true)

        local sin = (1 + math.sin(AllInJane.GAME:GetFrameCount() * 0.2)) / 2
        sprite.Color = Color.Lerp(Color.Default, Color(1,1,1,1,0.11,0.18,0.25), sin)
        sprite:Render(position)
	end,
}, HudHelper.HUDType.POCKET)