local EXTRA_ROLL_SPEEDSCALE = 1
local EXTRA_ROLL_NUM = 2

local VALID_BEGGARS = {
    [SlotVariant.BEGGAR] = true,
    [SlotVariant.DEVIL_BEGGAR] = true,
    [SlotVariant.KEY_MASTER] = true,
    [SlotVariant.ROTTEN_BEGGAR] = true,
    [SlotVariant.BOMB_BUM] = true,
    [SlotVariant.BATTERY_BUM] = true,
}

---@param id Card
---@param player EntityPlayer
---@param flags UseFlag
local function useCard(_, id, player, flags)
    local data = AllInJane:getUniversalData()
    if(data.BEANSTALK_ACTIVE) then
        local pos = AllInJane.GAME:GetRoom():FindFreePickupSpawnPosition(player.Position, 40)
        local beggar = Isaac.Spawn(6,SlotVariant.BEGGAR,0,pos,Vector.Zero,nil)
        local poof = Isaac.Spawn(1000,15,2,beggar.Position,Vector.Zero,nil)
    else
        data.BEANSTALK_ACTIVE = true
    end

    AllInJane.SFX:Play(AllInJane.SFX_BALANCE)
    AllInJane:playAnnouncerVoice(AllInJane.SFX_JIMBO, flags)
end
AllInJane:AddCallback(ModCallbacks.MC_USE_CARD, useCard, AllInJane.CARD_BEANSTALK)

---@param slot EntitySlot
local function slotUpdate(_, slot)
    if(not AllInJane:getUniversalData().BEANSTALK_ACTIVE) then return end

    local data = slot:GetData()
    local sp = slot:GetSprite()

    if(slot:GetDonationValue()%2==0) then
        slot:SetDonationValue(slot:GetDonationValue()+1)
    end

    if(slot:GetState()==SlotState.REWARD) then
        if(data.BEANSTALK_ROLLS==nil) then
            data.BEANSTALK_ROLLS = EXTRA_ROLL_NUM
            if(EXTRA_ROLL_NUM>0) then
                data.BEANSTALK_DATA = {
                    Anim = sp:GetAnimation(),
                    OverlayAnim = sp:GetOverlayAnimation(),
                    Timeout = slot:GetTimeout(),
                    PlaybackSpeed = sp.PlaybackSpeed,
                    LayerFrames = {},
                    StopAnim = sp:IsPlaying(),
                    StopOverlayAnim = sp:IsOverlayPlaying(),
                }
                for _, layer in ipairs(sp:GetCurrentAnimationData():GetAllLayers()) do
                    local lID = layer:GetLayerID()
                    if(sp:GetLayerFrameData(lID)) then
                        data.BEANSTALK_DATA.LayerFrames[lID] = sp:GetLayerFrameData(lID):GetStartFrame()
                    end
                end
            end
        end
    elseif(slot:GetState()==SlotState.IDLE) then
        if(data.BEANSTALK_ROLLS) then
            if(data.BEANSTALK_ROLLS==0) then
                data.BEANSTALK_ROLLS = nil
                data.BEANSTALK_DATA = nil
            else
                data.BEANSTALK_ROLLS = data.BEANSTALK_ROLLS-1
                if(data.BEANSTALK_DATA) then
                    sp.PlaybackSpeed = EXTRA_ROLL_SPEEDSCALE
                    sp:Play(data.BEANSTALK_DATA.Anim, true)
                    sp:PlayOverlay(data.BEANSTALK_DATA.OverlayAnim, true)

                    if(not data.BEANSTALK_DATA.StopAnim) then
                        sp:Stop(false)
                    end
                    if(not data.BEANSTALK_DATA.StopOverlayAnim) then
                        sp:StopOverlay()
                    end

                    if(slot.Variant==SlotVariant.DONATION_MACHINE or slot.Variant==SlotVariant.GREED_DONATION_MACHINE) then
                        local pgd = Isaac.GetPersistentGameData()
                        local val = (slot.Variant==SlotVariant.GREED_DONATION_MACHINE and pgd:GetEventCounter(EventCounter.GREED_DONATION_MACHINE_COUNTER) or pgd:GetEventCounter(EventCounter.DONATION_MACHINE_COUNTER))

                        sp:SetLayerFrame(3, (val)%10)
                        sp:SetLayerFrame(2, (val//10)%10)
                        sp:SetLayerFrame(1, (val//100)%10)
                    end

                    slot:SetTimeout(data.BEANSTALK_DATA.Timeout//EXTRA_ROLL_SPEEDSCALE)
                end
                slot:SetState(SlotState.REWARD)
            end
        end
    end
end
AllInJane:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, slotUpdate)

---@param pl EntityPlayer
local function removeJerkoStats(_, pl)
    local data = AllInJane:getUniversalData(pl)
    if(data.BEANSTALK_ACTIVE) then
        data.BEANSTALK_ACTIVE = nil
    end
end
AllInJane:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, removeJerkoStats)