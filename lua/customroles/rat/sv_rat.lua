--// Logan Christianson

local damageStyle = GetConVar("ttt_rat_damage_style"):GetInt()
local damageScaling = GetConVar("ttt_rat_damage_scaling"):GetFloat()
local damageEnabled = false

hook.Add("TTTDeathNotifyOverride", "Override Death Notification For Rats", function(vic, wep, att, reason, attName, attRole)
    if attRole and attRole == ROLE_RAT then
        if vic:IsInnocentTeam() then
            attRole = att:GetNWInt("RatRandomRole", ROLE_TRAITOR)
        else
            attRole = ROLE_INNOCENT
        end

        return reason, attName, attRole
    end
end)

hook.Add("TTTCanUseTraitorVoice", "Rat Can Use Traitor Chat", function(ply)
    if ply:IsTraitorTeam() or ply:IsRat() then
        return true
    end
end)

hook.Add("TTTBeginRound", "Notify Traitors Of Rat", function()
    if player.IsRoleLiving(ROLE_RAT) then
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsTraitorTeam() then
                ply:ChatPrint("There's a rat amongst the traitors! They are innocent, but know you are a traitor.")
            end
        end
    end
end)

hook.Add("TTTOnCorpseCreated", "Rat Corpse Role Icon", function(ragdoll, _)
    if ragdoll.killer and ragdoll.was_role == ROLE_RAT then
        if not IsValid(ragdoll.killer) or not ragdoll.killer:IsPlayer() or INNOCENT_ROLES[ragdoll.killer:GetRole()] or DETECTIVE_ROLES[ragdoll.killer:GetRole()] then
            local ply = player.GetBySteamID64(ragdoll.sid64)
            ragdoll.was_role = ply:GetNWInt("RatRandomRole", ROLE_TRAITOR)
        elseif TRAITOR_ROLES[ragdoll.killer:GetRole()] then
            ragdoll.was_role = ROLE_INNOCENT
        end
    end
end)

local function CheckRatDamageEnabled()
    local innocentsAlive = 0
    local rats = {}

    for _, ply in ipairs(player.GetAll()) do
        if ply:IsActive() and ply:IsInnocentTeam() then
            innocentsAlive = innocentsAlive + 1

            if ply:IsRat() then
                table.insert(rats, ply)
            end
        end
    end

    if innocentsAlive > 0 and #rats == innocentsAlive then
        damageEnabled = true
         
        for _, ply in ipairs(rats) do
            ply:ChatPrint("Only the innocent Rat(s) remain standing! Guess you're gonna have to get your hands bloody after all.")
        end
    end
end

hook.Add("PlayerDeath", "Rat DamageStyle 4 Enabled On Player Death", CheckRatDamageEnabled)

hook.Add("PlayerDisconnected", "Rat DamageStyle 4 Enabled On Player Leave", CheckRatDamageEnabled)

hook.Add("TTTBeginRound", "Rat DamageStyle 4 Reset", function()
    damageEnabled = false
end)

hook.Add("EntityTakeDamage", "Rat Damage Reduction", function(vic, dmgInfo)
    local att = dmgInfo:GetAttacker()

    if IsValid(att) then
        if not att:IsPlayer() then
            att = att:GetOwner()
        end

        if att:IsPlayer() and att:IsRat() and vic:IsPlayer() then
            if vic:IsTraitorTeam() then
                if damageStyle == 1 then
                    dmgInfo:ScaleDamage(damageScaling or 0.25)
                elseif damageStyle == 2 then
                    if vic:Health() <= dmgInfo:GetDamage() then
                        dmgInfo:ScaleDamage(0)
                        return true
                    end
                end
            end

            if damageStyle == 4 then
                if damageEnabled then
                    dmgInfo:ScaleDamage(damageScaling or 0.25)
                else
                    dmgInfo:ScaleDamage(0)
                    return true
                end
            end
        end
    end
end)

hook.Add("TTTEndRound", "Rat Remove NWVar", function()
    for _, ply in ipairs(player.GetAll()) do
        ply:SetNWInt("RatRandomRole", -1)
    end
end)