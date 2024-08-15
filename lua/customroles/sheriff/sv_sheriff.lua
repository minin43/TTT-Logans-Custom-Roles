-- Logan Christianson

local wepScaling = GetConVar("ttt_sheriff_secondary_weapon_damage_scaling"):GetFloat()
local doInstantKill = GetConVar("ttt_sheriff_secondary_equip_instant_kill"):GetBool() or true
local instantKillChain = GetConVar("ttt_sheriff_instant_kill_can_chain"):GetBool() or true

local function SetupSheriffPistol(ply, wep)
    if wep.IsSheriffPistol or not doInstantKill then return end

    local oldWepDeploy = wep.Deploy
    local oldWepFire = wep.PrimaryAttack
    local oldWepDrop = wep.OnDrop

    wep.Deploy = function(wep)
        wep.SheriffBonusDeployTimer = CurTime() + 1
            
        oldWepDeploy(wep)
    end

    wep.PrimaryAttack = function(wep, worldsnd)
        if not wep:CanPrimaryAttack() then return end

        if wep.SheriffBonusDeployTimer then
            timer.Simple(0, function() -- If we wait a frame, that SEEMS to be the window where the first bullet would hit if it landed
                if wep then
                    wep.SheriffBonusDeployTimer = nil
                end
            end)

            sound.Play("ttt/roles/srf/gunshot" .. math.random(8) .. ".ogg", wep:GetPos(), 160)
        end

        oldWepFire(wep)
    end

    wep.OnDrop = function(wep)
        wep.Deploy = oldWepDeploy
        wep.PrimaryAttack = oldWepFire
        wep.IsSheriffPistol = false

        oldWepDrop(wep)
    end

    wep.IsSheriffPistol = true
end

local function SetupSheriffWeapons(ply)
    if ply and IsValid(ply) and ply:IsActive() and ply:IsSheriff() then
        for _, wep in ipairs(ply:GetWeapons()) do
            if wep.Kind then
                if wep.Kind == WEAPON_HEAVY then
                    ply:DropWeapon(wep)
                elseif wep.Kind == WEAPON_PISTOL then
                    SetupSheriffPistol(ply, wep)
                end
            end
        end
    else
        timer.Remove("PreventSheriffPrimaryPickup" .. ply:SteamID64())
    end
end

hook.Add("TTTPlayerRoleChanged", "Sheriff CanCarryType Override", function(ply, _, newRole)
    if newRole == ROLE_SHERIFF then
        SetupSheriffWeapons(ply)

        timer.Create("PreventSheriffPrimaryPickup" .. ply:SteamID64(), 1, 0, function()
            SetupSheriffWeapons(ply)            
        end)
    end
end)

hook.Add("PlayerCanPickupWeapon", "Sheriff Primary Weapon Override", function(ply, wep)
    if ply:IsSheriff() and ply:IsActive() and wep.Kind == WEAPON_HEAVY then
        return false
    end
end)

hook.Add("EntityTakeDamage", "Sheriff Damage Buff", function(vic, dmgInfo)
    local att = dmgInfo:GetAttacker()

    if IsValid(att) and att:IsPlayer() and att:IsSheriff() and vic and vic:IsValid() and vic:IsPlayer() then
        local wep = att:GetActiveWeapon()

        if wep and IsValid(wep) and wep.Kind and wep.Kind == WEAPON_PISTOL then
            if wep.SheriffBonusDeployTimer and wep.SheriffBonusDeployTimer > CurTime() and not vic:IsOutlaw() then
                dmgInfo:SetDamage(999999)
                dmgInfo:ScaleDamage(1)

                if instantKillChain then
                    timer.Simple(0, function()
                        if wep then
                            wep.SheriffBonusDeployTimer = CurTime() + 1
                        end
                    end)
                end
                print("sheriff instant kill", instantKillChain, wep.SheriffBonusDeployTimer, CurTime())
            else
                dmgInfo:ScaleDamage(wepScaling or 1.25)
            end
        end
    end
end)

hook.Add("WeaponEquip", "Add Sheriff First Shot Bonus", function(wep, ply)
    timer.Simple(0, function()
        if ply:IsPlayer() and ply:IsSheriff() and wep.Kind and wep.Kind == WEAPON_PISTOL then
            SetupSheriffPistol(ply, wep)
        end
    end)
end)