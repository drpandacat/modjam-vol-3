---@param MOD ModReference
return function (MOD)
    local t = {}

    t.ID = Isaac.GetCardIdByName("Phonkard")
    t.MUSIC = Isaac.GetMusicIdByName("Isaac Phonk")
    t.NULL = Isaac.GetNullItemIdByName("Phonkard")
    t.BPM = 125.25 * 2
    t.SECONDS_PER_BEAT = 60 / t.BPM
    t.BLEED_DUR = 2
    t.BLEED_RADIUS = 40 * 1.5
    t.StartTime = -1
    t.LastBeat = -1
    t.PrevMusic = MOD.MUSIC:GetCurrentMusicID()
    t.Zoom = 1
    t.Ooh = 0
    t.ZoomPos = Vector.One * 0.5
    t.OldSFXVol = Options.SFXVolume
    t.OldMusicVol = Options.MusicVolume
    t.MusicEnabled = MOD.MUSIC:IsEnabled()
    t.ForceSFXVol = nil
    t.ForceMusicVol = nil
    t.ColorModifier = 0
    ---@type ColorModifier[]
    t.COLOR_MODIFIERS = {
        ColorModifier(
            2.5, 0.75, 0.75,
            0.6
        ),
        ColorModifier(
            0.5, 2.5, 2.5,
            0.6
        ),
        ColorModifier(
            0.75, 2.5, 0.75,
            0.6
        ),
        ColorModifier(
            2.5, 0.5, 2.5,
            0.6
        ),
        ColorModifier(
            0.75, 0.75, 2.5,
            0.6
        ),
        ColorModifier(
            2.5, 2.5, 0.5,
            0.6
        ),
    }
    t.ItsSoOver = false

    t.Confetti = {
        ---@type Confetti[]
        Instances = {},
    }
    ---@param index integer
    function t.Confetti:Update(index)
        ---@cast self Confetti
        self.Velocity = Vector(self.Velocity.X * 0.95, self.Velocity.Y + 0.075)
        self.Position = self.Position + self.Velocity --* 0.1
        self.Sprite:Render(self.Position)
        local len = self.Velocity:Length()
        self.Sprite.Rotation = self.Sprite.Rotation + 5 * (self.Sprite.Scale.X < 0 and -1 or 1) * len * 0.1
        self.Sprite.Scale = Vector(math.sin(Isaac.GetFrameCount() * 0.1 + self.Seed) * self.Sprite.Scale.Y, self.Sprite.Scale.Y)
        if self.Position.Y >= Isaac.GetScreenHeight() + 32 then
            table.remove(t.Confetti.Instances, index)
        end
    end
    t.Confetti.__index = t.Confetti
    setmetatable(t.Confetti, {
        __call = function (self, pos, type)
            ---@class Confetti
            ---@field Update fun(self: Confetti, index: integer)
            local this = {}
            this.Position = pos
            this.Velocity = Vector((math.random() - 0.5) * 7.5, -math.random() * 5)
            this.Sprite = Sprite("gfx/ui_phonkconfetti.anm2", true)
            this.Sprite:Play("Idle", true)
            this.Sprite.FlipX = math.random(1) == 1
            if (type == 1 or math.random() < 0.1) and type ~= 0 then
                this.Sprite:ReplaceSpritesheet(0, "gfx/ui/phonkvruddyvroddy.png", true)
            elseif type == 2 or math.random() < 0.005 or MOD.GAME:GetRoom():GetBackdropType() == MOD.CARD_BLUE_ASBESTOS.BACKDROP then
                this.Sprite:ReplaceSpritesheet(0, "gfx/ui/negaterainbowmango.png", true)
            end
            this.Seed = Random()
            local meta = setmetatable(this, self)
            t.Confetti.Instances[#t.Confetti.Instances + 1] = meta
            return meta
        end
    })

    function t:Start()
        t:End()
        MOD.MUSIC:Play(t.MUSIC, 1)
        t.StartTime = os.clock()
        t.LastBeat = -1
        t.PrevMusic = -1

        t.OldMusicVol = Options.MusicVolume
        t.OldSFXVol = Options.SFXVolume
        t.MusicEnabled = MOD.MUSIC:IsEnabled()

        t.ForceMusicVol = Options.MusicVolume
        if t.ForceMusicVol == 0 then
            t.ForceMusicVol = Options.SFXVolume
        end
        t.ForceSFXVol = t.OldSFXVol / 2

        Options.MusicVolume = t.ForceMusicVol
        Options.SFXVolume = t.ForceSFXVol
    end

    function t:End()
        Options.MusicVolume = t.OldMusicVol
        Options.SFXVolume = t.OldSFXVol
        if t.MusicEnabled then
            MOD.MUSIC:Enable()
        else
            MOD.MUSIC:Disable()
        end
        t.ForceMusicVol = nil
        t.ForceSFXVol = nil
        t.ItsSoOver = true
        if MOD.MUSIC:GetCurrentMusicID() == t.MUSIC then
            MOD.GAME:SetColorModifier(ColorModifier())
        end
        MOD.GAME:GetRoom():PlayMusic()
        t.ItsSoOver = false
        for _, player in ipairs(PlayerManager.GetPlayers()) do
            local count = player:GetInnateCollectibleCount(CollectibleType.COLLECTIBLE_MERCURIUS, "Phonkard")
            if count > 0 then
                player:RemoveInnateCollectible(CollectibleType.COLLECTIBLE_MERCURIUS, count, "Phonkard")
            end
            player:GetEffects():RemoveNullEffect(t.NULL, -1)
        end
    end

    function t:Reset()
        t:End()
        t.StartTime = -1
        t.LastBeat = -1
        t.PrevMusic = MOD.MUSIC:GetCurrentMusicID()
        t.Zoom = 1
        t.Ooh = 0
        t.ZoomPos = Vector.One * 0.5
        t.ColorModifier = 0
        t.Confetti.Instances = {}
    end

    function t:TrySetColorModifier()
        if t.LastBeat < 64 then
            return false
        end
        MOD.GAME:SetColorModifier(t.COLOR_MODIFIERS[t.ColorModifier + 1], true, 0.5)
        return true
    end

    MOD:AddCallback(ModCallbacks.MC_POST_RENDER, function ()
        if t.ForceMusicVol then
            Options.MusicVolume = t.ForceMusicVol
        end
        if t.ForceSFXVol then
            Options.SFXVolume = t.ForceSFXVol
        end

        t.Ooh = t.Ooh - 1

        if t.Ooh > 0 then
            local player = Isaac.GetPlayer()
            t.ZoomPos = MOD:Lerp(
                t.ZoomPos,
                Isaac.WorldToScreen(player.Position + Vector(0, -33 / 2 * player.SpriteScale.Y)) / Vector(Isaac.GetScreenWidth(), Isaac.GetScreenHeight()),
                0.1
            )
            t.Zoom = MOD:Lerp(t.Zoom, 4, 0.1)
        else
            t.Zoom = MOD:Lerp(t.Zoom, 1, 0.1)
            t.ZoomPos = MOD:Lerp(
                t.ZoomPos,
                Vector.One * 0.5,
                0.1
            )
        end

        local music = MOD.MUSIC:GetCurrentMusicID()

        if music == t.MUSIC then
            if t.PrevMusic ~= t.MUSIC then
                t.StartTime = os.clock()
            end
        else
            t.OldMusicVol = Options.MusicVolume
            t.OldSFXVol = Options.SFXVolume
            t.StartTime = -1
            t.MusicEnabled = MOD.MUSIC:IsEnabled()
        end

        t.PrevMusic = music

        if t.StartTime == -1 then return end

        local elapsed = os.clock() - t.StartTime
        local beat = elapsed // t.SECONDS_PER_BEAT
        local players = PlayerManager.GetPlayers()

        while t.LastBeat < beat do
            t.LastBeat = t.LastBeat + 1
            if t.Ooh <= 0 then
                if t.LastBeat % 8 == 0 then
                    t.Zoom = t.Zoom + 0.5
                    t.ColorModifier = (t.ColorModifier + 1) % #t.COLOR_MODIFIERS
                    t:TrySetColorModifier()
                elseif t.LastBeat % 2 == 0 then
                    t.Zoom = t.Zoom + 0.05
                end
            end

            local jump

            if t.LastBeat < 32 then -- Straight
                jump = t.LastBeat > 0 and t.LastBeat % 8 == 0
            elseif t.LastBeat < 48 then -- Straight (2x)
                jump = t.LastBeat % 4 == 0
            elseif t.LastBeat < 64 then -- Straight (4x)
                jump = t.LastBeat % 2 == 0
            elseif t.LastBeat < 128 then -- The bi bi bi
                local wrapped = t.LastBeat % 16
                jump = wrapped > 0 and wrapped < 15
            elseif t.LastBeat < 192 then -- Ice ice ice Isaac
                jump = t.LastBeat == 130
                or t.LastBeat == 134
                or t.LastBeat == 138
                or t.LastBeat == 142
                or t.LastBeat == 144
                or t.LastBeat == 150
                or t.LastBeat == 152
                -- or t.LastBeat == 156

                or t.LastBeat == 130 + 32
                or t.LastBeat == 134 + 32
                or t.LastBeat == 138 + 32
                or t.LastBeat == 142 + 32
                or t.LastBeat == 144 + 32
                or t.LastBeat == 150 + 32
                or t.LastBeat == 152 + 32
                -- or t.LastBeat == 156 + 32

                if t.LastBeat == 156
                or t.LastBeat == 156 + 32 then
                    for _, player in ipairs(players) do
                        player:StopExtraAnimation()
                        player:PlayExtraAnimation("Happy")
                    end
                    ImGui.PushNotification("Ooh!", ImGuiNotificationType.SUCCESS)
                    t.Ooh = 60
                end
            else -- Straight 3
                jump = t.LastBeat < 256 and (t.LastBeat + 2) % 2 == 0
            end

            for _, player in ipairs(players) do
                if jump then
                    player:StopExtraAnimation()
                    player:PlayExtraAnimation("Jump")
                end
                if t.LastBeat > 128 then
                    for _ = 1, math.random(1, 3) do
                        t.Confetti(Vector(Isaac.WorldToScreen(player.Position).X, -32))
                    end
                end
            end

            if t.LastBeat > 256 then
                t:End()
                break
            end
        end
    end)

    -- function t:Bleed()
    --     for _, v in ipairs(Isaac.GetRoomEntities()) do
    --         if v:IsVulnerableEnemy() and not v:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
    --             v:AddBleeding(EntityRef(nil), t.BLEED_DUR)
    --         end
    --     end
    -- end

    MOD:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
        if MOD.MUSIC:GetCurrentMusicID() ~= t.MUSIC then return end
        -- t:Bleed()
        t:TrySetColorModifier()
    end)

    ---@param player EntityPlayer
    MOD:AddCallback(ModCallbacks.MC_USE_CARD, function (_, _, player)
        t:Start()
        player:AddInnateCollectible(CollectibleType.COLLECTIBLE_MERCURIUS, nil, "Phonkard", nil, false)
        player:AddNullItemEffect(t.NULL)
        -- t:Bleed()
        local room = MOD.GAME:GetRoom()
        for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
            local door = room:GetDoor(i)
            if door then
                door:Open()
            end
        end
    end, t.ID)

    MOD:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, t.Reset)

    ---@param shader string
    MOD:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, function (_, shader)
        if shader == "Phonk Zoom" then
            return {
                StrengthIn = t.Zoom,
                ScreenPointScaleIn = Isaac.GetScreenPointScale(),
                PosIn = {t.ZoomPos.X, t.ZoomPos.Y}
            }
        elseif shader == "Phonk Overlay" then
            for i = #t.Confetti.Instances, 1, -1 do
                local v = t.Confetti.Instances[i]
                v:Update(i)
            end
        end
    end)

    ---@param id Music
    MOD:AddPriorityCallback(ModCallbacks.MC_PRE_MUSIC_PLAY, CallbackPriority.EARLY, function (_, id)
        if t.ItsSoOver
        or id == t.MUSIC
        or MOD.MUSIC:GetCurrentMusicID() ~= t.MUSIC then return end
        return false
    end)
    ---@param id Music
    MOD:AddPriorityCallback(ModCallbacks.MC_PRE_MUSIC_PLAY_JINGLE, CallbackPriority.EARLY, function (_, id)
        if MOD.MUSIC:GetCurrentMusicID() ~= t.MUSIC then return end
        return false
    end)

    ---@param mod ModReference
    MOD:AddCallback(ModCallbacks.MC_PRE_MOD_UNLOAD, function (_, mod)
        if mod.Name ~= MOD.Name then return end
        t:Reset()
    end)

    ---@param player EntityPlayer
    MOD:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)
        if MOD.MUSIC:GetCurrentMusicID() ~= t.MUSIC then return end
        for _, v in ipairs(Isaac.FindInRadius(player.Position, t.BLEED_RADIUS, EntityPartition.ENEMY)) do
            v:AddBleeding(EntityRef(player), t.BLEED_DUR)
        end
    end)

    return t
end