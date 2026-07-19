local game = Game()
local sfxManager = SFXManager()



ModJamV3.Cards.BlueSlime = {}
ModJamV3.Cards.BlueSlime.CARD_TYPE = Isaac.GetCardIdByName("Blue Slime")
ModJamV3.Cards.BlueSlime.ITEM_DROP_COLLECTIBLE_TYPE = Isaac.GetNullItemIdByName("Blue Slime Item Drop")

---@param card Card
---@param player EntityPlayer
---@param useFlags UseFlag
ModJamV3:AddCallback(ModCallbacks.MC_USE_CARD, function (_, card, player, useFlags)

    player:AddNullItemEffect(ModJamV3.Cards.BlueSlime.ITEM_DROP_COLLECTIBLE_TYPE, true, 300, false)

end, ModJamV3.Cards.BlueSlime.CARD_TYPE)

---@param player EntityPlayer
ModJamV3:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)

    local effects = player:GetEffects()
    if not effects:HasNullEffect(ModJamV3.Cards.BlueSlime.ITEM_DROP_COLLECTIBLE_TYPE) then return end

    if player.FrameCount % 4 ~= 0 then return end

    ---@type EntityEffect
    ---@diagnostic disable-next-line: assign-type-mismatch
    local bubl = Isaac.Spawn
    (
        EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, 0,
        player.Position + Vector(0, -30), RandomVector() * ModJamV3.RandomFloat(4, 8) + Vector(ModJamV3.RandomFloat(-1, 1), ModJamV3.RandomFloat(-5, -2)),
        nil
    ):ToEffect()
    bubl:Update()

    bubl.SpriteScale = Vector.One * 1.25
    bubl.Color = Color
    (
        0, 0, 0, 1,
        0.2, 0.5, 1
    )

end)

---@param entity Entity
---@param killSource EntityRef
ModJamV3:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function (_, entity, killSource)
    local anyoneHasBlueSlimeEffeect = false
    for _, player in ipairs(PlayerManager.GetPlayers()) do
        local effects = player:GetEffects()
        if effects:HasNullEffect(ModJamV3.Cards.BlueSlime.ITEM_DROP_COLLECTIBLE_TYPE) then
            anyoneHasBlueSlimeEffeect = true
            break
        end
    end

    if not anyoneHasBlueSlimeEffeect then return end

    local position = entity.Position
    Isaac.Spawn
    (
        EntityType.ENTITY_PICKUP, 0, 0,
        position, Vector.Zero,
        nil
    )
end)