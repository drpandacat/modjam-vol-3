AllInJohn = RegisterMod("AllInJohn", 1) ---@type ModReference

AllInJohn.GAME = Game()
AllInJohn.SFX = SFXManager()

---@param id SoundEffect
---@param flags UseFlag
function AllInJohn:playAnnouncerVoice(id, flags)
    if(flags & UseFlag.USE_NOANNOUNCER ~= 0) then return end

    if(Options.AnnouncerVoiceMode == AnnouncerVoiceMode.NEVER) then return end
    if(Options.AnnouncerVoiceMode == AnnouncerVoiceMode.RANDOM and math.random()<0.5) then return end

    AllInJohn.SFX:Play(id, 1, nil, nil, 0.95+math.random()*0.1)
end

include("scripts_modjam3.johnsorrow.scripts_allinjohn.enums")
include("scripts_modjam3.johnsorrow.scripts_allinjohn.data")

include("scripts_modjam3.johnsorrow.scripts_allinjohn.card_data")

include("scripts_modjam3.johnsorrow.scripts_allinjohn.hud_helper_by_kerkel")

include("scripts_modjam3.johnsorrow.scripts_allinjohn.cards.little_boy_blue")
include("scripts_modjam3.johnsorrow.scripts_allinjohn.cards.hat_trick")
include("scripts_modjam3.johnsorrow.scripts_allinjohn.cards.comedians_manifesto")
include("scripts_modjam3.johnsorrow.scripts_allinjohn.cards.lexicon")
include("scripts_modjam3.johnsorrow.scripts_allinjohn.cards.gnasher")
include("scripts_modjam3.johnsorrow.scripts_allinjohn.cards.silvio")
include("scripts_modjam3.johnsorrow.scripts_allinjohn.cards.eulenspiegel")
include("scripts_modjam3.johnsorrow.scripts_allinjohn.cards.coconut")

include("scripts_modjam3.johnsorrow.scripts_allinjohn.items.guess_the_jest")

include("scripts_modjam3.johnsorrow.scripts_allinjohn.eid")
include("scripts_modjam3.johnsorrow.scripts_allinjohn.minimapi")