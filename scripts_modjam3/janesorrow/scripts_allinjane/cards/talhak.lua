--[[
Talhak
 - when the boss of this floor is defeated, spawns 10 distinct consumables and you can only pick 1
]]

local CARD_SPAWNS = 10
local EXTRA_SPAWNS = 1

local PILL_CHANCE = 0.2

---@param id Card
---@param player EntityPlayer
---@param flags UseFlag
local function useCard(_, id, player, flags)
    local data = AllInJane:getUniversalData()
    data.TALHAK_TRIGGERS = (data.TALHAK_TRIGGERS or 0)+1

    AllInJane.SFX:Play(AllInJane.SFX_BALANCE)
    AllInJane:playAnnouncerVoice(AllInJane.SFX_JIMBO, flags)
end
AllInJane:AddCallback(ModCallbacks.MC_USE_CARD, useCard, AllInJane.CARD_TALHAK)

local function clearRoomCards(_)
    if(AllInJane.GAME:GetRoom():GetType()~=RoomType.ROOM_BOSS) then return end

    local data = AllInJane:getUniversalData()
    if(not data.TALHAK_TRIGGERS) then return end

    local pool = AllInJane.GAME:GetItemPool()
    local room = AllInJane.GAME:GetRoom()

    local rng = Isaac.GetPlayer():GetCardRNG(AllInJane.CARD_TALHAK)

    local pickupIndex

    local numSpawns = CARD_SPAWNS+(data.TALHAK_TRIGGERS-1)*EXTRA_SPAWNS
    local existingSpawns = {}
    for i=1, numSpawns do
        local failsafe = 250
        local var, sub, str
        
        repeat
            if(rng:RandomFloat()<PILL_CHANCE) then
                var = PickupVariant.PICKUP_PILL
                sub = pool:GetPill(rng:Next())
            else
                var = PickupVariant.PICKUP_TAROTCARD
                sub = pool:GetCard(rng:Next(), true, true, false)
            end

            str = tostring(var).."."..tostring(sub)
        until(failsafe==0 or not existingSpawns[str])

        existingSpawns[str] = true
        local pos = room:FindFreePickupSpawnPosition(room:GetRandomPosition(40), 0)
        local card = Isaac.Spawn(5,var,sub,pos,Vector.Zero,nil):ToPickup()
        if(card) then
            card:SetDropDelay((i*1.5)//1)

            if(pickupIndex) then
                card.OptionsPickupIndex = pickupIndex
            else
                pickupIndex = card:SetNewOptionsPickupIndex()
            end
        end
    end

    AllInJane.SFX:Play(SoundEffect.SOUND_JOKER)

    data.TALHAK_TRIGGERS = nil
end
AllInJane:AddCallback(ModCallbacks.MC_POST_ROOM_TRIGGER_CLEAR, clearRoomCards)


local ICON_SPRITE = Sprite("gfx/ui/ui_legendary_jokers_jane.anm2", true)
ICON_SPRITE:Play("Idle", true)
ICON_SPRITE:SetFrame(0)
ICON_SPRITE:Stop(true)

-- also stolen from kerkel
HudHelper.RegisterHUDElement({
    Name = "CARD_TALHAK",
    Priority = HudHelper.Priority.HIGH,
    Condition = function(player)
        return (player:GetCard(0)==AllInJane.CARD_TALHAK)
    end,
	OnRender = function(player, _, layout, position, alpha, scale)
        ICON_SPRITE:SetFrame("Back", 0)
        ICON_SPRITE.Rotation = 0
        ICON_SPRITE.Scale = Vector(scale, scale)
        ICON_SPRITE.Color = Color(1,1,1,alpha)
        ICON_SPRITE:Render(position)

        ICON_SPRITE:SetFrame("Idle", 0)
        local frame = AllInJane.GAME:GetFrameCount()
        ICON_SPRITE.Rotation = math.cos(math.rad(frame*10))*10
        ICON_SPRITE.Scale = ICON_SPRITE.Scale*(0.98+math.sin(math.rad(frame*3))*0.06)
        ICON_SPRITE:Render(position-Vector(0,2)*scale)
	end,
}, HudHelper.HUDType.POCKET)