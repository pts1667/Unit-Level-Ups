return {
  onPick = function (unitID)
    GG.Attributes.AddEffect(unitID, "even_faster", {
      reload = 2.0
    })
  end,
  onPreDamage = function (unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
    return 0.4
  end
}