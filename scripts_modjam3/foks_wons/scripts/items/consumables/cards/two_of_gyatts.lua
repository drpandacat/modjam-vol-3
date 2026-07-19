local mod = _MODJAM_CARDS
local game = Game()
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, card, player, flag)
	player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_LIL_DUMPY, false, 2)
	
	local announcerVoiceMode = Options.AnnouncerVoiceMode
	if flag & UseFlag.USE_NOANNOUNCER > 0 or announcerVoiceMode == AnnouncerVoiceMode.NEVER then return end
	if announcerVoiceMode == AnnouncerVoiceMode.RANDOM and Random() % 2 == 0 then return end
	
	player:PlayDelayedSFX(mod.Sound.TWO_OF_GYATTS, Isaac.GetItemConfig():GetCard(card).AnnouncerDelay)
end, mod.Card.TWO_OF_GYATTS)
