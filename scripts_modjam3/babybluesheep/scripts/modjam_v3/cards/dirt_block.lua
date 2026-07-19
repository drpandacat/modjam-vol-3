local game = Game()
local sfxManager = SFXManager()



ModJamV3.Cards.DirtBlock = {}
ModJamV3.Cards.DirtBlock.CARD_TYPE = Isaac.GetCardIdByName("Dirt Block")

---@param gridIndex integer
local function ActuallySpawnTintedRock(gridIndex)
    local room = game:GetRoom()

    local position = room:GetGridPosition(gridIndex)

    room:RemoveGridEntityImmediate(gridIndex, 0, false)
    
    local managedToSpawn = room:SpawnGridEntity(gridIndex, GridEntityType.GRID_ROCKT)
    if not managedToSpawn then return false end

    local rock = room:GetGridEntity(gridIndex)
---@diagnostic disable-next-line: need-check-nil
    rock = rock:ToRock()

    for i = 1, 4 do
        ---@type EntityEffect
        ---@diagnostic disable-next-line: assign-type-mismatch
        local rockParticle = Isaac.Spawn
        (
            EntityType.ENTITY_EFFECT, EffectVariant.ROCK_PARTICLE, room:GetBackdropType(),
            position, Vector.One:Rotated(math.random() * 360) * ModJamV3.RandomFloat(1, 2),
            nil
        ):ToEffect()
        rockParticle:Update()

        rockParticle.m_Height = rockParticle.m_Height + 5
    end

    local poof = Isaac.Spawn
    (
        EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0,
        position, Vector.Zero,
        nil
    )

    sfxManager:Play(SoundEffect.SOUND_ROCK_CRUMBLE)

    return true
end

---@param card Card
---@param player EntityPlayer
---@param useFlags UseFlag
ModJamV3:AddCallback(ModCallbacks.MC_USE_CARD, function (_, card, player, useFlags)
    local room = game:GetRoom()
    local gridWidth = room:GetGridWidth()

    local rng = player:GetCardRNG(card)

    local playerPosition = player.Position
    local playerGridIndex = room:GetGridIndex(playerPosition)

    local adjacentGridIndices = {}
    
    table.insert(adjacentGridIndices, playerGridIndex + 1)             -- Right
    table.insert(adjacentGridIndices, playerGridIndex - 1)             -- Left
    table.insert(adjacentGridIndices, playerGridIndex - gridWidth)     -- Up
    table.insert(adjacentGridIndices, playerGridIndex + gridWidth)     -- Down

    table.insert(adjacentGridIndices, playerGridIndex + 1 + gridWidth) -- RightDown
    table.insert(adjacentGridIndices, playerGridIndex - 1 + gridWidth) -- LeftDown
    table.insert(adjacentGridIndices, playerGridIndex + 1 - gridWidth) -- RightUp
    table.insert(adjacentGridIndices, playerGridIndex - 1 - gridWidth) -- LeftUp

    ModJamV3.ShuffleListInPlace(adjacentGridIndices, rng)

    local didPlaceGrid = false

    for _, gridIndex in ipairs(adjacentGridIndices) do
        local isGridWall = room:GetGridCollision(gridIndex) == GridCollisionClass.COLLISION_WALL or room:GetGridCollision(gridIndex) == GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER
        if isGridWall then goto continueNoDirectGrids end
        if not room:CanSpawnObstacleAtPosition(gridIndex, true) then goto continueNoDirectGrids end
        if not room:CanSpawnObstacleAtPosition(gridIndex, false) then goto continueNoDirectGrids end
        if room:GetGridPath(gridIndex) >= 1000 then goto continueNoDirectGrids end

        didPlaceGrid = ActuallySpawnTintedRock(gridIndex)
        if didPlaceGrid then break end

        ::continueNoDirectGrids::
    end
    if didPlaceGrid then return end

    --[[
    for _, gridIndex in ipairs(adjacentGridIndices) do
        local isGridWall = room:GetGridCollision(gridIndex) == GridCollisionClass.COLLISION_WALL or room:GetGridCollision(gridIndex) == GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER
        if isGridWall then goto continueAvailablePathUnforced end
        if not room:CanSpawnObstacleAtPosition(gridIndex, true) then goto continueAvailablePathUnforced end
        if not room:CanSpawnObstacleAtPosition(gridIndex, false) then goto continueAvailablePathUnforced end

        didPlaceGrid = ActuallySpawnTintedRock(gridIndex)
        if didPlaceGrid then break end

        ::continueAvailablePathUnforced::
    end
    if didPlaceGrid then return end

    for _, gridIndex in ipairs(adjacentGridIndices) do
        local isGridWall = room:GetGridCollision(gridIndex) == GridCollisionClass.COLLISION_WALL or room:GetGridCollision(gridIndex) == GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER
        if isGridWall then goto continueAvailablePathForced end
        if not room:CanSpawnObstacleAtPosition(gridIndex, true) then goto continueAvailablePathForced end

        didPlaceGrid = ActuallySpawnTintedRock(gridIndex)
        if didPlaceGrid then break end

        ::continueAvailablePathForced::
    end
    if didPlaceGrid then return end
    ]]

    sfxManager:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)
    if useFlags & UseFlag.USE_OWNED == UseFlag.USE_OWNED then
        player:AddCard(ModJamV3.Cards.DirtBlock.CARD_TYPE)
    end
end, ModJamV3.Cards.DirtBlock.CARD_TYPE)