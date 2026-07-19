local ROOM_BLACKLIST = {
    [RoomType.ROOM_BOSS] = true,
    [RoomType.ROOM_DEFAULT] = true,
}

local PICKUPS_TO_SPAWN = {
    PickupVariant.PICKUP_HEART,
    PickupVariant.PICKUP_COIN,
    PickupVariant.PICKUP_KEY,
    PickupVariant.PICKUP_BOMB,
    PickupVariant.PICKUP_TRINKET,
    PickupVariant.PICKUP_PILL,
    PickupVariant.PICKUP_TAROTCARD
}

---@param player EntityPlayer
---@return GridEntityDoor?
local function getNearbyValidDoor(player)
    local room = CardjamFlipCards.GAME:GetRoom()
    local nearestDoor
    local nearestDist = 2^31
    for _, slot in pairs(DoorSlot) do
        local door = room:GetDoor(slot)
        if(door and door:GetVariant()~=DoorVariant.DOOR_HIDDEN) then
            local dist = door.Position:Distance(player.Position)
            if((not nearestDoor) or (nearestDist and dist<nearestDist)) then
                nearestDoor = door
                nearestDist = dist
            end
        end
    end

    if(nearestDoor and nearestDist<40*2.5) then
        if(not ROOM_BLACKLIST[nearestDoor.TargetRoomType]) then
            if(not (CardjamFlipCards:getUniversalData().BOARD_INDEXES or {})[nearestDoor.TargetRoomIndex]) then
                return nearestDoor
            end
        end
    end
end

---@param id Card
---@param player EntityPlayer
---@param flags UseFlag
local function useCard(_, id, player, flags)
    local door = getNearbyValidDoor(player)
    if(door) then
        local data = CardjamFlipCards:getUniversalData()
        data.BOARD_INDEXES = data.BOARD_INDEXES or {}
        data.BOARD_INDEXES[door.TargetRoomIndex] = true

        local room = CardjamFlipCards.GAME:GetRoom()
        for _, var in ipairs(PICKUPS_TO_SPAWN) do
            local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP,var,0,room:FindFreePickupSpawnPosition(player.Position,40),Vector.Zero,nil)
        end

        CardjamFlipCards.SFX:Play(SoundEffect.SOUND_WOOD_PLANK_BREAK)

        CardjamFlipCards:playAnnouncerVoice(CardjamFlipCards.SFX_VOICE_BOARD_1, flags)
    else
        if(flags & UseFlag.USE_OWNED ~= 0) then
            player:AddCard(CardjamFlipCards.CARD_BOARD)
        end
        CardjamFlipCards.SFX:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)
    end
end
CardjamFlipCards:AddCallback(ModCallbacks.MC_USE_CARD, useCard, CardjamFlipCards.CARD_BOARD)

---@param door GridEntityDoor
local function doorUpdate(_, door)
    if((CardjamFlipCards:getUniversalData().BOARD_INDEXES or {})[door.TargetRoomIndex]) then
        if(door:GetVariant()~=DoorVariant.DOOR_HIDDEN) then
            if(CardjamFlipCards.GAME:GetLevel():GetCurrentRoomDesc().Flags & RoomDescriptor.FLAG_RED_ROOM == 0) then
                door:SetVariant(DoorVariant.DOOR_LOCKED_BARRED)
                door:Close(true)
                door:Bar()

                local sp = door:GetSprite()
                local anim = sp:GetAnimationData(door.CloseAnimation) and door.CloseAnimation or "Close"
                if(sp:GetAnimationData(anim)) then
                    sp:SetFrame(anim, sp:GetAnimationData(anim):GetLength()-1)
                end
            end
        end
    end
end
CardjamFlipCards:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_DOOR_UPDATE, doorUpdate)
CardjamFlipCards:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_DOOR_UPDATE, doorUpdate)

---@param door GridEntityDoor
local function doorSpawn(_, door)
    if((CardjamFlipCards:getUniversalData().BOARD_INDEXES or {})[door.TargetRoomIndex]) then
        if(door:GetVariant()~=DoorVariant.DOOR_HIDDEN) then
            if(CardjamFlipCards.GAME:GetLevel():GetCurrentRoomDesc().Flags & RoomDescriptor.FLAG_RED_ROOM == 0) then
                local sp = door:GetSprite()
                local anim = sp:GetAnimationData(door.CloseAnimation) and door.CloseAnimation or "Close"
                if(sp:GetAnimationData(anim)) then
                    sp:SetFrame(anim, sp:GetAnimationData(anim):GetLength()-1)
                end
            end
        end
    end
end
CardjamFlipCards:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_DOOR_RENDER, doorSpawn)

local function resetBoardedDoors(_)
    if(not CardjamFlipCards.GAME:GetRoom():IsFirstVisit()) then return end
    
    CardjamFlipCards:getUniversalData().BOARD_INDEXES = {}
end
CardjamFlipCards:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, resetBoardedDoors)


---@param ent Entity?
---@param hook InputHook
---@param action ButtonAction
local function cancelCardInput(_, ent, hook, action)
    if(hook==InputHook.IS_ACTION_TRIGGERED) then
        if(action==ButtonAction.ACTION_ITEM) then
            local pl = ent and ent:ToPlayer()
            if(not (pl and pl:GetCard(0)==CardjamFlipCards.CARD_BOARD and not getNearbyValidDoor(pl))) then return end

            if(pl:GetPlayerType()==PlayerType.PLAYER_JACOB and Options.JacobEsauControls~=1) then
                if(Input.IsActionPressed(ButtonAction.ACTION_DROP, pl.ControllerIndex)) then
                    return false
                end
            end
        elseif(action==ButtonAction.ACTION_PILLCARD) then
            local pl = ent and ent:ToPlayer()
            if(not (pl and pl:GetCard(0)==CardjamFlipCards.CARD_BOARD and not getNearbyValidDoor(pl))) then return end

            if(pl:GetPlayerType()==PlayerType.PLAYER_ESAU) then
                if(Input.IsActionPressed(ButtonAction.ACTION_DROP, pl.ControllerIndex)) then
                    return false
                end
            else
                return false
            end
        end
    end
end
CardjamFlipCards:AddCallback(ModCallbacks.MC_INPUT_ACTION, cancelCardInput)