---@param MOD ModReference
return function (MOD)
    local t = {}

    t.ID = Isaac.GetCardIdByName("Little Card John")
    ---@type table<PickupVariant, true>
    t.CHESTS = {
        [PickupVariant.PICKUP_CHEST] = true,
        [PickupVariant.PICKUP_MIMICCHEST] = true,
        [PickupVariant.PICKUP_REDCHEST] = true,
        [PickupVariant.PICKUP_BOMBCHEST] = true,
        [PickupVariant.PICKUP_SPIKEDCHEST] = true,
        [PickupVariant.PICKUP_GRAB_BAG] = true,
        [PickupVariant.PICKUP_WOODENCHEST] = true,
        [PickupVariant.PICKUP_HAUNTEDCHEST] = true,
        [PickupVariant.PICKUP_LOCKEDCHEST] = true,
        [PickupVariant.PICKUP_ETERNALCHEST] = true,
        [PickupVariant.PICKUP_MEGACHEST] = true,
    }

    ---@type table<PickupVariant, true>
    t.BLACKLIST = {
        [PickupVariant.PICKUP_SHOPITEM] = true,
        [PickupVariant.PICKUP_BIGCHEST] = true,
        [PickupVariant.PICKUP_BED] = true,
        [PickupVariant.PICKUP_COLLECTIBLE] = true,
    }

    ---@param pickup EntityPickup
    ---@param player EntityPlayer
    ---@param delay? integer
    function t:ThisIsMine(pickup, player, delay)
        MOD.SFX:Play(SoundEffect.SOUND_FETUS_LAND)
        local snatch = function ()
            local data = MOD:GetData(pickup)
            if data.LKJAnim or data.LKJTarget then return end
            local sprite = pickup:GetSprite()
            if sprite:GetAnimationData("Appear") then
                sprite:Play("Appear", true)
                sprite:SetFrame(6)
            else
                sprite:Play(sprite:GetDefaultAnimation(), true)
            end
            data.LKJAnim = sprite:GetAnimation()
            data.LKJTarget = EntityPtr(player)
        end
        if delay then
            local a = EntityPtr(pickup)
            local b = EntityPtr(player)
            Isaac.CreateTimer(function ()
                if not a.Ref or not a.Ref:Exists()
                or not b.Ref or not b.Ref:Exists() then return end
                snatch()
            end, delay, 1, false)
        else
            snatch()
        end
    end

    ---@param pickup EntityPickup
    MOD:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function (_, pickup)
        local data = MOD:GetData(pickup)
        ---@type Entity?
        local target = data.LKJTarget and data.LKJTarget.Ref and data.LKJTarget.Ref:Exists() and data.LKJTarget.Ref
        if not target then return end
        local sprite = pickup:GetSprite()
        for _, v in ipairs(Isaac.FindInCapsule(pickup:GetCollisionCapsule(), EntityPartition.PLAYER)) do
            pickup:ForceCollide(v, true)
            pickup:ForceCollide(v, false)
            v:ForceCollide(pickup, true)
            v:ForceCollide(pickup, false)
        end
        local finished = sprite:GetAnimation() ~= data.LKJAnim
        if finished or sprite:WasEventTriggered("DropSound") then
            data.LKJAnim = nil
            data.LKJTarget = nil
            -- sprite:Play("Idle", true)
            -- pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            -- pickup.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
            sprite.PlaybackSpeed = 1
            return
        end
        pickup.Velocity = pickup.Velocity * 0.8
        + (target.Position - pickup.Position):Resized(5)
        -- pickup.EntityCollisionClass = Entityw.ENTCOLL_PLAYERONLY
        -- pickup.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
        sprite.PlaybackSpeed = 0.75
    end)

    ---@param pickup EntityPickup
    MOD:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_GRID_COLLISION, CallbackPriority.EARLY, function (_, pickup)
        local data = MOD:GetData(pickup)
        if data.LKJTarget then
            return true
        end
    end)

    ---@param pickup EntityPickup
    ---@param collider Entity
    MOD:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.EARLY, function (_, pickup, collider)
        local data = MOD:GetData(pickup)
        if data.LKJTarget then
            if collider.Type ~= EntityType.ENTITY_PLAYER then
                return true
            end
        end
    end)

    t.STEAL_CHANCE = 1 / 3
    t.STEAL_PICKUPS = {
        PickupVariant.PICKUP_COIN,
        PickupVariant.PICKUP_BOMB,
        PickupVariant.PICKUP_KEY,
    }

    ---@param player EntityPlayer
    MOD:AddCallback(ModCallbacks.MC_USE_CARD, function (_, _, player)
        local rng = player:GetCardRNG(t.ID)
        local i = 0
        for _, v in ipairs(Isaac.GetRoomEntities()) do
            if v:IsActiveEnemy(false)
            and not v:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
            and v.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_NONE then
                if rng:RandomFloat() < t.STEAL_CHANCE
                or MOD.LEVEL:GetCurses() & MOD.CURSE_DELUGE.WTF ~= 0 then
                    t:ThisIsMine(
                        Isaac.Spawn(
                            EntityType.ENTITY_PICKUP,
                            t.STEAL_PICKUPS[rng:RandomInt(1, #t.STEAL_PICKUPS)],
                            0,
                            v.Position,
                            Vector.Zero,
                            nil
                        ):ToPickup(),
                        player,
                        i
                    )
                    Isaac.Spawn(
                        EntityType.ENTITY_EFFECT,
                        EffectVariant.POOF01,
                        0,
                        v.Position,
                        Vector.Zero,
                        nil
                    )
                    i = i + 1
                end
            end
        end
        i = 0
        for _, v in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
            if not t.BLACKLIST[v.Variant] then
                v = v:ToPickup()
                if v.Price == 0 then
                    if t.CHESTS[v.Variant] then
                        v:TryOpenChest(player)
                    else
                        t:ThisIsMine(v, player, i)
                        i = i + 1
                    end
                    MOD:GetData(v).LKJ = true
                end
            end
        end
        i = 0
        for _, v in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
            if not t.BLACKLIST[v.Variant] then
                v = v:ToPickup()
                if v.Price == 0 then
                    local data = MOD:GetData(v)
                    if not data.LKJ then
                        t:ThisIsMine(v, player, i)
                        i = i + 1
                    end
                    data.LKJ = nil
                end
            end
        end
    end, t.ID)

    return t
end