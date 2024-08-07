-- Logan Christianson

local ROLE = {}

ROLE.nameraw = "sheriff"
ROLE.name = "Sheriff"
ROLE.nameplural = "Sheriffs"
ROLE.nameext = "a Sheriff"
ROLE.nameshort = "srf"

ROLE.desc = [[You are a {role}!

You are unable to wield primary weapons, but all secondary

weapons have become more powerful in your hands!]]

ROLE.team = ROLE_TEAM_DETECTIVE

-- Sheriffs cannot hold slot 3 weapons, even if they buy them. Do not place primary/slot 3/WEAPON_HEAVY type weapons in their shop
ROLE.shop = {"item_armor", "weapon_ttt_binoculars", "weapon_ttt_defuser", "weapon_ttt_health_station", "weapon_ttt_cse", "weapon_ttt_teleport",}
ROLE.loadout = {}
ROLE.translations = {}

RegisterRole(ROLE)

if SERVER then
    AddCSLuaFile()
end