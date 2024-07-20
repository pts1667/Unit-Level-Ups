local lastShot = {}

return {
  onPick = function (unitID)
    lastShot[unitID] = 0
    GG.PerkRegisterOnTick(unitID, "slowAndSteady")
  end,
  onTick = function (unitID)
    lastShot[unitID] = lastShot[unitID] + 1
  end,
  onPreDamage = function (unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
    if lastShot[attackerID] > 150.0 then
      lastShot[attackerID] = 0.0
      return 2.5
    else
      return 1.0
    end
  end,
  onDeath = function (unitID)
    lastShot[unitID] = nil
  end
}