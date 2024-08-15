-- Logan Christianson

hook.Add("TTTTutorialRoleText", "Sheriff Tutorial Role Text", function(playerRole)
    local function getStyleString(role)
        local roleColor = ROLE_COLORS[role]
        return "<span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>"
    end

    if playerRole == ROLE_SHERIFF then
        local divStart = "<div style='margin-top: 10px;'>"
        local styleEnd = "</span>"

        local html = "The " .. ROLE_STRINGS[ROLE_SHERIFF] .. " is a member of the " .. getStyleString(ROLE_DETECTIVE) .. ROLE_STRINGS[ROLE_DETECTIVE] .. " team" .. styleEnd .. " whose goal is to find and eliminate all Innocent team enemies."

        html = html .. divStart .. "They have access to the regular assortment of " .. ROLE_STRINGS[ROLE_DETECTIVE] .. " equipment, but with an added twist:<ul style='margin-bottom: 0px; padding-bottom: 0px;'>"

        html = html .. "<li>They are unable to hold any primary weapons (most weapons in slot 3), but receive a general damage buff to all sidearms used</li>"

        html = html .. "<li>If enabled on the server, for the first second after equipping a secondary weapon (most weapons in slot 2), the first bullet fired receives a major damage bonus, instantly killing any terrorist it damages</li>"

        html = html .. "<li>If enabled on the server, the instant-kill effect may continue after each kill, as long as no bullet is missed</li></ul></div>"

        return html
    end
end)