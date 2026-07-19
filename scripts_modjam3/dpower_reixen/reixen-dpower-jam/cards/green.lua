local Mod = ModJamHolder
local GREEN = {}
ModJamHolder.Card.GREEN = GREEN
GREEN.NAME = "Kindness Card"
GREEN.ID = Isaac.GetCardIdByName(GREEN.NAME)

GREEN.EGG_ANM2 = "gfx/pickup_cooked_egg.anm2"

local ONE_SEC = 30
GREEN.PAN_ID = Isaac.GetEntityVariantByName("Green Cooking Pan")
GREEN.BASE_EGG_AMT = 3
GREEN.EGG_TIMEOUT = ONE_SEC * 1.5

GREEN.HOT_HEAD_COSTUME = Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_HOT_BOMBS)

local room_id_that_reixen_wants_the_card_to_not_trigger_twice_just_in_case_the_player_has_overcharged_blank_card = 0

--[[
GREEN.SFX = Isaac.GetSoundIdByName("GREEN")
GREEN.SFX_ALT = Isaac.GetSoundIdByName("Cultivate")
GREEN.SFX_ALT_CHANCE = 0.2]]

GREEN.WIKI = {
    { -- Effect
        { str = "Effect", fsize = 2, clr = 3, halign = 0 },
        { str = "Spawns a cooking pan that follows the player and throws cooked eggs." },
        { str = "Amount of eggs thrown is 3 + the amount of enemies killed in the room." },
        { str = "The eggs disappear after a while, with each egg healing half a red heart when picked up." },
        { str = "When Isaac cannot gain any red heart heals, the eggs heal half soul hearts instead." },
    },
    { -- Trivia
        { str = "Trivia", fsize = 2, clr = 3, halign = 0 },
        { str = "Art by Reixen" },
        { str = "Code by dpower12" },
        { str = "" },
        { str = "" },
    },
}

GREEN.EID = "Spawns a cooking pan that throws a cooked egg per enemy killed in the room + 3"..
            "#The eggs disappear after a while and each heals {{HalfHeart}} when picked up"..
            "#These eggs grant {{HalfSoulHeart}} instead if they are unable to heal heart containers"

function GREEN:ShootEgg(pan)
    local room = Mod.Game:GetRoom()
    local eggPos = room:FindFreePickupSpawnPosition(room:GetRandomPosition(0))
    local egg = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF, eggPos, Vector.Zero, pan.Parent):ToPickup() ---@cast egg EntityPickup
    local sprite = egg:GetSprite()
    sprite:Load(GREEN.EGG_ANM2, true)
    sprite:Play("Appear", true)
    egg.Timeout = ONE_SEC * 3 + GREEN.EGG_TIMEOUT
end


function GREEN:GetDeadEnemies()
    local level = Game():GetLevel()
    local roomDescriptor = level:GetCurrentRoomDesc()
    local roomConfigRoom = roomDescriptor.Data
    local spawnList = roomConfigRoom.Spawns
    local enemiesSpawn = 0
    --print("size: " ..spawnList.Size)
    for i = 0, spawnList.Size do
        local roomConfigSpawn = spawnList:Get(i)
        if roomConfigSpawn then
            local roomConfigEntry = roomConfigSpawn:PickEntry(0)
            local xmlData = XMLData.GetEntityByTypeVarSub(roomConfigEntry.Type, roomConfigEntry.Variant, roomConfigEntry.Subtype)
            if xmlData and tonumber(xmlData.id) >= 10 and tonumber(xmlData.id) < 1000 then
                enemiesSpawn = enemiesSpawn + 1
            end
        end
    end

    local enemiesActive = 0
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity:IsEnemy() and entity:IsActiveEnemy() and entity.SpawnerEntity == nil then
            enemiesActive = enemiesActive + 1
        end
    end

    --print("Kindness: enemies that spawn:"..enemiesSpawn, " enemies active in the room: "..enemiesActive, " Final egg bonus count from dead enemies: "..enemiesSpawn - enemiesActive)
    return enemiesSpawn - enemiesActive
end

---@param player EntityPlayer
function GREEN:OnUseCard(_, player)
    local pan = Isaac.Spawn(EntityType.ENTITY_EFFECT, GREEN.PAN_ID, 0, player.Position, Vector.Zero, player):ToEffect() ---@cast pan EntityEffect
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, player)
    Mod.SfxMan:Play(SoundEffect.SOUND_SUMMON_POOF)
    Mod.SfxMan:Play(SoundEffect.SOUND_GOLD_HEART_DROP)
    pan.Parent = player
    pan:FollowParent(player)
    pan.SpriteOffset = Vector(0, -33)
    pan.DepthOffset = player.DepthOffset + 1
    player:AddCostume(GREEN.HOT_HEAD_COSTUME)
    local roomid = Mod.Game:GetLevel():GetCurrentRoomIndex()
    local bonus = 0
    if Mod.Game:GetRoom():IsFirstVisit() and room_id_that_reixen_wants_the_card_to_not_trigger_twice_just_in_case_the_player_has_overcharged_blank_card ~= roomid then
        bonus =  GREEN:GetDeadEnemies()
    end
    room_id_that_reixen_wants_the_card_to_not_trigger_twice_just_in_case_the_player_has_overcharged_blank_card = roomid
    pan:GetData().MJ_eggs = GREEN.BASE_EGG_AMT - 1 + bonus -- + sucked in enemies
end
Mod:AddCallback(ModCallbacks.MC_USE_CARD, GREEN.OnUseCard, GREEN.ID)

---@param player EntityPlayer
local function TryRemoveFireCostume(player)
    if player:IsItemCostumeVisible(GREEN.HOT_HEAD_COSTUME, 0) and not player:HasCollectible(CollectibleType.COLLECTIBLE_HOT_BOMBS) then
        player:TryRemoveCollectibleCostume(CollectibleType.COLLECTIBLE_HOT_BOMBS)
    end
end

---@param pan EntityEffect
function GREEN:onEffectUpdate(pan)
    local sprite = pan:GetSprite()
    local data = pan:GetData()
    if sprite:IsPlaying("Spawn") and sprite:GetFrame() == 20 then
        sprite:Play("Throw", true)
    end
    if sprite:IsEventTriggered("Shoot") then
        Mod.SfxMan:Play(SoundEffect.SOUND_BLOBBY_WIGGLE)
        Mod.SfxMan:Play(SoundEffect.SOUND_GOLDENBOMB, 0.8, 2, false, math.random(11, 13)/10)
        GREEN:ShootEgg(pan)
    end
    if sprite:IsPlaying("Throw") and sprite:GetFrame() == 34 then
        if data.MJ_eggs < 1 then
            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pan.SpawnerEntity.Position, Vector.Zero, pan):ToEffect() ---@cast poof EntityEffect
            poof.Color = Color(0.6, 0.4, 0.3)
            poof:SetColor(Color(1.4, 0.9, 0.5, 1, 0.1), 10, 1, true, true)
            Mod.SfxMan:Play(SoundEffect.SOUND_STEAM_HALFSEC)
            TryRemoveFireCostume(pan.SpawnerEntity:ToPlayer())
            sprite:Play("FadeOut")
        else
            data.MJ_eggs = data.MJ_eggs - 1
            sprite:Play("Throw", true)
        end
    end
    if sprite:IsFinished("FadeOut") then
        Mod.SfxMan:Play(SoundEffect.SOUND_FIRE_BURN)
        pan:Remove()
    end
end
Mod:AddCallback(ModCallbacks.MC_PRE_EFFECT_UPDATE, GREEN.onEffectUpdate, GREEN.PAN_ID)

---@param egg EntityPickup
---@param entity Entity
function GREEN:onEggCollision(egg, entity)
    if egg.SubType ~= HeartSubType.HEART_HALF
    or egg:GetSprite():GetFilename() ~= GREEN.EGG_ANM2
    or (entity.Type and entity.Type ~= EntityType.ENTITY_PLAYER) then return end

    local player = entity:ToPlayer()
    if not player:CanPickRedHearts() then
        player:AddSoulHearts(1)
        egg:PlayPickupSound()
        egg:GetSprite():Play("Collect")
        egg.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        Isaac.CreateTimer(function()
            egg:Remove()
        end, 6, 1, false)
    end
end
Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, GREEN.onEggCollision, PickupVariant.PICKUP_HEART)

function GREEN:OnNewRoom()
    for _, player in ipairs(PlayerManager.GetPlayers()) do
        TryRemoveFireCostume(player)
    end
end
Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, GREEN.OnNewRoom)