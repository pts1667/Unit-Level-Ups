local flareupWepID = UnitDefNames["tankraid"].weapons[1].weaponDef
local flamePopTimers = {}

local utils = VFS.Include("luarules/configs/perkfuncs/utils.lua")
local getGoodClusterProjectilePosition = utils.getGoodClusterProjectilePosition
local getRandomTargetInRange = utils.getRandomTargetInRange
local getClusterRange = utils.getClusterRange

return {
  onPick = function (unitID)
    GG.PrepareUnitClusterWeapons(unitID)
  end,
  onDamage = function (unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, projectileID, attackerID, attackerDefID, attackerTeam)
    if damage < 20.0 then
      return
    end

    flamePopTimers[attackerID] = flamePopTimers[attackerID] or {}
    local oldDmg = (flamePopTimers[attackerID][unitID] and flamePopTimers[attackerID][unitID].dmg) or 0.0
    if damage >= oldDmg then
      flamePopTimers[attackerID][unitID] = {
        start = Spring.GetGameFrame(),
        time = 180,
        dmg = damage * 0.2
      }
      GG.PerkRegisterOnTick(attackerID, "flamePop")
    end
  end,
  onTick = function (unitID)
    local frame = Spring.GetGameFrame()
    for victim,timerInfo in pairs(flamePopTimers[unitID]) do
      if (not Spring.ValidUnitID(victim)) or Spring.GetUnitIsDead(unitID) then
        return
      end
      if ((frame - timerInfo.start) % 30.0) < 0.1 then
        timerInfo.time = timerInfo.time - 30
        local x,y,z = Spring.GetUnitPosition(victim)
        local cond = function (candidateUnit)
          return not (candidateUnit == victim)
        end
        local range = getClusterRange(unitID, WeaponDefs[flareupWepID])
        local target = getRandomTargetInRange(x, y, z, range, Spring.GetUnitAllyTeam(unitID), cond)
        if target then
          local projPos,projVelNorm = getGoodClusterProjectilePosition(victim, target)
          local wd = WeaponDefs[flareupWepID]
          local startVelMag = (wd.startVelocity or wd.weaponVelocity or (range * 0.3)) * 0.1
          local projVel = {projVelNorm.x * startVelMag, projVelNorm.y * startVelMag, projVelNorm.z * startVelMag}
          local projID = Spring.SpawnProjectile(flareupWepID, { pos = projPos, owner = unitID, team = Spring.GetUnitTeam(unitID)})
          Spring.SetProjectileTarget(projID, target, string.byte('u'))
          Spring.SetProjectileVelocity(projID, projVel[1], projVel[2], projVel[3])
          if timerInfo.time < 0.1 then
            flamePopTimers[unitID][victim] = nil
          end
        end
      end
    end

    if frame % 4 < 0.1 then
      local count = 0
      for _,_ in pairs(flamePopTimers[unitID]) do
        count = count + 1
      end

      if count == 0 then
        flamePopTimers[unitID] = nil
        GG.PerkDelistOnTick(unitID, "flamePop")
      end
    end
  end
}