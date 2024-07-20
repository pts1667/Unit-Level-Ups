function gadget:GetInfo()
  return {
    name      = "Weapon dummy units",
    desc      = "Weapons for dummy units",
    author    = "Presstabstart",
    date      = "now",
    license   = "GNU GPL v2 or later",
    layer     = 0,
    enabled   = true
 }
end

if (gadgetHandler:IsSyncedCode()) then
  function createWeaponDummy(unitOrProjID, weaponName)
    local unitID = GG.CreateDummyUnit(unitOrProjID, "weapondummy_" .. string.lower(weaponName))
    return unitID
  end

  function gadget:Initialize()
    GG.CreateWeaponDummy = createWeaponDummy
  end
end