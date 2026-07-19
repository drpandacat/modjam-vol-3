--I'm keeping this just in case we need to get cards from our mod
ModJamHolder.CARD_POOL = { }

for _, Table in pairs(ModJamHolder.Card) do
    if Table.ID then
        ModJamHolder.CARD_POOL[#ModJamHolder.CARD_POOL+1] = Table.ID
    end
end

ModJamHolder.DICTIONARY = {}

for _, ID in ipairs(ModJamHolder.CARD_POOL) do
    ModJamHolder.DICTIONARY[ID] = true
end

---@param ID Card
---@return boolean | nil
function ModJamHolder:IsJamCard(ID)
    return ModJamHolder.DICTIONARY[ID]
end