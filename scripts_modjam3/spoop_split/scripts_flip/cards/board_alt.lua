local DOODLE_SIZE = 16
local NUM_DOODLES = 7

local DOODLE_SCALE = 17

local CREEP_TIMEOUT = 40*30
local CREEP_SCALE = 0.75
local CREEP_FEAR_DURATION = 30*4

local directions = {
    {1,0},{0,1},{-1,0},{0,-1},{1,1},{-1,1},{-1,-1},{1,-1}
}

---@param row integer
---@param col integer
---@param map integer[][]
---@param visit boolean[][]
---@param returnQueue {Current:Vector, Prev:Vector?}[]
---@param originRow integer?
---@param originCol integer?
local function fill(row, col, map, visit, returnQueue, originRow, originCol)
    visit[row][col] = true
    table.insert(returnQueue, {Current=Vector(col,row), Prev=(originRow and originCol and Vector(originCol,originRow))})

    for _, dirPair in ipairs(directions) do
        local nRow, nCol = row+dirPair[2], col+dirPair[1]
        if(nRow>0 and nRow<=DOODLE_SIZE and nCol>0 and nCol<=DOODLE_SIZE) then
            if((not visit[nRow][nCol]) and map[nRow][nCol]==1) then
                visit[nRow][nCol] = true
                fill(nRow,nCol, map, visit, returnQueue, row, col)
            end
        end
    end
end

local function getRandomDoodleData(rng)
    local doodleId = rng:RandomInt(NUM_DOODLES)

    local img = Renderer.LoadImage("gfx/card_boardalt_doodles.png")
    local str = img:GetTexelRegion(doodleId*DOODLE_SIZE, 0, DOODLE_SIZE, DOODLE_SIZE)

    local mat = {}
    local visited = {}
    for i=0,DOODLE_SIZE-1 do
        mat[i+1] = {}
        visited[i+1] = {}
        for j=0,DOODLE_SIZE-1 do
            local pixelData = {string.byte(str, 4*(16*i+j)+1, 4*(16*i+j)+4)}
            table.insert(mat[i+1], (pixelData[1]==0 and 1 or 0))
            table.insert(visited[i+1], false)
        end
    end

    for _, row in ipairs(mat) do
        local st = ""
        for _, val in ipairs(row) do
            st = st..(val==1 and "X" or ".")
        end
    end

    local doodleQueue = {}
    for i=1,DOODLE_SIZE do
        for j=1,DOODLE_SIZE do
            if(mat[i][j]==1 and not visited[i][j]) then
                fill(i, j, mat, visited, doodleQueue)
            end
        end
    end

    return doodleQueue
end

---@param id Card
---@param player EntityPlayer
---@param flags UseFlag
local function useCard(_, id, player, flags)
    local rng = player:GetCardRNG(id)

    local data = getRandomDoodleData(rng)

    local centerPos = CardjamFlipCards.GAME:GetRoom():GetClampedPosition(player.Position, DOODLE_SIZE*DOODLE_SCALE/2)

    CardjamFlipCards.SFX:Play(CardjamFlipCards.SFX_CHALK, 1, 2, false, 0.95+math.random()*0.1)

    local spawnInterval = 1
    local eff = Isaac.CreateTimer(
        ---@param effect EntityEffect
        function(effect)
            local queueData = CardjamFlipCards:getData(effect).QUEUE_DATA
            local idx = effect.FrameCount//spawnInterval

            local basePos = CardjamFlipCards:getData(effect).CENTER_POS
            local pos = (queueData[idx].Current-Vector(8,8))*DOODLE_SCALE+basePos
            local prevPos = (queueData[idx].Prev and ((queueData[idx].Prev-Vector(8,8))*DOODLE_SCALE+basePos))

            local pl = CardjamFlipCards:getData(effect).PLAYER

            for i=1,(prevPos and 2 or 1) do
                local spawnPos = (prevPos and (prevPos+i*(pos-prevPos)/2) or pos)

                local eff = Isaac.Spawn(1000,EffectVariant.PLAYER_CREEP_RED,100,spawnPos,Vector.Zero,pl):ToEffect()
                if(eff) then
                    eff:GetSprite():ReplaceSpritesheet(0, "gfx/effects/effect_chalk.png", true)
                    eff:Update()

                    eff:SetTimeout(CREEP_TIMEOUT)
                    eff.Scale = eff.Scale*CREEP_SCALE
                    eff.SpriteScale = eff.SpriteScale*CREEP_SCALE

                    CardjamFlipCards:getData(eff).CHALK_CREEP = true
                end
            end

            if(idx==#data) then
                CardjamFlipCards.SFX:Stop(CardjamFlipCards.SFX_CHALK)
            end
        end,
        spawnInterval,
        #data,
        false
    )
    CardjamFlipCards:getData(eff).PLAYER = player
    CardjamFlipCards:getData(eff).QUEUE_DATA = data
    CardjamFlipCards:getData(eff).CENTER_POS = centerPos

    CardjamFlipCards:playAnnouncerVoice(CardjamFlipCards.SFX_VOICE_BOARD_2, flags)
end
CardjamFlipCards:AddCallback(ModCallbacks.MC_USE_CARD, useCard, CardjamFlipCards.CARD_BOARD_ALT)

---@param ent Entity
---@param source EntityRef
local function postChalkDamage(_, ent, _, _, source)
    if(source.Type==1000 and source.Variant==EffectVariant.PLAYER_CREEP_RED) then
        local sEnt = source.Entity
        if(sEnt and CardjamFlipCards:getData(sEnt).CHALK_CREEP) then
            ent:AddFear(EntityRef(sEnt.SpawnerEntity), CREEP_FEAR_DURATION, false)
        end
    end
end
CardjamFlipCards:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, postChalkDamage)