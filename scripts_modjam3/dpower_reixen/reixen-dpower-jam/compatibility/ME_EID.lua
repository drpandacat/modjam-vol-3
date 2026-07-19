local Mod = ModJamHolder

if not EID then
	return
end

-- changing mod's name and indicator for EID --
-----------------------------------------------
EID._currentMod = "ModJam Expanded"
--EID:setModIndicatorName("ModJam Expanded") I guess the entire modjam will have its icon

--[[
local CustomSprite = Sprite()
CustomSprite:Load("gfx/ui/eid_logo_icon.anm2", true)
EID:addIcon("ME ModIcon", "Icon", 0, 8, 8, 6, 6, CustomSprite)
EID:setModIndicatorIcon("ME ModIcon")]]

function Mod:CreateEIDIcon(cardId, name)
	local sprite = Sprite()
	sprite:Load("gfx/eid_soul_cards.anm2", true)
	EID:addIcon("Card"..cardId, name, -1, 9, 9, 6, 6, sprite)
end

for ItemKey, ItemTable in pairs(Mod.Card) do
	Mod:CreateEIDIcon(ItemTable.ID, ItemTable.NAME)
	EID:addCard(ItemTable.ID, ItemTable.EID, ItemTable.NAME, "en_us")
end

EID._currentMod = "ModJam Expanded_reserved" -- to prevent other mods overriding ME mod items