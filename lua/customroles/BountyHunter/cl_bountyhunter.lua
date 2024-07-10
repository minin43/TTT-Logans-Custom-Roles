--// Logan Christianson

local BountyHunter = BountyHunter or {}
BountyHunter.Icon16 = "vgui/ttt/roles/bhu/target16.png"
BountyHunter.Icon32 = "vgui/ttt/roles/bhu/target32.png"
BountyHunter.Icon64 = "vgui/ttt/roles/bhu/target64.png"
BountyHunter.Target = BountyHunter.Target or nil
BountyHunter.TargetHasBounty = BountyHunter.TargetHasBounty or false
BountyHunter.MarkPanelToUpdate = BountyHunter.MarkPanelToUpdate or false

local function SetupPanel(propertySheet)
    local padding = propertySheet:GetPadding()
    local credits = LocalPlayer():GetCredits()
    local hasCredits = credits > 0
    local color = Color(255, 255, 255, 255)
    if credits < 1 then color = Color(220, 60, 60, 255) end

    local bountyablePlayers = {}
    for _, ply in ipairs(player.GetAll()) do
        local group = ScoreGroup(ply)

        if group == GROUP_TERROR and not ply:IsDetectiveLike() and (ply:Alive() or (not ply:GetNWBool("body_found", false) and not ply:GetNWBool("body_searched", false))) then
            table.insert(bountyablePlayers, ply)
        end
    end
    
    local panel = vgui.Create("DPanel")
    panel:SetPaintBackground(false)
    panel:SetPos(0, 0)
    panel:SetSize(propertySheet:GetWide(), propertySheet:GetTall())
    panel.Think = function()
        if BountyHunter.MarkPanelToUpdate then
            UpdateInfo()

            BountyHunter.MarkPanelToUpdate = false
        end
    end
    panel.OnRemove = function()
        if not BountyHunter.TargetHasBounty then
            BountyHunter.Target = nil
        end
    end
    BountyHunter.Panel = panel

    local scrollBarHeader = vgui.Create("DPanel", panel)
    scrollBarHeader:SetPos(0, 0)
    scrollBarHeader:SetSize(panel:GetWide() * 0.4, 24)
    scrollBarHeader.Paint = function()
        draw.DrawText("Terrorists", "cool_large", scrollBarHeader:GetWide() * 0.5, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER)
    end

    local scrollBar = vgui.Create("DListView", panel)
    scrollBar:SetPos(0, scrollBarHeader:GetTall())
    scrollBar:SetSize(panel:GetWide() * 0.4, panel:GetTall() - scrollBarHeader:GetTall() - 40)
    scrollBar:AddColumn("Player")
    if KARMA.IsEnabled() then scrollBar:AddColumn("Karma") end
    scrollBar.OnRowSelected = function(pnl, index, row)
        BountyHunter.Target = bountyablePlayers[index]
        UpdateInfo()
    end

    for _, ply in pairs(bountyablePlayers) do
        scrollBar:AddLine(ply:Nick(), LANG.GetUnsafeLanguageTable()[util.KarmaToString(ply:GetBaseKarma())])
    end

    local info = vgui.Create("DPanel", panel)
    info:SetPos(scrollBar:GetWide() + 8, 0)
    info:SetSize(panel:GetWide() - scrollBar:GetWide() - 28, panel:GetTall() - 85)
    info.Paint = function()
        surface.SetDrawColor(90, 90, 95)
        surface.DrawRect(0, 0, info:GetWide(), info:GetTall())

        surface.SetDrawColor(0, 0, 0)
        surface.DrawOutlinedRect(0, 0, info:GetWide(), info:GetTall(), 1)
    end

    function UpdateInfo()
        if BountyHunter.InfoPanel and IsValid(BountyHunter.InfoPanel) then
            for _, panel in pairs(BountyHunter.InfoPanel:GetChildren()) do
                panel:Remove()
            end
        end
        BountyHunter.InfoPanel = info

        if BountyHunter.Target then
            local avatar = vgui.Create("DModelPanel", info)
            avatar:SetSize(194, 194)
            avatar:SetPos(info:GetWide() * 0.5 - (avatar:GetWide() * 0.5), 16)
            avatar:SetModel(BountyHunter.Target:GetModel())

            local name = vgui.Create("DPanel", info)
            name:SetPos(0, avatar:GetTall() + 16 + 8)
            name:SetSize(info:GetWide(), 24)
            name.Paint = function()
                if BountyHunter.Target then
                    draw.DrawText(BountyHunter.Target:Nick(), "cool_large", name:GetWide() * 0.5, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER)
                end
            end

            local place = vgui.Create("DButton", info)
            place:SetSize(130, 25)
            place:SetPos(8, info:GetTall() - 25 - 8)
            place:SetText("Place Bounty (1 credit)")
            place:SetTooltip("Placing a bounty consumes a credit!")
            if not hasCredits then place:SetTooltip("Not enough credits remaining!") end
            place.DoClick = function()
                propertySheet:GetParent():Remove()

                net.Start("BountyHunterSetTarget")
                    net.WriteEntity(BountyHunter.Target)
                net.SendToServer()
            end

            local rescind = vgui.Create("DButton", info)
            rescind:SetSize(130, 25)
            rescind:SetPos(info:GetWide() - 16 - rescind:GetWide(), info:GetTall() - 25 - 8)
            rescind:SetText("Rescind Bounty")
            rescind:SetTooltip("Rescinding does not refund the credit!")
            rescind.DoClick = function()
                net.Start("BountyHunterRemoveTarget")
                net.SendToServer()
            end
            if BountyHunter.TargetHasBounty then
                place:SetEnabled(false)
                rescind:SetEnabled(true)
            else
                place:SetEnabled(hasCredits)
                rescind:SetEnabled(false)
            end

            info.PaintOver = function() end
        else            
            info.PaintOver = function()
                draw.DrawText("< Select a Terrorist", "cool_large", info:GetWide() * 0.5, info:GetTall() * 0.45, Color(255, 255, 255), TEXT_ALIGN_CENTER)
            end
        end

        scrollBar:SetEnabled(not BountyHunter.TargetHasBounty)
    end
    UpdateInfo()

    local creditsPnl = vgui.Create("DPanel", panel)
    creditsPnl:SetPaintBackground(false)
    creditsPnl:SetHeight(32)
    creditsPnl:SetPos(scrollBar:GetWide() + 8, panel:GetTall() - 72)

    local img = vgui.Create("DImage", panel)
    img:SetSize(32, 32)
    img:CopyPos(creditsPnl)
    img:SetImage("vgui/ttt/equip/coin.png")
    img:SetImageColor(color)

    local lbl = vgui.Create("DLabel", panel)
    lbl:CopyPos(creditsPnl)
    lbl:MoveRightOf(img)
    lbl:SetTextColor(color)
    lbl:SetFont("DermaLarge")
    lbl:SetText(credits)
    lbl:SizeToContents()

    return panel
end

net.Receive("BountyHunterSetTargetCallback", function()
    local ply = net.ReadEntity()

    BountyHunter.Target = ply
    BountyHunter.TargetHasBounty = true
    BountyHunter.MarkPanelToUpdate = true
end)

net.Receive("BountyHunterResetTarget", function()
    BountyHunter.Target = nil
    BountyHunter.TargetHasBounty = false
    BountyHunter.MarkPanelToUpdate = true
end)

net.Receive("BountyHunterDisableMenu", function()
    BountyHunter.IsActive = false -- TODO Could alternatively still show the menu but lock it, where this just immediately hides it
end)

hook.Add("TTTEquipmentTabs", "Place Bounty Menu", function(propertySheet, frame)
    if BountyHunter.IsActive and LocalPlayer():IsDetectiveTeam() then
        propertySheet:AddSheet("Place Bounties", SetupPanel(propertySheet), BountyHunter.Icon16, false, false, "Bounty Hunter Menu")
    end
end)

hook.Add("TTTPlayerRoleChanged", "Mark Bounty Hunter Is Playing", function(ply, _, newRole)
    if newRole == ROLE_BOUNTYHUNTER then
        BountyHunter.IsActive = true
    end
end)

hook.Add("TTTBeginRound", "Set Up Bounty Hunter Radar Props", function()
    BountyHunter.RadarModeTargetOnly = GetConVar("ttt_bountyhunter_bounty_radar"):GetBool()
end)

hook.Add("TTTEndRound", "Clear Bounty Hunter Detected", function()
    BountyHunter.IsActive = false
    BountyHunter.Target = nil
    BountyHunter.TargetHasBounty = false
    BountyHunter.MarkPanelToUpdate = false
end)

hook.Add("TTTTargetIDPlayerText", "Mark Target For Bounty Hunter", function(target, localPly, text, textColor, secondaryText)
    if localPly:IsBountyHunter() and BountyHunter.IsActive and IsPlayer(target) and target == BountyHunter.Target and localPly != target then
        return "BOUNTY TARGET", ROLE_COLORS_RADAR[ROLE_TRAITOR], secondaryText
    end
end)

hook.Add("TTTRadarPlayerRender", "Bounty Hunter Radar", function(localPly, targetData, pingColor, pingIsHidden)
    local clr = pingColor
    local isHidden = pingIsHidden

    if localPly:IsBountyHunter() then
        local remaining = math.max(0, RADAR.endtime - CurTime())
        local alpha_base = 50 + 180 * (remaining / RADAR.duration)

        if BountyHunter.RadarModeTargetOnly then
            if BountyHunter.Target and targetData.sid64 == BountyHunter.Target:SteamID64() then
                clr = ColorAlpha(ROLE_COLORS_RADAR[ROLE_TRAITOR], alpha)
                isHidden = false
            end
            
            isHidden = true
        else
            if BountyHunter.Target and targetData.sid64 == BountyHunter.Target:SteamID64() then
                clr = ColorAlpha(ROLE_COLORS_RADAR[ROLE_TRAITOR], alpha)
            else
                clr = ColorAlpha(ROLE_COLORS_RADAR[ROLE_INNOCENT], alpha)
            end
        end
    end

    return clr, isHidden
end)

hook.Add("TTTTutorialRoleText", "Bounty Hunter Tutorial Text", function(playerRole)
    local function getStyleString(role)
        local roleColor = ROLE_COLORS[role]
        return "<span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>"
    end

    if playerRole == ROLE_BOUNTYHUNTER then
        local divStart = "<div style='margin-top: 10px;'>"
        local styleEnd = "</span>"

        local html = "The " .. ROLE_STRINGS[ROLE_BOUNTYHUNTER] .. " is a member of the " .. getStyleString(ROLE_INNOCENT) .. "innocent team" .. styleEnd .. " whose job is to eliminate bounties placed on other terrorist by " ..  getStyleString(ROLE_DETECTIVE) .. ROLE_STRINGS_EXT[ROLE_DETECTIVE] .. styleEnd .. ".</div>"

        html = html .. divStart .. "They effectively act as en extension of the detective, as elimination of placed bounties earns them a credit for use in a limited " .. getStyleString(ROLE_DETECTIVE) .. "shop" .. styleEnd .. ".</div>"

        html = html .. divStart .. "The " .. ROLE_STRINGS[ROLE_BOUNTYHUNTER] .. " has a damage bonus against their targets, and the targets are highlighted for easier visibility. The karma ramifications for the kill are sent to the detective who placed the bounty.</div>"

        html = html .. divStart .. "(Killing bounties... it's free real estate)</div>"
        return html
    end
end)