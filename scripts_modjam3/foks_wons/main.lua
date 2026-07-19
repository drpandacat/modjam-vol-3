_MODJAM_CARDS = RegisterMod("ModJam Cards", 1)

local mod = _MODJAM_CARDS
local version = "0.1.0"
local scripts = {
	"enums",
	"utils",
	
	"items.consumables.cards.tick_card",
	"items.consumables.cards.combusting_necromancy",
	"items.consumables.cards.chimera_form",
	"items.consumables.cards.drug_grind",
	"items.consumables.cards.two_of_gyatts",

	--"challenges.you_gyatt_to_stay_focused",
	
	"compat.eid",
}

if not REPENTOGON then
	error(mod.Name .. " requires REPENTOGON, which either wasn't installed correctly or is disabled.")
else
	for _, path in pairs(scripts) do include("scripts_modjam3.foks_wons.scripts." .. path) end
	local debugMessage = mod.Name .. " V" .. version .. " loaded successfully\n"
	
	-- Isaac.ConsoleOutput(debugMessage)
	Isaac.DebugString(debugMessage)
end

--[[ KNOWN ISSUES
	
--]]
