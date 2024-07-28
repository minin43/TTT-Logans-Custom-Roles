// Logan Christianson

hook.Add("PreRegisterSWEP", "Outlaw DNA Test Weapon Override", function(swep, class)
    if class == "weapon_ttt_wtester" then
        local oldFunc = swep.PerformScan

        swep.PerformScan = function(self, idx, repeated)
            local sample = self.ItemSamples[idx]

            if sample then
                local ply = sample.ply

                if ply and IsValid(ply) and ply:IsPlayer() and ply:IsOutlaw() then
                    self.ItemSamples[idx] = {} -- TODO Test
                end
            end

            oldFunc.PerformScan(self, idx, repeated)
        end
    end
end)

--[[
    local function GetScanTarget(sample)
        if not sample then return end

        local target = sample.ply
        if not IsValid(target) then return end

        -- decoys always take priority, even after death
        if IsValid(target.decoy) then
            target = target.decoy
        elseif not target:IsTerror() then
            -- fall back to ragdoll, as long as it's not destroyed
            target = target.server_ragdoll
            if not IsValid(target) then return end
        end

        return target
    end

    function SWEP:PerformScan(idx, repeated)
        if self:GetCharge() < MAX_CHARGE then return end

        local sample = self.ItemSamples[idx]
        if (not sample) or (not IsValid(self:GetOwner())) then
            if repeated then self:ClearScanState() end
            return
        end

        local target = GetScanTarget(sample)
        if not IsValid(target) then
            self:Report("dna_gone")
            self:SetCharge(self:GetCharge() - 50)

            if repeated then self:ClearScanState() end
            return
        end

        local pos = target:LocalToWorld(target:OBBCenter())

        self:SendScan(pos)

        self:SetLastScanned(idx)
        self.NowRepeating = self:GetRepeating()

        local dist = math.ceil(self:GetOwner():GetPos():Distance(pos))

        self:SetCharge(math.max(0, self:GetCharge() - math.max(50, dist / 2)))
    end
]]