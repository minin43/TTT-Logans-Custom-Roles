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

--// Logan Christianson

local ROLE = {}

if SERVER then
    -- ROLE.ConvarTargetDamageScaling = CreateConVar("ttt_bountyhunter_damage_scaling", "1.1", FCVAR_NONE, "Damage scaling to apply to damage done by a bounty hunter to their target, default is 1.1 (or 110% damage done).", 0.1, 2)
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