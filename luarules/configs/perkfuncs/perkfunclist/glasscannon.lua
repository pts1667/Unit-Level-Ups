return {
    onPick = function (unitID)
      local unitDefID = Spring.GetUnitDefID(unitID)
      local experience = Spring.GetUnitExperience(unitID)
      GG.Attributes.AddEffect(unitID, "glass_cannon", {
        range = 1.5,
        sense = 2.0,
      })
      GG.SetStats(unitID, UnitDefs[unitDefID], experience)
    end,
    onStatChange = function (unitID)
      Spring.SetUnitMaxHealth(unitID, 10)
    end,
    onPreDamage = function (unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
      return 2.0
    end
}