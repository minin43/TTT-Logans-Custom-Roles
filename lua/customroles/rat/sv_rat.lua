--// Logan Christianson
local damageStyle = GetConVar("ttt_rat_damage_style"):GetInt()
local damageScaling = GetConVar("ttt_rat_damage_scaling"):GetFloat()

hook.Add("TTTDeathNotifyOverride", "Override Death Notification For Rats", function(vic, wep, att, reason, attName, attRole)
    if attRole and attRole == ROLE_RAT then
        if vic:IsInnocentTeam() then
            attRole = ROLE_TRAITOR
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
    if ragdoll.killer then
        if not IsValid(ragdoll.killer) or not ragdoll.killer:IsPlayer() or INNOCENT_ROLES[ragdoll.killer:GetRole()] or DETECTIVE_ROLES[ragdoll.killer:GetRole()] then
            ragdoll.was_role = ROLE_TRAITOR
        elseif TRAITOR_ROLES[ragdoll.killer:GetRole()] then
            ragdoll.was_role = ROLE_INNOCENT
        end
    end
end)

hook.Add("EntityTakeDamage", "Rat Damage Reduction", function(vic, dmgInfo)
    local att = dmgInfo:GetAttacker()
    -- print("rat damage reduction", att)
    if IsValid(att) then
        if not att:IsPlayer() then
            att = att:GetOwner()
            -- print(att)
        end
        -- print(att:IsPlayer(), att:IsRat(), vic:IsPlayer(), vic:IsTraitorTeam())
        if att:IsPlayer() and att:IsRat() and vic:IsPlayer() and vic:IsTraitorTeam() then
            if damageStyle == 1 then
                dmgInfo:ScaleDamage(damageScaling or 0.25)
            elseif damageStyle == 2 then
                if vic:Health() <= dmgInfo:GetDamage() then
                    dmgInfo:ScaleDamage(0)
                end
            end
        end
    end
end)