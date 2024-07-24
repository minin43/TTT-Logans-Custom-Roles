--// Logan Christianson

local ROLE = {}

if SERVER then
    ROLE.ConvarTargetDamageScaling = CreateConVar("ttt_bountyhunter_damage_scaling", "1.2", FCVAR_NONE, "Damage scaling to apply to damage done by a bounty hunter to their target, default is 1.2 (or 120% damage done).", 0.1, 2)
    ROLE.ConvarRefundCreditOnLeave = CreateConVar("ttt_bountyhunter_refund_credits", "1", FCVAR_NONE, "Whether to refund the detective's credits if a target or the bounty hunter leaves the game.", 0, 1)
    ROLE.ConvarCanPickUpCredits = CreateConVar("ttt_bountyhunter_can_pick_up_credits", "0", FCVAR_NONE, "Whether the Bounty Hunter should be able to pick up credits off dead bodies.", 0, 1)
end
ROLE.ConvarSpawnWithRadar = CreateConVar("ttt_bountyhunter_bounty_radar", "1", FCVAR_REPLICATED, "Whether the Bounty Hunter starts with a 'bounty-only' radar, active when a bounty is set. If set '0', the radar is instead added to their shop.", 0, 1)

ROLE.nameraw = "bountyhunter"
ROLE.name = "Bounty Hunter"
ROLE.nameplural = "Bounty Hunters"
ROLE.nameext = "a Bounty Hunter"
ROLE.nameshort = "bhu"

ROLE.desc = [[You are a {role}!

You are on the {innocent} team. Detectives can place bounties on terrorists, earn
a credit by killing the target. Press {menukey} to spend the credit!]]

ROLE.team = ROLE_TEAM_INNOCENT

ROLE.shop = {"weapon_ttt_stungun", "weapon_ttt_sipistol", "weapon_ttt_health_station", "item_armor"}
ROLE.loadout = {}
ROLE.startingcredits = 0
ROLE.canlootcredits = false

ROLE.translations = {}

ROLE.selectionpredicate = function()
    for _, ply in pairs(player.GetAll()) do
        if ply:IsDetectiveTeam() then
            return true
        end
    end
end

RegisterRole(ROLE)

if SERVER then
    AddCSLuaFile()

    hook.Add("TTTUpdateRoleState", "Bounty Hunter ConVar Edits", function()
        ROLE.canlootcredits = ROLE.ConvarCanPickUpCredits:GetBool()

        if not ROLE.ConvarSpawnWithRadar:GetBool() then
            table.insert(ROLE.shop, "item_radar")
        end
    end)
end