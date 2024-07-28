// Logan Christianson

hook.Add("TTTRadarPlayerRender", "Outlaw Radar", function(localPly, targetData, pingColor, pingIsHidden)
    if targetData.role == ROLE_OUTLAW and not localPly:IsTeamTraitor() then
        return pingColor, true
    end
end)

hook.Add("TTTTutorialRoleText", "Outlaw Tutorial Role Text", function(playerRole)
    local function getStyleString(role)
        local roleColor = ROLE_COLORS[role]
        return "<span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>"
    end

    if playerRole == ROLE_OUTLAW then
        local divStart = "<div style='margin-top: 10px;'>"
        local styleEnd = "</span>"

        local html = " The " .. ROLE_STRINGS[ROLE_OUTLAW] .. " is a member of the " .. getStyleString(ROLE_TRAITOR) .. ROLE_STRINGS[ROLE_TRAITOR] .. " team" .. styleEnd .. " whose goal is to eliminate all innocents and independents."

        html = html .. divStart .. "Existing outside the law, they do not appear on non-traitor " .. getStyleString(ROLE_DETECTIVE) .. "radar" .. styleEnd .. ", cannot be traced via the " .. getStyleString(ROLE_DETECTIVE) .. "DNA Scanner" .. styleEnd

        html = html .. ", and come equipped with a " .. getStyleString(ROLE_TRAITOR) .. "Disguiser" .. styleEnd .. ", leaving them nigh-untraceable.</div>"

        html = html .. divStart .. "This untracability comes at a cost, however, as the " .. ROLE_STRINGS[ROLE_OUTLAW] .. " has no access to any kind of traitor shop.</div>"

        return html
    end
end)