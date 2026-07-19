if(not EID) then return end

local cardDescs = {
    [CardjamFlipCards.CARD_REPORT] = {
        Name = "Report",
        Desc = {
            "For every room cleared (max. 10) while holding this card, {{HalfHeart}} heals half a heart and grants \1 +1 Luck for the room",
--            "This effect is capped at 10 room clears",
            "On hit, this card is automatically used and the damage is blocked"
        }
    },
    [CardjamFlipCards.CARD_SCRATCH] = {
        Name = "Scratch",
        Desc = {
            "Use to reveal the 3 squares one by one, then use again to cash-out:",
            "{{ColorGray}}Grey{{CR}} - nothing",
            "{{Coin}} {{ColorYellow}}Yellow{{CR}} - 3 coins each",
            "{{Nickel}} {{ColorGreen}}Green{{CR}} - a nickel each",
            "{{HalfHeart}} {{ColorRed}}Red{{CR}} - half a heart of damage each",
            "A 3-of-a-kind triggers an amplified effect instead",
        }
    },
    [CardjamFlipCards.CARD_CHARM] = {
        Name = "Charm",
        Desc = {
            "{{Coin}} Spawns 1 coin",
            "\1 While held, grants +0.5 flat Damage and +3 Luck",
            "!!! Destroys itself when dropped",
        }
    },
    [CardjamFlipCards.CARD_BOARD] = {
        Name = "Board",
        Desc = {
            "Can only be used when near a non-boss special room door",
            "If used, boards up all entrances to that room and {{Collectible198}} spawns 1 pickup of each type",
        }
    },
    [CardjamFlipCards.CARD_REPORT_ALT] = {
        Name = "Report",
        Desc = {
            "{{Collectible638}} Erases the nearest enemy",
        }
    },
    [CardjamFlipCards.CARD_SCRATCH_ALT] = {
        Name = "Scratch",
        Desc = {
            "Using the card throws it in the direction Isaac is shooting/moving",
            "{{BleedingOut}} The card pierces and inflicts permanent bleeding (even on bosses)",
        }
    },
    [CardjamFlipCards.CARD_CHARM_ALT] = {
        Name = "Charm",
        Desc = {
            "{{Charm}} A random enemy in the room becomes friendly and gigantic",
            "Enemies with higher health are more likely to be picked",
        }
    },
    [CardjamFlipCards.CARD_BOARD_ALT] = {
        Name = "Board",
        Desc = {
            "Draws a chalk doodle on the ground",
            "{{Fear}} The chalk damages enemies and inflicts fear",
        }
    },
}

local itemDescs = {
    [CardjamFlipCards.COLLECTIBLE_DOUBLE_SIDED_CARD] = {
        Name = "Double-Sided Card",
        Desc = {
            "{{CardbackFlipFlopRed}} When used at full charge, spawns a random flip-flop card",
            "When used at partial charge, consumes 1 pip and morphs held cards:",
            "{{CardbackFlipFlopRed}} Regular <-> flipped flip-flop cards",
            "{{Card}} Regular <-> reverse tarot cards"
        }
    }
}

local iconSprite = Sprite("gfx/ui/ui_eid_cards_spoopsplit.anm2", true)
EID:addIcon("Card"..tostring(CardjamFlipCards.CARD_REPORT), "Cards", 0, 16, 16, 0, 0, iconSprite)
EID:addIcon("Card"..tostring(CardjamFlipCards.CARD_SCRATCH), "Cards", 1, 16, 16, 0, 0, iconSprite)
EID:addIcon("Card"..tostring(CardjamFlipCards.CARD_CHARM), "Cards", 2, 16, 16, 0, 0, iconSprite)
EID:addIcon("Card"..tostring(CardjamFlipCards.CARD_BOARD), "Cards", 3, 16, 16, 0, 0, iconSprite)
EID:addIcon("Card"..tostring(CardjamFlipCards.CARD_REPORT_ALT), "Cards", 4, 16, 16, 0, 0, iconSprite)
EID:addIcon("Card"..tostring(CardjamFlipCards.CARD_SCRATCH_ALT), "Cards", 5, 16, 16, 0, 0, iconSprite)
EID:addIcon("Card"..tostring(CardjamFlipCards.CARD_CHARM_ALT), "Cards", 6, 16, 16, 0, 0, iconSprite)
EID:addIcon("Card"..tostring(CardjamFlipCards.CARD_BOARD_ALT), "Cards", 7, 16, 16, 0, 0, iconSprite)

EID:addIcon("Card"..tostring(CardjamFlipCards.CARD_BOARD_ALT), "Cards", 7, 16, 16, 0, 0, iconSprite)

EID:addIcon("CardbackFlipFlopRed", "Cardbacks", 0, 16, 16, 0, 0, iconSprite)
EID:addIcon("CardbackFlipFlopBlue", "Cardbacks", 1, 16, 16, 0, 0, iconSprite)

---@param stringTable string[]
local function turnStringTableToDesc(stringTable)
    local str = ""
    for i, tableStr in ipairs(stringTable) do
        if(i>1) then str = str.."#" end
        str = str..tableStr
    end
    return str
end

for id, table in pairs(cardDescs) do
    EID:addCard(id, turnStringTableToDesc(table.Desc), table.Name, "en_us")
end

for id, table in pairs(itemDescs) do
    EID:addCollectible(id, turnStringTableToDesc(table.Desc), table.Name, "en_us")
end

local scratchOutcomes = {
    [0] = "???",
    [1] = "Grey",
    [2] = "Yellow",
    [3] = "Green",
    [4] = "Red",
}

local cardVarDataModifiers = {
    [CardjamFlipCards.CARD_REPORT] = function(val)
        return "{{ColorSilver}}"..tostring(val).." room"..(val==1 and "" or "s").." cleared{{CR}}"
    end,
    [CardjamFlipCards.CARD_SCRATCH] = function(val)
        local str = "{{ColorSilver}}"

        for i=0, 2 do
            local outcome = (val>>(i*CardjamFlipCards.OUTCOME_BIT_BLOCK_SIZE)) & (2^CardjamFlipCards.OUTCOME_BIT_BLOCK_SIZE-1)
            str = str..(i>0 and ", " or "")..(scratchOutcomes[outcome] or scratchOutcomes[0])
        end

        return str.."{{CR}}"
    end,
}

for id, result in pairs(cardVarDataModifiers) do
    EID:addDescriptionModifier(
        "CardJamFlipCardModifier"..tostring(id),
        function(descObj)
            if(descObj.ObjType==5 and descObj.ObjVariant==300 and descObj.ObjSubType==id) then
                return true
            end
            return false
        end,
        function(descObj, player)
            player = player or Isaac.GetPlayer()

            local val = 0
            if(descObj.Entity) then
                local pickup = descObj.Entity:ToPickup()
                if(pickup) then
                    val = pickup:GetVarData()
                end
            elseif(player) then
                for i=0,3 do
                    if(player:GetCard(i)==descObj.ObjSubType) then
                        val = CardjamFlipCards:getCardData(player, i)
                        break
                    end
                end
            end

            local str = result(val)
            descObj.Description = descObj.Description.."#"..str
            return descObj
        end
    )
end