--// Logan Christianson

-- Does this make sense?
hook.Add("TTTDeathNotifyOverride", "Override Death Notification For Rats", function(vic, wep, att, reason, attName, attRole)
    if attRole and attRole == ROLE_RAT then
        attRole = ROLE_INNOCENT
    end

    return reason, attName, attRole
end)

hook.Add("TTTCanUseTraitorVoice", "Rat Can Use Traitor Chat", function(ply)
    return ply:IsTraitorTeam() or ply:IsRat()
end)

hook.Add("TTTBeginRound", "Notify Traitors Of Rat", function()
    if player.IsRoleLiving(ROLE_RAT) then
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsTraitorTeam() then
                ply:ChatPrint("There's a rat amongst the traitors! Deal with them last.")
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

    if IsValid(att) and att:IsPlayer() and att:IsRat() and vic:IsPlayer() and vic:IsTraitorTeam() then
        dmgInfo:ScaleDamage(0.25)
    end
end)