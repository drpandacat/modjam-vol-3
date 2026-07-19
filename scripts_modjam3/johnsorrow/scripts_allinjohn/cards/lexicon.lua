local sfx = AllInJohn.SFX

local VALUE_SCALE = 0.01
local LETTER_VALUES = {
    a = 1,
    b = 3,
    c = 3,
    d = 2,
    e = 1,
    f = 4,
    g = 2,
    h = 4,
    i = 1,
    j = 8,
    k = 5,
    l = 1,
    m = 3,
    n = 1,
    o = 1,
    p = 3,
    q = 10,
    r = 1,
    s = 1,
    t = 1,
    u = 1,
    v = 4,
    w = 4,
    x = 8,
    y = 4,
    z = 10,
}

---@param id Card
---@param player EntityPlayer
---@param flags UseFlag
local function useCard(_, id, player, flags)
    local data = AllInJohn:getData(player)

    local val = 0

    local conf = Isaac.GetItemConfig()
    local history = player:GetHistory():GetCollectiblesHistory()
    for _, itemData in pairs(history) do
        local iConf = conf:GetCollectible(itemData:GetItemID())
        if(iConf) then
            local name = iConf.Name
            local localizedName = Isaac.GetString("Items", name)
            if(localizedName~="StringTable::InvalidKey") then
                name = localizedName
            end

            for i=1, string.len(name) do
                local char = string.sub(name, i, i)
                if(char~=" ") then
                    val = val+(LETTER_VALUES[char] or 1)
                end
            end
        end
    end

    data.LEXICON_DAMAGE = (data.LEXICON_DAMAGE or 0)+val*VALUE_SCALE
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)

    sfx:Play(AllInJohn.SFX_MULT)
    AllInJohn:playAnnouncerVoice(AllInJohn.SFX_JIMBO, flags)
end
AllInJohn:AddCallback(ModCallbacks.MC_USE_CARD, useCard, AllInJohn.CARD_LEXICON)

---@param pl EntityPlayer
---@param val number
local function evalStat(_, pl, stat, val)
    local data = AllInJohn:getData(pl)
    if(not data.LEXICON_DAMAGE) then return end

    return val+data.LEXICON_DAMAGE
end
AllInJohn:AddCallback(ModCallbacks.MC_EVALUATE_STAT, evalStat, EvaluateStatStage.FLAT_DAMAGE)

---@param pl EntityPlayer
local function removeLexiconStats(_, pl)
    local data = AllInJohn:getData(pl)
    if(data.LEXICON_DAMAGE) then
        data.LEXICON_DAMAGE = nil
        pl:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
    end
end
AllInJohn:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, removeLexiconStats)