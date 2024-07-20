return {
  onPick = function (unitID)
    GG.AddStackQueue(unitID, "fastAndHeavy", 150, 33)
  end,
  onDamage = function (unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, projectileID, attackerID, attackerDefID, attackerTeam)
    if weaponID > 0 then
      GG.AddStack(attackerID, "fastAndHeavy")
      GG.PerkRegisterOnTick(attackerID, "fastAndHeavy")
    end
  end,
  onTick = function (unitID)
    local numStacks = GG.GetNumStacks(unitID, "fastAndHeavy")
    GG.Attributes.AddEffect(unitID, "fast_and_heavy", {
      reload = 1.0 + (numStacks * 0.03)
    })

    if numStacks == 0 then
      GG.PerkDelistOnTick(unitID, "fastAndHeavy")
      GG.Attributes.RemoveEffect("fast_and_heavy")
    end
  end
}