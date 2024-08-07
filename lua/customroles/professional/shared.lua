-- Logan Christianson

local ROLE = {}

if SERVER then
    ROLE.ConvarProfessionalAmmoRefill = CreateConVar("ttt_professional_ammo_refill_all_ammo", "0", FCVAR_NONE, "Whether an 'ammo refill' restores all weapon's ammo or up to one box's worth, default is 0 (one box's worth)", 0, 1)
    ROLE.ConvarProfessionalAmmoOnWepPurchase = CreateConVar("ttt_professional_ammo_on_weapon_purchase", "0", FCVAR_NONE, "Whether purchased weapons are provided with maximum ammo, default is 0 (no extra ammo provided)", 0, 1)
end
ROLE.ConvarProfessionalCanShareCredits = CreateConVar("ttt_professional_can_share_credits", "0", FCVAR_REPLICATED, "Whether the Professional is allowed to share their credits with other traitors, default is 0 (disallowed)", 0, 1)
ROLE.ConvarProfessionalDamageBuff = CreateConVar("ttt_professional_damage_buff", "1.25", FCVAR_REPLICATED, "How much to scale the Professional's bullet damage by, default is 1.25", 1, 2)

ROLE.nameraw = "professional"
ROLE.name = "Professional"
ROLE.nameplural = "Professionals"
ROLE.nameext = "a Professional"
ROLE.nameshort = "pro"

ROLE.desc = [[You are a {role}! {comrades}

Press {menukey} to access a unique shop containing

all ground-spawning weapons and ammo refills.]]

ROLE.team = ROLE_TEAM_TRAITOR

ROLE.shop = {"item_armor", "item_radar"}
ROLE.loadout = {}

ROLE.translations = {}

RegisterRole(ROLE)

if SERVER then
    AddCSLuaFile()
end

-- The icon should probably be centered, not 1/4 the height