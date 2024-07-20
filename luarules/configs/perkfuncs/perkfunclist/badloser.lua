local badLoserTriggered = {}

return {
    onDamaged = function (unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, projectileID, attackerID, attackerDefID, attackerTeam)
        if badLoserTriggered[unitID] then
            return
        end

        local hp, maxHp = Spring.GetUnitHealth(unitID)
        if damage >= hp then
            badLoserTriggered[unitID] = true

            local iq_stacks = (GG.HasPerk(unitID, "iQuit") and GG.GetNumStacks(unitID, "iQuit")) or 0
            local aoeHpFactor = (maxHp * 0.025) / math.max(1.0, math.log(maxHp * 0.025))
            local aoe = (aoeHpFactor + 200.0) * (1.0 + iq_stacks * 0.01)
            local dmg = maxHp * 0.5 * (1.0 + iq_stacks * 0.01)
            local x,y,z = Spring.GetUnitPosition(unitID)
            
            if aoe < 300.0 then
                Spring.SpawnCEG("nuke_150", x, y, z, 0, 0, 0, aoe)
            elseif aoe < 450.0 then
                Spring.SpawnCEG("nuke_300", x, y, z, 0, 0, 0, aoe)
            elseif aoe < 600.0 then
                Spring.SpawnCEG("nuke_450", x, y, z, 0, 0, 0, aoe)
            elseif aoe < 1000.0 then
                Spring.SpawnCEG("nuke_600", x, y, z, 0, 0, 0, aoe)
            else
                Spring.SpawnCEG("london_flat", x, y, z, 0, 0, 0, aoe)
            end

            -- this isn't documented usage
            Spring.SpawnExplosion(x, y, z, 0, 0, 0,
                dmg, -- damage
                aoe, -- crater aoe
                aoe, -- damage aoe
                0.3, -- edge effectiveness
                2.5, -- explosion speed
                0.0, -- gfx mod
                false, -- impactOnly
                false, -- ignoreOwner
                true, -- damageGround
                WeaponDefNames["jumpbomb_jumpbomb_death"].id, -- weaponDef
                -1, -- projectileID
                unitID, -- owner
                -1, -- hitUnit
                -1  -- hitFeature
            )
        end
    end
}