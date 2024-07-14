--[[
    A traitor with no shop(?) but is immune from all (default) detective effects.
    - Cannot be seen on radar
    - Does not leave traceable DNA (or it goes "bad" when used?)
    - Role-specific effects are not triggered (damages paladin with explosives, is not tracked by bounty hunter, does not get one-shot by sheriff, etc)
]]

local role = {}

ROLE.nameraw = "outlaw"
ROLE.name = "Outlaw"
ROLE.nameplural = "Outlaws"
ROLE.nameext = "an Outlaw"
ROLE.nameshort = "otl"

ROLE.desc = [[You are a {role}!

You are on the {traitor} team. You are immune to detective effects,
such as DNA or their Radar, but do not have access to a shop.]]

ROLE.team = ROLE_TEAM_TRAITOR

ROLE.shop = {}
ROLE.loadout = {}
ROLE.startingcredits = 0
ROLE.canlootcredits = false

ROLE.translations = {}

RegisterRole(ROLE)

if SERVER then
    AddCSLuaFile()
end