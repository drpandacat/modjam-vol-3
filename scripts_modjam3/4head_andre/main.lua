-- Author: 4Head (ConJam Submission)
-- main.lua
-- 7/13/26
-- The main mod loader that loads in each script.

ClashRoyaleCards = RegisterMod("Clash Royale", 1)
ClashRoyaleCards.SFXMan = SFXManager()
ClashRoyaleCards.RNG = RNG(Random(), 35)

ClashRoyaleCards.Enums = {
    Card = {
        LOG = Isaac.GetCardIdByName("The Log"),
        RAGE = Isaac.GetCardIdByName("Rage"),
    },
    NullItem = {
        LOG_CARD = Isaac.GetItemIdByName("The Log Card"),
    },
    EffectVariant = {
        LOG = Isaac.GetEntityVariantByName("The Log"),
        RAGE_POTION = Isaac.GetEntityVariantByName("Rage Potion"),
        RAGE_AREA = Isaac.GetEntityVariantByName("Rage Area"),
    },
    SoundEffect = {
        LOG_VOCAL = Isaac.GetSoundIdByName("Log Vocal"),
        LOG_ROLL = Isaac.GetSoundIdByName("Log Roll"),
        LOG_DESTROY = Isaac.GetSoundIdByName("Log Destroy"),
        RAGE_USE = Isaac.GetSoundIdByName("Rage Use"),
        CARD_USE = Isaac.GetSoundIdByName("Clash Card Spell Use")
    }
}

local scripts = {
    include("scripts_modjam3.4head_andre.cr-scripts.utils"),
    include("scripts_modjam3.4head_andre.cr-scripts.cards.log"),
    include("scripts_modjam3.4head_andre.cr-scripts.cards.rage"),
}

for _, script in pairs(scripts) do
    if type(script.Init) == "function" then
        script:Init()
    end
end
