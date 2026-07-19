HODGEPODGE = RegisterMod("Hodgepodge", 1)

HODGEPODGE.Card = {
    RED_SEAL = Isaac.GetCardIdByName("Red Seal"),
    NIHIL = Isaac.GetCardIdByName("Nihil"),
    ECHO = Isaac.GetCardIdByName("Echo"),
    THE_161_OF_CLUBS = Isaac.GetCardIdByName("161 of Clubs"),
    CLAM_CARD = Isaac.GetCardIdByName("Clam Card"),
    MANIFESTATION = Isaac.GetCardIdByName("Manifestation"),
    MOON = Isaac.GetCardIdByName("Moon"),
    SD_CARD = Isaac.GetCardIdByName("SD Card"),
}

HODGEPODGE.NullItemID = {
    COPLAYER_TRACKER = Isaac.GetNullItemIdByName("[HDPG] Coplayer Tracker"),
    ECHO_STREAK_COUNTER = Isaac.GetNullItemIdByName("[HDPG] Echo Streak Counter"),
}

HODGEPODGE.NullCostume = {
    ISAAC_EXE = Isaac.GetCostumeIdByPath("gfx/characters/isaac_exe_costume.anm2")
}

HODGEPODGE.CollectibleType = {
    OLD_DATA = Isaac.GetItemIdByName("OLD_DATA"),
}

HODGEPODGE.SoundEffect = {
    MOON_USE = Isaac.GetSoundIdByName("[HDPG] Moon Use"),
    CLAM_CARD_USE = Isaac.GetSoundIdByName("[HDPG] Clam Card Use"),
    RED_SEAL_RETRIGGER = Isaac.GetSoundIdByName("[HDPG] Red Seal Retrigger"),
    RED_SEAL_FINISH = Isaac.GetSoundIdByName("[HDPG] Red Seal Finish"),
}

HODGEPODGE.Achievement = {
    VOID_CARDS = Isaac.GetAchievementIdByName("[HDPG] Void Cards"),
    LOTTA_CLUBS = Isaac.GetAchievementIdByName("[HDPG] 161 of Clubs"),
}

HODGEPODGE.EffectVariant = {
    HOLE_IN_WALL = Isaac.GetEntityVariantByName("[HDPG] Hole in wall"),
    MOON_PARTICLE = Isaac.GetEntityVariantByName("[HDPG] Moon Particle"),
}

HODGEPODGE.Music = {
    BANGER = Isaac.GetMusicIdByName("[HDPG] Funky Town"),
    ISAAC_EXE = Isaac.GetMusicIdByName("[HDPG] Isaac.exe"),
}

HODGEPODGE.PlayerType = {
    MANIFESTATION = Isaac.GetPlayerTypeByName("Manifestation")
}

HODGEPODGE.EntityType = {
    CARD_REPLACER = Isaac.GetEntityTypeByName("[HDPG] Red Seal Card Spawner")
}

HODGEPODGE.SaveManager = MODJAM_VOL_3.SaveManager
HODGEPODGE.CoplayerManager = include("scripts_modjam3.monwil_skulldier.card_jam_code.utils.coplayer_manager")

HODGEPODGE.Game = Game()
HODGEPODGE.ItemPool = Game():GetItemPool()
HODGEPODGE.ItemConfig = Isaac.GetItemConfig()
HODGEPODGE.Sfx = SFXManager()

for _, filename in ipairs({
    "eid_compat",
    "achievement_stuff",
    "card_replacer",
}) do
    include("scripts_modjam3.monwil_skulldier.card_jam_code.utils." .. filename)
end

for _, filename in ipairs({
    "red_seal",
    "nihil",
    "echo",
    "161_of_clubs",
    "clam_card",
    "manifestation",
    "moon",
    "sd_card",
}) do
    include("scripts_modjam3.monwil_skulldier.card_jam_code.cards." .. filename)
end

include("scripts_modjam3.monwil_skulldier.card_jam_code.items.old_data")