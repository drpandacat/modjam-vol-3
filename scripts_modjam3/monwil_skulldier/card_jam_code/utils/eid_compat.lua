local mod = HODGEPODGE

local function PostModsLoaded()
    if not EID then
        return
    end

    local sprite = Sprite()
    sprite:Load("gfx/ui/hodgepodge_eid_card_icons.anm2", true)
    EID:addIcon("Card"..HODGEPODGE.Card.RED_SEAL, "Idle", 1, 9, 9, 1, 1, sprite)
    EID:addIcon("Card"..HODGEPODGE.Card.NIHIL, "Idle", 2, 9, 9, 1, 1, sprite)
    EID:addIcon("Card"..HODGEPODGE.Card.ECHO, "Idle", 3, 9, 9, 1, 1, sprite)
    EID:addIcon("Card"..HODGEPODGE.Card.THE_161_OF_CLUBS, "Idle", 4, 9, 9, 1, 1, sprite)
    EID:addIcon("Card"..HODGEPODGE.Card.CLAM_CARD, "Idle", 5, 9, 9, 1, 1, sprite)
    EID:addIcon("Card"..HODGEPODGE.Card.MANIFESTATION, "Idle", 6, 9, 9, 1, 1, sprite)
    EID:addIcon("Card"..HODGEPODGE.Card.MOON, "Idle", 9, 9, 9, 1, 1, sprite)
    EID:addIcon("Card"..HODGEPODGE.Card.SD_CARD, "Idle", 7, 9, 9, 1, 1, sprite)

    EID:addCard(HODGEPODGE.Card.RED_SEAL, "{{ArrowUp}} Retriggers on-pickup effects of held passive items #{{ArrowDown}} Does not retrigger effects that grant health")
    EID:addCard(HODGEPODGE.Card.NIHIL, "{{ArrowUp}} Swaps closest item pedestal with item from Nihil's storage #{{Warning}} If no item is stored, will instead swap it with {{Collectible" .. mod.CollectibleType.OLD_DATA .. "}} OLD_DATA  #{{Warning}} Stored item persists between runs # Using this card with no item nearby will instead forget stored item")
    EID:addCard(HODGEPODGE.Card.ECHO, "Acts as a copy of a random active item #{{ArrowUp}} Has a chance to drop a copy of itself on use")
    EID:addCard(HODGEPODGE.Card.THE_161_OF_CLUBS, "{{Warning}} Fills the room with various bombs")
    EID:addCard(HODGEPODGE.Card.CLAM_CARD, "{{ArrowUp}} Isaac charges in current moving direction, breaking through obstacles, enemies and walls #{{Warning}} Ends when hitting a wall with no room on the other side")
    EID:addCard(HODGEPODGE.Card.MANIFESTATION, "{{ArrowUp}} Consumes all passive items and trinkets in the room, then spawns a permanent bonus player holding them #{{Warning}} This can collect paid items for free #{{Warning}} This can collect all options from choice pedestals #{{ArrowDown}} The extra character cannot heal in any way")
    EID:addCard(HODGEPODGE.Card.MOON, "{{SuperSecretRoom}} Teleports Isaac to the Super Secret Room #{{ArrowUp}} When dropped, attracts nearby entities to itself")
    EID:addCard(HODGEPODGE.Card.SD_CARD, "Activates a random effect #{{Warning}} The effect is usually good")

    EID:addCollectible(HODGEPODGE.CollectibleType.OLD_DATA, "{{Warning}} Makes pickup spawns more random #{{Warning}} Replaces all non-pill consumables with {{Card"..HODGEPODGE.Card.SD_CARD .. "}} SD Cards")

    EID:addBirthright(HODGEPODGE.PlayerType.MANIFESTATION, "{{Heart}} Allows picking up hearts")
end

mod:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, PostModsLoaded)
