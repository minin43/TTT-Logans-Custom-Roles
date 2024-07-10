--// Logan Christianson

hook.Add("TTTTargetIDPlayerRoleIcon", "Display Traitor Icons For Rat", function(target, localPly, targetRole, visibleThroughWalls, roleColor)
    if IsValid(target) and target:IsPlayer() then
        if (target:IsRat() and localPly:IsTraitorTeam()) or (target:IsTraitorTeam() and localPly:IsRat()) then
            targetRole = ROLE_TRAITOR
            roleColor = ROLE_TRAITOR
        end
    end

    return targetRole, visibleThroughWalls, roleColor
end)

hook.Add("TTTTargetIDPlayerText", "Rat Id Texts", function(target, localPly, text, textColor, secondaryText)
    if IsValid(target) and target:IsPlayer() then
        if target:IsRat() and localPly:IsTraitorTeam() then
            text = StringUpper(ROLE_STRINGS[ROLE_TRAITOR])
            textColor = ROLE_COLORS_RADAR[ROLE_TRAITOR]
        elseif target:IsTraitorTeam() and localPly:IsRat() then
            text = "DIRTY TRAITOR"
            textColor = ROLE_COLORS_RADAR[ROLE_TRAITOR]
        end
    end

    return text, textColor, secondaryText
end)

hook.Add("TTTTutorialRoleText", "Rat Tutorial Role Text", function(playerRole)
    local function getStyleString(role)
        local roleColor = ROLE_COLORS[role]
        return "<span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>"
    end

    if playerRole == ROLE_RAT then
        local divStart = "<div style='margin-top: 10px;'>"
        local styleEnd = "</span>"

        local html = "The " .. ROLE_STRINGS[ROLE_RAT] .. " is a member of the " .. getStyleString(ROLE_INNOCENT) .. "innocent team" .. styleEnd .. " whose job is to strategically out the " .. getStyleString(ROLE_INNOCENT) .. ROLE_STRINGS_EXT[ROLE_TRAITOR] .. styleEnd .. " without drawing suspicion away from the traitros and onto the themself.</div>"

        html = html .. divStart .. "The " .. ROLE_STRINGS[ROLE_RAT] .. "can see other " .. ROLE_STRINGS_EXT[ROLE_TRAITOR] .. " and appears as a " .. ROLE_STRINGS[ROLE_TRAITOR] .. " to them, but does severely reduced damage against them.</div>"

        html = html .. divStart .. "If an " .. getStyleString(ROLE_INNOCENT) .. ROLE_STRINGS[ROLE_INNOCENT] .. styleEnd .. " or " .. getStyleString(ROLE_DETECTIVE) .. detective .. styleEnd .. " kills them, they show as a " .. ROLE_STRINGS[ROLE_TRAITOR] .. ".\n"
        
        html = html .. "If a " .. getStyleString(ROLE_TRAITOR) .. ROLE_STRINGS[ROLE_TRAITOR] .. styleEnd .. " kills them, they show as an " .. ROLE_STRINGS[ROLE_INNOCENT] .. ".\n"
        
        html = html .. "If a " .. getStyleString(ROLE_TEAM_MONSTER) .. ROLE_STRINGS[ROLE_TEAM_MONSTER] .. styleEnd .. ", " .. getStyleString(ROLE_JESTER) .. ROLE_STRINGS[ROLE_JESTER] .. styleEnd .. ", or " .. getStyleString(ROLE_TEAM_INDEPENDENT) .. ROLE_STRINGS[ROLE_TEAM_INDEPENDENT] .. styleEnd .. " kills them, they show as a " .. ROLE_STRINGS[ROLE_RAT] .. ".</div>"

        return html
    end
end)