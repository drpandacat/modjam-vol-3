local mod = HODGEPODGE

local itemIcon = Sprite("gfx/ui/hdpg_item_icon.anm2", true)
itemIcon:Play("Idle")

local currentDisplayedItem = -1
local redSealActive = false

---@param player EntityPlayer
local function UseCard(_, _, player)
    local data = player:GetData()

    if not data.RedSealData then
        data.RedSealData = {
            ItemList = {},
            CurrentItem = 1,
            CurrentFrame = 0,
            CurrentPace = 1,
        }
    end

    local history = player:GetHistory():GetCollectiblesHistory()

    for _, item in ipairs(history) do
        if item:IsTrinket() then
            goto continue
        end
        local config = mod.ItemConfig:GetCollectible(item:GetItemID())
        if config.Type ~= ItemType.ITEM_ACTIVE then
            table.insert(data.RedSealData.ItemList, item:GetItemID())
        end
        ::continue::
    end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, UseCard, mod.Card.RED_SEAL)

local function PreAddHearts()
    if redSealActive then
        return 0
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, PreAddHearts)

---@param player EntityPlayer
local function PostPeffectUpdate(_, player)
    local data = player:GetData()
    if not data.RedSealData then
        return
    end

    local sealData = data.RedSealData

    if sealData.CurrentFrame == 0 then
        local item = sealData.ItemList[sealData.CurrentItem]
        if not item then
            data.RedSealData = nil
            return
        end
        redSealActive = true
        player:AddCollectible(item)
        player:RemoveCollectible(item)
        redSealActive = false
        mod.Sfx:Play(mod.SoundEffect.RED_SEAL_RETRIGGER, 5, 2, false, 0.7 + sealData.CurrentItem*0.05 + sealData.CurrentPace*0.1)
        player:AnimateCollectible(item)
    end

    sealData.CurrentFrame = sealData.CurrentFrame + sealData.CurrentPace
    if sealData.CurrentFrame > 20 then
        sealData.CurrentItem = sealData.CurrentItem + 1
        if not sealData.ItemList[sealData.CurrentItem] then
            data.RedSealData = nil
            mod.Sfx:Play(mod.SoundEffect.RED_SEAL_FINISH, 3)
            return
        end
        sealData.CurrentFrame = 0
        local newPace = math.max(1, math.min(8, sealData.CurrentItem/5))
        sealData.CurrentPace = newPace
    end

end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PostPeffectUpdate)