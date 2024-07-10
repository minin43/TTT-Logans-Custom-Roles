--[[
Role:
The Rat is an innocent (or independent) role who's win condition is an innocent victory (or where they remained alive until the end of the round).
The rat cannot deal damage to traitors but can damage everyone else. The rat can see who the traitors are, but shows up as another traitor to the traitors (a la the glitch).
When the rat is killed, all traitors are notified.

Depending on which team kills the rat, their role may show up different upon investigation:
- If a traitor kills the rat: rat shows up as generic innocent, giving potential credence to rat's claims during their life
- If an innocent kills the rat: rat shows up as a generic traitor, giving traitors additional cover
- If an independent/jester kills the rat: shows up as their true rat role
The only way I think these rules could be abused is if the rat outs themself immediately, and under supervision, goes around shooting everyone once and seeing who does and doesn't take damage.

If that is a concern, instead of doing no damage to traitors, the rat could:
- Do reduced damage to traitors
- Do heavily-reduced damage to traitors
- Do damage to traitors which they slowly recover over time
- Do "fake"/spoofed damage to traitors (I suggested this as a jester enhancement awhile ago)
- Do regular damage to traitors, but be unable to kill them (any damage which would kill them instead becomes 0)
- The mechanic is removed entirely
]]

--[[
Styles
1: The rat does heavily-reduced damage against traitors - enough that in rare circumstances they could win gun fights, but so low that their damage is almost a non-factor
]]

--// Logan Christianson

local ROLE = {}

if SERVER then
    -- ROLE.ConvarTargetDamageScaling = CreateConVar("ttt_bountyhunter_damage_scaling", "1.1", FCVAR_NONE, "Damage scaling to apply to damage done by a bounty hunter to their target, default is 1.1 (or 110% damage done).", 0.1, 2)
    ROLE.ConvarRatDamageStyle = CreateConVar("ttt_rat_damage_style", "1", FCVAR_NONE, "Controls how the Rat can damage traitors, lending to different gameplay. See workshop page for breakdown. 1: Reduced (default), 2: Full but can't kill, 3: Full and can kill", 1, 3)
    ROLE.ConvarRatDamageStyleOneReduction = CreateConVar("ttt_rat_damage_scaling", "0.25", FCVAR_NONE, "If ttt_rat_damage_style is 1, controls how much rat damage against traitors is scalled by, default is 0.25", 0.01, 1)
end

ROLE.nameraw = "rat"
ROLE.name = "Rat"
ROLE.nameplural = "Rats"
ROLE.nameext = "a Rat"
ROLE.nameshort = "rat"

ROLE.desc = [[You are a {role}!

You are on the {innocent} team. You know can see the traitors and appears as one
to them, but deal heavily reduced damage. Be careful when you out them!
Depending on who kills you, your body may show as innocent or traitor.]]

ROLE.team = ROLE_TEAM_INNOCENT

ROLE.shop = {}
ROLE.loadout = {}

ROLE.translations = {}

RegisterRole(ROLE)

if SERVER then
    AddCSLuaFile()
end