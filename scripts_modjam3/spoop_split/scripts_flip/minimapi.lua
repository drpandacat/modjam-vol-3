if(not MinimapAPI) then return end

local iconf = Isaac.GetItemConfig()
local function isCanTripped()
	return MinimapAPI.isRepentance and Isaac.GetChallenge() == Challenge.CHALLENGE_CANTRIPPED
end

local ICONS_SPRITE = Sprite("gfx/ui/ui_minimapi_icons_spoopsplit.anm2")

MinimapAPI:AddIcon("FlipFlopCardRed", ICONS_SPRITE, "Cards", 0)
MinimapAPI:AddIcon("FlipFlopCardBlue", ICONS_SPRITE, "Cards", 1)

MinimapAPI:AddPickup("FlipFlopCardRed","FlipFlopCardRed",5,300,-1,MinimapAPI.PickupNotCollected,"cards",10001,function(p) return not isCanTripped() and iconf:GetCard(p.SubType).PickupSubtype == 973 end)
MinimapAPI:AddPickup("FlipFlopCardBlue","FlipFlopCardBlue",5,300,-1,MinimapAPI.PickupNotCollected,"cards",10001,function(p) return not isCanTripped() and iconf:GetCard(p.SubType).PickupSubtype == 974 end)