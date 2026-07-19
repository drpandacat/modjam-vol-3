---@param id Card
---@param player EntityPlayer
---@param flags UseFlag
local function useCard(_, id, player, flags)
    local nearestEnemy
    local nearestDist = 2^31

    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        if(ent:ToNPC() and ent:IsEnemy() and ent:IsActiveEnemy(false)) then
            local dist = ent.Position:Distance(player.Position)
            if((not nearestEnemy) or dist<nearestDist) then
                nearestEnemy = ent
                nearestDist = dist
            end
        end
    end

    if(nearestEnemy) then
        local eraser = Isaac.Spawn(2,45,0,Vector.Zero,Vector.Zero,nil)
        eraser:ForceCollide(nearestEnemy, true)
        eraser:Remove()

        CardjamFlipCards.SFX:Play(SoundEffect.SOUND_EDEN_GLITCH,0.7)
        CardjamFlipCards.SFX:Play(CardjamFlipCards.SFX_ERROR,nil,nil,nil,0.975+math.random()*0.05)
        CardjamFlipCards.SFX:Stop(857)
    end

    CardjamFlipCards:playAnnouncerVoice(CardjamFlipCards.SFX_VOICE_REPORT_2, flags)
end
CardjamFlipCards:AddCallback(ModCallbacks.MC_USE_CARD, useCard, CardjamFlipCards.CARD_REPORT_ALT)