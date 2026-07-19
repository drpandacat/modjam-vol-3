MODJAM_VOL_3 = RegisterMod("Modjam Vol. 3", 1)

if not REPENTANCE_PLUS or not REPENTOGON then
    local MOD = MODJAM_VOL_3
    local GAME = Game()
    local FONT = Font()
    FONT:Load("font/luaminioutlined.fnt")
    ---@param player EntityPlayer
    MOD:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function (_, player)
        if player:GetName() ~= "Noah" then return end
        player:AddSoulHearts(1)
        player.ControlsCooldown = 30
    end)
    ---@param player EntityPlayer
    MOD:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)
        if player:GetName() ~= "Noah"
        or player.FrameCount ~= 1 then return end
        player:AnimateSad()
    end)
    MOD:AddCallback(ModCallbacks.MC_POST_RENDER, function ()
        local player = Isaac.GetPlayer()
        local bottom = Isaac.GetScreenHeight()
        local center = Isaac.GetScreenWidth() / 2
        local frame = GAME:GetFrameCount()
        local white = math.abs(math.sin(frame * 0.05))
        local color = KColor(1, white, white, 1)
        FONT:DrawString("ModJam requires REPENTOGON for Repentance+", center, bottom - 30, color, 1, true)
        FONT:DrawString("Visit https://repentogon.com/install.html", center, bottom - 20, color, 1, true)
        local room = GAME:GetRoom()
        -- for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
        --     room:RemoveDoor(i)
        -- end
        -- player.ControlsEnabled = false
    end)
    ---@param shader string
    MOD:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, function (_, shader)
        if shader ~= "Phonk Zoom" then return end
        return {
            StrengthIn = 1,
            ScreenPointScaleIn = 1,
            PosIn = {0.5, 0.5}
        }
    end)
    return
end

MODJAM_VOL_3.SaveManager = include("scripts_modjam3.monwil_skulldier.card_jam_code.utils.save_manager")
MODJAM_VOL_3.SaveManager.Init(MODJAM_VOL_3)

MODJAM_VOL_3.KerkelBiddy = include("scripts_modjam3.kerkel_biddy.main")
MODJAM_VOL_3.AeronautTruji = include("scripts_modjam3.aeronaut_truji.main")
MODJAM_VOL_3.SpoopSplit = include("scripts_modjam3.spoop_split.main")
MODJAM_VOL_3.Stale = include("scripts_modjam3.stale.main")
MODJAM_VOL_3.Gloopy20 = include("scripts_modjam3.gloopy20.main")
MODJAM_VOL_3.MonwilSkulldier = include("scripts_modjam3.monwil_skulldier.main")
MODJAM_VOL_3.FoksWons = include("scripts_modjam3.foks_wons.main")
MODJAM_VOL_3.BabyblueSheep = include("scripts_modjam3.babybluesheep.main")
MODJAM_VOL_3.BrendenDoodle = include("scripts_modjam3.brenden_doodle.main")
MODJAM_VOL_3.Rat = include("scripts_modjam3.rat.main")
MODJAM_VOL_3.dpowerReixen = include("scripts_modjam3.dpower_reixen.main")
MODJAM_VOL_3.FourHeadAndre = include("scripts_modjam3.4head_andre.main")
MODJAM_VOL_3.JaneSorrow = include("scripts_modjam3.janesorrow.main")
MODJAM_VOL_3.JohnSorrow = include("scripts_modjam3.johnsorrow.main")

--#region kerkel

MODJAM_VOL_3.Meta = {}
local t = MODJAM_VOL_3.Meta

t.CARD_JUSTICE = Isaac.GetCardIdByName("VIII - Justice!")
t.CARD_LITTLE_CARD_JOHN = Isaac.GetCardIdByName("Little Card John")
t.CARD_PHONKARD = Isaac.GetCardIdByName("Phonkard")
t.CARD_QUESTION_FUN = Isaac.GetCardIdByName("Red Card with White Question Mark in the Middle and a Border is Present and White Too")
t.CARD_BLUE_ASBESTOS = Isaac.GetCardIdByName("Blue Asbestos Card")
t.CARD_VIVIAN = Isaac.GetCardIdByName("Vivian Card")
t.CARD_WILD = Isaac.GetCardIdByName("Hexed Wild Card")
t.CARD_SMASH_KARD = Isaac.GetCardIdByName("Smash Kard")
t.CARD_POLYMERIZATION = Isaac.GetCardIdByName("CardJamAT_Polymerization")
t.CARD_AMALGAM = Isaac.GetCardIdByName("CardJamAT_Amalgam")
t.CARD_IJIRAQ = Isaac.GetCardIdByName("CardJamAT_Ijiraq")
t.CARD_PUNCH = Isaac.GetCardIdByName("CardJamAT_PunchCard")
t.CARD_MAGNETIC = Isaac.GetCardIdByName("CardJamAT_MagneticCard")
t.CARD_REPORT = Isaac.GetCardIdByName("Report")
t.CARD_SCRATCH = Isaac.GetCardIdByName("Scratch")
t.CARD_CHARM = Isaac.GetCardIdByName("Charm")
t.CARD_BOARD = Isaac.GetCardIdByName("Board")
t.CARD_REPORT_ALT = Isaac.GetCardIdByName("Report (alt)")
t.CARD_SCRATCH_ALT = Isaac.GetCardIdByName("Scratch (alt)")
t.CARD_CHARM_ALT = Isaac.GetCardIdByName("Charm (alt)")
t.CARD_BOARD_ALT = Isaac.GetCardIdByName("Board (alt)")
t.CARD_ELECTROCHEMISTRY = Isaac.GetCardIdByName("Electrochemistry")
t.CARD_INLAND_EMPIRE = Isaac.GetCardIdByName("InlandEmpire")
t.CARD_YARA_YARA = Isaac.GetCardIdByName("YaraYara")
t.CARD_RED_SEAL = Isaac.GetCardIdByName("Red Seal")
t.CARD_NIHIL = Isaac.GetCardIdByName("Nihil")
t.CARD_ECHO = Isaac.GetCardIdByName("Echo")
t.CARD_161_OF_CLUBS = Isaac.GetCardIdByName("161 of Clubs")
t.CARD_CLAM = Isaac.GetCardIdByName("Clam Card")
t.CARD_MANIFESTATION = Isaac.GetCardIdByName("Manifestation")
t.CARD_MOON = Isaac.GetCardIdByName("Moon")
t.CARD_SD = Isaac.GetCardIdByName("SD Card")
t.CARD_TICK = Isaac.GetCardIdByName("Tick Card")
t.CARD_COMBUSTING_NECROMANCY = Isaac.GetCardIdByName("Combusting Necromancy")
t.CARD_CHIMERA_FORM = Isaac.GetCardIdByName("Chimera Form")
t.CARD_DRUG_GRIND = Isaac.GetCardIdByName("Drug Grind")
t.CARD_2_OF_GYATTS = Isaac.GetCardIdByName("2 of Gyatts")
t.CARD_DIRT_BLOCK = Isaac.GetCardIdByName("Dirt Block")
t.CARD_WYVERN = Isaac.GetCardIdByName("Wyvern")
t.CARD_WRAITH = Isaac.GetCardIdByName("Wraith")
t.CARD_OLD_MAN = Isaac.GetCardIdByName("The Old Man")
t.CARD_BLUE_SLIME = Isaac.GetCardIdByName("Blue Slime")
t.CARD_WEREWOLF = Isaac.GetCardIdByName("Werewolf")
t.CARD_MEGASHARK = Isaac.GetCardIdByName("Megashark")
t.CARD_POT_OF_GREED = Isaac.GetCardIdByName("Pot of Greed")
t.CARD_MISPRINT = Isaac.GetCardIdByName("Misprint Card")
t.CARD_BASEBALL = Isaac.GetCardIdByName("Baseball Card")
t.CARD_GET_WELL_SOON = Isaac.GetCardIdByName("Get Well Soon")
t.CARD_CHAOS_WARP = Isaac.GetCardIdByName("Chaos Warp")
t.CARD_SCAN_N_PLAY = Isaac.GetCardIdByName("Scan-n-Play")
t.CARD_MANA_DRAIN = Isaac.GetCardIdByName("Mana Drain")
t.CARD_RAGING_RIVER = Isaac.GetCardIdByName("Raging River")
t.CARD_COSTCO = Isaac.GetCardIdByName("Membership Card")
t.CARD_DETERMINATION = Isaac.GetCardIdByName("Determination Card")
t.CARD_PERSEVERANCE = Isaac.GetCardIdByName("Perseverance Card")
t.CARD_KINDNESS = Isaac.GetCardIdByName("Kindness Card")
t.CARD_JUSTICE_SOUL = Isaac.GetCardIdByName("Justice Card")
t.CARD_INTEGRITY = Isaac.GetCardIdByName("Integrity Card")
t.CARD_PATIENCE = Isaac.GetCardIdByName("Patience Card")
t.CARD_BRAVERY = Isaac.GetCardIdByName("Bravery Card")
t.CARD_LOG = Isaac.GetCardIdByName("The Log")
t.CARD_RAGE = Isaac.GetCardIdByName("Rage")
t.CARD_NOBODY = Isaac.GetCardIdByName("Nobody")
t.CARD_PARTY_TIME = Isaac.GetCardIdByName("Party Time")
t.CARD_INFURIATING_NOTE = Isaac.GetCardIdByName("Infuriating Note")
t.CARD_BEANSTALK = Isaac.GetCardIdByName("Beanstalk")
t.CARD_JERKO = Isaac.GetCardIdByName("Jerko")
t.CARD_NEGATIVE_NANCY = Isaac.GetCardIdByName("Negative Nancy")
t.CARD_TALHAK = Isaac.GetCardIdByName("Talhak")
t.CARD_YU_SZE = Isaac.GetCardIdByName("Yu Sze")
t.CARD_LITTLE_BOY_BLUE = Isaac.GetCardIdByName("Little Boy Blue")
t.CARD_HAT_TRICK = Isaac.GetCardIdByName("Hat Trick")
t.CARD_COMEDIANS_MANIFESTO = Isaac.GetCardIdByName("Comedian's Manifesto")
t.CARD_LEXICON = Isaac.GetCardIdByName("Lexicon")
t.CARD_GNASHER = Isaac.GetCardIdByName("Gnasher")
t.CARD_SILVIO = Isaac.GetCardIdByName("Silvio")
t.CARD_EULENSPIEGEL = Isaac.GetCardIdByName("Eulenspiegel")
t.CARD_COCONUT = Isaac.GetCardIdByName("Coconut")

if EID then
    -- descs from stale
    EID:addCard(t.CARD_ELECTROCHEMISTRY, "Taking the card unlocks an effect where all pickups spawned are converted into pills, this effect is temporary but the duration is applied whenever a pill is eaten, as long as at least one card was used in the run.#After eating roughly 40 pills, electrochemistry levels up and items are replaced with horse pills during the effect.")
    EID:addCard(t.CARD_INLAND_EMPIRE, "Gives half a soul heart every time a floor is started, after 4 floors it becomes a full heart. After 9 it becomes an Angel heart.")
    -- descs from 4head
    EID:addCard(t.CARD_LOG , "On use, Isaac will hold the card above his head.#Shooting in any direction will throw a log towards it.#The thrown log knocks back any enemy it hits, deals 1.5x the player's damage, stuns for 0.5 seconds, and destroys rocks it hits.")
    EID:addCard(t.CARD_RAGE, "On use, a a potion falls from the sky and creates a temporary purple aura#Inside the aura, Isaac gains 2x tears, 2x speed, 2x damage, 10x luck, 2x range, and 1.5x shot speed#Familiars inside the aura are buffed")
end

t.TEAM_KERKEL_BIDDY = "Kerkel & Biddybododode"
t.TEAM_AERO_TRUJI = "Aeronaut & Truji"
t.TEAM_SPOOP_SPLIT = "Spoop & Split"
t.TEAM_STALE = "Stale"
t.TEAM_GLOOPY20 = "Gloopy20"
t.TEAM_MONWIL_SKULLDIER = "Monwil & Skulldier"
t.TEAM_FOKS_WONS = "Foks & Wons"
t.TEAM_BBS = "Babybluesheep"
t.TEAM_BRENDEN_DOODLE = "BrendenPerson? & DoodleDude"
t.TEAM_RAT = "Rat"
t.TEAM_DPOWER_REIXEN = "dpower12 & Reixen"
t.TEAM_4HEAD_ANDRE = "4Head & Andre Doruk"
t.TEAM_JANE = "Jane Sorrow"
t.TEAM_JOHN = "John Sorrow"

---@type string[]
t.TEAMS = {
    t.TEAM_KERKEL_BIDDY,
    t.TEAM_AERO_TRUJI,
    t.TEAM_SPOOP_SPLIT,
    t.TEAM_STALE,
    t.TEAM_GLOOPY20,
    t.TEAM_MONWIL_SKULLDIER,
    t.TEAM_FOKS_WONS,
    t.TEAM_BBS,
    t.TEAM_BRENDEN_DOODLE,
    t.TEAM_RAT,
    t.TEAM_DPOWER_REIXEN,
    t.TEAM_4HEAD_ANDRE,
    t.TEAM_JANE,
    t.TEAM_JOHN,
}

---@type table<string, Card[]>
t.TEAM_TO_CARDS = {
    [t.TEAM_KERKEL_BIDDY] = {
        t.CARD_JUSTICE,
        t.CARD_LITTLE_CARD_JOHN,
        t.CARD_PHONKARD,
        t.CARD_QUESTION_FUN,
        t.CARD_BLUE_ASBESTOS,
        t.CARD_VIVIAN,
        t.CARD_WILD,
        t.CARD_SMASH_KARD,
    },
    [t.TEAM_AERO_TRUJI] = {
        t.CARD_POLYMERIZATION,
        t.CARD_AMALGAM,
        t.CARD_IJIRAQ,
        t.CARD_PUNCH,
        t.CARD_MAGNETIC,
    },
    [t.TEAM_SPOOP_SPLIT] = {
        t.CARD_REPORT,
        t.CARD_SCRATCH,
        t.CARD_CHARM,
        t.CARD_BOARD,
        t.CARD_REPORT_ALT,
        t.CARD_SCRATCH_ALT,
        t.CARD_CHARM_ALT,
        t.CARD_BOARD_ALT,
    },
    [t.TEAM_STALE] = {
        t.CARD_ELECTROCHEMISTRY,
        t.CARD_INLAND_EMPIRE,
    },
    [t.TEAM_GLOOPY20] = {
        t.CARD_YARA_YARA,
    },
    [t.TEAM_MONWIL_SKULLDIER] = {
        t.CARD_RED_SEAL,
        t.CARD_NIHIL,
        t.CARD_ECHO,
        t.CARD_161_OF_CLUBS,
        t.CARD_CLAM,
        t.CARD_MANIFESTATION,
        t.CARD_MOON,
        t.CARD_SD,
    },
    [t.TEAM_FOKS_WONS] = {
        t.CARD_TICK,
        t.CARD_COMBUSTING_NECROMANCY,
        t.CARD_CHIMERA_FORM,
        t.CARD_DRUG_GRIND,
        t.CARD_2_OF_GYATTS,
    },
    [t.TEAM_BBS] = {
        t.CARD_DIRT_BLOCK,
        t.CARD_WYVERN,
        t.CARD_WRAITH,
        t.CARD_OLD_MAN,
        t.CARD_BLUE_SLIME,
        t.CARD_WEREWOLF,
        t.CARD_MEGASHARK,
    },
    [t.TEAM_BRENDEN_DOODLE] = {
        t.CARD_POT_OF_GREED,
        t.CARD_MISPRINT,
        t.CARD_BASEBALL,
        t.CARD_GET_WELL_SOON,
        t.CARD_CHAOS_WARP,
        t.CARD_SCAN_N_PLAY,
        t.CARD_MANA_DRAIN,
        t.CARD_RAGING_RIVER,
    },
    [t.TEAM_RAT] = {
        t.CARD_COSTCO,
    },
    [t.TEAM_DPOWER_REIXEN] = {
        t.CARD_DETERMINATION,
        t.CARD_PERSEVERANCE,
        t.CARD_KINDNESS,
        t.CARD_JUSTICE_SOUL,
        t.CARD_INTEGRITY,
        t.CARD_PATIENCE,
        t.CARD_BRAVERY,
    },
    [t.TEAM_4HEAD_ANDRE] = {
        t.CARD_LOG,
        t.CARD_RAGE,
    },
    [t.TEAM_JANE] = {
        t.CARD_NOBODY,
        t.CARD_PARTY_TIME,
        t.CARD_INFURIATING_NOTE,
        t.CARD_BEANSTALK,
        t.CARD_JERKO,
        t.CARD_NEGATIVE_NANCY,
        t.CARD_TALHAK,
        t.CARD_YU_SZE,
    },
    [t.TEAM_JOHN] = {
        t.CARD_LITTLE_BOY_BLUE,
        t.CARD_HAT_TRICK,
        t.CARD_COMEDIANS_MANIFESTO,
        t.CARD_LEXICON,
        t.CARD_GNASHER,
        t.CARD_SILVIO,
        t.CARD_EULENSPIEGEL,
        t.CARD_COCONUT,
    }
}

---@param team string
function t:ZeroToOneHowManyCardsDidYouDo(team)
    return 1 - (1 - #t.TEAM_TO_CARDS[team] / 8) ^ 1
end

---@type table<string, number>
t.TEAM_TO_WEIGHT = {
    [t.TEAM_KERKEL_BIDDY] = t:ZeroToOneHowManyCardsDidYouDo(t.TEAM_KERKEL_BIDDY),
    [t.TEAM_AERO_TRUJI] = t:ZeroToOneHowManyCardsDidYouDo(t.TEAM_AERO_TRUJI),
    [t.TEAM_SPOOP_SPLIT] = t:ZeroToOneHowManyCardsDidYouDo(t.TEAM_SPOOP_SPLIT),
    [t.TEAM_STALE] = t:ZeroToOneHowManyCardsDidYouDo(t.TEAM_STALE),
    [t.TEAM_GLOOPY20] = 0.0001,
    [t.TEAM_MONWIL_SKULLDIER] = t:ZeroToOneHowManyCardsDidYouDo(t.TEAM_MONWIL_SKULLDIER),
    [t.TEAM_FOKS_WONS] = t:ZeroToOneHowManyCardsDidYouDo(t.TEAM_FOKS_WONS),
    [t.TEAM_BBS] = t:ZeroToOneHowManyCardsDidYouDo(t.TEAM_BBS),
    [t.TEAM_BRENDEN_DOODLE] = t:ZeroToOneHowManyCardsDidYouDo(t.TEAM_BRENDEN_DOODLE),
    [t.TEAM_RAT] = 0.01,
    [t.TEAM_DPOWER_REIXEN] = t:ZeroToOneHowManyCardsDidYouDo(t.TEAM_DPOWER_REIXEN),
    [t.TEAM_4HEAD_ANDRE] = t:ZeroToOneHowManyCardsDidYouDo(t.TEAM_4HEAD_ANDRE),
    [t.TEAM_JANE] = t:ZeroToOneHowManyCardsDidYouDo(t.TEAM_JANE) * 0.5,
    [t.TEAM_JOHN] = t:ZeroToOneHowManyCardsDidYouDo(t.TEAM_JOHN) * 0.5,
}

---@type table<Card, true>
t.CARDS = {}
t.NumCards = -1

for _, v in ipairs(t.TEAMS) do
    for _, vv in ipairs(t.TEAM_TO_CARDS[v]) do
        t.NumCards = t.NumCards + 1
        t.CARDS[vv] = true
    end
end

-- for k, v in pairs(t.CARDS) do
--     if k ~= t.CARD_MOON then
--         Isaac.Spawn(
--             EntityType.ENTITY_PICKUP,
--             PickupVariant.PICKUP_TAROTCARD,
--             k,
--             Game():GetRoom():FindFreePickupSpawnPosition(Game():GetRoom():GetCenterPos(), 40),
--             Vector.Zero,
--             nil
--         )
--     end
-- end

--#region Hint

t.SPRITE_VRUD = Sprite("gfx/ui_cardhint.anm2", true)
t.SPRITE_VRUD:Play("Idle", true)
t.FONT = Font()
t.FONT:Load("font/luaminioutlined.fnt")

t.Frame = 0
t.GAME = Game()

t.PAD_LEFT = 18
t.PAD_DOWN = 18
t.SETTINGS = FontRenderSettings()
t.SETTINGS:SetAlignment(DrawStringAlignment.MIDDLE_LEFT)
t.TEXT_WIDTH = 150
t.SETTINGS:EnableAutoWrap(t.TEXT_WIDTH)
t.BASE_OFFSET = Vector(0, 50)
t.SPRITE_VRUD.Offset = t.BASE_OFFSET
t.SOUND_VRUD = Isaac.GetSoundIdByName("vrudwhat")
t.SFX = SFXManager()

t.Text = ""
t.TargetText = ""
t.TEXT_DURATION = 60 * 4
t.FinishFrame = nil
t.BLINK_FREQ = 60 * 5
t.BLINK_DUR = 8
t.Vel = 0
---@type table<Card, true>
t.TouchedCards = {}

---@class Guy
---@field Vel Vector
---@field Sprite Sprite
---@field Seed integer
---@field Pos Vector

---@type Guy[] 
t.Guys = {}

---@type Sprite[]
t.Bloods = {}

---@param text string
function t:Say(text)
    t.SPRITE_VRUD:GetLayer(0):SetCropOffset(Vector.Zero)
    t.Text = ""
    t.SPRITE_VRUD.Offset = t.BASE_OFFSET
    t.TargetText = text
    t.FinishFrame = nil
end

---@param player EntityPlayer
---@param id Card
MODJAM_VOL_3:AddCallback(ModCallbacks.MC_POST_PLAYER_ADD_CARD, function (_, player, id)
    if not t.CARDS[id]
    or t.TouchedCards[id]
    or MODJAM_VOL_3.SaveManager.GetSettingsSave().DisabledVrud then return end
    t.TouchedCards[id] = true
    for _, team in pairs(t.TEAMS) do
        for _, card in ipairs(t.TEAM_TO_CARDS[team]) do
            if card == id then
                t:Say("This card was made by " .. team .. ". (F3 to toggle)")
                break
            end
        end
    end
end)

MODJAM_VOL_3:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function ()
    t.Guys = {}
    t.Bloods = {}
    t.Text = ""
    t.TargetText = ""
    t.Vel = 0
    t.FinishFrame = nil
    t.SPRITE_VRUD.Offset = t.BASE_OFFSET
    t.TouchedCards = {}
end)

MODJAM_VOL_3:AddCallback(ModCallbacks.MC_POST_UPDATE, function ()
    if t.SPRITE_VRUD.Offset:Distance(Vector.Zero) < 2 then
        local update = t.GAME:GetFrameCount() % 2 == 0
        local enabled = not MODJAM_VOL_3.SaveManager.GetSettingsSave().DisabledVrud
        if #t.Text < #t.TargetText then
            if enabled then
                t.SFX:Play(t.SOUND_VRUD, 0.3)
                if update then
                    local layer = t.SPRITE_VRUD:GetLayer(0)
                    local offset = layer:GetCropOffset()
                    if offset.X == 0 then
                        layer:SetCropOffset(Vector(32, offset.Y))
                    else
                        layer:SetCropOffset(Vector(0, offset.Y))
                    end
                end
                t.Text = t.TargetText:sub(1, #t.Text + 1)
                t.FinishFrame = t.Frame
            end
        elseif update and enabled then
            local layer = t.SPRITE_VRUD:GetLayer(0)
            local offset = layer:GetCropOffset()
            layer:SetCropOffset(Vector(0, offset.Y))
        end
    end
    if t.FinishFrame and t.Frame - t.FinishFrame >= t.TEXT_DURATION then
        -- t.Text = ""
        t.TargetText = ""
        t.FinishFrame = nil
    end
end)

---@type string[]
t.RETURN_LINES = {
    "Alright bro, did you REALLY have to do that?",
    "Well well well, look who came CRAWLING back.",
}

---@param str string
function t:IsLetter(str)
    local byte = str:lower():byte()
    return byte >= 97 and byte <= 122
end

---@param hsader string
MODJAM_VOL_3:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, function (_, hsader)
    if hsader ~= "Phonk Overlay" then return end
    local paused = t.GAME:IsPaused()
    if not paused then
        t.Frame = t.Frame + 1

        if t.TargetText ~= "" then
            t.Vel = 0
            t.SPRITE_VRUD.Offset = MODJAM_VOL_3.KerkelBiddy:Lerp(t.SPRITE_VRUD.Offset, Vector.Zero, 0.08)
        else
            t.Vel = t.Vel + 1
            t.SPRITE_VRUD.Offset = t.SPRITE_VRUD.Offset + Vector(0, t.Vel * 0.05)
            -- t.SPRITE_VRUD.Offset = t.SPRITE_VRUD.Offset + Vector(0, 1.5)
            -- t.SPRITE_VRUD.Offset = MODJAM_VOL_3.KerkelBiddy:Lerp(t.SPRITE_VRUD.Offset, t.BASE_OFFSET, 0.03)
        end

        if t.Frame % t.BLINK_FREQ == 0 then
            local layer = t.SPRITE_VRUD:GetLayer(0)
            layer:SetCropOffset(Vector(layer:GetCropOffset().X, 32))
        end
        if (t.Frame - t.BLINK_DUR) % t.BLINK_FREQ == 0 then
            local layer = t.SPRITE_VRUD:GetLayer(0)
            layer:SetCropOffset(Vector(layer:GetCropOffset().X, 0))
        end
    end

    local height = Isaac.GetScreenHeight()
    local pos = Vector(
        t.PAD_LEFT,
        height - t.PAD_DOWN + math.sin(t.Frame * 0.08) * 0.5
    )

    if not paused and Input.IsButtonTriggered(Keyboard.KEY_F3, 0) then
        t.TouchedCards = {}
        local save = MODJAM_VOL_3.SaveManager.GetSettingsSave()
        save.DisabledVrud = not save.DisabledVrud
        if save.DisabledVrud then
            if (pos.Y + t.SPRITE_VRUD.Offset.Y - 15) < height then
                t.SFX:Play(SoundEffect.SOUND_GFUEL_GUNSHOT_LARGE)
                t.SFX:Play(SoundEffect.SOUND_DEATH_BURST_SMALL)
                if #t.Text > 0 and #t.Text < #t.TargetText then
                    while not t:IsLetter(t.Text:sub(#t.Text, #t.Text)) do
                        t.Text = t.Text:sub(1, #t.Text - 1)
                    end
                    t.Text = t.Text .. "-"
                end
                local sprite = Sprite("gfx/ui_cardhint.anm2", true)
                sprite:Play("Idle", true)
                sprite:GetLayer(0):SetCropOffset(Vector(0, 64))
                local finalPos = pos + Vector(0, 4) + t.SPRITE_VRUD.Offset
                t.Guys[#t.Guys + 1] = {
                    Sprite = sprite,
                    Vel = Vector((math.random() - 0.2) * 2, -7 - math.random() * 5),
                    Seed = Random(),
                    Pos = finalPos
                }
                local blood = Sprite("gfx/1000.002_Blood Explosion.anm2", true)
                blood:Play("Poof")
                blood.Color = Color(
                    1, 1, 1,
                    1,
                    0, 0, 0,
                    2, 2, 8,
                    1
                )
                blood.Scale = Vector.One * 0.8
                blood.Offset = finalPos + Vector(0, -10)
                t.Bloods[#t.Bloods + 1] = blood
                t.SPRITE_VRUD.Color = Color(0, 0, 0, 0)
            end
        else
            t:Say(t.RETURN_LINES[math.random(1, #t.RETURN_LINES)])
            t.SPRITE_VRUD.Color = Color.Default
        end
    end

    -- t.SPRITE_VRUD.Rotation = math.sin(t.Frame * 0.1) * 5

    Isaac.DrawLine(
        Vector(0, height) + t.SPRITE_VRUD.Offset + Vector(0, 5),
        Vector(0, height - t.PAD_DOWN - 16) + t.SPRITE_VRUD.Offset,
        KColor(0, 0, 0, 1),
        KColor(0, 0, 0, 0),
        t.TEXT_WIDTH + t.PAD_LEFT + 210
    )

    for i = #t.Guys, 1, -1 do
        local guy = t.Guys[i]
        if not paused then
            if t.Frame % 10 == 0 then
                local blood = Sprite("gfx/1000.002_Blood Explosion.anm2", true)
                blood:Play("Poof_Small")
                blood.Color = Color(
                    1, 1, 1,
                    1,
                    0, 0, 0,
                    2, 2, 8,
                    1
                )
                blood.Offset = guy.Pos
                t.Bloods[#t.Bloods + 1] = blood
            end
            guy.Vel = guy.Vel + Vector(0, 0.3)
            guy.Pos = guy.Pos + guy.Vel
            guy.Sprite.Rotation = guy.Sprite.Rotation + (10 + RNG(guy.Seed):RandomFloat() * 10) * (guy.Vel.X > 0 and 1 or -1)
        end
        guy.Sprite:Render(guy.Pos)
        -- print("Hey")
        if guy.Pos.Y > height + 100 then
            table.remove(t.Guys, i)
        end
    end

    for i = #t.Bloods, 1, -1 do
        local blood = t.Bloods[i]
        if t.Frame % 2 == 0 and not paused then
            blood:Update()
        end
        blood:Render(Vector.Zero)
        if blood:IsFinished() then
            table.remove(t.Bloods, i)
        end
    end

    t.SPRITE_VRUD:Render(pos)
    t.FONT:DrawString(
        t.Text,
        t.PAD_LEFT + 16 + t.SPRITE_VRUD.Offset.X + t.GAME.ScreenShakeOffset.X,
        height - t.PAD_DOWN - 2 + t.SPRITE_VRUD.Offset.Y + t.GAME.ScreenShakeOffset.Y,
        1,
        1,
        KColor(1, 1, 1, 1),
        t.SETTINGS
    )
end)
--#endregion
--#region Replacement

t.BASE_MODJAM_CHANCE = 0.2
t.CONFIG = Isaac.GetItemConfig()

---@param rng RNG
---@return Card?
function t:GetWeightedJamCard(rng)
    local picker = WeightedOutcomePicker()
    for i, v in ipairs(t.TEAMS) do
        picker:AddOutcomeFloat(i, t.TEAM_TO_WEIGHT[v])
    end
    local team = t.TEAMS[picker:PickOutcome(rng)]
    if team then
        ---@type Card[]
        local cards = {}
        for _, v in ipairs(t.TEAM_TO_CARDS[team]) do
            local card = t.CONFIG:GetCard(v)
            if card and card:IsAvailable() then
                cards[#cards + 1] = v
            end
        end
        if #cards > 0 then
            return cards[rng:RandomInt(1, #cards)]
        end
    end
end

---@param rng RNG
---@param id Card
---@param playing boolean
---@param runes boolean
---@param onlyRunes boolean
MODJAM_VOL_3:AddPriorityCallback(ModCallbacks.MC_GET_CARD, CallbackPriority.EARLY, function (_, rng, id, playing, runes, onlyRunes)
    if not onlyRunes and rng:RandomFloat() < t.BASE_MODJAM_CHANCE then
        local card = t:GetWeightedJamCard(rng)
        if card then
            return card
        end
    end

    if t.CARDS[id] then
        return t.GAME:GetItemPool():GetCard(rng:Next(), playing, runes, onlyRunes)
    end
end)
--#endregion
--#region Binder

t.COLLECTIBLE_BINDER = Isaac.GetItemIdByName("Binder")

if EID then
    EID:addCollectible(t.COLLECTIBLE_BINDER, "{{Card}} Gain a random card from ModJam Vol. 3")
    -- EID:addDescriptionModifier(
    --     "MJ3_BINDER",
    --     function (obj)
    --         return obj.ObjType == EntityType.ENTITY_PICKUP
    --         and obj.ObjVariant == PickupVariant.PICKUP_COLLECTIBLE
    --         and obj.ObjSubType == t.COLLECTIBLE_BINDER
    --     end,
    --     function (obj)
    --         obj.Description = obj.Description:gsub("{{Card}}", "{{Card" .. t:GetWeightedJamCard(RNG(Random() + 1)) .. "}}")
    --         -- obj.Description = "A"
    --         return obj
    --     end
    -- )
end

---@param rng RNG
---@param player EntityPlayer
---@param flags UseFlag
MODJAM_VOL_3:AddCallback(ModCallbacks.MC_USE_ITEM, function (_, _, rng, player, flags)
    local card = t:GetWeightedJamCard(rng)
    if card then
        -- Isaac.Spawn(
        --     EntityType.ENTITY_PICKUP,
        --     PickupVariant.PICKUP_TAROTCARD,
        --     card,
        --     t.GAME:GetRoom():FindFreePickupSpawnPosition(player.Position, 40),
        --     Vector.Zero,
        --     nil
        -- )
        player:AddCard(card)
        t.SFX:Play(SoundEffect.SOUND_BOOK_PAGE_TURN_12)
        if flags & UseFlag.USE_NOANIM == 0 then
            player:AnimateCard(card, "UseItem")
            return
        end
    end
    return flags & UseFlag.USE_NOANIM == 0
end, t.COLLECTIBLE_BINDER)

--#endregion

-- for i = 1, 2500 do
--     local card = t:GetWeightedJamCard(RNG(Random()))
--     if card == t.CARD_YARA_YARA then
--         print(i)
--         break
--     end
-- end