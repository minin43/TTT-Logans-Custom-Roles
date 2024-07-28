-- Logan Christianson

local weaponPanel = {}
weaponPanel.WeaponTable = {}
weaponPanel.WeaponName = "None Selected!"
weaponPanel.Damage = 0
weaponPanel.Firerate = 0
weaponPanel.Recoil = 0
weaponPanel.Accuracy = 0
weaponPanel.Magazine = 0

function weaponPanel:SetWeaponTable(weaponTable, isGrenade)
    self.WeaponTable = weaponTable
    self.WeaponName = weaponTable.PrintName

    if not isGrenade then
        self.Damage = math.max(weaponTable.Primary.Damage, 1)
        self.Firerate = math.Round(1 / weaponTable.Primary.Delay  * 60)
        self.Recoil = math.Clamp(weaponTable.Primary.Recoil * 10, 1, 100)
        self.Accuracy = math.Clamp(0.5 / weaponTable.Primary.Cone, 1, 100)
        self.Magazine = math.max(weaponTable.Primary.ClipSize, 1)
    end
end

function weaponPanel:Paint(w, h)
    if not self then return end

    draw.SimpleText(self.WeaponName, "cool_large", 4, 4, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    draw.SimpleText("DAMAGE: " + self.Damage, "DermaDefault", 4, h * 0.5, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText("FIRERATE: " + self.Firerate + " RPM", "DermaDefault", 4, h - 4, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    draw.SimpleText("RECOIL: " + self.Recoil + "%", "DermaDefault", w - 4, 4, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
    draw.SimpleText("ACCURACY: " + self.Accuracy + "%", "DermaDefault", w - 4, h * 0.5, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    draw.SimpleText("MAGAZINE: " + self.Magazine, "DermaDefault", w - 4, h - 4, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
end

vgui.Register("ArmoryWeaponPanel", weaponPanel, "DPanel")

local armoryColumn = {}
armoryColumn.Disabled = false
armoryColumn.HasSlot = false
armoryColumn.IsGrenade = false
armoryColumn.Sweps = []

function armoryColumn:SetDisabled(disabled)
    self.Disabled = disabled
end

function armoryColumn:SetIsGrenade(isGrenade)
    self.IsGrenade = isGrenade
end

function armoryColumn:SetHasSlot(hasSlot)
    self.HasSlot = hasSlot

    self:RefreshPanel()
end

function armoryColumn:SetSweps(sweps)
    self.Sweps = []
    
    for _, className in ipairs(sweps) do
        local tab = weapons.Get(className)
        tab.ClassName = className

        table.insert(self.Sweps, tab)
    end

    self:RefreshPanel()
end

function armoryColumn:RefreshPanel()
    if self.TopPanel then
        self.TopPanel:Remove()
        self.TopPanel = nil
    end

    if self.BottomPanel then
        self.BottomPanel:Remove()
        self.BottomPanel = nil
    end

    if self.HasSlot then
        -- TODO
    else
        self.TopPanel = vgui.Create("ArmoryWeaponPanel", self)
        self.TopPanel:SetPos(0, 0)
        self.TopPanel:SetSize(self:GetWide(), self:GetTall() * 0.33)

        self.BottomPanel = vgui.Create("DListView", self)
        self.BottomPanel:SetPos(0, self:GetTall() * 0.33)
        self.BottomPanel:SetSize(self:GetWide(), self:GetTall() * 0.66)
        self.BottomPanel:AddColumn("Weapon")
        self.BottomPanel:AddColumn("")
        self.BottomPanel.OnRowSelected = function(pnl, index, row)
            self.TopPanel:SetWeaponTable(self.Sweps[index], self.IsGrenade)
        end

        for _, wepTable in ipairs(self.Sweps) do
            local buyButton = vgui.Create("DButton", self.BottomPanel) -- TODO set size/pos?
            buyButton:SetText("PURCHASE")
            buyButton.DoClick = function()
                net.Start("ProfessionalArmoryBuyWep")
                    net.WriteString(wepTable.ClassName)
                net.SendToServer()

                -- TODO refresh the page?
            end

            self.BottomPanel:AddLine(wepTable.PrintName, buyButton)
        end
    end
end

vgui.Register("ArmoryColumn", armoryColumn, "DPanel")