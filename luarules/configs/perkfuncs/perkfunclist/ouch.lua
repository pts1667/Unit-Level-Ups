return {
  onPreDamaged = function (unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
    if not (unitTeam == attackerTeam) then
      return 1.0
    end

    local master_ff = GG.MiniMeList[unitID] and (GG.MiniMeList[unitID] == attackerID)
    local minime_ff = GG.MiniMeMasters[unitID] and GG.MiniMeMasterTables[unitID] and (GG.MiniMeMasterTables[unitID][attackerID] or false)
    local minime_between_ff = GG.MiniMeList[unitID] and GG.MiniMeList[attackerID] and (GG.MiniMeList[unitID] == GG.MiniMeList[attackerID])
    if minime_ff or master_ff or minime_between_ff then
      return 0.0
    end
	return 1.0
  end
}