--[[
Kerkel here:
I made some changes to save data necessary to merge the mods together.
Also removed debug print and fixed you trying to save entities to json. This applies to the file electro chem too
]]

-- local json = require("json")
local this = {}

local function ResetTempData()
    DiscoCards.DISCO_RUN_DATA_TEMP = {
        ELECTRO_CHEM_DATA = {
            PICKUP_TABLE = {},
        }
    }
end
ResetTempData()
DiscoCards:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, ResetTempData)
DiscoCards.DISCO_RUN_DATA = {
    LEVELS = {
         ["ELECTROCHEMISTRY"] = 0,
         ["INLAND EMPIRE"] = 0
    },
    LAST_LEVELS = {
         ["ELECTROCHEMISTRY"] = 0,
         ["INLAND EMPIRE"] = 0
    },
    HAS_USED = {
         ["ELECTROCHEMISTRY"] = false,
         ["INLAND EMPIRE"] = false
    },
    ELECTRO_CHEM_DATA = {
        PILL_ONLY_EFFECT = 0,
        -- PICKUP_TABLE = {},
        PICKUP_CONVERSION = false
    },
    CURRENT_LINE = "",
    CURRENT_CHAR = 1,
    CURRENT_TYPE = "",
    CURRENT_ID = 0,
    LAST_LINE = ""
}

local function CheckThresholds(CardType,Value)
    if DiscoCards.DISCO_RUN_DATA.LEVELS[CardType] >= 10 and DiscoCards.DISCO_RUN_DATA.LAST_LEVELS[CardType] < 10 and DiscoCards.DISCO_RUN_DATA.HAS_USED[CardType] == true then
           Isaac.CreateTimer(function()
        DiscoCards:SetText(DiscoCards:getTextData(CardType,"LEVEL_10_INTRODUCTION"))
            end,600,1,true)
    elseif DiscoCards.DISCO_RUN_DATA.LEVELS[CardType] >= 5 and DiscoCards.DISCO_RUN_DATA.LAST_LEVELS[CardType] < 5 and DiscoCards.DISCO_RUN_DATA.HAS_USED[CardType] == true then
                     Isaac.CreateTimer(function()
          DiscoCards:SetText(DiscoCards:getTextData(CardType,"LEVEL_5_INTRODUCTION"))
                 end,600,1,true)
    elseif DiscoCards.DISCO_RUN_DATA.LEVELS[CardType] >= 1 and DiscoCards.DISCO_RUN_DATA.LAST_LEVELS[CardType] < 1 and DiscoCards.DISCO_RUN_DATA.HAS_USED[CardType] == true then
          DiscoCards:SetText(DiscoCards:getTextData(CardType,"LEVEL_1_INTRODUCTION"))
    end
end

function DiscoCards:AddCardValue(CardType,Value)
    if  DiscoCards.DISCO_RUN_DATA.HAS_USED[CardType] == false then
        return
    end
    if Value == nil then
        Value = 1

    end
    DiscoCards.DISCO_RUN_DATA.CURRENT_TYPE = CardType
    DiscoCards.DISCO_RUN_DATA.LEVELS[CardType] = DiscoCards.DISCO_RUN_DATA.LEVELS[CardType] + Value
    DiscoCards.DISCO_RUN_DATA.LAST_LEVELS[CardType] =  DiscoCards.DISCO_RUN_DATA.LEVELS[CardType] - Value
    CheckThresholds(CardType,Value)
end


function this:onRunStart(Continue)
    if Continue == false then
        -- print("run")
    DiscoCards.DISCO_RUN_DATA = {
        LEVELS = {
            ["ELECTROCHEMISTRY"] = 0,
            ["INLAND EMPIRE"] = 0
        },
        LAST_LEVELS = {
            ["ELECTROCHEMISTRY"] = 0,
            ["INLAND EMPIRE"] = 0
        },
        HAS_USED = {
            ["ELECTROCHEMISTRY"] = false,
            ["INLAND EMPIRE"] = false
        },
        ELECTRO_CHEM_DATA = {
            PILL_ONLY_EFFECT = 0,
            -- PICKUP_TABLE = {},
            PICKUP_CONVERSION = false
        },
        CURRENT_LINE = "",
        CURRENT_CHAR = 1,
        CURRENT_TYPE = "",
        CURRENT_ID = 0,
        LAST_LINE = ""
    }
    else
        local save = MODJAM_VOL_3.SaveManager.GetRunSave()
        save.DISCO_RUN_DATA = save.DISCO_RUN_DATA or {}
        DiscoCards.DISCO_RUN_DATA = save.DISCO_RUN_DATA
        -- if DiscoCards:HasData() then
        --     local Data = json.decode(DiscoCards:LoadData())
        --     DiscoCards.DISCO_RUN_DATA = Data
        -- end
    end
end

function this:onExit()
  MODJAM_VOL_3.SaveManager.GetRunSave().DISCO_RUN_DATA = DiscoCards.DISCO_RUN_DATA or {}
--   local jsonString = json.encode(DISCO_RUN_DATA)
--   DiscoCards:SaveData(jsonString)
end

local function PlayChatter()
    local Data =  DiscoCards:getVoiceData(DiscoCards.DISCO_RUN_DATA.CURRENT_TYPE)
    SFXManager():Stop(Data.SFX)
    SFXManager():Play(Data.SFX, Data.VOLUME, 0, false, Data.PITCH + (math.random() * .5))
end

function DiscoCards:SetText(Line)
    DiscoCards.DISCO_RUN_DATA.LAST_LINE = DiscoCards.DISCO_RUN_DATA.CURRENT_LINE
    DiscoCards.DISCO_RUN_DATA.CURRENT_LINE = Line
    DiscoCards.DISCO_RUN_DATA.CURRENT_CHAR = 0
    for i=1, string.len(DiscoCards.DISCO_RUN_DATA.CURRENT_LINE), 1 do
        Isaac.CreateTimer(function()
                if  DiscoCards.DISCO_RUN_DATA.CURRENT_LINE == "" then
                    return
                end
                if DiscoCards.DISCO_RUN_DATA.CURRENT_CHAR <  string.len(DiscoCards.DISCO_RUN_DATA.CURRENT_LINE) then
                    DiscoCards.DISCO_RUN_DATA.CURRENT_CHAR = DiscoCards.DISCO_RUN_DATA.CURRENT_CHAR + 1
                end
                PlayChatter()
            end,
            i,
            1,
            true
        )
    end
     Isaac.CreateTimer(function()
             DiscoCards.DISCO_RUN_DATA.CURRENT_LINE = ""
     end,
         300,
         1,
         false)
end

local CardUI = Sprite()
CardUI:Load("gfx/ui/ui_CardUI.anm2", true)

function this:DialgoueHandler()
    if DiscoCards.DISCO_RUN_DATA.CURRENT_LINE ~= "" then
        CardUI:Play(DiscoCards.DISCO_RUN_DATA.CURRENT_TYPE,false)
        CardUI.Scale = Vector(.5,.5)
        CardUI:SetFrame(DiscoCards.DISCO_RUN_DATA.CURRENT_CHAR % 8)
        CardUI:Render(Vector(170,40))
    end
    local Dlog = Font() -- init font object
    Dlog:Load("font/luaminioutlined.fnt") -- load a font into the font object
    Dlog:DrawStringScaled(string.sub(DiscoCards.DISCO_RUN_DATA.CURRENT_LINE,1,DiscoCards.DISCO_RUN_DATA.CURRENT_CHAR),
       200,22, 1,1,KColor(0,0,0,.8),0,true)
    Dlog:DrawStringScaled(string.sub(DiscoCards.DISCO_RUN_DATA.CURRENT_LINE,1,DiscoCards.DISCO_RUN_DATA.CURRENT_CHAR),
       200,21, 1,1,DiscoCards:getColour(DiscoCards.DISCO_RUN_DATA.CURRENT_TYPE),0,true)
end

function this:NewRoom()
    DiscoCards.DISCO_RUN_DATA.CURRENT_LINE = ""
end

function this:init()
    DiscoCards:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, this.onRunStart)
    DiscoCards:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, this.onExit)
    DiscoCards:AddCallback(ModCallbacks.MC_POST_RENDER,this.DialgoueHandler)
    DiscoCards:AddCallback(ModCallbacks.MC_POST_NEW_ROOM,this.NewRoom)

end

return this