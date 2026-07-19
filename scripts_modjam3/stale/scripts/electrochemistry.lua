local this = {}

local ChemCard = Isaac.GetCardIdByName("Electrochemistry")
local TRAIL_OFFSET = -30

function this:PillValueAdd()
    local ChemData =  DiscoCards.DISCO_RUN_DATA.ELECTRO_CHEM_DATA
    DiscoCards:AddCardValue("ELECTROCHEMISTRY",.1)
    ChemData.PILL_ONLY_EFFECT = ChemData.PILL_ONLY_EFFECT + 600
end

function this:CardUse(Card)
    local ChemData =  DiscoCards.DISCO_RUN_DATA.ELECTRO_CHEM_DATA
    if Card ~= ChemCard then
        return
    end
    DiscoCards.DISCO_RUN_DATA.HAS_USED["ELECTROCHEMISTRY"] = true
    DiscoCards:AddCardValue("ELECTROCHEMISTRY",1)
    ChemData.PILL_ONLY_EFFECT = ChemData.PILL_ONLY_EFFECT + 3600
end

function PickupConditions(Pickup)
    local ChemData =  DiscoCards.DISCO_RUN_DATA.ELECTRO_CHEM_DATA
    local Check = false
    if ChemData.PILL_ONLY_EFFECT > 0 then
        Check = true
    end
    if  Pickup == 70 then
        Check = false
    end
if Pickup == 100 and DiscoCards.DISCO_RUN_DATA.LEVELS["ELECTROCHEMISTRY"] < 5 then
    Check = false
    end
    return Check
end

function this:PickupSpawn(Pickup)
    -- local ChemData =  DiscoCards.DISCO_RUN_DATA.ELECTRO_CHEM_DATA
    Data = Pickup:GetData()
    if Pickup:IsShopItem() == true then
        return
    end
    for i=1,#DiscoCards.DISCO_RUN_DATA_TEMP.ELECTRO_CHEM_DATA.PICKUP_TABLE,1 do
        if GetPtrHash(Pickup) == GetPtrHash(DiscoCards.DISCO_RUN_DATA_TEMP.ELECTRO_CHEM_DATA.PICKUP_TABLE[i]) then
            return
        end
    end
local concon = PickupConditions(Pickup.Variant)
    local ChemData =  DiscoCards.DISCO_RUN_DATA.ELECTRO_CHEM_DATA
    if concon == true then
        if  ChemData.PILL_ONLY_EFFECT > 0 then
            if ChemData.PICKUP_CONVERSION == false then
                DiscoCards:SetText(DiscoCards:getTextData("ELECTROCHEMISTRY","PICKUP_CONVERSION"))
                ChemData.PICKUP_CONVERSION = true
            end
            if Pickup.Variant == 100 then
             Pickup:Morph(5, 70, math.random(1,PillColor.NUM_PILLS) | PillColor.PILL_GIANT_FLAG, false, true, false)    
             DiscoCards:SetText(DiscoCards:getTextData("ELECTROCHEMISTRY","COLLECTIBLE_CONVERSION")) 
            else
             Pickup:Morph(5, 70, 0, false, true, false)
            end
            SFXManager():Play(SoundEffect.SOUND_GFUEL_ROCKETLAUNCHER, 1, 0, false, 1.5)
            Pickup:GetSprite():SetRenderFlags(AnimRenderFlags.GLITCH)
            Isaac.CreateTimer(function()
                Pickup:GetSprite():SetRenderFlags(0)
            end, 30, 1, false)
            for i=1, 5, 1 do
                Isaac.Spawn(
                EntityType.ENTITY_EFFECT,
                EffectVariant.BLOOD_PARTICLE,
                0,
                Pickup.Position + Vector(math.random(-10,10),math.random(-10,10)),
                Vector.Zero,
                npc)
            end
        end
    end
    table.insert(DiscoCards.DISCO_RUN_DATA_TEMP.ELECTRO_CHEM_DATA.PICKUP_TABLE,Pickup)
end

function this:Update()
    local ChemData =  DiscoCards.DISCO_RUN_DATA.ELECTRO_CHEM_DATA
    if  ChemData.PILL_ONLY_EFFECT > 0 and  DiscoCards.DISCO_RUN_DATA.LEVELS["ELECTROCHEMISTRY"] >= 1 then
         if ChemData.PILL_ONLY_EFFECT > 10 then
            ChemData.PILL_ONLY_EFFECT =  ChemData.PILL_ONLY_EFFECT - 1
         else
            ChemData.PILL_ONLY_EFFECT = 0
         end
         if Game():GetFrameCount() % 5 == 0 then
             local player = Isaac.GetPlayer()
		    local trail_position = player.Position + Vector(0, (TRAIL_OFFSET * player.SpriteScale.X))
		    local trail_Velocity = RandomVector()
    		local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, 0, trail_position, trail_Velocity, player)
    		trail.Color = Color((ChemData.PILL_ONLY_EFFECT / 1000),1, 1, 1)
    		trail.SpriteScale = player.SpriteScale * 1.3
	end
    end
end


function this:init()
    DiscoCards:AddCallback(ModCallbacks.MC_USE_PILL, this.PillValueAdd)
    DiscoCards:AddCallback(ModCallbacks.MC_USE_CARD,this.CardUse,ChemCard)
    DiscoCards:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE,this.PickupSpawn)
    DiscoCards:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.Update)
end

return this