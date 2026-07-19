if(not EID) then return end

local cardDescs = {
    [AllInJane.CARD_NOBODY] = {
        Name = "Nobody",
        Desc = {
            "{{BlackHeart}} Spawns a Black Heart",
            "After clearing 2 floors, it instead spawns a random item from the current room's item pool",
            "The item's quality is always 3 or higher",
            "!!! Destroys itself when dropped"
        }
    },
    [AllInJane.CARD_PARTY_TIME] = {
        Name = "Party Time",
        Desc = {
            "{{Timer}} For the next 20 seconds, killing an enemy permanently grants \1 +0.03 Fire rate",
        }
    },
    [AllInJane.CARD_JERKO] = {
        Name = "Jerko",
        Desc = {
            "\1 +0.25 flat Damage for the room",
            "Triggers on-hit effects",
            "On use, retriggers its effect 0-10 additional times"
        }
    },
    [AllInJane.CARD_BEANSTALK] = {
        Name = "Beanstalk",
        Desc = {
            "{{Beggar}} For the rest of the room, beggars pay out twice as often and pay out three times in a row",
            "Additional uses in the same room spawn a beggar",
        }
    },
    [AllInJane.CARD_NEGATIVE_NANCY] = {
        Name = "Negative Nancy",
        Desc = {
            "{{Planetarium}} +9% Planetarium chance",
        }
    },
    [AllInJane.CARD_INFURIATING_NOTE] = {
        Name = "Infuriating Note",
        Desc = {
            "Does nothing on use",
            "While held:",
            "\1 +2 flat Damage",
            "\2 All random pickup spawns are replaced with Infuriating Note"
        }
    },
    [AllInJane.CARD_YU_SZE] = {
        Name = "Yu Sze",
        Desc = {
            "{{BossRoom}} For the current room, doubles the effects of all Boss Room items you have",
        }
    },
    [AllInJane.CARD_TALHAK] = {
        Name = "Talhak",
        Desc = {
            "{{BossRoom}} The next time you clear a boss room, spawns 10 different cards/pills, you can only pick 1",
            "Additional uses spawn 1 additional card/pill"
        }
    },
}

local trinketDescs = {
    [AllInJane.TRINKET_ANARCHY_TAG] = {
        Name = "Anarchy Tag",
        Desc = {
            "Upon using a consumable, grants 1 completely random item effect for the room and spawns 1 random pickup",
        },
    }
}

local iconSprite = Sprite("gfx/ui/ui_eid_cards_jane.anm2", true)
EID:addIcon("Card"..tostring(AllInJane.CARD_NOBODY), "Cards", 0, 16, 16, 0, 0, iconSprite)
EID:addIcon("Card"..tostring(AllInJane.CARD_PARTY_TIME), "Cards", 1, 16, 16, 0, 0, iconSprite)
EID:addIcon("Card"..tostring(AllInJane.CARD_INFURIATING_NOTE), "Cards", 2, 16, 16, 0, 0, iconSprite)
EID:addIcon("Card"..tostring(AllInJane.CARD_BEANSTALK), "Cards", 3, 16, 16, 0, 0, iconSprite)
EID:addIcon("Card"..tostring(AllInJane.CARD_JERKO), "Cards", 4, 16, 16, 0, 0, iconSprite)
EID:addIcon("Card"..tostring(AllInJane.CARD_NEGATIVE_NANCY), "Cards", 5, 16, 16, 0, 0, iconSprite)
EID:addIcon("Card"..tostring(AllInJane.CARD_TALHAK), "Cards", 6, 16, 16, 0, 0, iconSprite)
EID:addIcon("Card"..tostring(AllInJane.CARD_YU_SZE), "Cards", 7, 16, 16, 0, 0, iconSprite)

EID:addIcon("CBAllInJane", "Cardbacks", 0, 16, 16, 0, 0, iconSprite)

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

for id, table in pairs(trinketDescs) do
    EID:addTrinket(id, turnStringTableToDesc(table.Desc), table.Name, "en_us")
end

EID.descriptions["en_us"].goldenTrinketData[AllInJane.TRINKET_ANARCHY_TAG] = {
    t = {1},
    findReplace = true,
    fullReplace = true,
}
EID.descriptions["en_us"].goldenTrinketEffects[AllInJane.TRINKET_ANARCHY_TAG] = {
    "Upon using a consumable, grants {{ColorGold}}2{{CR}} completely random item effects for the room and spawns {{ColorGold}}2{{CR}} random pickups", "Upon using a consumable, grants {{ColorRainbow}}3{{CR}} completely random item effects for the room and spawns {{ColorRainbow}}3{{CR}} random pickups"
}