local mod = _MODJAM_CARDS
local game = Game()
local sfx = SFXManager()

local EXPLOSION_DAMAGE = 40
local EXPLOSION_COUNTDOWN = 150 -- 5 seconds

local COLOR_START = 30 -- 1 second
local COLOR_FREQUENCY = 5
local COLOR_DURATION = 3

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, card, player, flag)
	for _ = 1, 2 do
		local npcPos = game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true)
		local npc = mod.Spawn(EntityType.ENTITY_GAPER, 0, 0, npcPos, nil, player):ToNPC()
		
		npc:AddCharmed(EntityRef(player), -1)
		npc:ReplaceSpritesheet(1, "gfx/monsters/monster_blowngaper.png", true)
		mod.GetEntityData(npc).ShouldCombust = true
	end

	local announcerVoiceMode = Options.AnnouncerVoiceMode
	if flag & UseFlag.USE_NOANNOUNCER > 0 or announcerVoiceMode == AnnouncerVoiceMode.NEVER then return end
	if announcerVoiceMode == AnnouncerVoiceMode.RANDOM and Random() % 2 == 0 then return end
	
	player:PlayDelayedSFX(mod.Sound.COMBUSTING_NECROMANCY, Isaac.GetItemConfig():GetCard(card).AnnouncerDelay)
end, mod.Card.COMBUSTING_NECROMANCY)

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
	if not mod.GetEntityData(npc).ShouldCombust then return end
	
	if npc.FrameCount > EXPLOSION_COUNTDOWN then
		Isaac.Explode(npc.Position, npc, EXPLOSION_DAMAGE)
		npc:Remove()
	elseif npc.FrameCount > EXPLOSION_COUNTDOWN - COLOR_START and npc.FrameCount % COLOR_FREQUENCY == 0 then
		npc:SetColor(npc.Color * Color(1, 1, 1, 1, 0.5, 0.35, 0, 1, 0.75, 0, 1), COLOR_DURATION, 1, true)
	end
end, EntityType.ENTITY_GAPER)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, amount, flag, source, countdown, extraSource)
	if mod.GetEntityData(entity).ShouldCombust then return false end
end, EntityType.ENTITY_GAPER)
