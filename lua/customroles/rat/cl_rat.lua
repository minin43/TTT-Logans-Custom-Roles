--// Logan Christianson

hook.Add("TTTTargetIDPlayerRoleIcon", "Display Traitor Icons For Rat", function(target, localPly, targetRole, visibleThroughWalls, roleColor)
    if IsValid(target) and target:IsPlayer() then
        if (target:IsRat() and localPly:IsTraitorTeam()) or (target:IsTraitorTeam() and localPly:IsRat()) then
            targetRole = ROLE_TRAITOR
            roleColor = ROLE_TRAITOR
        
            return targetRole, visibleThroughWalls, roleColor
        end
    end
end)

hook.Add("TTTTargetIDPlayerText", "Rat Id Texts", function(target, localPly, text, textColor, secondaryText)
    if IsValid(target) and target:IsPlayer() then
        if target:IsRat() and localPly:IsTraitorTeam() then
            return string.upper(ROLE_STRINGS[ROLE_TRAITOR]), ROLE_COLORS_RADAR[ROLE_TRAITOR], secondaryText
        elseif target:IsTraitorTeam() and localPly:IsRat() then
            return "DIRTY TRAITOR", ROLE_COLORS_RADAR[ROLE_TRAITOR], secondaryText
        end
    end
end)

hook.Add("TTTTargetIDPlayerRing", "Rat Hover Ring", function(ent, localPly, _)
    if ent and IsValid(ent) and ent:IsPlayer() and ent:IsRat() and localPly:IsTraitorTeam() then
        return true, ROLE_COLORS_RADAR[ROLE_TRAITOR]
    end
end)

hook.Add("TTTScoreboardPlayerRole", "Rat Scoreboard Alterations", function(targetPly, localPly, color, path)
    if localPly:IsTraitorTeam() and targetPly:IsRat() then
        if not targetPly:Alive() and targetPly:GetNWBool("body_searched", false) then
            return ROLE_COLORS_SCOREBOARD[ROLE_RAT], "vgui/ttt/roles/rat/tab_rat.png"
        else
            return ROLE_COLORS_SCOREBOARD[ROLE_TRAITOR], "vgui/ttt/roles/traitor/tab_traitor.png"
        end
    end

    if localPly:IsRat() and targetPly:IsTraitorTeam() and GetConVar("ttt_rat_show_traitors_scoreboard"):GetBool() then
        return ROLE_COLORS_SCOREBOARD[ROLE_TRAITOR], "vgui/ttt/roles/traitor/tab_traitor.png"
    end
end)

hook.Add("TTTTutorialRoleText", "Rat Tutorial Role Text", function(playerRole)
    local function getStyleString(role)
        local roleColor = ROLE_COLORS[role]
        return "<span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>"
    end

    if playerRole == ROLE_RAT then
        local divStart = "<div style='margin-top: 10px;'>"
        local styleEnd = "</span>"

        local html = "The " .. ROLE_STRINGS[ROLE_RAT] .. " is a member of the " .. getStyleString(ROLE_INNOCENT) .. "innocent team" .. styleEnd .. " whose job is to strategically out the " .. getStyleString(ROLE_INNOCENT) .. ROLE_STRINGS_EXT[ROLE_TRAITOR] .. styleEnd .. " without drawing suspicion away from the them and onto the " .. ROLE_STRINGS[ROLE_RAT] .. "."

        html = html .. divStart .. "The " .. ROLE_STRINGS[ROLE_RAT] .. "can see the " .. ROLE_STRINGS_EXT[ROLE_TRAITOR] .. " and appears as a generic " .. ROLE_STRINGS[ROLE_TRAITOR] .. " to them,"
        
        local style = GetConVar("ttt_rat_damage_style"):GetInt()
        if style == 1 then
            html = html .. " but does severely reduced damage against them.</div>"
        elseif style == 2 then
            html = html .. " and can damage, but not outright kill, any of them.</div>"
        elseif style == 3 then
            html = html .. " and is able to otherwise regularly damage them.</div>"
        elseif style == 4 then
            html = html .. "but cannot deal damage until they are the last remaining innocent.</div>"
        else
            html = html .. "</div>"
        end

        html = html .. divStart .. "If an " .. getStyleString(ROLE_INNOCENT) .. ROLE_STRINGS[ROLE_INNOCENT] .. styleEnd .. " or " .. getStyleString(ROLE_DETECTIVE) .. detective .. styleEnd .. " kills a " .. ROLE_STRINGS[ROLE_RAT] .. ", their corpse will show them as a " .. ROLE_STRINGS[ROLE_TRAITOR] .. ".\n"
        
        html = html .. "If a " .. getStyleString(ROLE_TRAITOR) .. ROLE_STRINGS[ROLE_TRAITOR] .. styleEnd .. " kills them, their corpse show as an " .. ROLE_STRINGS[ROLE_INNOCENT] .. ".\n"
        
        html = html .. "If a " .. getStyleString(ROLE_TEAM_MONSTER) .. ROLE_STRINGS[ROLE_TEAM_MONSTER] .. styleEnd .. ", " .. getStyleString(ROLE_JESTER) .. ROLE_STRINGS[ROLE_JESTER] .. styleEnd .. ", or " .. getStyleString(ROLE_TEAM_INDEPENDENT) .. ROLE_STRINGS[ROLE_TEAM_INDEPENDENT] .. styleEnd .. " kills them, they show as a " .. ROLE_STRINGS[ROLE_RAT] .. ".</div>"

        html = html .. divStart .. "The " .. ROLE_STRINGS[ROLE_RAT] .. " is largely a cowardly role. Positioning yourself to not be killed by an " .. ROLE_STRINGS[ROLE_INNOCENT] .. " is just as important as knowing when to reveal who the " .. ROLE_STRINGS_EXT[ROLE_TRAITOR] .. "are.</div>"

        return html
    end
end)