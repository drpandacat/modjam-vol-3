DiscoCards = RegisterMod("Disco Cards", 1)
---@param enumName string
---@param enum table<string, number>
function DiscoCards:validateEnum(enumName, enum)
	for i, v in pairs(enum) do
		assert(
			v ~= -1,
			"The value for " .. enumName .. "." .. i .. " is -1. Make sure this was properly defined in the XML file!"
		)
	end
end


local scripts = {
	-- Enums
	-- include("scripts.constants"),
	-- include("scripts.enums.CollectibleType"),
	-- include("scripts.enums.EffectVariantCustom"),
	-- include("scripts.enums.PlayerTypeCustom"),
	-- include("scripts.enums.FamiliarVariantCustom"),
	-- include("scripts.enums.NullItemIDCustom"),
	-- include("scripts.enums.SoundEffectCustom"),
	-- include("scripts.soundManager"),
	include("scripts_modjam3.stale.scripts.discoManager"),
	include("scripts_modjam3.stale.scripts.textData"),
	include("scripts_modjam3.stale.scripts.electrochemistry"),
	include("scripts_modjam3.stale.scripts.inlandEmpire")
}

for _, file in pairs(scripts) do
	if type(file) == "table" and type(file.init) == "function" then
		file:init()
	end
end