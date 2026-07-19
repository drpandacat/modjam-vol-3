local mod = CardJam_AeroTruji
local TempData = mod.TempData
local id = mod.Enums.DUELLING_DISK

local ThrowableCardTypes = {
    [ItemConfig.CARDTYPE_TAROT] = true,
    [ItemConfig.CARDTYPE_TAROT_REVERSE] = true,
    [ItemConfig.CARDTYPE_SUIT] = true,
    [ItemConfig.CARDTYPE_SPECIAL] = true,
}

local CARD_SPRITE_OFFSET = Vector(0, -5)

local ActiveHUDOffsets = {
    [1] = 1,    -- Tarot
    [14] = 1,   -- Reverse Tarot
}

local identifier = "CardJam_Duelling_Disk" -- For throwable active function
local itemUseIdentifier = "using" .. identifier

---@param player EntityPlayer
---@return table
local function GetDuellingDiskData(player)
    local data, exists = EntitySaveStateManager.GetEntityData(mod, player)
    -- if not exists then
        data.LastDuellingDiskCard = data.LastDuellingDiskCard or 0
    -- end
    return data
end

mod.Functions.MakeThrowableActive(id, identifier,
    function (player)
        local pdata = GetDuellingDiskData(player)
        local direction = player:GetAimDirection():Resized(20) + player:GetTearMovementInheritance(player:GetShootingInput())
        local card = player:GetPocketItem(PillCardSlot.PRIMARY):GetSlot()

        Isaac.RunCallbackWithParam(mod.CustomCallbacks.PRE_FIRE_DUELLING_DISK, card, card, player)
        local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLUE, 0, player.Position, direction, player):ToTear()
        tear.CollisionDamage = 40
        local col = tear.Color
        col.A = 0
        tear.Color = col
        tear:SetInitSound(SoundEffect.SOUND_NULL)
        local copyOverride = Isaac.RunCallbackWithParam(mod.CustomCallbacks.POST_FIRE_DUELLING_DISK, card, card, tear, player)

        player:RemovePocketItem(PillCardSlot.PRIMARY)
        if not copyOverride then
            tear:GetData().DuellingDiskTearType = card
        end
        pdata.LastDuellingDiskCard = tear:GetData().DuellingDiskTearType

        local cconfig = mod.Consts.Conf:GetCard(card)
        local econfig = EntityConfig.GetEntity(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, cconfig.PickupSubtype)
        local spr = Sprite(econfig:GetAnm2Path())
        spr:Play("Idle", true)
        spr:LoadGraphics()
        TempData:AddData(tear, "thrownTearSprite", spr)
        mod.Consts.SFX:Play(SoundEffect.SOUND_SHELLGAME)
    end,
    function (player)
        local pocket = player:GetPocketItem(PillCardSlot.PRIMARY)
        local type = pocket:GetSlot()
        local config = mod.Consts.Conf:GetCard(type)
        return pocket:GetType() == PocketItemType.CARD and type ~= Card.CARD_NULL and config and ThrowableCardTypes[config.CardType]
    end
)

---@param player EntityPlayer
---@param slot PillCardSlot
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_DROP_CARD, function (_, player, _, slot)
    if player:GetPocketItem(PillCardSlot.PRIMARY):GetSlot() == Card.CARD_NULL then
        local data = player:GetData()
        if data[itemUseIdentifier] then
            data[itemUseIdentifier] = false
            player:AnimateCollectible(id, "HideItem", "PlayerPickup")
        end
    end
end)

---@param tear EntityTear
mod:AddCallback(ModCallbacks.MC_POST_TEAR_RENDER, function (_, tear)
    local data = TempData:GetData(tear)
    if data.thrownTearSprite then
        local spr = data.thrownTearSprite ---@type Sprite
        spr:Render(Isaac.WorldToScreen(tear.Position + tear.SpriteOffset + Vector(0, tear.Height) + CARD_SPRITE_OFFSET))
        local tdata = tear:GetData()
        if tdata.DuellingDiskTearType ~= Card.CARD_WHEEL_OF_FORTUNE and tdata.DuellingDiskTearType ~= Card.CARD_REVERSE_HIEROPHANT then     -- dumb hacky
            spr.Scale = tear.SpriteScale
        end
        if not mod.Consts.Game:IsPaused() then
            spr.Rotation = spr.Rotation + math.max(40 - tear.FrameCount, 15)
        end
    end
end)

---@param tear EntityTear
---@param collider Entity
mod:AddCallback(ModCallbacks.MC_POST_TEAR_COLLISION, function (_, tear, collider)
    local npc = collider:ToNPC()
    if not npc then return end
    if not (npc:IsVulnerableEnemy() and npc:IsActiveEnemy()) then return end
    if npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then return end

    local data = tear:GetData()
    local card = data.DuellingDiskTearType
    if not card then return end
    local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
    Isaac.RunCallbackWithParam(mod.CustomCallbacks.POST_DUELLING_DISK_SHOT_COLLISION, card, card, tear, player, npc)
end)

---@param tear EntityTear
mod:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, function (_, tear)
    local data = tear:GetData()
    local card = data.DuellingDiskTearType
    if not card then return end
    local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
    Isaac.RunCallbackWithParam(mod.CustomCallbacks.POST_DUELLING_DISK_SHOT_DEATH, card, card, tear, player)
    mod.Consts.SFX:Stop(SoundEffect.SOUND_TEARIMPACTS)
end)

-- Change HUD sprites

---@param player EntityPlayer
---@param slot ActiveSlot
mod:AddCallback(ModCallbacks.MC_PRE_PLAYERHUD_RENDER_ACTIVE_ITEM, function (_, player, slot)
    if player:GetActiveItem(slot) ~= id then return end
    local offset = 0
    local pocket = player:GetPocketItem(PillCardSlot.PRIMARY)
    local type = pocket:GetSlot()
    local config = mod.Consts.Conf:GetCard(type)
    if pocket:GetType() == PocketItemType.CARD and type ~= Card.CARD_NULL and config and ThrowableCardTypes[config.CardType] then
        offset = ActiveHUDOffsets[config.PickupSubtype] and ActiveHUDOffsets[config.PickupSubtype] or 2
    end
    return {CropOffset = Vector(offset * 32, 0)}
end)

-- Card drop on pickup
mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, function (_, type, charge, first, slot, vardata, player)
    if not first then return end
    local rng = player:GetCollectibleRNG(id)
    local seed = rng:Next()
    local card = mod.Consts.Game:GetItemPool():GetCard(seed, true, false, false)
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, card, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, player)
end, id)

-- Wisp
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
    for _, wisp in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, id)) do
        wisp:Remove()
    end
end)