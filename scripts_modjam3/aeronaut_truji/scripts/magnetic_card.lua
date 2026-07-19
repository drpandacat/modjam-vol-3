local mod = CardJam_AeroTruji
local TempData = mod.TempData
local id = mod.Enums.MAGNETIC_CARD

local magnetizeBlacklist = {
    [PickupVariant.PICKUP_COLLECTIBLE] = true,
    [PickupVariant.PICKUP_BROKEN_SHOVEL] = true,
    [PickupVariant.PICKUP_BIGCHEST] = true,
    [PickupVariant.PICKUP_BED] = true,
    [PickupVariant.PICKUP_TROPHY] = true,
}

---@param player EntityPlayer
mod:AddCallback(ModCallbacks.MC_USE_CARD, function (_, card, player, useflags)
    local direction = player:GetHeadDirection()
    local angle = (direction - 2) * 90
    local vec = Vector.FromAngle(angle)

    for i = 0, 4 do
        Isaac.CreateTimer(function ()
            local focusPoint = player.Position + vec:Resized(i * 90 + 35)
            local capsule = Capsule(focusPoint, Vector(0.2, 1), angle, 240)
            --local shape = DebugRenderer.Get(Random())
            --shape:Capsule(capsule)
            local ents = mod.Functions.FilterOutTable(Isaac.FindInCapsule(capsule, EntityPartition.ENEMY), function (ent)
                local npc = ent:ToNPC()
                if not npc then return true end
                return not (npc:IsVulnerableEnemy() and npc:IsActiveEnemy() and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY))
            end)

            for _, npc in ipairs(ents) do
                npc:AddMagnetized(EntityRef(player), 75)
                npc:AddKnockback(EntityRef(player), (focusPoint - npc.Position) * 0.1, 15, true)
            end

            local pickups = mod.Functions.FilterOutTable(Isaac.FindInCapsule(capsule, EntityPartition.PICKUP), function (ent)
                local pickup = ent:ToPickup()
                if not pickup then return true end
                return magnetizeBlacklist[pickup.Variant]
            end)

            for _, pickup in ipairs(pickups) do
                pickup:AddVelocity((focusPoint - pickup.Position) * 0.1)
                TempData:AddData(pickup, "magnetCardMagnetizeTimer", 30)
            end
        end, i * 6, 1, false)
    end
end, id)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function (_, pickup)
    local data = TempData:GetData(pickup)
    if data.magnetCardMagnetizeTimer and data.magnetCardMagnetizeTimer > 0 then
        data.magnetCardMagnetizeTimer = data.magnetCardMagnetizeTimer - 1
        pickup.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
    end
end)