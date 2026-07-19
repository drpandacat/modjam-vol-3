if not EID then return end

local mod = CardJam_AeroTruji

local descs = {
    [mod.Enums.POLYMERIZATION] = "Destroys every consumable ({{Pill}} pills, {{Card}} cards, and {{Rune}} runes) in the room, then spawns an Amalgam consumable #Amalgam activates the effect of every consumable destroyed",
    [mod.Enums.AMALGAM] = "Activates the effect of every consumable destroyed by Polymerization #The stored effects are removed after being used",
    [mod.Enums.IJIRAQ] = "Spawns a permanently charmed Dople for the current room #The Dople shoots copies of the player's tears and has a high amount of HP",
    [mod.Enums.PUNCH_CARD] = "Teleports the player to a special room that hasn't been visited on the current floor #Priority: {{Planetarium}} > {{TreasureRoom}} > {{SuperSecretRoom}} > {{BossRoom}} #If all rooms have been visited, teleports the player to a special room on the next floor instead",
    [mod.Enums.MAGNETIC_CARD] = "Attracts pickups and enemies towards the direction the player is looking #Enemies get {{Magnetize}} Magnetized for 5 seconds and take damage upon colliding with grids or other enemies #Attracted pickups can go over rocks and pits for 1 second"
}

for i, v in pairs(descs) do
    EID:addCard(i, v)
end

EID:addCollectible(mod.Enums.DUELLING_DISK, "{{Card}} Spawns a random card on pickup #Allows the player to throw their held card in the direction they fire, dealing damage to enemies #The card respawns after hitting an enemy or the wall/ground #Different cards may activate additional effects")

local consumeText1, consumeText2 = "#{{ColorCyan}}{{Warning}} Does not respawn!{{CR}}", "#{{ColorCyan}}{{Warning}} Chance to not respawn!{{CR}}"
local ddSynergyDescs = {
    [Card.CARD_FOOL] = "Less damage, inflicts {{Confusion}} Confusion",
    [Card.CARD_MAGICIAN] = "Homing",
    [Card.CARD_HIGH_PRIESTESS] = "Chance to spawn a Mom stomp",
    [Card.CARD_EMPRESS] = "Higher damage and shot speed",
    [Card.CARD_HIEROPHANT] = ("Chance to spawn a {{Collectible%d}} light beam"):format(CollectibleType.COLLECTIBLE_HOLY_LIGHT),
    [Card.CARD_LOVERS] = "Inflicts {{Charm}} Charm",
    [Card.CARD_CHARIOT] = "Higher shot speed, piercing",
    [Card.CARD_JUSTICE] = "Less damage, spawns 4 piercing tears on hit",
    [Card.CARD_HERMIT] = ("Chance to freeze an enemy into {{Collectible%d}} gold"):format(CollectibleType.COLLECTIBLE_MIDAS_TOUCH),
    [Card.CARD_WHEEL_OF_FORTUNE] = "Random damage and tear effects",
    [Card.CARD_STRENGTH] = "Higher damage, knocks back enemies",
    [Card.CARD_HANGED_MAN] = "Spawns 2 Blue Flies or Blue Spiders",
    [Card.CARD_DEATH] = ("Its damage is dealt in a small radius around the hit enemy #{{ColorCyan}}Higher damage if the player has {{Collectible%d}}{{Trinket%d}} Missing Page{{CR}}"):format(CollectibleType.COLLECTIBLE_MISSING_PAGE_2, TrinketType.TRINKET_MISSING_PAGE),
    [Card.CARD_TEMPERANCE] = "Spawns red creep",
    [Card.CARD_DEVIL] = "Higher damage",
    [Card.CARD_TOWER] = "Explodes with the player's bomb effects",
    [Card.CARD_STARS] = "Rare chance to spawn a {{Card}} card",
    [Card.CARD_MOON] = "Less shot speed, inflicts {{Slow}} Slow",
    [Card.CARD_SUN] = "Less damage, its damage is dealt to all enemies in the room",

    [Card.CARD_CLUBS_2] = "+2 {{Bomb}} bombs"..consumeText2,
    [Card.CARD_DIAMONDS_2] = "+2 {{Coin}} coins"..consumeText2,
    [Card.CARD_SPADES_2] = "+2 {{Key}} keys"..consumeText2,
    [Card.CARD_HEARTS_2] = "+2 {{Heart}} hearts"..consumeText2,
    [Card.CARD_ACE_OF_CLUBS] = "Turns a non-boss enemy into a {{Bomb}} bomb"..consumeText2,
    [Card.CARD_ACE_OF_DIAMONDS] = "Turns a non-boss enemy into a {{Coin}} coin"..consumeText2,
    [Card.CARD_ACE_OF_SPADES] = "Turns a non-boss enemy into a {{Key}} key"..consumeText2,
    [Card.CARD_ACE_OF_HEARTS] = "Turns a non-boss enemy into a {{Heart}} heart"..consumeText2,
    [Card.CARD_JOKER] = ("Spawns a {{Collectible%d}} black brimstone ring or 4 light beams in a cross formation"):format(CollectibleType.COLLECTIBLE_MAW_OF_THE_VOID),

    [Card.CARD_CHAOS] = "Instantly kills enemies, except Delirium or The Beast #{{ColorCyan}}Creates a Giga Bomb explosion{{CR}}"..consumeText1,
    [Card.CARD_HUMANITY] = "Spawns 2 poops, chance to turn a non-boss enemy into a poop",
    [Card.CARD_SUICIDE_KING] = "Very high damage, spawns an item from the current pool, a {{Chest}} chest, and a few pickups"..consumeText1,
    [Card.CARD_GET_OUT_OF_JAIL] = "Opens all doors in the room",
    [Card.CARD_HOLY] = ("{{Collectible%d}} Homing, has an aura that deals damage"):format(CollectibleType.COLLECTIBLE_GODHEAD),
    [Card.CARD_HUGE_GROWTH] = "Much higher damage, less shot speed, piercing, higher tear size",
    [Card.CARD_ANCIENT_RECALL] = "Much higher damage, instead of respawning, spawns 3 random {{Card}} cards",
    [Card.CARD_ERA_WALK] = "Much higher damage, very slow shot speed, piercing, infinite range",

    [Card.CARD_REVERSE_FOOL] = "Subtracts up to 5 of each held pickup in exchange for additional damage, pickups are granted back if the card hits an enemy",
    [Card.CARD_REVERSE_MAGICIAN] = "Reflects nearby projectiles and knockbacks nearby enemies",
    [Card.CARD_REVERSE_EMPRESS] = "Inflicts {{BleedOut}} Bleeding",
    [Card.CARD_REVERSE_HIEROPHANT] = "Splits into two bone shards",
    [Card.CARD_REVERSE_LOVERS] = "Deals additional damage equal to 1/12 of the enemy's max HP (up to 100)",
    [Card.CARD_REVERSE_CHARIOT] = "Recharges Duelling Disk upon hitting an enemy",
    [Card.CARD_REVERSE_JUSTICE] = "Spawns and opens a random chest"..consumeText2,
    [Card.CARD_REVERSE_WHEEL_OF_FORTUNE] = ("{{Collectible%d}} Devolves the enemy, rerolls the enemy, or {{Collectible%d}} restarts the room"):format(CollectibleType.COLLECTIBLE_D10, CollectibleType.COLLECTIBLE_D7),
    [Card.CARD_REVERSE_STRENGTH] = "Inflicts {{Weakness}} Weakness",
    [Card.CARD_REVERSE_HANGED_MAN] = "Less damage, triple shot",
    [Card.CARD_REVERSE_DEATH] = "Spawns 2 Bone Orbitals",
    [Card.CARD_REVERSE_DEVIL] = "Higher damage, lower shot speed, homing",
    [Card.CARD_REVERSE_TOWER] = "Deals 0 damage, spawns a circular rock wave",
    [Card.CARD_REVERSE_STARS] = "Very rare chance to spawn an item from the current room pool",
    [Card.CARD_REVERSE_SUN] = "Higher damage, inflicts {{Fear}} Fear",

    [mod.Enums.POLYMERIZATION] = "Damage is dealt to all enemies in the room and increases based on how many enemies there are",
    [mod.Enums.IJIRAQ] = "Less damage, spawns a friendly copy of the enemy for the current room (excludes bosses)",
    [mod.Enums.MAGNETIC_CARD] = "Inflicts {{Magnetize}} Magnetized"
}

for card, desc in pairs(ddSynergyDescs) do
    EID:addCondition("5.300."..card, mod.Enums.DUELLING_DISK, "{{ColorCyan}}"..desc.."{{CR}}")
end
EID:addCondition(mod.Enums.DUELLING_DISK, CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES, "Spawns a wisp where the card lands, the wisp's tears have the tear effects of the thrown card's Duelling Disk synergy")