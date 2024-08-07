-- Logan Christianson

local shopIcon = "vgui/ttt/roles/pro/.png"

local function SetupPanel(propertySheet)
    local credits = LocalPlayer():GetCredits()
    local hasCredits = credits > 0
    local color = Color(255, 255, 255, 255)
    if credits < 1 then color = Color(220, 60, 60, 255) end
    
    local panel = vgui.Create("DPanel")
    panel:SetPaintBackground(false)
    panel:SetPos(0, 0)
    panel:SetSize(propertySheet:GetWide(), propertySheet:GetTall() - 85)

    local availablePrimaries = {}
    local availableSecondaries = {}
    local availableGrenades = {}

    for _, swep in pairs(weapons.GetList()) do
        if (swep.Base == "weapon_tttbase" or swep.Base == "weapon_tttbasegrenade") and swep.Spawnable and swep.AutoSpawnable then
            if swep.Slot == 2 then table.insert(availablePrimaries, swep.ClassName)
            elseif swep.Slot == 1 then table.insert(availableSecondaries, swep.ClassName)
            elseif swep.Slot == 3 then table.insert(availableGrenades, swep.ClassName)
            end 
        end
    end

    local primary = vgui.Create("ArmoryColumn", panel)
    primary:SetPos(0, 0)
    primary:SetSize(panel:GetWide() * 0.33 - 1, panel:GetTall())
    primary:SetDisabled(not hasCredits)
    primary:SetHasSlot(not LocalPlayer():CanCarryType(WEAPON_HEAVY))
    primary:SetSweps(availablePrimaries)
    primary:SetTitle("Primary")
    -- primary.Paint = function()
    --     surface.SetDrawColor(255, 0, 0)
    --     surface.DrawRect(0, 0, primary:GetWide(), primary:GetTall())
    -- end

    local secondary = vgui.Create("ArmoryColumn", panel)
    secondary:SetPos(panel:GetWide() * 0.33, 0)
    secondary:SetSize(panel:GetWide() * 0.33, panel:GetTall())
    secondary:SetDisabled(not hasCredits)
    secondary:SetHasSlot(not LocalPlayer():CanCarryType(WEAPON_PISTOL))
    secondary:SetSweps(availableSecondaries)
    secondary:SetTitle("Secondary")
    -- secondary.Paint = function()
    --     surface.SetDrawColor(0, 255, 0)
    --     surface.DrawRect(0, 0, secondary:GetWide(), secondary:GetTall())
    -- end

    local grenade = vgui.Create("ArmoryColumn", panel)
    grenade:SetPos(panel:GetWide() * 0.66, 0)
    grenade:SetSize(panel:GetWide() * 0.33, panel:GetTall())
    grenade:SetDisabled(not hasCredits)
    grenade:SetHasSlot(not LocalPlayer():CanCarryType(WEAPON_NADE))
    grenade:SetSweps(availableGrenades)
    grenade:SetIsGrenade(true)
    grenade:SetTitle("Grenade")
    -- grenade.Paint = function()
    --     surface.SetDrawColor(0, 0, 255)
    --     surface.DrawRect(0, 0, grenade:GetWide(), grenade:GetTall())
    -- end

    local creditsPnl = vgui.Create("DPanel", propertySheet)
    creditsPnl:SetPaintBackground(false)
    creditsPnl:SetHeight(32)
    creditsPnl:SetPos(propertySheet:GetWide() * 0.6, propertySheet:GetTall() - 32)

    local img = vgui.Create("DImage", propertySheet)
    img:SetSize(32, 32)
    img:CopyPos(creditsPnl)
    img:SetImage("vgui/ttt/equip/coin.png")
    img:SetImageColor(color)

    local lbl = vgui.Create("DLabel", propertySheet)
    lbl:CopyPos(creditsPnl)
    lbl:MoveRightOf(img)
    lbl:SetTextColor(color)
    lbl:SetFont("DermaLarge")
    lbl:SetText(credits)
    lbl:SizeToContents()

    return panel
end

hook.Add("TTTEquipmentTabs", "Professional Place Bounty Menu", function(propertySheet, frame)
    if LocalPlayer():IsProfessional() then
        propertySheet:AddSheet("Armory", SetupPanel(propertySheet), shopIcon, false, false, "Weapon Shop Menu")
    end
end)

hook.Add("TTTPlayerCanSendCredits", "Profesional Sending Credits", function(sender, credits, senderHasShop, senderCanSend)
    if sender == LocalPlayer() and sender:IsProfessional() then
        return false
    end
end)

hook.Add("TTTTutorialRoleText", "Professional Tutorial Text", function(playerRole)
    local function getStyleString(role)
        local roleColor = ROLE_COLORS[role]
        return "<span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>"
    end

    if playerRole == ROLE_PROFESSIONAL then
        local divStart = "<div style='margin-top: 10px;'>"
        local styleEnd = "</span>"

        local html = "The " .. ROLE_STRINGS[ROLE_PROFESSIONAL] .. " is a member of the " .. getStyleString(ROLE_TRAITOR) .. "traitor team" .. styleEnd .. " whose goal is to eliminate all innocents and independents."

        html = html .. divStart .. "The " .. ROLE_STRINGS[ROLE_PROFESSIONAL] .. " always comes prepared, and instead of a shop filled with complex and easy to misuse " .. getStyleString(ROLE_TRAITOR) .. "traitor items" .. styleEnd

        html = html .. ", they are instead able to purchase any naturally-spawning weapons from their " .. getStyleString(ROLE_TRAITOR) .. "traitor shop" .. styleEnd .. ", along with ammo refills.</div>"

        local bonus = (GetConVar("ttt_professional_damage_buff"):GetFloat() - 1) * 100
        html = html .. divStart .. "As a result of their professional efficiency, they also receive a bonus " .. bonus .. "% damage buff to the weapons they're firing. It pays to know your craft!</div>"

        return html
    end
end)