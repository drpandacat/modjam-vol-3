---@class ModReference
local mod = RegisterMod("yara_yara", 1)

-- ---@type SaveManager
-- local sm = include("save_manager")
-- sm.Init(mod)
-- sm.Load()

local sm = {}
function sm.GetRunSave()
    return EntitySaveStateManager.GetEntityData(mod, MODJAM_VOL_3.KerkelBiddy:GetGlobalPlayer())
end

local GIFS = {
    "tom_aura",
    "trollbob",
    "yara_yara"
}
local GIF_DIMENSIONS = {
    Vector(64, 64),
    Vector(96, 120),
    Vector(64, 114)
}
local GIF_LENGTH = {
    391,
    260,
    394
}
local GIF_SCALE_MULT = {
    1.75,
    1.25,
    1.75
}

---@param gif integer
---@param scale number
---@return Vector
local function getRandomPos(gif, scale)
    local dim = GIF_DIMENSIONS[gif] * scale
    local screen = Vector(Isaac.GetScreenWidth(), Isaac.GetScreenHeight()) - dim

    return screen * Vector(math.random(), math.random())
end

for key, x in ipairs(GIFS) do GIFS[key] = "gfx/gifs/" .. x .. ".anm2" end

local musicManager = MusicManager()
local music = Isaac.GetMusicIdByName("Yara Yara")
local card = Isaac.GetCardIdByName("YaraYara")
local sprite = Sprite()
local gifPos = Vector.Zero
local gifScale = 1
local showTime = 0

---@param cardId Card
mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardId)
    if cardId ~= card then return end

    sm.GetRunSave().Play = true
    musicManager:Play(music, 1)
end)

mod:AddCallback(ModCallbacks.MC_PRE_MUSIC_PLAY_JINGLE, function()
    if not Isaac.IsInGame() or not sm.GetRunSave().Play then return end
    return false
end)

mod:AddCallback(ModCallbacks.MC_PRE_MUSIC_PLAY, function(_, musicId)
    if not Isaac.IsInGame() or not sm.GetRunSave().Play or musicId == music then return end
    if musicManager:GetCurrentMusicID() ~= music then
        musicManager:Play(music, 1)
    end
    return false
end)

mod:AddCallback(ModCallbacks.MC_PRE_SFX_PLAY, function()
    if not Isaac.IsInGame() or not sm.GetRunSave().Play then return end
    return false
end)

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    if not sm.GetRunSave().Play then return end
        
    sprite:Update()
    
    showTime = math.max(showTime - 1, 0)
    if showTime == 0 then
        local gif = math.random(#GIFS)
        gifScale = (0.75 + math.random()/2) * GIF_SCALE_MULT[gif]
        sprite:Load(GIFS[gif], true)
        sprite:Play("Idle")
        gifPos = getRandomPos(gif, gifScale)
        sprite.Scale = Vector.One * gifScale
        showTime = GIF_LENGTH[gif] + 0
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if not sm.GetRunSave().Play then return end

    sprite:Render(gifPos)
end)