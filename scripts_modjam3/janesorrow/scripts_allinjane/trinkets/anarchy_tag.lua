--[[
Anarchy Tag - trinket (anarchy tag)
 - upon using a consumable, get a random item effect (if it is active then use it le epicly) for the room and spawn a random pickup
]]

---@param player EntityPlayer
local function BlaBlaBla(_, _, player)
    if(not player:HasTrinket(AllInJane.TRINKET_ANARCHY_TAG)) then return end

    local room = AllInJane.GAME:GetRoom()
    local conf = Isaac.GetItemConfig()

    local rng = player:GetTrinketRNG(AllInJane.TRINKET_ANARCHY_TAG)
    local mult = player:GetTrinketMultiplier(AllInJane.TRINKET_ANARCHY_TAG)

    for i=1, mult do
        local id
        repeat
            id = rng:RandomInt(1, conf:GetCollectibles().Size-1)
        until(conf:GetCollectible(id))

        if(conf:GetCollectible(id).Type==ItemType.ITEM_ACTIVE) then
            player:UseActiveItem(id, UseFlag.USE_NOANIM)
        end
        player:AddInnateCollectible(id, 1, "AllInJaneAnarchyTag")

        local pos = room:FindFreePickupSpawnPosition(player.Position,40)
        local pickup = Isaac.Spawn(5,0,NullPickupSubType.NO_COLLECTIBLE,pos,Vector.Zero,nil):ToPickup()
        if(pickup) then
            pickup:SetDropDelay(i*2)
        end
    end
end
AllInJane:AddCallback(ModCallbacks.MC_USE_CARD, BlaBlaBla)
AllInJane:AddCallback(ModCallbacks.MC_USE_PILL, BlaBlaBla)

---@param pl EntityPlayer
local function removeYuSzeItems(_, pl)
    pl:SetInnateCollectibleGroup("AllInJaneAnarchyTag", {})
end
AllInJane:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, removeYuSzeItems)