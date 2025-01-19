-- Logan Christianson

local ROLE = {}

if SERVER then
    ROLE.SheriffSecondaryWeaponDamageScaling = CreateConVar("ttt_sheriff_secondary_weapon_damage_scaling", "1.25", FCVAR_NONE, "How much pistol damage from sheriffs should be scaled by (default 1.25)", 1, 2)
    ROLE.SheriffSecondaryEquipInstantKill = CreateConVar("ttt_sheriff_secondary_equip_instant_kill", "1", FCVAR_NONE, "Whether the instant-kill effect is enabled (default 1)", 0, 1)
    ROLE.SheriffInstantKillCanChain = CreateConVar("ttt_sheriff_instant_kill_can_chain", "1", FCVAR_NONE, "Whether the instant-kill effect can be chained (default 1)", 0, 1)
end

ROLE.nameraw = "sheriff"
ROLE.name = "Sheriff"
ROLE.nameplural = "Sheriffs"
ROLE.nameext = "a Sheriff"
ROLE.nameshort = "srf"

ROLE.shortdesc = "A Detective unable to wield primary weapons, but secondary weapons are more powerful."
ROLE.desc = [[You are a {role}!

You are unable to wield primary weapons, but all secondary

weapons have become more powerful in your hands!]]

ROLE.team = ROLE_TEAM_DETECTIVE

-- Sheriffs cannot hold slot 3 weapons, even if they buy them. Do not place primary/WEAPON_HEAVY type weapons in their shop
ROLE.shop = {"item_radar", "weapon_ttt_binoculars", "weapon_ttt_defuser", "weapon_ttt_health_station", "weapon_ttt_cse", "weapon_ttt_teleport"}
ROLE.loadout = {}
ROLE.translations = {}

RegisterRole(ROLE)

if SERVER then
    AddCSLuaFile()
end