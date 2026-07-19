local this = {}

local InlandEmpireCard = Isaac.GetCardIdByName("InlandEmpire")


function this:CardUse()
    DiscoCards.DISCO_RUN_DATA.HAS_USED["INLAND EMPIRE"] = true
    DiscoCards:AddCardValue("INLAND EMPIRE",1)
end

local StageText = {
    [1] = {
        [0] = "SPAWN_BASEMENT",
        [1] = "SPAWN_CELLAR",
        [2] = "SPAWN_BURNING_BASEMENT",
        [4] = "SPAWN_DOWNPOUR",
        [5] = "SPAWN_DROSS",

    },
    [2] = {
        [0] = "SPAWN_BASEMENT",
        [1] = "SPAWN_CELLAR",
        [2] = "SPAWN_BURNING_BASEMENT",
        [4] = "SPAWN_DOWNPOUR",
        [5] = "SPAWN_DROSS",
    },
        [3] = {
        [0] = "SPAWN_CAVES",
        [1] = "SPAWN_CATACOMBS",
        [2] = "SPAWN_FLOODED_CAVES",
        [4] = "SPAWN_MINES",
        [5] = "SPAWN_ASHPIT",
    },
    [4] = {
        [0] = "SPAWN_CAVES",
        [1] = "SPAWN_CATACOMBS",
        [2] = "SPAWN_FLOODED_CAVES",
        [4] = "SPAWN_MINES",
        [5] = "SPAWN_ASHPIT",
    },
    [5] = {
        [0] = "SPAWN_DEPTHS",
        [1] = "SPAWN_NECROPOLIS",
        [2] = "SPAWN_DANK_DEPTHS",
        [4] = "SPAWN_MAUSOLEUM",
        [5] = "SPAWN_GEHENNA",
    },
    [6] = {
        [0] = "SPAWN_DEPTHS",
        [1] = "SPAWN_NECROPOLIS",
        [2] = "SPAWN_DANK_DEPTHS",
        [4] = "SPAWN_MAUSOLEUM",
        [5] = "SPAWN_GEHENNA",
    },
    [7] = {
        [0] = "SPAWN_WOMB",
        [1] = "SPAWN_UTERO",
        [2] = "SPAWN_SCARRED_WOMB",
        [3] = "SPAWN_CORPSE"
    },
    [8] = {
        [0] = "SPAWN_WOMB",
        [1] = "SPAWN_UTERO",
        [2] = "SPAWN_SCARRED_WOMB",
        [3] = "SPAWN_CORPSE"
    },
    [9] = {
        [0] = "SPAWN_BLUE_WOMB"
    },
    [10] = {
        [0] = "SPAWN_SHEOL",
        [1] = "SPAWN_CATHEDRAL"
    } ,
    [11] = {
        [0] = "SPAWN_DARKROOM",
        [1] = "SPAWN_CHEST"
    },
    [12] = {
        [0] = "SPAWN_VOID",
    },
    [13] = {
        [0] = "SPAWN_HOME",
    }
}

function this:NewLevel()
    if Game():GetFrameCount() == 0 then return end -- kerkel -_-
    if  DiscoCards.DISCO_RUN_DATA.HAS_USED["INLAND EMPIRE"] == true then 
        local TargetRoll = math.random()
        TargetRoll = 0
        if 0.5 +  DiscoCards.DISCO_RUN_DATA.LEVELS["INLAND EMPIRE"] >= TargetRoll then
            Isaac.CreateTimer(function()
                local Level = Game():GetLevel():GetStage()
                local Stage = Game():GetLevel():GetStageType()
                DiscoCards:SetText(DiscoCards:getTextData("INLAND EMPIRE", StageText[Level][Stage]))
                if DiscoCards.DISCO_RUN_DATA.LEVELS["INLAND EMPIRE"] > 10 then
                    Isaac.GetPlayer():AddSoulHearts(2)
                    Isaac.GetPlayer():AddEternalHearts(1)
                elseif DiscoCards.DISCO_RUN_DATA.LEVELS["INLAND EMPIRE"] > 5 then
                    Isaac.GetPlayer():AddSoulHearts(2)
                else 
                    Isaac.GetPlayer():AddSoulHearts(1)
                end
                DiscoCards:AddCardValue("INLAND EMPIRE",1)
            end,60,1,true)
        end
    end
end

function this:init()
    DiscoCards:AddCallback(ModCallbacks.MC_USE_CARD,this.CardUse,InlandEmpireCard)
    DiscoCards:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL,this.NewLevel)
end

return this