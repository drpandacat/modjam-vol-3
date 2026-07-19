-- sorry no entityptr for scheudle ALSO oops coop compat i dont have time

---@param MOD ModReference
return function (MOD)
    local t = {}

    t.ID = Isaac.GetCardIdByName("Red Card with White Question Mark in the Middle and a Border is Present and White Too")
    t.GIANTBOOK = Isaac.GetGiantBookIdByName("pasue the flipping game im card")
    t.Active = false
    t.SPRITE = Sprite("gfx/ui/prompt_yesno.anm2", true)
    t.SPRITE:Play("Appear", true)
    t.SPRITE:GetLayer("Text"):SetVisible(false)
    t.SPRITE:GetLayer("Cursor"):SetVisible(false)
    t.SPRITE:ReplaceSpritesheet(0, "gfx/ui/prompt_yesnowithoutyesno.png", true)
    t.SPRITE_CURSOR = Sprite("gfx/ui/prompt_yesno.anm2", true)
    t.SPRITE_CURSOR:Play("Idle", true)
    t.SPRITE_CURSOR:GetLayer(0):SetVisible(false)
    t.SPRITE_CURSOR:GetLayer("Text"):SetVisible(false)
    t.FONT = Font()
    t.FONT:Load("font/teammeatex/teammeatex12.fnt")
    t.FONT_BIG = Font()
    t.FONT_BIG:Load("font/teammeatex/teammeatex16.fnt")
    t.KCOLOR_FONT = KColor(54 / 255, 47 / 255, 45 / 255, 1)
    t.QuestionData = {}
    ---@type string
    t.QuestionText = nil
    ---@type string[]
    t.AnswerText = nil
    ---@type integer
    t.Question = nil
    t.AnswerIndex = 1
    t.MaxAnswerIndex = 1
    t.NULL_FIGHT = Isaac.GetNullItemIdByName("I like hurt people")
    t.NULL_FLIGHT = Isaac.GetNullItemIdByName("I don't like hurt people")
    t.NULL_ASBESTOS = Isaac.GetNullItemIdByName("Some Asbestos")
    t.COSTUME_JAVON = Isaac.GetCostumeIdByPath("gfx/characters/costume_javon.anm2")

    ---@class Question
    ---@field Init? fun(player: EntityPlayer)
    ---@field Weight? integer | fun(player: EntityPlayer): integer?
    ---@field Text string | fun(player: EntityPlayer): string
    ---@field Answers Answer[] --| fun(player: EntityPlayer): Answer[]

    ---@class Answer
    ---@field Text string | fun(player: EntityPlayer): string
    ---@field Outcome fun(player: EntityPlayer)

    -- t.QUESTION_FORCE = 11

    ---@param item ItemConfigItem
    function t:GetItemName(item)
        if item.ID >= CollectibleType.NUM_COLLECTIBLES then
            return item.Name
        end
        return Isaac.GetLocalizedString("Items", item.Name, Options.Language)
    end

    ---@type Question[]
    t.QUESTIONS = {
        {
            Weight = 1,
            Text = "Do you have a girlfriend?",
            Answers = {
                {
                    Text = "Yes",
                    Outcome = function (player)
                        MOD.SFX:Play(SoundEffect.SOUND_SATAN_GROW, 0, 30)
                        player:UseActiveItem(CollectibleType.COLLECTIBLE_MONSTER_MANUAL, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_NOHUD)
                        player:AnimateHappy()
                    end
                },
                {
                    Text = "No",
                    Outcome = function (player)
                        player:AddInnateCollectible(CollectibleType.COLLECTIBLE_DEPRESSION, nil, "DHMIS_FLOOR")
                        player:AnimateSad()
                    end
                }
            }
        },
        {
            Weight = 1,
            Text = "Do you like hurting other people?",
            Answers = {
                {
                    Text = "Yes",
                    Outcome = function (player)
                        player:AddNullItemEffect(t.NULL_FIGHT)
                        for _, v in ipairs(Isaac.GetRoomEntities()) do
                            if v:IsEnemy() and not v:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
                                v:AddFear(EntityRef(player), 30 * 5)
                            end
                        end
                        MOD.SFX:Play(SoundEffect.SOUND_SATAN_GROW, nil, nil, nil, 3)
                        player:PlayExtraAnimation("Jump")
                    end
                },
                {
                    Text = "No",
                    Outcome = function (player)
                        player:AddEternalHearts(1)
                        -- MOD.SFX:Play(SoundEffect.SOUND_SUPERHOLY)
                        player:AnimateHappy()
                    end
                },
            }
        },
        {
            Weight = function (player)
                for id, count in pairs(player:GetCollectiblesList()) do
                    if count > 0 then
                        local config = MOD.CONFIG:GetCollectible(id)
                        if config and not config:HasTags(ItemConfig.TAG_QUEST) then
                            return 1
                        end
                    end
                end
                return 0
            end,
            Init = function (player)
                local rng = player:GetCardRNG(t.ID)
                ---@type ItemConfigItem[]
                local items = {}
                for id, count in pairs(player:GetCollectiblesList()) do
                    if count > 0 then
                        local config = MOD.CONFIG:GetCollectible(id)
                        if config and not config:HasTags(ItemConfig.TAG_QUEST) then
                            for _ = 1, count do
                                items[#items + 1] = config
                            end
                        end
                    end
                end
                t.QuestionData.TastyItem = items[rng:RandomInt(1, #items)]
                t.QuestionData.TastyPrice = (t.QuestionData.TastyItem.Quality + 1) * 4
            end,
            Text = function (player)
                local name = t:GetItemName(t.QuestionData.TastyItem)
                if name:sub(1, 4) == "The " then
                    name = name:sub(5, #name)
                elseif name:sub(1, 2) == "A " then
                    name = name:sub(3, #name)
                end
                return "Would you sell that " .. name .. " of yours for " .. t.QuestionData.TastyPrice .. "¢?"
            end,
            Answers = {
                {
                    Text = "Yup!",
                    Outcome = function (player)
                        MOD.SFX:Play(SoundEffect.SOUND_CASH_REGISTER)
                        player:RemoveCollectible(t.QuestionData.TastyItem.ID)
                        local room = MOD.GAME:GetRoom()
                        Isaac.Spawn(
                            EntityType.ENTITY_EFFECT,
                            EffectVariant.POOF01,
                            0,
                            player.Position,
                            Vector.Zero,
                            nil
                        )
                        MOD.SFX:Play(286, 0.8)
                        for i = 1, t.QuestionData.TastyPrice do
                            local pickup = Isaac.Spawn(
                                EntityType.ENTITY_PICKUP,
                                PickupVariant.PICKUP_COIN,
                                CoinSubType.COIN_PENNY,
                                room:FindFreePickupSpawnPosition(player.Position, 40),
                                Vector.Zero,
                                nil
                            ):ToPickup()
                            pickup:SetDropDelay(i - 1)
                        end
                    end
                },
                {
                    Text = "No way buddy!",
                    Outcome = function (player)
                        MOD.HUD:ShowItemText("Now I'm angry!")
                        MOD.SFX:Play(SoundEffect.SOUND_THUMBS_DOWN)
                        local pos = t:GetRandomPos()
                        local npc = Isaac.Spawn(
                            EntityType.ENTITY_KEEPER,
                            0,
                            0,
                            pos,
                            Vector.Zero,
                            nil
                        ):ToNPC()
                        local rng = RNG(npc.InitSeed)
                        -- npc:MakeChampion(npc.InitSeed, ChampionColorIdx.GIANT)
                        npc:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
                        for _ = 1, 2 do
                            Isaac.Spawn(
                                EntityType.ENTITY_FLY,
                                0,
                                0,
                                npc.Position + rng:RandomVector():Resized(40),
                                Vector.Zero,
                                nil
                            )
                        end
                    end
                },
            }
        },
        {
            Text = "What's 9 + 10?",
            Weight = 1,
            Answers = {
                {
                    Text = "19",
                    Outcome = function (player)
                        player:AddInnateCollectible(CollectibleType.COLLECTIBLE_THE_WIZ, nil, "DHMIS_FLOOR")
                        MOD.SFX:Play(SoundEffect.SOUND_DERP)
                    end
                },
                {
                    Text = "21",
                    Outcome = function (player)
                        player:AddInnateCollectible(CollectibleType.COLLECTIBLE_MIND, nil, "DHMIS_FLOOR")
                        MOD.LEVEL:ApplyBlueMapEffect()
                        MOD.LEVEL:ApplyCompassEffect(true)
                        MOD.LEVEL:ApplyMapEffect()
                        MOD.SFX:Play(SoundEffect.SOUND_THUMBSUP)
                    end
                }
            }
        },
        {
            Text = "Would you like to do a victory lap!?",
            Weight = 1,
            Answers = {
                {
                    Text = "Yes",
                    Outcome = function (player)
                        player:UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW, UseFlag.USE_NOANIM)
                    end
                },
                {
                    Text = "No",
                    Outcome = function (player)
                        Isaac.Spawn(
                            EntityType.ENTITY_PICKUP,
                            PickupVariant.PICKUP_LOCKEDCHEST,
                            0,
                            MOD.GAME:GetRoom():FindFreePickupSpawnPosition(player.Position, 40),
                            Vector.Zero,
                            nil
                        )
                    end
                }
            }
        },
        {
            Text = 'In the Sega Saturn video game "Zoop" collecting 5 spring powerups does what?',
            Weight = 1,
            Answers = {
                {
                    Text = "Full clears the board",
                    Outcome = function (player)
                        MOD.GAME:GetRoom():MamaMegaExplosion(player.Position, player)
                    end
                },
                {
                    Text = "Grants an extra life",
                    Outcome = function (player)
                        player:AnimateCollectible(CollectibleType.COLLECTIBLE_1UP)
                        MOD.SFX:Play(SoundEffect.SOUND_1UP)
                        MOD.HUD:ShowItemText(player, MOD.CONFIG:GetCollectible(CollectibleType.COLLECTIBLE_1UP))
                        Isaac.CreateTimer(function ()
                            local flags = player:GetBombFlags()
                            MOD.GAME:BombExplosionEffects(
                                player.Position,
                                50,
                                flags,
                                nil,
                                player,
                                nil,
                                nil,
                                true
                            )
                            MOD.HUD:ShowItemText("JK")
                        end, 35, 1, true)
                    end
                }
            }
        },
        {
            Text = "Do I find ur mom funny",
            Weight = 1,
            Answers = {
                {
                    Text = "I still don't know",
                    Outcome = function (player)
                        player:UsePill(PillEffect.PILLEFFECT_QUESTIONMARK, PillColor.PILL_BLUE_BLUE, UseFlag.USE_NOANIM)
                        player:AddInnateCollectible(CollectibleType.COLLECTIBLE_GLAUCOMA, nil, "DHMIS_FLOOR", nil, false)
                    end
                },
                {
                    Text = "Have it ur way",
                    Outcome = function (player)
                        MOD.SFX:Play(SoundEffect.SOUND_BAND_AID_PICK_UP)
                        Isaac.Spawn(
                            EntityType.ENTITY_EFFECT,
                            EffectVariant.SPEAR_OF_DESTINY,
                            0,
                            player.Position,
                            Vector.Zero,
                            nil
                        )
                        Isaac.Spawn(
                            EntityType.ENTITY_PICKUP,
                            0,
                            0,
                            Vector.Zero,
                            Vector.Zero,
                            nil
                        )
                        player:AnimateCollectible(CollectibleType.COLLECTIBLE_REMOTE_DETONATOR, "UseItem")
                        local room = MOD.GAME:GetRoom()
                        local pos = player.Position + Vector(80, 0)
                        if room:CanSpawnObstacleAtPosition(room:GetGridIndex(pos), false) then
                            Isaac.GridSpawn(GridEntityType.GRID_ROCK_BOMB, 0, pos)
                        end
                        room:SetBackdropType(room:GetBackdropType(), 1)
                        player.Position = player.Position + Vector(5, 5)
                        MOD.GAME.TimeCounter = MOD.GAME.TimeCounter - 30 * 5
                        player.MoveSpeed = player.MoveSpeed + math.random() * 0.2
                        player.ControlsCooldown = 30
                        local roll = player:GetCardRNG(t.ID):RandomInt(1, 3)
                        if roll == 1 then
                            player:AddCoins(1)
                        elseif roll == 2 then
                            player:AddBombs(1)
                        elseif roll == 3 then
                            player:AddKeys(1)
                        end
                    end
                },
                {
                    Text = "No",
                    Outcome = function (player)
                        local items = MOD.CONFIG:GetTaggedItems(ItemConfig.TAG_MOM)
                        items = MOD:Filter(items, function (v)
                            return v:IsAvailable()
                            and v.Type ~= ItemType.ITEM_TRINKET
                            and v.Type ~= ItemType.ITEM_NULL
                            and v.Type ~= ItemType.ITEM_ACTIVE
                        end)
                        if #items == 0 then return end
                        local item = items[player:GetCardRNG(t.ID):RandomInt(1, #items)]
                        MOD.HUD:ShowItemText(player, item, false)
                        MOD.SFX:Play(SoundEffect.SOUND_POWERUP1)
                        player:AnimateCollectible(item.ID)
                        player:AddInnateCollectible(item.ID, nil, "DHMIS_FLOOR")
                    end
                },
                {
                    Text = "Yeah she fat hahahha",
                    Outcome = function (player)
                        MOD.SFX:Play(84)
                        player:UseCard(Card.CARD_REVERSE_HIGH_PRIESTESS, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
                    end
                },
            }
        },
        {
            Text = "Do you believe in God?",
            Weight = function ()
                return MOD.LEVEL:CanSpawnDevilRoom() and 1 or 0
            end,
            Answers = {
                {
                    Text = "Yes",
                    Outcome = function (player)
                        MOD.GAME:SetStateFlag(GameStateFlag.STATE_DEVILROOM_VISITED, false)
                        MOD.LEVEL:AddAngelRoomChance(1)
                        MOD.LEVEL:SetStateFlag(LevelStateFlag.STATE_BUM_KILLED, true)
                        MOD.LEVEL:SetStateFlag(LevelStateFlag.STATE_REDHEART_DAMAGED, false)
                        MOD.SFX:Play(SoundEffect.SOUND_CHOIR_UNLOCK)
                    end
                },
                {
                    Text = "No",
                    Outcome = function (player)
                        MOD.GAME:SetStateFlag(GameStateFlag.STATE_DEVILROOM_VISITED, true)
                        MOD.GAME:AddDevilRoomDeal()
                        MOD.LEVEL:AddAngelRoomChance(-MOD.LEVEL:GetAngelRoomChance())
                        MOD.LEVEL:SetStateFlag(LevelStateFlag.STATE_BUM_KILLED, true)
                        MOD.LEVEL:SetStateFlag(LevelStateFlag.STATE_REDHEART_DAMAGED, false)
                        MOD.SFX:Play(SoundEffect.SOUND_UNHOLY)
                    end
                }
            }
        },
        {
            Text = "Would you still love me if I were a worm?",
            Weight = 1,
            Answers = {
                {
                    Text = "Yes I would you love the same!",
                    Outcome = function (player)
                        if player:GetCardRNG(t.ID):RandomInt(1, 2) == 1 then
                            local npc = Isaac.Spawn(
                                EntityType.ENTITY_NERVE_ENDING,
                                0,
                                0,
                                player.Position,
                                Vector.Zero,
                                player
                            )
                            npc:AddCharmed(EntityRef(player), -1)
                        else
                            player:AddInnateCollectible(CollectibleType.COLLECTIBLE_WORM_FRIEND, nil, nil, 30 * 60 * 2.5 // 1)
                        end
                        MOD.SFX:Play(SoundEffect.SOUND_KISS_LIPS1)
                        player:GetEffects():RemoveNullEffect(t.NULL_ASBESTOS, 2)
                    end
                },
                {
                    Text = "No I am rotten inside like a moldy mango",
                    Outcome = function (player)
                        local room = MOD.GAME:GetRoom()
                        for i = 1, 1 do
                            local pickup = Isaac.Spawn(
                                EntityType.ENTITY_PICKUP,
                                PickupVariant.PICKUP_HEART,
                                HeartSubType.HEART_ROTTEN,
                                room:FindFreePickupSpawnPosition(player.Position, 40),
                                Vector.Zero,
                                nil
                            ):ToPickup()
                            pickup:SetDropDelay(i - 1)
                        end
                        MOD.SFX:Play(SoundEffect.SOUND_BLOBBY_WIGGLE)
                        player:GetEffects():AddNullEffect(t.NULL_ASBESTOS, nil, 25)
                    end
                }
            }
        },
        {
            Text = "Would you rather find a dead body, or 1,000,000 spiders in your attic?",
            Weight = 1,
            Answers = {
                {
                    Text = "Body",
                    Outcome = function (player)
                        local room = MOD.GAME:GetRoom()
                        local shopkeeper = Isaac.Spawn(
                            EntityType.ENTITY_SHOPKEEPER,
                            0,
                            0,
                            room:FindFreePickupSpawnPosition(player.Position, 40),
                            Vector.Zero,
                            nil
                        )
                        local rng = RNG(shopkeeper.InitSeed)
                        for _ = 1, 2 do
                            Isaac.Spawn(
                                EntityType.ENTITY_FLY,
                                0,
                                0,
                                room:FindFreePickupSpawnPosition(shopkeeper.Position + rng:RandomVector():Resized(60), 0, true, true),
                                Vector.Zero,
                                nil
                            )
                        end
                        Isaac.Spawn(
                            EntityType.ENTITY_PICKUP,
                            PickupVariant.PICKUP_TAROTCARD,
                            MOD.CARD_BLUE_ASBESTOS.ID,
                            room:FindFreePickupSpawnPosition(shopkeeper.Position + Vector(0, 40)),
                            Vector.Zero,
                            nil
                        )
                        shopkeeper:Update()
                        MOD.SFX:Play(SoundEffect.SOUND_SUMMONSOUND)
                    end
                },
                {
                    Text = "Spiders",
                    Outcome = function (player)
                        local rng = player:GetCardRNG(t.ID)
                        for i = 1, 100 do
                            Isaac.CreateTimer(function ()
                                if rng:RandomFloat() < 0.25 then
                                    EntityNPC.ThrowSpider(
                                        player.Position,
                                        nil,
                                        player.Position + rng:RandomVector():Resized(40 * 4),
                                        false,
                                        0
                                    )
                                else
                                    player:ThrowBlueSpider(player.Position, player.Position + rng:RandomVector():Resized(40 * 4))
                                end
                                MOD.SFX:Play(SoundEffect.SOUND_SPIDER_COUGH, nil, nil, nil, 1 + (i - 1) * 0.002)
                            end, i, 1, true)
                        end
                    end
                }
            }
        },
        {
            Text = "What would your super power be?",
            Weight = 1,
            Answers = {
                {
                    Text = "Flight",
                    Outcome = function (player)
                        MOD.SFX:Play(SoundEffect.SOUND_POWERUP1)
                        player:AddInnateCollectible(CollectibleType.COLLECTIBLE_HOLY_GRAIL, nil, nil, 30 * 60)
                    end
                },
                {
                    Text = "Teleportation",
                    Outcome = function (player)
                        local cards = {
                            Card.CARD_FOOL,
                            Card.CARD_EMPEROR,
                            Card.CARD_HERMIT,
                            Card.CARD_STARS,
                            Card.CARD_MOON,
                        }
                        for i, v in ipairs(cards) do
                            local pickup = Isaac.Spawn(
                                EntityType.ENTITY_PICKUP,
                                PickupVariant.PICKUP_TAROTCARD,
                                v,
                                player.Position + Vector.FromAngle(360 / #cards * (i - 1)):Resized(60),
                                Vector.Zero,
                                nil
                            ):ToPickup()
                            pickup:SetDropDelay(i - 1)
                        end
                    end
                },
                {
                    Text = "Laser vision",
                    Outcome = function (player)
                        MOD.SFX:Play(SoundEffect.SOUND_POWERUP1)
                        player:AddInnateCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY, nil, nil, 30 * 60)
                    end
                },
                {
                    Text = "Time travel",
                    Outcome = function (player)
                        player:UseActiveItem(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS)
                    end
                },
                {
                    Text = "Mango",
                    Outcome = function (player)
                        MOD.CARD_PHONK.Confetti(Vector(Isaac.GetScreenWidth() / 2, -32), 0)
                    end
                },
            }
        },
        {
            Text = "Which is your poison?",
            Weight = 1,
            Init = function (player)
                local items = {}
                for i = 1, MOD.CONFIG:GetCollectibles().Size - 1 do
                    local item = MOD.CONFIG:GetCollectible(i)
                    if item and item:IsAvailable() and item.Type ~= ItemType.ITEM_ACTIVE
                    and item.Quality >= 2
                    then
                        items[#items + 1] = item
                    end
                end
                t.QuestionData.PoisonItems = {}
                local rng = player:GetCardRNG(t.ID)
                for _ = 1, 4 do
                    t.QuestionData.PoisonItems[#t.QuestionData.PoisonItems + 1]
                    = table.remove(items, rng:RandomInt(1, #items))
                end
            end,
            Answers = {
                {
                    Text = function (player)
                        return t:GetItemName(t.QuestionData.PoisonItems[1])
                    end,
                    Outcome = function (player)
                        MOD.SFX:Play(SoundEffect.SOUND_POWERUP1)
                        player:AddInnateCollectible(t.QuestionData.PoisonItems[1].ID, nil, nil, 30 * 60 * 2.5 // 1)
                    end
                },
                {
                    Text = function (player)
                        return t:GetItemName(t.QuestionData.PoisonItems[2])
                    end,
                    Outcome = function (player)
                        MOD.SFX:Play(SoundEffect.SOUND_POWERUP1)
                        player:AddInnateCollectible(t.QuestionData.PoisonItems[2].ID, nil, nil, 30 * 60 * 2.5 // 1)
                    end
                },
                {
                    Text = function (player)
                        return t:GetItemName(t.QuestionData.PoisonItems[3])
                    end,
                    Outcome = function (player)
                        MOD.SFX:Play(SoundEffect.SOUND_POWERUP1)
                        player:AddInnateCollectible(t.QuestionData.PoisonItems[3].ID, nil, nil, 30 * 60 * 2.5 // 1)
                    end
                },
            }
        },
        {
            Text = "0 ÷ 0 = ?",
            Weight = 1,
            Answers = {
                {
                    Text = "Something absolutely incredible",
                    Outcome = function (player)
                        Isaac.Spawn(
                            EntityType.ENTITY_PICKUP,
                            PickupVariant.PICKUP_COLLECTIBLE,
                            ProceduralItemManager.CreateProceduralItem(player:GetCardRNG(t.ID):Next(), 0),
                            MOD.GAME:GetRoom():FindFreePickupSpawnPosition(player.Position, 40),
                            Vector.Zero,
                            nil
                        ):AddEntityFlags(EntityFlag.FLAG_GLITCH)
                        MOD.SFX:Play(SoundEffect.SOUND_EDEN_GLITCH)
                    end
                },
                {
                    Text = "Somewhere brand new",
                    Outcome = function (player)
                        MOD.GAME:StartRoomTransition(
                            GridRooms.ROOM_ERROR_IDX,
                            Direction.NO_DIRECTION,
                            RoomTransitionAnim.TELEPORT
                        )
                        MOD.SFX:Play(SoundEffect.SOUND_EDEN_GLITCH)
                    end
                },
                {
                    Text = "Something that will crash the game",
                    Outcome = function (player)
                        MOD.SFX:Play(SoundEffect.SOUND_EDEN_GLITCH)
                        Isaac.ExecuteCommand("fullrestart")
                    end
                },
                {
                    Text = "Someone familiar",
                    Outcome = function (player)
                        player:AddNullCostume(t.COSTUME_JAVON)
                        MOD.SFX:Play(SoundEffect.SOUND_EDEN_GLITCH)
                        player:PlayExtraAnimation("Glitch")
                        player:AddCoins(3)
                        local charge = player:GetActiveCharge() / player:GetActiveMaxCharge(ActiveSlot.SLOT_PRIMARY)
                        player:RemoveCollectible(player:GetActiveItem(), nil, ActiveSlot.SLOT_PRIMARY)
                        player:AddCollectible(CollectibleType.COLLECTIBLE_DECK_OF_CARDS, math.ceil(charge * 6))
                    end
                }
            }
        },
        {
            Text = "What would your last meal be?",
            Weight = 1,
            Init = function (player)
                t.QuestionData.LastMeal = MOD.GAME:GetItemPool():GetTrinket()
            end,
            Answers = {
                {
                    Text = "A juicy burger",
                    Outcome = function (player)
                        MOD.SFX:Play(SoundEffect.SOUND_ANIMAL_SQUISH)
                        MOD.SFX:Play(SoundEffect.SOUND_BOSS2_DIVE)
                        local room = MOD.GAME:GetRoom()
                        local gridSize = room:GetGridSize()
                        local rng = player:GetCardRNG(t.ID)
                        for i = 0, gridSize do
                            local grid = room:GetGridEntity(i)
                            if not grid and rng:RandomFloat() < 0.2 then
                                room:SpawnGridEntity(i, GridEntityType.GRID_SPIDERWEB)
                            end
                        end
                        for _ = 1, 30 * (gridSize / MOD.DEFAULT_GRID_SIZE) do
                            local creep = Isaac.Spawn(
                                EntityType.ENTITY_EFFECT,
                                EffectVariant.PLAYER_CREEP_WHITE,
                                0,
                                Isaac.GetRandomPosition(),
                                Vector.Zero,
                                player
                            )
                            creep.SpriteScale = creep.SpriteScale * (1 + RNG(creep.InitSeed):RandomFloat() * 3)
                            creep:Update()
                            creep:ToEffect().Timeout = 30 * 60
                        end
                        player:AddInnateCollectible(CollectibleType.COLLECTIBLE_JUICY_SACK, nil, "DHMIS_FLOOR")
                    end
                },
                {
                    Text = "Delicious steak",
                    Outcome = function (player)
                        player:AddHearts(player:GetEffectiveMaxHearts() - player:GetHearts())
                        MOD.SFX:Play(SoundEffect.SOUND_VAMP_GULP)
                        local effect = Isaac.Spawn(
                            EntityType.ENTITY_EFFECT,
                            EffectVariant.HEART,
                            0,
                            player.Position,
                            Vector.Zero,
                            nil
                        )
                        effect.DepthOffset = 10
                        effect.SpriteOffset = Vector(0, -16)
                        for i = 1, 2 do
                            local pos = t:GetRandomPos()
                            local npc = Isaac.Spawn(
                                EntityType.ENTITY_GYRO,
                                0,
                                0,
                                pos,
                                Vector.Zero,
                                nil
                            ):ToNPC()
                            npc:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
                        end
                    end
                },
                {
                    Text = function (player)
                        return t:GetItemName(MOD.CONFIG:GetTrinket(t.QuestionData.LastMeal))
                    end,
                    Outcome = function (player)
                        player:AddSmeltedTrinket(t.QuestionData.LastMeal)
                        MOD.SFX:Play(SoundEffect.SOUND_VAMP_GULP)
                    end
                },
                {
                    Text = "10 Whoppers",
                    Outcome = function (player)
                        MOD.SFX:Play(SoundEffect.SOUND_WHEEZY_COUGH)
                        local rng = player:GetCardRNG(t.ID)
                        for _ = 1, 10 do
                            local dip = Isaac.Spawn(
                                EntityType.ENTITY_SKINNY,
                                0,
                                0,
                                player.Position,
                                rng:RandomVector():Resized(rng:RandomFloat() * 30),
                                player
                            )
                            dip:AddKnockback(EntityRef(player), dip.Velocity, 30, false)
                            dip:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                            dip.HitPoints = 1
                            dip:AddCharmed(EntityRef(player), -1)
                        end
                    end
                }
            }
        },
        {
            Text = "Which would you choose?",
            Weight = 1,
            Answers = {}
        },
        {
            Text = "Try that again?",
            Weight = 1,
            Answers = {
                {
                    Text = "Yes",
                    Outcome = function (player)
                        Isaac.Spawn(
                            EntityType.ENTITY_PICKUP,
                            PickupVariant.PICKUP_TAROTCARD,
                            t.ID,
                            MOD.GAME:GetRoom():FindFreePickupSpawnPosition(player.Position, 40),
                            Vector.Zero,
                            nil
                        )
                    end
                },
                {
                    Text = "I'd prefer not to",
                    Outcome = function (player)
                        Isaac.Spawn(
                            EntityType.ENTITY_PICKUP,
                            PickupVariant.PICKUP_TAROTCARD,
                            0,
                            MOD.GAME:GetRoom():FindFreePickupSpawnPosition(player.Position, 40),
                            Vector.Zero,
                            nil
                        )
                    end
                }
            },
        },
        {
            Text = "Will you pick the left option?",
            Weight = 1,
            Answers = {
                {
                    Text = "No",
                    Outcome = function (player)
                        MOD.SFX:Play(SoundEffect.SOUND_EDEN_GLITCH)
                        player:UseActiveItem(CollectibleType.COLLECTIBLE_DATAMINER, UseFlag.USE_NOANIM)
                        player:PlayExtraAnimation("Glitch")
                    end
                },
                {
                    Text = "Yes",
                    Outcome = function (player)
                        MOD.SFX:Play(SoundEffect.SOUND_EDEN_GLITCH)
                        player:RerollAllCollectibles(player:GetCardRNG(t.ID), true)
                        player:PlayExtraAnimation("Glitch")
                    end
                }
            }
        },
        {
            Text = "雞為什麼要過馬路？",
            Weight = 1,
            Answers = {
                {
                    Text = "這個選項不好。",
                    Outcome = function (player)
                        Isaac.Spawn(
                            EntityType.ENTITY_BOMB,
                            BombVariant.BOMB_TROLL,
                            0,
                            player.Position,
                            Vector.Zero,
                            nil
                        )
                        MOD.SFX:Play(SoundEffect.SOUND_THUMBS_DOWN)
                        MOD.CARD_PHONK.Confetti(Vector(Isaac.GetScreenWidth() / 2, -32), 1)
                    end
                },
                {
                    Text = "到達另一邊",
                    Outcome = function (player)
                        player:UseCard(Card.CARD_EMPEROR, UseFlag.USE_NOANNOUNCER)
                        Isaac.Spawn(
                            EntityType.ENTITY_PICKUP,
                            PickupVariant.PICKUP_TAROTCARD,
                            Card.CARD_FOOL,
                            player.Position,
                            Vector.Zero,
                            nil
                        )
                    end
                },
                {
                    Text = "韭菜馬鈴薯湯",
                    Outcome = function (player)
                        MOD.SFX:Play(SoundEffect.SOUND_VAMP_GULP)
                        player:SetRedStewBonusDuration(player:GetRedStewBonusDuration() + 450)
                        player:AddCostume(MOD.CONFIG:GetCollectible(CollectibleType.COLLECTIBLE_RED_STEW))
                    end
                }
            }
        }
    }

    for _, v in ipairs(t.QUESTIONS) do
        if v.Text == "Which would you choose?" then
            for _, letter in ipairs({
                "A", "B", "C", "D", "E", "F", "G",
                "H", "I", "J", "K", "L", "M", "N",
                "O", "P", "Q", "R", "S", "T", "U",
                "V", "W", "X", "Y", "Z"
            }) do
                v.Answers[#v.Answers + 1] = {
                    Text = letter,
                    Outcome = function (player)
                        if player:GetCardRNG(t.ID):RandomFloat() < 0.1 then
                            MOD.SFX:Play(SoundEffect.SOUND_CASH_REGISTER)
                            player:AnimateHappy()
                            for _ = 1, 3 do
                                player:UseCard(Card.CARD_JUSTICE, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
                            end
                        else
                            MOD.SFX:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)
                        end
                    end
                }
            end
        end
    end

    ---@param player EntityPlayer
    ---@param value number
    MOD:AddCallback(ModCallbacks.MC_EVALUATE_CUSTOM_CACHE, function (_, player, _, value)
        return value + player:GetEffects():GetNullEffectNum(t.NULL_ASBESTOS) * 0.01
    end, "asbestos")

    ---@param player EntityPlayer
    MOD:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, function (_, player)
        player:SetInnateCollectibleGroup("DHMIS_FLOOR", {})
    end)

    function t:GetRandomPos()
        local room = MOD.GAME:GetRoom()
        ---@type Vector
        local pos
        for _ = 1, 200 do
            pos = room:FindFreePickupSpawnPosition(Isaac.GetRandomPosition(), 0, true, true)
            if MOD.GAME:GetNearestPlayer(pos).Position:Distance(pos) > 40 * 3
            and room:GetGridCollisionAtPos(pos) == GridCollisionClass.COLLISION_NONE then
                break
            end
        end
        return pos or room:GetCenterPos()
    end

    function t:ResetQuestion()
        t.QuestionData = {}
        t.QuestionText = nil
        t.AnswerText = nil
        t.Question = nil
        t.AnswerIndex = 1
    end

    ---@param player  EntityPlayer
    function t:InitQuestion(player)
        t:ResetQuestion()
        ---@type table<integer, integer>
        local questions = {}
        for i, v in ipairs(t.QUESTIONS) do
            if type(v.Weight) == "number" then
                questions[i] = v.Weight
            else
                questions[i] = v.Weight(player)
            end
        end
        local picker = WeightedOutcomePicker()
        for k, v in pairs(questions) do
            picker:AddOutcomeFloat(k, v)
        end
        local outcome = t.QUESTION_FORCE or picker:PickOutcome(player:GetCardRNG(t.ID))
        local question = t.QUESTIONS[outcome]
        if question then
            t.Question = outcome
            if question.Init then
                question.Init(player)
            end
            if type(question.Text) == "string" then
                t.QuestionText = question.Text
            else
                t.QuestionText = question.Text(player)
            end
            local answers = type(question.Answers) == "function" and question.Answers(player) or question.Answers
            t.MaxAnswerIndex = #answers
            t.AnswerText = {}
            for i, v in ipairs(answers) do
                if type(v.Text) == "string" then
                    t.AnswerText[i] = v.Text
                else
                    t.AnswerText[i] = v.Text(player)
                end
            end
        end
    end

    ---@param player EntityPlayer
    MOD:AddCallback(ModCallbacks.MC_USE_CARD, function (_, _, player)
        local ptr = EntityPtr(player)
        Isaac.CreateTimer(function ()
            if not ptr.Ref or not ptr.Ref:Exists() then return end
            t.Active = true
            t:InitQuestion(player)
            t.SPRITE:Play("Appear", true)
            MOD.SFX:Play(SoundEffect.SOUND_PAPER_IN)
        end, 3, 1, true)
    end, t.ID)

    ---@param i integer
    ---@param max integer
    ---@param padding number
    function t:GetTextOffset(i, max, padding)
        return (i - (max + 1) / 2) * padding
    end

    MOD:AddCallback(ModCallbacks.MC_HUD_RENDER, function ()
        if t.Active then
            ItemOverlay.Show(t.GIANTBOOK, 0)
            ItemOverlay.GetSprite():SetFrame(0)
            if Isaac.GetFrameCount() % 2 == 0 then
                if t.SPRITE:IsFinished("Appear") then
                    t.SPRITE:Play("Idle")
                end
                if t.SPRITE:IsFinished("Dissappear") then
                    t.Active = false
                    ItemOverlay.GetSprite():SetLastFrame()
                    local question = t.Question
                    local answer = t.AnswerIndex
                    Isaac.CreateTimer(function ()
                        t.QUESTIONS[question].Answers[answer].Outcome(Isaac.GetPlayer())
                        t:ResetQuestion()
                    end, 0, 1, true)
                    return
                end
                t.SPRITE:Update()
            end
            local center = Vector(Isaac.GetScreenWidth(), Isaac.GetScreenHeight()) / 2
            t.SPRITE:Render(center)
            local settings = FontRenderSettings()
            settings:SetAlignment(DrawStringAlignment.MIDDLE_CENTER)
            local padding = 350 / t.MaxAnswerIndex
            settings:EnableAutoWrap(60--[[math.floor(padding)]])
            settings:SetLineHeightModifier(0.6)
            -- local cursor = t.SPRITE:GetLayer("Cursor")
            -- cursor:SetVisible(true)
            local frame = t.SPRITE:GetCurrentAnimationData():GetLayer(0):GetFrame(t.SPRITE:GetFrame())
            local offset = frame:GetPos()
            -- print(offset.X)
            for i, v in ipairs(t.AnswerText) do
                local pos = Vector(
                    center.X + t:GetTextOffset(i, t.MaxAnswerIndex, padding) + offset.X,
                    center.Y + 40
                )
                t.FONT:DrawString(
                    v,
                    pos.X,
                    pos.Y,
                    1,
                    1,
                    t.KCOLOR_FONT,
                    settings
                )
                if i == t.AnswerIndex then
                    t.SPRITE_CURSOR:Render(pos + Vector(-44, -44))
                    -- t.SPRITE:RenderLayer(cursor:GetLayerID(), pos + Vector(-44, -44))
                end
            end
            -- cursor:SetVisible(false)
            if not MOD.GAME:IsPauseMenuOpen() then
                local idx = t.AnswerIndex
                local player = Isaac.GetPlayer() -- IM SORRYYY
                if player.ControllerIndex == 0 then
                    if Input.IsActionTriggered(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex) then
                        t.AnswerIndex = t.AnswerIndex - 1
                        if t.AnswerIndex < 1 then
                            t.AnswerIndex = t.MaxAnswerIndex
                        end
                    end
                    if Input.IsActionTriggered(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex) then
                        t.AnswerIndex = t.AnswerIndex + 1
                        if t.AnswerIndex > t.MaxAnswerIndex then
                            t.AnswerIndex = 1
                        end
                    end
                    if Input.IsActionTriggered(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex) then
                        t.AnswerIndex = 1
                    end
                    if Input.IsActionTriggered(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex) then
                        t.AnswerIndex = t.MaxAnswerIndex
                    end
                else
                    if Input.IsActionTriggered(ButtonAction.ACTION_LEFT, player.ControllerIndex) then
                        t.AnswerIndex = t.AnswerIndex - 1
                        if t.AnswerIndex < 1 then
                            t.AnswerIndex = t.MaxAnswerIndex
                        end
                    end
                    if Input.IsActionTriggered(ButtonAction.ACTION_RIGHT, player.ControllerIndex) then
                        t.AnswerIndex = t.AnswerIndex + 1
                        if t.AnswerIndex > t.MaxAnswerIndex then
                            t.AnswerIndex = 1
                        end
                    end
                    if Input.IsActionTriggered(ButtonAction.ACTION_DOWN, player.ControllerIndex) then
                        t.AnswerIndex = 1
                    end
                    if Input.IsActionTriggered(ButtonAction.ACTION_UP, player.ControllerIndex) then
                        t.AnswerIndex = t.MaxAnswerIndex
                    end
                end
                if Input.IsActionTriggered(ButtonAction.ACTION_MENUCONFIRM, -1) and t.SPRITE:GetAnimation() == "Idle" then
                    t.SPRITE:Play("Dissappear", true) -- omg its spelled wrong thats why it wasnt working
                    MOD.SFX:Play(SoundEffect.SOUND_PAPER_OUT)
                end
                if t.AnswerIndex ~= idx then
                    MOD.SFX:Play(SoundEffect.SOUND_MENU_SCROLL)
                end
            end
            settings = FontRenderSettings()
            settings:SetAlignment(DrawStringAlignment.MIDDLE_CENTER)
            settings:EnableAutoWrap(340)
            t.FONT_BIG:DrawString(t.QuestionText, center.X + offset.X, center.Y - 15 + offset.Y, 1, 1, t.KCOLOR_FONT, settings)
        end
    end)

    MOD:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function ()
        t.Active = false
    end)

    ---@param mod ModReference
    MOD:AddCallback(ModCallbacks.MC_PRE_MOD_UNLOAD, function (_, mod)
        if mod.Name ~= MOD.Name then return end
        if ItemOverlay.GetOverlayID() == t.GIANTBOOK then
            ItemOverlay.GetSprite():SetLastFrame()
        end
    end)

    return t
end