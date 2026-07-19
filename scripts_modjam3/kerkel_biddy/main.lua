---@class ModReference
local MOD = RegisterMod("Biddy Kerkel CardJam", 1)

MOD.SFX = SFXManager()
MOD.GAME = Game()
MOD.LEVEL = MOD.GAME:GetLevel()
MOD.CONFIG = Isaac.GetItemConfig()
MOD.MUSIC = MusicManager()
MOD.HUD = MOD.GAME:GetHUD()

include("scripts_modjam3.kerkel_biddy.scripts_kbeirdkdeyl.utiltiy.statuseffectlibrary")(MOD)
include("scripts_modjam3.kerkel_biddy.scripts_kbeirdkdeyl.utiltiy.hudhelper")(MOD)
include("scripts_modjam3.kerkel_biddy.scripts_kbeirdkdeyl.utiltiy.foundhudhelper")
include("scripts_modjam3.kerkel_biddy.scripts_kbeirdkdeyl.utiltiy.jumplib"):Init() -- I didnt want to have to

MOD.CURSE_CHARLIE = include("scripts_modjam3.kerkel_biddy.scripts_kbeirdkdeyl.curses.charlie")(MOD)
MOD.CURSE_RA = include("scripts_modjam3.kerkel_biddy.scripts_kbeirdkdeyl.curses.ra")(MOD)
MOD.CURSE_EARTHQUAKES = include("scripts_modjam3.kerkel_biddy.scripts_kbeirdkdeyl.curses.earthquakes")(MOD)
MOD.CURSE_DELUGE = include("scripts_modjam3.kerkel_biddy.scripts_kbeirdkdeyl.curses.deluge")(MOD)

MOD.COLLECTIBLE_NEGATE_RAINBOW_CONTAGION = include("scripts_modjam3.kerkel_biddy.scripts_kbeirdkdeyl.collectibles.negaterainbowcontagion")(MOD)
MOD.COLLECTIBLE_LOOT_BOX = include("scripts_modjam3.kerkel_biddy.scripts_kbeirdkdeyl.collectibles.lootbox")(MOD)

MOD.TRINKET_NEGATE_RAINBOW_CONWORM  = include("scripts_modjam3.kerkel_biddy.scripts_kbeirdkdeyl.trinkets.negaterainbowconworm")(MOD)

MOD.CARD_JUSTICE = include("scripts_modjam3.kerkel_biddy.scripts_kbeirdkdeyl.cards.justice")(MOD)
MOD.CARD_BLUE_ASBESTOS = include("scripts_modjam3.kerkel_biddy.scripts_kbeirdkdeyl.cards.blueasbestos")(MOD)
MOD.CARD_VIVIAN = include("scripts_modjam3.kerkel_biddy.scripts_kbeirdkdeyl.cards.vivian")(MOD)
MOD.CARD_WILD = include("scripts_modjam3.kerkel_biddy.scripts_kbeirdkdeyl.cards.wildcard")(MOD)
MOD.CARD_RCWWQMITMAABIPAWT = include("scripts_modjam3.kerkel_biddy.scripts_kbeirdkdeyl.cards.rcwwqmitmaabipawt")(MOD)
MOD.CARD_PHONK = include("scripts_modjam3.kerkel_biddy.scripts_kbeirdkdeyl.cards.phonkard")(MOD)
MOD.CARD_LKJ = include("scripts_modjam3.kerkel_biddy.scripts_kbeirdkdeyl.cards.lkj")(MOD)
MOD.CARD_SMASH = include("scripts_modjam3.kerkel_biddy.scripts_kbeirdkdeyl.cards.smash")(MOD)

function MOD:Init()
    MOD.TRINKET_NEGATE_RAINBOW_CONWORM:Init()
end
MOD:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, MOD.Init)
MOD:Init()

---@type table<Card, true>
MOD.CARDS_FOILED = {
    [MOD.CARD_JUSTICE.ID] = true,
    [MOD.CARD_BLUE_ASBESTOS.ID] = true,
    [MOD.CARD_VIVIAN.ID] = true,
    [MOD.CARD_WILD.ID] = true,
    [MOD.CARD_RCWWQMITMAABIPAWT.ID] = true,
    [MOD.CARD_PHONK.ID] = true,
    [MOD.CARD_LKJ.ID] = true,
    [MOD.CARD_SMASH.ID] = true,
}

---@type table<Card, SoundEffect>
MOD.CARD_TO_SFX = {
    [MOD.CARD_JUSTICE.ID] = Isaac.GetSoundIdByName("justicevox"),
    [MOD.CARD_BLUE_ASBESTOS.ID] = Isaac.GetSoundIdByName("bahvox"),
    [MOD.CARD_VIVIAN.ID] = Isaac.GetSoundIdByName("viviancardvox"),
    [MOD.CARD_WILD.ID] = Isaac.GetSoundIdByName("wildcardvox"),
    [MOD.CARD_RCWWQMITMAABIPAWT.ID] = Isaac.GetSoundIdByName("rcvox"),
    [MOD.CARD_PHONK.ID] = Isaac.GetSoundIdByName("phonkardvox"),
    [MOD.CARD_LKJ.ID] = Isaac.GetSoundIdByName("littlecardjohnvox"),
    [MOD.CARD_SMASH.ID] = Isaac.GetSoundIdByName("smashkardvox"),
}

---@param id Card
MOD:AddCallback(ModCallbacks.MC_USE_CARD, function (_, id, _, flags)
    if not MOD.CARD_TO_SFX[id]
    or flags & UseFlag.USE_NOANNOUNCER ~= 0
    or Options.AnnouncerVoiceMode == 1
    or (Options.AnnouncerVoiceMode == 0 and math.random() < 0.5) then return end
    MOD.SFX:Play(MOD.CARD_TO_SFX[id])
end)

if EID then
    local iaiafjjka = Sprite("gfx/ui_negaterainbowquality.anm2", true)
    iaiafjjka:Play(iaiafjjka:GetDefaultAnimation(), true)
    EID:addIcon("Quality67", "Quality67", 0, 10, 10, 0, 0, iaiafjjka)

    for k in pairs(MOD.CARDS_FOILED) do
        local card = MOD.CONFIG:GetCard(k)
        local old = card.ModdedCardFront
        local new = Sprite()
        new:Load(old:GetFilename(), true)
        new:Play(card.HudAnim, true)
        new:GetLayer(0):SetSize(Vector.One * 0.5)
        EID:addIcon("Card" .. k, card.HudAnim, -1, 9, 9, 4, 8, new)
    end

    -- EID:addCollectible(MOD.COLLECTIBLE_NEGATE_RAINBOW_CONTAGION.ID, "Okay... So hear this...#The first enemy in a room Rots nearby enemies. And you won't believe this. Enemies with this Rot, ALSO Rot nearby enemies when killed. So it's kind of like a chain.#If you don't know what Rot does, it makes enemies gradually asbestify, becoming slower and eventually recieving constant damage. The slowing effect is weaker on bosses though#Rot only lasts for so long outside of the Blue Asbestos Halls, soooooo you kind of need to kill the enemies fast in order to spread more Rot")
    EID:addCollectible(MOD.COLLECTIBLE_NEGATE_RAINBOW_CONTAGION.ID, "The fi{{ColorRainbow}}r{{CR}}st enemy killed in {{ColorRainbow}}a{{CR}} room Rots all nearby enem{{ColorRainbow}}i{{CR}}es#E{{ColorRainbow}}n{{CR}}emies Rotted {{ColorRainbow}}b{{CR}}y this item als{{ColorRainbow}}o{{CR}} Rot nearby enemies {{ColorRainbow}}w{{CR}}hen killed")
    EID:addCollectible(MOD.COLLECTIBLE_LOOT_BOX.ID, "Periodically spawns pickups in active rooms that grant temporary combat abilities#{{Warning}} These pickups disappear if not collected in time")

    EID:addTrinket(MOD.TRINKET_NEGATE_RAINBOW_CONWORM.ID, "{{ArrowUp}} +0.39 {{ColorRainbow}}Asbestos#Spectral + piercing tears# Isaac's tears move in a {{ColorTransform}}Blue Asbestos Halls{{CR}}-shaped pattern#{{Warning}} {{ColorRed}}Cursed")

    EID:addCard(MOD.CARD_JUSTICE.ID, "{{Collectible" .. CollectibleType.COLLECTIBLE_DAMOCLES .. "}} Hang a sword over every enemy with a permanent chance to fall and kill it once it's taken damage#Bosses are hurt for " .. math.ceil(MOD.CARD_JUSTICE.BOSS_HURT_PERCENT * 100) .. "% of their max HP instead")
    EID:addCard(MOD.CARD_BLUE_ASBESTOS.ID, "Transform the room into a Blue Asbestos Hall that permanently Rots enemies#Rotting enemies gradually slow before taking constant damage#May have transforming properties...")
    EID:addCard(MOD.CARD_VIVIAN.ID, "Gain a random unique familiar for the floor")
    EID:addCard(MOD.CARD_WILD.ID, "Enable 1 of 4 unique curses that can harm both players and enemies")
    EID:addCard(MOD.CARD_RCWWQMITMAABIPAWT.ID, "Answer a random multiple choice question with different outcomes for each option")
    EID:addCard(MOD.CARD_PHONK.ID, "#{{Timer}} For the next minute:#Normal doors are open#{{BleedingOut}} Bleed enemies around you#Your dance moves may get in the way of attacking")
    EID:addCard(MOD.CARD_LKJ.ID, "#Open all chests#Steal all non-shop pickups from the ground#Chance to steal a random pickup from each enemy")
    EID:addCard(MOD.CARD_SMASH.ID, "Activate a random temporary ability:#Lobbed explosive#Freezing snowballs#Rotating spike balls#Powerful triple shot#Invincibility ")
end

---@param pickup EntityPickup
MOD:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function (_, pickup)
    if not MOD.CARDS_FOILED[pickup.SubType] then return end
    local sprite = pickup:GetSprite()
    local players = PlayerManager.GetPlayers()
    local pos = Vector.Zero
    for _, player in ipairs(players) do
        pos = pos + player.Position
    end
    pos = pos / #players
    -- if pickup.FrameCount % 30 == 0 then
    --     sprite:Play("Appear")
    -- end
    local frame = sprite:GetCurrentAnimationData():GetLayer(0):GetFrame(sprite:GetFrame())
    pickup.Color = Color(
        1, 1, 1,
        1,
        0, 0, 0,
        (pickup.Position.X + pickup.Position.Y) * 0.5 + (pos.X + pos.Y) * 0.1
        + frame:GetPos().Y * 1.5
        + frame:GetScale().Y
    )
    sprite:SetCustomShader("shaders/bkfoil")
end, PickupVariant.PICKUP_TAROTCARD)

HudHelper.RegisterHUDElement({
    Name = "KBEIRDKDEYL_FOIL",
    Priority = HudHelper.Priority.HIGH,
    Condition = function (player)
        return MOD.CARDS_FOILED[player:GetCard(0)]
    end,
	OnRender = function(player, _, layout, position, alpha, scale)
        local config = Isaac.GetItemConfig():GetCard(player:GetCard(0))
        local modded = config.ModdedCardFront
        local sprite = Sprite(modded:GetFilename(), true)
        sprite:Play(config.HudAnim, true)
        sprite:SetCustomShader("shaders/bkfoil")
        -- sprite.Scale = Vector.One * scale
        sprite.Color = Color(
            1, 1, 1,
            alpha,
            0, 0, 0,
            (player.Position.X + player.Position.Y) * 0.1
        )
        sprite:Render(position)
	end,
}, HudHelper.HUDType.POCKET)

---@type table<GridEntityType, string>
MOD.GRID_TO_BACKDROP_DINGLE = {
    [GridEntityType.GRID_ROCK] = "rocks",
    [GridEntityType.GRID_ROCKB] = "rocks",
    [GridEntityType.GRID_ROCKT] = "rocks",
    -- [GridEntityType.GRID_ROCK_ALT] = "rocks",
    -- [GridEntityType.GRID_ROCK_ALT2] = "rocks",
    [GridEntityType.GRID_ROCK_BOMB] = "rocks",
    [GridEntityType.GRID_ROCK_GOLD] = "rocks",
    [GridEntityType.GRID_ROCK_SPIKED] = "rocks",
    [GridEntityType.GRID_ROCK_SS] = "rocks",
    [GridEntityType.GRID_PIT] = "pit",
    -- [GridEntityType.GRID_DECORATION],
    [GridEntityType.GRID_DOOR] = "door",
}

MOD.DEFAULT_GRID_SIZE = 135

---@param entity Entity
function MOD:GetData(entity)
    local data = entity:GetData()
    data.KBEIRDKDEYL = data.KBEIRDKDEYL or {}
    return data.KBEIRDKDEYL
end

function MOD:GetGlobalPlayer()
    local players = PlayerManager.GetPlayers()
    for i = 0, 3 do
        players[#players + 1] = PlayerManager.GetEsauJrState(i)
    end
    for _, player in ipairs(players) do
        players[#players + 1] = player:GetFlippedForm()
    end
    for _, player in ipairs(players) do
        if EntitySaveStateManager.GetEntityData(MOD, player).GlobalPlayer then
            return player
        end
    end
    EntitySaveStateManager.GetEntityData(MOD, players[1]).GlobalPlayer = true
    return players[1]
end

---@generic T
---@param a T
---@param b T
---@param t number
---@return T
function MOD:Lerp(a, b, t)
    return t == 1 and b or a + (b - a) * t
end

---@param a number
---@param b number
---@param t number
function MOD:LerpClamped(a, b, t)
    t = math.min(1, math.max(0, t))
    return t == 1 and b or a + (b - a) * t
end

---@param from number
---@param to number
function MOD:ShortAngleDis(from, to)
    local disAngle = (to - from) % 360
    return 2 * disAngle % 360 - disAngle
end

---@param from number
---@param to number
---@param fraction number
function MOD:LerpAngle(from, to, fraction)
    return from + MOD:ShortAngleDis(from, to) * fraction
end

---@param id BackdropType
function MOD:SetBackdrop(id)
    local room = MOD.GAME:GetRoom()
    local backdrop = room:GetBackdropType()
    if id == backdrop then return end
    local current = XMLData.GetEntryById(XMLNode.BACKDROP, backdrop)
    local next = XMLData.GetEntryById(XMLNode.BACKDROP, id)
    room:SetBackdropType(id, 1)
    for i = 0, room:GetGridSize() do
        local grid = room:GetGridEntity(i)
        if grid then
            local type = grid:GetType()
            local suffix = MOD.GRID_TO_BACKDROP_DINGLE[type]
            if suffix then
                local sprite = grid:GetSprite()
                local orig = current.gridgfxroot
                and current[suffix]
                and (current.gridgfxroot .. current[suffix])
                local targ = next.gridgfxroot
                and next[suffix]
                and (next.gridgfxroot .. next[suffix])
                local reload
                for _, layer in ipairs(sprite:GetAllLayers()) do
                    if orig and targ and layer:GetSpritesheetPath() == orig then
                        sprite:ReplaceSpritesheet(layer:GetLayerID(), targ)
                        reload = true
                    end
                end
                if reload then
                    sprite:LoadGraphics()
                end
            end
        end
    end
end

---@generic T
---@param tbl T[]
---@param filter? fun(value: T, key: any): boolean?
---@return T[]
function MOD:Filter(tbl, filter)
    local _tbl = {}

    for k, v in pairs(tbl) do
        if not filter or filter(v, k) then
            _tbl[#_tbl + 1] = v
        end
    end

    return _tbl
end

---@type Direction[]
MOD.ANGLE_TO_DIRECTION = {
    Direction.RIGHT,
    Direction.DOWN,
    Direction.LEFT,
    Direction.UP,
}
---@type table<Direction, Vector>
MOD.DIRECTION_TO_VECTOR = {
    [Direction.DOWN] = Vector(0, 1),
    [Direction.LEFT] = Vector(-1, 0),
    [Direction.UP] = Vector(0, -1),
    [Direction.RIGHT] = Vector(1, 0),
    [Direction.NO_DIRECTION] = Vector(0, 0),
}
---@type table<Direction, integer>
MOD.DIRECTION_TO_ANGLE = {
    [Direction.LEFT] = 180,
    [Direction.UP] = -90,
    [Direction.RIGHT] = 0,
    [Direction.DOWN] = 90,
    [Direction.NO_DIRECTION] = 0,
}

---@param vector Vector
function MOD:CardinalClamp(vector)
    return Vector.FromAngle(((vector:GetAngleDegrees() + 45) // 90) * 90)
end

---@param angle number
function MOD:AngleToDirection(angle)
    return MOD.ANGLE_TO_DIRECTION[math.floor((angle % 360 + 45) / 90) % 4 + 1]
end

---@param vector Vector
---@return Direction
function MOD:VectorToDirection(vector)
    if vector:Length() < 0.001 then
        return Direction.NO_DIRECTION
    end

    return MOD:AngleToDirection(vector:GetAngleDegrees())
end

---@param direction Direction
function MOD:DirectionToVector(direction)
    return MOD.DIRECTION_TO_VECTOR[direction]
end

---@param direction Direction
function MOD:DirectionToAngle(direction)
    return MOD.DIRECTION_TO_ANGLE[direction]
end

---@param idx integer
---@param max integer
---@param spread number
function MOD:SpreadShotAngle(idx, max, spread)
    return (idx - max / 2 - 0.5) * spread / (max - 1)
end

return MOD
--didnt have time to fix cutscenes messing with music volume after sorry