
-- Init --
-- Global table of the mod and name
ModJamHolder = RegisterMod("Bepis World", 1) -- placeholder, kerkel will bring us to a better place

ModJamHolder.Item = {}
ModJamHolder.Card = {}
ModJamHolder.Slot = {}

ModJamHolder.GENERIC_RNG = RNG()
ModJamHolder:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function ()
	ModJamHolder.GENERIC_RNG:SetSeed(Game():GetSeeds():GetStartSeed(), 35)
end)

-- CODE --
ModJamHolder.Game = Game()
ModJamHolder.SfxMan = SFXManager()

include("scripts_modjam3.dpower_reixen.reixen-dpower-jam.script_loader")