local mod = HODGEPODGE

local CLAM_CARD_VELOCITY = 10

local roomTransitionInfo

local DIRECTION_TO_ANIM_MAP = {
    [Direction.LEFT] = "WalkLeft",
    [Direction.UP] = "WalkUp",
    [Direction.RIGHT] = "WalkRight",
    [Direction.DOWN] = "WalkDown",
}

---@param player EntityPlayer
---@param source GridEntity
local function EndCardEffect(player, source)
    roomTransitionInfo = nil
    player:AddVelocity((player.Position - source.Position):Resized(15))
    local data = player:GetData()
    data.ClamCardInfo = nil

    player:SetMinDamageCooldown(30)
    mod.Game:SpawnParticles(player.Position, EffectVariant.ROCK_PARTICLE, 30, 5)
    mod.Game:ShakeScreen(15)
    mod.Sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
    player.CanFly = true
    player:AddCacheFlags(CacheFlag.CACHE_FLYING, true)
end

---Stolen from Car except I dumbed it down a bit.
---Hopefully it all still works.
---@param gridIndex integer
---@param direction Direction
---@return GridEntityDoor?
local function LocateClosestDoorToWall(gridIndex, direction)
    local room = mod.Game:GetRoom()
    local roomwidth = room:GetGridWidth()
    local foundDoor = nil
    local lastDoorDistance = 999
    for _, step in ipairs({ 1, -1, -roomwidth, roomwidth}) do
        for offset = 0, step*8, step do
            local gridEnt = room:GetGridEntity(gridIndex+offset)
            if gridEnt and gridEnt:ToDoor() and gridEnt:ToDoor().Direction == direction then
                local distance = offset/step
                if distance < lastDoorDistance then
                    lastDoorDistance = distance
                    foundDoor = gridEnt:ToDoor()
                end
            end
        end
    end
    return foundDoor
end

---@param player EntityPlayer
---@param gridIndex integer
---@param gridEntity GridEntity
local function GridCollision(_, player, gridIndex, gridEntity)
    if not gridEntity then
        return
    end
    local data = player:GetData()
    if not data.ClamCardInfo then
        return
    end

    local room = mod.Game:GetRoom()
    local type = gridEntity:GetType()
    if type == GridEntityType.GRID_WALL then
        if room:GetFrameCount() < 10 then
            return
        end
        local door = LocateClosestDoorToWall(gridIndex, data.ClamCardInfo.Direction)
        if not door then
            EndCardEffect(player, gridEntity)
            return
        end
        roomTransitionInfo = {
            PosOffset = player.Position - door.Position,
            Direction = door.Direction,
        }
        Isaac.Explode(player.Position, player, 100)
        door:SetLocked(false)
        door:Open()
        player.Position = door.Position

        Isaac.CreateTimer(function ()
            mod.Game:StartRoomTransition(door.TargetRoomIndex, Direction.NO_DIRECTION, RoomTransitionAnim.WALK, player)
        end, 10, 1, false)
    elseif type == GridEntityType.GRID_DOOR then
        local door = gridEntity:ToDoor()
        door:SetLocked(false)
        door:Open()
    elseif type == GridEntityType.GRID_PILLAR then
        EndCardEffect(player, gridEntity)
    elseif type == GridEntityType.GRID_ROCKB then
        Isaac.Explode(player.Position, player, 0)
        room:RemoveGridEntityImmediate(gridIndex, 0, false)
    elseif type == GridEntityType.GRID_TNT
    or type == GridEntityType.GRID_ROCK_BOMB then
        Isaac.Explode(gridEntity.Position, player, 100)
    else
        gridEntity:Destroy(true)
    end
end
mod:AddCallback(ModCallbacks.MC_PLAYER_GRID_COLLISION, GridCollision)

---@param player EntityPlayer
---@param gridIndex integer
---@param gridEntity GridEntity
local function PreGridCollision(_, player, gridIndex, gridEntity)
    if not gridEntity then
        return
    end
    local data = player:GetData()
    if not data.ClamCardInfo then
        return
    end
    if gridEntity:GetType() == GridEntityType.GRID_PIT then
        return true
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_GRID_COLLISION, PreGridCollision)

local function PrePlayerRender()
    if roomTransitionInfo then
        return false
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_RENDER, PrePlayerRender)

local function PostNewRoom()
    if not roomTransitionInfo then
        return
    end

    local firstPlayer = Isaac.GetPlayer()

    local room = mod.Game:GetRoom()

    for _, player in ipairs(PlayerManager.GetPlayers()) do
        player.Position = room:GetClampedPosition(player.Position + roomTransitionInfo.PosOffset, 1)
    end

    local hole = Isaac.Spawn(
        EntityType.ENTITY_EFFECT,
        mod.EffectVariant.HOLE_IN_WALL,
        0,
        firstPlayer.Position,
        Vector.Zero,
        nil
    )

    local wall
    if roomTransitionInfo.Direction == Direction.LEFT then
        wall = room:GetGridEntityFromPos(hole.Position + Vector(40,0))
        hole.SpriteRotation = 90
        if wall then
            hole.Position = Vector(wall.Position.X, hole.Position.Y)
        end
    elseif roomTransitionInfo.Direction == Direction.UP then
        wall = room:GetGridEntityFromPos(hole.Position + Vector(0,40))
        if wall then
            hole.Position = Vector(hole.Position.X, wall.Position.Y)
        end
    elseif roomTransitionInfo.Direction == Direction.RIGHT then
        hole.SpriteRotation = 270
        wall = room:GetGridEntityFromPos(hole.Position + Vector(-40,0))
        if wall then
            hole.Position = Vector(wall.Position.X, hole.Position.Y)
        end
    elseif roomTransitionInfo.Direction == Direction.DOWN then
        hole.SpriteRotation = 180
        wall = room:GetGridEntityFromPos(hole.Position + Vector(0,-40))
        if wall then
            hole.Position = Vector(hole.Position.X, wall.Position.Y)
        end
    end

    hole:Update()
    hole:AddEntityFlags(EntityFlag.FLAG_RENDER_WALL)

    mod.Game:SpawnParticles(firstPlayer.Position, EffectVariant.ROCK_PARTICLE, 30, 5)
    mod.Game:ShakeScreen(15)

    roomTransitionInfo = nil
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom)


local function PlayerTakeDamage(_, target)
    local data = target:GetData()
    if data.ClamCardInfo then
        return false
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, PlayerTakeDamage, EntityType.ENTITY_PLAYER)

---@param npc EntityNPC
---@param collider Entity
local function PreNpcCollision(_, npc, collider)
    if npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
        return
    end
    local data = collider:GetData()
    if not data.ClamCardInfo then
        return
    end

    if not npc:IsBoss() then
        npc:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
        npc:Kill()
        mod.Game:ShakeScreen(15)
        return true
    end
    return false
end
mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, PreNpcCollision)

---@param player EntityPlayer
local function PostPlayerUpdate(_, player)
    local data = player:GetData()
    if not data.ClamCardInfo then
        return
    end

    if player:IsExtraAnimationFinished() then
        local sprite = player:GetSprite()
        sprite:SetFrame(DIRECTION_TO_ANIM_MAP[data.ClamCardInfo.Direction], player.FrameCount%20)
    end

    local currentVel = player.Velocity
    if data.ClamCardInfo.Axis == "ver" then
        player.Velocity = Vector(currentVel.X, CLAM_CARD_VELOCITY * data.ClamCardInfo.Sign)
    else
        player.Velocity = Vector(CLAM_CARD_VELOCITY * data.ClamCardInfo.Sign, currentVel.Y)
    end
    if player.Visible then
        player:CreateAfterimage(3, player.Position)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PostPlayerUpdate)

---@param player EntityPlayer
local function UseCard(_, _, player)
    mod.Sfx:Play(mod.SoundEffect.CLAM_CARD_USE)
    local direction = player:GetMovementDirection()
    if direction == Direction.NO_DIRECTION then
        direction = Direction.DOWN
    end
    local sign = 1
    if direction == Direction.LEFT or direction == Direction.UP then
        sign = -1
    end

    local axis = "ver"
    if direction == Direction.LEFT or direction == Direction.RIGHT then
        axis = "hor"
    end

    local data = player:GetData()
    data.ClamCardInfo = {
        Sign = sign,
        Axis = axis,
        Direction = direction,
    }
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, UseCard, mod.Card.CLAM_CARD)