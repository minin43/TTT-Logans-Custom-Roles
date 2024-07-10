--// Logan Christianson

util.AddNetworkString("BountyHunterSetTarget")
util.AddNetworkString("BountyHunterSetTargetCallback")
util.AddNetworkString("BountyHunterRemoveTarget")
util.AddNetworkString("BountyHunterResetTarget")
util.AddNetworkString("BountyHunterDisableMenu")

local BountyHunter = BountyHunter or {
    Placer = nil,
    PlacerId = nil,
    Target = nil,
    TargetId = nil,
    TargetKiller = nil,
    TargetKillerId = nil
}

function BountyHunter:VerifyBounty(detectivePly, targetPly)
    -- Ignore if not detective or detective doesn't have a shop
    if not detectivePly:IsActiveShopRole() or not detectivePly:IsDetectiveTeam() then return end

    -- Ignore if detective has no credits
    if detectivePly:GetCredits() < 1 then return end

    -- Ignore if a target is already selected, bounty must be rescinded first
    if BountyHunter.Target then return end

    -- Ignore if the player is an invalid choice (already searched or confirmed innocent)
    if targetPly:IsDetectiveTeam() or targetPly:GetNWBool("body_found", false) or targetPly:GetNWBool("body_searched", false) then return end

    -- Passed all checks, NOW place bounty
    self:SetBounty(detectivePly, targetPly)
end

function BountyHunter:SetBounty(detectivePly, targetPly)
    self.Target = targetPly
    self.TargetId = targetPly:SteamID64()

    self.Placer = detectivePly
    self.PlacerId = detectivePly:SteamID64()

    detectivePly:SubtractCredits(1)

    for _, ply in ipairs(player.GetAll()) do
        if ply:IsBountyHunter() and BountyHunter:PlayerIsTarget(ply) then
            ply:ChatPrint("Detective " .. detectivePly:Nick() .. " has placed a bounty on... YOU! That's a little awkward.")
        else
            ply:ChatPrint("Detective " .. detectivePly:Nick() .. " has placed a bounty on " .. targetPly:Nick())
        end
    end
    
    if GetConVar("ttt_bountyhunter_bounty_radar"):GetBool() then
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsBountyHunter() then
                ply:GiveEquipmentItem(EQUIP_RADAR)

                timer.Simple(0, function()
                    if ply then
                        ply:ConCommand("ttt_radar_scan")
                    end
                end)
            end
        end
    end

    net.Start("BountyHunterSetTargetCallback")
        net.WriteEntity(targetPly)
    net.Broadcast()
end

function BountyHunter:RemoveBounty()
    self.Target = nil
    self.TargetId = nil
    self.TargetKiller = nil
    self.TargetKillerId = nil

    self:RemovePlacer()

    if GetConVar("ttt_bountyhunter_bounty_radar"):GetBool() then
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsBountyHunter() then
                ply:RemoveEquipmentItem(EQUIP_RADAR)
            end
        end
    end

    net.Start("BountyHunterResetTarget")
    net.Broadcast()
end

function BountyHunter:RemovePlacer()
    self.Placer = nil
    self.PlacerId = nil
end

function BountyHunter:PlayerIsPlacerDetective(ply)
    return IsValid(ply) and ply:IsPlayer() and (ply == self.Placer or ply:SteamID64() == self.PlacerId)
end

function BountyHunter:PlayerIsTarget(ply)
    return IsValid(ply) and ply:IsPlayer() and (ply == self.Target or ply:SteamID64() == self.TargetId)
end

function BountyHunter:CorpseIsTargetCorpse(corpse)
    return IsValid(corpse) and corspe.sid64 == self.TargetId
end

net.Receive("BountyHunterSetTarget", function(len, ply)
    local targetPly = net.ReadEntity()

    if not IsValid(targetPly) or not IsValid(ply) then return end

    BountyHunter:VerifyBounty(ply, targetPly)
end)

net.Receive("BountyHunterRemoveTarget", function(len, ply)
    if not ply:IsActiveShopRole() or not ply:IsDetectiveTeam() then return end

    BountyHunter:RemoveBounty()
end)

hook.Add("EntityTakeDamage", "Scale Bounty Hunter Damage", function(target, dmgInfo)
    local att = dmgInfo:GetAttacker()

    if IsValid(att) and att:IsPlayer() and att:IsBountyHunter() and BountyHunter:PlayerIsTarget(target) then
        local convar = GetConVar("ttt_bountyhunter_damage_scaling"):GetFloat()

        dmgInfo:ScaleDamage(convar or 1.1)
    end
end)

local function RefundCreditEnabled()
    return GetConVar("ttt_bountyhunter_refund_credits"):GetBool()
end

hook.Add("PlayerDisconnected", "RemoveBountyTargetOnLeave", function(ply)
    -- If target leaves after bounty is placed (but before they die)
    -- and the detective who placed the bounty is alive, refund the credit
    if BountyHunter:PlayerIsTarget(ply) and ply:Alive() then -- TODO test if alive returns true here, might need to look for another way to check that they didn't leave after dying (and so a corpse still remains)
        if IsValid(BountyHunter.Placer) and BountyHunter.Placer:Alive() and RefundCreditEnabled() then
            BountyHunter.Placer:AddCredits(1)
        end

        BountyHunter:RemoveBounty()

        for _, ply in ipairs(player.GetAll()) do
            if ply:Alive() then
                if ply:IsDetectiveTeam() then
                    if BountyHunter:PlayerIsPlacerDetective(ply) and RefundCreditEnabled() then
                        ply:ChatPrint("Bounty target has left the server, refunding your credit!")
                    else
                        ply:ChatPrint("Bounty target has left the server, a new bounty can be placed!")
                    end
                elseif ply:IsBountyHunter() then
                    ply:ChatPrint("Bounty target has left the server, waiting for a new target from the detectives...")
                end
            end
        end
    -- If the detective leaves, remove all references to them (prevent refunding credit to null player ent)
    elseif BountyHunter:PlayerIsPlacerDetective(ply) then
        BountyHunter:RemovePlacer()
    -- If there are no bounty hunters remaining in-game, disable bounty hunter menu
    -- And give placer detective back their credit
    elseif ply:IsBountyHunter() then
        for _, plyLoop in ipairs(player.GetAll()) do
            if plyLoop != ply and plyLoop:IsBountyHunter() then
                return
            end
        end

        if IsValid(BountyHunter.Placer) and BountyHunter.Placer:Alive() then
            if RefundCreditEnabled() then
                BountyHunter.Placer:AddCredits(1)
                BountyHunter.Placer:ChatPrint("The bounty hunter has left the server, refunding your credit!")
            else
                BountyHunter.Placer:ChatPrint("The bounty hunter has left the server, no new bounties can be placed!")
            end
            
            net.Start("BountyHunterDisableMenu")
            net.Broadcast()
        end
    end
end)

hook.Add("PlayerDeath", "Bounty Hunter Kills Target", function(vic, wep, att)
    if IsValid(att) and BountyHunter:PlayerIsTarget(vic) and att:IsPlayer() and att:IsBountyHunter() then
        BountyHunter.TargetKiller = att
        BountyHunter.TargetKillerId = att:SteamID64()
    end
end)

hook.Add("TTTEndRound", "Reset Bounty Hunter Props", function()
    BountyHunter.Target = nil
end)

-- This has the ability to interact strangely with fake dead bodies, I think I'm okay with the fake dead body passing this
hook.Add("TTTBodyFound", "Give Bounty Hunter Credit On Target Kill Confirmation", function(searcher, target, targetRagdoll)
    if BountyHunter:PlayerIsTarget(target) or BountyHunter:CorpseIsTargetCorpse(targetRagdoll) then
        if IsValid(BountyHunter.TargetKiller) and BountyHunter.TargetKiller:Alive() then
            BountyHunter.TargetKiller:AddCredits(1)
            BountyHunter.TargetKiller:ChatPrint("Someone has confirmed you successfully eliminated the bounty, receiving your credit now!")
        end

        for _, ply in ipairs(player.GetAll()) do
            if ply:Alive() and ply:IsDetectiveTeam() then
                ply:ChatPrint("The bounty target has been confirmed eliminated, another bounty can now be placed!")
            end
        end

        BountyHunter:RemoveBounty()
    end
end)

-- Give the karma penalty/reward to the detective instead of the bounty hunter
hook.Add("TTTKarmaGivePenalty", "Direct Negative Karma Of Killing Target To Detective", function(att, karma, vic)
    if att:IsBountyHunter() and BountyHunter:PlayerIsTarget(vic) then
        if IsValid(BountyHunter.Placer) then
            KARMA.GivePenalty(BountyHunter.Placer, karma, vic)
        end

        return true
    end
end)
hook.Add("TTTKarmaGiveReward", "Direct Positive Karma Of Killing Target To Detective", function(att, karma, vic)
    if att:IsBountyHunter() and BountyHunter:PlayerIsTarget(vic) then
        if IsValid(BountyHunter.Placer) then
            KARMA.GiveReward(BountyHunter.Placer, karma, vic)
        end

        return true
    end
end)