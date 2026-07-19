--[[
    Found HUD Helper by Kerkel
    HUD Helper by BenevolusGoat
    REPENTOGON by John sorrow
    Special thanks to Guantol Lemat
    Enjoy
    Version 1.2.1
]]

local PREFIX = "[Found HUD Helper] "
---@type string[]
local DEPENDENCIES = {
    "REPENTOGON",
    "HudHelper"
}

for _, dependency in ipairs(DEPENDENCIES) do
    if not _G[dependency] then
        error(PREFIX .. dependency .. " not found!")
    end
end

local VERSION = 4

---@type table<string, FoundHudElement>
local CACHED_ELEMENTS = {}

if FoundHUDHelper then
    if FoundHUDHelper.Internal.VERSION > VERSION then return end
    for _, v in ipairs(FoundHUDHelper.Internal.CallbackEntries) do
        FoundHUDHelper:RemoveCallback(v[1], v[3])
    end
    CACHED_ELEMENTS = FoundHUDHelper.ELEMENTS
end

FoundHUDHelper = RegisterMod("Found HUD Helper", 1)
FoundHUDHelper.Internal = {}
FoundHUDHelper.Internal.VERSION = VERSION

---@class FoundHudElement
---@field Sprite Sprite
---@field Priority number
---@field PrimaryText string?
---@field SecondaryText string?
---@field Visible boolean?
---@field Mod table

---@class FoundHudStatChange
---@field Text string
---@field Color KColor
---@field Duration integer
---@field Identifier string?
---@field Offset Vector
---@field FadeIn boolean
---@field Position Vector
---@field InitFrame integer

---@type FoundHudElement[]
FoundHUDHelper.ELEMENTS = CACHED_ELEMENTS or {}
---@type FoundHudStatChange[]
FoundHUDHelper.StatChanges = {}
FoundHUDHelper.FONT = Font()
FoundHUDHelper.GAME = Game()
FoundHUDHelper.COLOR_ICON = Color(1, 1, 1, 0.5)
FoundHUDHelper.COLOR_TEXT_PRIMARY = KColor(1, 1, 1, 0.5)
FoundHUDHelper.COLOR_TEXT_SECONDARY = KColor(1, 0.8, 0.8, 0.5)
FoundHUDHelper.OFFSET = Vector(8, 80)
FoundHUDHelper.OFFSET_TEXT_PRIMARY = Vector(8, -8)
FoundHUDHelper.OFFSET_ELEMENT = 12
FoundHUDHelper.OFFSET_ELEMENT_COOP = 2
FoundHUDHelper.OFFSET_TEXT_SECONDARY = Vector(4, 7)
FoundHUDHelper.OFFSET_TEXT_PRIMARY_COOP = Vector(0, -2)
FoundHUDHelper.OFFSET_EXTRA = Vector(0, 16)
FoundHUDHelper.NUM_ELEMENTS = 7
FoundHUDHelper.STAT_CHANGE_POS_LERP = 2 / 9
FoundHUDHelper.STAT_CHANGE_COLOR_LERP = 0.1
FoundHUDHelper.STAT_CHANGE_TARG_ALPHA = 0.45
FoundHUDHelper.STAT_CHANGE_ALPHA_POOP = 0
FoundHUDHelper.COLOR_STAT_CHANGE_POSITIVE = KColor(0.03, 0.9, 0.03, 1)
FoundHUDHelper.COLOR_STAT_CHANGE_NEGATIVE = KColor(0.9, 0.03, 0.03, 1)
FoundHUDHelper.STAT_CHANGE_DURATION = 140
FoundHUDHelper.STAT_CHANGE_POS_OFFSET = Vector(11, 4)
FoundHUDHelper.STAT_CHANGE_TARGPOS_OFFSET = Vector(27, 0)
FoundHUDHelper.STAT_CHANGE_PRIMARY_OFFSET = Vector(0, -5)
FoundHUDHelper.STAT_CHANGE_SECONDARY_OFFSET = Vector(4, 2)
FoundHUDHelper.STAT_CHANGE_DURATION_FADEIN = 15
FoundHUDHelper.STAT_CHANGE_DURATION_FULL = 150
FoundHUDHelper.STAT_CHANGE_DURATION_FADEOUT = 30
FoundHUDHelper.STAT_CHANGE_DURATION_NO_FADE_DECREASE = 30 * 3
FoundHUDHelper.STAT_CHANGE_DURATION_MIN = FoundHUDHelper.STAT_CHANGE_DURATION_FADEIN + FoundHUDHelper.STAT_CHANGE_DURATION_FADEOUT
FoundHUDHelper.STAT_CHANGE_X_OFFSET = 27
FoundHUDHelper.STAT_CHANGE_FADEIN_OFFSET = 20
FoundHUDHelper.OFFSET_POST_LUCK = 1
FoundHUDHelper.OFFSET_STAT_CHANGE_COOP = Vector(0, 3)

FoundHUDHelper.FONT:Load("font/luaminioutlined.fnt")

---@param sprite Sprite
---@param priority? number
function FoundHUDHelper:Register(mod, sprite, priority)
    if not sprite:IsPlaying() then
        sprite:Play(sprite:GetDefaultAnimation(), true)
    end

    sprite.Color = FoundHUDHelper.COLOR_ICON

    ---@type FoundHudElement
    local element = {
        Sprite = sprite,
        Priority = priority or 0,
        Mod = mod
    }

    FoundHUDHelper.ELEMENTS[#FoundHUDHelper.ELEMENTS + 1] = element

    table.sort(FoundHUDHelper.ELEMENTS, function (a, b)
        return a.Priority < b.Priority
    end)

    return element
end

---@generic T
---@param a T
---@param b T
---@param t number
---@return T
function FoundHUDHelper:Lerp(a, b, t)
    return a + (b - a) * t
end

---@generic T
---@param a T
---@param b T
---@param t number
---@return T
function FoundHUDHelper:InverseLerp(a, b, t)
    return (t - a) / (b - a)
end

function FoundHUDHelper:GetElementPosition(index)
    local players = HudHelper.GetHUDPlayers()

    if #players == 0 then
        HudHelper.PopulateHUDPlayers()
    end

    local pos = HudHelper.GetHUDPosition(1) + Vector(0, HudHelper.GetResourcesOffset().Y) + FoundHUDHelper.OFFSET
    + ((
        FoundHUDHelper.GAME.Difficulty > Difficulty.DIFFICULTY_NORMAL
        or FoundHUDHelper.GAME.Challenge > Challenge.CHALLENGE_NULL
        or FoundHUDHelper.GAME:AchievementUnlocksDisallowed()
    ) and FoundHUDHelper.OFFSET_EXTRA or Vector.Zero)

    if index > 5 and #players == 1 then
        pos.Y = pos.Y + FoundHUDHelper.OFFSET_POST_LUCK
    end

    index = index - 1

    pos.Y = pos.Y + FoundHUDHelper.OFFSET_ELEMENT * index

    if #players > 1 then
        pos.Y = pos.Y + FoundHUDHelper.OFFSET_ELEMENT_COOP * index
    end

    return pos
end

---@param element FoundHudElement
function FoundHUDHelper:GetIndex(element)
    local index = FoundHUDHelper:GetNumVanillaElements()
    local hash = GetPtrHash(element.Sprite)
    for _, v in ipairs(FoundHUDHelper.ELEMENTS) do
        if v.Visible then
            index = index + 1
            if GetPtrHash(v.Sprite) == hash then
                return index
            end
        end
    end
    return -1
end

---@param hudIndex integer
---@param text string
---@param color KColor
---@param duration? integer
---@param identifier? string
---@param offset? Vector
---@param fadeIn? boolean
---@param primary? boolean
function FoundHUDHelper:DisplayStatChange(hudIndex, text, color, duration, identifier, offset, fadeIn, primary)
    if identifier then
        for _, v in ipairs(FoundHUDHelper.StatChanges) do
            if v.Identifier == identifier then
                v.Text = text
                v.Color = KColor(color.Red, color.Green, color.Blue, v.Color.Alpha)
                v.InitFrame = FoundHUDHelper.GAME:GetFrameCount()
                return v
            end
        end
    end

    local players = HudHelper.GetHUDPlayers()

    if #players == 0 then
        HudHelper.PopulateHUDPlayers()
    end

    local pos = FoundHUDHelper:GetElementPosition(hudIndex - 1) + FoundHUDHelper.STAT_CHANGE_POS_OFFSET

    if #players > 1 then
        pos = pos + FoundHUDHelper.OFFSET_STAT_CHANGE_COOP
    end

    if primary == true then
        pos = pos + FoundHUDHelper.STAT_CHANGE_PRIMARY_OFFSET
    elseif primary == false then
        pos = pos + FoundHUDHelper.STAT_CHANGE_SECONDARY_OFFSET
    end

    if fadeIn == nil then
        fadeIn = true
    end

    duration = duration or FoundHUDHelper.STAT_CHANGE_DURATION_FULL

    if not fadeIn then
        duration = duration - FoundHUDHelper.STAT_CHANGE_DURATION_NO_FADE_DECREASE
    end

    ---@type FoundHudStatChange
    local statChange = {
        Text = text,
        Color = color,
        Duration = duration,
        Identifier = identifier,
        Offset = offset or Vector.Zero,
        FadeIn = fadeIn,
        Position = pos,
        InitFrame = FoundHUDHelper.GAME:GetFrameCount()
    }

    FoundHUDHelper.StatChanges[#FoundHUDHelper.StatChanges + 1] = statChange

    return statChange
end

function FoundHUDHelper:GetNumVanillaElements()
    return FoundHUDHelper.NUM_ELEMENTS
    ---@diagnostic disable-next-line: undefined-field
    + (Options.StatHUDPlanetarium and Isaac.GetPersistentGameData():Unlocked(Achievement.PLANETARIUMS) and 1 or 0)
    + (PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_DUALITY) and 0 or 1)
end

function FoundHUDHelper:GetNumVisibleElements()
    local num = FoundHUDHelper:GetNumVanillaElements()
    for _, v in pairs(FoundHUDHelper.ELEMENTS) do
        if v.Visible then
            num = num + 1
        end
    end
    return num
end

---@param value number
---@param sign? boolean
function FoundHUDHelper:GetFormattedValue(value, sign)
    local formatted = string.format("%.2f", value)
    if sign and value >= 0 then
        formatted = "+" .. formatted
    end
    return formatted
end

---@param value number
---@param sign? boolean
function FoundHUDHelper:GetFormattedPercentage(value, sign)
    local formatted = string.format("%.1f%%", value)
    if sign and value >= 0 then
        formatted = "+" .. formatted
    end
    return formatted
end

FoundHUDHelper.Internal.CallbackEntries = {
    {
        ModCallbacks.MC_HUD_RENDER,
        CallbackPriority.DEFAULT,
        function ()
            if not Options.FoundHUD or not FoundHUDHelper.GAME:GetHUD():IsVisible() then return end

            local room = FoundHUDHelper.GAME:GetRoom()
            if room:GetType() == RoomType.ROOM_DUNGEON and room:GetRoomConfigStage() == 35 then return end

            local index = FoundHUDHelper:GetNumVanillaElements()

            for _, v in ipairs(FoundHUDHelper.ELEMENTS) do
                if v.Visible then
                    index = index + 1

                    local pos = FoundHUDHelper:GetElementPosition(index)
                    local fontPos = pos + FoundHUDHelper.OFFSET_TEXT_PRIMARY

                    if v.SecondaryText then
                        fontPos = fontPos + FoundHUDHelper.OFFSET_TEXT_PRIMARY_COOP

                        FoundHUDHelper.FONT:DrawString(
                            v.SecondaryText,
                            fontPos.X + FoundHUDHelper.OFFSET_TEXT_SECONDARY.X,
                            fontPos.Y + FoundHUDHelper.OFFSET_TEXT_SECONDARY.Y,
                            FoundHUDHelper.COLOR_TEXT_SECONDARY
                        )
                    end

                    v.Sprite:Render(pos)

                    if v.PrimaryText then
                        FoundHUDHelper.FONT:DrawString(
                            v.PrimaryText,
                            fontPos.X + FoundHUDHelper.GAME.ScreenShakeOffset.X,
                            fontPos.Y + FoundHUDHelper.GAME.ScreenShakeOffset.Y,
                            FoundHUDHelper.COLOR_TEXT_PRIMARY
                        )
                    end
                end
            end

            local frame = FoundHUDHelper.GAME:GetFrameCount()
            ---@type FoundHudStatChange[]
            local statChanges = {}

            for _, v in ipairs(FoundHUDHelper.StatChanges) do
                local lifespan = frame - v.InitFrame

                if lifespan >= 0 and lifespan <= v.Duration then
                    local alpha = 1
                    local xOffset = 0

                    if v.FadeIn and lifespan < FoundHUDHelper.STAT_CHANGE_DURATION_FADEIN then
                        alpha = FoundHUDHelper:InverseLerp(0, FoundHUDHelper.STAT_CHANGE_DURATION_FADEIN, lifespan)
                        xOffset = ((1 - alpha) ^ 2) * -FoundHUDHelper.STAT_CHANGE_FADEIN_OFFSET
                    elseif lifespan > v.Duration - FoundHUDHelper.STAT_CHANGE_DURATION_FADEOUT then
                        alpha = FoundHUDHelper:InverseLerp(v.Duration, v.Duration - FoundHUDHelper.STAT_CHANGE_DURATION_FADEOUT, lifespan)
                    end

                    v.Color.Alpha = alpha * 0.5
                    FoundHUDHelper.FONT:DrawString(v.Text, v.Position.X + FoundHUDHelper.STAT_CHANGE_X_OFFSET + xOffset + v.Offset.X, v.Position.Y + v.Offset.Y, v.Color)
                    statChanges[#statChanges + 1] = v
                end
            end

            FoundHUDHelper.StatChanges = statChanges
        end
    },
    {
        ModCallbacks.MC_PRE_GAME_EXIT,
        CallbackPriority.DEFAULT,
        function ()
            FoundHUDHelper.StatChanges = {}
        end
    },
    {
        ModCallbacks.MC_PRE_MOD_UNLOAD,
        CallbackPriority.DEFAULT,
        function (_, mod)
            ---@type FoundHudElement[]
            local elements = {}

            for _, v in ipairs(FoundHUDHelper.ELEMENTS) do
                if v.Mod.Name ~= mod.Name then
                    elements[#elements + 1] = v
                end
            end

            FoundHUDHelper.ELEMENTS = elements
            CACHED_ELEMENTS = FoundHUDHelper.ELEMENTS
        end
    }
}

for _, v in ipairs(FoundHUDHelper.Internal.CallbackEntries) do
    FoundHUDHelper:AddPriorityCallback(v[1], v[2], v[3], v[4])
end