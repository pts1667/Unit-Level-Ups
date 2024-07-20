local inED = {}

return {
    onPreDamage = function (unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
        if GG.MiniMeMasters[attackerID] then
            return 1.0
        end
        
        if not inED[attackerID] then
            inED[attackerID] = true
            Spring.AddUnitDamage(unitID, 0.0, damage * 4.0, attackerID)
            return 0.0
        else
            inED[attackerID] = nil
            return 1.0
        end
    end
}