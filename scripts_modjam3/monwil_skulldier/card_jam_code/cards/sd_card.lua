local mod = HODGEPODGE

local cardConfig = mod.ItemConfig:GetCard(mod.Card.SD_CARD)

local consumableCopyFunctions = include("scripts_modjam3.monwil_skulldier.card_jam_code.cards.sd_card_effects.consumable_copies")
local financesFunction = include("scripts_modjam3.monwil_skulldier.card_jam_code.cards.sd_card_effects.finances")

local foodItems = {
    CollectibleType.COLLECTIBLE_SAD_ONION,
    CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM,
    CollectibleType.COLLECTIBLE_CHOCOLATE_MILK,
    CollectibleType.COLLECTIBLE_MINI_MUSH,
    CollectibleType.COLLECTIBLE_ODD_MUSHROOM_THIN,
    CollectibleType.COLLECTIBLE_ODD_MUSHROOM_LARGE,
    CollectibleType.COLLECTIBLE_BLACK_BEAN,
    CollectibleType.COLLECTIBLE_MEAT,
    CollectibleType.COLLECTIBLE_JESUS_JUICE,
    CollectibleType.COLLECTIBLE_THUNDER_THIGHS,
    CollectibleType.COLLECTIBLE_SOY_MILK,
    CollectibleType.COLLECTIBLE_GODS_FLESH,
    CollectibleType.COLLECTIBLE_FRUIT_CAKE,
    CollectibleType.COLLECTIBLE_APPLE,
    CollectibleType.COLLECTIBLE_LINGER_BEAN,
    CollectibleType.COLLECTIBLE_GHOST_PEPPER,
    CollectibleType.COLLECTIBLE_ALMOND_MILK,
    CollectibleType.COLLECTIBLE_PLAYDOUGH_COOKIE,
    CollectibleType.COLLECTIBLE_BIRDS_EYE,
    CollectibleType.COLLECTIBLE_ROTTEN_TOMATO,
    CollectibleType.COLLECTIBLE_SAUSAGE,
    CollectibleType.COLLECTIBLE_JELLY_BELLY,
}

local zipBombUnpacked = false
local myHousWadActive = false

local effects = {
    ---@param player EntityPlayer
    {"funky.ogg", function (player)
        MusicManager():Play(mod.Music.BANGER, 1)
        mod.Game:AddPixelation(150)
        local playerRef = EntityRef(player)
        for _, ent in ipairs(Isaac.GetRoomEntities()) do
            if ent:IsVulnerableEnemy() then
                ent:AddConfusion(playerRef, 150, true)
            end
        end
    end},
    ---@param player EntityPlayer
    {"brownies_recipe.txt", function (player)
        local rng = player:GetCardRNG(mod.Card.SD_CARD)
        local item = foodItems[rng:RandomInt(1, #foodItems)]
        player:AddInnateCollectible(item, 1, "HDPG Temp Items")
        Isaac.CreateTimer(function ()
            player:AnimateCollectible(item)
        end, 20, 1, false)
    end},
    ---@param player EntityPlayer
    {"us.png", function (player)
        player:AddInnateCollectible(CollectibleType.COLLECTIBLE_POLAROID, 1, "HDPG Temp Items")
        player:AddInnateCollectible(CollectibleType.COLLECTIBLE_NEGATIVE, 1, "HDPG Temp Items")
        player:AddInnateCollectible(CollectibleType.COLLECTIBLE_DIVORCE_PAPERS, 1, "HDPG Temp Items")
    end},
    ---@param player EntityPlayer
    {"bomb.zip", function (player)
        zipBombUnpacked = true
    end},
    ---@param player EntityPlayer
    {"isaac.exe", function (player)
        MusicManager():Play(mod.Music.ISAAC_EXE, 1)
        mod.Sfx:Play(SoundEffect.SOUND_DOGMA_APPEAR_SCREAM, 1.5, 2, false, 0.7)
        player:AddNullCostume(mod.NullCostume.ISAAC_EXE)
        mod.Game:SetColorModifier(ColorModifier(1,0.0,0.0, 1, 0,1), false)
        local playerRef = EntityRef(player)
        for _, ent in ipairs(Isaac.GetRoomEntities()) do
            if ent:IsVulnerableEnemy() then
                ent:AddBleeding(playerRef, 150)
                ent:AddFear(playerRef, 150)
            end
        end
    end},
    ---@param player EntityPlayer
    {"finances.xls", function (player)
        financesFunction(player)
    end},
    {"solitaire.exe", consumableCopyFunctions[1]},
    {"rocks.jpg", consumableCopyFunctions[2]},
    ---@param player EntityPlayer
    {"myhouse.wad", function (player)
        Isaac.CreateTimer(function ()
            myHousWadActive = true
        end, 1, 1, true)
        Isaac.ExecuteCommand("goto s.isaacs.0")
    end},
    ---@param player EntityPlayer
    {"guppy.mp4", function (player)
        player:AddInnateTrinket(TrinketType.TRINKET_KIDS_DRAWING, 3, "HDPG Temp Items")
    end},

    [0] = {"hello-connor.txt", function ()
        local font = Font()
        font:Load("font/pftempestasevencondensed.fnt")
        local currentFrame = mod.Game:GetFrameCount()
        local renderFunc = function ()
            local newKColor = KColor(1,1,1, 1 - (mod.Game:GetFrameCount()-currentFrame)/100)
            font:DrawString("Meet me in the files", Isaac.GetScreenWidth()/2-50, Isaac.GetScreenHeight()/2-80, newKColor, 100, true)
        end
        mod:AddCallback(ModCallbacks.MC_POST_RENDER, renderFunc)
        Isaac.CreateTimer(function ()
            mod:RemoveCallback(ModCallbacks.MC_POST_RENDER, renderFunc)
        end, 150, 1, true)
    end},
}

local function PostNewRoom()
    zipBombUnpacked = false
    myHousWadActive = false
    for _, player in ipairs(PlayerManager.GetPlayers()) do
        player:ClearInnateItemGroup("HDPG Temp Items")
        player:TryRemoveNullCostume(mod.NullCostume.ISAAC_EXE)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom)

---@param effect integer?
local function UpdateCardName(effect)
    if not effect then --This should never happen
        cardConfig.Description = "corrupted.wat"
        return
    end

    local effectData = effects[effect]

    cardConfig.Description = effectData[1]
    cardConfig.MimicCharge = effectData[3] or 3
end

local function RollNewSDCardEffect()
    local data = mod.SaveManager.GetRunSave()
    if not data.SDCardSeed then
        data.SDCardSeed = mod.Game:GetSeeds():GetStartSeed()
    end
    local rng = RNG(data.SDCardSeed)
    local newItem = rng:RandomInt(1, #effects)

    if rng:RandomInt(95) == 0 then
        newItem = 0
    end

    data.SDCardEffect = newItem
    data.SDCardSeed = rng:GetSeed()

    UpdateCardName(newItem)
end

---@param isContinued boolean
local function PostGameStarted(_, isContinued)
    if not isContinued then
        RollNewSDCardEffect()
    else
        UpdateCardName(mod.SaveManager.GetRunSave().SDCardEffect)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, PostGameStarted)

---@param flags integer
---@param player EntityPlayer
local function UseCard(_, _, player, flags)
    local data = mod.SaveManager.GetRunSave()
    if data.SDCardEffect then
        effects[data.SDCardEffect][2](player)
    end

    RollNewSDCardEffect()
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, UseCard, mod.Card.SD_CARD)



local function PostUpdate()
    if not zipBombUnpacked then
        return
    end
    local startTime = Isaac.GetNanoTime()
    repeat until Isaac.GetNanoTime() - startTime > 10^8
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate)

---@param npc EntityNPC
local function PostNPCKill(_, npc)
    if not zipBombUnpacked then
        return
    end
    local rng = npc:GetDropRNG()
    if rng:RandomFloat() < 0.25 then
        Isaac.Explode(npc.Position, npc, 100)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, PostNPCKill)

---@param trapdoor GridEntity
local function TrapDoorSpawn(_, trapdoor)
    if myHousWadActive then
        return false
    end
end
---@diagnostic disable-next-line: undefined-field
mod:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_SPAWN, TrapDoorSpawn, GridEntityType.GRID_STAIRS)
