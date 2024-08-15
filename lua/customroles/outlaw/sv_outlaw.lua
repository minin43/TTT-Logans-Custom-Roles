// Logan Christianson

hook.Add("PreRegisterSWEP", "Outlaw DNA Test Weapon Override", function(swep, class)
    if class == "weapon_ttt_wtester" then
        local oldFunc = swep.PerformScan

        swep.PerformScan = function(self, idx, repeated)
            local sample = self.ItemSamples[idx]

            if sample then
                local ply = sample.ply

                if ply and IsValid(ply) and ply:IsPlayer() and ply:IsOutlaw() then
                    self.ItemSamples[idx] = nil
                    self:Report("outlaw_dna")
                end
            end

            oldFunc(self, idx, repeated)
        end
    end
end)