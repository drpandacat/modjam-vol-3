local CARD_VALUES = {0,0,0,0}
---@param slot PillCardSlot
---@return integer
local function getCardData(slot)
    return (CARD_VALUES or {})[slot+1] or 0
end
---@param slot PillCardSlot
---@param val integer
local function setCardData(slot, val)
    CARD_VALUES = CARD_VALUES or {}
    CARD_VALUES[slot+1] = val
end

---@param player EntityPlayer
---@param slot PillCardSlot
---@return integer
function AllInJohn:getCardData(player, slot)
    local data = AllInJohn:getData(player)
    data.CARD_DATA = data.CARD_DATA or {0,0,0,0}

    return (data.CARD_DATA[slot+1] or 0)
end

---@param player EntityPlayer
---@param slot PillCardSlot
---@param value integer
---@return nil
function AllInJohn:setCardData(player, slot, value)
    local data = AllInJohn:getData(player)
    data.CARD_DATA = data.CARD_DATA or {0,0,0,0}

    data.CARD_DATA[slot+1] = value
end

---@param player EntityPlayer
local function getMaxPocketSlot(player)
    for i=0, 3 do
        local pocket = player:GetPocketItem(i)
        if(pocket:GetSlot()==0) then
            return i-1
        end
    end

    return 3
end


---@param player EntityPlayer
---@param pickup EntityPickup
---@param slot PillCardSlot
local function dropCard(_, player, pickup, slot)
    if(player:GetData().OUTGOING_CARD_SLOT==slot) then
        player:GetData().OUTGOING_CARD_SLOT = nil

        pickup:SetVarData(player:GetData().OUTGOING_CARD_VAL or 0)
    end
end
AllInJohn:AddCallback(ModCallbacks.MC_POST_PLAYER_DROP_CARD, dropCard)

-- ---@param player EntityPlayer
-- ---@param id Card
-- ---@param slot PillCardSlot
-- local function removeCard(_, player, id, slot)
--     --print("REMOVED CARD IN SLOT:", slot)

--     local ogVal = AllInJohn:getCardData(player, slot)

--     local plData = player:GetData()
--     plData.OUTGOING_CARD_VAL = ogVal
--     plData.OUTGOING_CARD_SLOT = slot

--     plData.JUST_REMOVED_DATA = {
--         Value = ogVal,
--         ID = id,
--     }

--     AllInJohn:setCardData(player, slot, 0)

--     local maxSlot = getMaxPocketSlot(player)
--     if(maxSlot<0) then return end

--     for i=slot, maxSlot do
--         AllInJohn:setCardData(player, i, AllInJohn:getCardData(player, i+1))
--     end
--     AllInJohn:setCardData(player, maxSlot+1, 0)
-- end
-- AllInJohn:AddCallback(ModCallbacks.MC_POST_PLAYER_REMOVE_CARD, removeCard)

---@param player EntityPlayer
---@param id PillColor
---@param slot PillCardSlot
local function removePill(_, player, id, slot)
    --print("REMOVED CARD IN SLOT:", slot)

    AllInJohn:setCardData(player, slot, 0)

    local maxSlot = getMaxPocketSlot(player)
    if(maxSlot<0) then return end

    for i=slot, maxSlot do
        AllInJohn:setCardData(player, i, AllInJohn:getCardData(player, i+1))
    end
    AllInJohn:setCardData(player, maxSlot+1, 0)
end
AllInJohn:AddCallback(ModCallbacks.MC_POST_PLAYER_REMOVE_PILL, removePill)

---@param player EntityPlayer
local function swapPocket(_, player)
    --print("SWAPPED POCKETS")

    local maxSlot = getMaxPocketSlot(player)
    if(maxSlot<=0) then return end

    local ogVal = AllInJohn:getCardData(player, 0)
    for i=0, maxSlot-1 do
        AllInJohn:setCardData(player, i, AllInJohn:getCardData(player, i+1))
    end
    AllInJohn:setCardData(player, maxSlot, ogVal)
end
AllInJohn:AddCallback(ModCallbacks.MC_PRE_PLAYER_POCKET_ITEMS_SWAP, swapPocket)

---@param player EntityPlayer
---@param pickup EntityPickup
local function pickUpCard(_, player, pickup)
    local slot = player:GetData().INCOMING_CARD_SLOT
    if(slot) then
        AllInJohn:setCardData(player, slot, pickup:GetVarData())
        player:GetData().INCOMING_CARD_SLOT = nil
    end
end
AllInJohn:AddCallback(ModCallbacks.MC_POST_PLAYER_COLLECT_CARD, pickUpCard)

---@param player EntityPlayer
---@param id Card
---@param slot PillCardSlot
local function addCard(_, player, id, slot)
    local slotPocket = player:GetPocketItem(slot)
    if(slotPocket:GetSlot()~=0 and slotPocket:GetType()==PocketItemType.ACTIVE_ITEM) then
        slot = slot+1
    end

    local maxSlot = getMaxPocketSlot(player)
    if(maxSlot>0) then
        for i=maxSlot, slot+1, -1 do
            AllInJohn:setCardData(player, i, AllInJohn:getCardData(player, i-1))
        end
    end

    AllInJohn:setCardData(player, slot, 0)
    player:GetData().INCOMING_CARD_SLOT = slot
end
AllInJohn:AddCallback(ModCallbacks.MC_POST_PLAYER_ADD_CARD, addCard)

---@param player EntityPlayer
---@param slot PillCardSlot
local function addPill(_, player, _, slot)
    local slotPocket = player:GetPocketItem(slot)
    if(slotPocket:GetSlot()~=0 and slotPocket:GetType()==PocketItemType.ACTIVE_ITEM) then
        slot = slot+1
    end

    local maxSlot = getMaxPocketSlot(player)
    if(maxSlot>0) then
        for i=maxSlot, slot+1, -1 do
            AllInJohn:setCardData(player, i, AllInJohn:getCardData(player, i-1))
        end
    end

    AllInJohn:setCardData(player, slot, -1)
    player:GetData().INCOMING_CARD_SLOT = nil
end
AllInJohn:AddCallback(ModCallbacks.MC_POST_PLAYER_ADD_PILL, addPill)

---@param slot ActiveSlot
---@param player EntityPlayer
local function addCollectible(_, id, charge, firstTime, slot, varData, player)
    if(slot==ActiveSlot.SLOT_POCKET or slot==ActiveSlot.SLOT_POCKET2) then
        local addedSlot = nil
        for i=0, 3 do
            local pocketitem = player:GetPocketItem(i)
            if(pocketitem:GetType()==PocketItemType.ACTIVE_ITEM and pocketitem:GetSlot()==slot+1) then
                addedSlot = i
            end
        end

        if(addedSlot) then
            --print("ADDED ACTIVE IN SLOT:", addedSlot)

            local maxSlot = getMaxPocketSlot(player)
            for i=maxSlot, addedSlot+1, -1 do
                AllInJohn:setCardData(player, i, AllInJohn:getCardData(player, i-1))
            end
            AllInJohn:setCardData(player, addedSlot, -2)
        end
    end
end
AllInJohn:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, addCollectible)

---@param player EntityPlayer
local function removeCollectible(_, player, id, fromPlayer, innate)
    local removedSlot = nil
    for i=0, 3 do
        local pocketitem = player:GetPocketItem(i)
        --print("  ", i, pocketitem:GetSlot(), (pocketitem:GetSlot()>2 and player:GetActiveItem(pocketitem:GetSlot()-1) or -1), AllInJohn:getCardData(i))
        if(AllInJohn:getCardData(player, i)==-2 and (pocketitem:GetSlot()==0 or (pocketitem:GetType()==PocketItemType.ACTIVE_ITEM and player:GetActiveItem(pocketitem:GetSlot()-1)==0))) then
            removedSlot = i
        end
    end

    if(removedSlot) then
        --print("REMOVED ACTIVE IN SLOT:", removedSlot)
        AllInJohn:setCardData(player, removedSlot, 0)

        local maxSlot = getMaxPocketSlot(player)
        if(maxSlot<0) then return end

        for i=removedSlot, maxSlot do
            AllInJohn:setCardData(player, i, AllInJohn:getCardData(player, i+1))
        end
    end
end
AllInJohn:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, removeCollectible)



--[[] ]

---@param pl EntityPlayer
local function postRender(_, pl)
    local pos = Isaac.WorldToRenderPosition(pl.Position)

    for i=0, 3 do
        Isaac.RenderText(tostring(i)..": "..tostring(AllInJohn:getCardData(pl,i)), pos.X+20, pos.Y-40+i*10, 1,1,1,1)
    end
end
AllInJohn:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, postRender)

--]]