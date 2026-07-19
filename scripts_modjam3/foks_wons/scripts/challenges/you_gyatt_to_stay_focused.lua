local mod = _MODJAM_CARDS
local game = Game()
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_PLAYER_INIT_POST_LEVEL_INIT_STATS, function(_, player)
	if Isaac.GetChallenge() == mod.Challenge.GYATT then
		player:AddCard(mod.Card.TWO_OF_GYATTS)
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_ROOM_TRIGGER_CLEAR, function(_, silent)
	if Isaac.GetChallenge() == mod.Challenge.GYATT then
		local room = game:GetRoom()
		local pickupPos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)
		
		mod.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, mod.Card.TWO_OF_GYATTS, pickupPos)
	end
end)
