CardjamFlipCards = RegisterMod("CardjamFlip", 1) ---@type ModReference

CardjamFlipCards.GAME = Game()
CardjamFlipCards.SFX = SFXManager()

---@param id SoundEffect
---@param flags UseFlag
function CardjamFlipCards:playAnnouncerVoice(id, flags)
    if(flags & UseFlag.USE_NOANNOUNCER ~= 0) then return end

    if(Options.AnnouncerVoiceMode == AnnouncerVoiceMode.NEVER) then return end
    if(Options.AnnouncerVoiceMode == AnnouncerVoiceMode.RANDOM and math.random()<0.5) then return end

    CardjamFlipCards.SFX:Play(id, 2)
end

include("scripts_modjam3.spoop_split.scripts_flip.enums")
include("scripts_modjam3.spoop_split.scripts_flip.data")

include("scripts_modjam3.spoop_split.scripts_flip.card_data")

include("scripts_modjam3.spoop_split.scripts_flip.hud_helper_by_kerkel")

include("scripts_modjam3.spoop_split.scripts_flip.cards.report")
include("scripts_modjam3.spoop_split.scripts_flip.cards.scratch")
include("scripts_modjam3.spoop_split.scripts_flip.cards.charm")
include("scripts_modjam3.spoop_split.scripts_flip.cards.board")

include("scripts_modjam3.spoop_split.scripts_flip.cards.report_alt")
include("scripts_modjam3.spoop_split.scripts_flip.cards.scratch_alt")
include("scripts_modjam3.spoop_split.scripts_flip.cards.charm_alt")
include("scripts_modjam3.spoop_split.scripts_flip.cards.board_alt")

include("scripts_modjam3.spoop_split.scripts_flip.items.double_sided_card")

include("scripts_modjam3.spoop_split.scripts_flip.eid")
include("scripts_modjam3.spoop_split.scripts_flip.minimapi")