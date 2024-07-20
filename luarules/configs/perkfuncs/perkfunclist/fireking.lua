return {
  onPreDamaged = function (unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
    if weaponID == -4 or (weaponID > 0 and WeaponDefs[weaponID].customParams.setunitsonfire) then
      local h,mh = Spring.GetUnitHealth(unitID)
      Spring.SetUnitHealth(unitID, math.min(mh, h + damage))
      return 0.0
    end

    return 1.0
  end
}