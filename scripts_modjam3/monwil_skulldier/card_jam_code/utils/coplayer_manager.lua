local mod = HODGEPODGE
local this = {}
local TRACKER_ID = mod.NullItemID.COPLAYER_TRACKER

local OWNER_INDEX_RNG = CollectibleType.COLLECTIBLE_SAD_ONION
local COPLAYER_POINTER_RNG = CollectibleType.COLLECTIBLE_LADDER

---@param owner EntityPlayer
---@param playerType integer | PlayerType
---@return EntityPlayer
function this.SpawnCoplayer(owner, playerType)
    local newPlayer = PlayerManager.SpawnCoPlayer2(playerType)
    newPlayer:SetControllerIndex(owner.ControllerIndex)
    newPlayer:AddNullItemEffect(TRACKER_ID, false)
    local newRNG = newPlayer:GetCollectibleRNG(COPLAYER_POINTER_RNG)
    local ownerRNG = owner:GetCollectibleRNG(OWNER_INDEX_RNG)
    newRNG:SetSeed(ownerRNG:GetSeed())
    newPlayer.Parent = owner --Thanks Fly!
    return newPlayer
end

---@param owner EntityPlayer
---@param playerType integer | PlayerType | nil
---@return EntityPlayer?
function this.FindCoPlayer(owner, playerType)
    local seed = owner:GetCollectibleRNG(1):GetSeed()
    for _, otherPlayer in ipairs(PlayerManager.GetPlayers()) do
        if otherPlayer:GetEffects():HasNullEffect(TRACKER_ID)
        and otherPlayer:GetCollectibleRNG(COPLAYER_POINTER_RNG):GetSeed() == seed
        and (not playerType or otherPlayer:GetPlayerType() == playerType) then
            return otherPlayer
        end
    end
end

---@param player EntityPlayer
---@return EntityPlayer?
function this.FindOwner(player)
    if not player:GetEffects():HasNullEffect(TRACKER_ID) then
        return end
    local seed = player:GetCollectibleRNG(COPLAYER_POINTER_RNG):GetSeed()
    for _, otherPlayer in ipairs(PlayerManager.GetPlayers()) do
        if otherPlayer:GetCollectibleRNG(OWNER_INDEX_RNG):GetSeed() == seed then
            return otherPlayer
        end
    end
end

---@param player EntityPlayer
---@return boolean
function this.IsCoplayer(player)
    return player:GetEffects():HasNullEffect(TRACKER_ID)
end

local function GameStart()
    for _, player in ipairs(PlayerManager.GetPlayers()) do
        if not player:GetEffects():HasNullEffect(TRACKER_ID) then
            goto continue end
        local owner = this.FindOwner(player)
        if not owner then
            player:SetControllerIndex(0)
        else
            player:SetControllerIndex(owner.ControllerIndex)
        end
        ::continue::
    end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, GameStart)

local function PostNewRoom()
    for _, player in ipairs(PlayerManager.GetPlayers()) do
        local owner = this.FindOwner(player)
        if owner then
            player.Position = owner.Position
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom)


return this