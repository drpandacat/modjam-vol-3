local mod = CardJam_AeroTruji
local TempData = mod.TempData
local id = mod.Enums.IJIRAQ

---@param player EntityPlayer
mod:AddCallback(ModCallbacks.MC_USE_CARD, function (_, card, player, useflags)
    local dople = Isaac.Spawn(EntityType.ENTITY_DOPLE, 0, 0, player.Position, Vector.Zero, player)
    dople:AddCharmed(EntityRef(player), -1)
    dople.MaxHitPoints = 300
    dople.HitPoints = dople.MaxHitPoints
    TempData:AddData(dople, "ijiraqDople", true)
    mod.Consts.SFX:Play(SoundEffect.SOUND_SUMMONSOUND)
end, id)

---@param proj EntityProjectile
mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, function (_, proj)
    local npc = proj.SpawnerEntity
    if not npc then return end
    local data = TempData:GetData(npc)
    if data.ijiraqDople then
        local player = npc.SpawnerEntity and npc.SpawnerEntity:ToPlayer()
        if player then
            proj:Remove()
            player:FireTear(proj.Position, proj.Velocity, true, true, false, player)
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, function ()
    for _, dople in ipairs(Isaac.FindByType(EntityType.ENTITY_DOPLE)) do
        local data = TempData:GetData(dople)
        if data.ijiraqDople then
            dople:Remove()
        end
    end
end)