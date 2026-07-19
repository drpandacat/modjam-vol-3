local mod = HODGEPODGE

local ACE_ACHIEVEMENTS = {
    [Achievement.ACE_OF_CLUBS] = true,
    [Achievement.ACE_OF_DIAMONDS] = true,
    [Achievement.ACE_OF_SPADES] = true,
    [Achievement.ACE_OF_HEARTS] = true,
}

local function CheckClubsUnlock()
    local pgd = Isaac.GetPersistentGameData()
    if pgd:Unlocked(mod.Achievement.LOTTA_CLUBS) then
        return
    end
    for ace in pairs(ACE_ACHIEVEMENTS) do
        if not pgd:Unlocked(ace) then
            return
        end
        pgd:TryUnlock(mod.Achievement.LOTTA_CLUBS)
    end
end

local function CheckVoidCardsUnlock()
    local pgd = Isaac.GetPersistentGameData()
    if pgd:Unlocked(mod.Achievement.VOID_CARDS) then
        return
    end
    if pgd:Unlocked(Achievement.DELIRIOUS) then
        pgd:Unlock(mod.Achievement.VOID_CARDS)
    end
end

---@param isSelected boolean
local function PostSaveFileLoad(_, _, isSelected)
    if not isSelected then
        return
    end
    CheckClubsUnlock()
    CheckVoidCardsUnlock()
end
mod:AddCallback(ModCallbacks.MC_POST_SAVESLOT_LOAD, PostSaveFileLoad)

local function PostCompletionMark(_, completionMark)
    if completionMark == CompletionType.DELIRIUM then
        Isaac.GetPersistentGameData():TryUnlock(mod.Achievement.VOID_CARDS)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_COMPLETION_EVENT, PostCompletionMark)

---@param achievement Achievement
local function PostAchievement(_, achievement)
    if ACE_ACHIEVEMENTS[achievement] then
        CheckClubsUnlock()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ACHIEVEMENT_UNLOCK, PostAchievement)