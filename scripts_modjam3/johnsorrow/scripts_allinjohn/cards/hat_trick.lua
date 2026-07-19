local sfx = AllInJohn.SFX

local HIT_FREQ = 3

---@param id Card
---@param player EntityPlayer
---@param flags UseFlag
local function useCard(_, id, player, flags)
    local data = AllInJohn:getData(player)
    data.HAT_TRICK_ACTIVE = (data.HAT_TRICK_ACTIVE or 0)+1
    data.HAT_TRICK_COUNTER = data.HAT_TRICK_COUNTER or 0

    sfx:Play(AllInJohn.SFX_CASH)
    AllInJohn:playAnnouncerVoice(AllInJohn.SFX_JIMBO, flags)
end
AllInJohn:AddCallback(ModCallbacks.MC_USE_CARD, useCard, AllInJohn.CARD_HAT_TRICK)

---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param frames integer
local function entityDmg(_, ent, amount, flags, _, frames)
    local player = ent:ToPlayer()
    if(not player) then return end

    local data = AllInJohn:getData(player)
    if(data.HAT_TRICK_ACTIVE and data.HAT_TRICK_COUNTER and (data.HAT_TRICK_COUNTER%HIT_FREQ)>=(HIT_FREQ-data.HAT_TRICK_ACTIVE)) then
        sfx:Play(SoundEffect.SOUND_SHELLGAME)
        return {
            Damage = amount,
            DamageFlags = flags | DamageFlag.DAMAGE_FAKE,
            DamageCountdown = frames,
        }
    end
end
AllInJohn:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, entityDmg, EntityType.ENTITY_PLAYER)

---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param frames integer
local function postEntityDmg(_, ent, amount, flags, _, frames)
    local player = ent:ToPlayer()
    if(not player) then return end

    local data = AllInJohn:getData(player)
    if(data.HAT_TRICK_COUNTER) then
        data.HAT_TRICK_COUNTER = data.HAT_TRICK_COUNTER+1
    end
end
AllInJohn:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, postEntityDmg, EntityType.ENTITY_PLAYER)

---@param pl EntityPlayer
local function removeHatTrick(_, pl)
    if(pl.FrameCount==0) then return end

    local data = AllInJohn:getData(pl)
    data.HAT_TRICK_ACTIVE = nil
    data.HAT_TRICK_COUNTER = nil
end
AllInJohn:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, removeHatTrick)