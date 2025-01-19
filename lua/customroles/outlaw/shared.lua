// Logan Christianson

local ROLE = {}

ROLE.nameraw = "outlaw"
ROLE.name = "Outlaw"
ROLE.nameplural = "Outlaws"
ROLE.nameext = "an Outlaw"
ROLE.nameshort = "otl"

ROLE.shortdesc = "A traitor that is immune to a variety of Detective team effects."
ROLE.desc = [[You are an {role}! {comrades}

You are immune to a variety of detective effects, and spawn with

a disguiser. Press {menukey} to access it and a very basic shop.]]

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