--[[
Styles
1: The rat does heavily-reduced damage against traitors - enough that in rare circumstances they could win gun fights, but so low that their damage is almost a non-factor to the traitors.
    If the damage scaling is able to be demonstrated to others (thus proving their role as the Rat), this could ruin the round for traitors (be cautionary when setting the damage scaling).
2: The rat does regular damage against traitors, but cannot deal the final blow against them, so if they are the final innocent alive, a traitor's win is nearly guarnateed. This avoids
    the demonstration problem of style 1, but incentivizes an aggressive appraoch for the rat (which is not fully intended), and cannot account for poorly-coded workshop weapons that fail
    to set the attacker entity correctly, which could rarely fail to prevent traitor death.
3: The rat does regular damage against traitors, no additional fluff. One innocent starts the game knowing who the traitors are, and gets to execute them on sight. Probably don't use this
    style unless you want intense pressure on the traitors with this role active (maybe your server's setup calls for extra traitors!).

Scoreboard ConVar explanation:
    If the rat sees all the traitors the instant the round begins from the scoreboard, they may be incentivized to immediately call out who they all are, which may introduce an un-fun dynamic
    that ruins the standard play of TTT. If the traitors are hidden from the Rat's scoreboard, the Rat must instead discover who the traitors are by running into the player as they navigate
    the map, and remember who that person is for the duration of the round. This puts the rat in harm's way in order to glean any meaningful information, and make the role more fun & interesting.
]]

--// Logan Christianson

local ROLE = {}

if SERVER then
    ROLE.ConvarRatDamageStyleOneReduction = CreateConVar("ttt_rat_damage_scaling", "0.25", FCVAR_NONE, "If ttt_rat_damage_style is 1, controls how much rat damage against traitors is scalled by, default is 0.25", 0.01, 1)
end
ROLE.ConvarRatShowTraitorsOnScoreboard = CreateConVar("ttt_rat_show_traitors_scoreboard", "0", FCVAR_REPLICATED, "If set to 1, shows all the traitors in the Rat's scoreboard, default is 0", 0, 1)
ROLE.ConvarRatDamageStyle = CreateConVar("ttt_rat_damage_style", "1", FCVAR_REPLICATED, "Controls how the Rat can damage traitors, lending to different gameplay. See workshop page for breakdown. 1: Reduced (default), 2: Full but can't kill, 3: Full and can kill", 1, 3)

ROLE.nameraw = "rat"
ROLE.name = "Rat"
ROLE.nameplural = "Rats"
ROLE.nameext = "a Rat"
ROLE.nameshort = "rat"

ROLE.desc = [[You are a {role}!

You are on the {innocent} team. You can see the traitors and appears as one to them.
Depending on who kills you, your corpse will instead show as innocent or traitor.]]

ROLE.team = ROLE_TEAM_INNOCENT

ROLE.shop = {}
ROLE.loadout = {}

ROLE.translations = {}

RegisterRole(ROLE)

if SERVER then
    AddCSLuaFile()
end