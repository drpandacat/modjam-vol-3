---@param ent Entity
---@return table, boolean
function AllInJane:getData(ent)
    return EntitySaveStateManager.GetEntityData(AllInJane, ent)
end

---@return table, boolean
function AllInJane:getUniversalData()
    return EntitySaveStateManager.GetEntityData(AllInJane, Isaac.GetPlayer())
end