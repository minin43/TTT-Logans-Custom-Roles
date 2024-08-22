-- Logan Christianson

local shopIcon = "vgui/ttt/roles/pro/.png"
local numColsVar = CreateClientConVar("ttt_bem_cols", 4, true, false, "Sets the number of columns in the Traitor/Detective menu's item list.")
local numRowsVar = CreateClientConVar("ttt_bem_rows", 5, true, false, "Sets the number of rows in the Traitor/Detective menu's item list.")
local itemSizeVar = CreateClientConVar("ttt_bem_size", 64, true, false, "Sets the item size in the Traitor/Detective menu's item list.")
local color_darkened = Color(255, 255, 255, 80)

local function DoesValueMatch(item, data, value)
    if not item[data] then return false end

    local itemdata = item[data]
    if isfunction(itemdata) then
        itemdata = itemdata()
    end
    return itemdata and StringFind(StringLower(LANG.TryTranslation(itemdata)), StringLower(value), 1, true)
end

local function SetupPanel(propertySheet)
    local credits = LocalPlayer():GetCredits()
    local hasCredits = credits > 0
    local color = Color(255, 255, 255, 255)
    if credits < 1 then color = Color(220, 60, 60, 255) end

    local availableWeapons = {Primaries = {}, Secondaries = {}, Grenades = {}}

    local function IsValidCustomBase(weapon)
        return weapon.WeaponID and weapon.Primary -- What else?
    end

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

        if isGrenadeSlot then
            return {
                id = weapon.ClassName,
                material = weapon.Icon or "vgui/ttt/icon_id",
                model = equipData.model or equipData.WorldModel or "models/weapons/w_bugbait.mdl",
                name = name,
                damage = "---",
                firerate = "---",
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
        if (swep.Base == "weapon_tttbase" or swep.Base == "weapon_tttbasegrenade" or IsValidCustomBase(swep)) and swep.Spawnable and swep.AutoSpawnable then
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
    local dlist = vgui.Create("EquipSelect", dequip)
    dlist:SetPos(0, dsearchheight + dsearchpadding)
    dlist:SetSize(dlistWide, dlistHeight - dsearchheight - dsearchpadding)
    dlist:EnableVerticalScrollbar()
    dlist:EnableHorizontal(true)

    local bw, bh = 102, 25

    -- Whole right column
    local dih = frameHeight - bh - margin * 5
    -- local dinfoWide = frameWide - dlistWide - margin*6 - 2
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

    dlist.OnActivePanelChanged = function(self, _, new)
        if new and new.item then
            for k, v in pairs(new.item) do
                if dfields[k] then
                    dfields[k]:SetText(LANG.TryTranslation(v))
                    dfields[k]:SetAutoStretchVertical(true)
                    dfields[k]:SetWrap(true)
                end
            end
        else
            for _, v in pairs(dfields) do
                if v then
                    v:SetText("---")
                    v:SetAutoStretchVertical(true)
                    v:SetWrap(true)
                end
            end
        end

        -- dconfirm:SetDisabled() -- TODO
    end

    local dhelp = vgui.Create("DPanel", dinfobg)
    dhelp:SetPaintBackground(false)
    dhelp:SetSize(dinfoWide, 64)
    dhelp:MoveBelow(dinfo, margin)

    local function FillEquipmentListWithSlot(itemlist, isDisabled)
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
                icon.Disabled = true
            end

            dlist:AddPanel(icon)
        end
    end

    local function FillOutListRow(numberOfIcons)
        local actualCount = numberOfIcons + 1
        local toFill = actualCount % 4

        for i = 1, toFill do
            print("creating empty panel")
            local panel = vgui.Create("DPanel")
            -- panel:SetSize(itemSize, itemSize)
            panel.Paint = function() end

            dlist:AddPanel(panel)
        end
    end

    local function FillEquipmentList(allItems)
        dlist:Clear()

        local primHeader = vgui.Create("DPanel")
        primHeader:SetSize(itemSize, itemSize)
        primHeader.Paint = function()
            surface.SetDrawColor(0, 0, 0)
            surface.DrawRect(0, 0, primHeader:GetWide(), primHeader:GetTall())
            draw.SimpleText("Primary Slot")
        end
        dlist:AddPanel(primHeader)
        FillEquipmentListWithSlot(allItems.Primaries, true) -- TODO determine when to disable the weapons due to what player is holding
        FillOutListRow(#allItems.Primaries)

        local secHeader = vgui.Create("DPanel", dlist)
        secHeader.Paint = function()
            draw.SimpleText("Secondary Slot")
        end
        dlist:AddPanel(secHeader)
        FillEquipmentListWithSlot(allItems.Secondaries, false)
        FillOutListRow(#allItems.Secondaries)

        local grenHeader = vgui.Create("DPanel", dlist)
        grenHeader.Paint = function()
            draw.SimpleText("Tertiary Slot")
        end
        dlist:AddPanel(grenHeader)
        FillEquipmentListWithSlot(allItems.Grenades, false)
        -- FillOutListRow(#allItems.Grenades) -- This necessary?

        dlist:SelectPanel(dlist:GetItems()[2])
    end

    dsearch.OnValueChange = function(_, value)
        -- local roleitems = GetEquipmentForRole(ply:GetRole(), ply:IsDetectiveLike() and not ply:IsDetectiveTeam(), false)
        local filtered = {}
        for _, tbl in pairs(availableWeapons) do
            for _, wep in pairs(tbl) do
                if v and DoesValueMatch(wep, "name", value) then
                    TableInsert(filtered, wep)
                end
            end
        end
        FillEquipmentList(filtered)
    end

    dhelp:SizeToContents()

    -- local dconfirm = vgui.Create("DButton", dinfobg)
    -- dconfirm:SetPos(0, dih - bh * 2)
    -- dconfirm:SetSize(bw, bh)
    -- dconfirm:SetDisabled(true)
    -- dconfirm:SetText(LANG.GetTranslation("equip_confirm"))

    -- local creditsPnl = vgui.Create("DPanel", dequip) -- dinfobg) ?
    -- creditsPnl:SetPaintBackground(false)
    -- creditsPnl:SetHeight(32)
    -- creditsPnl:SetPos(dequip:GetWide() * 0.6, dequip:GetTall() - 32)

    -- local img = vgui.Create("DImage", dequip)
    -- img:SetSize(32, 32)
    -- img:CopyPos(creditsPnl)
    -- img:SetImage("vgui/ttt/equip/coin.png")
    -- img:SetImageColor(color)

    -- local lbl = vgui.Create("DLabel", dequip)
    -- lbl:CopyPos(creditsPnl)
    -- lbl:MoveRightOf(img)
    -- lbl:SetTextColor(color)
    -- lbl:SetFont("DermaLarge")
    -- lbl:SetText(credits)
    -- lbl:SizeToContents()

    FillEquipmentList(availableWeapons)
    return dequip
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

        html = html .. ", they are instead able to purchase any naturally-spawning weapons from their " .. getStyleString(ROLE_TRAITOR) .. "traitor shop" .. styleEnd .. ", along with ammo refills for them.</div>"

        local bonus = (GetConVar("ttt_professional_damage_buff"):GetFloat() - 1) * 100
        html = html .. divStart .. "As a result of their professional efficiency, they also receive a bonus " .. bonus .. "% damage buff to the weapons they're firing. It pays to know your craft!</div>"

        return html
    end
end)