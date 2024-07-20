return {
  onPreDamaged = function (unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
    local master = GG.MiniMeList[unitID]
    if master and (weaponID > 0 or weaponID == -4) then -- todo: paralyzer stuff
      Spring.AddUnitDamage(master, damage, 0, unitID, weaponID)
      return 0.0
    end

    return 1.0
  end
}