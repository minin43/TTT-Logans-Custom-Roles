--[[
Detective who can only use sidearms, but sidearm damage is buffed. Maybe has a fun effect where the first shot within the first 1 second of equipping a sidearm will 1-shot anyone instead?
]]
-- Logan Christianson

local ROLE = {}

ROLE.nameraw = "sheriff"
ROLE.name = "Sheriff"
ROLE.nameplural = "Sheriffs"
ROLE.nameext = "a Sheriff"
ROLE.nameshort = "srf"

ROLE.desc = [[You are a {role}! You are on the {innocent} team.

]]

ROLE.team = ROLE_TEAM_INNOCENT

ROLE.shop = {}
ROLE.loadout = {}
ROLE.translations = {}

RegisterRole(ROLE)

if SERVER then
    AddCSLuaFile()
end