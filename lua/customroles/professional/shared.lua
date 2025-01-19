-- Logan Christianson

local ROLE = {}

if SERVER then
    ROLE.ConvarProfessionalAmmoOnWepPurchase = CreateConVar("ttt_professional_ammo_on_weapon_purchase", "1", FCVAR_NONE, "Whether purchased weapons are provided with maximum ammo, default is 1 (extra ammo provided)", 0, 1)
end
ROLE.ConvarProfessionalCanShareCredits = CreateConVar("ttt_professional_can_share_credits", "0", FCVAR_REPLICATED, "Whether the Professional is allowed to share their credits with other traitors, default is 0 (disallowed)", 0, 1)
ROLE.ConvarProfessionalDamageBuff = CreateConVar("ttt_professional_damage_buff", "1.25", FCVAR_REPLICATED, "How much to scale the Professional's bullet damage by, default is 1.25", 1, 2)

ROLE.nameraw = "professional"
ROLE.name = "Professional"
ROLE.nameplural = "Professionals"
ROLE.nameext = "a Professional"
ROLE.nameshort = "pro"

ROLE.shortdesc = "A traitor with a damage bonus and access to a unique shop containing all standard weapons."
ROLE.desc = [[You are a {role}! {comrades}

Press {menukey} to access a unique shop containing all ground-

spawning weapons and ammo refills for them.]]

ROLE.team = ROLE_TEAM_TRAITOR

ROLE.shop = {"item_armor", "item_radar"}
ROLE.loadout = {}

ROLE.translations = {}

RegisterRole(ROLE)

if SERVER then
    AddCSLuaFile()
end

function ProfessionalIsValidCustomWeaponBase(weapon)
    return weapon.WeaponID and weapon.Primary -- What else?
end

local plymeta = FindMetaTable("Player")
if not plymeta then return end

function plymeta:ProfessionalCanRefillAmmoByWeaponClass(wepClass)
    local wepTable = weapons.Get(wepClass)
    local ammoDefaults = {["SMG1"] = 30, ["357"] = 10, ["Pistol"] = 20, ["AlyxGun"] = 12, ["Buckshot"] = 8}

    if wepTable and (wepTable.Base == "weapon_tttbase" or ProfessionalIsValidCustomWeaponBase(wepTable)) and wepTable.Spawnable and wepTable.AutoSpawnable and wepTable.Primary.Ammo then
        local currentAmmo = self:GetAmmoCount(wepTable.Primary.Ammo)
        local ammoInBox = ammoDefaults[wepTable.Primary.Ammo] or wepTable.Primary.ClipSize or 20
        -- By default in TTT, if there's room for at least 1/4 of a box, you can add more
        return wepTable.Primary.ClipMax >= currentAmmo + math.ceil(ammoInBox * 0.25)
    end

    return false
end