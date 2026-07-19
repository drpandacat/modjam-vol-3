local mod = _MODJAM_CARDS
local game = Game()
local sfx = SFXManager()

local CHIMERA_CONFIG = Isaac.GetItemConfig():GetNullItem(mod.NullItem.CHIMERA_HELPER)
local CHIMERA_AMOUNT = 3

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, card, player, flag)
	player:AddNullItemEffect(mod.NullItem.CHIMERA_HELPER)

	local announcerVoiceMode = Options.AnnouncerVoiceMode
	if flag & UseFlag.USE_NOANNOUNCER > 0 or announcerVoiceMode == AnnouncerVoiceMode.NEVER then return end
	if announcerVoiceMode == AnnouncerVoiceMode.RANDOM and Random() % 2 == 0 then return end
	
	player:PlayDelayedSFX(mod.Sound.CHIMERA_FORM, Isaac.GetItemConfig():GetCard(card).AnnouncerDelay)
end, mod.Card.CHIMERA_FORM)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_ADD_EFFECT, function(_, player, configItem, costume, count)
	player:IncrementPlayerFormCounter(PlayerForm.PLAYERFORM_GUPPY, CHIMERA_AMOUNT)
	player:IncrementPlayerFormCounter(PlayerForm.PLAYERFORM_LORD_OF_THE_FLIES, CHIMERA_AMOUNT)
	player:IncrementPlayerFormCounter(PlayerForm.PLAYERFORM_MUSHROOM, CHIMERA_AMOUNT)
	player:IncrementPlayerFormCounter(PlayerForm.PLAYERFORM_ANGEL, CHIMERA_AMOUNT)
	player:IncrementPlayerFormCounter(PlayerForm.PLAYERFORM_BOB, CHIMERA_AMOUNT)
	player:IncrementPlayerFormCounter(PlayerForm.PLAYERFORM_DRUGS, CHIMERA_AMOUNT)
	player:IncrementPlayerFormCounter(PlayerForm.PLAYERFORM_MOM, CHIMERA_AMOUNT)
	player:IncrementPlayerFormCounter(PlayerForm.PLAYERFORM_BABY, CHIMERA_AMOUNT)
	player:IncrementPlayerFormCounter(PlayerForm.PLAYERFORM_EVIL_ANGEL, CHIMERA_AMOUNT)
	player:IncrementPlayerFormCounter(PlayerForm.PLAYERFORM_POOP, CHIMERA_AMOUNT)
	player:IncrementPlayerFormCounter(PlayerForm.PLAYERFORM_BOOK_WORM, CHIMERA_AMOUNT)
	player:IncrementPlayerFormCounter(PlayerForm.PLAYERFORM_ADULTHOOD, CHIMERA_AMOUNT)
	player:IncrementPlayerFormCounter(PlayerForm.PLAYERFORM_SPIDERBABY, CHIMERA_AMOUNT)
	player:IncrementPlayerFormCounter(PlayerForm.PLAYERFORM_STOMPY, CHIMERA_AMOUNT)
	
	game:GetHUD():ShowItemText("Chimera!", nil, nil, true)
end, CHIMERA_CONFIG)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_TRIGGER_EFFECT_REMOVED, function(_, player, configItem, count)
	player:IncrementPlayerFormCounter(PlayerForm.PLAYERFORM_GUPPY, -CHIMERA_AMOUNT)
	player:IncrementPlayerFormCounter(PlayerForm.PLAYERFORM_LORD_OF_THE_FLIES, -CHIMERA_AMOUNT)
	player:IncrementPlayerFormCounter(PlayerForm.PLAYERFORM_MUSHROOM, -CHIMERA_AMOUNT)
	player:IncrementPlayerFormCounter(PlayerForm.PLAYERFORM_ANGEL, -CHIMERA_AMOUNT)
	player:IncrementPlayerFormCounter(PlayerForm.PLAYERFORM_BOB, -CHIMERA_AMOUNT)
	player:IncrementPlayerFormCounter(PlayerForm.PLAYERFORM_DRUGS, -CHIMERA_AMOUNT)
	player:IncrementPlayerFormCounter(PlayerForm.PLAYERFORM_MOM, -CHIMERA_AMOUNT)
	player:IncrementPlayerFormCounter(PlayerForm.PLAYERFORM_BABY, -CHIMERA_AMOUNT)
	player:IncrementPlayerFormCounter(PlayerForm.PLAYERFORM_EVIL_ANGEL, -CHIMERA_AMOUNT)
	player:IncrementPlayerFormCounter(PlayerForm.PLAYERFORM_POOP, -CHIMERA_AMOUNT)
	player:IncrementPlayerFormCounter(PlayerForm.PLAYERFORM_BOOK_WORM, -CHIMERA_AMOUNT)
	player:IncrementPlayerFormCounter(PlayerForm.PLAYERFORM_ADULTHOOD, -CHIMERA_AMOUNT)
	player:IncrementPlayerFormCounter(PlayerForm.PLAYERFORM_SPIDERBABY, -CHIMERA_AMOUNT)
	player:IncrementPlayerFormCounter(PlayerForm.PLAYERFORM_STOMPY, -CHIMERA_AMOUNT)
end, CHIMERA_CONFIG)
