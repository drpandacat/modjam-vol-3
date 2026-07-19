if(not MinimapAPI) then return end

local iconf = Isaac.GetItemConfig()
local function isCanTripped()
	return MinimapAPI.isRepentance and Isaac.GetChallenge() == Challenge.CHALLENGE_CANTRIPPED
end

local ICONS_SPRITE = Sprite("gfx/ui/ui_minimapi_icons_john.anm2")

MinimapAPI:AddIcon("AllInJohnCard", ICONS_SPRITE, "Cards", 0)

MinimapAPI:AddPickup("AllInJohnCard","AllInJohnCard",5,300,-1,MinimapAPI.PickupNotCollected,"cards",10001,function(p) return not isCanTripped() and iconf:GetCard(p.SubType).PickupSubtype == 975 end)