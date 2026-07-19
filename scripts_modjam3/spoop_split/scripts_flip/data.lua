---@param ent Entity
---@return table, boolean
function CardjamFlipCards:getData(ent)
    return EntitySaveStateManager.GetEntityData(CardjamFlipCards, ent)
end

---@return table, boolean
function CardjamFlipCards:getUniversalData()
    return EntitySaveStateManager.GetEntityData(CardjamFlipCards, Isaac.GetPlayer())
end