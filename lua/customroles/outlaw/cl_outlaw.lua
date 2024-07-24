// Logan Christianson

hook.Add("TTTRadarPlayerRender", "Outlaw Radar", function(localPly, targetData, pingColor, pingIsHidden)
    if targetData.role == ROLE_OUTLAW and not localPly:IsTeamTraitor() then
        return pingColor, true
    end
end)