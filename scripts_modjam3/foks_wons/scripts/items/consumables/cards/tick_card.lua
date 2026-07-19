local mod = _MODJAM_CARDS
local game = Game()
local sfx = SFXManager()

local HP_DEPLETE_COOLDOWN = 900 -- 30 seconds
local MIN_DEPLETE_HP = 1

local DAMAGE = 5
local DAMAGE_STACK = 5 -- Stack with the amount of hearts depleted

local BLINK_THRESHOLD = 90 -- 3 seconds

local BLOOD_SPLAT_CHANCE_MAX = 0.5
local BLOOD_SPLAT_SIZE_MULT = 0.4
local BLOOD_SPLAT_SIZE = 0.3
local BLOOD_SPLAT_SIZE_BIG = 1.2

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
	local playerData = mod.GetEntityData(player)
	local playerRNG = mod.RNG()
	local holdsTickCard = false
	local hasWantedHp = false

	local minDepleteHp = player:GetHealthType() == HealthType.COIN and mod.MakeEven(MIN_DEPLETE_HP) or MIN_DEPLETE_HP
	if (player:GetHearts() - player:GetRottenHearts() * 2) > minDepleteHp then
		hasWantedHp = true
	end
	
	for slot = PillCardSlot.PRIMARY, PillCardSlot.QUATERNARY do
		if player:GetCard(slot) == mod.Card.TICK_CARD then
			holdsTickCard = true
		end
	end
	
	if holdsTickCard then
		if not playerData.TickCardCooldown or not hasWantedHp then
			playerData.TickCardCooldown = HP_DEPLETE_COOLDOWN
		else
			if playerData.TickCardCooldown > 0 then
				if playerRNG:RandomFloat() <= (1 - playerData.TickCardCooldown / HP_DEPLETE_COOLDOWN) * BLOOD_SPLAT_CHANCE_MAX then
					mod.MakeBloodSplat(player, nil, playerRNG:RandomFloat() * BLOOD_SPLAT_SIZE_MULT + BLOOD_SPLAT_SIZE)
				end
				if playerData.TickCardCooldown <= BLINK_THRESHOLD and playerData.TickCardCooldown % 9 == 0 then
					local colorStrength = 1 - playerData.TickCardCooldown / BLINK_THRESHOLD
					
					player:SetColor(player.Color * Color(1, 1, 1, 1, colorStrength * 0.25, 0, 0, 1, 0, 0, colorStrength), 6, 1, true)
				end
				playerData.TickCardCooldown = playerData.TickCardCooldown - 1
			else
				player:AddHearts(-1)
				player:AddNullItemEffect(mod.NullItem.TICK_CARD_POWER)
				player:SpawnBloodEffect(2):FollowParent(player)

				for _ = 1, 3 do mod.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_PARTICLE, 0, player.Position, RandomVector() * 5, player) end
				
				mod.MakeBloodSplat(player, nil, BLOOD_SPLAT_SIZE_BIG)
				sfx:Play(SoundEffect.SOUND_DEATH_BURST_SMALL)
				
				playerData.TickCardCooldown = nil
			end
		end
	elseif playerData.TickCardCooldown then
		playerData.TickCardCooldown = nil
	end
end)

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, card, player, flag)
	local playerFx = player:GetEffects()
	local tickPower = playerFx:GetNullEffectNum(mod.NullItem.TICK_CARD_POWER)

	for _, entity in pairs(Isaac.GetRoomEntities()) do
		if entity and entity:IsVulnerableEnemy() then
			entity:TakeDamage(DAMAGE + tickPower * DAMAGE_STACK, 0, EntityRef(player), 0)
		end
	end
	game:ShakeScreen(15)
	game:GetRoom():EmitBloodFromWalls(3, math.min(3 + tickPower * 3, 30))
	playerFx:RemoveNullEffect(mod.NullItem.TICK_CARD_POWER, -1)

	for _ = 1, 5 do mod.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_PARTICLE, 0, player.Position, RandomVector() * 5, player) end
	
	player:SpawnBloodEffect(3)
	mod.MakeBloodSplat(player, nil, 2)
	sfx:Play(SoundEffect.SOUND_DEATH_BURST_LARGE)

	local announcerVoiceMode = Options.AnnouncerVoiceMode
	if flag & UseFlag.USE_NOANNOUNCER > 0 or announcerVoiceMode == AnnouncerVoiceMode.NEVER then return end
	if announcerVoiceMode == AnnouncerVoiceMode.RANDOM and Random() % 2 == 0 then return end
	
	player:PlayDelayedSFX(mod.Sound.TICK_CARD, Isaac.GetItemConfig():GetCard(card).AnnouncerDelay)
end, mod.Card.TICK_CARD)
