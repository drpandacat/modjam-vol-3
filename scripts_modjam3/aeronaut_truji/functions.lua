CardJam_AeroTruji.Functions = {}

---@param lower number
---@param value number
---@param higher number
---@return number
function CardJam_AeroTruji.Functions.Clamp(value, lower, higher) -- returns value. if value is < than lower, returns lower, and if it's > than higher, returns higher
    if value < lower then
        return lower
    elseif value > higher then
        return higher
    else
        return value
    end
end

---@param rng RNG
---@param table table
---@return any
function CardJam_AeroTruji.Functions.GetRandomTableElement(rng, table) -- returns a random element from a table
    return table[rng:RandomInt(#table) + 1]
end

---@param table1 table
---@param table2 table
---@return table
function CardJam_AeroTruji.Functions.CombineTables(table1, table2) -- combines Table1 and Table2 and returns 1 table with the elements of both. ex. {1, 2, 3} + {4, 5} = {1, 2, 3, 4, 5}
    local CombinedTable = {}
    for i = 1, #table1 do
        CombinedTable[i] = table1[i]
    end
    for i = 1, #table2 do
        CombinedTable[i + #table1] = table2[i]
    end
    return CombinedTable
end

---Removes any values in the table that cause the provided function in func to return true
---@param tableToFilter table
---@param func any
---@return table
function CardJam_AeroTruji.Functions.FilterOutTable(tableToFilter, func)
    local filteredTable = {}
    for _, v in ipairs(tableToFilter) do
        if not func(v) then
            table.insert(filteredTable, v)
        end
    end
    return filteredTable
end

-- Throwable Active Creator Function
---Makes a defined item have all the functionality of a throwable active, with one simple touch! effect function takes player as a parameter
---@param collectible CollectibleType
---@param identifier string
---@param effect fun(player?: EntityPlayer)
---@param onLift fun(player?: EntityPlayer): boolean?
function CardJam_AeroTruji.Functions.MakeThrowableActive(collectible, identifier, effect, onLift)
    local itemUseIdentifier = "using" .. identifier
    local slotIdentifier = identifier .. "ActiveSlot"
    local heartChargeIdentifier = identifier .. "HeartChargeToSpend"

    CardJam_AeroTruji:AddCallback(ModCallbacks.MC_USE_ITEM, function (_, itemUsed, _, player, useFlags, slot, _)
        if useFlags & UseFlag.USE_CARBATTERY == UseFlag.USE_CARBATTERY then return end
        local data = player:GetData()
        if not data[itemUseIdentifier] then
            if not onLift or (onLift and onLift(player)) then
                data[itemUseIdentifier] = true
                data[slotIdentifier] = slot
                if slot ~= -1 and player:NeedsCharge(slot) then    -- if the player is able to use their active item but also needs charge, they are playing as bethany
                    local config = Isaac.GetItemConfig():GetCollectible(collectible)
                    local maxcharges = config.ChargeType == 1 and 1 or config.MaxCharges
                    data[heartChargeIdentifier] = math.max(maxcharges - player:GetActiveCharge(slot), 1)
                end
                player:AnimateCollectible(collectible, "LiftItem", "PlayerPickup")
            end
        else
            data[itemUseIdentifier] = false
            player:AnimateCollectible(collectible, "HideItem", "PlayerPickup")
        end
        return {Discharge = false, Remove = false, ShowAnim = false}
    end, collectible)

    CardJam_AeroTruji:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)
        local data = player:GetData()
        if data[itemUseIdentifier] then
            if player:GetAimDirection():Length() < 1 then
                return
            else
                data[itemUseIdentifier] = false

                effect(player)

                local slot = data[slotIdentifier]
                if slot ~= -1 then
                    if slot == ActiveSlot.SLOT_PRIMARY then -- Prevent possible cheese with Schoolbag
                        if player:GetActiveItem(slot) ~= collectible then
                            slot = ActiveSlot.SLOT_SECONDARY
                        else
                            if player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) < Isaac.GetItemConfig():GetCollectible(collectible).MaxCharges then
                                slot = ActiveSlot.SLOT_SECONDARY
                            end
                        end
                    end
                    player:DischargeActiveItem(slot) -- Since the item was used successfully, actually discharge the item
                end
                if data[heartChargeIdentifier] then
                    local spendHearts = data[heartChargeIdentifier]
                    if player:GetPlayerType() == PlayerType.PLAYER_BETHANY then
                        player:AddSoulCharge(-1 * spendHearts)
                    elseif player:GetPlayerType() == PlayerType.PLAYER_BETHANY_B then
                        player:AddBloodCharge(-1 * spendHearts)
                    end
                    if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
                        local wispXmlData = XMLData.GetEntryById(XMLNode.WISP, collectible)
                        if wispXmlData then
                            local count = wispXmlData.count or 1
                            for i = 1, count do
                                player:AddWisp(collectible, player.Position)
                            end
                        end
                    end
                end
                player:AnimateCollectible(collectible, "HideItem", "PlayerPickup")
            end
        end
    end)

    -- Terminate held active item functions
    CardJam_AeroTruji:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function (_, entity, _, _, _, _)
        local player = entity:ToPlayer()
        if not player then return end

        local data = player:GetData()
        if data[itemUseIdentifier] then
            data[itemUseIdentifier] = false
            player:AnimateCollectible(collectible, "HideItem", "PlayerPickup")
        end
    end)

    CardJam_AeroTruji:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, function (_, player)
        local data = player:GetData()
        if data[itemUseIdentifier] then
            data[itemUseIdentifier] = false
            player:AnimateCollectible(collectible, "HideItem", "PlayerPickup")
        end
    end)
end