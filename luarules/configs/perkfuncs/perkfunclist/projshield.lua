return {
  onPick = function (unitID)
    local unitDef = UnitDefs[Spring.GetUnitDefID(unitID)]
    for _,wd in ipairs(unitDef.weapons) do
      local wdID = wd.weaponDef
      if not (WeaponDefs[wdID].type == [[BeamLaser]] or WeaponDefs[wdID].type == [[LightningCannon]]) then
        Script.SetWatchWeapon(wdID, true)
      end
    end
  end,

  onProjectileCreated = function (projectileID, projOwnerID, weaponDefID)
    if not (WeaponDefs[weaponDefID].type == [[BeamLaser]] or WeaponDefs[weaponDefID].type == [[LightningCannon]]) then
      local ownerUnitDef = Spring.GetUnitDefID(projOwnerID)
      local shieldName = (UnitDefs[ownerUnitDef].name == [[staticantinuke]] and "anti") or "tiny"
      local shieldStrength = (shieldName == "anti" and 10000) or 1000
      local unitID = GG.CreateShieldDummy({proj = projectileID}, shieldName, true)
      Spring.SetUnitShieldState(unitID, 1, true, shieldStrength)
    end
  end
}