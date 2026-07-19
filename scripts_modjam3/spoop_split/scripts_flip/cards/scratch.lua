local OUTCOMES = {
    [1] = {
        ---@param player EntityPlayer
        RewardFunc = function(player) end,
        ---@param player EntityPlayer
        JackpotFunc = function(player)
            CardjamFlipCards.GAME:Fart(player.Position)

            player:UseActiveItem(CollectibleType.COLLECTIBLE_POOP, UseFlag.USE_NOANIM, -1)
        end,

        SFX = SoundEffect.SOUND_FETUS_FEET,
        RewardSFX = SoundEffect.SOUND_FETUS_FEET,
        JackpotSFX = SoundEffect.SOUND_DERP,
    },
    [2] = {
        ---@param player EntityPlayer
        RewardFunc = function(player)
            local room = CardjamFlipCards.GAME:GetRoom()
            for _=1, 3 do
                local pos = room:FindFreePickupSpawnPosition(player.Position, 40)
                local coin = Isaac.Spawn(5,PickupVariant.PICKUP_COIN,0,pos,Vector.Zero,nil):ToPickup()
            end
        end,
        ---@param player EntityPlayer
        JackpotFunc = function(player)
            local room = CardjamFlipCards.GAME:GetRoom()
            local pool = CardjamFlipCards.GAME:GetItemPool()
            
            if(pool:HasCollectible(CollectibleType.COLLECTIBLE_QUARTER)) then
                local pos = room:FindFreePickupSpawnPosition(player.Position, 40)
                local item = Isaac.Spawn(5,100,CollectibleType.COLLECTIBLE_QUARTER,pos,Vector.Zero,nil):ToPickup()

                pool:RemoveCollectible(CollectibleType.COLLECTIBLE_QUARTER)
            else
                for _=1, 15 do
                    local pos = room:FindFreePickupSpawnPosition(player.Position, 40)
                    local coin = Isaac.Spawn(5,PickupVariant.PICKUP_COIN,0,pos,Vector.Zero,nil):ToPickup()
                end
            end
        end,

        SFX = SoundEffect.SOUND_THUMBSUP,
        RewardSFX = SoundEffect.SOUND_PENNYPICKUP,
        JackpotSFX = SoundEffect.SOUND_THUMBSUP_AMPLIFIED,
    },
    [3] = {
        ---@param player EntityPlayer
        RewardFunc = function(player)
            local room = CardjamFlipCards.GAME:GetRoom()
            local pos = room:FindFreePickupSpawnPosition(player.Position, 40)
            local coin = Isaac.Spawn(5,PickupVariant.PICKUP_COIN,CoinSubType.COIN_NICKEL,pos,Vector.Zero,nil):ToPickup()
        end,
        ---@param player EntityPlayer
        JackpotFunc = function(player)
            local room = CardjamFlipCards.GAME:GetRoom()
            local pool = CardjamFlipCards.GAME:GetItemPool()

            if(pool:HasCollectible(CollectibleType.COLLECTIBLE_DOLLAR)) then
                local pos = room:FindFreePickupSpawnPosition(player.Position, 40)
                local item = Isaac.Spawn(5,100,CollectibleType.COLLECTIBLE_DOLLAR,pos,Vector.Zero,nil):ToPickup()

                pool:RemoveCollectible(CollectibleType.COLLECTIBLE_DOLLAR)
            else
                for i=1, 10 do
                    local pos = room:FindFreePickupSpawnPosition(player.Position, 40)
                    local coin = Isaac.Spawn(5,PickupVariant.PICKUP_COIN,CoinSubType.COIN_DIME,pos,Vector.Zero,nil):ToPickup()
                end
            end
        end,

        SFX = SoundEffect.SOUND_CASH_REGISTER,
        RewardSFX = SoundEffect.SOUND_NICKELPICKUP,
        JackpotSFX = CardjamFlipCards.SFX_JACKPOT,
    },
    [4] = {
        ---@param player EntityPlayer
        RewardFunc = function(player)
            local vfx = Isaac.Spawn(1000,16,4,player.Position,Vector.Zero,nil):ToEffect()
            vfx.DepthOffset = player.DepthOffset+1

            player:ResetDamageCooldown()
            player:TakeDamage(1, DamageFlag.DAMAGE_INVINCIBLE, EntityRef(player), 0)
        end,
        ---@param player EntityPlayer
        JackpotFunc = function(player)
            local vfx1 = Isaac.Spawn(1000,16,4,player.Position,Vector.Zero,nil):ToEffect()
            vfx1.DepthOffset = player.DepthOffset+1

            local vfx2 = Isaac.Spawn(1000,16,3,player.Position,Vector.Zero,nil):ToEffect()
            vfx2.DepthOffset = player.DepthOffset-1

            player:BloodExplode()

            for _=1, 10 do
                player:ResetDamageCooldown()
                player:TakeDamage(1, DamageFlag.DAMAGE_INVINCIBLE, EntityRef(player), 0)
            end

            player:Die()
        end,

        SFX = SoundEffect.SOUND_THUMBS_DOWN,
        RewardSFX = SoundEffect.SOUND_DEATH_BURST_SMALL,
        JackpotSFX = SoundEffect.SOUND_DEATH_BURST_LARGE,
    }
}

local OUTCOME_PICKER = WeightedOutcomePicker()
OUTCOME_PICKER:AddOutcomeFloat(1, 1)
OUTCOME_PICKER:AddOutcomeFloat(2, 1)
OUTCOME_PICKER:AddOutcomeFloat(3, 0.5)
OUTCOME_PICKER:AddOutcomeFloat(4, 0.35)

CardjamFlipCards.OUTCOME_BIT_BLOCK_SIZE = 3
local NUM_OUTCOMES = 3

---@param id Card
---@param player EntityPlayer
---@param flags UseFlag
local function useCard(_, id, player, flags)
    if(flags & UseFlag.USE_OWNED == 0) then
        local pos = CardjamFlipCards.GAME:GetRoom():FindFreePickupSpawnPosition(player.Position)
        local coin = Isaac.Spawn(5, PickupVariant.PICKUP_COIN, 0, pos, Vector.Zero, nil):ToPickup()

        return
    end

    local data = player:GetData().JUST_REMOVED_DATA or {}
    if(data.ID==id) then
        local value = data.Value
        local rng = player:GetCardRNG(id)

        local finalSlot = NUM_OUTCOMES
        for i=0, NUM_OUTCOMES-1 do
            local shiftedVal = (value>>(i*CardjamFlipCards.OUTCOME_BIT_BLOCK_SIZE)) & (2^CardjamFlipCards.OUTCOME_BIT_BLOCK_SIZE-1)
            if(shiftedVal==0) then
                finalSlot = i
                break
            end
        end

        if(finalSlot==NUM_OUTCOMES) then
            local outcomes = {}
            local hasJackpot = true

            for i=0, NUM_OUTCOMES-1 do
                local outcome = (value>>(i*CardjamFlipCards.OUTCOME_BIT_BLOCK_SIZE)) & (2^CardjamFlipCards.OUTCOME_BIT_BLOCK_SIZE-1)
                table.insert(outcomes, outcome)
                if(outcome~=outcomes[1]) then
                    hasJackpot = false
                end
            end

            if(hasJackpot) then
                local res = OUTCOMES[outcomes[1]]
                res.JackpotFunc(player)
                CardjamFlipCards.SFX:Play(res.JackpotSFX)
                CardjamFlipCards.SFX:Play(res.SFX)
            else
                for _, outcome in ipairs(outcomes) do
                    local res = OUTCOMES[outcome]
                    res.RewardFunc(player)
                    CardjamFlipCards.SFX:Play(res.RewardSFX)
                end
            end

            CardjamFlipCards:playAnnouncerVoice(CardjamFlipCards.SFX_VOICE_SCRATCH_1, flags)
        else
            local pickedOutcome = OUTCOME_PICKER:PickOutcome(rng)

            value = value+(pickedOutcome<<(finalSlot*CardjamFlipCards.OUTCOME_BIT_BLOCK_SIZE))

            player:AddCard(id)
            CardjamFlipCards:setCardData(player, player:GetData().INCOMING_CARD_SLOT or 0, value)

            CardjamFlipCards.SFX:Play(OUTCOMES[pickedOutcome].SFX)
        end
    end

    player:GetData().JUST_REMOVED_DATA = nil
end
CardjamFlipCards:AddCallback(ModCallbacks.MC_USE_CARD, useCard, CardjamFlipCards.CARD_SCRATCH)


local SCRATCH_SPRITE = Sprite("gfx/ui/ui_card_scratch.anm2", true)
SCRATCH_SPRITE:Play("Idle", true)
SCRATCH_SPRITE:Stop(true)

-- also stolen from kerkel
HudHelper.RegisterHUDElement({
    Name = "CARD_SCRATCH",
    Priority = HudHelper.Priority.HIGH,
    Condition = function(player)
        return (player:GetCard(0)==CardjamFlipCards.CARD_SCRATCH)
    end,
	OnRender = function(player, _, layout, position, alpha, scale)
        local val = CardjamFlipCards:getCardData(player, 0)

        for i=0, NUM_OUTCOMES-1 do
            local bitVal = (val>>(i*CardjamFlipCards.OUTCOME_BIT_BLOCK_SIZE)) & (2^CardjamFlipCards.OUTCOME_BIT_BLOCK_SIZE-1)

            SCRATCH_SPRITE:SetLayerFrame(i+1, bitVal)
        end

        SCRATCH_SPRITE.Scale = Vector(scale, scale)
        SCRATCH_SPRITE.Color = Color(1,1,1,alpha)
        SCRATCH_SPRITE:Render(position)
	end,
}, HudHelper.HUDType.POCKET)