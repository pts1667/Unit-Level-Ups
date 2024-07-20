local utils = VFS.Include("luarules/configs/perkfuncs/utils.lua")
local getClusterRange = utils.getClusterRange
local getRandomTargetListInRange = utils.getRandomTargetListInRange
local getGoodClusterProjPosition_XYZOrigin = utils.getGoodClusterProjPosition_XYZOrigin

local spreadProjectiles = {}
local spreadFrom = {}
local projectileOwners = {}

function spawnSpreadProjectile(projectileID, projOwnerID, weaponDefID)
  local x,y,z = Spring.GetProjectilePosition(projectileID)
  if not z then
    return
  end

  if spreadFrom[projectileID] then
    return
  end

  local wd = WeaponDefs[weaponDefID]
  local range = getClusterRange(projOwnerID, wd)
  local unitList = getRandomTargetListInRange(x, y, z, range, Spring.GetUnitAllyTeam(projOwnerID), 1)
  for i=1,#unitList do
    local projPos,projVelNorm = getGoodClusterProjPosition_XYZOrigin(x, y, z, weaponDefID, unitList[i])
    local startVelMag = (wd.startVelocity or wd.weaponVelocity or (range * 0.3)) * 0.1
    local projVel = {projVelNorm.x * startVelMag, projVelNorm.y * startVelMag, projVelNorm.z * startVelMag}
    local spreadProj = GG.SpawnClusterProjectile({
      from = projectileID,
      owner = projOwnerID,
      weaponDefID = weaponDefID,
      x = projPos[1],
      y = projPos[2],
      z = projPos[3],
      damageMult = 0.4,
      targetUnit = unitList[i],
      velocityX = projVel[1],
      velocityY = projVel[2],
      velocityZ = projVel[3],
    })

    if spreadProj then
      spreadFrom[spreadProj] = true
    end
  end
end

return {
  onPick = function (unitID)
    local unitDef = UnitDefs[Spring.GetUnitDefID(unitID)]
    for _,wd in ipairs(unitDef.weapons) do
      local wdID = wd.weaponDef
      if not (WeaponDefs[wdID].type == "BeamLaser" or WeaponDefs[wdID].type == "LightningCannon") then
        Script.SetWatchWeapon(wdID, true)
      end
    end

    spreadProjectiles[unitID] = {}
    GG.PrepareUnitClusterWeapons(unitID)
    GG.PerkRegisterOnTick(unitID, "projWeapon")
  end,

  onProjectileCreated = function (projectileID, projOwnerID, weaponDefID)
    if (not Spring.ValidUnitID(projOwnerID)) or weaponDefID < 0 then
      return
    end

    projectileOwners[projectileID] = projOwnerID
    spreadProjectiles[projOwnerID][projectileID] = {
      wdID = weaponDefID,
      tickCount = 0
    }
  end,

  onProjectileDeath = function (projectileID)
    local ownerID = projectileOwners[projectileID]
    projectileOwners[projectileID] = nil
    spreadFrom[projectileID] = nil

    if spreadProjectiles[ownerID] then
      spreadProjectiles[ownerID][projectileID] = nil
    end
  end,

  onDeath = function (unitID)
    if spreadProjectiles[unitID] then
      for projID,projInfo in pairs(spreadProjectiles[unitID]) do
        projectileOwners[projID] = nil
      end

      spreadProjectiles[unitID] = nil
    end
  end,

  onTick = function (unitID)
    for projID,projInfo in pairs(spreadProjectiles[unitID]) do
      local currentTick = projInfo.tickCount + 1
      local wd = WeaponDefs[projInfo.wdID]
      local reload = math.min(100, wd.reload * 300)

      if currentTick > reload then
        projInfo.tickCount = 0
        spawnSpreadProjectile(projID, unitID, projInfo.wdID)
      else
        projInfo.tickCount = currentTick
      end
    end
  end
}