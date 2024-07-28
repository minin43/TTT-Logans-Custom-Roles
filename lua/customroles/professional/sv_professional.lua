-- Logan Christianson

util.AddNetworkString("ProfessionalArmoryBuyWep")
util.AddNetworkString("ProfessionalArmoryBuyAmmo")

local AmmoVals = []

hook.Add("OnEntityCreated", "Professional Ammo Ent Tracking", function(ent)
    if ent and IsValid(ent) and ent.Base and ent.Base == "base_ammo_ttt" then
        AmmoVals[ent.AmomType] = {amount = ent.AmmoAmount, max = ent.AmmoMax}
    end
end)

hook.Add("ScalePlayerDamage", "Professional Damage Scaling", function(ply, hitgroup, dmginfo)
    local att = dmginfo:GetAttacker()

    if att and IsValid(att) and att:IsPlayer() and att:IsProfessional() and dmginfo:IsBulletDamage() then
        dmginfo:ScaleDamage(GetConVar("ttt_professional_damage_buff"):GetFloat() or 1.25)
    end
end)

local GetAmmoMaxFromAmmoType(ammoType)
    local stored = AmmoVals[ammoType]

    if stored then
        return stored.max
    end

    return 10
end

local GetAmmoAmountFromAmmoType(ammoType)
    local stored = AmmoVals[ammoType]

    if stored then
        return stored.amount
    end

    return 1
end

net.Receive("ProfessionalArmoryBuyWep", function(_, ply)
    local wepClass = net.ReadString()

    if ply and IsValid(ply) and ply:Alive() and ply:IsProfessional() then
        local wepTable = weapons.Get(wepClass)

        if wepTable and (wepTable.Base == "weapon_tttbase" or wepTable.Base == "weapon_tttbasegrenade") and wepTable.Spawnable and wepTable.AutoSpawnable then
            if ply:CanCarryWeapon(wepClass) then
                ply:Give(wepClass)
                ply:SubtractCredits(1)

                if GetConVar("ttt_professional_ammo_on_weapon_purchase"):GetBool() then
                    ply:SetAmmo(GetAmmoMaxFromAmmoType(wepTable.Primary.Ammo), wepTable.Primary.Ammo)
                end
            end
        end
    end
end)

net.Receive("ProfessionalArmoryBuyAmmo", function(_, ply)
    local wepClass = net.ReadString()

    if ply and IsValid(ply) and ply:Alive() and ply:IsProfessional() then
        local wepTable = weapons.Get(wepClass)

        if wepTable and wepTable.Base == "weapon_tttbase" and wepTable.Spawnable and wepTable.AutoSpawnable then
            local currentAmmo = ent:GetAmmoCount(wepTable.Primary.Ammo)

            -- If there's room for at least 1/4 of a box, you can add more
            if GetAmmoMaxFromAmmoType(wepTable.Primary.Ammo) >= (currentAmmo + math.ceil(GetAmmoAmountFromAmmoType(wepTable.Primary.Ammo) * 0.25)) then
                if GetConVar("ttt_professional_ammo_refill_all_ammo"):GetBool() then
                    ply:SetAmmo(GetAmmoMaxFromAmmoType(wepTable.Primary.Ammo), wepTable.Primary.Ammo)
                else
                    local given = GetAmmoAmountFromAmmoType(wepTable.Primary.Ammo)
                    given = math.min(given, GetAmmoMaxFromAmmoType(wepTable.Primary.Ammo) - ammo)
                    ply:GiveAmmo(given, wepTable.Primary.Ammo)
                end
                
                ply:SubtractCredits(1)
            end
        end
    end
end)