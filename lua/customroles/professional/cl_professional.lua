-- Logan Christianson

local shopIcon = "vgui/ttt/roles/pro/.png"
local numColsVar = CreateClientConVar("ttt_bem_cols", 4, true, false, "Sets the number of columns in the Traitor/Detective menu's item list.")
local numRowsVar = CreateClientConVar("ttt_bem_rows", 5, true, false, "Sets the number of rows in the Traitor/Detective menu's item list.")
local itemSizeVar = CreateClientConVar("ttt_bem_size", 64, true, false, "Sets the item size in the Traitor/Detective menu's item list.")
local color_darkened = Color(255, 255, 255, 80)
local emptyIcon = "vgui/ttt/roles/pro/icon_template.png"
local tabIcon = "vgui/ttt/roles/pro/ammo-box.png"

local function DoesValueMatch(item, data, value)
    local itemdata = item[data]

    if not itemdata then return false end

    return string.find(string.lower(LANG.TryTranslation(itemdata)), string.lower(value), 1, true)
end

local function SetupPanel(propertySheet)
    local credits = LocalPlayer():GetCredits()
    local hasCredits = credits > 0
    local color = Color(255, 255, 255, 255)
    if credits < 1 then color = Color(220, 60, 60, 255) end

    local availableWeapons = {Primaries = {}, Secondaries = {}, Grenades = {}}

    local function ExtractWeaponInfo(weapon, isGrenadeSlot)
        local equipData = weapon.EquipMenuData or {}
        local primary = weapon.Primary or {}

        local name = weapon.ShopName or weapon.PrintName or "Unnamed weapon"
        local damage = "Damage: " .. math.max(weapon.Damage or primary.Damage or 0, 1)
        local firerate = "Firerate: " .. math.Round(1 / (weapon.FireDelay or primary.Delay or 1) * 60) .. " RPM"
        local recoil = "Recoil: " .. math.Clamp((weapon.Recoil or primary.Recoil or 0) * 10, 1, 100) .. "%"
        local accuracy = "Accuracy: " .. math.Round(math.Clamp(0.5 / (weapon.Cone or weapon.AimSpread or primary.Cone or 0), 1, 100)) .. "%"
        local magazine = "Magazine: " .. (primary.ClipSize or 0) .. " round(s)"
        local ammo = "Ammo: " .. (weapon.Ammo or primary.Ammo or "None")

        if primary.NumShots or weapon.Shots then
            damage = "Damage: " .. math.max((weapon.Damage or primary.Damage or 1) * (primary.NumShots or weapon.Shots), 1)
        end

        if isGrenadeSlot then
            return {
                id = weapon.ClassName,
                material = weapon.Icon or "vgui/ttt/icon_id",
                model = equipData.model or equipData.WorldModel or "models/weapons/w_bugbait.mdl",
                name = name,
                damage = "",
                firerate = "",
                recoil = "",
                accuracy = "",
                magazine = "",
                ammo = ""
            }
        else
            return {
                id = weapon.ClassName,
                material = weapon.Icon or "vgui/ttt/icon_id",
                model = equipData.model or equipData.WorldModel or "models/weapons/w_bugbait.mdl",
                name = name,
                damage = damage,
                firerate = firerate,
                recoil = recoil,
                accuracy = accuracy,
                magazine = magazine,
                ammo = ammo
            }
        end
    end

    for _, swep in pairs(weapons.GetList()) do
        if (swep.Base == "weapon_tttbase" or swep.Base == "weapon_tttbasegrenade" or ProfessionalIsValidCustomWeaponBase(swep)) and swep.Spawnable and swep.AutoSpawnable then
            if swep.Slot == 2 then table.insert(availableWeapons.Primaries, ExtractWeaponInfo(swep))
            elseif swep.Slot == 1 then table.insert(availableWeapons.Secondaries, ExtractWeaponInfo(swep))
            elseif swep.Slot == 3 then table.insert(availableWeapons.Grenades, ExtractWeaponInfo(swep, true))
            end 
        end
    end

    local numCols = GetGlobalInt("ttt_bem_sv_cols", 4)
    local numRows = GetGlobalInt("ttt_bem_sv_rows", 5)
    local itemSize = GetGlobalInt("ttt_bem_sv_size", 64)

    if GetGlobalBool("ttt_bem_allow_change", true) then
        numCols = numColsVar:GetInt()
        numRows = numRowsVar:GetInt()
        itemSize = itemSizeVar:GetInt()
    end

    local margin = 5
    local dlistWide = ((itemSize + 2) * numCols) - 2 + 15
    local dlistHeight = ((itemSize + 2) * numRows) - 2 + 45
    local dinfoWide = 270
    local frameWide = dlistWide + dinfoWide + (margin * 4)
    local frameHeight = dlistHeight + 75
    local padding = propertySheet:GetPadding()

    local dequip = vgui.Create("DPanel", propertySheet)
    dequip:SetPaintBackground(false)
    dequip:StretchToParent(padding, padding, padding, padding)

    local dsearchheight = 25
    local dsearchpadding = 5
    local dsearch = vgui.Create("DTextEntry", dequip)
    dsearch:SetPos(0, 0)
    dsearch:SetSize(dlistWide, dsearchheight)
    dsearch:SetPlaceholderText("Search...")
    dsearch:SetUpdateOnType(true)
    local dframe = propertySheet:GetParent()
    dsearch.OnGetFocus = function() dframe:SetKeyboardInputEnabled(true) end
    dsearch.OnLoseFocus = function() dframe:SetKeyboardInputEnabled(false) end

    --- Construct icon listing
    local listHeaderHeight = 16
    local headerMargin = 4
    local pListHeight = (itemSize + 2) * 2 + 2
    local dlistPFrame = vgui.Create("DPanel", dequip)
    dlistPFrame:SetPos(0, dsearchheight + dsearchpadding)
    dlistPFrame:SetSize(dlistWide, pListHeight + listHeaderHeight)
    dlistPFrame.Paint = function()
        draw.DrawText("Primaries", "TabLarge", headerMargin)
    end
    local dlistP = vgui.Create("EquipSelect", dlistPFrame)
    dlistP:SetPos(0, listHeaderHeight)
    dlistP:SetSize(dlistWide, pListHeight)
    dlistP:EnableVerticalScrollbar()
    dlistP:EnableHorizontal(true)

    local remainingListHeight = (dlistHeight - dsearchheight - dsearchpadding - dlistPFrame:GetTall()) / 2
    local dlistSFrame = vgui.Create("DPanel", dequip)
    dlistSFrame:SetPos(0, dsearchheight + dsearchpadding + dlistPFrame:GetTall())
    dlistSFrame:SetSize(dlistWide, remainingListHeight)
    dlistSFrame.Paint = function()
        draw.DrawText("Secondaries", "TabLarge", headerMargin)
    end
    local dlistS = vgui.Create("EquipSelect", dlistSFrame)
    dlistS:SetPos(0, listHeaderHeight)
    dlistS:SetSize(dlistWide, remainingListHeight - listHeaderHeight)
    dlistS:EnableVerticalScrollbar()
    dlistS:EnableHorizontal(true)

    local dlistGFrame = vgui.Create("DPanel", dequip)
    dlistGFrame:SetPos(0, dsearchheight + dsearchpadding + dlistPFrame:GetTall() + dlistSFrame:GetTall())
    dlistGFrame:SetSize(dlistWide, remainingListHeight)
    dlistGFrame.Paint = function()
        draw.DrawText("Grenades/Tertiary", "TabLarge", headerMargin)
    end
    local dlistG = vgui.Create("EquipSelect", dlistGFrame)
    dlistG:SetPos(0, listHeaderHeight)
    dlistG:SetSize(dlistWide, remainingListHeight - listHeaderHeight)
    dlistG:EnableVerticalScrollbar()
    dlistG:EnableHorizontal(true)

    local bw, bh = 102, 25

    -- Whole right column
    local dih = frameHeight - bh - margin * 5
    local dinfobg = vgui.Create("DPanel", dequip)
    dinfobg:SetPaintBackground(false)
    dinfobg:SetSize(dinfoWide - margin, dih)
    dinfobg:SetPos(dlistWide + margin, 0)

    -- item info pane
    local dinfo = vgui.Create("ColoredBox", dinfobg)
    dinfo:SetColor(Color(90, 90, 95))
    dinfo:SetPos(0, 0)
    dinfo:StretchToParent(0, 0, margin * 2, 105)

    local dfields = {}
    dfields.name = vgui.Create("DLabel", dinfo)
    dfields.name:SetWidth(dinfoWide - margin * 6)
    dfields.name:SetPos(margin * 3, margin * 2)
    dfields.name:SetFont("TabLarge")

    for i, k in pairs({ "damage", "firerate", "recoil", "accuracy", "magazine", "ammo" }) do
        dfields[k] = vgui.Create("DLabel", dinfo)
        dfields[k]:SetWidth(dinfoWide - margin * 3)
        dfields[k]:SetFont("DermaDefault")

        local rowMult = math.Round(i * 0.5)
        if i % 2 == 1 then
            dfields[k]:SetPos(margin * 3, margin * 2 + (dfields.name:GetTall() * rowMult))
        else
            dfields[k]:SetPos((0.5 * dinfoWide) + margin * 3, margin * 2 + (dfields.name:GetTall() * rowMult))
        end
    end

    dfields.name:SetFont("TabLarge")

    -- item info, ammo subpanels
    local primary, secondary, grenade = nil, nil, nil
    local primaryName, secondaryName = "No Weapon", "No Weapon"
    local clr = Color(210, 210, 210)

    local dinfoEquip = vgui.Create("DPanel", dinfo)
    dinfoEquip:SetPos(0, dinfo:GetTall() / 3)
    dinfoEquip:SetSize(dinfo:GetWide(), dinfo:GetTall() / 3 * 2)
    dinfoEquip.Paint = function(_, w, h)
        surface.SetDrawColor(255, 255, 255)
        surface.DrawLine(w * 0.5, 3, w * 0.5, h - 2)
        surface.DrawLine(3, 0, w - 3, 0)

        draw.DrawText("Equipped\nPrimary", "TabLarge", w * 0.25, 8, clr, TEXT_ALIGN_CENTER)
        draw.DrawText("Equipped\nSecondary", "TabLarge", w * 0.75, 8, clr, TEXT_ALIGN_CENTER)
    end

    if not LocalPlayer():CanCarryType(WEAPON_HEAVY) then
        for k, v in ipairs(ply:GetWeapons()) do
            if v:GetSlot() == 2 and v:GetSlotPos() == 0 then
                primary = v
            end
        end
    end
    if not LocalPlayer():CanCarryType(WEAPON_PISTOL) then
        for k, v in ipairs(ply:GetWeapons()) do
            if v:GetSlot() == 1 and v:GetSlotPos() == 0 then
                secondary = v
            end
        end
    end
    if not LocalPlayer():CanCarryType(WEAPON_NADE) then
        for k, v in ipairs(ply:GetWeapons()) do
            if v:GetSlot() == 3 and v:GetSlotPos() == 1000 then
                grenade = v
            end
        end
    end

    local buttonHeight = (dinfoEquip:GetTall() * 0.85) - (bh * 0.5)
    local pammo = vgui.Create("DButton", dinfoEquip)
    pammo:SetPos((dinfoEquip:GetWide() * 0.25) - (bw * 0.5), buttonHeight)
    pammo:SetSize(bw, bh)
    pammo:SetDisabled(true)
    pammo:SetText("Buy Ammo")
    pammo.DoClick = function()
        net.Start("ProfessionalArmoryBuyAmmo")
            net.WriteString(primary:GetClass())
        net.SendToServer()

        dframe:Close()
    end

    local sammo = vgui.Create("DButton", dinfoEquip)
    sammo:SetPos((dinfoEquip:GetWide() * 0.75) - (bw * 0.5), buttonHeight)
    sammo:SetSize(bw, bh)
    sammo:SetDisabled(true)
    sammo:SetText("Buy Ammo")
    sammo.DoClick = function()
        net.Start("ProfessionalArmoryBuyAmmo")
            net.WriteString(secondary:GetClass())
        net.SendToServer()

        dframe:Close()
    end

    local function CreateEmptyIcon(x, y)
        local icon = vgui.Create("SimpleIcon", dinfoEquip)
        icon:SetIconSize(itemSize)
        icon:SetIcon(emptyIcon)
        icon:SetPos(x, y)
    end

    local pIconX = (dinfoEquip:GetWide() * 0.25) - (itemSize * 0.5)
    local iconY = (dinfoEquip:GetTall() * 0.45) - (itemSize * 0.5)
    if primary then
        local primaryName = primary.ShopName or primary.PrintName or "Unnamed weapon"

        local icon = vgui.Create("SimpleIcon", dinfoEquip)
        icon:SetIconSize(itemSize)
        icon:SetIcon(primary.Icon)
        icon:SetTooltip(LANG.TryTranslation(primaryName))
        icon:SetPos(pIconX, iconY)

        local iconLabel = vgui.Create("DLabel", dinfoEquip)
        iconLabel:SetText(primaryName)
        iconLabel:SizeToContents()
        iconLabel:SetPos((dinfoEquip:GetWide() * 0.25) - (iconLabel:GetWide() * 0.5), (dinfoEquip:GetTall() * 0.45) + (itemSize * 0.5) + 2)

        pammo:SetDisabled(not LocalPlayer():ProfessionalCanRefillAmmoByWeaponClass(primary:GetClass()) or not hasCredits)
    else
        CreateEmptyIcon(pIconX, iconY)
    end

    local sIconX = (dinfoEquip:GetWide() * 0.75) - (itemSize * 0.5)
    if secondary then
        local secondaryName = secondary.ShopName or secondary.PrintName or "Unnamed weapon"

        local icon = vgui.Create("SimpleIcon", dinfoEquip)
        icon:SetIconSize(itemSize)
        icon:SetIcon(secondary.Icon)
        icon:SetTooltip(LANG.TryTranslation(secondaryName))
        icon:SetPos(sIconX, iconY)

        local iconLabel = vgui.Create("DLabel", dinfoEquip)
        iconLabel:SetText(secondaryName)
        iconLabel:SizeToContents()
        iconLabel:SetPos((dinfoEquip:GetWide() * 0.75) - (iconLabel:GetWide() * 0.5), (dinfoEquip:GetTall() * 0.45) + (itemSize * 0.5) + 2)

        sammo:SetDisabled(not LocalPlayer():ProfessionalCanRefillAmmoByWeaponClass(secondary:GetClass()) or not hasCredits)
    else
        CreateEmptyIcon(sIconX, iconY)
    end

    local function FillEquipmentListWithSlot(dlist, itemlist, isDisabled)
        for _, item in pairs(itemlist) do
            local icon = nil

            if item.material then
                icon = vgui.Create("LayeredIcon", dlist)
                icon:SetIconSize(itemSize)
                icon:SetIcon(item.material)
            elseif item.model then
                icon = vgui.Create("SpawnIcon", dlist)
                icon:SetModel(item.model)
            else
                ErrorNoHalt("Equipment item has both invalid material and model specified: " .. tostring(item) .. "\n")
                continue
            end

            icon.item = item
            icon:SetTooltip(LANG.TryTranslation(item.name))

            if isDisabled then
                icon:SetIconColor(color_darkened)
                icon:SetTooltip("Weapon already equipped in this slot!")
                icon.Disabled = true
            end

            dlist:AddPanel(icon)
        end
    end

    local function FillEquipmentList(allItems)
        dlistP:Clear()
        dlistS:Clear()
        dlistG:Clear()

        FillEquipmentListWithSlot(dlistP, allItems.Primaries, primary)
        FillEquipmentListWithSlot(dlistS, allItems.Secondaries, secondary)
        FillEquipmentListWithSlot(dlistG, allItems.Grenades, grenade)

        dlistP:SelectPanel(dlistP:GetItems()[1])
    end

    dsearch.OnValueChange = function(_, value)
        local filtered = {Primaries = {}, Secondaries = {}, Grenades = {}}
        for slot, tbl in pairs(availableWeapons) do
            for _, wep in pairs(tbl) do
                if v and DoesValueMatch(wep, "name", value) then
                    TableInsert(filtered[slot], wep)
                end
            end
        end

        FillEquipmentList(filtered)
    end

    local selectedGun = nil
    local dconfirm = vgui.Create("DButton", dinfobg)
    dconfirm:SetPos(0, dih - bh * 2)
    dconfirm:SetSize(bw, bh)
    dconfirm:SetDisabled(true)
    dconfirm:SetText(LANG.GetTranslation("equip_confirm"))
    dconfirm.DoClick = function()
        if selectedGun then
            net.Start("ProfessionalArmoryBuyWep")
                net.WriteString(selectedGun)
            net.SendToServer()

            dframe:Close()
        end
    end

    local creditsPnl = vgui.Create("DPanel", dequip)
    creditsPnl:SetPaintBackground(false)
    creditsPnl:SetHeight(32)
    creditsPnl:SetPos(dequip:GetWide() * 0.5 + 13, dequip:GetTall() - 72 - 17)

    local img = vgui.Create("DImage", dequip)
    img:SetSize(32, 32)
    img:CopyPos(creditsPnl)
    img:SetImage("vgui/ttt/equip/coin.png")
    img:SetImageColor(color)

    local lbl = vgui.Create("DLabel", dequip)
    lbl:CopyPos(creditsPnl)
    lbl:MoveRightOf(img, 7)
    lbl:SetTextColor(color)
    lbl:SetFont("DermaLarge")
    lbl:SetText(credits)
    lbl:SizeToContents()

    local function ResetSelectPanelsPaint(panelList)
        for _, pnl in ipairs(panelList:GetItems()) do
            pnl.PaintOver = function() end
        end
    end

    local function onActivePanelChanged(self, _, new)
        if new and new.item then
            selectedGun = new.item.id

            if dlistP == self then
                ResetSelectPanelsPaint(dlistS)
                ResetSelectPanelsPaint(dlistG)
            elseif dlistS == self then
                ResetSelectPanelsPaint(dlistP)
                ResetSelectPanelsPaint(dlistG)
            elseif dlistG == self then
                ResetSelectPanelsPaint(dlistS)
                ResetSelectPanelsPaint(dlistP)
            end

            for k, v in pairs(new.item) do
                if dfields[k] then
                    dfields[k]:SetText(LANG.TryTranslation(v))
                    dfields[k]:SetAutoStretchVertical(true)
                    dfields[k]:SetWrap(true)
                end
            end
        else
            selectedGun = nil

            for _, v in pairs(dfields) do
                if v then
                    v:SetText("---")
                    v:SetAutoStretchVertical(true)
                    v:SetWrap(true)
                end
            end
        end

        dconfirm:SetDisabled(new.Disabled or not hasCredits)
    end
    dlistP.OnActivePanelChanged = onActivePanelChanged
    dlistS.OnActivePanelChanged = onActivePanelChanged
    dlistG.OnActivePanelChanged = onActivePanelChanged

    FillEquipmentList(availableWeapons)

    return dequip
end

hook.Add("TTTEquipmentTabs", "Professional Place Bounty Menu", function(propertySheet, frame)
    if LocalPlayer():IsProfessional() then
        propertySheet:AddSheet("Armory", SetupPanel(propertySheet), tabIcon, false, false, "Weapon Shop Menu")
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

        html = html .. ", they are instead able to purchase any naturally-spawning weapons from their " .. getStyleString(ROLE_TRAITOR) .. "traitor shop" .. styleEnd .. ", along with ammo refills for them.</div>"

        local bonus = (GetConVar("ttt_professional_damage_buff"):GetFloat() - 1) * 100
        html = html .. divStart .. "As a result of their professional efficiency, they also receive a bonus " .. bonus .. "% damage buff to the weapons they're firing. It pays to know your craft!</div>"

        return html
    end
end)