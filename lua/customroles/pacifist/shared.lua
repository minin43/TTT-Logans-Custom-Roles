--[[
Innocent team - Killer Clown but is on the innocent team. Appears as an unknown jester to traitors (is the whole "unknown jester" itself a ConVar rule?)
]]
-- Logan Christianson

local ROLE = {}

ROLE.nameraw = "pacifist"
ROLE.name = "Pacifist"
ROLE.nameplural = "Pacifists"
ROLE.nameext = "a Pacifist"
ROLE.nameshort = "pac"

ROLE.desc = [[You are a {role}! You are on the {innocent} team.

You are unable to damage anyone unless you're the last innocent

alive, but appear as a potential Jester to traitors!]]

ROLE.team = ROLE_TEAM_INNOCENT

ROLE.shop = {}
ROLE.loadout = {}
ROLE.translations = {}

RegisterRole(ROLE)

if SERVER then
    AddCSLuaFile()
end