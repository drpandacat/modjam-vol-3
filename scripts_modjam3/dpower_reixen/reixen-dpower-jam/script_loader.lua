

local function LoadMagic(names, category)
    for _, name in ipairs(names) do
        include("scripts_modjam3.dpower_reixen.reixen-dpower-jam." .. category .. "." .. name)
    end
end

local helpers = {
    "throwable_item_lib"
}

local cards = {
    "blue",
    "purple",
    "red",
    "yellow",
    "cyan",
    "green",
    "orange"
}


LoadMagic(helpers, "helpers")
LoadMagic(cards, "cards")

include("scripts_modjam3.dpower_reixen.reixen-dpower-jam.magic_table")
include("scripts_modjam3.dpower_reixen.reixen-dpower-jam.compatibility.ME_Encyclopedia")
include("scripts_modjam3.dpower_reixen.reixen-dpower-jam.compatibility.ME_EID")
include("scripts_modjam3.dpower_reixen.reixen-dpower-jam.consumable_sounds")