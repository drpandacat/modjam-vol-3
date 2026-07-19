
local Mod = ModJamHolder

if Encyclopedia then

    for name, PickupTable in pairs(Mod.Card) do
        Encyclopedia.AddCard({
            Class = "ModJam Expanded",
            ID = PickupTable.ID,
            WikiDesc = PickupTable.WIKI,
            ModName = "ModJam Expanded",
        })
    end
end