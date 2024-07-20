local utils = VFS.Include("luarules/configs/perkfuncs/utils.lua")
local getClusterRange = utils.getClusterRange
local getRandomTargetListInRange = utils.getRandomTargetListInRange
local getGoodClusterProjectilePosition = utils.getGoodClusterProjectilePosition
local clusterLaserTimers = {}

return {
    onPick = function (unitID)
      GG.PrepareUnitClusterWeapons(unitID)
    end,
    onDeath = function (unitID)
      clusterLaserTimers[unitID] = nil
    end,
    onDamage = function (unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, projectileID, attackerID, attackerDefID, attackerTeam)
      if (weaponID < 0 or damage < 5.0) then
        return
      end

      if (not Spring.ValidUnitID(attackerID)) or (not Spring.ValidUnitID(unitID)) then
        return
      end

      local x,y,z = Spring.GetUnitPosition(unitID)
      if not z then
        return
      end

      local wd = WeaponDefs[weaponID]
      if wd.type == [[LightningCannon]] then
        local f = Spring.GetGameFrame()
        if clusterLaserTimers[attackerID] and clusterLaserTimers[attackerID] > f then
          return
        end
        
        clusterLaserTimers[attackerID] = f + 15
      end

      local range = getClusterRange(attackerID, wd)
      local unitList = getRandomTargetListInRange(x, y, z, range, Spring.GetUnitAllyTeam(attackerID), 4)
      for i=1,#unitList do
        if unitList[i] ~= unitID then
          local projPos,projVelNorm = getGoodClusterProjectilePosition(unitID, unitList[i])
          local startVelMag = (wd.startVelocity or wd.weaponVelocity or (range * 0.3)) * 0.1
          local projVel = {projVelNorm.x * startVelMag, projVelNorm.y * startVelMag, projVelNorm.z * startVelMag}
          GG.SpawnClusterProjectile({
            from = (projectileID > 0 and projectileID) or nil,
            owner = attackerID,
            weaponDefID = weaponID,
            x = projPos[1],
            y = projPos[2],
            z = projPos[3],
            damageMult = 0.4,
            targetUnit = unitList[i],
            velocityX = projVel[1],
            velocityY = projVel[2],
            velocityZ = projVel[3]
          })
        end
      end
    end
}