AllInJane = RegisterMod("AllInJane", 1) ---@type ModReference

AllInJane.GAME = Game()
AllInJane.SFX = SFXManager()

---@param id SoundEffect
---@param flags UseFlag
function AllInJane:playAnnouncerVoice(id, flags)
    if(flags & UseFlag.USE_NOANNOUNCER ~= 0) then return end

    if(Options.AnnouncerVoiceMode == AnnouncerVoiceMode.NEVER) then return end
    if(Options.AnnouncerVoiceMode == AnnouncerVoiceMode.RANDOM and math.random()<0.5) then return end

    AllInJane.SFX:Play(id, 1, nil, nil, 0.95+math.random()*0.1)
end

include("scripts_modjam3.janesorrow.scripts_allinjane.enums")
include("scripts_modjam3.janesorrow.scripts_allinjane.data")

include("scripts_modjam3.janesorrow.scripts_allinjane.card_data")

include("scripts_modjam3.janesorrow.scripts_allinjane.hud_helper_by_kerkel")

include("scripts_modjam3.janesorrow.scripts_allinjane.cards.nobody")
include("scripts_modjam3.janesorrow.scripts_allinjane.cards.party_time")
include("scripts_modjam3.janesorrow.scripts_allinjane.cards.infuriating_note")
include("scripts_modjam3.janesorrow.scripts_allinjane.cards.beanstalk")
include("scripts_modjam3.janesorrow.scripts_allinjane.cards.jerko")
include("scripts_modjam3.janesorrow.scripts_allinjane.cards.negative_nancy")
include("scripts_modjam3.janesorrow.scripts_allinjane.cards.talhak")
include("scripts_modjam3.janesorrow.scripts_allinjane.cards.yu_sze")

include("scripts_modjam3.janesorrow.scripts_allinjane.trinkets.anarchy_tag")

include("scripts_modjam3.janesorrow.scripts_allinjane.eid")
include("scripts_modjam3.janesorrow.scripts_allinjane.minimapi")