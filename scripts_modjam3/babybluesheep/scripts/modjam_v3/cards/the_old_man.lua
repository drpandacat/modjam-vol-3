local game = Game()
local sfxManager = SFXManager()



ModJamV3.Cards.TheOldMan = {}
ModJamV3.Cards.TheOldMan.CARD_TYPE = Isaac.GetCardIdByName("The Old Man")

local applicableCurses =
{
    LevelCurse.CURSE_OF_BLIND,
    --LevelCurse.CURSE_OF_DARKNESS, no fade-in, looks weird TODO: fix this??
    LevelCurse.CURSE_OF_MAZE,
    LevelCurse.CURSE_OF_THE_LOST,
    LevelCurse.CURSE_OF_THE_UNKNOWN
}

local RoomClearStatus = {
    NONEXISTENT = 0,
    UNVISITED = 1,
    UNCLEARED = 2,
    CLEARED = 3,
}

local function InitializeArrays()
    local level = game:GetLevel()

    local globalSave = EntitySaveStateManager.GetEntityData(ModJamV3, Isaac.GetPlayer(0))

    globalSave.VisitedRooms = {}
    globalSave.VisitedRoomsWithOldMan = {}

    local roomDescriptors = level:GetRooms()
    for i = 0, #roomDescriptors - 1 do
        globalSave.VisitedRooms[i + 1] = RoomClearStatus.NONEXISTENT
        globalSave.VisitedRoomsWithOldMan[i + 1] = RoomClearStatus.NONEXISTENT
    
        local roomDescriptor = roomDescriptors:Get(i)
        if roomDescriptor.Data == nil then goto continue end

        if roomDescriptor.Data.Type ~= RoomType.ROOM_DEFAULT then goto continue end

        globalSave.VisitedRooms[i] = RoomClearStatus.UNVISITED
        globalSave.VisitedRoomsWithOldMan[i] = RoomClearStatus.UNVISITED

        ::continue::
    end
end

---@param card Card
---@param player EntityPlayer
---@param useFlags UseFlag
ModJamV3:AddCallback(ModCallbacks.MC_USE_CARD, function (_, card, player, useFlags)

    local room = game:GetRoom()
    if PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then
        
        for i = 1, 2 do
            local position = room:FindFreePickupSpawnPosition(player.Position, 40)
            Isaac.Spawn
            (
                EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK,
                position, Vector.Zero,
                nil
            )
        end
        
        return
    end
    
    local level = game:GetLevel()

    local allCurses = 0
    for _, curse in ipairs(applicableCurses) do
        allCurses = allCurses | curse
    end

    if level:GetCurses() & allCurses == allCurses then
        sfxManager:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)
        if useFlags & UseFlag.USE_OWNED == UseFlag.USE_OWNED then
            player:AddCard(ModJamV3.Cards.TheOldMan.CARD_TYPE)
        end
        return
    end

    while true do
        local curseToApply = applicableCurses[player:GetCardRNG(card):RandomInt(#applicableCurses) + 1]

        if level:GetCurses() & curseToApply == curseToApply then goto continue end

        level:AddCurse(curseToApply, true)
        break

        ::continue::
    end

    game:Darken(1, 60 * 2)
    sfxManager:Play(SoundEffect.SOUND_SATAN_GROW)

    local globalSave = EntitySaveStateManager.GetEntityData(ModJamV3, Isaac.GetPlayer(0))
    globalSave.HadOldManActivated = true

end, ModJamV3.Cards.TheOldMan.CARD_TYPE)


ModJamV3:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function (_)
    local roomDesc = game:GetLevel():GetCurrentRoomDesc()
    local roomListIndex = roomDesc.ListIndex

    local globalSave = EntitySaveStateManager.GetEntityData(ModJamV3, Isaac.GetPlayer(0))

    if globalSave.HadOldManActivated == nil then
        globalSave.HadOldManActivated = false
    end

    if globalSave.VisitedRooms == nil or globalSave.VisitedRoomsWithOldMan == nil then
        InitializeArrays()
    end

    if globalSave.VisitedRooms[roomListIndex] == RoomClearStatus.UNVISITED then
        globalSave.VisitedRooms[roomListIndex] = RoomClearStatus.CLEARED
        if globalSave.HadOldManActivated then
            globalSave.VisitedRoomsWithOldMan[roomListIndex] = RoomClearStatus.CLEARED
        else
            globalSave.VisitedRoomsWithOldMan[roomListIndex] = RoomClearStatus.UNCLEARED
        end
    end
end)

---@param curses integer
ModJamV3:AddPriorityCallback(ModCallbacks.MC_POST_CURSE_EVAL, CallbackPriority.LATE, function (_, curses)
    local globalSave = EntitySaveStateManager.GetEntityData(ModJamV3, Isaac.GetPlayer(0))

    if globalSave.HadOldManActivated == nil then return end

    if globalSave.HadOldManActivated == true then
        local amountOfUnvisitedRooms = 0
        local amountOfVisitedRooms = 0
        local amountOfVisitedRoomsWithOldMan = 0

        for i = 1, #globalSave.VisitedRooms do
            if globalSave.VisitedRooms[i] == RoomClearStatus.UNVISITED then
                amountOfUnvisitedRooms = amountOfUnvisitedRooms + 1
            elseif globalSave.VisitedRooms[i] == RoomClearStatus.CLEARED then
                amountOfVisitedRooms = amountOfVisitedRooms + 1

                if globalSave.VisitedRoomsWithOldMan[i] == RoomClearStatus.CLEARED then
                    amountOfVisitedRoomsWithOldMan = amountOfVisitedRoomsWithOldMan + 1
                end
            end
        end

        local chanceToRemoveCurse = 1.5 * (amountOfVisitedRoomsWithOldMan + 1) / (amountOfVisitedRooms + amountOfUnvisitedRooms * 0.75 + 1)

        local rng = Isaac.GetPlayer(0):GetCardRNG(ModJamV3.Cards.TheOldMan.CARD_TYPE)
        local rolledChance = rng:RandomFloat()

        if rolledChance < chanceToRemoveCurse then
            globalSave.ProccedOldMan = true

            return 0
        end
    end
end)

ModJamV3:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function (_)
    local globalSave = EntitySaveStateManager.GetEntityData(ModJamV3, Isaac.GetPlayer(0))

    if globalSave.ProccedOldMan == true then
        Isaac.CreateTimer(function ()
            game:ShakeScreen(30)
            game:Darken(1.0, 30)
        end, 15, 1, true)
        Isaac.CreateTimer(function ()
            sfxManager:Play(SoundEffect.SOUND_SATAN_RISE_UP)
        end, 20, 1, true)
    end

    globalSave.ProccedOldMan = false
end)

ModJamV3:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function (_)
    local globalSave = EntitySaveStateManager.GetEntityData(ModJamV3, Isaac.GetPlayer(0))

    globalSave.HadOldManActivated = false

    InitializeArrays()
end)