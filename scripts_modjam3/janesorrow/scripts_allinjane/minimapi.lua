if(not MinimapAPI) then return end

local iconf = Isaac.GetItemConfig()
local function isCanTripped()
	return MinimapAPI.isRepentance and Isaac.GetChallenge() == Challenge.CHALLENGE_CANTRIPPED
end

local ICONS_SPRITE = Sprite("gfx/ui/ui_minimapi_icons_jane.anm2")

MinimapAPI:AddIcon("AllInJaneCard", ICONS_SPRITE, "Cards", 0)

MinimapAPI:AddPickup("AllInJaneCard","AllInJaneCard",5,300,-1,MinimapAPI.PickupNotCollected,"cards",10001,function(p) return not isCanTripped() and iconf:GetCard(p.SubType).PickupSubtype == 976 end)