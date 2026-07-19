local mod = _MODJAM_CARDS
local game = Game()
local sfx = SFXManager()

--mod:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, function()
	if EID then
		
		-----------------------
		-- << CONSUMABLES >> --
		-----------------------
		EID:addCard(mod.Card.TICK_CARD, "{{HalfHeart}} While held, after 30 seconds depletes half a red heart#The more red hearts it depletes the stronger the card is#When used deals a room wide damage that scales with the amount of red hearts consumed")
		EID:addCard(mod.Card.COMBUSTING_NECROMANCY, "Summons two special friendly invincible Gapers that chase enemies#After 5 seconds they explode dealing 40 damage to nearby enemies")
		EID:addCard(mod.Card.DRUG_GRIND, "{{Pill}} Turns all pickups, chests and non-boss enemies into random pills")
		EID:addCard(mod.Card.CHIMERA_FORM, "Grants all transformations for 30 seconds")
		EID:addCard(mod.Card.TWO_OF_GYATTS, "{{Collectible" .. CollectibleType.COLLECTIBLE_LIL_DUMPY .. "}} Spawns 2 Lil Dumpy familiars for the room")
	end
--end)
