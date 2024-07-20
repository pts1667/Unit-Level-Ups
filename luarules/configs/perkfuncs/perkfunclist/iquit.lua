local maxHPs = {}

return {
    onPick = function (unitID)
        GG.AddStackQueue(unitID, "iQuit", 99999999, 200)
        maxHPs[unitID] = Spring.GetUnitHealth(unitID)

        GG.PerkRegisterOnTick(unitID, "iQuit")
    end,
    onTick = function (unitID)
        maxHPs[unitID] = math.min(Spring.GetUnitHealth(unitID), maxHPs[unitID])
        Spring.SetUnitHealth(unitID, maxHPs[unitID])
    end,
    onDamaged = function (unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, projectileID, attackerID, attackerDefID, attackerTeam)
        if weaponID < 0 then
            return
        end

        GG.AddStack(unitID, "iQuit")
    end,
    onDamage = function (unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, projectileID, attackerID, attackerDefID, attackerTeam)
        if weaponID < 0 then
            return
        end

        if GG.GetNumStacks(attackerID, "iQuit") > 0 then
            GG.PopStack(attackerID, "iQuit")
        end
    end,
}