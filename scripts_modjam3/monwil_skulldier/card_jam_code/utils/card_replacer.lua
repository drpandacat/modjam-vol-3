local mod = HODGEPODGE

local CARD_ORDER = {
    mod.Card.RED_SEAL,
    mod.Card.THE_161_OF_CLUBS,
    mod.Card.ECHO,
    mod.Card.MANIFESTATION,
    mod.Card.NIHIL,
    mod.Card.CLAM_CARD,
    mod.Card.MOON,
    mod.Card.SD_CARD
}

---@param type integer
---@param variant integer
---@param subtype integer
---@param pos Vector
---@param vel Vector
---@param spawner Entity
---@param seed integer
local function PreEntitySpawn(_, type, variant, subtype, pos, vel, spawner, seed)
    if type ~= mod.EntityType.CARD_REPLACER then
        return
    end
    local cardSubtype = CARD_ORDER[subtype]
    if not cardSubtype then
        return
    end
    local config = mod.ItemConfig:GetCard(cardSubtype)
    if not config:IsAvailable() then
        if cardSubtype == mod.Card.THE_161_OF_CLUBS then
            cardSubtype = mod.Card.RED_SEAL
        else
            cardSubtype = mod.ItemPool:GetCard(seed, true, false, false)
        end
    end

    return {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, cardSubtype}
end
mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, PreEntitySpawn)