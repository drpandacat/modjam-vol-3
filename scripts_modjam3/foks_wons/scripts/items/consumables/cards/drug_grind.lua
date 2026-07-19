local mod = _MODJAM_CARDS
local game = Game()
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, card, player, flag)
	for _, entity in pairs(Isaac.GetRoomEntities()) do
		local pickup = entity:ToPickup()
		local npc = entity:ToNPC()
		
		if pickup and pickup:CanReroll() and not pickup:IsShopItem() and pickup.Variant ~= PickupVariant.PICKUP_COLLECTIBLE then
			pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, PillColor.PILL_NULL, true, true, true)
		end
		if npc and npc:CanReroll() and npc:IsActiveEnemy() then
			mod.SpawnPickup(PickupVariant.PICKUP_PILL, PillColor.PILL_NULL, npc.Position)
			npc:Remove()
		end
	end

	local announcerVoiceMode = Options.AnnouncerVoiceMode
	if flag & UseFlag.USE_NOANNOUNCER > 0 or announcerVoiceMode == AnnouncerVoiceMode.NEVER then return end
	if announcerVoiceMode == AnnouncerVoiceMode.RANDOM and Random() % 2 == 0 then return end
	
	player:PlayDelayedSFX(mod.Sound.DRUG_GRIND, Isaac.GetItemConfig():GetCard(card).AnnouncerDelay)
end, mod.Card.DRUG_GRIND)
