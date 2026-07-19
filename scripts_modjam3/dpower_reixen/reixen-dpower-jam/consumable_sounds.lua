-- ================================================================================

-- Epiphany Custom SFX implementation for consumables -----------------------------

-- Checks if the card,essence or capsule has a sound associated with them----------
-- and plays it -------------------------------------------------------------------

-- SFX = main sound ID ------------------------------------------------------------
-- SFX_ALT = alternate sound ID ---------------------------------------------------
-- SFX_ALT_CHANCE = Float chance for the alternate sound to replace the main one --

-- ================================================================================
local Mod = ModJamHolder
local SFX = SFXManager()
local SoundChance = 0.5


---@param card Card
---@param flags UseFlag
---@param player EntityPlayer
local function OnUseCard(_, card, player, flags)
	if (flags & UseFlag.USE_CARBATTERY) > 0 or (flags & UseFlag.USE_NOANNOUNCER) > 0 then
		return
	end

	local announcerMode = Options.AnnouncerVoiceMode
	if
		announcerMode == 1 -- announcer off
		or announcerMode == 0 and player:GetCardRNG(card):PhantomFloat() < SoundChance
	then -- announcer with chance
		return
	end

	for _, v in pairs(Mod.Card) do
		if v.ID and v.ID == card and v.SFX then
			if (v.SFX_ALT and v.SFX_ALT_CHANCE and player:GetCardRNG(card):RandomFloat() < v.SFX_ALT_CHANCE) then
				SFX:Play(v.SFX_ALT, 1.3)
			else
				SFX:Play(v.SFX, 1.3)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, OnUseCard)
