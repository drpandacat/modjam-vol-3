if EID == nil then return end



local eidIcons = Sprite()
eidIcons:Load("gfx/modjam_v3/ui/eid cards.anm2", true)



EID:addCard
(
    ModJamV3.Cards.BlueSlime.CARD_TYPE,
    "{{Timer}} Receive for 15 seconds:#Killed enemies drop random pickups",
    "Blue Slime",
    "en_us"
)
EID:addIcon("Card"..ModJamV3.Cards.BlueSlime.CARD_TYPE, "Cards", 4, 8, 8, 0, 1, eidIcons)


EID:addCard
(
    ModJamV3.Cards.DirtBlock.CARD_TYPE,
    "Spawns a tinted rock near Isaac",
    "Dirt Block",
    "en_us"
)
EID:addIcon("Card"..ModJamV3.Cards.DirtBlock.CARD_TYPE, "Cards", 0, 8, 8, 0, 1, eidIcons)


EID:addCard
(
    ModJamV3.Cards.Megashark.CARD_TYPE,
    "Grants a burst of tears that depletes when Isaac shoots",
    "Megashark",
    "en_us"
)
EID:addIcon("Card"..ModJamV3.Cards.Megashark.CARD_TYPE, "Cards", 6, 8, 8, 0, 1, eidIcons)


EID:addCard
(
    ModJamV3.Cards.TheOldMan.CARD_TYPE,
    "{{CurseBlind}} Applies a random curse for the floor#{{Collectible260}} The next floor will have no curses#Clearing the majority of the floor before using the card only has a chance to prevent curses",
    "The Old Man",
    "en_us"
)
EID:addIcon("Card"..ModJamV3.Cards.TheOldMan.CARD_TYPE, "Cards", 3, 8, 8, 0, 1, eidIcons)


EID:addCard
(
    ModJamV3.Cards.Werewolf.CARD_TYPE,
    "Isaac knocks back nearby enemies#{{Fear}} Fears all enemies in the room for 4 seconds#{{Timer}} Receive for 30 seconds:#↑ {{Speed}} +0.1 Speed#↑ {{Tears}} +0.3 Tears#↑ {{Damage}} +1 Damage#↑ {{Shotspeed}} +0.16 Shot speed#Doubles all damage taken",
    "Werewolf",
    "en_us"
)
EID:addIcon("Card"..ModJamV3.Cards.Werewolf.CARD_TYPE, "Cards", 5, 8, 8, 0, 1, eidIcons)


EID:addCard
(
    ModJamV3.Cards.Wraith.CARD_TYPE,
    "{{HalfBlackHeart}} +1 half Black Heart#{{Timer}} Receive for the room:#Spectral tears#Flight#{{Collectible468}} 2 Shade familiars",
    "Wraith",
    "en_us"
)
EID:addIcon("Card"..ModJamV3.Cards.Wraith.CARD_TYPE, "Cards", 5, 8, 8, 0, 1, eidIcons)


EID:addCard
(
    ModJamV3.Cards.Wyvern.CARD_TYPE,
    "{{Timer}} Receive for the room:#↑ {{Luck}} +8 Luck",
    "Wyvern",
    "en_us"
)
EID:addIcon("Card"..ModJamV3.Cards.Wyvern.CARD_TYPE, "Cards", 1, 8, 8, 0, 1, eidIcons)

