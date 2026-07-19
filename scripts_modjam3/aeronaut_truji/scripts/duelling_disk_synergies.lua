local mod = CardJam_AeroTruji
local TempData = mod.TempData

local duellingDiskD7ed = false

---@param player EntityPlayer
---@return table
local function GetDuellingDiskData(player)
    local data, exists = EntitySaveStateManager.GetEntityData(mod, player)
    if not exists then
        data.LastDuellingDiskCard = 0
    end
    return data
end

---@param player EntityPlayer
---@param position Vector
---@param minRadius number
---@param maxRadius number
---@param timeout integer
---@param extraFunc fun(effect: EntityEffect, player: EntityPlayer)
local function SpawnPulse(player, position, minRadius, maxRadius, timeout, extraFunc)
    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_ATTRACT, 10, position, Vector.Zero, player):ToEffect()
    effect.MinRadius = minRadius
    effect.MaxRadius = maxRadius
    effect.LifeSpan = timeout
    effect.Timeout = timeout
    effect.SpriteOffset = Vector(0, -15)
    extraFunc(effect, player)
    effect.Visible = false
    effect:Update()
    effect.Visible = true
end

local DuellingDiskSynergy = {

[Card.CARD_FOOL] = {damage = 30, tearFlags = TearFlags.TEAR_CONFUSION},
[Card.CARD_MAGICIAN] = {tearFlags = TearFlags.TEAR_HOMING},
[Card.CARD_HIGH_PRIESTESS] = {onCollide = function (_, card, tear, player, npc)
    local rng = player:GetCollectibleRNG(mod.Enums.DUELLING_DISK)
    if rng:RandomFloat() < 0.15 then
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.MOM_FOOT_STOMP, 0, tear.Position, Vector.Zero, nil)
    end
end},
[Card.CARD_EMPRESS] = {damage = 60, velMult = 1.5},
[Card.CARD_HIEROPHANT] = {onFire = function (_, card, tear, player, isWisp)
    local rng = player:GetCollectibleRNG(mod.Enums.DUELLING_DISK)
    if rng:RandomFloat() < 0.3 then
        tear:AddTearFlags(TearFlags.TEAR_LIGHT_FROM_HEAVEN)
    end
end},
[Card.CARD_LOVERS] = {tearFlags = TearFlags.TEAR_CHARM},
[Card.CARD_CHARIOT] = {velMult = 1.5, tearFlags = TearFlags.TEAR_PIERCING},
[Card.CARD_JUSTICE] = {damage = 20, onCollide = function (_, card, tear, player, npc)
    local rotation = math.random(0, 89)
    for i = 1, 4 do
        local splitTear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLUE, 0, tear.Position, Vector.FromAngle(i * 90 + rotation):Resized(player.ShotSpeed * 10), player):ToTear()
        splitTear.CollisionDamage = math.max(player.Damage + 1.5, 5)
        splitTear:AddTearFlags(TearFlags.TEAR_PIERCING)
        splitTear.Color = Color(0.5, 0.3, 0, 1, 0.75, 0.5, 0.2)
    end
end},
[Card.CARD_HERMIT] = {onFire = function (_, card, tear, player, isWisp)
    local rng = player:GetCollectibleRNG(mod.Enums.DUELLING_DISK)
    if rng:RandomFloat() < 0.2 then
        tear:AddTearFlags(TearFlags.TEAR_MIDAS)
    end
end},
[Card.CARD_WHEEL_OF_FORTUNE] = {onFire = function (_, card, tear, player, isWisp)
    local rng = player:GetCollectibleRNG(mod.Enums.DUELLING_DISK)
    if not isWisp then
        local dmgMult = rng:RandomInt(1, 8) / 4
        tear.CollisionDamage = tear.CollisionDamage * dmgMult
    end

    local possibleFlags = {
        TearFlags.TEAR_PIERCING,
        TearFlags.TEAR_WIGGLE,
        TearFlags.TEAR_BURN,
        TearFlags.TEAR_EXPLOSIVE,
        TearFlags.TEAR_BOUNCE,
        TearFlags.TEAR_SQUARE,
        TearFlags.TEAR_BIG_SPIRAL,
        TearFlags.TEAR_JACOBS,
    }
    local flag = mod.Functions.GetRandomTableElement(rng, possibleFlags)
    tear:AddTearFlags(flag)
    if (flag & TearFlags.TEAR_BURN) == TearFlags.TEAR_BURN then tear:Update() end
    if not isWisp and (flag & TearFlags.TEAR_EXPLOSIVE) == TearFlags.TEAR_EXPLOSIVE then
        local col = tear.Color
        col.A = 1
        tear.Color = col
        tear.SpriteScale = Vector(0.01, 0.01)
    end
end},
[Card.CARD_STRENGTH] = {damage = 60, tearFlags = TearFlags.TEAR_PUNCH},
[Card.CARD_HANGED_MAN] = {onCollide = function (_, card, tear, player, npc)
    local rng = player:GetCollectibleRNG(mod.Enums.DUELLING_DISK)
    for i = 1, 2 do
        if rng:RandomFloat() < 0.5 then
            player:AddBlueFlies(1, tear.Position + tear.Velocity:Resized(-10), nil)
        else
            player:ThrowBlueSpider(tear.Position, tear.Position + tear.Velocity:Resized(-80))
        end
    end
end},
[Card.CARD_DEATH] = {damage = 0, onCollide = function (_, card, tear, player, npc)
    local damage = 40 * (1 + player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MISSING_PAGE_2) + player:GetTrinketMultiplier(TrinketType.TRINKET_MISSING_PAGE))
    for _, entity in ipairs(Isaac.FindInRadius(tear.Position, 50, EntityPartition.ENEMY)) do
        local enemy = entity:ToNPC()
        if enemy and enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy() and not enemy:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
            enemy:TakeDamage(damage, 0, EntityRef(player), 0)
            local deathSplat = Color(-1, -1, -1)
            enemy.SplatColor = deathSplat
            enemy:MakeSplat(1)
        end
    end
    mod.Consts.SFX:Play(SoundEffect.SOUND_DEATH_CARD)
end},
[Card.CARD_TEMPERANCE] = {onCollide = function (_, card, tear, player, npc)
    local rng = player:GetCollectibleRNG(mod.Enums.DUELLING_DISK)
    for i = 1, 3 do
        local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_RED, 0, tear.Position + Vector(rng:RandomInt(-40, 40), rng:RandomInt(-40, 40)), Vector.Zero, player)
        creep.SpriteScale = Vector(0.8, 0.8)
        creep:Update()
    end
end},
[Card.CARD_DEVIL] = {damage = 75},
[Card.CARD_TOWER] = {onDeath = function (_, card, tear, player)
    local bomb = Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_TROLL, 0, tear.Position, Vector.Zero, player):ToBomb()
    bomb:AddTearFlags(player:GetBombFlags())
    bomb:SetExplosionCountdown(0)
    bomb.Visible = false
end},
[Card.CARD_STARS] = {onCollide = function (_, card, tear, player, npc)
    local rng = player:GetCollectibleRNG(mod.Enums.DUELLING_DISK)
    if rng:RandomFloat() < 0.025 then
        local room = mod.Consts.Game:GetRoom()
        local seed = rng:Next()
        local newCard = mod.Consts.Game:GetItemPool():GetCard(seed, true, false, false)
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, newCard, room:FindFreePickupSpawnPosition(tear.Position), Vector.Zero, player)
    end
end},
[Card.CARD_MOON] = {velMult = 0.5, tearFlags = TearFlags.TEAR_SLOW},
[Card.CARD_SUN] = {damage = 0, onCollide = function (_, card, tear, player, npc)
    local damage = 30
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        local n = entity:ToNPC()
        if n and n:IsVulnerableEnemy() and n:IsActiveEnemy() and not n:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
            n:TakeDamage(damage, 0, EntityRef(player), 0)
            --n:SetColor(Color(1, 1, 1, 1, 0, 0, 0, 2, 2, 0.6, 1), 10, 1, true, false)
        end
    end
    SpawnPulse(player, tear.Position, 1, 200, 30, function (effect, pl)
        effect.Color = Color(1, 1, 1, 0.4, 0, 0, 0, 1.5, 1.5, 0.45, 1)
    end)
end},
[Card.CARD_CLUBS_2] = {consume = 0.45, onCollide = function (_, card, tear, player, npc)
    player:AddBombs(2)
end},
[Card.CARD_DIAMONDS_2] = {consume = 0.45, onCollide = function (_, card, tear, player, npc)
    player:AddCoins(2)
end},
[Card.CARD_SPADES_2] = {consume = 0.45, onCollide = function (_, card, tear, player, npc)
    player:AddKeys(2)
end},
[Card.CARD_HEARTS_2] = {consume = 0.45, onCollide = function (_, card, tear, player, npc)
    player:AddHearts(4)
end},
[Card.CARD_ACE_OF_CLUBS] = {consume = 0.25, onCollide = function (_, card, tear, player, npc)
    if not npc:IsBoss() then
        npc:Remove()
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, 0, npc.Position, Vector.Zero, player)
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, npc.Position, Vector.Zero, nil)
    end
end},
[Card.CARD_ACE_OF_DIAMONDS] = {consume = 0.25, onCollide = function (_, card, tear, player, npc)
    if not npc:IsBoss() then
        npc:Remove()
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, npc.Position, Vector.Zero, player)
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, npc.Position, Vector.Zero, nil)
    end
end},
[Card.CARD_ACE_OF_SPADES] = {consume = 0.25, onCollide = function (_, card, tear, player, npc)
    if not npc:IsBoss() then
        npc:Remove()
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, 0, npc.Position, Vector.Zero, player)
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, npc.Position, Vector.Zero, nil)
    end
end},
[Card.CARD_ACE_OF_HEARTS] = {consume = 0.25, onCollide = function (_, card, tear, player, npc)
    if not npc:IsBoss() then
        npc:Remove()
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, 0, npc.Position, Vector.Zero, player)
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, npc.Position, Vector.Zero, nil)
    end
end},
[Card.CARD_JOKER] = {onCollide = function (_, card, tear, player, npc)
    local rng = player:GetCollectibleRNG(mod.Enums.DUELLING_DISK)
    if rng:RandomFloat() < 0.5 then
        local laser = player:SpawnMawOfVoid(45)
        local dummy = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TARGET, 0, npc.Position, Vector.Zero, nil):ToEffect()
        Isaac.CreateTimer(function ()
            dummy:Remove()
        end, 45, 1, false)
        dummy.Visible = false
        laser.Parent = dummy
    else
        for i = 1, 4 do
            local laser = EntityLaser.ShootAngle(LaserVariant.LIGHT_BEAM, npc.Position, i * 90, 15, Vector.Zero, player)
            laser.CollisionDamage = player.Damage / 4
            laser.DisableFollowParent = true
        end
    end
end},
[Card.CARD_CHAOS] = {consume = 1, onCollide = function (_, card, tear, player, npc)
    if not npc:ToDelirium() and not (npc.Type == EntityType.ENTITY_BEAST and npc.Variant == 0) then
        npc:Kill()
    end
end, onDeath = function (_, card, tear, player)
    local bomb = Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_GIGA, 0, tear.Position, Vector.Zero, player):ToBomb()
    bomb:AddTearFlags(player:GetBombFlags())
    bomb:SetExplosionCountdown(0)
    bomb.Visible = false
end},
[Card.CARD_HUMANITY] = {onCollide = function (_, card, tear, player, npc)
    local rng = player:GetCollectibleRNG(mod.Enums.DUELLING_DISK)
    for i = 1, 2 do
        local poopvar = GridPoopVariant.NORMAL
        if rng:RandomFloat() < 0.1 and player:HasTrinket(TrinketType.TRINKET_MECONIUM) then
            poopvar = GridPoopVariant.BLACK
        elseif rng:RandomFloat() < 0.1 and player:HasCollectible(CollectibleType.COLLECTIBLE_HALLOWED_GROUND) then
            poopvar = GridPoopVariant.HOLY
        elseif rng:RandomFloat() < 0.1 and player:HasCollectible(CollectibleType.COLLECTIBLE_MIDAS_TOUCH) then
            poopvar = GridPoopVariant.GOLDEN
        end
        Isaac.GridSpawn(GridEntityType.GRID_POOP, poopvar, Isaac.GetFreeNearPosition(tear.Position, 40), false)
    end
    if rng:RandomFloat() < 0.1 and not npc:IsBoss() then
        npc:Morph(EntityType.ENTITY_POOP, 0, 0, -1)
    end
    mod.Consts.SFX:Play(SoundEffect.SOUND_FART)
end},
[Card.CARD_SUICIDE_KING] = {damage = 500, consume = 1, onCollide = function (_, card, tear, player, npc)
    if npc.HitPoints <= 500 then
        npc:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
    end
    local rng = player:GetCollectibleRNG(mod.Enums.DUELLING_DISK)
    local room = mod.Consts.Game:GetRoom()
    local pool = room:GetItemPool(rng:Next())
    if pool == ItemPoolType.POOL_NULL then
        pool = mod.Consts.Game:IsGreedMode() and ItemPoolType.POOL_GREED_TREASURE or ItemPoolType.POOL_TREASURE
    end
    local item = mod.Consts.Game:GetItemPool():GetCollectible(pool, true, rng:Next())
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, item, Isaac.GetFreeNearPosition(npc.Position, 40), Vector.Zero, player)
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_CHEST, 0, Isaac.GetFreeNearPosition(npc.Position, 40), Vector.Zero, nil)
    for i = 1, 3 do
        Isaac.Spawn(EntityType.ENTITY_PICKUP, 0, NullPickupSubType.NO_COLLECTIBLE, Isaac.GetFreeNearPosition(npc.Position, 40), Vector.Zero, nil)
    end
end},
[Card.CARD_GET_OUT_OF_JAIL] = {onCollide = function (_, card, tear, player, npc)
    player:UseActiveItem(CollectibleType.COLLECTIBLE_DADS_KEY, UseFlag.USE_NOANIM)
end},
[Card.CARD_HOLY] = {tearFlags = TearFlags.TEAR_HOMING | TearFlags.TEAR_GLOW},
[Card.CARD_HUGE_GROWTH] = {damage = 100, velMult = 0.5, tearFlags = TearFlags.TEAR_PIERCING, onFire = function (_, card, tear, player, isWisp)
    tear.Size = tear.Size * 2.25
    tear.SpriteScale = tear.SpriteScale * 2.25
    if not isWisp then
        mod.Consts.SFX:Play(SoundEffect.SOUND_SHELLGAME, 1, 2, false, 0.5)
    end
end},
[Card.CARD_ANCIENT_RECALL] = {damage = 120, consume = 1, onDeath = function (_, card, tear, player)
    local rng = player:GetCollectibleRNG(mod.Enums.DUELLING_DISK)
    for i = -1, 1 do
        local seed = rng:Next()
        local newCard = mod.Consts.Game:GetItemPool():GetCard(seed, true, false, false)
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, newCard, tear.Position, tear.Velocity:Resized(-3):Rotated(i * 30), player)
    end
end},
[Card.CARD_ERA_WALK] = {damage = 100, velMult = 0.05, tearFlags = TearFlags.TEAR_PIERCING, onFire = function (_, card, tear, player, isWisp)
    tear.FallingSpeed = 0
    tear.FallingAcceleration = -0.1
end},
[Card.CARD_REVERSE_FOOL] = {onFire = function (_, card, tear, player, isWisp)
    if not isWisp then
        local extraDmgTable = {
            math.min(player:GetNumCoins(), 5),
            math.min(player:GetNumBombs(), 5),
            math.min(player:GetNumKeys(), 5)
        }
        player:AddCoins(extraDmgTable[1] * -1)
        player:AddBombs(extraDmgTable[2] * -1)
        player:AddKeys(extraDmgTable[3] * -1)
        for i = 1, 3 do
            tear.CollisionDamage = tear.CollisionDamage + extraDmgTable[i] * 3
        end
        TempData:AddData(tear, "duellingDiskReverseFoolPickups", extraDmgTable)
    end
end,
onCollide = function (_, card, tear, player, npc)
    local data = TempData:GetData(tear)
    if data.duellingDiskReverseFoolPickups then
        local pickupVaraints = {PickupVariant.PICKUP_COIN, PickupVariant.PICKUP_BOMB, PickupVariant.PICKUP_KEY}
        for i, v in ipairs(data.duellingDiskReverseFoolPickups) do
            for j = 1, v do
                Isaac.Spawn(EntityType.ENTITY_PICKUP, pickupVaraints[i], 1, tear.Position, tear.Velocity:Resized(-4):Rotated(math.random(-60, 60)), player)
            end
        end
    end
end},
[Card.CARD_REVERSE_MAGICIAN] = {onCollide = function (_, card, tear, player, npc)
    local radius = 75
    for _, proj in ipairs(Isaac.FindInRadius(tear.Position, radius, EntityPartition.BULLET)) do
        proj = proj:ToProjectile()
        proj:AddProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER | ProjectileFlags.HIT_ENEMIES)
        proj.Velocity = (proj.Position - tear.Position):Resized(10)
    end
    for _, entity in ipairs(Isaac.FindInRadius(tear.Position, radius, EntityPartition.ENEMY)) do
        local enemy = entity:ToNPC()
        if enemy and enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy() and not enemy:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
            enemy:AddKnockback(EntityRef(player), (enemy.Position - tear.Position):Resized(15), 15, true)
        end
    end
    SpawnPulse(player, tear.Position, 1, radius / 2, 30, function (effect, pl)
        effect.Color = Color(0.5, 0.7, 1, 0.4, 0, 0, 0)
    end)
end},
[Card.CARD_REVERSE_EMPRESS] = {onCollide = function (_, card, tear, player, npc)
    npc:AddBleeding(EntityRef(player), 63)
end},
[Card.CARD_REVERSE_HIEROPHANT] = {tearFlags = TearFlags.TEAR_BONE, onFire = function (_, card, tear, player, isWisp)
    if not isWisp then
        local col = tear.Color
        col.A = 1
        tear.Color = col
        tear.SpriteScale = Vector(0.01, 0.01)
    end
    tear:ChangeVariant(TearVariant.BONE)
end},
[Card.CARD_REVERSE_LOVERS] = {onCollide = function (_, card, tear, player, npc)
    local damage = math.min(npc.MaxHitPoints / 12, 100)
    npc:TakeDamage(damage, 0, EntityRef(player), 0)
    npc.Color = npc.Color * Color(1.05, 1, 1, 1, 0, 0, 0, 0.9, 0.6, 0.6, 1)
    mod.Consts.SFX:Play(SoundEffect.SOUND_FORTUNE_COOKIE, 1, 2, false, 0.75)
end},
[Card.CARD_REVERSE_CHARIOT] = {onCollide = function (_, card, tear, player, npc)
    local slot = player:GetActiveItemSlot(mod.Enums.DUELLING_DISK)
    if slot ~= -1 then
        player:FullCharge(slot)
    end
end},
[Card.CARD_REVERSE_JUSTICE] = {consume = 0.35, onCollide = function (_, card, tear, player, npc)
    local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_CHEST, 0, npc.Position, Vector.Zero, player):ToPickup()
    pickup.Visible = false
    pickup:TryOpenChest(player)
end},
[Card.CARD_REVERSE_WHEEL_OF_FORTUNE] = {onCollide = function (_, card, tear, player, npc)
    local rng = player:GetCollectibleRNG(mod.Enums.DUELLING_DISK)
    local roll = rng:RandomInt(1, 3)
    if roll == 1 then
        mod.Consts.Game:DevolveEnemy(npc)
        mod.Consts.SFX:Play(SoundEffect.SOUND_EDEN_GLITCH)
    elseif roll == 2 then
        mod.Consts.Game:RerollEnemy(npc)
        mod.Consts.SFX:Play(SoundEffect.SOUND_EDEN_GLITCH)
    elseif not duellingDiskD7ed then
        player:UseActiveItem(CollectibleType.COLLECTIBLE_D7, UseFlag.USE_NOANIM)
        duellingDiskD7ed = true
    end
end},
[Card.CARD_REVERSE_STRENGTH] = {onCollide = function (_, card, tear, player, npc)
    npc:AddWeakness(EntityRef(player), 63)
end},
[Card.CARD_REVERSE_HANGED_MAN] = {damage = 30, preFire = function (_, card, player)
    local direction = player:GetAimDirection():Resized(20) + player:GetTearMovementInheritance(player:GetShootingInput())
    for i = -15, 15, 30 do
        local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLUE, 0, player.Position, direction:Rotated(i), player):ToTear()
        tear.CollisionDamage = 30
        local col = tear.Color
        col.A = 0
        tear.Color = col
        tear:SetInitSound(SoundEffect.SOUND_NULL)

        local data = tear:GetData()
        data.DuellingDiskTearType = card
        data.DuellingDiskCopyTearType = -1

        local cconfig = mod.Consts.Conf:GetCard(card)
        local econfig = EntityConfig.GetEntity(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, cconfig.PickupSubtype)
        local spr = Sprite(econfig:GetAnm2Path())
        spr:Play("Idle", true)
        spr:LoadGraphics()
        TempData:AddData(tear, "thrownTearSprite", spr)
    end
end},
[Card.CARD_REVERSE_DEATH] = {onCollide = function (_, card, tear, player, npc)
    for i = 1, 2 do
        local bone = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BONE_SPUR, 0, tear.Position, Vector.Zero, player)
        bone:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        bone:AddVelocity(RandomVector():Resized(math.random(3, 9)))
    end
end},
[Card.CARD_REVERSE_DEVIL] = {damage = 80, velMult = 0.5, tearFlags = TearFlags.TEAR_HOMING},
[Card.CARD_REVERSE_TOWER] = {damage = 0, onDeath = function (_, card, tear, player)
    local shockwave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, tear.Position, Vector.Zero, player):ToEffect()
    shockwave.Parent = player
    shockwave.MaxRadius = 60
end},
[Card.CARD_REVERSE_STARS] = {onCollide = function (_, card, tear, player, npc)
    local rng = player:GetCollectibleRNG(mod.Enums.DUELLING_DISK)
    if rng:RandomFloat() < 0.01 then
        local room = mod.Consts.Game:GetRoom()
        local pool = room:GetItemPool(rng:Next())
        if pool == ItemPoolType.POOL_NULL then
            pool = mod.Consts.Game:IsGreedMode() and ItemPoolType.POOL_GREED_TREASURE or ItemPoolType.POOL_TREASURE
        end
        local item = mod.Consts.Game:GetItemPool():GetCollectible(pool, true, rng:Next())
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, item, Isaac.GetFreeNearPosition(npc.Position, 40), Vector.Zero, player)
    end
end},
[Card.CARD_REVERSE_SUN] = {damage = 75, tearFlags = TearFlags.TEAR_FEAR},
[mod.Enums.POLYMERIZATION] = {damage = 0, onCollide = function (_, card, tear, player, npc)
    local entities = mod.Functions.FilterOutTable(Isaac.GetRoomEntities(), function (entity)
        local n = entity:ToNPC()
        if not n then return true end
        return not (n:IsVulnerableEnemy() and n:IsActiveEnemy() and not n:HasEntityFlags(EntityFlag.FLAG_FRIENDLY))
    end)
    local damage = 15 + #entities * 7
    for _, entity in ipairs(entities) do
        entity:TakeDamage(damage, 0, EntityRef(player), 0)
        --n:SetColor(Color(1, 1, 1, 1, 0, 0, 0, 2, 2, 0.6, 1), 10, 1, true, false)
    end
    SpawnPulse(player, tear.Position, 1, 200, 30, function (effect, pl)
        effect.Color = Color(1, 1, 1, 0.4, 0, 0, 0, 2, 0, 1, 1)
    end)
end},
[mod.Enums.IJIRAQ] = {damage = 10, onCollide = function (_, card, tear, player, npc)
    if not npc:IsBoss() then
        local center = mod.Consts.Game:GetRoom():GetCenterPos()
        local fren = Isaac.Spawn(npc.Type, npc.Variant, npc.SubType, center + (npc.Position - center) * -1, Vector.Zero, player)
        fren:AddCharmed(EntityRef(player), -1)
        TempData:AddData(fren, "duellingDiskIjiraqFriendly", true)
    end
end},
[mod.Enums.MAGNETIC_CARD] = {onCollide = function (_, card, tear, player, npc)
    npc:AddMagnetized(EntityRef(player), 45)
end},
}

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
    duellingDiskD7ed = false
end)

-- Shared
mod:AddCallback(mod.CustomCallbacks.POST_DUELLING_DISK_SHOT_DEATH, function (_, card, tear, player)
    local rng = player:GetCollectibleRNG(mod.Enums.DUELLING_DISK)
    local consume = DuellingDiskSynergy[card] and DuellingDiskSynergy[card].consume
    if not consume or (consume and rng:RandomFloat() < (1 - consume)) then
        local data = tear:GetData()
        if not (data.DuellingDiskCopyTearType and data.DuellingDiskCopyTearType == -1) then
            local cardDrop = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, data.DuellingDiskCopyTearType or card, tear.Position, tear.Velocity:Resized(-3), player):ToPickup()
            cardDrop.Touched = true
        end
        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, tear.Position, Vector.Zero, nil)
        poof.SpriteScale = Vector(0.7, 0.7)
    else
        for i = 1, 3 do
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TOOTH_PARTICLE, 0, tear.Position, Vector.Zero, nil)
        end
    end
end)

-- Build callbacks
for card, synergy in pairs(DuellingDiskSynergy) do
    if synergy.preFire then
        mod:AddCallback(mod.CustomCallbacks.PRE_FIRE_DUELLING_DISK, synergy.preFire, card)
    end
    if synergy.onFire or synergy.damage or synergy.velMult or synergy.tearFlags then
        if synergy.onFire then
            mod:AddCallback(mod.CustomCallbacks.POST_FIRE_DUELLING_DISK, synergy.onFire, card)
        end
        mod:AddCallback(mod.CustomCallbacks.POST_FIRE_DUELLING_DISK, function (_, card, tear, player)
            if synergy.damage then tear.CollisionDamage = synergy.damage end
            if synergy.velMult then tear.Velocity = tear.Velocity * synergy.velMult end
            if synergy.tearFlags then tear:AddTearFlags(synergy.tearFlags) end
        end, card)
    end
    if synergy.onCollide then
        mod:AddCallback(mod.CustomCallbacks.POST_DUELLING_DISK_SHOT_COLLISION, synergy.onCollide, card)
    end
    if synergy.onDeath then
        mod:AddCallback(mod.CustomCallbacks.POST_DUELLING_DISK_SHOT_DEATH, synergy.onDeath, card)
    end
end

-- Special ones
local function InitDuellingDiskSynergy(effect, card, tear, player)
    local synergy = DuellingDiskSynergy[effect]
    if synergy then
        if synergy.onFire then
            synergy.onFire(_, card, tear, player)
        end
        if synergy.damage then tear.CollisionDamage = synergy.damage end
        if synergy.velMult then tear.Velocity = tear.Velocity * synergy.velMult end
        if synergy.tearFlags then tear:AddTearFlags(synergy.tearFlags) end
    end
end

mod:AddPriorityCallback(mod.CustomCallbacks.POST_FIRE_DUELLING_DISK, CallbackPriority.EARLY, function (_, card, tear, player)
    local rng = player:GetCollectibleRNG(mod.Enums.DUELLING_DISK)
    local possibleEffects = {}
    for k, v in pairs(DuellingDiskSynergy) do
        if not v.consume then
            table.insert(possibleEffects, k)
        end
    end
    local data = tear:GetData()
    data.DuellingDiskTearType = mod.Functions.GetRandomTableElement(rng, possibleEffects)
    data.DuellingDiskCopyTearType = card
    InitDuellingDiskSynergy(data.DuellingDiskTearType, card, tear, player)
    return true
end, Card.CARD_QUESTIONMARK)

mod:AddPriorityCallback(mod.CustomCallbacks.POST_FIRE_DUELLING_DISK, CallbackPriority.EARLY, function (_, card, tear, player)
    local data = tear:GetData()
    data.DuellingDiskTearType = GetDuellingDiskData(player).LastDuellingDiskCard
    data.DuellingDiskCopyTearType = card
    InitDuellingDiskSynergy(data.DuellingDiskTearType, card, tear, player)
    return true
end, Card.CARD_WILD)

mod:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, function ()
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        local data = TempData:GetData(entity)
        if data.duellingDiskIjiraqFriendly then
            entity:Remove()
        end
    end
end)

-- Wisp synergy
mod:AddCallback(mod.CustomCallbacks.POST_DUELLING_DISK_SHOT_DEATH, function (_, card, tear, player)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
        local wisp = player:AddWisp(mod.Enums.DUELLING_DISK, tear.Position + tear.Velocity:Resized(-20))
        TempData:AddData(wisp, "duellingDiskWispType", card)
    end
end)

---@param tear EntityTear
mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_FIRE_PROJECTILE, function (_, tear)
    local familiar = tear.SpawnerEntity
    if not familiar then return end
    local data = TempData:GetData(familiar)
    if data.duellingDiskWispType then
        familiar = familiar:ToFamiliar()
        local synergy = DuellingDiskSynergy[data.duellingDiskWispType]
        if synergy then
            if synergy.velMult then tear.Velocity = tear.Velocity * synergy.velMult end
            if synergy.tearFlags then tear:AddTearFlags(synergy.tearFlags) end
            if synergy.onFire then
                synergy.onFire(_, DuellingDiskSynergy[data.duellingDiskWispType], tear, familiar.Player, true)
            end
        end
    end
end, FamiliarVariant.WISP)