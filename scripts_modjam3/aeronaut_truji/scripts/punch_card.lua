local mod = CardJam_AeroTruji
local id = mod.Enums.PUNCH_CARD

local roomPriority = {
    RoomType.ROOM_PLANETARIUM,
    RoomType.ROOM_TREASURE,
    RoomType.ROOM_SUPERSECRET,
    RoomType.ROOM_BOSS,
}

local punchCardBlacklist = {
    [LevelStage.STAGE8] = true,
}

local function PunchCardTeleport(player)
    local level = mod.Consts.Game:GetLevel()
    local roomsList = level:GetRooms()
    local newIndex
    for i = 1, #roomPriority do
        for r = 0, #roomsList - 1 do
            local roomDesc = roomsList:Get(r)
            if roomDesc.Data.Type == roomPriority[i] and roomDesc.VisitedCount == 0 then
                newIndex = roomDesc.SafeGridIndex
                break
            end
        end
        if newIndex then break end
    end
    if newIndex then
        mod.Consts.Game:StartRoomTransition(newIndex, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player)
    else
        Isaac.CreateTimer(function ()
            mod.Consts.Game:StartStageTransition(false, level:GetStage() == LevelStage.STAGE6 and 3 or 0, player)
        end, 18, 1, true)
        Isaac.CreateTimer(function ()
            local stage = level:GetStage()
            if not punchCardBlacklist[stage] then
                PunchCardTeleport(player)
            end
        end, 19, 1, true)
    end
end

---@param player EntityPlayer
mod:AddCallback(ModCallbacks.MC_USE_CARD, function (_, card, player, useflags)
    PunchCardTeleport(player)
end, id)