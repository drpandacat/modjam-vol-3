if not REPENTANCE then return end
local mod = RegisterMod("modjam3_bnd", 1)
local sfx = SFXManager()



local potOfGreed = Isaac.GetCardIdByName("Pot of Greed")

-- Spawn two random trinkets
function mod:useCardPotOfGreed(card, player, flags)
    local room = Game():GetRoom()
    
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0, room:FindFreePickupSpawnPosition((player.Position+Vector(40,0)), 0, false, false), Vector.Zero, player)
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0, room:FindFreePickupSpawnPosition((player.Position-Vector(40,0)), 0, false, false), Vector.Zero, player)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.useCardPotOfGreed, potOfGreed)




local misprint = Isaac.GetCardIdByName("Misprint Card")

-- 2 random card effects
function mod:useCardMisprint(card, player, flags)
    local pool = Game():GetItemPool()

    local v = 2
    if player:HasCollectible(CollectibleType.COLLECTIBLE_TAROT_CLOTH, false) then v = 3 end

    for i=1, v do
        local id 

        while (not id or (id==Card.CARD_REVERSE_LOVERS or id==Card.CARD_SUICIDE_KING or id==card)) do
            id = pool:GetCardEx(player:GetDropRNG():GetSeed(), 100, 0, 100, false)
            player:GetDropRNG():Next()
        end
        
        --local c = Isaac.GetItemConfig():GetCard(id)
        --Game():GetHUD():ShowItemText(c.Name, c.Description, false, true)
        player:UseCard(id, 0)
        sfx:Play(SoundEffect.SOUND_EDEN_GLITCH, 1, 0, false, 1, 0)
    end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.useCardMisprint, misprint)




local BaseballCard = Isaac.GetCardIdByName("Baseball Card")
local baseballSound = Isaac.GetSoundIdByName("Baseball Charge")

-- give forgotten bone club
function mod:useCardBaseball(card, player, flags)
    local data, exists = EntitySaveStateManager.GetEntityData(mod, player)
    if player:GetWeapon(1):GetWeaponType() == WeaponType.WEAPON_BONE then return end

    data.oldWeapon = player:GetWeapon(1)
    player:EnableWeaponType(WeaponType.WEAPON_BONE, true)
    
    data.baseballClub = Isaac.CreateWeapon(WeaponType.WEAPON_BONE, player)
    player:SetWeapon(data.baseballClub, 1)

    sfx:Play(baseballSound, 1, 0, false, 1, 0)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.useCardBaseball, BaseballCard)




local getWellSoon = Isaac.GetCardIdByName("Get Well Soon")

-- full heal
function mod:useCardGetWellSoon(card, player, flags)
    player:AddHearts(99)
    sfx:Play(SoundEffect.SOUND_KISS_LIPS1, 1, 0, false, 1, 0)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.useCardGetWellSoon, getWellSoon)




local chaosWarp = Isaac.GetCardIdByName("Chaos Warp")
local warpColor = Color(0.6,0.38,1.0,1.0,0.2,0.2,0.2)
local warpenemyColor = Color(0.46,0.16,1.0,1.0,0.3,0.0,0.75)

-- get random door position where player isnt at
local function getFreeDoorPosition(rng) 
    local room = Game():GetRoom()
    local pos = {}
    local playerpos = {}

    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        table.insert(playerpos, player.Position)
    end

    for i=0, DoorSlot.NUM_DOOR_SLOTS - 1 do 
        local doorpos = room:GetDoorSlotPosition(i) 

        if room:GetDoor(i) then 
            local far = true
            for i2, pos2 in ipairs(playerpos) do
                if far and doorpos:Distance(pos2) < 100 then 
                    far = false
                end
            end

            if far==true then table.insert(pos, doorpos) end
        end
    end

    local p
    if(#pos>0) then
        p = room:GetClampedPosition(pos[rng:RandomInt(1,#pos)], 1)
    else
        p = room:GetCenterPos()
    end
    if not p then p = room:GetCenterPos() end
    return room:FindFreePickupSpawnPosition(p, 0, true, false)
end

function mod:useCardChaosWarp(card, player, flags)
    local level = Game():GetLevel()
    local data, exists = EntitySaveStateManager.GetEntityData(mod, player)
    if not data.teleEnemies then data.teleEnemies = {} end

    for i, entity in ipairs(Isaac.FindInRadius(player.Position, 999, 0xFFFFFFFF )) do
        local id = level:GetRandomRoomIndex(false, player:GetDropRNG():GetSeed())
        if not data.teleEnemies[id] then data.teleEnemies[id]= {} end

        if entity:ToNPC() and entity:IsVulnerableEnemy() and entity:IsEnemy() and not entity:IsBoss() and not entity:IsDead() and entity.Type ~= EntityType.ENTITY_FIREPLACE then
            local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil)
            eff:SetColor(warpColor, 99, 99, false, true)
            
            table.insert(data.teleEnemies[id], {entity.Type, entity.Variant, entity.SubType, entity:ToNPC():GetChampionColorIdx()})
            entity:Remove()
            player:GetDropRNG():Next()

        elseif (entity:ToPickup() and not entity:ToPickup():IsShopItem()) or entity:ToBomb() or entity:ToSlot() then
            local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil)
            eff:SetColor(warpColor, 99, 99, false, true)

            table.insert(data.teleEnemies[id], {entity.Type, entity.Variant, entity.SubType, -1})
            entity:Remove()
            player:GetDropRNG():Next()
        end
    end

    sfx:Play(SoundEffect.SOUND_PORTAL_SPAWN, 1, 0, false, 1, 0)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.useCardChaosWarp, chaosWarp)




local scanNPlay = Isaac.GetCardIdByName("Scan-n-Play")

function mod:useCardScanNPlay(card, player, flags)
    local tempEffects = player:GetEffects()
    local data, exists = EntitySaveStateManager.GetEntityData(mod, player)

    tempEffects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_BUDDY_IN_A_BOX, false, 1)
    sfx:Play(SoundEffect.SOUND_SUMMON_POOF, 1, 0, false, 1, 0)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.useCardScanNPlay, scanNPlay)




local manaDrain = Isaac.GetCardIdByName("Mana Drain")
local manaColor = Color(0.84,0.99,1.0,1.0,0.1,0.1,0.33)
local manaPlayerColor = Color(0.47,0.31,0.79,1.0,0.61,0.84,1.0)

local wave1 = Isaac.GetEntityVariantByName("Mana Wave Effect 1")
local wave2 = Isaac.GetEntityVariantByName("Mana Wave Effect 2")

local mana1 = Isaac.GetEntityVariantByName("Mana Effect")

local function Lerp(vec1, vec2, percent)
  return vec1 * (1 - percent) + vec2 * percent
end

function mod:useCardManaDrain(card, player, flags)
    local radius = 100
    local rng = player:GetDropRNG()

    local w1 = Isaac.Spawn(EntityType.ENTITY_EFFECT, wave2, 0, player.Position, Vector.Zero, player)
    w1:GetData().Player = player
    w1.DepthOffset = -20
    w1:GetSprite().Color = manaColor

    for i=1, ((math.abs(radius / 25)) or 1) do
        local w2 = Isaac.Spawn(EntityType.ENTITY_EFFECT, wave1, 0, player.Position, Vector.Zero, player)
        local size = ((radius / 35) * (rng:RandomInt(5) + 3) / 10)
        w2.SpriteScale = Vector(size,size)
        w2.DepthOffset = -20
        w2:GetSprite().PlaybackSpeed = w2:GetSprite().PlaybackSpeed + ((rng:RandomInt(40) - 20)/100)
        
        local trans = (rng:RandomInt(40) + 10) / 100
        w2:GetSprite().Color = Color(manaColor.R,manaColor.G,manaColor.B,trans,manaColor.RO,manaColor.GO,manaColor.BO)
    end
    sfx:Play(SoundEffect.SOUND_BATTERYDISCHARGE, 3, 0, false, 2, 0)

    sfx:Play(SoundEffect.SOUND_DEATH_REVERSE, 2, 0, false, 1.5, 0)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.useCardManaDrain, manaDrain)

local maxsize = 15

function mod:wave2Update(effect)
    local s = effect:GetSprite()
    local d = effect:GetData()
    local rng = effect:GetDropRNG()

    s:Play("wave2")
    if not d.size then d.size = 0 end
    d.size = Lerp(d.size, maxsize, 0.05)
    
    s.Color = Color(manaColor.R,manaColor.G,manaColor.B,Lerp(100,0,(d.size+2)/maxsize)/100,manaColor.RO,manaColor.GO,manaColor.BO)
    effect.SpriteScale = Vector(d.size,d.size)

    if (d.size > maxsize-2) then
        effect:Remove()
    end

    for i, proj in ipairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE, -1, -1, true, false)) do
        if proj:Exists() then
            local dist = proj.Position:Distance(effect.Position)
            if dist < d.size*55 then --and dist > d.size*25 then
                
                local mana = Isaac.Spawn(EntityType.ENTITY_EFFECT, mana1, 0, proj.Position, proj.Velocity*.5, effect)
                mana:GetData().Player = d.Player
                if proj:ToProjectile().Scale > 1.5 then mana:GetData().big = true end
                mana.SpriteOffset = Vector(0,proj:ToProjectile().Height*.75)
                mana:GetSprite().Color = manaColor

                local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACKED_ORB_POOF, 0, proj.Position, proj.Velocity*.3, effect)
                eff.SpriteOffset = Vector(0,proj:ToProjectile().Height+25)

                proj:Remove()
                sfx:Play(SoundEffect.SOUND_TOOTH_AND_NAIL_TICK, 2, 0, false, 1.5, 0)
            end
        end
    end

    for i=1, 10 do 
        local pos = Vector.FromAngle(rng:RandomInt(360)):Resized(d.size*55)
        local line = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ULTRA_GREED_BLING, 0, effect.Position+pos,((effect.Position+pos)-effect.Position):Resized(d.size*2), effect)
        line:GetSprite().Color = manaColor
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.wave2Update, wave2)

function mod:wave1Update(effect)
    local s = effect:GetSprite()

    s:Play("wave1")
    if s:IsFinished("wave1") then
        effect:Remove()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.wave1Update, wave1)

function mod:manaUpdate(effect)
    local s = effect:GetSprite()
    local d = effect:GetData()
    local rng = effect:GetDropRNG()
    if not d.state then d.state = 0 end

    if d.big then 
        s:Play("Idle2")
    else
        s:Play("Idle1")
    end
    
    if d.state == 0 then 
        if not d.timeout then d.timeout = effect.Position:Distance(d.Player.Position)*.125 end
        effect.Velocity = effect.Velocity * .9
        
        d.timeout = d.timeout - 1
        if d.timeout < 0 then 
            d.state = 1
            effect.Velocity = effect.Velocity - ((d.Player.Position - effect.Position):Rotated(rng:RandomInt(180)-90):Normalized()) * (d.Player.Position - effect.Position)*.1
        
            local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0, effect.Position, effect.Velocity*.3, effect):ToEffect()
            local tsprite = trail:GetSprite()

            local length = .15
            local size = 1
            local tcolor = manaColor
            local offset = effect.SpriteOffset*1.5

            trail:FollowParent(effect)
            trail:SetRadii(length, length)
            trail.SpriteScale = Vector(size, size)
            trail.ParentOffset = offset
            tsprite.Color = tcolor
            trail:Update()

            sfx:Play(SoundEffect.SOUND_FETUS_JUMP, 1, 0, false, 1.75, 0)
        end

    elseif d.state == 1 then 
        effect.Velocity = Lerp(effect.Velocity, (d.Player.Position - effect.Position):Resized((effect.Velocity:Length()+5)*1.5), 0.125)

        if effect.Position:Distance(d.Player.Position) < d.Player.Size+20 then
            local data, exists = EntitySaveStateManager.GetEntityData(mod, d.Player)
            data.manaGain = (data.manaGain or 0) + 1
            d.Player:SetColor(manaPlayerColor, 10, 99, true, true)
            d.Player:ToPlayer():AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)

            effect:Remove()
            sfx:Play(SoundEffect.SOUND_ROTTEN_HEART, 1, 0, false, 1, 0)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.manaUpdate, mana1)




local ragingRiver = Isaac.GetCardIdByName("Raging River")
local waterEffect = Isaac.GetEntityVariantByName("Water Wave")

local roomSizes= {
    [RoomShape.ROOMSHAPE_1x1] = Vector(13,7),
    [RoomShape.ROOMSHAPE_IH] = Vector(13, 3),
    [RoomShape.ROOMSHAPE_IV] = Vector(5, 7),
    [RoomShape.ROOMSHAPE_1x2] = Vector(13, 14),
    [RoomShape.ROOMSHAPE_IIV] = Vector(5, 14),
    [RoomShape.ROOMSHAPE_2x1] = Vector(26, 7),
    [RoomShape.ROOMSHAPE_IIH] = Vector(26, 3),
    [RoomShape.ROOMSHAPE_2x2] = Vector(26, 14),
    [RoomShape.ROOMSHAPE_LTL] = Vector(26, 14),
    [RoomShape.ROOMSHAPE_LTR] = Vector(26, 14),
    [RoomShape.ROOMSHAPE_LBL] = Vector(26, 14),
    [RoomShape.ROOMSHAPE_LBR] = Vector(26, 14)
}
local enemyConverts = {
    {EntityType.ENTITY_GAPER, 2, -1} , {EntityType.ENTITY_GAPER, 0, 0},
    {EntityType.ENTITY_GURGLE, 1, -1} , {EntityType.ENTITY_DANNY, 0, 0},
    {EntityType.ENTITY_NECRO, -1, -1} , {EntityType.ENTITY_DEATHS_HEAD, 0, 0},
    {EntityType.ENTITY_WILLO, -1, -1} , {EntityType.ENTITY_ATTACKFLY, 0, 0},
    {EntityType.ENTITY_CLOTTY, 3, -1} , {EntityType.ENTITY_CLOTTY, 0, 0},
    {EntityType.ENTITY_DANNY, 1, -1} , {EntityType.ENTITY_DANNY, 0, 0},
    {EntityType.ENTITY_FLAMINGHOPPER, -1, -1} , {EntityType.ENTITY_HOPPER, 0, 0},
    {EntityType.ENTITY_GYRO, 1, -1} , {EntityType.ENTITY_GYRO, 0, 0},
    {EntityType.ENTITY_KNIGHT, 4, -1} , {EntityType.ENTITY_KNIGHT, 0, 0},
    {EntityType.ENTITY_ROCK_SPIDER, 2, -1} , {EntityType.ENTITY_ROCK_SPIDER, 0, 0},
    {EntityType.ENTITY_FATTY, 2, -1} , {EntityType.ENTITY_FATTY, 0, 0},
    {EntityType.ENTITY_DEATHSHEAD, 4, -1} , {EntityType.ENTITY_FLESH_DEATHS_HEAD, 0, 0},
    {EntityType.ENTITY_WILLO_L2, -1, -1} , {EntityType.ENTITY_FLY_L2, 0, 0},
    {EntityType.ENTITY_SKINNY, 2, -1} , {EntityType.ENTITY_SKINNY, 0, 0},
    {EntityType.ENTITY_REVENANT, -1, -1} , {EntityType.ENTITY_BONY, 0, 0},
    {EntityType.ENTITY_FIRE_WORM, -1, -1} , {EntityType.ENTITY_ROUND_WORM, 0, 0},
}

local function getWaterColor() 
    local roomColor = Game():GetRoom():GetFXParams().WaterEffectColor 
    if roomColor then 
        return Color(roomColor.R,roomColor.G,roomColor.B,0.75,roomColor.RO,roomColor.GO,roomColor.BO)
    else 
        return Color(1,1,1,.75,0,0,0)
    end
end


function mod:useCardRagingRiver(card, player, flags)
    local room = Game():GetRoom()
    local rng = player:GetDropRNG()

    local leftside = true
    local startpos = room:GetGridPosition(room:GetGridIndex(room:GetTopLeftPos()))

    if player.Position.X < startpos.X + (40*(roomSizes[room:GetRoomShape()].X-1))*0.5 then
        leftside = false
        startpos = startpos + Vector(40*(roomSizes[room:GetRoomShape()].X-1), 0)
    end
    --local leftside = (rng:RandomInt(2)==1) --random
    --if not leftside then startpos = startpos + Vector(40*(roomSizes[room:GetRoomShape()].X-1), 0) end

    for i=0, math.ceil((roomSizes[room:GetRoomShape()].X-1)/2) do
        local p = startpos
        if leftside then
            p = p + Vector(40*i, 0)
        else
            p = p - Vector(40*i, 0)
        end

        local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, waterEffect, 0, p, Vector.Zero, nil)
        eff:GetData().water = true
        local eff2 = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_SPLASH, 0, p, Vector.Zero, nil)
        eff2:SetColor(getWaterColor(), -1, 99, false, true)
    end

    Game():ShakeScreen(5)

    sfx:Play(SoundEffect.SOUND_BOSS2INTRO_WATER_EXPLOSION, 1, 0, false, 1, 0)
    sfx:Play(SoundEffect.SOUND_BOSS2_WATERTHRASHING, 0.8, 0, false, 1.5, 0)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.useCardRagingRiver, ragingRiver)

function mod:waterInit(effect)
    local s = effect:GetSprite()
    local d = effect:GetData()
    local rng = effect:GetDropRNG()
    local room = Game():GetRoom()

    d.pos = room:GetGridPosition(room:GetGridIndex(effect.Position))
    effect:SetColor(getWaterColor(), -1, 99, false, true)

    if rng:RandomInt(2)==1 then
        s.FlipX = true
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, mod.waterInit, waterEffect)

function mod:waterUpdate(effect)
    local s = effect:GetSprite()
    local d = effect:GetData()
    local rng = effect:GetDropRNG()
    local room = Game():GetRoom()
    local startpos = room:GetGridPosition(room:GetGridIndex(room:GetTopLeftPos()))

    s:Play("Appear")
    effect.Position = d.pos
    effect.Velocity = Vector.Zero

    local atLowestTile = not (effect.Position.Y < startpos.Y+(roomSizes[room:GetRoomShape()].Y-1)*40)

    if effect.FrameCount==3 then
        if not atLowestTile then 
            local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, waterEffect, 0, effect.Position+Vector(0, 40), Vector.Zero, nil)
        else
            local eff2 = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_SPLASH, 0, effect.Position, Vector.Zero, nil)
            eff2:SetColor(getWaterColor(), -1, 99, false, true)
        end
    end

    if s:IsFinished("Appear") then
        effect:Remove()
    end

    
    if s:IsEventTriggered("Impact") and rng:RandomInt(4)==0  then
        local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, effect.Position, Vector.Zero, nil)
        local effsprite = eff:GetSprite()
        effsprite:ReplaceSpritesheet(0, "gfx/effects/bloodStains.png")
        effsprite:LoadGraphics()

        local num = (rng:RandomInt(30)+1)*.1
        eff.SpriteScale = Vector(num,num)

        local c = getWaterColor()
        eff.Color = Color(c.R,c.G,c.B,0.25,c.RO,c.GO,c.BO)
    end


    if s:WasEventTriggered("Start") and not s:WasEventTriggered("End") then
        for i, entity in ipairs(Isaac.FindInRadius(effect.Position, 32, 0xFFFFFFFF)) do
            if (entity:ToBomb() or entity:ToPlayer() or entity:ToProjectile() or entity:ToTear() or entity:ToNPC() or 
            (entity:ToPickup() and (entity.Variant~=100 and not entity:ToPickup():IsShopItem()))) and (not entity:IsDead() and entity:Exists()) then
                if (entity:ToNPC() and entity.Type~=EntityType.ENTITY_SHOPKEEPER) then

                    if entity.Type==EntityType.ENTITY_FIREPLACE then
                        entity:TakeDamage(999, 0, EntityRef(effect), 0)

                    elseif entity:IsVulnerableEnemy() then

                        -- tiny passive damage
                        if effect:IsFrame(5,0) then
                            entity:TakeDamage(1, 0, EntityRef(effect), 0)

                            if entity.Mass >= 100 then
                                entity:TakeDamage(5, 0, EntityRef(effect), 0)
                            end
                        end

                        
                        -- morph enemies
                        for i, tab in ipairs(enemyConverts) do
                            if i%2==1 and (tab[1]==entity.Type and (tab[2]==entity.Variant or tab[2]==-1) and (tab[3]==entity.SubType or tab[3]==-1)) then

                                local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, effect)
                                entity:ToNPC():Morph(enemyConverts[i+1][1], enemyConverts[i+1][2], enemyConverts[i+1][3], entity:ToNPC():GetChampionColorIdx())
                                entity:ToNPC().State = NpcState.STATE_INIT
                                sfx:Play(SoundEffect.SOUND_STEAM_HALFSEC, .5, 0, false, 1, 0)

                                break
                            end
                        end

                        if entity:CollidesWithGrid() then
                            if entity:IsBoss() then
                                local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_SPLASH, 0, entity.Position, Vector.Zero, nil)
                                eff:SetColor(getWaterColor(), -1, 99, false, true)
                                entity:TakeDamage(5, 0, EntityRef(effect), 0)
                            else
                                local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_SPLASH, 0, entity.Position, Vector.Zero, nil)
                                eff:SetColor(getWaterColor(), -1, 99, false, true)

                                entity:TakeDamage(50, 0, EntityRef(effect), 0)
                            end
                        end
                    end
                end

                if entity:ToPlayer() or entity:ToProjectile() or entity:ToTear() then 
                    entity.Velocity = Lerp(entity.Velocity, Vector.FromAngle(90):Resized(entity.Velocity:Length()+1), 0.05)
                else
                    if entity.Mass < 100 then 
                        entity.Velocity = Lerp(entity.Velocity, Vector.FromAngle(90):Resized(entity.Velocity:Length()+25), 0.1)
                    end
                end


                if entity:IsFrame(4,0) then
                    local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WATER_SPLASH, 1, entity.Position+Vector(rng:RandomInt(math.ceil(entity.Size*2))-math.ceil(entity.Size), rng:RandomInt(math.ceil(entity.Size*2))-math.ceil(entity.Size)), Vector.FromAngle(90+(rng:RandomInt(40)-20)):Resized(rng:RandomInt(10)+1), effect)
                    eff:SetColor(getWaterColor(), -1, 99, false, true)
                    eff.SpriteScale = Vector(1.25,1.25)
                    eff:Update()
                end
            end
        end

        if effect:IsFrame(4,0) then
            local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WATER_SPLASH, 1, effect.Position+Vector(rng:RandomInt(40)-20, rng:RandomInt(40)-20), Vector.FromAngle(90):Resized(rng:RandomInt(10)), effect)
            eff:SetColor(getWaterColor(), -1, 99, false, true)
            eff:Update()
        end
    end

    -- Destroy Grids
    if s:IsEventTriggered("Start") then
        local room = Game():GetRoom()
        local ProcRadius = 32

        for g = 0, room:GetGridSize() do
            local entity = room:GetGridEntity(g)

            if entity and effect.Position.X < entity.Position.X + ProcRadius and effect.Position.X > entity.Position.X - ProcRadius and effect.Position.Y < entity.Position.Y + ProcRadius and effect.Position.Y > entity.Position.Y - ProcRadius then 
                if entity:ToPoop() and entity.State ~= 1000 then
                    entity:Hurt(999)
                elseif entity:ToTNT() and entity.State ~= 4 then
                    entity:Hurt(999)
                end
            end
        end
    end

    --if d.water and room:GetWaterAmount() < 1 then
        --room:SetWaterAmount(Lerp(room:GetWaterAmount(), 1, .01))
    --end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.waterUpdate, waterEffect)





function mod:playerUpdate(player)
    local data, exists = EntitySaveStateManager.GetEntityData(mod, player)
   
    if data.manaGain then 
        if player:IsFrame(25,0) then
            data.manaGain = data.manaGain - 0.25
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
        end

        if data.manaGain <= .3 then
            data.manaGain = nil
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
        end
    end

    if data.baseballClub and not data.baseballClub_Change then
        local club =  data.baseballClub:GetMainEntity()

        if club then
            club:GetSprite():ReplaceSpritesheet(0, "gfx/effects/boneClub_BaseballBat.png")
            club:GetSprite():ReplaceSpritesheet(1, "gfx/effects/boneClub_BaseballBat.png")
            club:GetSprite():LoadGraphics()

            data.baseballClub_Change = true
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.playerUpdate)

function mod:cacheEval(player, cacheFlags)
    local data, exists = EntitySaveStateManager.GetEntityData(mod, player)

    if data.manaGain then
        if cacheFlags & CacheFlag.CACHE_FIREDELAY==CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = player.MaxFireDelay - ((-100*(1/(data.manaGain+10))+10))
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.cacheEval)

function mod:newRoom()
    local level = Game():GetLevel()
    local room = Game():GetRoom()
    local numPlayers = Game():GetNumPlayers()

    for i = 0, numPlayers - 1 do
        local player = Isaac.GetPlayer(i)
        local data, exists = EntitySaveStateManager.GetEntityData(mod, player)

        if data.teleEnemies then
            if data.teleEnemies[level:GetCurrentRoomIndex()] then
                for i, tab in ipairs(data.teleEnemies[level:GetCurrentRoomIndex()]) do
                    if (tab[1] == EntityType.ENTITY_BOMB or tab[1] == EntityType.ENTITY_PICKUP or tab[1] == EntityType.ENTITY_SLOT) then
                        local pos = room:FindFreePickupSpawnPosition(room:GetRandomPosition(0), 0, true, false)
                        local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pos, Vector.Zero, nil)
                        eff:SetColor(warpColor, 99, 99, false, true)

                        local entity = Isaac.Spawn(tab[1], tab[2], tab[3], pos, Vector.Zero, nil)
                        entity:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                        entity:SetColor(warpenemyColor, 20, 99, true, true)
                    else 
                        local pos = getFreeDoorPosition(player:GetDropRNG())
                        local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pos, Vector.Zero, nil)
                        eff:SetColor(warpColor, 99, 99, false, true)

                        local entity = Isaac.Spawn(tab[1], tab[2], tab[3], pos, Vector.Zero, nil)
                        entity:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                        entity:ToNPC().State = NpcState.STATE_INIT
                        entity:SetColor(warpenemyColor, 20, 99, true, true)
                        if tab[4] ~= -1 then   
                            entity:ToNPC():MakeChampion(player:GetDropRNG():GetSeed(), tab[4], true)
                            player:GetDropRNG():Next()
                        end
                    end
                end
             
                data.teleEnemies[level:GetCurrentRoomIndex()] = nil
                sfx:Play(SoundEffect.SOUND_PORTAL_OPEN, .8, 0, false, 1, 0)
            end
        end
        
        if data.baseballClub then
            if player:GetWeapon(1):GetWeaponType() == WeaponType.WEAPON_BONE then
                Isaac.DestroyWeapon(data.baseballClub)
                player:EnableWeaponType(data.oldWeapon:GetWeaponType(), true)
                player:SetWeapon(data.oldWeapon, 1)
                
                data.baseballClub = nil
                data.baseballClub_Change = nil
                data.oldWeapon = nil
            else -- bone club was replaced by another weapon
                Isaac.DestroyWeapon(data.baseballClub)
                Isaac.DestroyWeapon(data.oldWeapon)

                data.baseballClub = nil
                data.baseballClub_Change = nil
                data.oldWeapon = nil
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.newRoom)

function mod:newLevel(level, type)
    local numPlayers = Game():GetNumPlayers()

    for i = 0, numPlayers - 1 do
        local player = Isaac.GetPlayer(i)
        local data, exists = EntitySaveStateManager.GetEntityData(mod, player)

        if data.teleEnemies then data.teleEnemies = nil end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_LEVEL_SELECT, mod.newLevel)

--  -----------------
--  |   6        6  |
--  |               |
--  |       )--- )  |
--  -----------------

-- EID DOODLE TOUCHED ME

if EID then
    local mySprite = Sprite()
    mySprite:Load("gfx/eid/eid_cardfronts_brendendoodle.anm2", true)
    EID:addIcon("Card".. potOfGreed, "Pot of Greed", -1, 9, 9, -1, 0, mySprite)

    local mySprite = Sprite()
    mySprite:Load("gfx/eid/eid_cardfronts_brendendoodle.anm2", true)
    EID:addIcon("Card".. misprint, "Misprint Card", -1, 9, 9, -1, 0, mySprite)

    local mySprite = Sprite()
    mySprite:Load("gfx/eid/eid_cardfronts_brendendoodle.anm2", true)
    EID:addIcon("Card".. BaseballCard, "Baseball Card", -1, 9, 9, -1, 0, mySprite)

    local mySprite = Sprite()
    mySprite:Load("gfx/eid/eid_cardfronts_brendendoodle.anm2", true)
    EID:addIcon("Card".. getWellSoon, "Get Well Soon", -1, 9, 9, -1, 0, mySprite)

    local mySprite = Sprite()
    mySprite:Load("gfx/eid/eid_cardfronts_brendendoodle.anm2", true)
    EID:addIcon("Card".. chaosWarp, "Chaos Warp", -1, 9, 9, -1, 0, mySprite)

    local mySprite = Sprite()
    mySprite:Load("gfx/eid/eid_cardfronts_brendendoodle.anm2", true)
    EID:addIcon("Card".. scanNPlay, "Scan-n-Play", -1, 9, 9, -1, 0, mySprite)

    local mySprite = Sprite()
    mySprite:Load("gfx/eid/eid_cardfronts_brendendoodle.anm2", true)
    EID:addIcon("Card".. manaDrain, "Mana Drain", -1, 9, 9, -1, 0, mySprite)

    local mySprite = Sprite()
    mySprite:Load("gfx/eid/eid_cardfronts_brendendoodle.anm2", true)
    EID:addIcon("Card".. ragingRiver, "Raging River", -1, 9, 9, -1, 0, mySprite)

    EID:addCard(potOfGreed, "Spawns two random trinkets")
    EID:addCard(misprint, "Activates the effects of 2 random tarot cards#{{Card"..Card.CARD_SUICIDE_KING.."}} The Suicide King and {{Card"..Card.CARD_REVERSE_LOVERS.."}} The Lovers..? are excluded")
    EID:addCard(BaseballCard, "Grants a temporary baseball club for the room")
    EID:addCard(getWellSoon, "Fills all red health")

    EID:addCard(chaosWarp, "Teleports all enemies and pickups in the current room to random rooms throughout the current floor")
    EID:addCard(scanNPlay,"Grants a temporary {{Collectible"..CollectibleType.COLLECTIBLE_BUDDY_IN_A_BOX.."}} buddy in a box familiar for the room")
    EID:addCard(manaDrain, "Absorb all enemy projectiles in the room and grant a fading tears up depending on the amount absorbed")
    EID:addCard(ragingRiver,"Summons a wave of water on the opposite half of the room isaac is on")
end