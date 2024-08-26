-- Logan Christianson

util.AddNetworkString("ProfessionalArmoryBuyWep")
util.AddNetworkString("ProfessionalArmoryBuyAmmo")

hook.Add("ScalePlayerDamage", "Professional Damage Scaling", function(ply, hitgroup, dmginfo)
    local att = dmginfo:GetAttacker()

    if att and IsValid(att) and att:IsPlayer() and att:IsProfessional() and dmginfo:IsBulletDamage() then
        dmginfo:ScaleDamage(GetConVar("ttt_professional_damage_buff"):GetFloat() or 1.25)
    end
end)

local function EmitSoundPlayer(ply, snd)
    local playerFilter = RecipientFilter()
    playerFilter:AddPlayer(ply)

    EmitSound(snd, ply:GetPos(), 0, CHAN_AUTO, 1, 75, 0, 100, 0, playerFilter)
end

net.Receive("ProfessionalArmoryBuyWep", function(_, ply)
    local wepClass = net.ReadString()

    if ply and IsValid(ply) and ply:Alive() and ply:IsProfessional() and not (ply:GetCredits() < 1) then
        local wepTable = weapons.Get(wepClass)

        if wepTable and (wepTable.Base == "weapon_tttbase" or wepTable.Base == "weapon_tttbasegrenade" or ProfessionalIsValidCustomWeaponBase(wepTable)) and wepTable.Spawnable and wepTable.AutoSpawnable then
            if ply:CanCarryType(wepTable.Kind) then
                EmitSoundPlayer(ply, "items/ammo_pickup.wav")
                ply:Give(wepClass)
                ply:SubtractCredits(1)

                if GetConVar("ttt_professional_ammo_on_weapon_purchase"):GetBool() then
                    ply:SetAmmo(wepTable.Primary.ClipMax, wepTable.Primary.Ammo)
                end
            end
        end
    end
end)

net.Receive("ProfessionalArmoryBuyAmmo", function(_, ply)
    local wepClass = net.ReadString()

    if ply and IsValid(ply) and ply:Alive() and ply:IsProfessional() and not (ply:GetCredits() < 1) then
        local wepTable = weapons.Get(wepClass)

        if ply:ProfessionalCanRefillAmmoByWeaponClass(wepClass) then
            EmitSoundPlayer(ply, "items/ammo_pickup.wav")
            ply:SetAmmo(wepTable.Primary.ClipMax, wepTable.Primary.Ammo)
            ply:SubtractCredits(1)
        end
    end
end)