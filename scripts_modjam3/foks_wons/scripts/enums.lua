local mod = _MODJAM_CARDS
local game = Game()
local sfx = SFXManager()

mod.Card = {
	TICK_CARD = Isaac.GetCardIdByName("Tick Card"),
	COMBUSTING_NECROMANCY = Isaac.GetCardIdByName("Combusting Necromancy"),
	CHIMERA_FORM = Isaac.GetCardIdByName("Chimera Form"),
	DRUG_GRIND = Isaac.GetCardIdByName("Drug Grind"),
	TWO_OF_GYATTS = Isaac.GetCardIdByName("2 of Gyatts"),
}

mod.NullItem = {
	TICK_CARD_POWER = Isaac.GetNullItemIdByName("Tick Card Power"),
	CHIMERA_HELPER = Isaac.GetNullItemIdByName("Chimera Helper"),
}

mod.Challenge = {
	GYATT = Isaac.GetChallengeIdByName("You Gyatt To Stay Focused"),
}

mod.Sound = {
	TICK_CARD = Isaac.GetSoundIdByName("Tick Card"),
	COMBUSTING_NECROMANCY = Isaac.GetSoundIdByName("Combusting Necromancy"),
	CHIMERA_FORM = Isaac.GetSoundIdByName("Chimera Form"),
	DRUG_GRIND = Isaac.GetSoundIdByName("Drug Grind"),
	TWO_OF_GYATTS = Isaac.GetSoundIdByName("2 of Gyatts"),
}
