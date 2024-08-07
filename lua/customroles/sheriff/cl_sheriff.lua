-- Logan Christianson

hook.Add("TTTTutorialRoleText", "Sheriff Tutorial Role Text", function(playerRole)
    local function getStyleString(role)
        local roleColor = ROLE_COLORS[role]
        return "<span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>"
    end

    if playerRole == ROLE_SHERIFF then
        local divStart = "<div style='margin-top: 10px;'>"
        local styleEnd = "</span>"

        local html = " The " .. ROLE_STRINGS[ROLE_SHERIFF] .. " is a member of the " .. getStyleString(ROLE_DETECTIVE) .. ROLE_STRINGS[ROLE_DETECTIVE] .. " team" .. styleEnd .. " whose goal is to find and eliminate all Innocent team enemies."

        -- html = html .. divStart .. "Existing outside the law, they do not appear on non-traitor " .. getStyleString(ROLE_DETECTIVE) .. "radar" .. styleEnd .. ", cannot be traced via the " .. getStyleString(ROLE_DETECTIVE) .. "DNA Scanner" .. styleEnd

        -- html = html .. ", and come equipped with a " .. getStyleString(ROLE_TRAITOR) .. "Disguiser" .. styleEnd .. ", leaving them nigh-untraceable.</div>"

        -- html = html .. divStart .. "This untracability comes at a cost, however, as the " .. ROLE_STRINGS[ROLE_OUTLAW] .. " has no access to any kind of traitor shop.</div>"

        return html
    end
end)