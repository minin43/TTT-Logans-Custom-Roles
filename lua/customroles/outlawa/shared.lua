//Logan Christianson

local ROLE = {}

ROLE.nameraw = "outlaw"
ROLE.name = "Outlaw"
ROLE.nameplural = "Outlaws"
ROLE.nameext = "an Outlaw"
ROLE.nameshort = "otl"

ROLE.desc = [[You are an {role}!

You are on the {traitor} team. You are invisible to non-friendly
Radar, leave no DNA trail, and come equipped with a disguiser,
but do not have access to a shop.]]

ROLE.team = ROLE_TEAM_TRAITOR

ROLE.shop = {}
ROLE.loadout = {"item_disg"}
ROLE.startingcredits = 0
ROLE.canlootcredits = false

ROLE.translations = {}

RegisterRole(ROLE)

if SERVER then
    AddCSLuaFile()
end