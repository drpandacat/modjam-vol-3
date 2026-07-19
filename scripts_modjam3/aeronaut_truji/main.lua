---@class ModReference
CardJam_AeroTruji = RegisterMod("CardJam: Aero & Truji Submission", 1)
---@class ModReference
local mod = CardJam_AeroTruji

mod.Enums = {
    DUELLING_DISK = Isaac.GetItemIdByName("Duelling Disk"),

    POLYMERIZATION = Isaac.GetCardIdByName("CardJamAT_Polymerization"),
    AMALGAM = Isaac.GetCardIdByName("CardJamAT_Amalgam"),
    IJIRAQ = Isaac.GetCardIdByName("CardJamAT_Ijiraq"),
    PUNCH_CARD = Isaac.GetCardIdByName("CardJamAT_PunchCard"),
    MAGNETIC_CARD = Isaac.GetCardIdByName("CardJamAT_MagneticCard"),
}

mod.Consts = {
    Game = Game(),
    SFX = SFXManager(),
    Conf = Isaac.GetItemConfig()
}

mod.CustomCallbacks = {
    POST_FIRE_DUELLING_DISK = "",
    PRE_FIRE_DUELLING_DISK = "",
    POST_DUELLING_DISK_SHOT_COLLISION = "",
    POST_DUELLING_DISK_SHOT_DEATH = "",
}

for k, v in pairs(mod.CustomCallbacks) do
    mod.CustomCallbacks[k] = "CARDJAM_AT_" .. k
end

include("scripts_modjam3.aeronaut_truji.functions")

-- Temporary Data Handler
mod.TempData = {
    Data = {}
}
local TempData = mod.TempData

-- Returns the entity's TempData table.
---@param entity Entity
---@return table
function mod.TempData:GetData(entity)
    local hash = GetPtrHash(entity)
    if not self.Data[hash] then self.Data[hash] = {} end
    local data = self.Data[hash]
    return data
end

-- Returns the value added to the entity's TempData.
---@param entity Entity
---@param field string
---@param value any
---@param defaultValue any?
---@return any
function mod.TempData:AddData(entity, field, value, defaultValue)
    defaultValue = defaultValue or value
    local data = self:GetData(entity)
    if not data[field] then
        data[field] = defaultValue
    end
    data[field] = value
    return data[field]
end

---Version of TempData:AddData that does not override the field if data already exists in there. Returns the value added to the entity's TempData.
---@param entity Entity
---@param field string
---@param value any
---@return any
function mod.TempData:InitData(entity, field, value)
    local data = self:GetData(entity)
    if not data[field] then
        data[field] = value
    end
    return data[field]
end

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function (_, entity)
    TempData.Data[GetPtrHash(entity)] = nil
end)
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function ()
    TempData.Data = {}
end)


local includes = {
    "duelling_disk",
    "duelling_disk_synergies",
    "polymerization",
    "ijiraq",
    "punch_card",
    "magnetic_card",

    "eid",
}

for _, v in ipairs(includes) do
    include("scripts_modjam3.aeronaut_truji.scripts." .. v)
end