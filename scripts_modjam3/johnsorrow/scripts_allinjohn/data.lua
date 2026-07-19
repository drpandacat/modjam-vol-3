---@param ent Entity
---@return table, boolean
function AllInJohn:getData(ent)
    return EntitySaveStateManager.GetEntityData(AllInJohn, ent)
end

---@return table, boolean
function AllInJohn:getUniversalData()
    return EntitySaveStateManager.GetEntityData(AllInJohn, Isaac.GetPlayer())
end